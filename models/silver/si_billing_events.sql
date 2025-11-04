{{ config(
    materialized='table'
) }}

-- Silver Billing Events Table - Validated billing transaction data
-- Includes payment method derivation and transaction status

WITH bronze_billing_events AS (
    SELECT *
    FROM {{ source('bronze', 'bz_billing_events') }}
),

-- Data Quality Validation and Cleansing
billing_events_cleaned AS (
    SELECT
        bbe.event_id,
        bbe.user_id,
        
        -- Standardize event type
        CASE 
            WHEN bbe.event_type IN ('Subscription', 'Upgrade', 'Downgrade', 'Refund') 
                THEN bbe.event_type
            WHEN bbe.amount < 0 THEN 'Refund'
            ELSE 'Subscription'
        END AS event_type,
        
        -- Validate transaction amount
        CASE 
            WHEN bbe.amount IS NULL THEN 0.00
            WHEN bbe.amount < 0 AND bbe.event_type != 'Refund' THEN ABS(bbe.amount)
            ELSE bbe.amount
        END AS transaction_amount,
        
        -- Validate transaction date
        CASE 
            WHEN bbe.event_date IS NULL THEN CURRENT_DATE()
            WHEN bbe.event_date > CURRENT_DATE() THEN CURRENT_DATE()
            ELSE bbe.event_date
        END AS transaction_date,
        
        -- Derive payment method from event type and amount
        CASE 
            WHEN bbe.amount >= 100 THEN 'Bank Transfer'
            WHEN bbe.amount >= 50 THEN 'Credit Card'
            ELSE 'PayPal'
        END AS payment_method,
        
        -- Default currency code
        'USD' AS currency_code,
        
        -- Generate invoice number
        'INV-' || bbe.event_id AS invoice_number,
        
        -- Derive transaction status
        CASE 
            WHEN bbe.amount IS NULL OR bbe.amount = 0 THEN 'Failed'
            WHEN bbe.event_type = 'Refund' THEN 'Refunded'
            WHEN bbe.amount > 0 THEN 'Completed'
            ELSE 'Pending'
        END AS transaction_status,
        
        -- Metadata columns
        bbe.load_timestamp,
        bbe.update_timestamp,
        bbe.source_system,
        
        -- Calculate data quality score
        CASE 
            WHEN bbe.event_id IS NOT NULL 
                AND bbe.user_id IS NOT NULL
                AND bbe.event_type IS NOT NULL
                AND bbe.amount IS NOT NULL
                AND bbe.event_date IS NOT NULL
                THEN 1.00
            WHEN bbe.event_id IS NOT NULL AND bbe.user_id IS NOT NULL
                THEN 0.75
            WHEN bbe.event_id IS NOT NULL
                THEN 0.50
            ELSE 0.25
        END AS data_quality_score,
        
        DATE(bbe.load_timestamp) AS load_date,
        DATE(bbe.update_timestamp) AS update_date
        
    FROM bronze_billing_events bbe
    WHERE bbe.event_id IS NOT NULL  -- Block records without event_id
        AND bbe.user_id IS NOT NULL -- Block records without user_id
),

-- Remove duplicates - keep latest record
billing_events_deduped AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY event_id ORDER BY update_timestamp DESC) AS rn
    FROM billing_events_cleaned
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
    load_date,
    update_date
FROM billing_events_deduped
WHERE rn = 1
    AND data_quality_score >= 0.50  -- Only high quality records
    AND transaction_amount >= 0     -- Ensure non-negative amounts (except refunds)
