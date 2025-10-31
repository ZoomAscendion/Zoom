{{ config(
    materialized='table',
    cluster_by=['DATE_KEY', 'LICENSE_KEY']
) }}

-- Revenue Events Fact Table
WITH billing_base AS (
    SELECT 
        be.EVENT_ID,
        be.USER_ID,
        be.EVENT_TYPE,
        be.TRANSACTION_AMOUNT,
        be.TRANSACTION_DATE,
        be.PAYMENT_METHOD,
        be.CURRENCY_CODE,
        be.INVOICE_NUMBER,
        be.TRANSACTION_STATUS,
        be.DATA_QUALITY_SCORE,
        be.SOURCE_SYSTEM
    FROM {{ source('silver', 'si_billing_events') }} be
    WHERE be.DATA_QUALITY_SCORE >= 0.8
      AND be.TRANSACTION_STATUS = 'Completed'
),

user_info AS (
    SELECT 
        USER_ID,
        PLAN_TYPE
    FROM {{ source('silver', 'si_users') }}
    WHERE DATA_QUALITY_SCORE >= 0.8
),

license_info AS (
    SELECT 
        ASSIGNED_TO_USER_ID,
        LICENSE_TYPE
    FROM {{ source('silver', 'si_licenses') }}
    WHERE DATA_QUALITY_SCORE >= 0.8
),

fact_revenue_events AS (
    SELECT 
        CONCAT('FACT_REV_', be.EVENT_ID, '_', TO_CHAR(be.TRANSACTION_DATE, 'YYYYMMDD')) AS FACT_REVENUE_EVENTS_ID,
        be.TRANSACTION_DATE AS DATE_KEY,
        be.USER_ID AS USER_KEY,
        COALESCE(l.LICENSE_TYPE, 'UNKNOWN') AS LICENSE_KEY,
        be.TRANSACTION_DATE,
        CASE 
            WHEN be.CURRENCY_CODE = 'USD' THEN be.TRANSACTION_AMOUNT
            WHEN be.CURRENCY_CODE = 'EUR' THEN be.TRANSACTION_AMOUNT * 1.1
            WHEN be.CURRENCY_CODE = 'GBP' THEN be.TRANSACTION_AMOUNT * 1.25
            ELSE be.TRANSACTION_AMOUNT
        END AS TRANSACTION_AMOUNT_USD,
        be.TRANSACTION_AMOUNT AS ORIGINAL_AMOUNT,
        be.CURRENCY_CODE,
        be.EVENT_TYPE,
        be.PAYMENT_METHOD,
        COALESCE(l.LICENSE_TYPE, 'UNKNOWN') AS LICENSE_TYPE,
        COALESCE(u.PLAN_TYPE, 'Unknown') AS CUSTOMER_PLAN_TYPE,
        be.TRANSACTION_STATUS,
        CASE 
            WHEN be.EVENT_TYPE IN ('Subscription', 'Upgrade') THEN 
                CASE 
                    WHEN be.CURRENCY_CODE = 'USD' THEN be.TRANSACTION_AMOUNT
                    WHEN be.CURRENCY_CODE = 'EUR' THEN be.TRANSACTION_AMOUNT * 1.1
                    WHEN be.CURRENCY_CODE = 'GBP' THEN be.TRANSACTION_AMOUNT * 1.25
                    ELSE be.TRANSACTION_AMOUNT
                END
            WHEN be.EVENT_TYPE IN ('Downgrade', 'Refund') THEN 
                -1 * CASE 
                    WHEN be.CURRENCY_CODE = 'USD' THEN be.TRANSACTION_AMOUNT
                    WHEN be.CURRENCY_CODE = 'EUR' THEN be.TRANSACTION_AMOUNT * 1.1
                    WHEN be.CURRENCY_CODE = 'GBP' THEN be.TRANSACTION_AMOUNT * 1.25
                    ELSE be.TRANSACTION_AMOUNT
                END
            ELSE 0
        END AS MRR_IMPACT,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        'SILVER_LAYER' AS SOURCE_SYSTEM
    FROM billing_base be
    LEFT JOIN user_info u ON be.USER_ID = u.USER_ID
    LEFT JOIN license_info l ON be.USER_ID = l.ASSIGNED_TO_USER_ID
)

SELECT * FROM fact_revenue_events
