{{ config(
    materialized='table',
    cluster_by=['TRANSACTION_DATE', 'USER_DIM_ID']
) }}

WITH billing_events_base AS (
    SELECT 
        be.EVENT_ID,
        be.USER_ID,
        be.EVENT_TYPE,
        be.AMOUNT,
        be.EVENT_DATE,
        be.EVENT_DATE::TIMESTAMP_NTZ AS TRANSACTION_TIMESTAMP,
        be.SOURCE_SYSTEM
    FROM {{ ref('si_billing_events') }} be
    WHERE be.VALIDATION_STATUS = 'PASSED'
),

user_license_mapping AS (
    SELECT 
        sl.ASSIGNED_TO_USER_ID AS USER_ID,
        sl.LICENSE_TYPE
    FROM {{ ref('si_licenses') }} sl
    WHERE sl.VALIDATION_STATUS = 'PASSED'
)

SELECT 
    dd.DATE_ID,
    dl.LICENSE_ID,
    du.USER_DIM_ID,
    beb.EVENT_ID AS BILLING_EVENT_ID,
    beb.EVENT_DATE AS TRANSACTION_DATE,
    beb.TRANSACTION_TIMESTAMP,
    beb.EVENT_TYPE,
    CASE 
        WHEN beb.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') THEN 'Recurring'
        WHEN beb.EVENT_TYPE IN ('One-time Purchase', 'Setup Fee') THEN 'One-time'
        ELSE 'Other'
    END AS REVENUE_TYPE,
    beb.AMOUNT AS GROSS_AMOUNT,
    0.00 AS TAX_AMOUNT,
    0.00 AS DISCOUNT_AMOUNT,
    CASE 
        WHEN beb.EVENT_TYPE = 'Refund' THEN -beb.AMOUNT
        ELSE beb.AMOUNT
    END AS NET_AMOUNT,
    'USD' AS CURRENCY_CODE,
    1.0 AS EXCHANGE_RATE,
    beb.AMOUNT AS USD_AMOUNT,
    'Credit Card' AS PAYMENT_METHOD,
    CASE 
        WHEN beb.EVENT_TYPE IN ('Subscription', 'Renewal') THEN 12
        ELSE 0
    END AS SUBSCRIPTION_PERIOD_MONTHS,
    1 AS LICENSE_QUANTITY,
    0.00 AS PRORATION_AMOUNT,
    0.00 AS COMMISSION_AMOUNT,
    CASE 
        WHEN beb.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') THEN beb.AMOUNT / 12
        ELSE 0
    END AS MRR_IMPACT,
    CASE 
        WHEN beb.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') THEN beb.AMOUNT
        ELSE 0
    END AS ARR_IMPACT,
    beb.AMOUNT AS CUSTOMER_LIFETIME_VALUE,
    CASE 
        WHEN beb.EVENT_TYPE = 'Downgrade' THEN 4.0
        WHEN beb.EVENT_TYPE = 'Refund' THEN 3.5
        WHEN DATEDIFF('day', beb.EVENT_DATE, CURRENT_DATE()) > 90 AND beb.EVENT_TYPE = 'Subscription' THEN 3.0
        WHEN beb.AMOUNT < 0 THEN 2.5
        ELSE 1.0
    END AS CHURN_RISK_SCORE,
    CASE 
        WHEN beb.EVENT_TYPE = 'Refund' THEN 'Refunded'
        WHEN beb.AMOUNT > 0 THEN 'Successful'
        WHEN beb.AMOUNT = 0 THEN 'Pending'
        ELSE 'Failed'
    END AS PAYMENT_STATUS,
    CASE 
        WHEN beb.EVENT_TYPE = 'Refund' THEN 'Customer Request'
        ELSE NULL
    END AS REFUND_REASON,
    'Online' AS SALES_CHANNEL,
    NULL AS PROMOTION_CODE,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
    CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP,
    beb.SOURCE_SYSTEM
FROM billing_events_base beb
LEFT JOIN {{ ref('go_dim_date') }} dd ON beb.EVENT_DATE = dd.DATE_VALUE
LEFT JOIN {{ ref('go_dim_user') }} du ON beb.USER_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
LEFT JOIN user_license_mapping ulm ON beb.USER_ID = ulm.USER_ID
LEFT JOIN {{ ref('go_dim_license') }} dl ON ulm.LICENSE_TYPE = dl.LICENSE_TYPE AND dl.IS_CURRENT_RECORD = TRUE
