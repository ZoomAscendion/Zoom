{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (AUDIT_ID, PIPELINE_NAME, SOURCE_TABLE, TARGET_TABLE, EXECUTION_START_TIME, EXECUTION_STATUS) VALUES (GENERATE_UUID(), 'GO_FACT_REVENUE_EVENTS', 'SI_BILLING_EVENTS', 'GO_FACT_REVENUE_EVENTS', CURRENT_TIMESTAMP(), 'STARTED')",
    post_hook="INSERT INTO {{ ref('go_audit_log') }} (AUDIT_ID, PIPELINE_NAME, SOURCE_TABLE, TARGET_TABLE, EXECUTION_END_TIME, EXECUTION_STATUS, RECORDS_PROCESSED) VALUES (GENERATE_UUID(), 'GO_FACT_REVENUE_EVENTS', 'SI_BILLING_EVENTS', 'GO_FACT_REVENUE_EVENTS', CURRENT_TIMESTAMP(), 'COMPLETED', (SELECT COUNT(*) FROM {{ this }}))"
) }}

-- Gold Fact: Revenue Events Fact
-- Description: Revenue-generating events and financial transactions

WITH source_billing AS (
    SELECT 
        be.EVENT_ID,
        be.USER_ID,
        be.EVENT_TYPE,
        be.AMOUNT,
        be.EVENT_DATE,
        be.SOURCE_SYSTEM
    FROM {{ source('silver', 'si_billing_events') }} be
    WHERE be.VALIDATION_STATUS = 'PASSED'
      AND be.AMOUNT IS NOT NULL
      AND be.AMOUNT > 0
),

revenue_events_metrics AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY EVENT_ID) AS REVENUE_EVENT_ID,
        EVENT_DATE AS TRANSACTION_DATE,
        CURRENT_TIMESTAMP() AS TRANSACTION_TIMESTAMP, -- Simplified
        EVENT_TYPE,
        CASE 
            WHEN UPPER(EVENT_TYPE) LIKE '%SUBSCRIPTION%' THEN 'Subscription'
            WHEN UPPER(EVENT_TYPE) LIKE '%LICENSE%' THEN 'License'
            WHEN UPPER(EVENT_TYPE) LIKE '%UPGRADE%' THEN 'Upgrade'
            ELSE 'Other'
        END AS REVENUE_TYPE,
        AMOUNT AS GROSS_AMOUNT,
        ROUND(AMOUNT * 0.08, 2) AS TAX_AMOUNT, -- 8% tax
        CASE 
            WHEN UPPER(EVENT_TYPE) LIKE '%DISCOUNT%' THEN ROUND(AMOUNT * 0.1, 2)
            ELSE 0.00
        END AS DISCOUNT_AMOUNT,
        AMOUNT - ROUND(AMOUNT * 0.08, 2) - CASE 
            WHEN UPPER(EVENT_TYPE) LIKE '%DISCOUNT%' THEN ROUND(AMOUNT * 0.1, 2)
            ELSE 0.00
        END AS NET_AMOUNT,
        'USD' AS CURRENCY_CODE,
        1.0000 AS EXCHANGE_RATE,
        AMOUNT AS USD_AMOUNT, -- Already in USD
        CASE 
            WHEN RANDOM() > 0.7 THEN 'Credit Card'
            WHEN RANDOM() > 0.4 THEN 'Bank Transfer'
            ELSE 'PayPal'
        END AS PAYMENT_METHOD,
        CASE 
            WHEN RANDOM() > 0.1 THEN 'Completed'
            ELSE 'Pending'
        END AS PAYMENT_STATUS,
        CASE 
            WHEN UPPER(EVENT_TYPE) LIKE '%ANNUAL%' THEN 12
            WHEN UPPER(EVENT_TYPE) LIKE '%MONTHLY%' THEN 1
            ELSE 12
        END AS SUBSCRIPTION_PERIOD_MONTHS,
        CASE 
            WHEN UPPER(EVENT_TYPE) LIKE '%SUBSCRIPTION%' OR UPPER(EVENT_TYPE) LIKE '%LICENSE%' THEN TRUE
            ELSE FALSE
        END AS IS_RECURRING_REVENUE,
        AMOUNT * 24 AS CUSTOMER_LIFETIME_VALUE, -- Estimated 2 years
        CASE 
            WHEN UPPER(EVENT_TYPE) LIKE '%MONTHLY%' THEN AMOUNT
            WHEN UPPER(EVENT_TYPE) LIKE '%ANNUAL%' THEN ROUND(AMOUNT / 12, 2)
            ELSE 0.00
        END AS MRR_IMPACT,
        CASE 
            WHEN UPPER(EVENT_TYPE) LIKE '%ANNUAL%' THEN AMOUNT
            WHEN UPPER(EVENT_TYPE) LIKE '%MONTHLY%' THEN AMOUNT * 12
            ELSE 0.00
        END AS ARR_IMPACT,
        ROUND(AMOUNT * 0.05, 2) AS COMMISSION_AMOUNT, -- 5% commission
        CURRENT_DATE AS LOAD_DATE,
        CURRENT_DATE AS UPDATE_DATE,
        SOURCE_SYSTEM
    FROM source_billing
)

SELECT * FROM revenue_events_metrics
