{{ config(
    materialized='table'
) }}

-- Revenue Events Fact Table
-- Fact table capturing detailed billing events and revenue metrics

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
      AND be.AMOUNT IS NOT NULL
),

license_context AS (
    SELECT 
        sl.ASSIGNED_TO_USER_ID,
        sl.LICENSE_TYPE,
        dl.LICENSE_ID
    FROM {{ source('silver', 'si_licenses') }} sl
    LEFT JOIN {{ ref('go_dim_license') }} dl ON sl.LICENSE_TYPE = dl.LICENSE_TYPE
    WHERE sl.VALIDATION_STATUS = 'PASSED'
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY bb.EVENT_ID) AS REVENUE_EVENT_ID,
    dd.DATE_ID,
    COALESCE(lc.LICENSE_ID, 1) AS LICENSE_ID,
    du.USER_DIM_ID,
    bb.EVENT_ID AS BILLING_EVENT_ID,
    bb.EVENT_DATE AS TRANSACTION_DATE,
    bb.EVENT_DATE::TIMESTAMP_NTZ AS TRANSACTION_TIMESTAMP,
    bb.EVENT_TYPE,
    CASE 
        WHEN bb.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') THEN 'Recurring'
        WHEN bb.EVENT_TYPE IN ('One-time Purchase', 'Setup Fee') THEN 'One-time'
        WHEN bb.EVENT_TYPE = 'Refund' THEN 'Refund'
        ELSE 'Other'
    END AS REVENUE_TYPE,
    bb.AMOUNT AS GROSS_AMOUNT,
    bb.AMOUNT * 0.08 AS TAX_AMOUNT,
    0.00 AS DISCOUNT_AMOUNT,
    CASE 
        WHEN bb.EVENT_TYPE = 'Refund' THEN -bb.AMOUNT
        ELSE bb.AMOUNT
    END AS NET_AMOUNT,
    'USD' AS CURRENCY_CODE,
    1.0 AS EXCHANGE_RATE,
    CASE 
        WHEN bb.EVENT_TYPE = 'Refund' THEN -bb.AMOUNT
        ELSE bb.AMOUNT
    END AS USD_AMOUNT,
    'Credit Card' AS PAYMENT_METHOD,
    CASE 
        WHEN bb.EVENT_TYPE IN ('Subscription', 'Renewal') THEN 12
        ELSE 0
    END AS SUBSCRIPTION_PERIOD_MONTHS,
    1 AS LICENSE_QUANTITY,
    0.00 AS PRORATION_AMOUNT,
    bb.AMOUNT * 0.05 AS COMMISSION_AMOUNT,
    CASE 
        WHEN bb.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') THEN bb.AMOUNT / 12
        ELSE 0
    END AS MRR_IMPACT,
    CASE 
        WHEN bb.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') THEN bb.AMOUNT
        ELSE 0
    END AS ARR_IMPACT,
    bb.AMOUNT * 5 AS CUSTOMER_LIFETIME_VALUE,
    CASE 
        WHEN bb.EVENT_TYPE = 'Downgrade' THEN 4.0
        WHEN bb.EVENT_TYPE = 'Refund' THEN 3.5
        WHEN DATEDIFF('day', bb.EVENT_DATE, CURRENT_DATE()) > 90 AND bb.EVENT_TYPE = 'Subscription' THEN 3.0
        WHEN bb.AMOUNT < 0 THEN 2.5
        ELSE 1.0
    END AS CHURN_RISK_SCORE,
    CASE 
        WHEN bb.EVENT_TYPE = 'Refund' THEN 'Refunded'
        WHEN bb.AMOUNT > 0 THEN 'Successful'
        WHEN bb.AMOUNT = 0 THEN 'Pending'
        ELSE 'Failed'
    END AS PAYMENT_STATUS,
    CASE 
        WHEN bb.EVENT_TYPE = 'Refund' THEN 'Customer Request'
        ELSE NULL
    END AS REFUND_REASON,
    'Online' AS SALES_CHANNEL,
    NULL AS PROMOTION_CODE,
    CURRENT_DATE() AS LOAD_DATE,
    CURRENT_DATE() AS UPDATE_DATE,
    bb.SOURCE_SYSTEM
FROM billing_base bb
LEFT JOIN {{ ref('go_dim_date') }} dd ON bb.EVENT_DATE = dd.DATE_VALUE
LEFT JOIN {{ ref('go_dim_user') }} du ON bb.USER_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
LEFT JOIN license_context lc ON bb.USER_ID = lc.ASSIGNED_TO_USER_ID
