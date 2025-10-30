{{ config(
    materialized='incremental',
    unique_key='event_id',
    on_schema_change='sync_all_columns'
) }}

-- Silver layer transformation for Billing Events data
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
    
    {% if is_incremental() %}
    WHERE UPDATE_TIMESTAMP > (SELECT MAX(UPDATE_TIMESTAMP) FROM {{ this }})
    {% endif %}
),

cleansed_billing_events AS (
    SELECT 
        TRIM(EVENT_ID) AS event_id,
        TRIM(USER_ID) AS user_id,
        CASE 
            WHEN UPPER(TRIM(EVENT_TYPE)) IN ('SUBSCRIPTION', 'UPGRADE', 'DOWNGRADE', 'REFUND')
            THEN INITCAP(TRIM(EVENT_TYPE))
            ELSE 'Subscription'
        END AS event_type,
        AMOUNT AS transaction_amount,
        EVENT_DATE AS transaction_date,
        'Credit Card' AS payment_method,
        'USD' AS currency_code,
        CONCAT('INV-', EVENT_ID, '-', DATE_PART('year', EVENT_DATE)) AS invoice_number,
        CASE 
            WHEN AMOUNT > 0 THEN 'Completed'
            WHEN AMOUNT = 0 THEN 'Pending'
            ELSE 'Failed'
        END AS transaction_status,
        LOAD_TIMESTAMP AS load_timestamp,
        UPDATE_TIMESTAMP AS update_timestamp,
        SOURCE_SYSTEM AS source_system,
        CASE 
            WHEN EVENT_ID IS NOT NULL AND USER_ID IS NOT NULL AND AMOUNT IS NOT NULL
            THEN 1.00
            ELSE 0.70
        END AS data_quality_score,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date
    FROM bronze_billing_events
    WHERE EVENT_ID IS NOT NULL
        AND AMOUNT IS NOT NULL
),

deduped_billing_events AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY event_id 
            ORDER BY update_timestamp DESC
        ) AS row_num
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
WHERE row_num = 1
