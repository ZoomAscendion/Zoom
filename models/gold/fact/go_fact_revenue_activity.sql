{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_process_audit') }} (AUDIT_LOG_ID, PROCESS_NAME, PROCESS_TYPE, EXECUTION_START_TIMESTAMP, EXECUTION_STATUS, SOURCE_TABLE_NAME, TARGET_TABLE_NAME, PROCESS_TRIGGER, EXECUTED_BY, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) VALUES (UUID_STRING(), 'GO_FACT_REVENUE_ACTIVITY_LOAD', 'FACT_LOAD', CURRENT_TIMESTAMP(), 'STARTED', 'SI_BILLING_EVENTS,SI_LICENSES', 'GO_FACT_REVENUE_ACTIVITY', 'DBT_RUN', 'DBT_SYSTEM', CURRENT_DATE(), CURRENT_DATE(), 'DBT_GOLD_PIPELINE')",
    post_hook="INSERT INTO {{ ref('go_process_audit') }} (AUDIT_LOG_ID, PROCESS_NAME, PROCESS_TYPE, EXECUTION_START_TIMESTAMP, EXECUTION_END_TIMESTAMP, EXECUTION_STATUS, SOURCE_TABLE_NAME, TARGET_TABLE_NAME, RECORDS_PROCESSED, PROCESS_TRIGGER, EXECUTED_BY, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) VALUES (UUID_STRING(), 'GO_FACT_REVENUE_ACTIVITY_LOAD', 'FACT_LOAD', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 'COMPLETED', 'SI_BILLING_EVENTS,SI_LICENSES', 'GO_FACT_REVENUE_ACTIVITY', (SELECT COUNT(*) FROM {{ this }}), 'DBT_RUN', 'DBT_SYSTEM', CURRENT_DATE(), CURRENT_DATE(), 'DBT_GOLD_PIPELINE')"
) }}

-- Revenue Activity Fact Table
-- Captures billing events and revenue metrics

WITH source_billing AS (
    SELECT *
    FROM {{ source('silver', 'si_billing_events') }}
    WHERE VALIDATION_STATUS = 'PASSED'
),

source_licenses AS (
    SELECT *
    FROM {{ source('silver', 'si_licenses') }}
    WHERE VALIDATION_STATUS = 'PASSED'
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
            ORDER BY sl.UPDATE_TIMESTAMP DESC, dl.UPDATE_DATE DESC
        ) AS rn
    FROM source_licenses sl
    JOIN {{ ref('go_dim_license') }} dl ON sl.LICENSE_TYPE = dl.LICENSE_TYPE 
                                        AND dl.IS_CURRENT_RECORD = TRUE
    WHERE sl.START_DATE <= CURRENT_DATE() 
      AND (sl.END_DATE IS NULL OR sl.END_DATE >= CURRENT_DATE())
),

revenue_transformations AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY be.EVENT_ID) AS REVENUE_ACTIVITY_ID,
        -- Foreign Key Columns for BI Integration
        COALESCE(du.USER_KEY, 'UNKNOWN_USER') AS USER_KEY,
        COALESCE(dl.LICENSE_KEY, 'UNKNOWN_LICENSE') AS LICENSE_KEY,
        dd.DATE_KEY,
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
    LEFT JOIN unique_users du ON be.USER_ID = du.USER_ID AND du.rn = 1
    JOIN {{ ref('go_dim_date') }} dd ON be.EVENT_DATE = dd.DATE_KEY
    LEFT JOIN unique_licenses dl ON be.USER_ID = dl.ASSIGNED_TO_USER_ID AND dl.rn = 1
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
