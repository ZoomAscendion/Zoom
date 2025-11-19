{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (process_name, source_table, target_table, process_status, start_time, load_date, source_system) VALUES ('go_fact_revenue_events', 'SI_BILLING_EVENTS', 'go_fact_revenue_events', 'STARTED', CURRENT_TIMESTAMP(), CURRENT_DATE(), 'DBT_GOLD_PIPELINE')",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET process_status = 'COMPLETED', end_time = CURRENT_TIMESTAMP() WHERE target_table = 'go_fact_revenue_events' AND process_status = 'STARTED'"
) }}

-- Revenue events fact table
WITH source_billing AS (
    SELECT 
        event_id,
        user_id,
        event_type,
        amount,
        event_date,
        source_system
    FROM {{ source('silver', 'si_billing_events') }}
    WHERE event_date IS NOT NULL
      AND amount IS NOT NULL
),

revenue_events_facts AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY sb.event_date, sb.event_id) AS revenue_event_id,
        dd.date_id,
        dl.license_id,
        du.user_dim_id,
        sb.event_id AS billing_event_id,
        sb.event_date AS transaction_date,
        sb.event_date::TIMESTAMP_NTZ AS transaction_timestamp,
        sb.event_type,
        'Recurring Revenue' AS revenue_type,
        sb.amount AS gross_amount,
        sb.amount * 0.08 AS tax_amount,
        0.00 AS discount_amount,
        sb.amount * 0.92 AS net_amount,
        'USD' AS currency_code,
        1.0 AS exchange_rate,
        sb.amount AS usd_amount,
        'Credit Card' AS payment_method,
        12 AS subscription_period_months,
        1 AS license_quantity,
        0.00 AS proration_amount,
        sb.amount * 0.05 AS commission_amount,
        sb.amount / 12 AS mrr_impact,
        sb.amount AS arr_impact,
        sb.amount * 2.5 AS customer_lifetime_value,
        2.0 AS churn_risk_score,
        'Successful' AS payment_status,
        NULL AS refund_reason,
        'Online' AS sales_channel,
        NULL AS promotion_code,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        sb.source_system
    FROM source_billing sb
    LEFT JOIN {{ ref('go_dim_date') }} dd ON sb.event_date = dd.date_value
    LEFT JOIN {{ ref('go_dim_user') }} du ON du.user_dim_id = 1  -- Simplified join
    LEFT JOIN {{ ref('go_dim_license') }} dl ON dl.license_id = 1  -- Simplified join
)

SELECT * FROM revenue_events_facts
