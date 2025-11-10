{{ config(
    materialized='table'
) }}

-- Gold Fact: Revenue Events Fact
-- Description: Revenue-generating events and financial transactions

WITH source_billing AS (
    SELECT 
        be.EVENT_ID,
        be.USER_ID,
        be.EVENT_TYPE,
        be.AMOUNT,
        be.EVENT_DATE,
        be.SOURCE_SYSTEM,
        be.VALIDATION_STATUS
    FROM {{ source('silver', 'si_billing_events') }} be
    WHERE (be.VALIDATION_STATUS = 'PASSED' OR be.VALIDATION_STATUS IS NULL)
      AND be.AMOUNT IS NOT NULL
      AND be.AMOUNT > 0
      AND be.EVENT_ID IS NOT NULL
),

revenue_events_metrics AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY EVENT_ID) AS REVENUE_EVENT_ID,
        COALESCE(EVENT_DATE, CURRENT_DATE) AS TRANSACTION_DATE,
        CURRENT_TIMESTAMP() AS TRANSACTION_TIMESTAMP,
        COALESCE(EVENT_TYPE, 'Unknown') AS EVENT_TYPE,
        CASE 
            WHEN UPPER(COALESCE(EVENT_TYPE, '')) LIKE '%SUBSCRIPTION%' THEN 'Subscription'
            WHEN UPPER(COALESCE(EVENT_TYPE, '')) LIKE '%LICENSE%' THEN 'License'
            WHEN UPPER(COALESCE(EVENT_TYPE, '')) LIKE '%UPGRADE%' THEN 'Upgrade'
            ELSE 'Other'
        END AS REVENUE_TYPE,
        AMOUNT AS GROSS_AMOUNT,
        ROUND(AMOUNT * 0.08, 2) AS TAX_AMOUNT,
        CASE 
            WHEN UPPER(COALESCE(EVENT_TYPE, '')) LIKE '%DISCOUNT%' THEN ROUND(AMOUNT * 0.1, 2)
            ELSE 0.00
        END AS DISCOUNT_AMOUNT,
        AMOUNT - ROUND(AMOUNT * 0.08, 2) - CASE 
            WHEN UPPER(COALESCE(EVENT_TYPE, '')) LIKE '%DISCOUNT%' THEN ROUND(AMOUNT * 0.1, 2)
            ELSE 0.00
        END AS NET_AMOUNT,
        'USD' AS CURRENCY_CODE,
        1.0000 AS EXCHANGE_RATE,
        AMOUNT AS USD_AMOUNT,
        'Credit Card' AS PAYMENT_METHOD,
        'Completed' AS PAYMENT_STATUS,
        CASE 
            WHEN UPPER(COALESCE(EVENT_TYPE, '')) LIKE '%ANNUAL%' THEN 12
            WHEN UPPER(COALESCE(EVENT_TYPE, '')) LIKE '%MONTHLY%' THEN 1
            ELSE 12
        END AS SUBSCRIPTION_PERIOD_MONTHS,
        CASE 
            WHEN UPPER(COALESCE(EVENT_TYPE, '')) LIKE '%SUBSCRIPTION%' OR UPPER(COALESCE(EVENT_TYPE, '')) LIKE '%LICENSE%' THEN TRUE
            ELSE FALSE
        END AS IS_RECURRING_REVENUE,
        AMOUNT * 24 AS CUSTOMER_LIFETIME_VALUE,
        CASE 
            WHEN UPPER(COALESCE(EVENT_TYPE, '')) LIKE '%MONTHLY%' THEN AMOUNT
            WHEN UPPER(COALESCE(EVENT_TYPE, '')) LIKE '%ANNUAL%' THEN ROUND(AMOUNT / 12, 2)
            ELSE 0.00
        END AS MRR_IMPACT,
        CASE 
            WHEN UPPER(COALESCE(EVENT_TYPE, '')) LIKE '%ANNUAL%' THEN AMOUNT
            WHEN UPPER(COALESCE(EVENT_TYPE, '')) LIKE '%MONTHLY%' THEN AMOUNT * 12
            ELSE 0.00
        END AS ARR_IMPACT,
        ROUND(AMOUNT * 0.05, 2) AS COMMISSION_AMOUNT,
        CURRENT_DATE AS LOAD_DATE,
        CURRENT_DATE AS UPDATE_DATE,
        COALESCE(SOURCE_SYSTEM, 'UNKNOWN') AS SOURCE_SYSTEM
    FROM source_billing
)

SELECT * FROM revenue_events_metrics
