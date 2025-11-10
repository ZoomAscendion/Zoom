{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (PROCESS_ID, PROCESS_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_START_TIME, PROCESS_STATUS, CREATED_AT, UPDATED_AT) VALUES (GENERATE_UUID(), 'go_fact_revenue_events_transformation', 'SI_BILLING_EVENTS', 'GO_FACT_REVENUE_EVENTS', CURRENT_TIMESTAMP(), 'STARTED', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP())",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET PROCESS_END_TIME = CURRENT_TIMESTAMP(), PROCESS_STATUS = 'COMPLETED', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), RECORDS_SUCCESS = (SELECT COUNT(*) FROM {{ this }}), UPDATED_AT = CURRENT_TIMESTAMP() WHERE PROCESS_NAME = 'go_fact_revenue_events_transformation' AND PROCESS_STATUS = 'STARTED'"
) }}

-- Revenue Events Fact Table
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
        rb.EVENT_DATE as TRANSACTION_DATE,
        CURRENT_TIMESTAMP() as TRANSACTION_TIMESTAMP,
        rb.EVENT_TYPE,
        -- Classify revenue type based on event type
        CASE 
            WHEN rb.EVENT_TYPE ILIKE '%subscription%' THEN 'Recurring'
            WHEN rb.EVENT_TYPE ILIKE '%upgrade%' THEN 'Expansion'
            WHEN rb.EVENT_TYPE ILIKE '%addon%' THEN 'Add-on'
            ELSE 'One-time'
        END as REVENUE_TYPE,
        rb.AMOUNT as GROSS_AMOUNT,
        -- Calculate tax (estimated at 8%)
        rb.AMOUNT * 0.08 as TAX_AMOUNT,
        -- Calculate discount based on user plan
        CASE 
            WHEN rb.PLAN_TYPE = 'Enterprise' THEN rb.AMOUNT * 0.15
            WHEN rb.PLAN_TYPE = 'Pro' THEN rb.AMOUNT * 0.10
            ELSE 0
        END as DISCOUNT_AMOUNT,
        -- Net amount after tax and discount
        rb.AMOUNT - (rb.AMOUNT * 0.08) - 
        CASE 
            WHEN rb.PLAN_TYPE = 'Enterprise' THEN rb.AMOUNT * 0.15
            WHEN rb.PLAN_TYPE = 'Pro' THEN rb.AMOUNT * 0.10
            ELSE 0
        END as NET_AMOUNT,
        'USD' as CURRENCY_CODE,
        1.0 as EXCHANGE_RATE,
        rb.AMOUNT as USD_AMOUNT,
        -- Determine payment method based on amount
        CASE 
            WHEN rb.AMOUNT > 1000 THEN 'Bank Transfer'
            WHEN rb.AMOUNT > 100 THEN 'Credit Card'
            ELSE 'PayPal'
        END as PAYMENT_METHOD,
        'Completed' as PAYMENT_STATUS,
        -- Subscription period based on license type
        CASE 
            WHEN rb.LICENSE_TYPE ILIKE '%annual%' THEN 12
            WHEN rb.LICENSE_TYPE ILIKE '%monthly%' THEN 1
            ELSE 12
        END as SUBSCRIPTION_PERIOD_MONTHS,
        -- Recurring revenue flag
        CASE 
            WHEN rb.EVENT_TYPE ILIKE '%subscription%' OR rb.EVENT_TYPE ILIKE '%renewal%' THEN TRUE
            ELSE FALSE
        END as IS_RECURRING_REVENUE,
        -- Calculate CLV based on plan type
        CASE 
            WHEN rb.PLAN_TYPE = 'Enterprise' THEN rb.AMOUNT * 24
            WHEN rb.PLAN_TYPE = 'Pro' THEN rb.AMOUNT * 18
            WHEN rb.PLAN_TYPE = 'Basic' THEN rb.AMOUNT * 12
            ELSE rb.AMOUNT * 6
        END as CUSTOMER_LIFETIME_VALUE,
        -- MRR Impact calculation
        CASE 
            WHEN rb.EVENT_TYPE ILIKE '%subscription%' AND rb.LICENSE_TYPE ILIKE '%monthly%' THEN rb.AMOUNT
            WHEN rb.EVENT_TYPE ILIKE '%subscription%' AND rb.LICENSE_TYPE ILIKE '%annual%' THEN rb.AMOUNT / 12
            ELSE 0
        END as MRR_IMPACT,
        -- ARR Impact calculation
        CASE 
            WHEN rb.EVENT_TYPE ILIKE '%subscription%' THEN 
                CASE 
                    WHEN rb.LICENSE_TYPE ILIKE '%monthly%' THEN rb.AMOUNT * 12
                    ELSE rb.AMOUNT
                END
            ELSE 0
        END as ARR_IMPACT,
        -- Commission calculation (5% for sales)
        rb.AMOUNT * 0.05 as COMMISSION_AMOUNT,
        CURRENT_DATE() as LOAD_DATE,
        CURRENT_DATE() as UPDATE_DATE,
        rb.SOURCE_SYSTEM
    FROM revenue_base rb
)

SELECT * FROM revenue_enriched
