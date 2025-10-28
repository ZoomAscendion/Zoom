{{ config(
    materialized='table'
) }}

-- Gold Billing Facts Table
WITH billing_base AS (
    SELECT 
        b.billing_event_id,
        b.user_id,
        b.event_type,
        b.amount,
        b.event_date,
        b.currency_code,
        b.payment_method,
        b.transaction_status,
        b.load_date as b_load_date,
        b.update_date as b_update_date,
        b.source_system as b_source_system
    FROM {{ source('silver', 'si_billing_events') }} b
),

user_info AS (
    SELECT 
        u.user_id,
        u.user_name,
        u.plan_type,
        u.company
    FROM {{ source('silver', 'si_users') }} u
),

billing_enriched AS (
    SELECT 
        bb.*,
        ui.user_name,
        ui.plan_type,
        ui.company
    FROM billing_base bb
    LEFT JOIN user_info ui ON bb.user_id = ui.user_id
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY billing_event_id) as billing_fact_id,
    event_date as transaction_date,
    COALESCE(user_name, 'Unknown User') as user_name,
    COALESCE(event_type, 'Unknown') as event_type,
    COALESCE(amount, 0.00) as amount,
    COALESCE(currency_code, 'USD') as currency_code,
    COALESCE(payment_method, 'Unknown') as payment_method,
    COALESCE(transaction_status, 'Pending') as transaction_status,
    COALESCE(plan_type, 'Free') as plan_type,
    COALESCE(company, 'Individual') as company,
    -- Revenue recognition calculation
    CASE 
        WHEN event_type = 'Subscription' THEN amount
        WHEN event_type = 'Upgrade' THEN amount
        WHEN event_type = 'Refund' THEN -amount
        ELSE amount 
    END as revenue_recognition_amount,
    -- Additional columns from Silver layer
    billing_event_id,
    user_id,
    event_date,
    -- Metadata columns
    COALESCE(b_load_date, CURRENT_DATE()) as load_date,
    COALESCE(b_update_date, CURRENT_DATE()) as update_date,
    COALESCE(b_source_system, 'ZOOM_BILLING') as source_system
FROM billing_enriched
