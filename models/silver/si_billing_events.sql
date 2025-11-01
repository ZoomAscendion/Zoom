{{ config(
    materialized='table',
    tags=['silver', 'billing']
) }}

WITH source_billing_events AS (
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
      AND AMOUNT > 0
      AND EVENT_DATE IS NOT NULL
),

validated_users AS (
    SELECT USER_ID
    FROM {{ ref('si_users') }}
),

validated_billing_events AS (
    SELECT
        sbe.EVENT_ID,
        sbe.USER_ID,
        CASE
            WHEN UPPER(TRIM(sbe.EVENT_TYPE)) IN ('SUBSCRIPTION', 'UPGRADE', 'DOWNGRADE', 'REFUND')
            THEN INITCAP(TRIM(sbe.EVENT_TYPE))
            ELSE 'Subscription'
        END AS EVENT_TYPE,
        sbe.AMOUNT AS TRANSACTION_AMOUNT,
        sbe.EVENT_DATE AS TRANSACTION_DATE,
        'Credit Card' AS PAYMENT_METHOD,
        'USD' AS CURRENCY_CODE,
        'INV-' || sbe.EVENT_ID AS INVOICE_NUMBER,
        'Completed' AS TRANSACTION_STATUS,
        sbe.LOAD_TIMESTAMP,
        sbe.UPDATE_TIMESTAMP,
        sbe.SOURCE_SYSTEM
    FROM source_billing_events sbe
    INNER JOIN validated_users vu ON sbe.USER_ID = vu.USER_ID
    WHERE sbe.EVENT_DATE <= CURRENT_DATE()
),

quality_scored_billing AS (
    SELECT
        *,
        (
            CASE WHEN EVENT_TYPE IN ('Subscription', 'Upgrade', 'Downgrade', 'Refund') THEN 0.20 ELSE 0 END +
            CASE WHEN TRANSACTION_AMOUNT > 0 THEN 0.20 ELSE 0 END +
            CASE WHEN TRANSACTION_DATE IS NOT NULL AND TRANSACTION_DATE <= CURRENT_DATE() THEN 0.20 ELSE 0 END +
            CASE WHEN LENGTH(CURRENCY_CODE) = 3 THEN 0.20 ELSE 0 END +
            CASE WHEN INVOICE_NUMBER IS NOT NULL THEN 0.20 ELSE 0 END
        ) AS DATA_QUALITY_SCORE
    FROM validated_billing_events
),

deduped_billing AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY EVENT_ID ORDER BY UPDATE_TIMESTAMP DESC) AS row_num
    FROM quality_scored_billing
)

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
    DATA_QUALITY_SCORE,
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
FROM deduped_billing
WHERE row_num = 1
  AND DATA_QUALITY_SCORE >= 0.60
