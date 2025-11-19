{{
  config(
    materialized='table',
    cluster_by=['DATE_ID', 'USER_DIM_ID', 'LICENSE_ID'],
    tags=['fact', 'gold'],
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (AUDIT_LOG_ID, PROCESS_NAME, PROCESS_TYPE, EXECUTION_START_TIMESTAMP, EXECUTION_STATUS, SOURCE_TABLE_NAME, TARGET_TABLE_NAME, PROCESS_TRIGGER, EXECUTED_BY, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key(['go_fact_revenue_events', run_started_at]) }}', 'go_fact_revenue_events', 'FACT_LOAD', CURRENT_TIMESTAMP(), 'RUNNING', 'SI_BILLING_EVENTS', 'GO_FACT_REVENUE_EVENTS', 'DBT_RUN', 'DBT_SYSTEM', CURRENT_DATE(), CURRENT_DATE(), 'DBT_GOLD_LAYER'",
    post_hook="INSERT INTO {{ ref('go_audit_log') }} (AUDIT_LOG_ID, PROCESS_NAME, PROCESS_TYPE, EXECUTION_START_TIMESTAMP, EXECUTION_END_TIMESTAMP, EXECUTION_STATUS, SOURCE_TABLE_NAME, TARGET_TABLE_NAME, RECORDS_PROCESSED, PROCESS_TRIGGER, EXECUTED_BY, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key(['go_fact_revenue_events_complete', run_started_at]) }}', 'go_fact_revenue_events', 'FACT_LOAD', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 'SUCCESS', 'SI_BILLING_EVENTS', 'GO_FACT_REVENUE_EVENTS', (SELECT COUNT(*) FROM {{ this }}), 'DBT_RUN', 'DBT_SYSTEM', CURRENT_DATE(), CURRENT_DATE(), 'DBT_GOLD_LAYER'"
  )
}}

-- Revenue Events Fact Table
-- Captures detailed billing events and revenue metrics with dimensional relationships

WITH billing_events_base AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        EVENT_TYPE,
        AMOUNT,
        EVENT_DATE,
        SOURCE_SYSTEM
    FROM {{ source('silver', 'si_billing_events') }}
    WHERE VALIDATION_STATUS = 'PASSED'
),

user_license_mapping AS (
    SELECT 
        ASSIGNED_TO_USER_ID AS USER_ID,
        LICENSE_TYPE,
        START_DATE,
        END_DATE
    FROM {{ source('silver', 'si_licenses') }}
    WHERE VALIDATION_STATUS = 'PASSED'
),

revenue_events_facts AS (
    SELECT 
        -- Surrogate Key
        {{ dbt_utils.generate_surrogate_key(['beb.EVENT_ID']) }} AS REVENUE_EVENT_ID,
        
        -- Foreign Keys
        dd.DATE_ID,
        COALESCE(dl.LICENSE_ID, 1) AS LICENSE_ID,
        COALESCE(du.USER_DIM_ID, 1) AS USER_DIM_ID,
        
        -- Event Information
        beb.EVENT_ID AS BILLING_EVENT_ID,
        beb.EVENT_DATE AS TRANSACTION_DATE,
        beb.EVENT_DATE::TIMESTAMP_NTZ AS TRANSACTION_TIMESTAMP,
        beb.EVENT_TYPE,
        
        -- Revenue Classification
        CASE 
            WHEN UPPER(beb.EVENT_TYPE) IN ('SUBSCRIPTION', 'RENEWAL', 'UPGRADE') THEN 'Recurring'
            WHEN UPPER(beb.EVENT_TYPE) IN ('ONE_TIME', 'SETUP_FEE') THEN 'One-time'
            ELSE 'Other'
        END AS REVENUE_TYPE,
        
        -- Financial Metrics
        beb.AMOUNT AS GROSS_AMOUNT,
        beb.AMOUNT * 0.08 AS TAX_AMOUNT, -- Assuming 8% tax rate
        0.00 AS DISCOUNT_AMOUNT, -- Default value
        beb.AMOUNT * 0.92 AS NET_AMOUNT, -- After tax
        'USD' AS CURRENCY_CODE,
        1.0 AS EXCHANGE_RATE,
        beb.AMOUNT AS USD_AMOUNT,
        
        -- Payment Information
        'Credit Card' AS PAYMENT_METHOD, -- Default value
        12 AS SUBSCRIPTION_PERIOD_MONTHS, -- Default annual subscription
        1 AS LICENSE_QUANTITY, -- Default quantity
        0.00 AS PRORATION_AMOUNT, -- Default value
        beb.AMOUNT * 0.05 AS COMMISSION_AMOUNT, -- Assuming 5% commission
        
        -- Revenue Impact Calculations
        CASE 
            WHEN UPPER(beb.EVENT_TYPE) IN ('SUBSCRIPTION', 'RENEWAL', 'UPGRADE') THEN beb.AMOUNT / 12
            ELSE 0
        END AS MRR_IMPACT,
        
        CASE 
            WHEN UPPER(beb.EVENT_TYPE) IN ('SUBSCRIPTION', 'RENEWAL', 'UPGRADE') THEN beb.AMOUNT
            ELSE 0
        END AS ARR_IMPACT,
        
        -- Customer Metrics
        beb.AMOUNT * 5 AS CUSTOMER_LIFETIME_VALUE, -- Estimated CLV multiplier
        
        -- Churn Risk Score
        CASE 
            WHEN UPPER(beb.EVENT_TYPE) = 'DOWNGRADE' THEN 4.0
            WHEN UPPER(beb.EVENT_TYPE) = 'REFUND' THEN 3.5
            WHEN DATEDIFF('day', beb.EVENT_DATE, CURRENT_DATE()) > 90 
                 AND UPPER(beb.EVENT_TYPE) = 'SUBSCRIPTION' THEN 3.0
            WHEN beb.AMOUNT < 0 THEN 2.5
            ELSE 1.0
        END AS CHURN_RISK_SCORE,
        
        -- Payment Status
        CASE 
            WHEN UPPER(beb.EVENT_TYPE) = 'REFUND' THEN 'Refunded'
            WHEN beb.AMOUNT > 0 THEN 'Successful'
            WHEN beb.AMOUNT = 0 THEN 'Pending'
            ELSE 'Failed'
        END AS PAYMENT_STATUS,
        
        -- Additional Attributes
        CASE 
            WHEN UPPER(beb.EVENT_TYPE) = 'REFUND' THEN 'Customer Request'
            ELSE NULL
        END AS REFUND_REASON,
        
        'Online' AS SALES_CHANNEL, -- Default value
        NULL AS PROMOTION_CODE, -- Default value
        
        -- Metadata
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        beb.SOURCE_SYSTEM
    FROM billing_events_base beb
    LEFT JOIN {{ ref('go_dim_date') }} dd ON beb.EVENT_DATE = dd.DATE_VALUE
    LEFT JOIN {{ ref('go_dim_user') }} du ON beb.USER_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
    LEFT JOIN user_license_mapping ulm ON beb.USER_ID = ulm.USER_ID
    LEFT JOIN {{ ref('go_dim_license') }} dl ON ulm.LICENSE_TYPE = dl.LICENSE_TYPE AND dl.IS_CURRENT_RECORD = TRUE
)

SELECT * FROM revenue_events_facts
