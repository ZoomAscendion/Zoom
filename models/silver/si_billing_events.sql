{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (execution_id, pipeline_name, start_time, status, source_tables_processed, target_tables_updated, executed_by, execution_environment, load_date, update_date, source_system) SELECT 'SI_BILLING_EVENTS_' || TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), 'SI_BILLING_EVENTS_ETL', CURRENT_TIMESTAMP(), 'Started', 'BZ_BILLING_EVENTS', 'SI_BILLING_EVENTS', 'DBT', 'PRODUCTION', CURRENT_DATE(), CURRENT_DATE(), 'SILVER_LAYER' WHERE NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = CURRENT_SCHEMA() AND TABLE_NAME = 'SI_PIPELINE_AUDIT' AND TABLE_TYPE = 'BASE TABLE')",
    post_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (execution_id, pipeline_name, end_time, status, records_processed, executed_by, execution_environment, load_date, update_date, source_system) SELECT 'SI_BILLING_EVENTS_' || TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), 'SI_BILLING_EVENTS_ETL', CURRENT_TIMESTAMP(), 'Completed', (SELECT COUNT(*) FROM {{ this }}), 'DBT', 'PRODUCTION', CURRENT_DATE(), CURRENT_DATE(), 'SILVER_LAYER' WHERE NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = CURRENT_SCHEMA() AND TABLE_NAME = 'SI_PIPELINE_AUDIT' AND TABLE_TYPE = 'BASE TABLE')"
) }}

-- Silver Layer Billing Events Table
-- Transforms Bronze billing events data with financial validations and enrichment

WITH bronze_billing_events AS (
    SELECT *
    FROM {{ source('bronze', 'bz_billing_events') }}
),

-- Data Quality Validations
validated_billing_events AS (
    SELECT 
        b.*,
        CASE 
            WHEN b.event_id IS NULL THEN 'CRITICAL_MISSING_ID'
            WHEN b.user_id IS NULL THEN 'CRITICAL_MISSING_USER_ID'
            WHEN b.amount IS NULL THEN 'CRITICAL_MISSING_AMOUNT'
            WHEN b.event_date IS NULL THEN 'CRITICAL_MISSING_EVENT_DATE'
            WHEN b.event_date > CURRENT_DATE() THEN 'CRITICAL_FUTURE_EVENT_DATE'
            WHEN b.amount < 0 AND UPPER(b.event_type) != 'REFUND' THEN 'WARNING_NEGATIVE_AMOUNT'
            ELSE 'VALID'
        END AS data_quality_status,
        
        -- Calculate data quality score
        CASE 
            WHEN b.event_id IS NOT NULL 
                AND b.user_id IS NOT NULL
                AND b.amount IS NOT NULL
                AND b.event_date IS NOT NULL
                AND b.event_date <= CURRENT_DATE()
            THEN 1.00
            ELSE 0.70
        END AS data_quality_score,
        
        -- Row number for deduplication
        ROW_NUMBER() OVER (PARTITION BY b.event_id ORDER BY b.update_timestamp DESC, b.load_timestamp DESC) AS rn
    FROM bronze_billing_events b
    WHERE b.event_id IS NOT NULL
        AND b.user_id IS NOT NULL
        AND b.amount IS NOT NULL
        AND b.event_date IS NOT NULL
        AND b.event_date <= CURRENT_DATE()
),

-- Apply transformations
transformed_billing_events AS (
    SELECT 
        vb.event_id,
        vb.user_id,
        
        -- Standardize event type
        CASE 
            WHEN UPPER(vb.event_type) IN ('SUBSCRIPTION', 'UPGRADE', 'DOWNGRADE', 'REFUND') 
            THEN INITCAP(vb.event_type)
            ELSE 'Other'
        END AS event_type,
        
        -- Handle negative amounts for refunds
        CASE 
            WHEN vb.amount < 0 AND UPPER(vb.event_type) != 'REFUND' THEN ABS(vb.amount)
            ELSE vb.amount
        END AS transaction_amount,
        
        vb.event_date AS transaction_date,
        
        -- Derive payment method from amount patterns
        CASE 
            WHEN vb.amount >= 100 THEN 'Bank Transfer'
            WHEN vb.amount >= 50 THEN 'Credit Card'
            ELSE 'PayPal'
        END AS payment_method,
        
        'USD' AS currency_code,  -- Default to USD
        
        -- Generate invoice number
        'INV-' || vb.event_id AS invoice_number,
        
        -- Derive transaction status
        CASE 
            WHEN UPPER(vb.event_type) = 'REFUND' THEN 'Refunded'
            WHEN vb.amount > 0 THEN 'Completed'
            ELSE 'Pending'
        END AS transaction_status,
        
        -- Metadata columns
        vb.load_timestamp,
        vb.update_timestamp,
        vb.source_system,
        vb.data_quality_score,
        DATE(vb.load_timestamp) AS load_date,
        DATE(vb.update_timestamp) AS update_date
    FROM validated_billing_events vb
    WHERE vb.rn = 1
        AND vb.data_quality_status IN ('VALID', 'WARNING_NEGATIVE_AMOUNT')
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
FROM transformed_billing_events
