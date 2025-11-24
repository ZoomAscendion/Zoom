{{ config(
    materialized='table'
) }}

SELECT 
    be.EVENT_ID AS BILLING_EVENT_ID,
    be.EVENT_DATE AS TRANSACTION_DATE,
    be.EVENT_DATE::TIMESTAMP_NTZ AS TRANSACTION_TIMESTAMP,
    be.EVENT_TYPE,
    CASE 
        WHEN be.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') THEN 'Recurring'
        WHEN be.EVENT_TYPE IN ('One-time Purchase', 'Setup Fee') THEN 'One-time'
        ELSE 'Other'
    END AS REVENUE_TYPE,
    COALESCE(be.AMOUNT, 0) AS GROSS_AMOUNT,
    0.00 AS TAX_AMOUNT,
    0.00 AS DISCOUNT_AMOUNT,
    CASE 
        WHEN be.EVENT_TYPE = 'Refund' THEN -COALESCE(be.AMOUNT, 0)
        ELSE COALESCE(be.AMOUNT, 0)
    END AS NET_AMOUNT,
    'USD' AS CURRENCY_CODE,
    1.0 AS EXCHANGE_RATE,
    COALESCE(be.AMOUNT, 0) AS USD_AMOUNT,
    'Credit Card' AS PAYMENT_METHOD,
    CASE 
        WHEN be.EVENT_TYPE IN ('Subscription', 'Renewal') THEN 12
        ELSE 0
    END AS SUBSCRIPTION_PERIOD_MONTHS,
    1 AS LICENSE_QUANTITY,
    0.00 AS PRORATION_AMOUNT,
    0.00 AS COMMISSION_AMOUNT,
    CASE 
        WHEN be.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') THEN COALESCE(be.AMOUNT, 0) / 12
        ELSE 0
    END AS MRR_IMPACT,
    CASE 
        WHEN be.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') THEN COALESCE(be.AMOUNT, 0)
        ELSE 0
    END AS ARR_IMPACT,
    COALESCE(be.AMOUNT, 0) AS CUSTOMER_LIFETIME_VALUE,
    CASE 
        WHEN be.EVENT_TYPE = 'Downgrade' THEN 4.0
        WHEN be.EVENT_TYPE = 'Refund' THEN 3.5
        WHEN DATEDIFF('day', be.EVENT_DATE, CURRENT_DATE()) > 90 AND be.EVENT_TYPE = 'Subscription' THEN 3.0
        WHEN COALESCE(be.AMOUNT, 0) < 0 THEN 2.5
        ELSE 1.0
    END AS CHURN_RISK_SCORE,
    CASE 
        WHEN be.EVENT_TYPE = 'Refund' THEN 'Refunded'
        WHEN COALESCE(be.AMOUNT, 0) > 0 THEN 'Successful'
        WHEN COALESCE(be.AMOUNT, 0) = 0 THEN 'Pending'
        ELSE 'Failed'
    END AS PAYMENT_STATUS,
    CASE 
        WHEN be.EVENT_TYPE = 'Refund' THEN 'Customer Request'
        ELSE NULL
    END AS REFUND_REASON,
    'Online' AS SALES_CHANNEL,
    NULL AS PROMOTION_CODE,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
    CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP,
    COALESCE(be.SOURCE_SYSTEM, 'UNKNOWN') AS SOURCE_SYSTEM
FROM {{ source('silver', 'si_billing_events') }} be
WHERE COALESCE(be.VALIDATION_STATUS, 'PASSED') = 'PASSED'
