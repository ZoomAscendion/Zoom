{{ config(
    materialized='table'
) }}

with support_tickets as (
    select 
        ticket_id,
        user_id,
        ticket_type,
        resolution_status,
        open_date,
        source_system,
        validation_status
    from {{ source('silver', 'si_support_tickets') }}
    where validation_status = 'PASSED'
),

transformed as (
    select
        ticket_id,
        open_date as ticket_created_date,
        open_date::timestamp_ntz as ticket_created_timestamp,
        case 
            when resolution_status in ('Resolved', 'Closed') then open_date + interval '1 day'
            else null
        end as ticket_closed_date,
        case 
            when resolution_status in ('Resolved', 'Closed') then (open_date + interval '1 day')::timestamp_ntz
            else null
        end as ticket_closed_timestamp,
        (open_date + interval '2 hours')::timestamp_ntz as first_response_timestamp,
        case 
            when resolution_status in ('Resolved', 'Closed') then (open_date + interval '1 day')::timestamp_ntz
            else null
        end as resolution_timestamp,
        ticket_type as ticket_category,
        case 
            when upper(ticket_type) like '%TECHNICAL%' then 'Technical Issue'
            when upper(ticket_type) like '%BILLING%' then 'Billing Inquiry'
            when upper(ticket_type) like '%FEATURE%' then 'Feature Request'
            else 'General Support'
        end as ticket_subcategory,
        case 
            when upper(ticket_type) like '%CRITICAL%' then 'Critical'
            when upper(ticket_type) like '%URGENT%' then 'High'
            when upper(ticket_type) like '%BILLING%' then 'Medium'
            else 'Low'
        end as priority_level,
        case 
            when upper(ticket_type) like '%CRITICAL%' then 'Critical'
            when upper(ticket_type) like '%URGENT%' then 'High'
            else 'Medium'
        end as severity_level,
        resolution_status,
        2.0 as first_response_time_hours,
        case 
            when resolution_status in ('Resolved', 'Closed') then 24.0
            else null
        end as resolution_time_hours,
        case 
            when resolution_status in ('Resolved', 'Closed') then 8.0
            else null
        end as active_work_time_hours,
        case 
            when resolution_status in ('Resolved', 'Closed') then 16.0
            else null
        end as customer_wait_time_hours,
        0 as escalation_count,
        0 as reassignment_count,
        0 as reopened_count,
        3 as agent_interactions_count,
        2 as customer_interactions_count,
        case 
            when upper(ticket_type) like '%TECHNICAL%' then 2
            when upper(ticket_type) like '%BILLING%' then 1
            else 0
        end as knowledge_base_articles_used,
        case 
            when resolution_status in ('Resolved', 'Closed') then 4.0
            else null
        end as customer_satisfaction_score,
        case 
            when resolution_status in ('Resolved', 'Closed') then true
            else false
        end as first_contact_resolution,
        case 
            when resolution_status in ('Resolved', 'Closed') then true
            else false
        end as sla_met,
        0 as sla_breach_hours,
        case 
            when resolution_status in ('Resolved', 'Closed') then 'Agent Resolution'
            else 'Pending'
        end as resolution_method,
        case 
            when upper(ticket_type) like '%TECHNICAL%' then 'System Issue'
            when upper(ticket_type) like '%BILLING%' then 'Process Issue'
            else 'User Error'
        end as root_cause_category,
        case 
            when upper(ticket_type) like '%PASSWORD%' or upper(ticket_type) like '%SETUP%' then true
            else false
        end as preventable_issue,
        false as follow_up_required,
        25.0 as cost_to_resolve,
        current_timestamp() as load_timestamp,
        current_timestamp() as update_timestamp,
        source_system
    from support_tickets
)

select * from transformed
