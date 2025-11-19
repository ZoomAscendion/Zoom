{{ config(
    materialized='table',
    tags=['fact', 'gold'],
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (AUDIT_LOG_ID, PROCESS_NAME, PROCESS_TYPE, EXECUTION_START_TIMESTAMP, EXECUTION_STATUS, SOURCE_TABLE_NAME, TARGET_TABLE_NAME, RECORDS_READ, PROCESS_TRIGGER, EXECUTED_BY, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key([\"'GO_FACT_REVENUE_EVENTS'\", 'CURRENT_TIMESTAMP()']) }}', 'GO_FACT_REVENUE_EVENTS_LOAD', 'FACT_LOAD', CURRENT_TIMESTAMP(), 'RUNNING', 'SI_BILLING_EVENTS', 'GO_FACT_REVENUE_EVENTS', (SELECT COUNT(*) FROM {{ source('silver', 'si_billing_events') }}), 'DBT_PIPELINE', 'DBT_SYSTEM', CURRENT_DATE, CURRENT_DATE, 'DBT_GOLD_PIPELINE'",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET EXECUTION_END_TIMESTAMP = CURRENT_TIMESTAMP(), EXECUTION_STATUS = 'SUCCESS', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), RECORDS_INSERTED = (SELECT COUNT(*) FROM {{ this }}) WHERE PROCESS_NAME = 'GO_FACT_REVENUE_EVENTS_LOAD' AND EXECUTION_STATUS = 'RUNNING'"
) }}

-- Gold Fact: Revenue Events Fact Table
-- Detailed billing events and revenue metrics

SELECT 
    ROW_NUMBER() OVER (ORDER BY be.EVENT_ID) AS REVENUE_EVENT_ID,
    dd.DATE_ID,
    dl.LICENSE_ID,
    du.USER_DIM_ID,
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
    be.AMOUNT * 0.1 AS TAX_AMOUNT,
    0 AS DISCOUNT_AMOUNT,
    be.AMOUNT * 0.9 AS NET_AMOUNT,
    'USD' AS CURRENCY_CODE,
    1.0 AS EXCHANGE_RATE,
    be.AMOUNT AS USD_AMOUNT,
    'Credit Card' AS PAYMENT_METHOD,
    12 AS SUBSCRIPTION_PERIOD_MONTHS,
    1 AS LICENSE_QUANTITY,
    0 AS PRORATION_AMOUNT,
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
    CASE 
        WHEN be.EVENT_TYPE = 'Downgrade' THEN 4.0
        WHEN be.EVENT_TYPE = 'Refund' THEN 3.5
        WHEN DATEDIFF('day', be.EVENT_DATE, CURRENT_DATE()) > 90 AND be.EVENT_TYPE = 'Subscription' THEN 3.0
        WHEN be.AMOUNT < 0 THEN 2.5
        ELSE 1.0
    END AS CHURN_RISK_SCORE,
    CASE 
        WHEN be.EVENT_TYPE = 'Refund' THEN 'Refunded'
        WHEN be.AMOUNT > 0 THEN 'Successful'
        WHEN be.AMOUNT = 0 THEN 'Pending'
        ELSE 'Failed'
    END AS PAYMENT_STATUS,
    CASE 
        WHEN be.EVENT_TYPE = 'Refund' THEN 'Customer Request'
        ELSE NULL
    END AS REFUND_REASON,
    'Online' AS SALES_CHANNEL,
    NULL AS PROMOTION_CODE,
    CURRENT_DATE AS LOAD_DATE,
    CURRENT_DATE AS UPDATE_DATE,
    be.SOURCE_SYSTEM
FROM {{ source('silver', 'si_billing_events') }} be
LEFT JOIN {{ ref('go_dim_user') }} du ON be.USER_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
LEFT JOIN {{ ref('go_dim_date') }} dd ON be.EVENT_DATE = dd.DATE_VALUE
LEFT JOIN {{ source('silver', 'si_licenses') }} sl ON be.USER_ID = sl.ASSIGNED_TO_USER_ID
LEFT JOIN {{ ref('go_dim_license') }} dl ON sl.LICENSE_TYPE = dl.LICENSE_TYPE AND dl.IS_CURRENT_RECORD = TRUE
WHERE be.VALIDATION_STATUS = 'PASSED'
