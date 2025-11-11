{{ config(
    materialized='table',
    tags=['fact', 'gold'],
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (PROCESS_ID, PROCESS_NAME, PROCESS_TYPE, PROCESS_START_TIME, PROCESS_STATUS, SOURCE_TABLE, TARGET_TABLE, PROCESS_TRIGGER, EXECUTED_BY, LOAD_DATE, SOURCE_SYSTEM) VALUES (UUID_STRING(), 'GO_FACT_REVENUE_ACTIVITY_LOAD', 'FACT_LOAD', CURRENT_TIMESTAMP(), 'RUNNING', 'SI_BILLING_EVENTS', 'GO_FACT_REVENUE_ACTIVITY', 'DBT_MODEL_RUN', 'DBT_SYSTEM', CURRENT_DATE(), 'DBT_GOLD_PIPELINE')",
    post_hook="INSERT INTO {{ ref('go_audit_log') }} (PROCESS_ID, PROCESS_NAME, PROCESS_TYPE, PROCESS_START_TIME, PROCESS_END_TIME, PROCESS_STATUS, SOURCE_TABLE, TARGET_TABLE, RECORDS_PROCESSED, PROCESS_TRIGGER, EXECUTED_BY, LOAD_DATE, SOURCE_SYSTEM) SELECT UUID_STRING(), 'GO_FACT_REVENUE_ACTIVITY_LOAD', 'FACT_LOAD', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 'SUCCESS', 'SI_BILLING_EVENTS', 'GO_FACT_REVENUE_ACTIVITY', (SELECT COUNT(*) FROM {{ this }}), 'DBT_MODEL_RUN', 'DBT_SYSTEM', CURRENT_DATE(), 'DBT_GOLD_PIPELINE'"
) }}

-- Revenue activity fact table transformation
WITH billing_base AS (
    SELECT 
        be.EVENT_ID,
        be.USER_ID,
        be.EVENT_TYPE,
        be.AMOUNT,
        be.EVENT_DATE,
        be.SOURCE_SYSTEM
    FROM {{ source('silver', 'si_billing_events') }} be
    WHERE be.VALIDATION_STATUS = 'PASSED'
),

license_mapping AS (
    SELECT 
        sl.ASSIGNED_TO_USER_ID,
        sl.LICENSE_TYPE
    FROM {{ source('silver', 'si_licenses') }} sl
    WHERE sl.VALIDATION_STATUS = 'PASSED'
),

revenue_metrics AS (
    SELECT 
        bb.*,
        COALESCE(lm.LICENSE_TYPE, 'Unknown') AS LICENSE_TYPE,
        CASE WHEN bb.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') 
             THEN bb.AMOUNT ELSE 0 END AS SUBSCRIPTION_REVENUE_AMOUNT,
        CASE WHEN bb.EVENT_TYPE IN ('One-time Purchase', 'Setup Fee') 
             THEN bb.AMOUNT ELSE 0 END AS ONE_TIME_REVENUE_AMOUNT,
        CASE WHEN bb.EVENT_TYPE = 'Refund' 
             THEN -bb.AMOUNT ELSE bb.AMOUNT END AS NET_REVENUE_AMOUNT,
        CASE WHEN bb.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') 
             THEN bb.AMOUNT / 12 ELSE 0 END AS MRR_IMPACT,
        CASE WHEN bb.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') 
             THEN bb.AMOUNT ELSE 0 END AS ARR_IMPACT
    FROM billing_base bb
    LEFT JOIN license_mapping lm ON bb.USER_ID = lm.ASSIGNED_TO_USER_ID
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY rm.EVENT_ID) AS REVENUE_ACTIVITY_ID,
    -- Foreign Key Columns for BI Integration
    du.USER_KEY,
    COALESCE(dl.LICENSE_KEY, 'UNKNOWN') AS LICENSE_KEY,
    dd.DATE_KEY,
    -- Fact Measures
    rm.EVENT_DATE AS TRANSACTION_DATE,
    rm.EVENT_TYPE,
    rm.AMOUNT,
    'USD' AS CURRENCY,
    'Credit Card' AS PAYMENT_METHOD,
    rm.SUBSCRIPTION_REVENUE_AMOUNT,
    rm.ONE_TIME_REVENUE_AMOUNT,
    0 AS REFUND_AMOUNT, -- Default value
    rm.AMOUNT * 0.1 AS TAX_AMOUNT, -- Estimated tax
    rm.NET_REVENUE_AMOUNT,
    0 AS DISCOUNT_AMOUNT, -- Default value
    1.0 AS EXCHANGE_RATE, -- Default USD
    rm.AMOUNT AS USD_AMOUNT,
    12 AS SUBSCRIPTION_PERIOD_MONTHS, -- Default annual
    1 AS LICENSE_QUANTITY, -- Default value
    0 AS PRORATION_AMOUNT, -- Default value
    rm.AMOUNT * 0.05 AS COMMISSION_AMOUNT, -- Estimated commission
    rm.MRR_IMPACT,
    rm.ARR_IMPACT,
    rm.AMOUNT * 10 AS CUSTOMER_LIFETIME_VALUE, -- Estimated CLV
    CASE 
        WHEN rm.EVENT_TYPE = 'Downgrade' THEN 4.0
        WHEN rm.EVENT_TYPE = 'Refund' THEN 3.5
        WHEN DATEDIFF('day', rm.EVENT_DATE, CURRENT_DATE()) > 90 
             AND rm.EVENT_TYPE = 'Subscription' THEN 3.0
        WHEN rm.NET_REVENUE_AMOUNT < 0 THEN 2.5
        ELSE 1.0
    END AS CHURN_RISK_SCORE,
    CASE 
        WHEN rm.EVENT_TYPE = 'Refund' THEN 'Refunded'
        WHEN rm.NET_REVENUE_AMOUNT > 0 THEN 'Successful'
        WHEN rm.NET_REVENUE_AMOUNT = 0 THEN 'Pending'
        ELSE 'Failed'
    END AS PAYMENT_STATUS,
    CASE WHEN rm.EVENT_TYPE = 'Refund' THEN 'Customer Request' ELSE NULL END AS REFUND_REASON,
    'Online' AS SALES_CHANNEL,
    NULL AS PROMOTION_CODE,
    -- Metadata
    CURRENT_DATE AS LOAD_DATE,
    CURRENT_DATE AS UPDATE_DATE,
    rm.SOURCE_SYSTEM
FROM revenue_metrics rm
JOIN {{ ref('go_dim_user') }} du ON rm.USER_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
JOIN {{ ref('go_dim_date') }} dd ON rm.EVENT_DATE = dd.DATE_KEY
LEFT JOIN {{ ref('go_dim_license') }} dl ON MD5(UPPER(TRIM(rm.LICENSE_TYPE))) = dl.LICENSE_KEY AND dl.IS_CURRENT_RECORD = TRUE
