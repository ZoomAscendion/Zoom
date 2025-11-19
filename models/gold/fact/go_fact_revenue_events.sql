{{ config(
    materialized='table',
    tags=['fact', 'gold'],
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} SELECT {{ dbt_utils.generate_surrogate_key(['\"GO_FACT_REVENUE_EVENTS\"', 'CURRENT_TIMESTAMP()']) }} AS audit_log_id, 'GO_FACT_REVENUE_EVENTS' AS process_name, 'FACT_LOAD' AS process_type, CURRENT_TIMESTAMP() AS execution_start_timestamp, NULL AS execution_end_timestamp, NULL AS execution_duration_seconds, 'RUNNING' AS execution_status, 'SI_BILLING_EVENTS' AS source_table_name, 'GO_FACT_REVENUE_EVENTS' AS target_table_name, 0 AS records_read, 0 AS records_processed, 0 AS records_inserted, 0 AS records_updated, 0 AS records_failed, 100.0 AS data_quality_score, 0 AS error_count, 0 AS warning_count, 'DBT_RUN' AS process_trigger, 'DBT_SYSTEM' AS executed_by, 'DBT_SERVER' AS server_name, '1.0.0' AS process_version, PARSE_JSON('{}') AS configuration_parameters, PARSE_JSON('{}') AS performance_metrics, CURRENT_DATE() AS load_date, CURRENT_DATE() AS update_date, 'DBT_GOLD_PIPELINE' AS source_system",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET execution_end_timestamp = CURRENT_TIMESTAMP(), execution_status = 'SUCCESS', records_processed = (SELECT COUNT(*) FROM {{ this }}), execution_duration_seconds = DATEDIFF('second', execution_start_timestamp, CURRENT_TIMESTAMP()) WHERE process_name = 'GO_FACT_REVENUE_EVENTS' AND execution_status = 'RUNNING'"
) }}

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
),

user_license_mapping AS (
    SELECT 
        sl.ASSIGNED_TO_USER_ID,
        sl.LICENSE_TYPE
    FROM {{ source('silver', 'si_licenses') }} sl
    WHERE sl.VALIDATION_STATUS = 'PASSED'
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY bb.EVENT_ID) AS revenue_event_id,
    dd.date_id AS date_id,
    dl.license_id AS license_id,
    du.user_dim_id AS user_dim_id,
    bb.EVENT_ID AS billing_event_id,
    bb.EVENT_DATE AS transaction_date,
    bb.EVENT_DATE::TIMESTAMP_NTZ AS transaction_timestamp,
    bb.EVENT_TYPE,
    CASE 
        WHEN bb.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') THEN 'Recurring'
        WHEN bb.EVENT_TYPE IN ('One-time Purchase', 'Setup Fee') THEN 'One-time'
        WHEN bb.EVENT_TYPE = 'Refund' THEN 'Refund'
        ELSE 'Other'
    END AS revenue_type,
    bb.AMOUNT AS gross_amount,
    bb.AMOUNT * 0.08 AS tax_amount,
    0.00 AS discount_amount,
    bb.AMOUNT * 0.92 AS net_amount,
    'USD' AS currency_code,
    1.0 AS exchange_rate,
    bb.AMOUNT AS usd_amount,
    'Credit Card' AS payment_method,
    CASE 
        WHEN bb.EVENT_TYPE IN ('Subscription', 'Renewal') THEN 12
        ELSE 0
    END AS subscription_period_months,
    1 AS license_quantity,
    0.00 AS proration_amount,
    bb.AMOUNT * 0.05 AS commission_amount,
    CASE 
        WHEN bb.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') THEN bb.AMOUNT / 12
        ELSE 0
    END AS mrr_impact,
    CASE 
        WHEN bb.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') THEN bb.AMOUNT
        ELSE 0
    END AS arr_impact,
    bb.AMOUNT * 5 AS customer_lifetime_value,
    CASE 
        WHEN bb.EVENT_TYPE = 'Downgrade' THEN 4.0
        WHEN bb.EVENT_TYPE = 'Refund' THEN 3.5
        WHEN DATEDIFF('day', bb.EVENT_DATE, CURRENT_DATE()) > 90 AND bb.EVENT_TYPE = 'Subscription' THEN 3.0
        WHEN bb.AMOUNT < 0 THEN 2.5
        ELSE 1.0
    END AS churn_risk_score,
    CASE 
        WHEN bb.EVENT_TYPE = 'Refund' THEN 'Refunded'
        WHEN bb.AMOUNT > 0 THEN 'Successful'
        WHEN bb.AMOUNT = 0 THEN 'Pending'
        ELSE 'Failed'
    END AS payment_status,
    CASE 
        WHEN bb.EVENT_TYPE = 'Refund' THEN 'Customer Request'
        ELSE NULL
    END AS refund_reason,
    'Online' AS sales_channel,
    NULL AS promotion_code,
    CURRENT_DATE() AS load_date,
    CURRENT_DATE() AS update_date,
    COALESCE(bb.SOURCE_SYSTEM, 'UNKNOWN') AS source_system
FROM billing_base bb
LEFT JOIN {{ ref('go_dim_date') }} dd ON bb.EVENT_DATE = dd.date_key
LEFT JOIN {{ ref('go_dim_user') }} du ON bb.USER_ID = du.user_id AND du.is_current_record = TRUE
LEFT JOIN user_license_mapping ulm ON bb.USER_ID = ulm.ASSIGNED_TO_USER_ID
LEFT JOIN {{ ref('go_dim_license') }} dl ON ulm.LICENSE_TYPE = dl.license_type AND dl.is_current_record = TRUE
