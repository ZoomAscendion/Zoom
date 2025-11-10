{{ config(
    materialized='table',
    cluster_by=['PRIORITY_LEVEL', 'LOAD_DATE'],
    tags=['dimension', 'support']
) }}

-- Support category dimension derived from support ticket types
-- Contains support classifications and SLA definitions

WITH source_ticket_types AS (
    SELECT DISTINCT 
        ticket_type
    FROM {{ source('silver', 'si_support_tickets') }}
    WHERE ticket_type IS NOT NULL 
        AND TRIM(ticket_type) != ''
        AND validation_status = {{ var('validation_status_filter') }}
        AND data_quality_score >= {{ var('data_quality_threshold') }}
),

support_categorization AS (
    SELECT 
        ticket_type AS support_category,
        
        -- Support subcategory classification
        CASE 
            WHEN UPPER(ticket_type) LIKE '%TECHNICAL%' OR UPPER(ticket_type) LIKE '%BUG%' THEN 'Technical'
            WHEN UPPER(ticket_type) LIKE '%BILLING%' OR UPPER(ticket_type) LIKE '%PAYMENT%' THEN 'Billing'
            WHEN UPPER(ticket_type) LIKE '%FEATURE%' OR UPPER(ticket_type) LIKE '%REQUEST%' THEN 'Feature Request'
            WHEN UPPER(ticket_type) LIKE '%ACCOUNT%' OR UPPER(ticket_type) LIKE '%ACCESS%' THEN 'Account'
            WHEN UPPER(ticket_type) LIKE '%TRAINING%' OR UPPER(ticket_type) LIKE '%HOW%' THEN 'Training'
            WHEN UPPER(ticket_type) LIKE '%INTEGRATION%' OR UPPER(ticket_type) LIKE '%API%' THEN 'Integration'
            ELSE 'General'
        END AS support_subcategory,
        
        -- Priority level mapping
        CASE 
            WHEN UPPER(ticket_type) LIKE '%CRITICAL%' OR UPPER(ticket_type) LIKE '%URGENT%' THEN 'Critical'
            WHEN UPPER(ticket_type) LIKE '%HIGH%' OR UPPER(ticket_type) LIKE '%IMPORTANT%' THEN 'High'
            WHEN UPPER(ticket_type) LIKE '%MEDIUM%' OR UPPER(ticket_type) LIKE '%NORMAL%' THEN 'Medium'
            WHEN UPPER(ticket_type) LIKE '%LOW%' OR UPPER(ticket_type) LIKE '%MINOR%' THEN 'Low'
            ELSE 'Medium'  -- Default priority
        END AS priority_level,
        
        -- Expected resolution hours based on priority
        CASE 
            WHEN UPPER(ticket_type) LIKE '%CRITICAL%' OR UPPER(ticket_type) LIKE '%URGENT%' THEN 4
            WHEN UPPER(ticket_type) LIKE '%HIGH%' OR UPPER(ticket_type) LIKE '%IMPORTANT%' THEN 24
            WHEN UPPER(ticket_type) LIKE '%MEDIUM%' OR UPPER(ticket_type) LIKE '%NORMAL%' THEN 72
            WHEN UPPER(ticket_type) LIKE '%LOW%' OR UPPER(ticket_type) LIKE '%MINOR%' THEN 168
            ELSE 72  -- Default 3 days
        END AS expected_resolution_hours,
        
        -- Escalation requirement
        CASE 
            WHEN UPPER(ticket_type) LIKE '%CRITICAL%' OR UPPER(ticket_type) LIKE '%URGENT%' THEN TRUE
            WHEN UPPER(ticket_type) LIKE '%HIGH%' OR UPPER(ticket_type) LIKE '%IMPORTANT%' THEN TRUE
            ELSE FALSE
        END AS requires_escalation,
        
        -- Self-service availability
        CASE 
            WHEN UPPER(ticket_type) LIKE '%TRAINING%' OR UPPER(ticket_type) LIKE '%HOW%' THEN TRUE
            WHEN UPPER(ticket_type) LIKE '%BILLING%' OR UPPER(ticket_type) LIKE '%ACCOUNT%' THEN TRUE
            WHEN UPPER(ticket_type) LIKE '%FEATURE%' THEN FALSE
            WHEN UPPER(ticket_type) LIKE '%CRITICAL%' OR UPPER(ticket_type) LIKE '%TECHNICAL%' THEN FALSE
            ELSE TRUE
        END AS self_service_available,
        
        -- Specialist requirement
        CASE 
            WHEN UPPER(ticket_type) LIKE '%INTEGRATION%' OR UPPER(ticket_type) LIKE '%API%' THEN TRUE
            WHEN UPPER(ticket_type) LIKE '%TECHNICAL%' OR UPPER(ticket_type) LIKE '%BUG%' THEN TRUE
            WHEN UPPER(ticket_type) LIKE '%CRITICAL%' THEN TRUE
            ELSE FALSE
        END AS specialist_required,
        
        -- Category complexity
        CASE 
            WHEN UPPER(ticket_type) LIKE '%INTEGRATION%' OR UPPER(ticket_type) LIKE '%API%' THEN 'High'
            WHEN UPPER(ticket_type) LIKE '%TECHNICAL%' OR UPPER(ticket_type) LIKE '%BUG%' THEN 'High'
            WHEN UPPER(ticket_type) LIKE '%FEATURE%' OR UPPER(ticket_type) LIKE '%BILLING%' THEN 'Medium'
            WHEN UPPER(ticket_type) LIKE '%TRAINING%' OR UPPER(ticket_type) LIKE '%ACCOUNT%' THEN 'Low'
            ELSE 'Medium'
        END AS category_complexity,
        
        -- Customer impact level
        CASE 
            WHEN UPPER(ticket_type) LIKE '%CRITICAL%' THEN 'High'
            WHEN UPPER(ticket_type) LIKE '%TECHNICAL%' OR UPPER(ticket_type) LIKE '%BUG%' THEN 'High'
            WHEN UPPER(ticket_type) LIKE '%BILLING%' OR UPPER(ticket_type) LIKE '%ACCESS%' THEN 'Medium'
            WHEN UPPER(ticket_type) LIKE '%FEATURE%' OR UPPER(ticket_type) LIKE '%TRAINING%' THEN 'Low'
            ELSE 'Medium'
        END AS customer_impact_level,
        
        -- Resolution method
        CASE 
            WHEN UPPER(ticket_type) LIKE '%TRAINING%' OR UPPER(ticket_type) LIKE '%HOW%' THEN 'Documentation'
            WHEN UPPER(ticket_type) LIKE '%BILLING%' OR UPPER(ticket_type) LIKE '%ACCOUNT%' THEN 'Administrative'
            WHEN UPPER(ticket_type) LIKE '%TECHNICAL%' OR UPPER(ticket_type) LIKE '%BUG%' THEN 'Technical Fix'
            WHEN UPPER(ticket_type) LIKE '%FEATURE%' THEN 'Product Enhancement'
            WHEN UPPER(ticket_type) LIKE '%INTEGRATION%' THEN 'Configuration'
            ELSE 'Support Assistance'
        END AS resolution_method,
        
        -- Knowledge base articles count (estimated)
        CASE 
            WHEN UPPER(ticket_type) LIKE '%TRAINING%' OR UPPER(ticket_type) LIKE '%HOW%' THEN 25
            WHEN UPPER(ticket_type) LIKE '%BILLING%' OR UPPER(ticket_type) LIKE '%ACCOUNT%' THEN 15
            WHEN UPPER(ticket_type) LIKE '%TECHNICAL%' THEN 20
            WHEN UPPER(ticket_type) LIKE '%INTEGRATION%' THEN 10
            WHEN UPPER(ticket_type) LIKE '%FEATURE%' THEN 5
            ELSE 8
        END AS knowledge_base_articles
        
    FROM source_ticket_types
),

-- Add standard support categories if not present in source data
standard_categories AS (
    SELECT 'Technical Issue' AS support_category, 'Technical' AS support_subcategory, 'High' AS priority_level, 24 AS expected_resolution_hours, TRUE AS requires_escalation, FALSE AS self_service_available, TRUE AS specialist_required, 'High' AS category_complexity, 'High' AS customer_impact_level, 'Technical Fix' AS resolution_method, 20 AS knowledge_base_articles
    UNION ALL
    SELECT 'Billing Question' AS support_category, 'Billing' AS support_subcategory, 'Medium' AS priority_level, 72 AS expected_resolution_hours, FALSE AS requires_escalation, TRUE AS self_service_available, FALSE AS specialist_required, 'Low' AS category_complexity, 'Medium' AS customer_impact_level, 'Administrative' AS resolution_method, 15 AS knowledge_base_articles
    UNION ALL
    SELECT 'Feature Request' AS support_category, 'Feature Request' AS support_subcategory, 'Low' AS priority_level, 168 AS expected_resolution_hours, FALSE AS requires_escalation, FALSE AS self_service_available, FALSE AS specialist_required, 'Medium' AS category_complexity, 'Low' AS customer_impact_level, 'Product Enhancement' AS resolution_method, 5 AS knowledge_base_articles
    UNION ALL
    SELECT 'Account Access' AS support_category, 'Account' AS support_subcategory, 'High' AS priority_level, 24 AS expected_resolution_hours, TRUE AS requires_escalation, TRUE AS self_service_available, FALSE AS specialist_required, 'Medium' AS category_complexity, 'Medium' AS customer_impact_level, 'Administrative' AS resolution_method, 12 AS knowledge_base_articles
    UNION ALL
    SELECT 'Training Request' AS support_category, 'Training' AS support_subcategory, 'Low' AS priority_level, 168 AS expected_resolution_hours, FALSE AS requires_escalation, TRUE AS self_service_available, FALSE AS specialist_required, 'Low' AS category_complexity, 'Low' AS customer_impact_level, 'Documentation' AS resolution_method, 25 AS knowledge_base_articles
    UNION ALL
    SELECT 'Integration Support' AS support_category, 'Integration' AS support_subcategory, 'Medium' AS priority_level, 72 AS expected_resolution_hours, FALSE AS requires_escalation, FALSE AS self_service_available, TRUE AS specialist_required, 'High' AS category_complexity, 'Medium' AS customer_impact_level, 'Configuration' AS resolution_method, 10 AS knowledge_base_articles
    UNION ALL
    SELECT 'General Inquiry' AS support_category, 'General' AS support_subcategory, 'Low' AS priority_level, 168 AS expected_resolution_hours, FALSE AS requires_escalation, TRUE AS self_service_available, FALSE AS specialist_required, 'Low' AS category_complexity, 'Low' AS customer_impact_level, 'Support Assistance' AS resolution_method, 8 AS knowledge_base_articles
),

all_categories AS (
    SELECT * FROM support_categorization
    UNION 
    SELECT * FROM standard_categories
),

final_dimension AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY support_category) AS support_category_id,
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
        
        -- Standard metadata columns
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        'SI_SUPPORT_TICKETS' AS source_system
        
    FROM all_categories
)

SELECT * FROM final_dimension
ORDER BY priority_level, support_category
