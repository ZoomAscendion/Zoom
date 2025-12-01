{{ config(
    materialized='table',
    unique_key='support_metrics_id'
) }}

with source_support as (
    select *
    from {{ source('silver', 'si_support_tickets') }}
    where validation_status = 'PASSED'
),

support_metrics_fact as (
    select 
        row_number() over (order by sst.ticket_id) as support_metrics_id,
        dd.date_id,
        coalesce(dsc.support_category_id, 1) as support_category_id,
        coalesce(du.user_dim_id, 1) as user_dim_id,
        sst.ticket_id,
        sst.open_date as ticket_created_date,
        sst.open_date::timestamp_ntz as ticket_created_timestamp,
        case 
            when sst.resolution_status in ('Resolved', 'Closed') 
            then sst.open_date + interval '1 day' -- Placeholder for actual close date
            else null
        end as ticket_closed_date,
        case 
            when sst.resolution_status in ('Resolved', 'Closed') 
            then (sst.open_date + interval '1 day')::timestamp_ntz
            else null
        end as ticket_closed_timestamp,
        (sst.open_date + interval '2 hours')::timestamp_ntz as first_response_timestamp, -- Placeholder
        case 
            when sst.resolution_status in ('Resolved', 'Closed') 
            then (sst.open_date + interval '1 day')::timestamp_ntz
            else null
        end as resolution_timestamp,
        sst.ticket_type as ticket_category,
        case 
            when upper(sst.ticket_type) like '%TECHNICAL%' then 'Technical Issue'
            when upper(sst.ticket_type) like '%BILLING%' then 'Billing Inquiry'
            when upper(sst.ticket_type) like '%FEATURE%' then 'Feature Request'
            else 'General Support'
        end as ticket_subcategory,
        coalesce(dsc.priority_level, 'Medium') as priority_level,
        case 
            when upper(sst.ticket_type) like '%CRITICAL%' then 'Critical'
            when upper(sst.ticket_type) like '%URGENT%' then 'High'
            else 'Medium'
        end as severity_level,
        sst.resolution_status,
        2.0 as first_response_time_hours, -- Placeholder
        case 
            when sst.resolution_status in ('Resolved', 'Closed')
            then 24.0 -- Placeholder for actual resolution time
            else null
        end as resolution_time_hours,
        case 
            when sst.resolution_status in ('Resolved', 'Closed')
            then 20.0 -- Placeholder for actual work time
            else null
        end as active_work_time_hours,
        case 
            when sst.resolution_status in ('Resolved', 'Closed')
            then 4.0 -- Placeholder for customer wait time
            else null
        end as customer_wait_time_hours,
        0 as escalation_count, -- Default value
        0 as reassignment_count, -- Default value
        0 as reopened_count, -- Default value
        3 as agent_interactions_count, -- Default value
        2 as customer_interactions_count, -- Default value
        1 as knowledge_base_articles_used, -- Default value
        case 
            when sst.resolution_status in ('Resolved', 'Closed') then 4.0
            else null
        end as customer_satisfaction_score,
        case 
            when sst.resolution_status in ('Resolved', 'Closed') then true
            else false
        end as first_contact_resolution,
        case 
            when sst.resolution_status in ('Resolved', 'Closed') 
                 and coalesce(dsc.sla_target_hours, 72) >= 24.0 then true
            else false
        end as sla_met,
        case 
            when sst.resolution_status in ('Resolved', 'Closed') 
                 and 24.0 > coalesce(dsc.sla_target_hours, 72) 
            then 24.0 - coalesce(dsc.sla_target_hours, 72)
            else 0
        end as sla_breach_hours,
        'Standard Resolution' as resolution_method, -- Default value
        case 
            when upper(sst.ticket_type) like '%TECHNICAL%' then 'Technical'
            when upper(sst.ticket_type) like '%BILLING%' then 'Process'
            else 'User Error'
        end as root_cause_category,
        case 
            when sst.ticket_type in ('Password Reset', 'Account Lockout', 'Basic Setup') then true
            else false
        end as preventable_issue,
        false as follow_up_required, -- Default value
        50.0 as cost_to_resolve, -- Default value
        current_date as load_date,
        current_date as update_date,
        sst.source_system
    from source_support sst
    left join {{ ref('dim_date') }} dd on sst.open_date = dd.date_id
    left join {{ ref('dim_user') }} du on sst.user_id = du.user_id and du.is_current_record = true
    left join {{ ref('dim_support_category') }} dsc on sst.ticket_type = dsc.support_category
)

select * from support_metrics_fact
