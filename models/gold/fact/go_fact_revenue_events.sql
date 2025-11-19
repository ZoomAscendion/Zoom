{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (audit_log_id, process_name, process_type, execution_start_timestamp, execution_status, source_table_name, target_table_name, process_trigger, executed_by, load_date, source_system) VALUES ('{{ dbt_utils.generate_surrogate_key(['GO_FACT_REVENUE_EVENTS', run_started_at]) }}', 'GO_FACT_REVENUE_EVENTS_LOAD', 'DBT_MODEL', CURRENT_TIMESTAMP(), 'RUNNING', 'SI_BILLING_EVENTS', 'GO_FACT_REVENUE_EVENTS', 'DBT_RUN', 'DBT_SYSTEM', CURRENT_DATE(), 'DBT_GOLD_PIPELINE')",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET execution_end_timestamp = CURRENT_TIMESTAMP(), execution_status = 'SUCCESS', records_processed = (SELECT COUNT(*) FROM {{ this }}), execution_duration_seconds = DATEDIFF('second', execution_start_timestamp, CURRENT_TIMESTAMP()) WHERE audit_log_id = '{{ dbt_utils.generate_surrogate_key(['GO_FACT_REVENUE_EVENTS', run_started_at]) }}'"
) }}

-- Revenue events fact table transformation
WITH billing_events_base AS (
    SELECT 
        be.event_id,
        COALESCE(be.user_id, 'UNKNOWN') AS user_id,
        COALESCE(be.event_type, 'Subscription') AS event_type,
        COALESCE(be.amount, 0) AS amount,
        COALESCE(be.event_date, CURRENT_DATE()) AS event_date,
        COALESCE(be.source_system, 'UNKNOWN') AS source_system
    FROM {{ source('gold', 'si_billing_events') }} be
    WHERE be.validation_status = 'PASSED'
),

revenue_events_fact AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY beb.event_id) AS revenue_event_id,
        dd.date_id AS date_id,
        1 AS license_id, -- Default license
        1 AS user_dim_id, -- Default user
        beb.event_id AS billing_event_id,
        beb.event_date AS transaction_date,
        beb.event_date::TIMESTAMP_NTZ AS transaction_timestamp,
        beb.event_type,
        CASE 
            WHEN beb.event_type IN ('Subscription', 'Renewal', 'Upgrade') THEN 'Recurring'
            WHEN beb.event_type IN ('One-time Purchase', 'Setup Fee') THEN 'One-time'
            WHEN beb.event_type = 'Refund' THEN 'Refund'
            ELSE 'Other'
        END AS revenue_type,
        beb.amount AS gross_amount,
        beb.amount * 0.1 AS tax_amount,
        0.00 AS discount_amount,
        CASE 
            WHEN beb.event_type = 'Refund' THEN -beb.amount
            ELSE beb.amount
        END AS net_amount,
        'USD' AS currency_code,
        1.0 AS exchange_rate,
        beb.amount AS usd_amount,
        'Credit Card' AS payment_method,
        CASE 
            WHEN beb.event_type IN ('Subscription', 'Renewal') THEN 12
            ELSE 0
        END AS subscription_period_months,
        1 AS license_quantity,
        0.00 AS proration_amount,
        beb.amount * 0.05 AS commission_amount,
        CASE 
            WHEN beb.event_type IN ('Subscription', 'Renewal', 'Upgrade') THEN beb.amount / 12
            ELSE 0
        END AS mrr_impact,
        CASE 
            WHEN beb.event_type IN ('Subscription', 'Renewal', 'Upgrade') THEN beb.amount
            ELSE 0
        END AS arr_impact,
        beb.amount * 10 AS customer_lifetime_value,
        CASE 
            WHEN beb.event_type = 'Downgrade' THEN 4.0
            WHEN beb.event_type = 'Refund' THEN 3.5
            WHEN DATEDIFF('day', beb.event_date, CURRENT_DATE()) > 90 AND beb.event_type = 'Subscription' THEN 3.0
            WHEN beb.amount < 0 THEN 2.5
            ELSE 1.0
        END AS churn_risk_score,
        CASE 
            WHEN beb.event_type = 'Refund' THEN 'Refunded'
            WHEN beb.amount > 0 THEN 'Successful'
            WHEN beb.amount = 0 THEN 'Pending'
            ELSE 'Failed'
        END AS payment_status,
        CASE 
            WHEN beb.event_type = 'Refund' THEN 'Customer Request'
            ELSE NULL
        END AS refund_reason,
        'Online' AS sales_channel,
        NULL AS promotion_code,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        beb.source_system
    FROM billing_events_base beb
    LEFT JOIN {{ ref('go_dim_date') }} dd ON beb.event_date = dd.date_value
)

SELECT * FROM revenue_events_fact
