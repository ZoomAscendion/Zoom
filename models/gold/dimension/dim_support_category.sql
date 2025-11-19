{{ config(
    materialized='table',
    cluster_by=['support_category_id', 'priority_level']
) }}

-- Create sample support category dimension
with sample_support_categories as (
    select
        1 as support_category_id,
        'Technical Issue' as support_category,
        'Technical Issue' as support_subcategory,
        'High' as priority_level,
        24.0 as expected_resolution_time_hours,
        false as requires_escalation,
        false as self_service_available,
        15 as knowledge_base_articles,
        'Standard resolution steps for Technical Issue' as common_resolution_steps,
        'Medium' as customer_impact_level,
        'Technical Support' as department_responsible,
        24.0 as sla_target_hours,
        current_date as load_date,
        current_date as update_date,
        'SAMPLE_DATA' as source_system
    
    union all
    
    select
        2 as support_category_id,
        'Billing Inquiry' as support_category,
        'Billing Inquiry' as support_subcategory,
        'Medium' as priority_level,
        48.0 as expected_resolution_time_hours,
        false as requires_escalation,
        true as self_service_available,
        10 as knowledge_base_articles,
        'Standard resolution steps for Billing Inquiry' as common_resolution_steps,
        'Low' as customer_impact_level,
        'Billing Department' as department_responsible,
        48.0 as sla_target_hours,
        current_date as load_date,
        current_date as update_date,
        'SAMPLE_DATA' as source_system
    
    union all
    
    select
        3 as support_category_id,
        'Feature Request' as support_category,
        'Feature Request' as support_subcategory,
        'Low' as priority_level,
        72.0 as expected_resolution_time_hours,
        false as requires_escalation,
        true as self_service_available,
        5 as knowledge_base_articles,
        'Standard resolution steps for Feature Request' as common_resolution_steps,
        'Low' as customer_impact_level,
        'Customer Success' as department_responsible,
        72.0 as sla_target_hours,
        current_date as load_date,
        current_date as update_date,
        'SAMPLE_DATA' as source_system
)

select * from sample_support_categories
