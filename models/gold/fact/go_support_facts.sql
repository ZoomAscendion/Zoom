{{ config(
    materialized='table'
) }}

-- Gold Support Facts Table
WITH support_base AS (
    SELECT 
        s.support_ticket_id,
        s.user_id,
        s.ticket_type,
        s.issue_description,
        s.priority_level,
        s.resolution_status,
        s.open_date,
        s.close_date,
        s.resolution_time_hours,
        s.first_response_time_hours,
        s.escalation_flag,
        s.sla_breach_flag,
        s.load_date as s_load_date,
        s.update_date as s_update_date,
        s.source_system as s_source_system
    FROM {{ source('silver', 'si_support_tickets') }} s
),

user_info AS (
    SELECT 
        u.user_id,
        u.user_name,
        u.company,
        u.plan_type
    FROM {{ source('silver', 'si_users') }} u
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY sb.support_ticket_id) as support_fact_id,
    sb.open_date as ticket_date,
    COALESCE(ui.user_name, 'Unknown User') as user_name,
    COALESCE(sb.ticket_type, 'General') as ticket_type,
    COALESCE(sb.priority_level, 'Medium') as priority_level,
    COALESCE(sb.resolution_status, 'Open') as resolution_status,
    COALESCE(sb.resolution_time_hours, 0) as resolution_time_hours,
    COALESCE(sb.first_response_time_hours, 0) as first_response_time_hours,
    COALESCE(sb.escalation_flag, FALSE) as escalation_flag,
    -- SLA breach calculation
    CASE 
        WHEN sb.priority_level = 'Critical' AND sb.first_response_time_hours > 1 THEN TRUE
        WHEN sb.priority_level = 'High' AND sb.resolution_time_hours > 24 THEN TRUE
        WHEN sb.priority_level = 'Medium' AND sb.resolution_time_hours > 72 THEN TRUE
        ELSE COALESCE(sb.sla_breach_flag, FALSE)
    END as sla_breach_flag,
    COALESCE(ui.company, 'Individual') as company,
    COALESCE(ui.plan_type, 'Free') as plan_type,
    'System_Agent' as assigned_agent,
    -- Additional columns from Silver layer
    sb.support_ticket_id,
    sb.user_id,
    COALESCE(sb.issue_description, 'No description provided') as issue_description,
    sb.open_date,
    sb.close_date,
    -- Metadata columns
    COALESCE(sb.s_load_date, CURRENT_DATE()) as load_date,
    COALESCE(sb.s_update_date, CURRENT_DATE()) as update_date,
    COALESCE(sb.s_source_system, 'ZOOM_SUPPORT') as source_system
FROM support_base sb
LEFT JOIN user_info ui ON sb.user_id = ui.user_id
