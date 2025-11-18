{{ config(
    materialized='table'
) }}

-- Revenue Activity Fact Table
-- Captures billing events and revenue metrics

WITH source_billing AS (
    SELECT *
    FROM {{ source('silver', 'si_billing_events') }}
    WHERE COALESCE(VALIDATION_STATUS, 'PASSED') = 'PASSED'
),

source_licenses AS (
    SELECT *
    FROM {{ source('silver', 'si_licenses') }}
    WHERE COALESCE(VALIDATION_STATUS, 'PASSED') = 'PASSED'
),

unique_users AS (
    SELECT DISTINCT 
        USER_ID, 
        USER_KEY,
        ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY UPDATE_DATE DESC) AS rn
    FROM {{ ref('go_dim_user') }}
    WHERE IS_CURRENT_RECORD = TRUE
),

unique_licenses AS (
    SELECT DISTINCT 
        sl.ASSIGNED_TO_USER_ID, 
        sl.LICENSE_TYPE, 
        dl.LICENSE_KEY,
        ROW_NUMBER() OVER (
            PARTITION BY sl.ASSIGNED_TO_USER_ID, sl.LICENSE_TYPE 
            ORDER BY COALESCE(sl.UPDATE_TIMESTAMP, CURRENT_TIMESTAMP()) DESC, dl.UPDATE_DATE DESC
        ) AS rn
    FROM source_licenses sl
    JOIN {{ ref('go_dim_license') }} dl ON COALESCE(sl.LICENSE_TYPE, 'Unknown License') = dl.LICENSE_TYPE 
                                        AND dl.IS_CURRENT_RECORD = TRUE
    WHERE COALESCE(sl.START_DATE, CURRENT_DATE()) <= CURRENT_DATE() 
      AND (sl.END_DATE IS NULL OR sl.END_DATE >= CURRENT_DATE())
),

revenue_transformations AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY COALESCE(be.EVENT_ID, 'UNKNOWN_EVENT')) AS REVENUE_ACTIVITY_ID,
        -- Foreign Key Columns for BI Integration
        COALESCE(du.USER_KEY, 'UNKNOWN_USER') AS USER_KEY,
        COALESCE(dl.LICENSE_KEY, 'UNKNOWN_LICENSE') AS LICENSE_KEY,
        COALESCE(dd.DATE_KEY, CURRENT_DATE()) AS DATE_KEY,
        -- Fact Measures
        COALESCE(be.EVENT_DATE, CURRENT_DATE()) AS TRANSACTION_DATE,
        COALESCE(be.EVENT_TYPE, 'Unknown') AS EVENT_TYPE,
        COALESCE(be.AMOUNT, 0) AS AMOUNT,
        'USD' AS CURRENCY,
        'Credit Card' AS PAYMENT_METHOD,
        CASE 
            WHEN COALESCE(be.EVENT_TYPE, 'Unknown') IN ('Subscription', 'Renewal', 'Upgrade') 
            THEN COALESCE(be.AMOUNT, 0) 
            ELSE 0 
        END AS SUBSCRIPTION_REVENUE_AMOUNT,
        CASE 
            WHEN COALESCE(be.EVENT_TYPE, 'Unknown') IN ('One-time Purchase', 'Setup Fee') 
            THEN COALESCE(be.AMOUNT, 0) 
            ELSE 0 
        END AS ONE_TIME_REVENUE_AMOUNT,
        CASE 
            WHEN COALESCE(be.EVENT_TYPE, 'Unknown') = 'Refund' 
            THEN COALESCE(be.AMOUNT, 0) 
            ELSE 0 
        END AS REFUND_AMOUNT,
        COALESCE(be.AMOUNT, 0) * 0.08 AS TAX_AMOUNT,
        CASE 
            WHEN COALESCE(be.EVENT_TYPE, 'Unknown') = 'Refund' 
            THEN -COALESCE(be.AMOUNT, 0) 
            ELSE COALESCE(be.AMOUNT, 0) 
        END AS NET_REVENUE_AMOUNT,
        0 AS DISCOUNT_AMOUNT,
        1.0 AS EXCHANGE_RATE,
        COALESCE(be.AMOUNT, 0) AS USD_AMOUNT,
        12 AS SUBSCRIPTION_PERIOD_MONTHS,
        1 AS LICENSE_QUANTITY,
        0 AS PRORATION_AMOUNT,
        COALESCE(be.AMOUNT, 0) * 0.05 AS COMMISSION_AMOUNT,
        CASE 
            WHEN COALESCE(be.EVENT_TYPE, 'Unknown') IN ('Subscription', 'Renewal', 'Upgrade') 
            THEN COALESCE(be.AMOUNT, 0) / 12 
            ELSE 0 
        END AS MRR_IMPACT,
        CASE 
            WHEN COALESCE(be.EVENT_TYPE, 'Unknown') IN ('Subscription', 'Renewal', 'Upgrade') 
            THEN COALESCE(be.AMOUNT, 0) 
            ELSE 0 
        END AS ARR_IMPACT,
        COALESCE(be.AMOUNT, 0) * 10 AS CUSTOMER_LIFETIME_VALUE,
        2.5 AS CHURN_RISK_SCORE,
        'Completed' AS PAYMENT_STATUS,
        CASE 
            WHEN COALESCE(be.EVENT_TYPE, 'Unknown') = 'Refund' 
            THEN 'Customer Request' 
            ELSE NULL 
        END AS REFUND_REASON,
        'Online' AS SALES_CHANNEL,
        NULL AS PROMOTION_CODE,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        'SILVER_TO_GOLD_ETL' AS SOURCE_SYSTEM
    FROM source_billing be
    LEFT JOIN unique_users du ON COALESCE(be.USER_ID, 'UNKNOWN_USER') = du.USER_ID AND du.rn = 1
    LEFT JOIN {{ ref('go_dim_date') }} dd ON COALESCE(be.EVENT_DATE, CURRENT_DATE()) = dd.DATE_KEY
    LEFT JOIN unique_licenses dl ON COALESCE(be.USER_ID, 'UNKNOWN_USER') = dl.ASSIGNED_TO_USER_ID AND dl.rn = 1
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
