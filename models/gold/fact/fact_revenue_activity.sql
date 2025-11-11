{{
  config(
    materialized='table',
    cluster_by=['DATE_KEY', 'USER_KEY'],
    tags=['fact', 'gold']
  )
}}

-- Revenue Activity Fact Table
WITH billing_base AS (
    SELECT 
        be.EVENT_ID,
        be.USER_ID,
        be.EVENT_TYPE,
        be.AMOUNT,
        be.EVENT_DATE,
        be.SOURCE_SYSTEM
    FROM {{ source('silver', 'si_billing_events') }} be
    WHERE COALESCE(be.VALIDATION_STATUS, '') = 'PASSED'
      AND be.EVENT_ID IS NOT NULL
      AND be.USER_ID IS NOT NULL
),

license_mapping AS (
    SELECT 
        sl.ASSIGNED_TO_USER_ID AS USER_ID,
        sl.LICENSE_TYPE,
        ROW_NUMBER() OVER (PARTITION BY sl.ASSIGNED_TO_USER_ID ORDER BY sl.START_DATE DESC) AS rn
    FROM {{ source('silver', 'si_licenses') }} sl
    WHERE COALESCE(sl.VALIDATION_STATUS, '') = 'PASSED'
),

fact_data AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY bb.EVENT_ID) AS REVENUE_ACTIVITY_ID,
        -- Foreign Keys
        du.USER_KEY,
        COALESCE(dl.LICENSE_KEY, 'UNKNOWN') AS LICENSE_KEY,
        dd.DATE_KEY,
        -- Fact Measures
        bb.EVENT_DATE AS TRANSACTION_DATE,
        COALESCE(bb.EVENT_TYPE, 'Unknown') AS EVENT_TYPE,
        COALESCE(bb.AMOUNT, 0) AS AMOUNT,
        'USD' AS CURRENCY,
        'Credit Card' AS PAYMENT_METHOD, -- Default value
        CASE 
            WHEN bb.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') 
            THEN COALESCE(bb.AMOUNT, 0) 
            ELSE 0 
        END AS SUBSCRIPTION_REVENUE_AMOUNT,
        CASE 
            WHEN bb.EVENT_TYPE IN ('One-time Purchase', 'Setup Fee') 
            THEN COALESCE(bb.AMOUNT, 0) 
            ELSE 0 
        END AS ONE_TIME_REVENUE_AMOUNT,
        CASE 
            WHEN bb.EVENT_TYPE = 'Refund' 
            THEN -COALESCE(bb.AMOUNT, 0) 
            ELSE 0 
        END AS REFUND_AMOUNT,
        COALESCE(bb.AMOUNT, 0) * 0.08 AS TAX_AMOUNT, -- 8% tax rate
        CASE 
            WHEN bb.EVENT_TYPE = 'Refund' 
            THEN -COALESCE(bb.AMOUNT, 0) 
            ELSE COALESCE(bb.AMOUNT, 0) 
        END AS NET_REVENUE_AMOUNT,
        0 AS DISCOUNT_AMOUNT, -- Default value
        1.0 AS EXCHANGE_RATE, -- Default USD rate
        COALESCE(bb.AMOUNT, 0) AS USD_AMOUNT,
        CASE 
            WHEN bb.EVENT_TYPE IN ('Subscription', 'Renewal') 
            THEN 12 
            ELSE NULL 
        END AS SUBSCRIPTION_PERIOD_MONTHS,
        1 AS LICENSE_QUANTITY, -- Default value
        0 AS PRORATION_AMOUNT, -- Default value
        COALESCE(bb.AMOUNT, 0) * 0.05 AS COMMISSION_AMOUNT, -- 5% commission
        CASE 
            WHEN bb.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') 
            THEN COALESCE(bb.AMOUNT, 0) / 12 
            ELSE 0 
        END AS MRR_IMPACT,
        CASE 
            WHEN bb.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') 
            THEN COALESCE(bb.AMOUNT, 0) 
            ELSE 0 
        END AS ARR_IMPACT,
        COALESCE(bb.AMOUNT, 0) * 5 AS CUSTOMER_LIFETIME_VALUE, -- Estimated 5x multiplier
        CASE 
            WHEN bb.EVENT_TYPE = 'Downgrade' THEN 4.0
            WHEN bb.EVENT_TYPE = 'Refund' THEN 3.5
            WHEN bb.EVENT_TYPE = 'Cancellation' THEN 5.0
            ELSE 1.0
        END AS CHURN_RISK_SCORE,
        CASE 
            WHEN bb.EVENT_TYPE = 'Refund' THEN 'Refunded'
            WHEN COALESCE(bb.AMOUNT, 0) > 0 THEN 'Successful'
            ELSE 'Pending'
        END AS PAYMENT_STATUS,
        CASE 
            WHEN bb.EVENT_TYPE = 'Refund' THEN 'Customer Request'
            ELSE NULL
        END AS REFUND_REASON,
        'Online' AS SALES_CHANNEL, -- Default value
        NULL AS PROMOTION_CODE, -- Default value
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        COALESCE(bb.SOURCE_SYSTEM, 'SILVER_ETL') AS SOURCE_SYSTEM
    FROM billing_base bb
    LEFT JOIN {{ ref('dim_user') }} du ON bb.USER_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
    LEFT JOIN {{ ref('dim_date') }} dd ON bb.EVENT_DATE = dd.DATE_KEY
    LEFT JOIN license_mapping lm ON bb.USER_ID = lm.USER_ID AND lm.rn = 1
    LEFT JOIN {{ ref('dim_license') }} dl ON {{ dbt_utils.generate_surrogate_key(['lm.LICENSE_TYPE']) }} = dl.LICENSE_KEY AND dl.IS_CURRENT_RECORD = TRUE
    WHERE du.USER_KEY IS NOT NULL
      AND dd.DATE_KEY IS NOT NULL
)

SELECT * FROM fact_data
