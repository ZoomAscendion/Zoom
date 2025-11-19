{{ config(
    materialized='table',
    cluster_by=['date_id', 'support_category_id']
) }}

with source_support as (
    select *
    from {{ source('silver', 'si_support_tickets') }}
    where validation_status = 'PASSED'
),

fact_support_metrics as (
    select
        row_number() over (order by sst.ticket_id) as support_metrics_id,
        
        -- Foreign keys to dimensions
        dd.date_id,
        dsc.support_category_id,
        du.user_dim_id,
        
        -- Ticket identifiers
        sst.ticket_id,
        sst.open_date as ticket_created_date,
        sst.open_date::timestamp_ntz as ticket_created_timestamp,
        
        -- Calculated close date (placeholder logic)
        case 
            when upper(sst.resolution_status) in ('RESOLVED', 'CLOSED') then sst.open_date + interval '1 day'
            else null
        end as ticket_closed_date,
        
        case 
            when upper(sst.resolution_status) in ('RESOLVED', 'CLOSED') then (sst.open_date + interval '1 day')::timestamp_ntz
            else null
        end as ticket_closed_timestamp,
        
        -- Response and resolution timestamps (placeholders)
        sst.open_date::timestamp_ntz + interval '2 hours' as first_response_timestamp,
        case 
            when upper(sst.resolution_status) in ('RESOLVED', 'CLOSED') then (sst.open_date + interval '1 day')::timestamp_ntz
            else null
        end as resolution_timestamp,
        
        -- Ticket attributes
        sst.ticket_type as ticket_category,
        case 
            when upper(sst.ticket_type) like '%TECHNICAL%' then 'Technical Issue'
            when upper(sst.ticket_type) like '%BILLING%' then 'Billing Inquiry'
            else 'General Support'
        end as ticket_subcategory,
        
        case 
            when upper(sst.ticket_type) like '%CRITICAL%' then 'Critical'
            when upper(sst.ticket_type) like '%URGENT%' then 'High'
            else 'Medium'
        end as priority_level,
        
        'Medium' as severity_level, -- Placeholder
        sst.resolution_status,
        
        -- Time metrics
        2.0 as first_response_time_hours, -- Placeholder
        case 
            when upper(sst.resolution_status) in ('RESOLVED', 'CLOSED') then 24.0
            else null
        end as resolution_time_hours,
        
        case 
            when upper(sst.resolution_status) in ('RESOLVED', 'CLOSED') then 20.0
            else null
        end as active_work_time_hours,
        
        case 
            when upper(sst.resolution_status) in ('RESOLVED', 'CLOSED') then 4.0
            else null
        end as customer_wait_time_hours,
        
        -- Process metrics (placeholders)
        0 as escalation_count,
        0 as reassignment_count,
        0 as reopened_count,
        3 as agent_interactions_count,
        2 as customer_interactions_count,
        1 as knowledge_base_articles_used,
        
        -- Quality metrics
        4.0 as customer_satisfaction_score, -- Placeholder
        false as first_contact_resolution,
        
        -- SLA metrics
        case 
            when upper(sst.resolution_status) in ('RESOLVED', 'CLOSED') and dsc.sla_target_hours >= 24.0 then true
            else false
        end as sla_met,
        
        case 
            when upper(sst.resolution_status) in ('RESOLVED', 'CLOSED') and 24.0 > dsc.sla_target_hours then 24.0 - dsc.sla_target_hours
            else 0
        end as sla_breach_hours,
        
        'Agent Resolution' as resolution_method, -- Placeholder
        'User Error' as root_cause_category, -- Placeholder
        true as preventable_issue, -- Placeholder
        false as follow_up_required, -- Placeholder
        25.00 as cost_to_resolve, -- Placeholder
        
        -- Metadata
        current_date as load_date,
        current_date as update_date,
        sst.source_system
        
    from source_support sst
    join {{ ref('dim_date') }} dd on sst.open_date = dd.date_value
    join {{ ref('dim_user') }} du on sst.user_id = du.user_id and du.is_current_record = true
    join {{ ref('dim_support_category') }} dsc on sst.ticket_type = dsc.support_category
)

select * from fact_support_metrics
