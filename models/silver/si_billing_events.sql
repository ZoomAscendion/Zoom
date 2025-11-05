{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

-- Silver Billing Events transformation with data quality checks
WITH bronze_billing_events AS (
    SELECT *
    FROM {{ ref('bz_billing_events') }}
    WHERE EVENT_ID IS NOT NULL
      AND TRIM(EVENT_ID) != ''
      AND USER_ID IS NOT NULL
      AND EVENT_TYPE IS NOT NULL
      AND AMOUNT > 0
      AND EVENT_DATE IS NOT NULL
      AND EVENT_DATE >= '2020-01-01'
      AND EVENT_DATE <= DATEADD('day', 30, CURRENT_DATE)
),

valid_users AS (
    SELECT DISTINCT USER_ID
    FROM {{ ref('si_users') }}
),

filtered_billing_events AS (
    SELECT bbe.*
    FROM bronze_billing_events bbe
    INNER JOIN valid_users vu ON bbe.USER_ID = vu.USER_ID
    WHERE UPPER(TRIM(bbe.EVENT_TYPE)) IN ('SUBSCRIPTION', 'UPGRADE', 'DOWNGRADE', 'REFUND', 'CHARGEBACK', 'PAYMENT')
),

deduped_billing_events AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY EVENT_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM filtered_billing_events
),

final_billing_events AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        UPPER(TRIM(EVENT_TYPE)) AS EVENT_TYPE,
        AMOUNT,
        EVENT_DATE,
        'USD' AS CURRENCY_CODE,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        SOURCE_SYSTEM,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP
    FROM deduped_billing_events
    WHERE rn = 1
)

SELECT * FROM final_billing_events
