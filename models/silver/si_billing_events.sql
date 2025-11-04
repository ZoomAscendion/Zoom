{{ config(
    materialized='table'
) }}

-- Silver Layer Billing Events Transformation
-- Source: Bronze.BZ_BILLING_EVENTS
-- Target: Silver.SI_BILLING_EVENTS
-- Description: Transforms and validates billing and financial transaction data

WITH bronze_billing_events AS (
    SELECT 
        event_id,
        user_id,
        event_type,
        amount,
        event_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('bronze', 'bz_billing_events') }}
    WHERE event_id IS NOT NULL
      AND user_id IS NOT NULL
),

-- Data Quality Validation and Cleansing
data_quality_checks AS (
    SELECT 
        event_id,
        user_id,
        
        -- Standardize event type
        CASE 
            WHEN UPPER(event_type) IN ('SUBSCRIPTION', 'UPGRADE', 'DOWNGRADE', 'REFUND') THEN UPPER(event_type)
            ELSE 'OTHER'
        END AS event_type_clean,
        
        -- Validate transaction amount
        CASE 
            WHEN amount IS NULL THEN 0.00
            WHEN amount < 0 AND UPPER(event_type) != 'REFUND' THEN ABS(amount)
            ELSE amount
        END AS transaction_amount,
        
        -- Validate transaction date
        CASE 
            WHEN event_date IS NULL THEN DATE(load_timestamp)
            WHEN event_date > CURRENT_DATE() THEN CURRENT_DATE()
            ELSE event_date
        END AS transaction_date,
        
        load_timestamp,
        update_timestamp,
        source_system
    FROM bronze_billing_events
),

-- Add derived fields
derived_fields AS (
    SELECT 
        *,
        -- Derive payment method from amount patterns
        CASE 
            WHEN transaction_amount >= 100 THEN 'Bank Transfer'
            WHEN transaction_amount >= 20 THEN 'Credit Card'
            ELSE 'PayPal'
        END AS payment_method,
        
        -- Default currency code
        'USD' AS currency_code,
        
        -- Generate invoice number
        'INV-' || event_id AS invoice_number,
        
        -- Derive transaction status
        CASE 
            WHEN event_type_clean = 'REFUND' THEN 'Refunded'
            WHEN transaction_amount > 0 THEN 'Completed'
            ELSE 'Pending'
        END AS transaction_status
    FROM data_quality_checks
),

-- Calculate data quality score
quality_scored AS (
    SELECT 
        *,
        -- Calculate data quality score
        (
            CASE WHEN event_type_clean != 'OTHER' THEN 0.30 ELSE 0 END +
            CASE WHEN transaction_amount >= 0 THEN 0.25 ELSE 0 END +
            CASE WHEN transaction_date IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN transaction_status != 'Pending' THEN 0.20 ELSE 0 END
        ) AS data_quality_score
    FROM derived_fields
),

-- Remove duplicates keeping the most recent record
deduped_billing_events AS (
    SELECT 
        event_id,
        user_id,
        event_type_clean AS event_type,
        transaction_amount,
        transaction_date,
        payment_method,
        currency_code,
        invoice_number,
        transaction_status,
        load_timestamp,
        update_timestamp,
        source_system,
        data_quality_score,
        ROW_NUMBER() OVER (PARTITION BY event_id ORDER BY update_timestamp DESC) AS rn
    FROM quality_scored
    WHERE data_quality_score >= {{ var('dq_score_threshold') }}
)

SELECT 
    event_id,
    user_id,
    event_type,
    transaction_amount,
    transaction_date,
    payment_method,
    currency_code,
    invoice_number,
    transaction_status,
    load_timestamp,
    update_timestamp,
    source_system,
    data_quality_score,
    DATE(load_timestamp) AS load_date,
    DATE(update_timestamp) AS update_date
FROM deduped_billing_events
WHERE rn = 1
  AND transaction_amount >= 0
