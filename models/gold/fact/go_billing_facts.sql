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
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY bb.billing_event_id) as billing_fact_id,
    bb.event_date as transaction_date,
    COALESCE(ui.user_name, 'Unknown User') as user_name,
    COALESCE(bb.event_type, 'Unknown') as event_type,
    COALESCE(bb.amount, 0.00) as amount,
    COALESCE(bb.currency_code, 'USD') as currency_code,
    COALESCE(bb.payment_method, 'Unknown') as payment_method,
    COALESCE(bb.transaction_status, 'Pending') as transaction_status,
    COALESCE(ui.plan_type, 'Free') as plan_type,
    COALESCE(ui.company, 'Individual') as company,
    -- Revenue recognition calculation
    CASE 
        WHEN bb.event_type = 'Subscription' THEN bb.amount
        WHEN bb.event_type = 'Upgrade' THEN bb.amount
        WHEN bb.event_type = 'Refund' THEN -bb.amount
        ELSE bb.amount 
    END as revenue_recognition_amount,
    -- Additional columns from Silver layer
    bb.billing_event_id,
    bb.user_id,
    bb.event_date,
    -- Metadata columns
    COALESCE(bb.b_load_date, CURRENT_DATE()) as load_date,
    COALESCE(bb.b_update_date, CURRENT_DATE()) as update_date,
    COALESCE(bb.b_source_system, 'ZOOM_BILLING') as source_system
FROM billing_base bb
LEFT JOIN user_info ui ON bb.user_id = ui.user_id
