{{ config(
    materialized='table',
    cluster_by=['date_id', 'user_dim_id']
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

fact_revenue_events as (
    select
        row_number() over (order by sbe.event_id) as revenue_event_id,
        
        -- Foreign keys to dimensions
        dd.date_id,
        dl.license_id,
        du.user_dim_id,
        
        -- Event identifiers
        sbe.event_id as billing_event_id,
        sbe.event_date as transaction_date,
        sbe.event_date::timestamp_ntz as transaction_timestamp,
        sbe.event_type,
        
        -- Revenue classification
        case 
            when upper(sbe.event_type) in ('SUBSCRIPTION', 'RENEWAL', 'UPGRADE') then 'Subscription'
            when upper(sbe.event_type) in ('ONE_TIME', 'SETUP') then 'One-time'
            else 'Other'
        end as revenue_type,
        
        -- Financial metrics
        sbe.amount as gross_amount,
        sbe.amount * 0.1 as tax_amount, -- Placeholder 10% tax
        0.00 as discount_amount, -- Placeholder
        sbe.amount * 0.9 as net_amount, -- After tax
        'USD' as currency_code,
        1.0 as exchange_rate,
        sbe.amount as usd_amount,
        
        'Credit Card' as payment_method, -- Placeholder
        12 as subscription_period_months, -- Placeholder
        1 as license_quantity, -- Placeholder
        0.00 as proration_amount, -- Placeholder
        sbe.amount * 0.05 as commission_amount, -- Placeholder 5% commission
        
        -- MRR/ARR calculations
        case 
            when upper(sbe.event_type) in ('SUBSCRIPTION', 'RENEWAL', 'UPGRADE') then sbe.amount / 12
            else 0
        end as mrr_impact,
        
        case 
            when upper(sbe.event_type) in ('SUBSCRIPTION', 'RENEWAL', 'UPGRADE') then sbe.amount
            else 0
        end as arr_impact,
        
        -- Customer metrics (placeholders)
        sbe.amount as customer_lifetime_value,
        
        case 
            when upper(sbe.event_type) = 'REFUND' then 4.0
            when upper(sbe.event_type) = 'DOWNGRADE' then 3.0
            else 1.0
        end as churn_risk_score,
        
        case 
            when upper(sbe.event_type) = 'REFUND' then 'Refunded'
            when sbe.amount > 0 then 'Successful'
            else 'Pending'
        end as payment_status,
        
        case 
            when upper(sbe.event_type) = 'REFUND' then 'Customer Request'
            else null
        end as refund_reason,
        
        'Online' as sales_channel, -- Placeholder
        null as promotion_code, -- Placeholder
        
        -- Metadata
        current_date as load_date,
        current_date as update_date,
        sbe.source_system
        
    from source_billing sbe
    join {{ ref('dim_date') }} dd on sbe.event_date = dd.date_value
    join {{ ref('dim_user') }} du on sbe.user_id = du.user_id and du.is_current_record = true
    left join source_licenses sl on sbe.user_id = sl.assigned_to_user_id
    left join {{ ref('dim_license') }} dl on sl.license_type = dl.license_type and dl.is_current_record = true
)

select * from fact_revenue_events
