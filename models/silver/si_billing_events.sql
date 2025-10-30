{{
    config(
        materialized='incremental',
        unique_key='event_id',
        on_schema_change='sync_all_columns'
    )
}}

-- Silver Layer Billing Events Transformation
-- Source: Bronze.BZ_BILLING_EVENTS
-- Target: Silver.SI_BILLING_EVENTS

WITH bronze_billing_events AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        EVENT_TYPE,
        AMOUNT,
        EVENT_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('bronze', 'bz_billing_events') }}
    WHERE EVENT_ID IS NOT NULL
    
    {% if is_incremental() %}
        AND UPDATE_TIMESTAMP > (SELECT MAX(update_timestamp) FROM {{ this }})
    {% endif %}
),

-- Data Quality and Transformation Layer
data_quality_checks AS (
    SELECT 
        *,
        -- Data Quality Score Calculation
        CASE 
            WHEN EVENT_ID IS NULL THEN 0.0
            WHEN USER_ID IS NULL THEN 0.3
            WHEN EVENT_TYPE NOT IN ('Subscription', 'Upgrade', 'Downgrade', 'Refund') THEN 0.4
            WHEN (EVENT_TYPE != 'Refund' AND AMOUNT <= 0) OR (EVENT_TYPE = 'Refund' AND AMOUNT >= 0) THEN 0.5
            WHEN EVENT_DATE IS NULL OR EVENT_DATE > CURRENT_DATE() THEN 0.6
            ELSE 1.0
        END AS data_quality_score,
        
        -- Row Number for Deduplication
        ROW_NUMBER() OVER (PARTITION BY EVENT_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_billing_events
),

-- Final Transformation
transformed_billing_events AS (
    SELECT 
        TRIM(EVENT_ID) AS event_id,
        TRIM(USER_ID) AS user_id,
        CASE 
            WHEN EVENT_TYPE IN ('Subscription', 'Upgrade', 'Downgrade', 'Refund') THEN EVENT_TYPE
            ELSE 'Other'
        END AS event_type,
        ABS(AMOUNT) AS transaction_amount,
        EVENT_DATE AS transaction_date,
        'Credit Card' AS payment_method,  -- Default value
        'USD' AS currency_code,  -- Default value
        CONCAT('INV-', EVENT_ID, '-', DATE_PART('year', EVENT_DATE)) AS invoice_number,
        CASE 
            WHEN EVENT_TYPE = 'Refund' THEN 'Refunded'
            WHEN AMOUNT > 0 THEN 'Completed'
            ELSE 'Pending'
        END AS transaction_status,
        LOAD_TIMESTAMP AS load_timestamp,
        UPDATE_TIMESTAMP AS update_timestamp,
        SOURCE_SYSTEM AS source_system,
        data_quality_score,
        DATE(LOAD_TIMESTAMP) AS load_date,
        DATE(UPDATE_TIMESTAMP) AS update_date
    FROM data_quality_checks
    WHERE rn = 1  -- Remove duplicates
        AND data_quality_score > 0.0  -- Remove records with critical quality issues
        AND AMOUNT IS NOT NULL
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
