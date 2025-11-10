{{ config(
    materialized='table'
) }}

-- Revenue Events Fact Table
WITH sample_data AS (
    SELECT 
        'USER_001' AS USER_ID,
        'Subscription' AS EVENT_TYPE,
        19.99 AS AMOUNT,
        '2024-01-15'::DATE AS EVENT_DATE,
        'Pro' AS PLAN_TYPE,
        'Monthly' AS LICENSE_TYPE
    UNION ALL
    SELECT 
        'USER_002' AS USER_ID,
        'Upgrade' AS EVENT_TYPE,
        79.99 AS AMOUNT,
        '2024-01-16'::DATE AS EVENT_DATE,
        'Enterprise' AS PLAN_TYPE,
        'Monthly' AS LICENSE_TYPE
    UNION ALL
    SELECT 
        'USER_003' AS USER_ID,
        'Renewal' AS EVENT_TYPE,
        39.99 AS AMOUNT,
        '2024-01-17'::DATE AS EVENT_DATE,
        'Business' AS PLAN_TYPE,
        'Monthly' AS LICENSE_TYPE
)
SELECT 
    EVENT_DATE as TRANSACTION_DATE,
    CURRENT_TIMESTAMP() as TRANSACTION_TIMESTAMP,
    EVENT_TYPE,
    CASE 
        WHEN EVENT_TYPE ILIKE '%subscription%' THEN 'Recurring'
        WHEN EVENT_TYPE ILIKE '%upgrade%' THEN 'Expansion'
        WHEN EVENT_TYPE ILIKE '%addon%' THEN 'Add-on'
        ELSE 'One-time'
    END as REVENUE_TYPE,
    AMOUNT as GROSS_AMOUNT,
    AMOUNT * 0.08 as TAX_AMOUNT,
    CASE 
        WHEN PLAN_TYPE = 'Enterprise' THEN AMOUNT * 0.15
        WHEN PLAN_TYPE = 'Pro' THEN AMOUNT * 0.10
        ELSE 0
    END as DISCOUNT_AMOUNT,
    AMOUNT - (AMOUNT * 0.08) - 
    CASE 
        WHEN PLAN_TYPE = 'Enterprise' THEN AMOUNT * 0.15
        WHEN PLAN_TYPE = 'Pro' THEN AMOUNT * 0.10
        ELSE 0
    END as NET_AMOUNT,
    'USD' as CURRENCY_CODE,
    1.0 as EXCHANGE_RATE,
    AMOUNT as USD_AMOUNT,
    CASE 
        WHEN AMOUNT > 1000 THEN 'Bank Transfer'
        WHEN AMOUNT > 100 THEN 'Credit Card'
        ELSE 'PayPal'
    END as PAYMENT_METHOD,
    'Completed' as PAYMENT_STATUS,
    CASE 
        WHEN LICENSE_TYPE ILIKE '%annual%' THEN 12
        WHEN LICENSE_TYPE ILIKE '%monthly%' THEN 1
        ELSE 12
    END as SUBSCRIPTION_PERIOD_MONTHS,
    CASE 
        WHEN EVENT_TYPE ILIKE '%subscription%' OR EVENT_TYPE ILIKE '%renewal%' THEN TRUE
        ELSE FALSE
    END as IS_RECURRING_REVENUE,
    CASE 
        WHEN PLAN_TYPE = 'Enterprise' THEN AMOUNT * 24
        WHEN PLAN_TYPE = 'Pro' THEN AMOUNT * 18
        WHEN PLAN_TYPE = 'Basic' THEN AMOUNT * 12
        ELSE AMOUNT * 6
    END as CUSTOMER_LIFETIME_VALUE,
    CASE 
        WHEN EVENT_TYPE ILIKE '%subscription%' AND LICENSE_TYPE ILIKE '%monthly%' THEN AMOUNT
        WHEN EVENT_TYPE ILIKE '%subscription%' AND LICENSE_TYPE ILIKE '%annual%' THEN AMOUNT / 12
        ELSE 0
    END as MRR_IMPACT,
    CASE 
        WHEN EVENT_TYPE ILIKE '%subscription%' THEN 
            CASE 
                WHEN LICENSE_TYPE ILIKE '%monthly%' THEN AMOUNT * 12
                ELSE AMOUNT
            END
        ELSE 0
    END as ARR_IMPACT,
    AMOUNT * 0.05 as COMMISSION_AMOUNT,
    CURRENT_DATE() as LOAD_DATE,
    CURRENT_DATE() as UPDATE_DATE,
    'SYSTEM' AS SOURCE_SYSTEM
FROM sample_data
