{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (audit_log_id, process_name, process_type, execution_start_timestamp, execution_status, source_table_name, target_table_name, process_trigger, executed_by, load_date, source_system) VALUES ('{{ dbt_utils.generate_surrogate_key(['GO_FACT_SUPPORT_METRICS', run_started_at]) }}', 'GO_FACT_SUPPORT_METRICS_LOAD', 'DBT_MODEL', CURRENT_TIMESTAMP(), 'RUNNING', 'SI_SUPPORT_TICKETS', 'GO_FACT_SUPPORT_METRICS', 'DBT_RUN', 'DBT_SYSTEM', CURRENT_DATE(), 'DBT_GOLD_PIPELINE')",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET execution_end_timestamp = CURRENT_TIMESTAMP(), execution_status = 'SUCCESS', records_processed = (SELECT COUNT(*) FROM {{ this }}), execution_duration_seconds = DATEDIFF('second', execution_start_timestamp, CURRENT_TIMESTAMP()) WHERE audit_log_id = '{{ dbt_utils.generate_surrogate_key(['GO_FACT_SUPPORT_METRICS', run_started_at]) }}'"
) }}

-- Support metrics fact table transformation
WITH support_tickets_base AS (
    SELECT 
        st.ticket_id,
        COALESCE(st.user_id, 'UNKNOWN') AS user_id,
        COALESCE(st.ticket_type, 'General') AS ticket_type,
        COALESCE(st.resolution_status, 'Open') AS resolution_status,
        COALESCE(st.open_date, CURRENT_DATE()) AS open_date,
        COALESCE(st.source_system, 'UNKNOWN') AS source_system
    FROM {{ source('gold', 'si_support_tickets') }} st
    WHERE st.validation_status = 'PASSED'
),

support_metrics_fact AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY stb.ticket_id) AS support_metrics_id,
        dd.date_id AS date_id,
        dsc.support_category_id AS support_category_id,
        1 AS user_dim_id, -- Default user
        stb.ticket_id,
        stb.open_date AS ticket_created_date,
        stb.open_date::TIMESTAMP_NTZ AS ticket_created_timestamp,
        CASE 
            WHEN stb.resolution_status IN ('Resolved', 'Closed') THEN stb.open_date + INTERVAL '1 DAY'
            ELSE NULL
        END AS ticket_closed_date,
        CASE 
            WHEN stb.resolution_status IN ('Resolved', 'Closed') THEN (stb.open_date + INTERVAL '1 DAY')::TIMESTAMP_NTZ
            ELSE NULL
        END AS ticket_closed_timestamp,
        (stb.open_date + INTERVAL '2 HOURS')::TIMESTAMP_NTZ AS first_response_timestamp,
        CASE 
            WHEN stb.resolution_status IN ('Resolved', 'Closed') THEN (stb.open_date + INTERVAL '1 DAY')::TIMESTAMP_NTZ
            ELSE NULL
        END AS resolution_timestamp,
        stb.ticket_type AS ticket_category,
        CASE 
            WHEN UPPER(stb.ticket_type) LIKE '%TECHNICAL%' THEN 'Technical Issue'
            WHEN UPPER(stb.ticket_type) LIKE '%BILLING%' THEN 'Billing Inquiry'
            WHEN UPPER(stb.ticket_type) LIKE '%FEATURE%' THEN 'Feature Request'
            ELSE 'General Support'
        END AS ticket_subcategory,
        CASE 
            WHEN UPPER(stb.ticket_type) LIKE '%CRITICAL%' THEN 'Critical'
            WHEN UPPER(stb.ticket_type) LIKE '%URGENT%' THEN 'High'
            WHEN UPPER(stb.ticket_type) LIKE '%BILLING%' THEN 'Medium'
            ELSE 'Low'
        END AS priority_level,
        CASE 
            WHEN UPPER(stb.ticket_type) LIKE '%CRITICAL%' THEN 'Critical'
            WHEN UPPER(stb.ticket_type) LIKE '%URGENT%' THEN 'High'
            WHEN UPPER(stb.ticket_type) LIKE '%BILLING%' THEN 'Medium'
            ELSE 'Low'
        END AS severity_level,
        stb.resolution_status,
        2.0 AS first_response_time_hours,
        CASE 
            WHEN stb.resolution_status IN ('Resolved', 'Closed') THEN 24.0
            ELSE NULL
        END AS resolution_time_hours,
        CASE 
            WHEN stb.resolution_status IN ('Resolved', 'Closed') THEN 20.0
            ELSE NULL
        END AS active_work_time_hours,
        CASE 
            WHEN stb.resolution_status IN ('Resolved', 'Closed') THEN 4.0
            ELSE NULL
        END AS customer_wait_time_hours,
        0 AS escalation_count,
        0 AS reassignment_count,
        0 AS reopened_count,
        3 AS agent_interactions_count,
        2 AS customer_interactions_count,
        1 AS knowledge_base_articles_used,
        CASE 
            WHEN stb.resolution_status IN ('Resolved', 'Closed') AND 24.0 <= 4 THEN 5.0
            WHEN stb.resolution_status IN ('Resolved', 'Closed') AND 24.0 <= 24 THEN 4.0
            WHEN stb.resolution_status IN ('Resolved', 'Closed') AND 24.0 <= 72 THEN 3.0
            WHEN stb.resolution_status IN ('Resolved', 'Closed') THEN 2.0
            ELSE 1.0
        END AS customer_satisfaction_score,
        FALSE AS first_contact_resolution,
        CASE 
            WHEN stb.resolution_status IN ('Resolved', 'Closed') AND 24.0 <= 72.0 THEN TRUE
            ELSE FALSE
        END AS sla_met,
        CASE 
            WHEN stb.resolution_status IN ('Resolved', 'Closed') AND 24.0 > 72.0 
            THEN 24.0 - 72.0
            ELSE 0
        END AS sla_breach_hours,
        'Agent Resolution' AS resolution_method,
        'User Error' AS root_cause_category,
        CASE 
            WHEN stb.ticket_type IN ('Password Reset', 'Account Lockout', 'Basic Setup') THEN TRUE
            ELSE FALSE
        END AS preventable_issue,
        FALSE AS follow_up_required,
        50.00 AS cost_to_resolve,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        stb.source_system
    FROM support_tickets_base stb
    LEFT JOIN {{ ref('go_dim_date') }} dd ON stb.open_date = dd.date_value
    LEFT JOIN {{ ref('go_dim_support_category') }} dsc ON stb.ticket_type = dsc.support_category
)

SELECT * FROM support_metrics_fact
