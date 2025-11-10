{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (PROCESS_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_START_TIME, PROCESS_STATUS, PROCESS_NOTES, LOAD_DATE, UPDATE_DATE) VALUES ('GO_FACT_REVENUE_EVENTS_TRANSFORMATION', 'SI_BILLING_EVENTS', 'GO_FACT_REVENUE_EVENTS', CURRENT_TIMESTAMP(), 'STARTED', 'Revenue events fact transformation started', CURRENT_DATE(), CURRENT_DATE())",
    post_hook="INSERT INTO {{ ref('go_audit_log') }} (PROCESS_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_END_TIME, PROCESS_STATUS, PROCESS_NOTES, LOAD_DATE, UPDATE_DATE) VALUES ('GO_FACT_REVENUE_EVENTS_TRANSFORMATION', 'SI_BILLING_EVENTS', 'GO_FACT_REVENUE_EVENTS', CURRENT_TIMESTAMP(), 'COMPLETED', 'Revenue events fact transformation completed successfully', CURRENT_DATE(), CURRENT_DATE())"
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
        u.PLAN_TYPE,
        l.LICENSE_TYPE,
        be.SOURCE_SYSTEM
    FROM {{ source('silver', 'si_billing_events') }} be
    LEFT JOIN {{ source('silver', 'si_users') }} u ON be.USER_ID = u.USER_ID
    LEFT JOIN {{ source('silver', 'si_licenses') }} l ON u.USER_ID = l.ASSIGNED_TO_USER_ID
    WHERE be.VALIDATION_STATUS = 'PASSED'
        AND be.DATA_QUALITY_SCORE >= 80
        AND be.AMOUNT > 0
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
            WHEN rb.PLAN_TYPE = 'Enterprise' THEN rb.AMOUNT * 0.15
            WHEN rb.PLAN_TYPE = 'Pro' THEN rb.AMOUNT * 0.10
            ELSE 0
        END AS DISCOUNT_AMOUNT,
        -- Net amount calculation
        rb.AMOUNT - (rb.AMOUNT * 0.08) - 
        CASE 
            WHEN rb.PLAN_TYPE = 'Enterprise' THEN rb.AMOUNT * 0.15
            WHEN rb.PLAN_TYPE = 'Pro' THEN rb.AMOUNT * 0.10
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
            WHEN UPPER(rb.LICENSE_TYPE) LIKE '%ANNUAL%' THEN 12
            WHEN UPPER(rb.LICENSE_TYPE) LIKE '%MONTHLY%' THEN 1
            ELSE 12
        END AS SUBSCRIPTION_PERIOD_MONTHS,
        -- Recurring revenue flag
        CASE 
            WHEN UPPER(rb.EVENT_TYPE) LIKE '%SUBSCRIPTION%' OR UPPER(rb.EVENT_TYPE) LIKE '%RENEWAL%' THEN TRUE
            ELSE FALSE
        END AS IS_RECURRING_REVENUE,
        -- Customer lifetime value calculation
        CASE 
            WHEN rb.PLAN_TYPE = 'Enterprise' THEN rb.AMOUNT * 24
            WHEN rb.PLAN_TYPE = 'Pro' THEN rb.AMOUNT * 18
            WHEN rb.PLAN_TYPE = 'Basic' THEN rb.AMOUNT * 12
            ELSE rb.AMOUNT * 6
        END AS CUSTOMER_LIFETIME_VALUE,
        -- MRR impact calculation
        CASE 
            WHEN UPPER(rb.EVENT_TYPE) LIKE '%SUBSCRIPTION%' AND UPPER(rb.LICENSE_TYPE) LIKE '%MONTHLY%' THEN rb.AMOUNT
            WHEN UPPER(rb.EVENT_TYPE) LIKE '%SUBSCRIPTION%' AND UPPER(rb.LICENSE_TYPE) LIKE '%ANNUAL%' THEN rb.AMOUNT / 12
            ELSE 0
        END AS MRR_IMPACT,
        -- ARR impact calculation
        CASE 
            WHEN UPPER(rb.EVENT_TYPE) LIKE '%SUBSCRIPTION%' THEN 
                CASE 
                    WHEN UPPER(rb.LICENSE_TYPE) LIKE '%MONTHLY%' THEN rb.AMOUNT * 12
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
)

SELECT * FROM revenue_calculations
ORDER BY REVENUE_EVENT_ID
