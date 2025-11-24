{{ config(
    materialized='table',
    unique_key='support_metrics_id'
) }}

with source_support as (
    select 
        ticket_id,
        user_id,
        ticket_type,
        resolution_status,
        open_date,
        source_system
    from {{ source('silver', 'si_support_tickets') }}
    where validation_status = 'PASSED'
),

support_metrics_fact as (
    select 
        row_number() over (order by ss.ticket_id) as support_metrics_id,
        dd.date_id as date_id,
        dsc.support_category_id as support_category_id,
        du.user_dim_id as user_dim_id,
        ss.ticket_id,
        ss.open_date as ticket_created_date,
        ss.open_date::timestamp_ntz as ticket_created_timestamp,
        case 
            when ss.resolution_status in ('Resolved', 'Closed') then ss.open_date + interval '1 day'
            else null
        end as ticket_closed_date,
        case 
            when ss.resolution_status in ('Resolved', 'Closed') then (ss.open_date + interval '1 day')::timestamp_ntz
            else null
        end as ticket_closed_timestamp,
        ss.open_date::timestamp_ntz + interval '2 hours' as first_response_timestamp,
        case 
            when ss.resolution_status in ('Resolved', 'Closed') then (ss.open_date + interval '1 day')::timestamp_ntz
            else null
        end as resolution_timestamp,
        ss.ticket_type as ticket_category,
        case 
            when upper(ss.ticket_type) like '%TECHNICAL%' then 'Technical Issue'
            when upper(ss.ticket_type) like '%BILLING%' then 'Billing Inquiry'
            when upper(ss.ticket_type) like '%FEATURE%' then 'Feature Request'
            else 'General Support'
        end as ticket_subcategory,
        case 
            when upper(ss.ticket_type) like '%CRITICAL%' then 'Critical'
            when upper(ss.ticket_type) like '%URGENT%' then 'High'
            when upper(ss.ticket_type) like '%BILLING%' then 'Medium'
            else 'Low'
        end as priority_level,
        case 
            when upper(ss.ticket_type) like '%CRITICAL%' then 'Critical'
            when upper(ss.ticket_type) like '%URGENT%' then 'High'
            else 'Medium'
        end as severity_level,
        ss.resolution_status,
        2.0 as first_response_time_hours,
        case 
            when ss.resolution_status in ('Resolved', 'Closed') then 24.0
            else null
        end as resolution_time_hours,
        case 
            when ss.resolution_status in ('Resolved', 'Closed') then 20.0
            else null
        end as active_work_time_hours,
        case 
            when ss.resolution_status in ('Resolved', 'Closed') then 4.0
            else null
        end as customer_wait_time_hours,
        case 
            when upper(ss.ticket_type) like '%CRITICAL%' then 1
            else 0
        end as escalation_count,
        0 as reassignment_count,
        0 as reopened_count,
        3 as agent_interactions_count,
        2 as customer_interactions_count,
        case 
            when upper(ss.ticket_type) like '%TECHNICAL%' then 2
            else 1
        end as knowledge_base_articles_used,
        case 
            when ss.resolution_status in ('Resolved', 'Closed') and 
                 case when ss.resolution_status in ('Resolved', 'Closed') then 24.0 else null end <= 4 then 5.0
            when ss.resolution_status in ('Resolved', 'Closed') and 
                 case when ss.resolution_status in ('Resolved', 'Closed') then 24.0 else null end <= 24 then 4.0
            when ss.resolution_status in ('Resolved', 'Closed') and 
                 case when ss.resolution_status in ('Resolved', 'Closed') then 24.0 else null end <= 72 then 3.0
            when ss.resolution_status in ('Resolved', 'Closed') then 2.0
            else null
        end as customer_satisfaction_score,
        case 
            when 3 <= 1 then true
            else false
        end as first_contact_resolution,
        case 
            when case when ss.resolution_status in ('Resolved', 'Closed') then 24.0 else null end <= 
                 case 
                     when upper(ss.ticket_type) like '%CRITICAL%' then 4.0
                     when upper(ss.ticket_type) like '%URGENT%' then 24.0
                     when upper(ss.ticket_type) like '%BILLING%' then 48.0
                     else 72.0
                 end then true
            else false
        end as sla_met,
        case 
            when case when ss.resolution_status in ('Resolved', 'Closed') then 24.0 else null end > 
                 case 
                     when upper(ss.ticket_type) like '%CRITICAL%' then 4.0
                     when upper(ss.ticket_type) like '%URGENT%' then 24.0
                     when upper(ss.ticket_type) like '%BILLING%' then 48.0
                     else 72.0
                 end then 
                 case when ss.resolution_status in ('Resolved', 'Closed') then 24.0 else null end - 
                 case 
                     when upper(ss.ticket_type) like '%CRITICAL%' then 4.0
                     when upper(ss.ticket_type) like '%URGENT%' then 24.0
                     when upper(ss.ticket_type) like '%BILLING%' then 48.0
                     else 72.0
                 end
            else 0
        end as sla_breach_hours,
        'Agent Resolution' as resolution_method,
        'User Error' as root_cause_category,
        case 
            when ss.ticket_type in ('Password Reset', 'Account Lockout', 'Basic Setup') then true
            else false
        end as preventable_issue,
        false as follow_up_required,
        50.0 as cost_to_resolve,
        current_date as load_date,
        current_date as update_date,
        ss.source_system
    from source_support ss
    left join {{ ref('go_dim_date') }} dd on ss.open_date = dd.date_value
    left join {{ ref('go_dim_user') }} du on ss.user_id = du.user_id
    left join {{ ref('go_dim_support_category') }} dsc on ss.ticket_type = dsc.support_category
)

select * from support_metrics_fact
