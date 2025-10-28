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
),

support_enriched AS (
    SELECT 
        sb.*,
        ui.user_name,
        ui.company,
        ui.plan_type
    FROM support_base sb
    LEFT JOIN user_info ui ON sb.user_id = ui.user_id
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY support_ticket_id) as support_fact_id,
    open_date as ticket_date,
    COALESCE(user_name, 'Unknown User') as user_name,
    COALESCE(ticket_type, 'General') as ticket_type,
    COALESCE(priority_level, 'Medium') as priority_level,
    COALESCE(resolution_status, 'Open') as resolution_status,
    COALESCE(resolution_time_hours, 0) as resolution_time_hours,
    COALESCE(first_response_time_hours, 0) as first_response_time_hours,
    COALESCE(escalation_flag, FALSE) as escalation_flag,
    -- SLA breach calculation
    CASE 
        WHEN priority_level = 'Critical' AND first_response_time_hours > 1 THEN TRUE
        WHEN priority_level = 'High' AND resolution_time_hours > 24 THEN TRUE
        WHEN priority_level = 'Medium' AND resolution_time_hours > 72 THEN TRUE
        ELSE COALESCE(sla_breach_flag, FALSE)
    END as sla_breach_flag,
    COALESCE(company, 'Individual') as company,
    COALESCE(plan_type, 'Free') as plan_type,
    'System_Agent' as assigned_agent,
    -- Additional columns from Silver layer
    support_ticket_id,
    user_id,
    COALESCE(issue_description, 'No description provided') as issue_description,
    open_date,
    close_date,
    -- Metadata columns
    COALESCE(s_load_date, CURRENT_DATE()) as load_date,
    COALESCE(s_update_date, CURRENT_DATE()) as update_date,
    COALESCE(s_source_system, 'ZOOM_SUPPORT') as source_system
FROM support_enriched
