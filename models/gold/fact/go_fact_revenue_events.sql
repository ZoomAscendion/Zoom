{{ config(
    materialized='table',
    unique_key='REVENUE_EVENT_ID'
) }}

-- Revenue events fact table with financial metrics and analytics

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
      AND be.DATA_QUALITY_SCORE >= 70
      AND be.AMOUNT IS NOT NULL
),

user_license_mapping AS (
    SELECT DISTINCT
        l.ASSIGNED_TO_USER_ID,
        l.LICENSE_TYPE,
        l.START_DATE,
        l.END_DATE
    FROM {{ source('silver', 'si_licenses') }} l
    WHERE l.VALIDATION_STATUS = 'PASSED'
),

revenue_events_fact AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY sb.EVENT_ID) AS REVENUE_EVENT_ID,
        dd.DATE_ID,
        dl.LICENSE_ID,
        du.USER_DIM_ID,
        sb.EVENT_ID AS BILLING_EVENT_ID,
        sb.EVENT_DATE AS TRANSACTION_DATE,
        sb.EVENT_DATE::TIMESTAMP_NTZ AS TRANSACTION_TIMESTAMP,
        sb.EVENT_TYPE,
        CASE 
            WHEN UPPER(sb.EVENT_TYPE) IN ('SUBSCRIPTION', 'RENEWAL', 'UPGRADE') THEN 'Recurring'
            WHEN UPPER(sb.EVENT_TYPE) IN ('ONE_TIME', 'SETUP', 'ADDON') THEN 'One-time'
            WHEN UPPER(sb.EVENT_TYPE) = 'REFUND' THEN 'Refund'
            ELSE 'Other'
        END AS REVENUE_TYPE,
        sb.AMOUNT AS GROSS_AMOUNT,
        ROUND(sb.AMOUNT * 0.08, 2) AS TAX_AMOUNT, -- 8% tax assumption
        0.00 AS DISCOUNT_AMOUNT, -- Default value
        CASE 
            WHEN UPPER(sb.EVENT_TYPE) = 'REFUND' THEN -sb.AMOUNT
            ELSE sb.AMOUNT
        END AS NET_AMOUNT,
        'USD' AS CURRENCY_CODE,
        1.0 AS EXCHANGE_RATE,
        CASE 
            WHEN UPPER(sb.EVENT_TYPE) = 'REFUND' THEN -sb.AMOUNT
            ELSE sb.AMOUNT
        END AS USD_AMOUNT,
        'Credit Card' AS PAYMENT_METHOD, -- Default value
        CASE 
            WHEN UPPER(sb.EVENT_TYPE) IN ('SUBSCRIPTION', 'RENEWAL') THEN 12
            ELSE 0
        END AS SUBSCRIPTION_PERIOD_MONTHS,
        1 AS LICENSE_QUANTITY, -- Default value
        0.00 AS PRORATION_AMOUNT, -- Default value
        ROUND(sb.AMOUNT * 0.05, 2) AS COMMISSION_AMOUNT, -- 5% commission assumption
        -- MRR Impact calculation
        CASE 
            WHEN UPPER(sb.EVENT_TYPE) IN ('SUBSCRIPTION', 'RENEWAL', 'UPGRADE') THEN ROUND(sb.AMOUNT / 12, 2)
            WHEN UPPER(sb.EVENT_TYPE) = 'DOWNGRADE' THEN -ROUND(sb.AMOUNT / 12, 2)
            WHEN UPPER(sb.EVENT_TYPE) = 'REFUND' THEN -ROUND(sb.AMOUNT / 12, 2)
            ELSE 0.00
        END AS MRR_IMPACT,
        -- ARR Impact calculation
        CASE 
            WHEN UPPER(sb.EVENT_TYPE) IN ('SUBSCRIPTION', 'RENEWAL', 'UPGRADE') THEN sb.AMOUNT
            WHEN UPPER(sb.EVENT_TYPE) = 'DOWNGRADE' THEN -sb.AMOUNT
            WHEN UPPER(sb.EVENT_TYPE) = 'REFUND' THEN -sb.AMOUNT
            ELSE 0.00
        END AS ARR_IMPACT,
        -- Customer Lifetime Value (simplified calculation)
        sb.AMOUNT * 2.5 AS CUSTOMER_LIFETIME_VALUE, -- Simplified multiplier
        -- Churn risk score
        CASE 
            WHEN UPPER(sb.EVENT_TYPE) = 'REFUND' THEN 5.0
            WHEN UPPER(sb.EVENT_TYPE) = 'DOWNGRADE' THEN 4.0
            WHEN UPPER(sb.EVENT_TYPE) = 'CANCELLATION' THEN 4.5
            WHEN DATEDIFF('day', sb.EVENT_DATE, CURRENT_DATE()) > 90 THEN 3.0
            ELSE 1.0
        END AS CHURN_RISK_SCORE,
        CASE 
            WHEN UPPER(sb.EVENT_TYPE) = 'REFUND' THEN 'Refunded'
            WHEN sb.AMOUNT > 0 THEN 'Successful'
            ELSE 'Pending'
        END AS PAYMENT_STATUS,
        CASE 
            WHEN UPPER(sb.EVENT_TYPE) = 'REFUND' THEN 'Customer Request'
            ELSE NULL
        END AS REFUND_REASON,
        'Online' AS SALES_CHANNEL, -- Default value
        NULL AS PROMOTION_CODE, -- Default value
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        sb.SOURCE_SYSTEM
    FROM source_billing sb
    LEFT JOIN {{ ref('go_dim_date') }} dd 
        ON sb.EVENT_DATE = dd.DATE_VALUE
    LEFT JOIN {{ ref('go_dim_user') }} du 
        ON sb.USER_ID = du.USER_ID 
        AND du.IS_CURRENT_RECORD = TRUE
    LEFT JOIN user_license_mapping ulm 
        ON sb.USER_ID = ulm.ASSIGNED_TO_USER_ID
        AND sb.EVENT_DATE BETWEEN ulm.START_DATE AND COALESCE(ulm.END_DATE, '9999-12-31'::DATE)
    LEFT JOIN {{ ref('go_dim_license') }} dl 
        ON ulm.LICENSE_TYPE = dl.LICENSE_TYPE 
        AND dl.IS_CURRENT_RECORD = TRUE
)

SELECT * FROM revenue_events_fact
