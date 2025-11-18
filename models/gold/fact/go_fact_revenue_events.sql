{{ config(
    materialized='table'
) }}

-- Revenue events fact table with comprehensive financial metrics

WITH revenue_base AS (
    SELECT 
        be.EVENT_ID,
        be.USER_ID,
        be.EVENT_TYPE,
        be.AMOUNT,
        be.EVENT_DATE,
        be.SOURCE_SYSTEM,
        sl.LICENSE_TYPE
    FROM {{ source('silver', 'si_billing_events') }} be
    LEFT JOIN {{ source('silver', 'si_licenses') }} sl ON be.USER_ID = sl.ASSIGNED_TO_USER_ID
    WHERE be.VALIDATION_STATUS = 'PASSED'
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY rb.EVENT_ID) AS REVENUE_EVENT_ID,
    dd.DATE_ID,
    dl.LICENSE_ID,
    du.USER_DIM_ID,
    rb.EVENT_ID AS BILLING_EVENT_ID,
    rb.EVENT_DATE AS TRANSACTION_DATE,
    rb.EVENT_DATE::TIMESTAMP_NTZ AS TRANSACTION_TIMESTAMP,
    rb.EVENT_TYPE,
    CASE 
        WHEN rb.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') THEN 'Recurring'
        WHEN rb.EVENT_TYPE IN ('One-time Purchase', 'Setup Fee') THEN 'One-time'
        ELSE 'Other'
    END AS REVENUE_TYPE,
    rb.AMOUNT AS GROSS_AMOUNT,
    rb.AMOUNT * 0.08 AS TAX_AMOUNT, -- Assuming 8% tax
    0.00 AS DISCOUNT_AMOUNT, -- Default value
    CASE 
        WHEN rb.EVENT_TYPE = 'Refund' THEN -rb.AMOUNT
        ELSE rb.AMOUNT
    END AS NET_AMOUNT,
    'USD' AS CURRENCY_CODE,
    1.0 AS EXCHANGE_RATE,
    rb.AMOUNT AS USD_AMOUNT,
    'Credit Card' AS PAYMENT_METHOD, -- Default value
    CASE 
        WHEN rb.EVENT_TYPE IN ('Subscription', 'Renewal') THEN 12
        ELSE 0
    END AS SUBSCRIPTION_PERIOD_MONTHS,
    1 AS LICENSE_QUANTITY, -- Default value
    0.00 AS PRORATION_AMOUNT, -- Default value
    rb.AMOUNT * 0.05 AS COMMISSION_AMOUNT, -- Assuming 5% commission
    CASE 
        WHEN rb.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') THEN rb.AMOUNT / 12
        ELSE 0
    END AS MRR_IMPACT,
    CASE 
        WHEN rb.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') THEN rb.AMOUNT
        ELSE 0
    END AS ARR_IMPACT,
    rb.AMOUNT * 5 AS CUSTOMER_LIFETIME_VALUE, -- Simplified calculation
    CASE 
        WHEN rb.EVENT_TYPE = 'Downgrade' THEN 4.0
        WHEN rb.EVENT_TYPE = 'Refund' THEN 3.5
        WHEN DATEDIFF('day', rb.EVENT_DATE, CURRENT_DATE()) > 90 AND rb.EVENT_TYPE = 'Subscription' THEN 3.0
        WHEN rb.AMOUNT < 0 THEN 2.5
        ELSE 1.0
    END AS CHURN_RISK_SCORE,
    CASE 
        WHEN rb.EVENT_TYPE = 'Refund' THEN 'Refunded'
        WHEN rb.AMOUNT > 0 THEN 'Successful'
        WHEN rb.AMOUNT = 0 THEN 'Pending'
        ELSE 'Failed'
    END AS PAYMENT_STATUS,
    CASE 
        WHEN rb.EVENT_TYPE = 'Refund' THEN 'Customer Request'
        ELSE NULL
    END AS REFUND_REASON,
    'Online' AS SALES_CHANNEL, -- Default value
    NULL AS PROMOTION_CODE,
    CURRENT_DATE() AS LOAD_DATE,
    CURRENT_DATE() AS UPDATE_DATE,
    rb.SOURCE_SYSTEM
FROM revenue_base rb
LEFT JOIN {{ ref('go_dim_date') }} dd ON rb.EVENT_DATE = dd.DATE_VALUE
LEFT JOIN {{ ref('go_dim_license') }} dl ON rb.LICENSE_TYPE = dl.LICENSE_TYPE AND dl.IS_CURRENT_RECORD = TRUE
LEFT JOIN {{ ref('go_dim_user') }} du ON rb.USER_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
