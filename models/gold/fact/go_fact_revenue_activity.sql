{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_process_audit') }} (AUDIT_KEY, PIPELINE_NAME, PIPELINE_RUN_TIMESTAMP, SOURCE_TABLE, TARGET_TABLE, EXECUTION_START_TIME, EXECUTION_STATUS, PROCESSED_BY, LOAD_DATE, SOURCE_SYSTEM) SELECT 'REVENUE_FACT_' || CURRENT_TIMESTAMP()::VARCHAR, 'GO_FACT_REVENUE_ACTIVITY_TRANSFORM', CURRENT_TIMESTAMP(), 'SI_BILLING_EVENTS', 'GO_FACT_REVENUE_ACTIVITY', CURRENT_TIMESTAMP(), 'STARTED', CURRENT_USER(), CURRENT_DATE(), 'DBT_GOLD_LAYER'",
    post_hook="INSERT INTO {{ ref('go_process_audit') }} (AUDIT_KEY, PIPELINE_NAME, PIPELINE_RUN_TIMESTAMP, SOURCE_TABLE, TARGET_TABLE, EXECUTION_START_TIME, EXECUTION_END_TIME, EXECUTION_DURATION_SECONDS, RECORDS_PROCESSED, EXECUTION_STATUS, PROCESSED_BY, LOAD_DATE, SOURCE_SYSTEM) SELECT 'REVENUE_FACT_' || CURRENT_TIMESTAMP()::VARCHAR, 'GO_FACT_REVENUE_ACTIVITY_TRANSFORM', CURRENT_TIMESTAMP(), 'SI_BILLING_EVENTS', 'GO_FACT_REVENUE_ACTIVITY', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 1, (SELECT COUNT(*) FROM {{ this }}), 'COMPLETED', CURRENT_USER(), CURRENT_DATE(), 'DBT_GOLD_LAYER'"
) }}

-- Gold Layer Revenue Activity Fact Table
-- Transforms billing events with revenue classification and churn risk scoring
-- Enables comprehensive revenue analytics and financial reporting

WITH source_billing AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        EVENT_TYPE,
        AMOUNT,
        EVENT_DATE,
        CURRENCY_CODE,
        SOURCE_SYSTEM
    FROM {{ source('silver', 'si_billing_events') }}
    WHERE AMOUNT IS NOT NULL
      AND EVENT_DATE IS NOT NULL
      AND USER_ID IS NOT NULL
),

user_activity AS (
    SELECT 
        HOST_ID AS USER_ID,
        COUNT(*) AS meeting_count
    FROM {{ source('silver', 'si_meetings') }}
    WHERE START_TIME >= DATEADD('month', -1, CURRENT_DATE())
    GROUP BY HOST_ID
),

revenue_enrichment AS (
    SELECT 
        be.EVENT_DATE,
        be.USER_ID AS USER_KEY,
        CASE 
            WHEN UPPER(TRIM(be.EVENT_TYPE)) IN ('SUBSCRIPTION', 'RENEWAL', 'UPGRADE', 'DOWNGRADE', 'PAYMENT', 'REFUND', 'CHARGEBACK') 
            THEN UPPER(TRIM(be.EVENT_TYPE))
            ELSE 'OTHER'
        END AS EVENT_TYPE,
        ABS(be.AMOUNT) AS AMOUNT,
        COALESCE(be.CURRENCY_CODE, 'USD') AS CURRENCY_CODE,
        'CREDIT_CARD' AS PAYMENT_METHOD, -- Default payment method
        CASE 
            WHEN UPPER(be.EVENT_TYPE) IN ('SUBSCRIPTION', 'RENEWAL', 'UPGRADE') 
            THEN TRUE 
            ELSE FALSE 
        END AS RECURRING_REVENUE_FLAG,
        CASE 
            WHEN ua.meeting_count IS NULL OR ua.meeting_count = 0 THEN 0.95
            WHEN ua.meeting_count < 5 THEN 0.75
            WHEN ua.meeting_count < 15 THEN 0.50
            WHEN ua.meeting_count < 30 THEN 0.25
            ELSE 0.10
        END AS CHURN_RISK_SCORE,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        be.SOURCE_SYSTEM
    FROM source_billing be
    LEFT JOIN user_activity ua ON be.USER_ID = ua.USER_ID
)

SELECT 
    EVENT_DATE::DATE,
    USER_KEY::VARCHAR(16777216),
    EVENT_TYPE::VARCHAR(16777216),
    AMOUNT::NUMBER(10,2),
    CURRENCY_CODE::VARCHAR(3),
    PAYMENT_METHOD::VARCHAR(100),
    RECURRING_REVENUE_FLAG::BOOLEAN,
    CHURN_RISK_SCORE::NUMBER(3,2),
    LOAD_DATE::DATE,
    UPDATE_DATE::DATE,
    SOURCE_SYSTEM::VARCHAR(16777216)
FROM revenue_enrichment
