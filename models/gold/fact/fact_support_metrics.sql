{{ config(
    materialized='table',
    cluster_by=['date_id', 'support_category_id']
) }}

-- Create sample support metrics fact data
with sample_support_metrics as (
    select
        1 as support_metrics_id,
        
        -- Foreign keys to dimensions
        (select date_id from {{ ref('dim_date') }} where date_value = current_date - 2 limit 1) as date_id,
        1 as support_category_id,
        1 as user_dim_id,
        
        -- Ticket identifiers
        'TICK001' as ticket_id,
        current_date - 2 as ticket_created_date,
        (current_timestamp - interval '2 days') as ticket_created_timestamp,
        
        -- Calculated close date
        current_date - 1 as ticket_closed_date,
        (current_timestamp - interval '1 day') as ticket_closed_timestamp,
        
        -- Response and resolution timestamps
        (current_timestamp - interval '2 days' + interval '2 hours') as first_response_timestamp,
        (current_timestamp - interval '1 day') as resolution_timestamp,
        
        -- Ticket attributes
        'Technical Issue' as ticket_category,
        'Technical Issue' as ticket_subcategory,
        'High' as priority_level,
        'Medium' as severity_level,
        'Resolved' as resolution_status,
        
        -- Time metrics
        2.0 as first_response_time_hours,
        22.0 as resolution_time_hours,
        18.0 as active_work_time_hours,
        4.0 as customer_wait_time_hours,
        
        -- Process metrics
        0 as escalation_count,
        0 as reassignment_count,
        0 as reopened_count,
        3 as agent_interactions_count,
        2 as customer_interactions_count,
        2 as knowledge_base_articles_used,
        
        -- Quality metrics
        4.5 as customer_satisfaction_score,
        false as first_contact_resolution,
        
        -- SLA metrics
        true as sla_met,
        0.0 as sla_breach_hours,
        
        'Agent Resolution' as resolution_method,
        'Configuration Error' as root_cause_category,
        true as preventable_issue,
        false as follow_up_required,
        45.00 as cost_to_resolve,
        
        -- Metadata
        current_date as load_date,
        current_date as update_date,
        'SAMPLE_DATA' as source_system
    
    union all
    
    select
        2 as support_metrics_id,
        
        -- Foreign keys to dimensions
        (select date_id from {{ ref('dim_date') }} where date_value = current_date - 5 limit 1) as date_id,
        2 as support_category_id,
        2 as user_dim_id,
        
        -- Ticket identifiers
        'TICK002' as ticket_id,
        current_date - 5 as ticket_created_date,
        (current_timestamp - interval '5 days') as ticket_created_timestamp,
        
        -- Calculated close date
        current_date - 3 as ticket_closed_date,
        (current_timestamp - interval '3 days') as ticket_closed_timestamp,
        
        -- Response and resolution timestamps
        (current_timestamp - interval '5 days' + interval '4 hours') as first_response_timestamp,
        (current_timestamp - interval '3 days') as resolution_timestamp,
        
        -- Ticket attributes
        'Billing Inquiry' as ticket_category,
        'Billing Inquiry' as ticket_subcategory,
        'Medium' as priority_level,
        'Low' as severity_level,
        'Resolved' as resolution_status,
        
        -- Time metrics
        4.0 as first_response_time_hours,
        44.0 as resolution_time_hours,
        36.0 as active_work_time_hours,
        8.0 as customer_wait_time_hours,
        
        -- Process metrics
        0 as escalation_count,
        1 as reassignment_count,
        0 as reopened_count,
        2 as agent_interactions_count,
        1 as customer_interactions_count,
        1 as knowledge_base_articles_used,
        
        -- Quality metrics
        4.0 as customer_satisfaction_score,
        false as first_contact_resolution,
        
        -- SLA metrics
        true as sla_met,
        0.0 as sla_breach_hours,
        
        'Self Service' as resolution_method,
        'User Error' as root_cause_category,
        false as preventable_issue,
        false as follow_up_required,
        25.00 as cost_to_resolve,
        
        -- Metadata
        current_date as load_date,
        current_date as update_date,
        'SAMPLE_DATA' as source_system
)

select * from sample_support_metrics
