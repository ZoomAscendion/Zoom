{{ config(
    materialized='incremental',
    unique_key='event_id',
    on_schema_change='sync_all_columns'
) }}

-- Silver layer transformation for Billing Events
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
        AND USER_ID IS NOT NULL
        AND EVENT_DATE IS NOT NULL
        AND EVENT_DATE <= CURRENT_DATE()
        AND EVENT_DATE >= '2011-01-01'
        AND AMOUNT IS NOT NULL
),

-- Data Quality Checks and Cleansing
cleansed_billing_events AS (
    SELECT 
        TRIM(EVENT_ID) as EVENT_ID,
        TRIM(USER_ID) as USER_ID,
        CASE 
            WHEN UPPER(EVENT_TYPE) IN ('SUBSCRIPTION', 'UPGRADE', 'DOWNGRADE', 'REFUND') 
            THEN INITCAP(EVENT_TYPE)
            ELSE 'Other'
        END as EVENT_TYPE,
        ABS(AMOUNT) as TRANSACTION_AMOUNT,
        EVENT_DATE as TRANSACTION_DATE,
        'Credit Card' as PAYMENT_METHOD,
        'USD' as CURRENCY_CODE,
        CONCAT('INV-', EVENT_ID, '-', DATE_PART('year', EVENT_DATE)) as INVOICE_NUMBER,
        CASE 
            WHEN AMOUNT > 0 THEN 'Completed'
            WHEN AMOUNT = 0 THEN 'Pending'
            ELSE 'Failed'
        END as TRANSACTION_STATUS,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM bronze_billing_events
    WHERE (EVENT_TYPE != 'Refund' AND AMOUNT >= 0) OR (EVENT_TYPE = 'Refund')
),

-- Remove duplicates
deduped_billing_events AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY EVENT_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) as rn
    FROM cleansed_billing_events
),

-- Calculate data quality score
final_billing_events AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        EVENT_TYPE,
        TRANSACTION_AMOUNT,
        TRANSACTION_DATE,
        PAYMENT_METHOD,
        CURRENCY_CODE,
        INVOICE_NUMBER,
        TRANSACTION_STATUS,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Calculate data quality score
        ROUND(
            (CASE WHEN EVENT_TYPE != 'Other' THEN 0.2 ELSE 0 END +
             CASE WHEN TRANSACTION_AMOUNT >= 0 THEN 0.3 ELSE 0 END +
             CASE WHEN TRANSACTION_DATE IS NOT NULL THEN 0.2 ELSE 0 END +
             CASE WHEN PAYMENT_METHOD IS NOT NULL THEN 0.15 ELSE 0 END +
             CASE WHEN CURRENCY_CODE IS NOT NULL THEN 0.15 ELSE 0 END), 2
        ) as DATA_QUALITY_SCORE,
        DATE(LOAD_TIMESTAMP) as LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) as UPDATE_DATE
    FROM deduped_billing_events
    WHERE rn = 1
)

SELECT * FROM final_billing_events

{% if is_incremental() %}
    WHERE UPDATE_TIMESTAMP > (SELECT COALESCE(MAX(UPDATE_TIMESTAMP), '1900-01-01') FROM {{ this }})
{% endif %}
