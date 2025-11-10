/*
  go_dim_support_category.sql
  Zoom Platform Analytics System - Support Category Dimension
  
  Author: Data Engineering Team
  Description: Support category dimension for standardizing support ticket classifications
  
  This model creates a comprehensive support category dimension with priority levels,
  resolution expectations, and service level definitions.
*/

{{ config(
    materialized='table',
    tags=['dimension', 'support_category'],
    cluster_by=['support_category', 'priority_level']
) }}

-- Extract unique support ticket types from source data
WITH source_tickets AS (
    SELECT DISTINCT
        UPPER(TRIM(COALESCE(ticket_type, 'GENERAL'))) AS ticket_type,
        UPPER(TRIM(COALESCE(resolution_status, 'UNKNOWN'))) AS resolution_status,
        COUNT(*) AS ticket_count,
        MIN(open_date) AS first_ticket_date,
        MAX(open_date) AS last_ticket_date,
        source_system
    FROM {{ source('silver', 'si_support_tickets') }}
    WHERE validation_status = 'PASSED'
        AND data_quality_score >= {{ var('min_data_quality_score') }}
    GROUP BY 
        UPPER(TRIM(COALESCE(ticket_type, 'GENERAL'))),
        UPPER(TRIM(COALESCE(resolution_status, 'UNKNOWN'))),
        source_system
),

-- Support category classification and attributes
support_categories AS (
    SELECT 
        ticket_type AS support_category,
        
        -- Support subcategory classification
        CASE 
            WHEN ticket_type LIKE '%TECHNICAL%' OR ticket_type LIKE '%BUG%' OR ticket_type LIKE '%ERROR%' THEN 'Technical Issues'
            WHEN ticket_type LIKE '%BILLING%' OR ticket_type LIKE '%PAYMENT%' OR ticket_type LIKE '%INVOICE%' THEN 'Billing & Payments'
            WHEN ticket_type LIKE '%FEATURE%' OR ticket_type LIKE '%REQUEST%' OR ticket_type LIKE '%ENHANCEMENT%' THEN 'Feature Requests'
            WHEN ticket_type LIKE '%ACCOUNT%' OR ticket_type LIKE '%LOGIN%' OR ticket_type LIKE '%ACCESS%' THEN 'Account Management'
            WHEN ticket_type LIKE '%TRAINING%' OR ticket_type LIKE '%HELP%' OR ticket_type LIKE '%HOW%' THEN 'Training & Support'
            WHEN ticket_type LIKE '%INTEGRATION%' OR ticket_type LIKE '%API%' OR ticket_type LIKE '%SETUP%' THEN 'Integration Support'
            WHEN ticket_type LIKE '%SECURITY%' OR ticket_type LIKE '%PRIVACY%' OR ticket_type LIKE '%COMPLIANCE%' THEN 'Security & Compliance'
            WHEN ticket_type LIKE '%PERFORMANCE%' OR ticket_type LIKE '%SLOW%' OR ticket_type LIKE '%LATENCY%' THEN 'Performance Issues'
            ELSE 'General Support'
        END AS support_subcategory,
        
        -- Priority level determination
        CASE 
            WHEN ticket_type LIKE '%CRITICAL%' OR ticket_type LIKE '%URGENT%' OR ticket_type LIKE '%EMERGENCY%' THEN 'Critical'
            WHEN ticket_type LIKE '%HIGH%' OR ticket_type LIKE '%IMPORTANT%' THEN 'High'
            WHEN ticket_type LIKE '%MEDIUM%' OR ticket_type LIKE '%NORMAL%' THEN 'Medium'
            WHEN ticket_type LIKE '%LOW%' OR ticket_type LIKE '%MINOR%' THEN 'Low'
            -- Default priority based on category
            WHEN ticket_type LIKE '%SECURITY%' OR ticket_type LIKE '%BILLING%' THEN 'High'
            WHEN ticket_type LIKE '%TECHNICAL%' OR ticket_type LIKE '%BUG%' THEN 'Medium'
            WHEN ticket_type LIKE '%FEATURE%' OR ticket_type LIKE '%TRAINING%' THEN 'Low'
            ELSE 'Medium'
        END AS priority_level,
        
        -- Expected resolution hours based on priority and category
        CASE 
            WHEN ticket_type LIKE '%CRITICAL%' OR ticket_type LIKE '%URGENT%' OR ticket_type LIKE '%EMERGENCY%' THEN 4
            WHEN ticket_type LIKE '%HIGH%' OR ticket_type LIKE '%SECURITY%' OR ticket_type LIKE '%BILLING%' THEN 24
            WHEN ticket_type LIKE '%MEDIUM%' OR ticket_type LIKE '%TECHNICAL%' THEN 72
            WHEN ticket_type LIKE '%LOW%' OR ticket_type LIKE '%FEATURE%' OR ticket_type LIKE '%TRAINING%' THEN 168
            ELSE 72
        END AS expected_resolution_hours,
        
        -- Escalation requirements
        CASE 
            WHEN ticket_type LIKE '%CRITICAL%' OR ticket_type LIKE '%URGENT%' OR ticket_type LIKE '%EMERGENCY%' THEN TRUE
            WHEN ticket_type LIKE '%SECURITY%' OR ticket_type LIKE '%COMPLIANCE%' THEN TRUE
            WHEN ticket_type LIKE '%HIGH%' THEN TRUE
            ELSE FALSE
        END AS requires_escalation,
        
        -- Self-service availability
        CASE 
            WHEN ticket_type LIKE '%TRAINING%' OR ticket_type LIKE '%HOW%' OR ticket_type LIKE '%HELP%' THEN TRUE
            WHEN ticket_type LIKE '%ACCOUNT%' OR ticket_type LIKE '%LOGIN%' THEN TRUE
            WHEN ticket_type LIKE '%FEATURE%' OR ticket_type LIKE '%REQUEST%' THEN TRUE
            WHEN ticket_type LIKE '%BILLING%' AND ticket_type NOT LIKE '%DISPUTE%' THEN TRUE
            ELSE FALSE
        END AS self_service_available,
        
        -- Specialist requirement
        CASE 
            WHEN ticket_type LIKE '%INTEGRATION%' OR ticket_type LIKE '%API%' THEN TRUE
            WHEN ticket_type LIKE '%SECURITY%' OR ticket_type LIKE '%COMPLIANCE%' THEN TRUE
            WHEN ticket_type LIKE '%PERFORMANCE%' OR ticket_type LIKE '%TECHNICAL%' THEN TRUE
            WHEN ticket_type LIKE '%CRITICAL%' OR ticket_type LIKE '%URGENT%' THEN TRUE
            ELSE FALSE
        END AS specialist_required,
        
        -- Category complexity
        CASE 
            WHEN ticket_type LIKE '%INTEGRATION%' OR ticket_type LIKE '%API%' OR ticket_type LIKE '%SECURITY%' THEN 'Very High'
            WHEN ticket_type LIKE '%TECHNICAL%' OR ticket_type LIKE '%PERFORMANCE%' THEN 'High'
            WHEN ticket_type LIKE '%BILLING%' OR ticket_type LIKE '%ACCOUNT%' THEN 'Medium'
            WHEN ticket_type LIKE '%TRAINING%' OR ticket_type LIKE '%FEATURE%' THEN 'Low'
            ELSE 'Medium'
        END AS category_complexity,
        
        -- Customer impact level
        CASE 
            WHEN ticket_type LIKE '%CRITICAL%' OR ticket_type LIKE '%URGENT%' OR ticket_type LIKE '%EMERGENCY%' THEN 'Critical'
            WHEN ticket_type LIKE '%SECURITY%' OR ticket_type LIKE '%BILLING%' THEN 'High'
            WHEN ticket_type LIKE '%TECHNICAL%' OR ticket_type LIKE '%PERFORMANCE%' THEN 'Medium'
            WHEN ticket_type LIKE '%FEATURE%' OR ticket_type LIKE '%TRAINING%' THEN 'Low'
            ELSE 'Medium'
        END AS customer_impact_level,
        
        -- Resolution method
        CASE 
            WHEN ticket_type LIKE '%TRAINING%' OR ticket_type LIKE '%HOW%' THEN 'Documentation'
            WHEN ticket_type LIKE '%TECHNICAL%' OR ticket_type LIKE '%BUG%' THEN 'Technical Fix'
            WHEN ticket_type LIKE '%FEATURE%' OR ticket_type LIKE '%REQUEST%' THEN 'Product Enhancement'
            WHEN ticket_type LIKE '%BILLING%' OR ticket_type LIKE '%ACCOUNT%' THEN 'Administrative'
            WHEN ticket_type LIKE '%INTEGRATION%' OR ticket_type LIKE '%API%' THEN 'Configuration'
            ELSE 'Standard Support'
        END AS resolution_method,
        
        -- Knowledge base articles count (estimated)
        CASE 
            WHEN ticket_type LIKE '%TRAINING%' OR ticket_type LIKE '%HOW%' THEN 50
            WHEN ticket_type LIKE '%TECHNICAL%' OR ticket_type LIKE '%BUG%' THEN 25
            WHEN ticket_type LIKE '%ACCOUNT%' OR ticket_type LIKE '%LOGIN%' THEN 15
            WHEN ticket_type LIKE '%BILLING%' THEN 10
            WHEN ticket_type LIKE '%FEATURE%' THEN 5
            ELSE 3
        END AS knowledge_base_articles,
        
        ticket_count,
        first_ticket_date,
        last_ticket_date,
        source_system
        
    FROM source_tickets
),

-- Get unique support categories
unique_categories AS (
    SELECT DISTINCT
        support_category,
        support_subcategory,
        priority_level,
        expected_resolution_hours,
        requires_escalation,
        self_service_available,
        specialist_required,
        category_complexity,
        customer_impact_level,
        resolution_method,
        knowledge_base_articles,
        SUM(ticket_count) AS total_tickets,
        MIN(first_ticket_date) AS first_occurrence,
        MAX(last_ticket_date) AS last_occurrence,
        source_system
    FROM support_categories
    GROUP BY 
        support_category, support_subcategory, priority_level,
        expected_resolution_hours, requires_escalation, self_service_available,
        specialist_required, category_complexity, customer_impact_level,
        resolution_method, knowledge_base_articles, source_system
),

-- Final dimension with surrogate key
final_dimension AS (
    SELECT 
        -- Generate surrogate key
        ROW_NUMBER() OVER (ORDER BY support_category, support_subcategory) AS support_category_id,
        
        support_category,
        support_subcategory,
        priority_level,
        expected_resolution_hours,
        requires_escalation,
        self_service_available,
        specialist_required,
        category_complexity,
        customer_impact_level,
        resolution_method,
        knowledge_base_articles,
        
        -- Metadata columns
        CURRENT_DATE AS load_date,
        CURRENT_DATE AS update_date,
        source_system
        
    FROM unique_categories
)

SELECT 
    support_category_id,
    support_category,
    support_subcategory,
    priority_level,
    expected_resolution_hours,
    requires_escalation,
    self_service_available,
    specialist_required,
    category_complexity,
    customer_impact_level,
    resolution_method,
    knowledge_base_articles,
    load_date,
    update_date,
    source_system
FROM final_dimension
ORDER BY support_category_id