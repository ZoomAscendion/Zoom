{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (process_name, source_table, target_table, process_status, start_time, load_date, source_system) VALUES ('go_dim_support_category', 'SI_SUPPORT_TICKETS', 'go_dim_support_category', 'STARTED', CURRENT_TIMESTAMP(), CURRENT_DATE(), 'DBT_GOLD_PIPELINE')",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET process_status = 'COMPLETED', end_time = CURRENT_TIMESTAMP() WHERE target_table = 'go_dim_support_category' AND process_status = 'STARTED'"
) }}

-- Support category dimension
WITH source_support AS (
    SELECT DISTINCT
        COALESCE(TRIM(ticket_type), 'General Support') AS ticket_type,
        source_system
    FROM {{ source('silver', 'si_support_tickets') }}
    WHERE ticket_type IS NOT NULL
      AND TRIM(ticket_type) != ''
),

transformed_support_categories AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY ticket_type) AS support_category_id,
        INITCAP(ticket_type) AS support_category,
        CASE 
            WHEN UPPER(ticket_type) LIKE '%TECHNICAL%' THEN 'Technical Issue'
            WHEN UPPER(ticket_type) LIKE '%BILLING%' THEN 'Billing Inquiry'
            WHEN UPPER(ticket_type) LIKE '%FEATURE%' THEN 'Feature Request'
            ELSE 'General Support'
        END AS support_subcategory,
        CASE 
            WHEN UPPER(ticket_type) LIKE '%CRITICAL%' THEN 'Critical'
            WHEN UPPER(ticket_type) LIKE '%URGENT%' THEN 'High'
            WHEN UPPER(ticket_type) LIKE '%BILLING%' THEN 'Medium'
            ELSE 'Low'
        END AS priority_level,
        CASE 
            WHEN UPPER(ticket_type) LIKE '%CRITICAL%' THEN 4.0
            WHEN UPPER(ticket_type) LIKE '%URGENT%' THEN 24.0
            WHEN UPPER(ticket_type) LIKE '%BILLING%' THEN 48.0
            ELSE 72.0
        END AS expected_resolution_time_hours,
        CASE 
            WHEN UPPER(ticket_type) LIKE '%CRITICAL%' THEN TRUE
            ELSE FALSE
        END AS requires_escalation,
        CASE 
            WHEN UPPER(ticket_type) LIKE '%BILLING%' OR UPPER(ticket_type) LIKE '%FEATURE%' THEN TRUE
            ELSE FALSE
        END AS self_service_available,
        CASE 
            WHEN UPPER(ticket_type) LIKE '%TECHNICAL%' THEN 15
            WHEN UPPER(ticket_type) LIKE '%BILLING%' THEN 10
            ELSE 5
        END AS knowledge_base_articles,
        'Standard resolution steps for ' || ticket_type AS common_resolution_steps,
        CASE 
            WHEN UPPER(ticket_type) LIKE '%CRITICAL%' THEN 'High'
            WHEN UPPER(ticket_type) LIKE '%TECHNICAL%' THEN 'Medium'
            ELSE 'Low'
        END AS customer_impact_level,
        CASE 
            WHEN UPPER(ticket_type) LIKE '%TECHNICAL%' THEN 'Technical Support'
            WHEN UPPER(ticket_type) LIKE '%BILLING%' THEN 'Billing Department'
            ELSE 'Customer Success'
        END AS department_responsible,
        CASE 
            WHEN UPPER(ticket_type) LIKE '%CRITICAL%' THEN 4.0
            WHEN UPPER(ticket_type) LIKE '%URGENT%' THEN 24.0
            WHEN UPPER(ticket_type) LIKE '%BILLING%' THEN 48.0
            ELSE 72.0
        END AS sla_target_hours,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        source_system
    FROM source_support
)

SELECT * FROM transformed_support_categories
