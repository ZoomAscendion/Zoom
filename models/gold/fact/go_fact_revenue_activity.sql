{{ config(
    materialized='table'
) }}

-- Revenue Activity Fact Table
-- Captures billing events and revenue metrics

WITH source_billing AS (
    SELECT 
        COALESCE(EVENT_ID, 'UNKNOWN_EVENT') AS EVENT_ID,
        COALESCE(USER_ID, 'UNKNOWN_USER') AS USER_ID,
        COALESCE(EVENT_TYPE, 'Unknown') AS EVENT_TYPE,
        COALESCE(AMOUNT, 0) AS AMOUNT,
        COALESCE(EVENT_DATE, CURRENT_DATE()) AS EVENT_DATE,
        COALESCE(SOURCE_SYSTEM, 'UNKNOWN') AS SOURCE_SYSTEM
    FROM {{ source('silver', 'si_billing_events') }}
    WHERE COALESCE(VALIDATION_STATUS, 'PASSED') = 'PASSED'
),

revenue_transformations AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY be.EVENT_ID) AS REVENUE_ACTIVITY_ID,
        -- Foreign Key Columns for BI Integration
        COALESCE(du.USER_KEY, 'UNKNOWN_USER') AS USER_KEY,
        COALESCE(dl.LICENSE_KEY, 'UNKNOWN_LICENSE') AS LICENSE_KEY,
        COALESCE(dd.DATE_KEY, CURRENT_DATE()) AS DATE_KEY,
        -- Fact Measures
        be.EVENT_DATE AS TRANSACTION_DATE,
        be.EVENT_TYPE,
        be.AMOUNT,
        'USD' AS CURRENCY,
        'Credit Card' AS PAYMENT_METHOD,
        CASE 
            WHEN be.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') 
            THEN be.AMOUNT 
            ELSE 0 
        END AS SUBSCRIPTION_REVENUE_AMOUNT,
        CASE 
            WHEN be.EVENT_TYPE IN ('One-time Purchase', 'Setup Fee') 
            THEN be.AMOUNT 
            ELSE 0 
        END AS ONE_TIME_REVENUE_AMOUNT,
        CASE 
            WHEN be.EVENT_TYPE = 'Refund' 
            THEN be.AMOUNT 
            ELSE 0 
        END AS REFUND_AMOUNT,
        be.AMOUNT * 0.08 AS TAX_AMOUNT,
        CASE 
            WHEN be.EVENT_TYPE = 'Refund' 
            THEN -be.AMOUNT 
            ELSE be.AMOUNT 
        END AS NET_REVENUE_AMOUNT,
        0 AS DISCOUNT_AMOUNT,
        1.0 AS EXCHANGE_RATE,
        be.AMOUNT AS USD_AMOUNT,
        12 AS SUBSCRIPTION_PERIOD_MONTHS,
        1 AS LICENSE_QUANTITY,
        0 AS PRORATION_AMOUNT,
        be.AMOUNT * 0.05 AS COMMISSION_AMOUNT,
        CASE 
            WHEN be.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') 
            THEN be.AMOUNT / 12 
            ELSE 0 
        END AS MRR_IMPACT,
        CASE 
            WHEN be.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') 
            THEN be.AMOUNT 
            ELSE 0 
        END AS ARR_IMPACT,
        be.AMOUNT * 10 AS CUSTOMER_LIFETIME_VALUE,
        2.5 AS CHURN_RISK_SCORE,
        'Completed' AS PAYMENT_STATUS,
        CASE 
            WHEN be.EVENT_TYPE = 'Refund' 
            THEN 'Customer Request' 
            ELSE NULL 
        END AS REFUND_REASON,
        'Online' AS SALES_CHANNEL,
        NULL AS PROMOTION_CODE,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        'SILVER_TO_GOLD_ETL' AS SOURCE_SYSTEM
    FROM source_billing be
    LEFT JOIN {{ ref('go_dim_user') }} du ON be.USER_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
    LEFT JOIN {{ ref('go_dim_date') }} dd ON be.EVENT_DATE = dd.DATE_KEY
    LEFT JOIN {{ ref('go_dim_license') }} dl ON dl.IS_CURRENT_RECORD = TRUE AND dl.LICENSE_TYPE = 'Basic'
)

SELECT 
    REVENUE_ACTIVITY_ID,
    USER_KEY,
    LICENSE_KEY,
    DATE_KEY,
    TRANSACTION_DATE,
    EVENT_TYPE,
    AMOUNT,
    CURRENCY,
    PAYMENT_METHOD,
    SUBSCRIPTION_REVENUE_AMOUNT,
    ONE_TIME_REVENUE_AMOUNT,
    REFUND_AMOUNT,
    TAX_AMOUNT,
    NET_REVENUE_AMOUNT,
    DISCOUNT_AMOUNT,
    EXCHANGE_RATE,
    USD_AMOUNT,
    SUBSCRIPTION_PERIOD_MONTHS,
    LICENSE_QUANTITY,
    PRORATION_AMOUNT,
    COMMISSION_AMOUNT,
    MRR_IMPACT,
    ARR_IMPACT,
    CUSTOMER_LIFETIME_VALUE,
    CHURN_RISK_SCORE,
    PAYMENT_STATUS,
    REFUND_REASON,
    SALES_CHANNEL,
    PROMOTION_CODE,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM
FROM revenue_transformations
