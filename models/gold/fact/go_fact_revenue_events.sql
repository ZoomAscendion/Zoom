{{ config(
    materialized='table'
) }}

with billing_events as (
    select 
        event_id,
        user_id,
        event_type,
        amount,
        event_date,
        source_system,
        validation_status
    from {{ source('silver', 'si_billing_events') }}
    where validation_status = 'PASSED'
),

licenses as (
    select 
        assigned_to_user_id,
        license_type
    from {{ source('silver', 'si_licenses') }}
    where validation_status = 'PASSED'
),

transformed as (
    select
        b.event_id as billing_event_id,
        b.event_date as transaction_date,
        b.event_date::timestamp_ntz as transaction_timestamp,
        b.event_type,
        case 
            when b.event_type in ('Subscription', 'Renewal', 'Upgrade') then 'Recurring'
            else 'One-time'
        end as revenue_type,
        b.amount as gross_amount,
        b.amount * 0.1 as tax_amount,
        0 as discount_amount,
        b.amount * 0.9 as net_amount,
        'USD' as currency_code,
        1.0 as exchange_rate,
        b.amount as usd_amount,
        'Credit Card' as payment_method,
        case 
            when b.event_type in ('Subscription', 'Renewal') then 12
            else 0
        end as subscription_period_months,
        1 as license_quantity,
        0 as proration_amount,
        b.amount * 0.05 as commission_amount,
        case 
            when b.event_type in ('Subscription', 'Renewal', 'Upgrade') then b.amount / 12
            else 0
        end as mrr_impact,
        case 
            when b.event_type in ('Subscription', 'Renewal', 'Upgrade') then b.amount
            else 0
        end as arr_impact,
        b.amount * 10 as customer_lifetime_value,
        case 
            when b.event_type = 'Downgrade' then 4.0
            when b.event_type = 'Refund' then 3.5
            when datediff('day', b.event_date, current_date()) > 90 and b.event_type = 'Subscription' then 3.0
            when b.amount < 0 then 2.5
            else 1.0
        end as churn_risk_score,
        case 
            when b.event_type = 'Refund' then 'Refunded'
            when b.amount > 0 then 'Successful'
            when b.amount = 0 then 'Pending'
            else 'Failed'
        end as payment_status,
        case 
            when b.event_type = 'Refund' then 'Customer request'
            else null
        end as refund_reason,
        'Online' as sales_channel,
        null as promotion_code,
        current_timestamp() as load_timestamp,
        current_timestamp() as update_timestamp,
        b.source_system
    from billing_events b
    left join licenses l on b.user_id = l.assigned_to_user_id
)

select * from transformed
