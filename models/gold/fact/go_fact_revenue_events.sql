{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (AUDIT_LOG_ID, PROCESS_NAME, SOURCE_TABLE_NAME, TARGET_TABLE_NAME, EXECUTION_START_TIMESTAMP, EXECUTION_STATUS, LOAD_DATE, SOURCE_SYSTEM) VALUES ('{{ invocation_id }}_FACT_REVENUE', 'go_fact_revenue_events', 'SILVER.SI_BILLING_EVENTS', 'GOLD.GO_FACT_REVENUE_EVENTS', CURRENT_TIMESTAMP(), 'RUNNING', CURRENT_DATE(), 'DBT_GOLD_PIPELINE')",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET EXECUTION_END_TIMESTAMP = CURRENT_TIMESTAMP(), EXECUTION_STATUS = 'SUCCESS', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), UPDATE_DATE = CURRENT_DATE() WHERE AUDIT_LOG_ID = '{{ invocation_id }}_FACT_REVENUE' AND PROCESS_NAME = 'go_fact_revenue_events'"
) }}

-- Revenue events fact table transformation from Silver to Gold layer
WITH revenue_base AS (
    SELECT 
        be.EVENT_ID,
        be.USER_ID,
        be.EVENT_TYPE,
        be.AMOUNT,
        be.EVENT_DATE,
        be.SOURCE_SYSTEM
    FROM {{ source('silver', 'si_billing_events') }} be
    WHERE COALESCE(be.VALIDATION_STATUS, 'PASSED') = 'PASSED'
      AND be.EVENT_ID IS NOT NULL
),

revenue_events_fact AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY rb.EVENT_ID) AS REVENUE_EVENT_ID,
        COALESCE(dd.DATE_ID, 1) AS DATE_ID,
        1 AS LICENSE_ID,
        COALESCE(du.USER_DIM_ID, 1) AS USER_DIM_ID,
        rb.EVENT_ID AS BILLING_EVENT_ID,
        COALESCE(rb.EVENT_DATE, CURRENT_DATE()) AS TRANSACTION_DATE,
        COALESCE(rb.EVENT_DATE, CURRENT_DATE())::TIMESTAMP_NTZ AS TRANSACTION_TIMESTAMP,
        COALESCE(rb.EVENT_TYPE, 'Unknown') AS EVENT_TYPE,
        CASE 
            WHEN COALESCE(rb.EVENT_TYPE, 'Unknown') IN ('Subscription', 'Renewal', 'Upgrade') THEN 'Recurring'
            ELSE 'One-time'
        END AS REVENUE_TYPE,
        COALESCE(rb.AMOUNT, 0) AS GROSS_AMOUNT,
        COALESCE(rb.AMOUNT, 0) * 0.08 AS TAX_AMOUNT,
        0.00 AS DISCOUNT_AMOUNT,
        COALESCE(rb.AMOUNT, 0) * 0.92 AS NET_AMOUNT,
        'USD' AS CURRENCY_CODE,
        1.0 AS EXCHANGE_RATE,
        COALESCE(rb.AMOUNT, 0) AS USD_AMOUNT,
        'Credit Card' AS PAYMENT_METHOD,
        CASE 
            WHEN COALESCE(rb.EVENT_TYPE, 'Unknown') IN ('Subscription', 'Renewal') THEN 12
            ELSE 1
        END AS SUBSCRIPTION_PERIOD_MONTHS,
        1 AS LICENSE_QUANTITY,
        0.00 AS PRORATION_AMOUNT,
        COALESCE(rb.AMOUNT, 0) * 0.05 AS COMMISSION_AMOUNT,
        CASE 
            WHEN COALESCE(rb.EVENT_TYPE, 'Unknown') IN ('Subscription', 'Renewal', 'Upgrade') THEN COALESCE(rb.AMOUNT, 0) / 12
            ELSE 0
        END AS MRR_IMPACT,
        CASE 
            WHEN COALESCE(rb.EVENT_TYPE, 'Unknown') IN ('Subscription', 'Renewal', 'Upgrade') THEN COALESCE(rb.AMOUNT, 0)
            ELSE 0
        END AS ARR_IMPACT,
        COALESCE(rb.AMOUNT, 0) * 5 AS CUSTOMER_LIFETIME_VALUE,
        1.0 AS CHURN_RISK_SCORE,
        'Successful' AS PAYMENT_STATUS,
        NULL AS REFUND_REASON,
        'Online' AS SALES_CHANNEL,
        NULL AS PROMOTION_CODE,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        COALESCE(rb.SOURCE_SYSTEM, 'UNKNOWN') AS SOURCE_SYSTEM
    FROM revenue_base rb
    LEFT JOIN {{ ref('go_dim_date') }} dd ON COALESCE(rb.EVENT_DATE, CURRENT_DATE()) = dd.DATE_VALUE
    LEFT JOIN {{ ref('go_dim_user') }} du ON rb.USER_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
)

SELECT * FROM revenue_events_fact
