{{ config(materialized='table') }}

WITH source_data AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        EVENT_TYPE,
        AMOUNT,
        EVENT_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ ref('bz_billing_events') }}
    WHERE EVENT_ID IS NOT NULL
        AND USER_ID IS NOT NULL
),

cleaned_data AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        CASE 
            WHEN EVENT_TYPE IN ('Subscription', 'Upgrade', 'Downgrade', 'Refund') THEN EVENT_TYPE
            WHEN AMOUNT < 0 THEN 'Refund'
            ELSE 'Subscription'
        END AS EVENT_TYPE,
        ABS(AMOUNT) AS TRANSACTION_AMOUNT,
        CASE 
            WHEN EVENT_DATE > CURRENT_DATE() THEN CURRENT_DATE()
            ELSE EVENT_DATE
        END AS TRANSACTION_DATE,
        CASE 
            WHEN AMOUNT >= 1000 THEN 'Bank Transfer'
            WHEN AMOUNT >= 100 THEN 'Credit Card'
            ELSE 'PayPal'
        END AS PAYMENT_METHOD,
        'USD' AS CURRENCY_CODE,
        'INV-' || EVENT_ID AS INVOICE_NUMBER,
        CASE 
            WHEN AMOUNT > 0 THEN 'Completed'
            WHEN AMOUNT < 0 THEN 'Refunded'
            ELSE 'Pending'
        END AS TRANSACTION_STATUS,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        1.00 AS DATA_QUALITY_SCORE,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM source_data
    WHERE AMOUNT IS NOT NULL
        AND EVENT_DATE <= CURRENT_DATE()
),

deduplicated AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY EVENT_ID 
            ORDER BY UPDATE_TIMESTAMP DESC
        ) AS row_num
    FROM cleaned_data
    QUALIFY row_num = 1
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
    LOAD_DATE,
    UPDATE_DATE
FROM deduplicated
