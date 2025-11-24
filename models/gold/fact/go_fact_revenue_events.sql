{{ config(
    materialized='table',
    unique_key='revenue_event_id'
) }}

with source_billing as (
    select 
        event_id,
        user_id,
        event_type,
        amount,
        event_date,
        source_system
    from {{ source('silver', 'si_billing_events') }}
    where validation_status = 'PASSED'
),

revenue_events_fact as (
    select 
        row_number() over (order by sb.event_id) as revenue_event_id,
        dd.date_id as date_id,
        dl.license_id as license_id,
        du.user_dim_id as user_dim_id,
        sb.event_id as billing_event_id,
        sb.event_date as transaction_date,
        sb.event_date::timestamp_ntz as transaction_timestamp,
        sb.event_type,
        case 
            when sb.event_type in ('Subscription', 'Renewal', 'Upgrade') then 'Recurring'
            when sb.event_type in ('One-time Purchase', 'Setup Fee') then 'One-time'
            when sb.event_type = 'Refund' then 'Refund'
            else 'Other'
        end as revenue_type,
        sb.amount as gross_amount,
        sb.amount * 0.1 as tax_amount,
        0 as discount_amount,
        case 
            when sb.event_type = 'Refund' then -sb.amount
            else sb.amount
        end as net_amount,
        'USD' as currency_code,
        1.0 as exchange_rate,
        sb.amount as usd_amount,
        'Credit Card' as payment_method,
        case 
            when sb.event_type in ('Subscription', 'Renewal') then 12
            else 1
        end as subscription_period_months,
        1 as license_quantity,
        0 as proration_amount,
        sb.amount * 0.05 as commission_amount,
        case 
            when sb.event_type in ('Subscription', 'Renewal', 'Upgrade') then sb.amount / 12
            else 0
        end as mrr_impact,
        case 
            when sb.event_type in ('Subscription', 'Renewal', 'Upgrade') then sb.amount
            else 0
        end as arr_impact,
        sb.amount * 10 as customer_lifetime_value,
        case 
            when sb.event_type = 'Downgrade' then 4.0
            when sb.event_type = 'Refund' then 3.5
            when datediff('day', sb.event_date, current_date()) > 90 and sb.event_type = 'Subscription' then 3.0
            when sb.amount < 0 then 2.5
            else 1.0
        end as churn_risk_score,
        case 
            when sb.event_type = 'Refund' then 'Refunded'
            when sb.amount > 0 then 'Successful'
            when sb.amount = 0 then 'Pending'
            else 'Failed'
        end as payment_status,
        case 
            when sb.event_type = 'Refund' then 'Customer Request'
            else null
        end as refund_reason,
        'Online' as sales_channel,
        null as promotion_code,
        current_date as load_date,
        current_date as update_date,
        sb.source_system
    from source_billing sb
    left join {{ ref('go_dim_date') }} dd on sb.event_date = dd.date_value
    left join {{ ref('go_dim_user') }} du on sb.user_id = du.user_id
    left join {{ source('silver', 'si_licenses') }} sl on sb.user_id = sl.assigned_to_user_id
    left join {{ ref('go_dim_license') }} dl on sl.license_type = dl.license_type
)

select * from revenue_events_fact
