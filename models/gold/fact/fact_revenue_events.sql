{{ config(
    materialized='table',
    unique_key='revenue_event_id'
) }}

with source_billing as (
    select *
    from {{ source('silver', 'si_billing_events') }}
    where validation_status = 'PASSED'
),

source_licenses as (
    select *
    from {{ source('silver', 'si_licenses') }}
    where validation_status = 'PASSED'
),

revenue_events_fact as (
    select 
        row_number() over (order by sbe.event_id) as revenue_event_id,
        dd.date_id,
        coalesce(dl.license_id, 1) as license_id,
        coalesce(du.user_dim_id, 1) as user_dim_id,
        sbe.event_id as billing_event_id,
        sbe.event_date as transaction_date,
        sbe.event_date::timestamp_ntz as transaction_timestamp,
        sbe.event_type,
        case 
            when upper(sbe.event_type) in ('SUBSCRIPTION', 'RENEWAL', 'UPGRADE') then 'Recurring'
            when upper(sbe.event_type) in ('ONE_TIME', 'SETUP') then 'One-time'
            else 'Other'
        end as revenue_type,
        sbe.amount as gross_amount,
        sbe.amount * 0.1 as tax_amount, -- Assuming 10% tax
        0 as discount_amount, -- Default value
        sbe.amount * 0.9 as net_amount, -- After tax
        'USD' as currency_code,
        1.0 as exchange_rate,
        sbe.amount as usd_amount,
        'Credit Card' as payment_method, -- Default value
        case 
            when upper(sbe.event_type) in ('SUBSCRIPTION', 'RENEWAL') then 12
            else 0
        end as subscription_period_months,
        1 as license_quantity, -- Default value
        0 as proration_amount, -- Default value
        sbe.amount * 0.05 as commission_amount, -- Assuming 5% commission
        case 
            when upper(sbe.event_type) in ('SUBSCRIPTION', 'RENEWAL', 'UPGRADE') then sbe.amount / 12
            else 0
        end as mrr_impact,
        case 
            when upper(sbe.event_type) in ('SUBSCRIPTION', 'RENEWAL', 'UPGRADE') then sbe.amount
            else 0
        end as arr_impact,
        sbe.amount * 5 as customer_lifetime_value, -- Simplified calculation
        case 
            when upper(sbe.event_type) = 'DOWNGRADE' then 4.0
            when upper(sbe.event_type) = 'REFUND' then 3.5
            when datediff('day', sbe.event_date, current_date()) > 90 
                 and upper(sbe.event_type) = 'SUBSCRIPTION' then 3.0
            when sbe.amount < 0 then 2.5
            else 1.0
        end as churn_risk_score,
        case 
            when upper(sbe.event_type) = 'REFUND' then 'Refunded'
            when sbe.amount > 0 then 'Successful'
            when sbe.amount = 0 then 'Pending'
            else 'Failed'
        end as payment_status,
        case 
            when upper(sbe.event_type) = 'REFUND' then 'Customer request'
            else null
        end as refund_reason,
        'Online' as sales_channel, -- Default value
        null as promotion_code, -- Default value
        current_date as load_date,
        current_date as update_date,
        sbe.source_system
    from source_billing sbe
    left join {{ ref('dim_date') }} dd on sbe.event_date = dd.date_id
    left join {{ ref('dim_user') }} du on sbe.user_id = du.user_id and du.is_current_record = true
    left join source_licenses sl on sbe.user_id = sl.assigned_to_user_id
    left join {{ ref('dim_license') }} dl on sl.license_type = dl.license_type and dl.is_current_record = true
)

select * from revenue_events_fact
