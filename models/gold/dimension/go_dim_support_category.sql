{{ config(
    materialized='table'
) }}

-- Support category dimension with SLA and resolution characteristics
-- Derived from distinct ticket types in Silver layer support tickets

WITH source_support AS (
    SELECT DISTINCT
        ticket_type,
        source_system
    FROM {{ source('silver', 'si_support_tickets') }}
    WHERE validation_status = 'PASSED'
      AND ticket_type IS NOT NULL
      AND TRIM(ticket_type) != ''
),

transformed_support_categories AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY ticket_type) AS support_category_id,
        INITCAP(TRIM(ticket_type)) AS support_category,
        CASE 
            WHEN UPPER(ticket_type) LIKE '%TECHNICAL%' OR UPPER(ticket_type) LIKE '%BUG%' THEN 'Technical Issue'
            WHEN UPPER(ticket_type) LIKE '%BILLING%' OR UPPER(ticket_type) LIKE '%PAYMENT%' THEN 'Billing Inquiry'
            WHEN UPPER(ticket_type) LIKE '%FEATURE%' OR UPPER(ticket_type) LIKE '%REQUEST%' THEN 'Feature Request'
            WHEN UPPER(ticket_type) LIKE '%ACCOUNT%' OR UPPER(ticket_type) LIKE '%LOGIN%' THEN 'Account Support'
            WHEN UPPER(ticket_type) LIKE '%TRAINING%' OR UPPER(ticket_type) LIKE '%HOW%TO%' THEN 'Training Support'
            ELSE 'General Support'
        END AS support_subcategory,
        CASE 
            WHEN UPPER(ticket_type) LIKE '%CRITICAL%' OR UPPER(ticket_type) LIKE '%URGENT%' THEN 'Critical'
            WHEN UPPER(ticket_type) LIKE '%HIGH%' OR UPPER(ticket_type) LIKE '%IMPORTANT%' THEN 'High'
            WHEN UPPER(ticket_type) LIKE '%BILLING%' OR UPPER(ticket_type) LIKE '%ACCOUNT%' THEN 'Medium'
            WHEN UPPER(ticket_type) LIKE '%FEATURE%' OR UPPER(ticket_type) LIKE '%TRAINING%' THEN 'Low'
            ELSE 'Medium'
        END AS priority_level,
        CASE 
            WHEN UPPER(ticket_type) LIKE '%CRITICAL%' OR UPPER(ticket_type) LIKE '%URGENT%' THEN 4.0
            WHEN UPPER(ticket_type) LIKE '%HIGH%' OR UPPER(ticket_type) LIKE '%IMPORTANT%' THEN 8.0
            WHEN UPPER(ticket_type) LIKE '%TECHNICAL%' OR UPPER(ticket_type) LIKE '%BUG%' THEN 24.0
            WHEN UPPER(ticket_type) LIKE '%BILLING%' OR UPPER(ticket_type) LIKE '%ACCOUNT%' THEN 48.0
            WHEN UPPER(ticket_type) LIKE '%FEATURE%' OR UPPER(ticket_type) LIKE '%TRAINING%' THEN 72.0
            ELSE 48.0
        END AS expected_resolution_time_hours,
        CASE 
            WHEN UPPER(ticket_type) LIKE '%CRITICAL%' OR UPPER(ticket_type) LIKE '%URGENT%' THEN TRUE
            ELSE FALSE
        END AS requires_escalation,
        CASE 
            WHEN UPPER(ticket_type) LIKE '%BILLING%' OR UPPER(ticket_type) LIKE '%FEATURE%' OR 
                 UPPER(ticket_type) LIKE '%TRAINING%' OR UPPER(ticket_type) LIKE '%HOW%TO%' THEN TRUE
            ELSE FALSE
        END AS self_service_available,
        CASE 
            WHEN UPPER(ticket_type) LIKE '%TECHNICAL%' OR UPPER(ticket_type) LIKE '%BUG%' THEN 15
            WHEN UPPER(ticket_type) LIKE '%BILLING%' OR UPPER(ticket_type) LIKE '%ACCOUNT%' THEN 10
            WHEN UPPER(ticket_type) LIKE '%TRAINING%' OR UPPER(ticket_type) LIKE '%HOW%TO%' THEN 20
            ELSE 5
        END AS knowledge_base_articles,
        'Standard resolution steps for ' || INITCAP(TRIM(ticket_type)) AS common_resolution_steps,
        CASE 
            WHEN UPPER(ticket_type) LIKE '%CRITICAL%' OR UPPER(ticket_type) LIKE '%URGENT%' THEN 'High'
            WHEN UPPER(ticket_type) LIKE '%TECHNICAL%' OR UPPER(ticket_type) LIKE '%BUG%' THEN 'Medium'
            ELSE 'Low'
        END AS customer_impact_level,
        CASE 
            WHEN UPPER(ticket_type) LIKE '%TECHNICAL%' OR UPPER(ticket_type) LIKE '%BUG%' THEN 'Technical Support'
            WHEN UPPER(ticket_type) LIKE '%BILLING%' OR UPPER(ticket_type) LIKE '%PAYMENT%' THEN 'Billing Department'
            WHEN UPPER(ticket_type) LIKE '%TRAINING%' OR UPPER(ticket_type) LIKE '%HOW%TO%' THEN 'Training Team'
            ELSE 'Customer Success'
        END AS department_responsible,
        CASE 
            WHEN UPPER(ticket_type) LIKE '%CRITICAL%' OR UPPER(ticket_type) LIKE '%URGENT%' THEN 4.0
            WHEN UPPER(ticket_type) LIKE '%HIGH%' OR UPPER(ticket_type) LIKE '%IMPORTANT%' THEN 8.0
            WHEN UPPER(ticket_type) LIKE '%TECHNICAL%' OR UPPER(ticket_type) LIKE '%BUG%' THEN 24.0
            WHEN UPPER(ticket_type) LIKE '%BILLING%' OR UPPER(ticket_type) LIKE '%ACCOUNT%' THEN 48.0
            ELSE 72.0
        END AS sla_target_hours,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        source_system
    FROM source_support
)

SELECT * FROM transformed_support_categories
