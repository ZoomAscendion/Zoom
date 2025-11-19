{{ config(
    materialized='table'
) }}

-- Revenue events fact table with financial metrics and analytics
-- Comprehensive billing and revenue tracking with MRR/ARR calculations

WITH source_billing AS (
    SELECT 
        event_id,
        user_id,
        event_type,
        amount,
        event_date,
        source_system
    FROM {{ source('silver', 'si_billing_events') }}
    WHERE validation_status = 'PASSED'
      AND data_quality_score >= 70
      AND event_date IS NOT NULL
      AND amount IS NOT NULL
),

user_licenses AS (
    SELECT 
        assigned_to_user_id,
        license_type,
        start_date,
        end_date
    FROM {{ source('silver', 'si_licenses') }}
    WHERE validation_status = 'PASSED'
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
        CASE 
            WHEN UPPER(sb.event_type) IN ('SUBSCRIPTION', 'RENEWAL', 'UPGRADE') THEN 'Recurring Revenue'
            WHEN UPPER(sb.event_type) IN ('ONE_TIME', 'SETUP', 'ADDON') THEN 'One-time Revenue'
            WHEN UPPER(sb.event_type) = 'REFUND' THEN 'Refund'
            ELSE 'Other'
        END AS revenue_type,
        sb.amount AS gross_amount,
        sb.amount * 0.08 AS tax_amount,  -- Simplified tax calculation
        0.00 AS discount_amount,  -- Default value
        CASE 
            WHEN UPPER(sb.event_type) = 'REFUND' THEN -sb.amount
            ELSE sb.amount - (sb.amount * 0.08)  -- Net after tax
        END AS net_amount,
        'USD' AS currency_code,
        1.0 AS exchange_rate,
        CASE 
            WHEN UPPER(sb.event_type) = 'REFUND' THEN -sb.amount
            ELSE sb.amount
        END AS usd_amount,
        'Credit Card' AS payment_method,  -- Default value
        CASE 
            WHEN UPPER(sb.event_type) IN ('SUBSCRIPTION', 'RENEWAL') THEN 12
            ELSE 0
        END AS subscription_period_months,
        1 AS license_quantity,  -- Default value
        0.00 AS proration_amount,  -- Default value
        sb.amount * 0.05 AS commission_amount,  -- Simplified commission
        -- MRR Impact calculation
        CASE 
            WHEN UPPER(sb.event_type) IN ('SUBSCRIPTION', 'RENEWAL', 'UPGRADE') THEN sb.amount / 12
            WHEN UPPER(sb.event_type) = 'REFUND' THEN -(sb.amount / 12)
            ELSE 0
        END AS mrr_impact,
        -- ARR Impact calculation
        CASE 
            WHEN UPPER(sb.event_type) IN ('SUBSCRIPTION', 'RENEWAL', 'UPGRADE') THEN sb.amount
            WHEN UPPER(sb.event_type) = 'REFUND' THEN -sb.amount
            ELSE 0
        END AS arr_impact,
        -- Customer lifetime value (simplified)
        sb.amount * 2.5 AS customer_lifetime_value,
        -- Churn risk score
        CASE 
            WHEN UPPER(sb.event_type) = 'REFUND' THEN 5.0
            WHEN UPPER(sb.event_type) = 'DOWNGRADE' THEN 4.0
            WHEN sb.amount < 100 THEN 3.0
            WHEN sb.amount >= 500 THEN 1.0
            ELSE 2.0
        END AS churn_risk_score,
        CASE 
            WHEN UPPER(sb.event_type) = 'REFUND' THEN 'Refunded'
            WHEN sb.amount > 0 THEN 'Successful'
            ELSE 'Pending'
        END AS payment_status,
        CASE 
            WHEN UPPER(sb.event_type) = 'REFUND' THEN 'Customer Request'
            ELSE NULL
        END AS refund_reason,
        'Online' AS sales_channel,  -- Default value
        NULL AS promotion_code,  -- Default value
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        sb.source_system
    FROM source_billing sb
    LEFT JOIN {{ ref('go_dim_date') }} dd ON sb.event_date = dd.date_value
    LEFT JOIN {{ ref('go_dim_user') }} du ON sb.user_id = du.user_id AND du.is_current_record = TRUE
    LEFT JOIN user_licenses ul ON sb.user_id = ul.assigned_to_user_id
    LEFT JOIN {{ ref('go_dim_license') }} dl ON ul.license_type = dl.license_type AND dl.is_current_record = TRUE
)

SELECT * FROM revenue_events_facts
