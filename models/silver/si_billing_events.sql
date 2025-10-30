{{
  config(
    materialized='incremental',
    unique_key='event_id',
    on_schema_change='sync_all_columns'
  )
}}

WITH bronze_billing_events AS (
    SELECT *
    FROM {{ source('bronze', 'bz_billing_events') }}
    WHERE EVENT_ID IS NOT NULL
        AND USER_ID IS NOT NULL
        AND AMOUNT > 0
        AND EVENT_DATE IS NOT NULL
    {% if is_incremental() %}
        AND UPDATE_TIMESTAMP > (SELECT MAX(UPDATE_TIMESTAMP) FROM {{ this }})
    {% endif %}
),

cleaned_billing_events AS (
    SELECT 
        EVENT_ID AS event_id,
        USER_ID AS user_id,
        CASE 
            WHEN UPPER(TRIM(EVENT_TYPE)) IN ('SUBSCRIPTION', 'UPGRADE', 'DOWNGRADE', 'REFUND') 
            THEN UPPER(TRIM(EVENT_TYPE))
            ELSE 'OTHER'
        END AS event_type,
        AMOUNT AS transaction_amount,
        EVENT_DATE AS transaction_date,
        'CREDIT_CARD' AS payment_method,
        'USD' AS currency_code,
        CONCAT('INV-', EVENT_ID) AS invoice_number,
        'COMPLETED' AS transaction_status,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        0.95 AS data_quality_score,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date
    FROM bronze_billing_events
),

deduped_billing_events AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY event_id ORDER BY update_timestamp DESC) AS rn
    FROM cleaned_billing_events
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
