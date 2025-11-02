{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (execution_id, pipeline_name, start_time, status, source_tables_processed, target_tables_updated, executed_by, execution_environment, load_date, update_date, source_system) SELECT 'EXEC_SI_BILLING_EVENTS_' || TO_VARCHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), 'SI_BILLING_EVENTS_TRANSFORMATION', CURRENT_TIMESTAMP(), 'STARTED', 'BZ_BILLING_EVENTS', 'SI_BILLING_EVENTS', 'DBT_PIPELINE', 'PRODUCTION', CURRENT_DATE(), CURRENT_DATE(), 'DBT_PIPELINE' WHERE NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = CURRENT_SCHEMA() AND TABLE_NAME = 'SI_PIPELINE_AUDIT')",
    post_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (execution_id, pipeline_name, end_time, status, records_processed, records_inserted, executed_by, execution_environment, load_date, update_date, source_system) SELECT 'EXEC_SI_BILLING_EVENTS_' || TO_VARCHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), 'SI_BILLING_EVENTS_TRANSFORMATION', CURRENT_TIMESTAMP(), 'COMPLETED', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 'DBT_PIPELINE', 'PRODUCTION', CURRENT_DATE(), CURRENT_DATE(), 'DBT_PIPELINE' WHERE NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = CURRENT_SCHEMA() AND TABLE_NAME = 'SI_PIPELINE_AUDIT')"
) }}

-- Silver Billing Events Model
-- Transforms bronze billing data with validation and enrichment

WITH bronze_billing_events AS (
    SELECT * FROM {{ source('bronze', 'bz_billing_events') }}
),

silver_users AS (
    SELECT * FROM {{ ref('si_users') }}
),

-- Data Quality Validation
data_quality_checks AS (
    SELECT 
        *,
        -- Amount validation
        CASE 
            WHEN amount < 0 AND event_type != 'Refund' THEN 'NEGATIVE_AMOUNT_WRONG_TYPE'
            WHEN amount = 0 THEN 'ZERO_AMOUNT'
            WHEN amount > 100000 THEN 'EXCESSIVE_AMOUNT'
            ELSE 'VALID'
        END AS amount_quality_flag,
        
        -- Event type validation
        CASE 
            WHEN event_type NOT IN ('Subscription', 'Upgrade', 'Downgrade', 'Refund') THEN 'INVALID_EVENT_TYPE'
            ELSE 'VALID'
        END AS event_type_quality_flag
    FROM bronze_billing_events
    WHERE event_id IS NOT NULL
      AND user_id IS NOT NULL
),

-- Data Cleansing and Enrichment
cleansed_billing_events AS (
    SELECT 
        b.event_id,
        b.user_id,
        
        -- Corrected event type
        CASE 
            WHEN b.amount_quality_flag = 'NEGATIVE_AMOUNT_WRONG_TYPE' THEN 'Refund'
            WHEN b.event_type_quality_flag = 'VALID' THEN b.event_type
            ELSE 'Subscription'
        END AS event_type,
        
        -- Corrected transaction amount
        CASE 
            WHEN b.amount_quality_flag = 'ZERO_AMOUNT' THEN 0.01
            WHEN b.amount_quality_flag = 'EXCESSIVE_AMOUNT' THEN 9999.99
            ELSE ABS(b.amount)
        END AS transaction_amount,
        
        b.event_date AS transaction_date,
        
        -- Derived payment method
        CASE 
            WHEN b.amount <= 50 THEN 'Credit Card'
            WHEN b.amount <= 500 THEN 'Bank Transfer'
            ELSE 'Wire Transfer'
        END AS payment_method,
        
        'USD' AS currency_code,
        
        -- Generated invoice number
        'INV-' || b.event_id AS invoice_number,
        
        -- Derived transaction status
        CASE 
            WHEN b.amount_quality_flag = 'VALID' THEN 'Completed'
            WHEN b.event_type = 'Refund' THEN 'Refunded'
            ELSE 'Pending'
        END AS transaction_status,
        
        -- Silver layer metadata
        b.load_timestamp,
        b.update_timestamp,
        b.source_system,
        
        -- Data quality score
        ROUND(
            (CASE WHEN b.amount_quality_flag = 'VALID' THEN 0.4 ELSE 0.0 END +
             CASE WHEN b.event_type_quality_flag = 'VALID' THEN 0.3 ELSE 0.0 END +
             CASE WHEN u.user_id IS NOT NULL THEN 0.2 ELSE 0.0 END +
             CASE WHEN b.event_date IS NOT NULL THEN 0.1 ELSE 0.0 END), 2
        ) AS data_quality_score,
        
        -- Standard metadata
        DATE(b.load_timestamp) AS load_date,
        DATE(b.update_timestamp) AS update_date
        
    FROM data_quality_checks b
    LEFT JOIN silver_users u ON b.user_id = u.user_id
    WHERE u.user_id IS NOT NULL  -- Block billing events with invalid user references
),

-- Deduplication
deduped_billing_events AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY event_id ORDER BY update_timestamp DESC) AS rn
    FROM cleansed_billing_events
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
FROM deduped_billing_events
WHERE rn = 1
