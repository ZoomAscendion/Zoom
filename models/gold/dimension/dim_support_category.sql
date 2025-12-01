{{ config(
    materialized='table',
    unique_key='support_category_id'
) }}

with source_support as (
    select distinct
        ticket_type,
        source_system
    from {{ source('silver', 'si_support_tickets') }}
    where validation_status = 'PASSED'
      and ticket_type is not null
),

support_category_dimension as (
    select 
        row_number() over (order by ticket_type) as support_category_id,
        initcap(trim(ticket_type)) as support_category,
        case 
            when upper(ticket_type) like '%TECHNICAL%' then 'Technical Issue'
            when upper(ticket_type) like '%BILLING%' then 'Billing Inquiry'
            when upper(ticket_type) like '%FEATURE%' then 'Feature Request'
            else 'General Support'
        end as support_subcategory,
        case 
            when upper(ticket_type) like '%CRITICAL%' then 'Critical'
            when upper(ticket_type) like '%URGENT%' then 'High'
            when upper(ticket_type) like '%BILLING%' then 'Medium'
            else 'Low'
        end as priority_level,
        case 
            when upper(ticket_type) like '%CRITICAL%' then 4.0
            when upper(ticket_type) like '%URGENT%' then 24.0
            when upper(ticket_type) like '%BILLING%' then 48.0
            else 72.0
        end as expected_resolution_time_hours,
        case 
            when upper(ticket_type) like '%CRITICAL%' then true
            else false
        end as requires_escalation,
        case 
            when upper(ticket_type) like '%BILLING%' or upper(ticket_type) like '%FEATURE%' then true
            else false
        end as self_service_available,
        case 
            when upper(ticket_type) like '%TECHNICAL%' then 15
            when upper(ticket_type) like '%BILLING%' then 10
            else 5
        end as knowledge_base_articles,
        'Standard resolution steps for ' || ticket_type as common_resolution_steps,
        case 
            when upper(ticket_type) like '%CRITICAL%' then 'High'
            when upper(ticket_type) like '%TECHNICAL%' then 'Medium'
            else 'Low'
        end as customer_impact_level,
        case 
            when upper(ticket_type) like '%TECHNICAL%' then 'Technical Support'
            when upper(ticket_type) like '%BILLING%' then 'Billing Department'
            else 'Customer Success'
        end as department_responsible,
        case 
            when upper(ticket_type) like '%CRITICAL%' then 4.0
            when upper(ticket_type) like '%URGENT%' then 24.0
            when upper(ticket_type) like '%BILLING%' then 48.0
            else 72.0
        end as sla_target_hours,
        current_date as load_date,
        current_date as update_date,
        source_system
    from source_support
)

select * from support_category_dimension
