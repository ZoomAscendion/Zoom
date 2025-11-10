{{ config(
    materialized='table'
) }}

-- Revenue Events Fact Table
-- Comprehensive financial transaction analytics with revenue recognition

WITH revenue_base AS (
    SELECT 
        be.EVENT_ID,
        be.USER_ID,
        be.EVENT_TYPE,
        be.AMOUNT,
        be.EVENT_DATE,
        be.SOURCE_SYSTEM
    FROM SILVER.SI_BILLING_EVENTS be
    WHERE be.VALIDATION_STATUS = 'PASSED'
        AND be.DATA_QUALITY_SCORE >= 80
        AND be.AMOUNT > 0
),

user_info AS (
    SELECT 
        USER_ID,
        PLAN_TYPE
    FROM SILVER.SI_USERS
    WHERE VALIDATION_STATUS = 'PASSED'
),

license_info AS (
    SELECT 
        ASSIGNED_TO_USER_ID,
        LICENSE_TYPE
    FROM SILVER.SI_LICENSES
    WHERE VALIDATION_STATUS = 'PASSED'
),

revenue_calculations AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY rb.EVENT_ID) AS REVENUE_EVENT_ID,
        rb.EVENT_DATE AS TRANSACTION_DATE,
        CURRENT_TIMESTAMP() AS TRANSACTION_TIMESTAMP,
        rb.EVENT_TYPE,
        -- Revenue type classification
        CASE 
            WHEN UPPER(rb.EVENT_TYPE) LIKE '%SUBSCRIPTION%' THEN 'Recurring'
            WHEN UPPER(rb.EVENT_TYPE) LIKE '%UPGRADE%' THEN 'Expansion'
            WHEN UPPER(rb.EVENT_TYPE) LIKE '%ADDON%' THEN 'Add-on'
            ELSE 'One-time'
        END AS REVENUE_TYPE,
        rb.AMOUNT AS GROSS_AMOUNT,
        -- Tax calculation (8% standard rate)
        rb.AMOUNT * 0.08 AS TAX_AMOUNT,
        -- Discount calculation based on plan type
        CASE 
            WHEN u.PLAN_TYPE = 'Enterprise' THEN rb.AMOUNT * 0.15
            WHEN u.PLAN_TYPE = 'Pro' THEN rb.AMOUNT * 0.10
            ELSE 0
        END AS DISCOUNT_AMOUNT,
        -- Net amount calculation
        rb.AMOUNT - (rb.AMOUNT * 0.08) - 
        CASE 
            WHEN u.PLAN_TYPE = 'Enterprise' THEN rb.AMOUNT * 0.15
            WHEN u.PLAN_TYPE = 'Pro' THEN rb.AMOUNT * 0.10
            ELSE 0
        END AS NET_AMOUNT,
        'USD' AS CURRENCY_CODE,
        1.0 AS EXCHANGE_RATE,
        rb.AMOUNT AS USD_AMOUNT,
        -- Payment method determination
        CASE 
            WHEN rb.AMOUNT > 1000 THEN 'Bank Transfer'
            WHEN rb.AMOUNT > 100 THEN 'Credit Card'
            ELSE 'PayPal'
        END AS PAYMENT_METHOD,
        'Completed' AS PAYMENT_STATUS,
        -- Subscription period determination
        CASE 
            WHEN UPPER(l.LICENSE_TYPE) LIKE '%ANNUAL%' THEN 12
            WHEN UPPER(l.LICENSE_TYPE) LIKE '%MONTHLY%' THEN 1
            ELSE 12
        END AS SUBSCRIPTION_PERIOD_MONTHS,
        -- Recurring revenue flag
        CASE 
            WHEN UPPER(rb.EVENT_TYPE) LIKE '%SUBSCRIPTION%' OR UPPER(rb.EVENT_TYPE) LIKE '%RENEWAL%' THEN TRUE
            ELSE FALSE
        END AS IS_RECURRING_REVENUE,
        -- Customer lifetime value calculation
        CASE 
            WHEN u.PLAN_TYPE = 'Enterprise' THEN rb.AMOUNT * 24
            WHEN u.PLAN_TYPE = 'Pro' THEN rb.AMOUNT * 18
            WHEN u.PLAN_TYPE = 'Basic' THEN rb.AMOUNT * 12
            ELSE rb.AMOUNT * 6
        END AS CUSTOMER_LIFETIME_VALUE,
        -- MRR impact calculation
        CASE 
            WHEN UPPER(rb.EVENT_TYPE) LIKE '%SUBSCRIPTION%' AND UPPER(l.LICENSE_TYPE) LIKE '%MONTHLY%' THEN rb.AMOUNT
            WHEN UPPER(rb.EVENT_TYPE) LIKE '%SUBSCRIPTION%' AND UPPER(l.LICENSE_TYPE) LIKE '%ANNUAL%' THEN rb.AMOUNT / 12
            ELSE 0
        END AS MRR_IMPACT,
        -- ARR impact calculation
        CASE 
            WHEN UPPER(rb.EVENT_TYPE) LIKE '%SUBSCRIPTION%' THEN 
                CASE 
                    WHEN UPPER(l.LICENSE_TYPE) LIKE '%MONTHLY%' THEN rb.AMOUNT * 12
                    ELSE rb.AMOUNT
                END
            ELSE 0
        END AS ARR_IMPACT,
        -- Commission calculation (5% standard rate)
        rb.AMOUNT * 0.05 AS COMMISSION_AMOUNT,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        rb.SOURCE_SYSTEM
    FROM revenue_base rb
    LEFT JOIN user_info u ON rb.USER_ID = u.USER_ID
    LEFT JOIN license_info l ON rb.USER_ID = l.ASSIGNED_TO_USER_ID
)

SELECT * FROM revenue_calculations
ORDER BY REVENUE_EVENT_ID
