{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (PROCESS_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_START_TIME, PROCESS_STATUS, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) VALUES ('GO_FACT_REVENUE_EVENTS_LOAD', 'SI_BILLING_EVENTS', 'GO_FACT_REVENUE_EVENTS', CURRENT_TIMESTAMP(), 'STARTED', CURRENT_DATE(), CURRENT_DATE(), 'DBT_GOLD_PIPELINE')",
    post_hook="INSERT INTO {{ ref('go_audit_log') }} (PROCESS_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_START_TIME, PROCESS_END_TIME, PROCESS_STATUS, RECORDS_PROCESSED, RECORDS_SUCCESS, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) VALUES ('GO_FACT_REVENUE_EVENTS_LOAD', 'SI_BILLING_EVENTS', 'GO_FACT_REVENUE_EVENTS', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 'SUCCESS', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), CURRENT_DATE(), CURRENT_DATE(), 'DBT_GOLD_PIPELINE')"
) }}

-- Gold Layer Revenue Events Fact
-- Fact table capturing all revenue-generating events and financial transactions

WITH revenue_base AS (
    SELECT 
        be.EVENT_ID,
        be.USER_ID,
        be.EVENT_TYPE,
        be.AMOUNT,
        be.EVENT_DATE,
        be.SOURCE_SYSTEM,
        u.PLAN_TYPE,
        l.LICENSE_TYPE
    FROM {{ source('silver', 'si_billing_events') }} be
    LEFT JOIN {{ source('silver', 'si_users') }} u ON be.USER_ID = u.USER_ID
    LEFT JOIN {{ source('silver', 'si_licenses') }} l ON u.USER_ID = l.ASSIGNED_TO_USER_ID
    WHERE be.VALIDATION_STATUS = 'PASSED'
        AND be.DATA_QUALITY_SCORE >= 80
        AND be.AMOUNT > 0
),

revenue_enriched AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY EVENT_DATE, EVENT_ID) AS REVENUE_EVENT_ID,
        EVENT_DATE as TRANSACTION_DATE,
        CURRENT_TIMESTAMP() as TRANSACTION_TIMESTAMP,
        EVENT_TYPE,
        -- Classify revenue type based on event type
        CASE 
            WHEN UPPER(EVENT_TYPE) LIKE '%SUBSCRIPTION%' THEN 'Recurring'
            WHEN UPPER(EVENT_TYPE) LIKE '%UPGRADE%' THEN 'Expansion'
            WHEN UPPER(EVENT_TYPE) LIKE '%ADDON%' THEN 'Add-on'
            ELSE 'One-time'
        END as REVENUE_TYPE,
        AMOUNT as GROSS_AMOUNT,
        -- Calculate tax (estimated at 8% for demonstration)
        AMOUNT * 0.08 as TAX_AMOUNT,
        -- Calculate discount based on user plan
        CASE 
            WHEN UPPER(PLAN_TYPE) LIKE '%ENTERPRISE%' THEN AMOUNT * 0.15
            WHEN UPPER(PLAN_TYPE) LIKE '%PRO%' THEN AMOUNT * 0.10
            ELSE 0
        END as DISCOUNT_AMOUNT,
        -- Net amount after tax and discount
        AMOUNT - (AMOUNT * 0.08) - 
        CASE 
            WHEN UPPER(PLAN_TYPE) LIKE '%ENTERPRISE%' THEN AMOUNT * 0.15
            WHEN UPPER(PLAN_TYPE) LIKE '%PRO%' THEN AMOUNT * 0.10
            ELSE 0
        END as NET_AMOUNT,
        'USD' as CURRENCY_CODE,
        1.0 as EXCHANGE_RATE,
        AMOUNT as USD_AMOUNT,
        -- Determine payment method based on amount
        CASE 
            WHEN AMOUNT > 1000 THEN 'Bank Transfer'
            WHEN AMOUNT > 100 THEN 'Credit Card'
            ELSE 'PayPal'
        END as PAYMENT_METHOD,
        'Completed' as PAYMENT_STATUS,
        -- Subscription period based on license type
        CASE 
            WHEN UPPER(LICENSE_TYPE) LIKE '%ANNUAL%' THEN 12
            WHEN UPPER(LICENSE_TYPE) LIKE '%MONTHLY%' THEN 1
            ELSE 12
        END as SUBSCRIPTION_PERIOD_MONTHS,
        -- Recurring revenue flag
        CASE 
            WHEN UPPER(EVENT_TYPE) LIKE '%SUBSCRIPTION%' OR UPPER(EVENT_TYPE) LIKE '%RENEWAL%' THEN TRUE
            ELSE FALSE
        END as IS_RECURRING_REVENUE,
        -- Calculate CLV based on plan type
        CASE 
            WHEN UPPER(PLAN_TYPE) LIKE '%ENTERPRISE%' THEN AMOUNT * 24
            WHEN UPPER(PLAN_TYPE) LIKE '%PRO%' THEN AMOUNT * 18
            WHEN UPPER(PLAN_TYPE) LIKE '%BASIC%' THEN AMOUNT * 12
            ELSE AMOUNT * 6
        END as CUSTOMER_LIFETIME_VALUE,
        -- MRR Impact calculation
        CASE 
            WHEN UPPER(EVENT_TYPE) LIKE '%SUBSCRIPTION%' AND UPPER(LICENSE_TYPE) LIKE '%MONTHLY%' THEN AMOUNT
            WHEN UPPER(EVENT_TYPE) LIKE '%SUBSCRIPTION%' AND UPPER(LICENSE_TYPE) LIKE '%ANNUAL%' THEN AMOUNT / 12
            ELSE 0
        END as MRR_IMPACT,
        -- ARR Impact calculation
        CASE 
            WHEN UPPER(EVENT_TYPE) LIKE '%SUBSCRIPTION%' THEN 
                CASE 
                    WHEN UPPER(LICENSE_TYPE) LIKE '%MONTHLY%' THEN AMOUNT * 12
                    ELSE AMOUNT
                END
            ELSE 0
        END as ARR_IMPACT,
        -- Commission calculation (5% for sales)
        AMOUNT * 0.05 as COMMISSION_AMOUNT,
        CURRENT_DATE() as LOAD_DATE,
        CURRENT_DATE() as UPDATE_DATE,
        SOURCE_SYSTEM
    FROM revenue_base
)

SELECT * FROM revenue_enriched
