{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (audit_log_id, process_name, process_type, execution_start_timestamp, execution_status, source_table_name, target_table_name, process_trigger, executed_by, load_date, source_system) VALUES ('{{ dbt_utils.generate_surrogate_key(['GO_DIM_SUPPORT_CATEGORY', run_started_at]) }}', 'GO_DIM_SUPPORT_CATEGORY_LOAD', 'DBT_MODEL', CURRENT_TIMESTAMP(), 'RUNNING', 'SI_SUPPORT_TICKETS', 'GO_DIM_SUPPORT_CATEGORY', 'DBT_RUN', 'DBT_SYSTEM', CURRENT_DATE(), 'DBT_GOLD_PIPELINE')",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET execution_end_timestamp = CURRENT_TIMESTAMP(), execution_status = 'SUCCESS', records_processed = (SELECT COUNT(*) FROM {{ this }}), execution_duration_seconds = DATEDIFF('second', execution_start_timestamp, CURRENT_TIMESTAMP()) WHERE audit_log_id = '{{ dbt_utils.generate_surrogate_key(['GO_DIM_SUPPORT_CATEGORY', run_started_at]) }}'"
) }}

-- Support category dimension transformation from Silver layer
WITH support_source AS (
    SELECT DISTINCT
        ticket_type,
        source_system
    FROM {{ source('silver', 'si_support_tickets') }}
    WHERE validation_status = 'PASSED'
      AND ticket_type IS NOT NULL
),

support_category_transformed AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['ticket_type']) }} AS support_category_key,
        INITCAP(TRIM(ticket_type)) AS support_category,
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
    FROM support_source
)

SELECT * FROM support_category_transformed
