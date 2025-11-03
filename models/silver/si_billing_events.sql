{{ config(
    materialized='table',
    on_schema_change='sync_all_columns',
    pre_hook="
        INSERT INTO {{ ref('si_pipeline_audit') }} (
            execution_id, pipeline_name, start_time, status, 
            source_tables_processed, executed_by, execution_environment,
            load_date, update_date, source_system
        )
        VALUES (
            '{{ invocation_id }}_si_billing_events', 
            'si_billing_events', 
            CURRENT_TIMESTAMP(), 
            'STARTED',
            'BZ_BILLING_EVENTS',
            '{{ var(\"audit_user\") }}',
            'PRODUCTION',
            CURRENT_DATE(),
            CURRENT_DATE(),
            'DBT_SILVER_PIPELINE'
        )
    ",
    post_hook="
        UPDATE {{ ref('si_pipeline_audit') }}
        SET 
            end_time = CURRENT_TIMESTAMP(),
            status = 'SUCCESS',
            execution_duration_seconds = DATEDIFF('second', start_time, CURRENT_TIMESTAMP()),
            target_tables_updated = 'SI_BILLING_EVENTS',
            records_processed = (SELECT COUNT(*) FROM {{ this }}),
            records_inserted = (SELECT COUNT(*) FROM {{ this }}),
            records_updated = 0,
            records_rejected = 0,
            update_date = CURRENT_DATE()
        WHERE execution_id = '{{ invocation_id }}_si_billing_events'
    "
) }}

-- Silver layer transformation for Billing Events
WITH bronze_billing_events AS (
    SELECT *
    FROM {{ source('bronze', 'bz_billing_events') }}
),

-- Data Quality Checks and Cleansing
cleansed_billing AS (
    SELECT 
        event_id,
        user_id,
        TRIM(UPPER(event_type)) AS event_type_clean,
        amount,
        event_date,
        load_timestamp,
        update_timestamp,
        source_system,
        
        -- Data Quality Validations
        CASE 
            WHEN event_id IS NULL THEN 0
            WHEN user_id IS NULL THEN 0
            WHEN amount IS NULL THEN 0
            WHEN event_date IS NULL THEN 0
            WHEN event_date > CURRENT_DATE() THEN 0
            ELSE 1
        END AS billing_valid,
        
        -- Corrected event_date if future
        CASE 
            WHEN event_date > CURRENT_DATE() THEN CURRENT_DATE()
            ELSE event_date
        END AS event_date_corrected,
        
        -- Corrected event_type for negative amounts
        CASE 
            WHEN amount < 0 AND event_type NOT LIKE '%REFUND%' THEN 'REFUND'
            ELSE event_type
        END AS event_type_corrected
        
    FROM bronze_billing_events
),

-- Remove duplicates
deduped_billing AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY event_id 
            ORDER BY update_timestamp DESC, load_timestamp DESC
        ) AS rn
    FROM cleansed_billing
    WHERE billing_valid = 1
),

-- Final transformation with derived fields
final_billing AS (
    SELECT 
        event_id,
        user_id,
        
        -- Standardize event type
        CASE 
            WHEN event_type_corrected IN ('SUBSCRIPTION', 'SUBSCRIBE', 'NEW_SUBSCRIPTION') THEN 'Subscription'
            WHEN event_type_corrected IN ('UPGRADE', 'PLAN_UPGRADE') THEN 'Upgrade'
            WHEN event_type_corrected IN ('DOWNGRADE', 'PLAN_DOWNGRADE') THEN 'Downgrade'
            WHEN event_type_corrected IN ('REFUND', 'REFUND_PAYMENT', 'CHARGEBACK') THEN 'Refund'
            ELSE 'Other'
        END AS event_type,
        
        ABS(amount) AS transaction_amount,
        event_date_corrected AS transaction_date,
        
        -- Derive payment method from amount patterns
        CASE 
            WHEN amount BETWEEN 0 AND 50 THEN 'Credit Card'
            WHEN amount BETWEEN 50 AND 200 THEN 'Bank Transfer'
            WHEN amount > 200 THEN 'PayPal'
            ELSE 'Unknown'
        END AS payment_method,
        
        'USD' AS currency_code,
        
        -- Generate invoice number
        CONCAT('INV-', event_id) AS invoice_number,
        
        -- Derive transaction status
        CASE 
            WHEN amount > 0 AND event_type_corrected NOT LIKE '%REFUND%' THEN 'Completed'
            WHEN amount < 0 OR event_type_corrected LIKE '%REFUND%' THEN 'Refunded'
            WHEN amount = 0 THEN 'Failed'
            ELSE 'Pending'
        END AS transaction_status,
        
        -- Metadata columns
        load_timestamp,
        update_timestamp,
        source_system,
        
        -- Data quality score
        CASE 
            WHEN event_id IS NOT NULL 
                AND user_id IS NOT NULL 
                AND amount IS NOT NULL 
                AND event_date_corrected IS NOT NULL
            THEN 1.00
            ELSE 0.75
        END AS data_quality_score,
        
        DATE(load_timestamp) AS load_date,
        DATE(update_timestamp) AS update_date
        
    FROM deduped_billing
    WHERE rn = 1
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
FROM final_billing
