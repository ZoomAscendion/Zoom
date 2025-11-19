{{ config(
    materialized='table',
    tags=['dimension', 'gold'],
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} SELECT {{ dbt_utils.generate_surrogate_key(['\"GO_DIM_SUPPORT_CATEGORY\"', 'CURRENT_TIMESTAMP()']) }} AS audit_log_id, 'GO_DIM_SUPPORT_CATEGORY' AS process_name, 'DIMENSION_LOAD' AS process_type, CURRENT_TIMESTAMP() AS execution_start_timestamp, NULL AS execution_end_timestamp, NULL AS execution_duration_seconds, 'RUNNING' AS execution_status, 'SI_SUPPORT_TICKETS' AS source_table_name, 'GO_DIM_SUPPORT_CATEGORY' AS target_table_name, 0 AS records_read, 0 AS records_processed, 0 AS records_inserted, 0 AS records_updated, 0 AS records_failed, 100.0 AS data_quality_score, 0 AS error_count, 0 AS warning_count, 'DBT_RUN' AS process_trigger, 'DBT_SYSTEM' AS executed_by, 'DBT_SERVER' AS server_name, '1.0.0' AS process_version, PARSE_JSON('{}') AS configuration_parameters, PARSE_JSON('{}') AS performance_metrics, CURRENT_DATE() AS load_date, CURRENT_DATE() AS update_date, 'DBT_GOLD_PIPELINE' AS source_system",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET execution_end_timestamp = CURRENT_TIMESTAMP(), execution_status = 'SUCCESS', records_processed = (SELECT COUNT(*) FROM {{ this }}), execution_duration_seconds = DATEDIFF('second', execution_start_timestamp, CURRENT_TIMESTAMP()) WHERE process_name = 'GO_DIM_SUPPORT_CATEGORY' AND execution_status = 'RUNNING'"
) }}

WITH source_support AS (
    SELECT DISTINCT
        TICKET_TYPE,
        SOURCE_SYSTEM
    FROM {{ source('silver', 'si_support_tickets') }}
    WHERE VALIDATION_STATUS = 'PASSED'
      AND TICKET_TYPE IS NOT NULL
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY TICKET_TYPE) AS support_category_id,
    INITCAP(TRIM(TICKET_TYPE)) AS support_category,
    CASE 
        WHEN UPPER(TICKET_TYPE) LIKE '%TECHNICAL%' THEN 'Technical Issue'
        WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 'Billing Inquiry'
        WHEN UPPER(TICKET_TYPE) LIKE '%FEATURE%' THEN 'Feature Request'
        ELSE 'General Support'
    END AS support_subcategory,
    CASE 
        WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN 'Critical'
        WHEN UPPER(TICKET_TYPE) LIKE '%URGENT%' THEN 'High'
        WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 'Medium'
        ELSE 'Low'
    END AS priority_level,
    CASE 
        WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN 4.0
        WHEN UPPER(TICKET_TYPE) LIKE '%URGENT%' THEN 24.0
        WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 48.0
        ELSE 72.0
    END AS expected_resolution_time_hours,
    CASE 
        WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN TRUE
        ELSE FALSE
    END AS requires_escalation,
    CASE 
        WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' OR UPPER(TICKET_TYPE) LIKE '%FEATURE%' THEN TRUE
        ELSE FALSE
    END AS self_service_available,
    CASE 
        WHEN UPPER(TICKET_TYPE) LIKE '%TECHNICAL%' THEN 15
        WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 10
        ELSE 5
    END AS knowledge_base_articles,
    'Standard resolution steps for ' || TICKET_TYPE AS common_resolution_steps,
    CASE 
        WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN 'High'
        WHEN UPPER(TICKET_TYPE) LIKE '%TECHNICAL%' THEN 'Medium'
        ELSE 'Low'
    END AS customer_impact_level,
    CASE 
        WHEN UPPER(TICKET_TYPE) LIKE '%TECHNICAL%' THEN 'Technical Support'
        WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 'Billing Department'
        ELSE 'Customer Success'
    END AS department_responsible,
    CASE 
        WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN 4.0
        WHEN UPPER(TICKET_TYPE) LIKE '%URGENT%' THEN 24.0
        WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 48.0
        ELSE 72.0
    END AS sla_target_hours,
    CURRENT_DATE() AS load_date,
    CURRENT_DATE() AS update_date,
    COALESCE(SOURCE_SYSTEM, 'UNKNOWN') AS source_system
FROM source_support
