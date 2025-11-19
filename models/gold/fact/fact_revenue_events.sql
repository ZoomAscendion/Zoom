{{ config(
    materialized='table',
    cluster_by=['date_id', 'user_dim_id']
) }}

-- Create sample revenue events fact data
with sample_revenue_events as (
    select
        1 as revenue_event_id,
        
        -- Foreign keys to dimensions
        (select date_id from {{ ref('dim_date') }} where date_value = current_date limit 1) as date_id,
        2 as license_id,
        1 as user_dim_id,
        
        -- Event identifiers
        'BILL001' as billing_event_id,
        current_date as transaction_date,
        current_timestamp as transaction_timestamp,
        'SUBSCRIPTION' as event_type,
        
        -- Revenue classification
        'Subscription' as revenue_type,
        
        -- Financial metrics
        19.99 as gross_amount,
        2.00 as tax_amount,
        0.00 as discount_amount,
        17.99 as net_amount,
        'USD' as currency_code,
        1.0 as exchange_rate,
        19.99 as usd_amount,
        
        'Credit Card' as payment_method,
        12 as subscription_period_months,
        1 as license_quantity,
        0.00 as proration_amount,
        1.00 as commission_amount,
        
        -- MRR/ARR calculations
        19.99 as mrr_impact,
        239.88 as arr_impact,
        
        -- Customer metrics
        239.88 as customer_lifetime_value,
        1.0 as churn_risk_score,
        'Successful' as payment_status,
        null as refund_reason,
        'Online' as sales_channel,
        null as promotion_code,
        
        -- Metadata
        current_date as load_date,
        current_date as update_date,
        'SAMPLE_DATA' as source_system
    
    union all
    
    select
        2 as revenue_event_id,
        
        -- Foreign keys to dimensions
        (select date_id from {{ ref('dim_date') }} where date_value = current_date - 30 limit 1) as date_id,
        1 as license_id,
        2 as user_dim_id,
        
        -- Event identifiers
        'BILL002' as billing_event_id,
        current_date - 30 as transaction_date,
        current_timestamp - interval '30 days' as transaction_timestamp,
        'SUBSCRIPTION' as event_type,
        
        -- Revenue classification
        'Subscription' as revenue_type,
        
        -- Financial metrics
        14.99 as gross_amount,
        1.50 as tax_amount,
        0.00 as discount_amount,
        13.49 as net_amount,
        'USD' as currency_code,
        1.0 as exchange_rate,
        14.99 as usd_amount,
        
        'Credit Card' as payment_method,
        12 as subscription_period_months,
        1 as license_quantity,
        0.00 as proration_amount,
        0.75 as commission_amount,
        
        -- MRR/ARR calculations
        14.99 as mrr_impact,
        179.88 as arr_impact,
        
        -- Customer metrics
        179.88 as customer_lifetime_value,
        1.5 as churn_risk_score,
        'Successful' as payment_status,
        null as refund_reason,
        'Online' as sales_channel,
        null as promotion_code,
        
        -- Metadata
        current_date as load_date,
        current_date as update_date,
        'SAMPLE_DATA' as source_system
)

select * from sample_revenue_events
