{{ config(
    materialized='table',
    tags=['fact', 'gold'],
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (AUDIT_LOG_ID, PROCESS_NAME, PROCESS_TYPE, EXECUTION_START_TIMESTAMP, EXECUTION_STATUS, SOURCE_TABLE_NAME, TARGET_TABLE_NAME, PROCESS_TRIGGER, EXECUTED_BY, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) VALUES (UUID_STRING(), 'GO_FACT_REVENUE_EVENTS_LOAD', 'FACT_LOAD', CURRENT_TIMESTAMP(), 'RUNNING', 'SI_BILLING_EVENTS', 'GO_FACT_REVENUE_EVENTS', 'DBT_MODEL', 'DBT_SYSTEM', CURRENT_DATE, CURRENT_DATE, 'DBT_GOLD_LAYER')",
    post_hook="INSERT INTO {{ ref('go_audit_log') }} (AUDIT_LOG_ID, PROCESS_NAME, PROCESS_TYPE, EXECUTION_START_TIMESTAMP, EXECUTION_END_TIMESTAMP, EXECUTION_STATUS, SOURCE_TABLE_NAME, TARGET_TABLE_NAME, RECORDS_PROCESSED, PROCESS_TRIGGER, EXECUTED_BY, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) VALUES (UUID_STRING(), 'GO_FACT_REVENUE_EVENTS_LOAD', 'FACT_LOAD', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 'SUCCESS', 'SI_BILLING_EVENTS', 'GO_FACT_REVENUE_EVENTS', (SELECT COUNT(*) FROM {{ this }}), 'DBT_MODEL', 'DBT_SYSTEM', CURRENT_DATE, CURRENT_DATE, 'DBT_GOLD_LAYER')"
) }}

-- Revenue Events Fact Table
WITH source_billing AS (
    SELECT 
        be.EVENT_ID,
        be.USER_ID,
        be.EVENT_TYPE,
        be.AMOUNT,
        be.EVENT_DATE,
        be.SOURCE_SYSTEM
    FROM {{ source('silver', 'SI_BILLING_EVENTS') }} be
    WHERE be.VALIDATION_STATUS = 'PASSED'
),

user_license_mapping AS (
    SELECT 
        sl.ASSIGNED_TO_USER_ID,
        sl.LICENSE_TYPE
    FROM {{ source('silver', 'SI_LICENSES') }} sl
    WHERE sl.VALIDATION_STATUS = 'PASSED'
),

fact_revenue_events AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY sb.EVENT_ID) AS REVENUE_EVENT_ID,
        dd.DATE_ID AS DATE_ID,
        dl.LICENSE_ID AS LICENSE_ID,
        du.USER_DIM_ID AS USER_DIM_ID,
        sb.EVENT_ID AS BILLING_EVENT_ID,
        sb.EVENT_DATE AS TRANSACTION_DATE,
        sb.EVENT_DATE::TIMESTAMP_NTZ AS TRANSACTION_TIMESTAMP,
        sb.EVENT_TYPE,
        CASE 
            WHEN sb.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') THEN 'Recurring'
            ELSE 'One-time'
        END AS REVENUE_TYPE,
        sb.AMOUNT AS GROSS_AMOUNT,
        sb.AMOUNT * 0.08 AS TAX_AMOUNT,
        0.00 AS DISCOUNT_AMOUNT,
        sb.AMOUNT * 0.92 AS NET_AMOUNT,
        'USD' AS CURRENCY_CODE,
        1.0 AS EXCHANGE_RATE,
        sb.AMOUNT AS USD_AMOUNT,
        'Credit Card' AS PAYMENT_METHOD,
        12 AS SUBSCRIPTION_PERIOD_MONTHS,
        1 AS LICENSE_QUANTITY,
        0.00 AS PRORATION_AMOUNT,
        sb.AMOUNT * 0.05 AS COMMISSION_AMOUNT,
        CASE 
            WHEN sb.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') THEN sb.AMOUNT / 12
            ELSE 0
        END AS MRR_IMPACT,
        CASE 
            WHEN sb.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') THEN sb.AMOUNT
            ELSE 0
        END AS ARR_IMPACT,
        sb.AMOUNT * 5 AS CUSTOMER_LIFETIME_VALUE,
        CASE 
            WHEN sb.EVENT_TYPE = 'Refund' THEN 4.0
            WHEN sb.EVENT_TYPE = 'Downgrade' THEN 3.0
            ELSE 1.0
        END AS CHURN_RISK_SCORE,
        CASE 
            WHEN sb.EVENT_TYPE = 'Refund' THEN 'Refunded'
            WHEN sb.AMOUNT > 0 THEN 'Successful'
            ELSE 'Failed'
        END AS PAYMENT_STATUS,
        CASE 
            WHEN sb.EVENT_TYPE = 'Refund' THEN 'Customer Request'
            ELSE NULL
        END AS REFUND_REASON,
        'Online' AS SALES_CHANNEL,
        NULL AS PROMOTION_CODE,
        CURRENT_DATE AS LOAD_DATE,
        CURRENT_DATE AS UPDATE_DATE,
        sb.SOURCE_SYSTEM
    FROM source_billing sb
    LEFT JOIN {{ ref('go_dim_date') }} dd ON sb.EVENT_DATE = dd.DATE_VALUE
    LEFT JOIN {{ ref('go_dim_user') }} du ON sb.USER_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
    LEFT JOIN user_license_mapping ulm ON sb.USER_ID = ulm.ASSIGNED_TO_USER_ID
    LEFT JOIN {{ ref('go_dim_license') }} dl ON ulm.LICENSE_TYPE = dl.LICENSE_TYPE AND dl.IS_CURRENT_RECORD = TRUE
)

SELECT * FROM fact_revenue_events
