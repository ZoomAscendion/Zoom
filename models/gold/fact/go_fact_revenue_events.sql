{{ config(
    materialized='table'
) }}

-- Revenue events fact table with financial metrics
-- Tracks billing events, subscriptions, and revenue attribution

WITH source_billing AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        EVENT_TYPE,
        AMOUNT,
        EVENT_DATE,
        SOURCE_SYSTEM
    FROM DB_POC_ZOOM.SILVER.SI_BILLING_EVENTS
    WHERE VALIDATION_STATUS = 'PASSED'
      AND EVENT_ID IS NOT NULL
      AND USER_ID IS NOT NULL
),

revenue_events_fact AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY be.EVENT_ID) AS REVENUE_EVENT_ID,
        1 AS DATE_ID,
        1 AS LICENSE_ID,
        1 AS USER_DIM_ID,
        be.EVENT_ID AS BILLING_EVENT_ID,
        be.EVENT_DATE AS TRANSACTION_DATE,
        be.EVENT_DATE::TIMESTAMP_NTZ AS TRANSACTION_TIMESTAMP,
        be.EVENT_TYPE,
        CASE 
            WHEN be.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') THEN 'Recurring'
            WHEN be.EVENT_TYPE IN ('One-time Purchase', 'Setup Fee') THEN 'One-time'
            ELSE 'Other'
        END AS REVENUE_TYPE,
        be.AMOUNT AS GROSS_AMOUNT,
        be.AMOUNT * 0.08 AS TAX_AMOUNT,
        0.00 AS DISCOUNT_AMOUNT,
        be.AMOUNT * 0.92 AS NET_AMOUNT,
        'USD' AS CURRENCY_CODE,
        1.0 AS EXCHANGE_RATE,
        be.AMOUNT AS USD_AMOUNT,
        'Credit Card' AS PAYMENT_METHOD,
        CASE 
            WHEN be.EVENT_TYPE IN ('Subscription', 'Renewal') THEN 12
            ELSE 0
        END AS SUBSCRIPTION_PERIOD_MONTHS,
        1 AS LICENSE_QUANTITY,
        0.00 AS PRORATION_AMOUNT,
        be.AMOUNT * 0.05 AS COMMISSION_AMOUNT,
        CASE 
            WHEN be.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') THEN be.AMOUNT / 12
            ELSE 0
        END AS MRR_IMPACT,
        CASE 
            WHEN be.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') THEN be.AMOUNT
            ELSE 0
        END AS ARR_IMPACT,
        be.AMOUNT * 5 AS CUSTOMER_LIFETIME_VALUE,
        1.0 AS CHURN_RISK_SCORE,
        'Successful' AS PAYMENT_STATUS,
        NULL AS REFUND_REASON,
        'Online' AS SALES_CHANNEL,
        NULL AS PROMOTION_CODE,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        be.SOURCE_SYSTEM
    FROM source_billing be
)

SELECT * FROM revenue_events_fact
