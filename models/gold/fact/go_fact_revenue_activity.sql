{{ config(
    materialized='table',
    tags=['fact', 'gold']
) }}

-- Revenue Activity Fact Table
-- Captures billing events and revenue metrics

WITH revenue_base AS (
    SELECT 
        be.EVENT_ID,
        be.USER_ID,
        be.EVENT_TYPE,
        be.AMOUNT,
        be.EVENT_DATE,
        be.SOURCE_SYSTEM,
        ROW_NUMBER() OVER (
            PARTITION BY be.EVENT_ID 
            ORDER BY COALESCE(be.UPDATE_TIMESTAMP, be.LOAD_TIMESTAMP) DESC
        ) as rn
    FROM DB_POC_ZOOM_1.GOLD.SI_BILLING_EVENTS be
    WHERE be.VALIDATION_STATUS = 'PASSED'
),

user_licenses AS (
    SELECT 
        sl.ASSIGNED_TO_USER_ID,
        sl.LICENSE_TYPE,
        dl.LICENSE_KEY,
        ROW_NUMBER() OVER (
            PARTITION BY sl.ASSIGNED_TO_USER_ID 
            ORDER BY COALESCE(sl.UPDATE_TIMESTAMP, sl.LOAD_TIMESTAMP) DESC
        ) as rn
    FROM DB_POC_ZOOM_1.GOLD.SI_LICENSES sl
    JOIN {{ ref('go_dim_license') }} dl ON sl.LICENSE_TYPE = dl.LICENSE_TYPE AND dl.IS_CURRENT_RECORD = TRUE
    WHERE sl.VALIDATION_STATUS = 'PASSED'
      AND sl.START_DATE <= CURRENT_DATE() 
      AND (sl.END_DATE IS NULL OR sl.END_DATE >= CURRENT_DATE())
),

final_fact AS (
    SELECT 
        -- Foreign Key Columns for BI Integration
        COALESCE(du.USER_KEY, 'UNKNOWN_USER') as USER_KEY,
        COALESCE(ul.LICENSE_KEY, 'UNKNOWN_LICENSE') as LICENSE_KEY,
        rb.EVENT_DATE as DATE_KEY,
        
        -- Fact Measures
        rb.EVENT_DATE as TRANSACTION_DATE,
        rb.EVENT_TYPE,
        rb.AMOUNT,
        'USD' as CURRENCY,
        'Credit Card' as PAYMENT_METHOD,
        CASE WHEN rb.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') 
             THEN rb.AMOUNT ELSE 0 END as SUBSCRIPTION_REVENUE_AMOUNT,
        CASE WHEN rb.EVENT_TYPE IN ('One-time Purchase', 'Setup Fee') 
             THEN rb.AMOUNT ELSE 0 END as ONE_TIME_REVENUE_AMOUNT,
        0.0 as REFUND_AMOUNT,
        rb.AMOUNT * 0.08 as TAX_AMOUNT,
        CASE WHEN rb.EVENT_TYPE = 'Refund' 
             THEN -rb.AMOUNT ELSE rb.AMOUNT END as NET_REVENUE_AMOUNT,
        0.0 as DISCOUNT_AMOUNT,
        1.0 as EXCHANGE_RATE,
        rb.AMOUNT as USD_AMOUNT,
        12 as SUBSCRIPTION_PERIOD_MONTHS,
        1 as LICENSE_QUANTITY,
        0.0 as PRORATION_AMOUNT,
        rb.AMOUNT * 0.05 as COMMISSION_AMOUNT,
        CASE WHEN rb.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') 
             THEN rb.AMOUNT / 12 ELSE 0 END as MRR_IMPACT,
        CASE WHEN rb.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') 
             THEN rb.AMOUNT ELSE 0 END as ARR_IMPACT,
        rb.AMOUNT * 24 as CUSTOMER_LIFETIME_VALUE,
        2.5 as CHURN_RISK_SCORE,
        'Completed' as PAYMENT_STATUS,
        NULL as REFUND_REASON,
        'Online' as SALES_CHANNEL,
        NULL as PROMOTION_CODE,
        
        -- Metadata
        CURRENT_DATE() as LOAD_DATE,
        CURRENT_DATE() as UPDATE_DATE,
        rb.SOURCE_SYSTEM
    FROM revenue_base rb
    LEFT JOIN {{ ref('go_dim_user') }} du ON rb.USER_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
    LEFT JOIN user_licenses ul ON rb.USER_ID = ul.ASSIGNED_TO_USER_ID AND ul.rn = 1
    WHERE rb.rn = 1
)

SELECT * FROM final_fact
