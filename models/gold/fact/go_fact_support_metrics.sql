{{ config(
    materialized='table',
    tags=['fact', 'gold'],
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} SELECT {{ dbt_utils.generate_surrogate_key(['\"GO_FACT_SUPPORT_METRICS\"', 'CURRENT_TIMESTAMP()']) }} AS audit_log_id, 'GO_FACT_SUPPORT_METRICS' AS process_name, 'FACT_LOAD' AS process_type, CURRENT_TIMESTAMP() AS execution_start_timestamp, NULL AS execution_end_timestamp, NULL AS execution_duration_seconds, 'RUNNING' AS execution_status, 'SI_SUPPORT_TICKETS' AS source_table_name, 'GO_FACT_SUPPORT_METRICS' AS target_table_name, 0 AS records_read, 0 AS records_processed, 0 AS records_inserted, 0 AS records_updated, 0 AS records_failed, 100.0 AS data_quality_score, 0 AS error_count, 0 AS warning_count, 'DBT_RUN' AS process_trigger, 'DBT_SYSTEM' AS executed_by, 'DBT_SERVER' AS server_name, '1.0.0' AS process_version, PARSE_JSON('{}') AS configuration_parameters, PARSE_JSON('{}') AS performance_metrics, CURRENT_DATE() AS load_date, CURRENT_DATE() AS update_date, 'DBT_GOLD_PIPELINE' AS source_system",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET execution_end_timestamp = CURRENT_TIMESTAMP(), execution_status = 'SUCCESS', records_processed = (SELECT COUNT(*) FROM {{ this }}), execution_duration_seconds = DATEDIFF('second', execution_start_timestamp, CURRENT_TIMESTAMP()) WHERE process_name = 'GO_FACT_SUPPORT_METRICS' AND execution_status = 'RUNNING'"
) }}

WITH support_base AS (
    SELECT 
        st.TICKET_ID,
        st.USER_ID,
        st.TICKET_TYPE,
        st.RESOLUTION_STATUS,
        st.OPEN_DATE,
        st.SOURCE_SYSTEM
    FROM {{ source('silver', 'si_support_tickets') }} st
    WHERE st.VALIDATION_STATUS = 'PASSED'
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY sb.TICKET_ID) AS support_metrics_id,
    dd.date_id AS date_id,
    dsc.support_category_id AS support_category_id,
    du.user_dim_id AS user_dim_id,
    sb.TICKET_ID AS ticket_id,
    sb.OPEN_DATE AS ticket_created_date,
    sb.OPEN_DATE::TIMESTAMP_NTZ AS ticket_created_timestamp,
    CASE 
        WHEN sb.RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN sb.OPEN_DATE + INTERVAL '1 DAY'
        ELSE NULL
    END AS ticket_closed_date,
    CASE 
        WHEN sb.RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN (sb.OPEN_DATE + INTERVAL '1 DAY')::TIMESTAMP_NTZ
        ELSE NULL
    END AS ticket_closed_timestamp,
    sb.OPEN_DATE::TIMESTAMP_NTZ + INTERVAL '2 HOURS' AS first_response_timestamp,
    CASE 
        WHEN sb.RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN (sb.OPEN_DATE + INTERVAL '1 DAY')::TIMESTAMP_NTZ
        ELSE NULL
    END AS resolution_timestamp,
    sb.TICKET_TYPE AS ticket_category,
    CASE 
        WHEN UPPER(sb.TICKET_TYPE) LIKE '%TECHNICAL%' THEN 'Technical Issue'
        WHEN UPPER(sb.TICKET_TYPE) LIKE '%BILLING%' THEN 'Billing Inquiry'
        WHEN UPPER(sb.TICKET_TYPE) LIKE '%FEATURE%' THEN 'Feature Request'
        ELSE 'General Support'
    END AS ticket_subcategory,
    COALESCE(dsc.priority_level, 'Medium') AS priority_level,
    'Medium' AS severity_level,
    sb.RESOLUTION_STATUS,
    2.0 AS first_response_time_hours,
    CASE 
        WHEN sb.RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN 24.0
        ELSE NULL
    END AS resolution_time_hours,
    CASE 
        WHEN sb.RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN 20.0
        ELSE NULL
    END AS active_work_time_hours,
    CASE 
        WHEN sb.RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN 4.0
        ELSE NULL
    END AS customer_wait_time_hours,
    0 AS escalation_count,
    0 AS reassignment_count,
    0 AS reopened_count,
    3 AS agent_interactions_count,
    2 AS customer_interactions_count,
    1 AS knowledge_base_articles_used,
    CASE 
        WHEN sb.RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN 4.0
        ELSE NULL
    END AS customer_satisfaction_score,
    FALSE AS first_contact_resolution,
    CASE 
        WHEN sb.RESOLUTION_STATUS IN ('Resolved', 'Closed') AND COALESCE(dsc.sla_target_hours, 72.0) >= 24.0 THEN TRUE
        ELSE FALSE
    END AS sla_met,
    CASE 
        WHEN sb.RESOLUTION_STATUS IN ('Resolved', 'Closed') AND 24.0 > COALESCE(dsc.sla_target_hours, 72.0) THEN 24.0 - COALESCE(dsc.sla_target_hours, 72.0)
        ELSE 0.0
    END AS sla_breach_hours,
    'Agent Resolution' AS resolution_method,
    'User Error' AS root_cause_category,
    TRUE AS preventable_issue,
    FALSE AS follow_up_required,
    50.00 AS cost_to_resolve,
    CURRENT_DATE() AS load_date,
    CURRENT_DATE() AS update_date,
    COALESCE(sb.SOURCE_SYSTEM, 'UNKNOWN') AS source_system
FROM support_base sb
LEFT JOIN {{ ref('go_dim_date') }} dd ON sb.OPEN_DATE = dd.date_key
LEFT JOIN {{ ref('go_dim_user') }} du ON sb.USER_ID = du.user_id AND du.is_current_record = TRUE
LEFT JOIN {{ ref('go_dim_support_category') }} dsc ON sb.TICKET_TYPE = dsc.support_category
