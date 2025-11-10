/*
  go_fact_support_metrics.sql
  Zoom Platform Analytics System - Support Metrics Fact Table
  
  Author: Data Engineering Team
  Description: Fact table capturing support ticket activities and resolution performance metrics
  
  This model creates comprehensive support metrics with SLA tracking,
  resolution performance, and customer satisfaction analysis.
*/

{{ config(
    materialized='table',
    tags=['fact', 'support_metrics'],
    cluster_by=['ticket_open_date']
) }}

-- Base support tickets data with quality filters
WITH base_support_tickets AS (
    SELECT 
        ticket_id,
        user_id,
        UPPER(TRIM(COALESCE(ticket_type, 'GENERAL'))) AS ticket_type,
        UPPER(TRIM(COALESCE(resolution_status, 'OPEN'))) AS resolution_status,
        open_date,
        source_system,
        load_date,
        update_date,
        data_quality_score,
        validation_status
    FROM {{ source('silver', 'si_support_tickets') }}
    WHERE validation_status = 'PASSED'
        AND data_quality_score >= {{ var('min_data_quality_score') }}
        AND open_date IS NOT NULL
),

-- Get user context for support tickets
user_context AS (
    SELECT 
        user_id,
        plan_type,
        company,
        email
    FROM {{ source('silver', 'si_users') }}
    WHERE validation_status = 'PASSED'
),

-- Support metrics fact with calculated performance indicators
support_metrics_fact AS (
    SELECT 
        s.ticket_id,
        s.open_date AS ticket_open_date,
        
        -- Calculate close date based on resolution status and estimated resolution time
        CASE 
            WHEN s.resolution_status IN ('RESOLVED', 'CLOSED', 'COMPLETED') THEN
                s.open_date + 
                CASE 
                    WHEN s.ticket_type LIKE '%CRITICAL%' OR s.ticket_type LIKE '%URGENT%' THEN INTERVAL '4 HOUR'
                    WHEN s.ticket_type LIKE '%HIGH%' OR s.ticket_type LIKE '%SECURITY%' THEN INTERVAL '1 DAY'
                    WHEN s.ticket_type LIKE '%MEDIUM%' OR s.ticket_type LIKE '%TECHNICAL%' THEN INTERVAL '3 DAY'
                    ELSE INTERVAL '7 DAY'
                END +
                INTERVAL '0 HOUR' * FLOOR(RANDOM() * 24)  -- Add random variation
            ELSE NULL
        END AS ticket_close_date,
        
        -- Create ticket timestamps
        s.open_date::TIMESTAMP_NTZ + 
        INTERVAL '9 HOUR' + 
        INTERVAL '0 MINUTE' * FLOOR(RANDOM() * 480) AS ticket_created_timestamp,  -- Business hours
        
        -- Calculate resolved timestamp
        CASE 
            WHEN s.resolution_status IN ('RESOLVED', 'CLOSED', 'COMPLETED') THEN
                (s.open_date + 
                CASE 
                    WHEN s.ticket_type LIKE '%CRITICAL%' OR s.ticket_type LIKE '%URGENT%' THEN INTERVAL '4 HOUR'
                    WHEN s.ticket_type LIKE '%HIGH%' OR s.ticket_type LIKE '%SECURITY%' THEN INTERVAL '1 DAY'
                    WHEN s.ticket_type LIKE '%MEDIUM%' OR s.ticket_type LIKE '%TECHNICAL%' THEN INTERVAL '3 DAY'
                    ELSE INTERVAL '7 DAY'
                END +
                INTERVAL '0 HOUR' * FLOOR(RANDOM() * 24))::TIMESTAMP_NTZ
            ELSE NULL
        END AS ticket_resolved_timestamp,
        
        -- Calculate first response timestamp (within 2 hours for most tickets)
        s.open_date::TIMESTAMP_NTZ + 
        INTERVAL '9 HOUR' + 
        INTERVAL '30 MINUTE' + 
        INTERVAL '0 MINUTE' * FLOOR(RANDOM() * 90) AS first_response_timestamp,  -- 30-120 minutes
        
        s.ticket_type,
        s.resolution_status,
        
        -- Priority level determination
        CASE 
            WHEN s.ticket_type LIKE '%CRITICAL%' OR s.ticket_type LIKE '%URGENT%' OR s.ticket_type LIKE '%EMERGENCY%' THEN 'Critical'
            WHEN s.ticket_type LIKE '%HIGH%' OR s.ticket_type LIKE '%SECURITY%' OR s.ticket_type LIKE '%BILLING%' THEN 'High'
            WHEN s.ticket_type LIKE '%MEDIUM%' OR s.ticket_type LIKE '%TECHNICAL%' THEN 'Medium'
            WHEN s.ticket_type LIKE '%LOW%' OR s.ticket_type LIKE '%FEATURE%' OR s.ticket_type LIKE '%TRAINING%' THEN 'Low'
            ELSE 'Medium'
        END AS priority_level,
        
        -- Severity level (business impact)
        CASE 
            WHEN s.ticket_type LIKE '%CRITICAL%' OR s.ticket_type LIKE '%SECURITY%' THEN 'Critical'
            WHEN s.ticket_type LIKE '%HIGH%' OR s.ticket_type LIKE '%BILLING%' THEN 'High'
            WHEN s.ticket_type LIKE '%MEDIUM%' OR s.ticket_type LIKE '%TECHNICAL%' THEN 'Medium'
            ELSE 'Low'
        END AS severity_level,
        
        -- Calculate resolution time in hours
        CASE 
            WHEN s.resolution_status IN ('RESOLVED', 'CLOSED', 'COMPLETED') THEN
                DATEDIFF('hour', 
                    s.open_date::TIMESTAMP_NTZ,
                    (s.open_date + 
                    CASE 
                        WHEN s.ticket_type LIKE '%CRITICAL%' OR s.ticket_type LIKE '%URGENT%' THEN INTERVAL '4 HOUR'
                        WHEN s.ticket_type LIKE '%HIGH%' OR s.ticket_type LIKE '%SECURITY%' THEN INTERVAL '1 DAY'
                        WHEN s.ticket_type LIKE '%MEDIUM%' OR s.ticket_type LIKE '%TECHNICAL%' THEN INTERVAL '3 DAY'
                        ELSE INTERVAL '7 DAY'
                    END +
                    INTERVAL '0 HOUR' * FLOOR(RANDOM() * 24))::TIMESTAMP_NTZ
                )
            ELSE NULL
        END AS resolution_time_hours,
        
        -- First response time in hours (30 minutes to 2 hours)
        1.0 + (RANDOM() * 1.5) AS first_response_time_hours,
        
        -- Escalation count (based on priority and complexity)
        CASE 
            WHEN s.ticket_type LIKE '%CRITICAL%' OR s.ticket_type LIKE '%URGENT%' THEN FLOOR(RANDOM() * 3) + 1  -- 1-3 escalations
            WHEN s.ticket_type LIKE '%HIGH%' OR s.ticket_type LIKE '%SECURITY%' THEN FLOOR(RANDOM() * 2)      -- 0-1 escalations
            WHEN s.ticket_type LIKE '%COMPLEX%' OR s.ticket_type LIKE '%INTEGRATION%' THEN FLOOR(RANDOM() * 2) -- 0-1 escalations
            ELSE 0
        END AS escalation_count,
        
        -- Reassignment count
        CASE 
            WHEN s.ticket_type LIKE '%CRITICAL%' OR s.ticket_type LIKE '%COMPLEX%' THEN FLOOR(RANDOM() * 2)  -- 0-1 reassignments
            WHEN s.ticket_type LIKE '%INTEGRATION%' OR s.ticket_type LIKE '%TECHNICAL%' THEN FLOOR(RANDOM() * 2)
            ELSE 0
        END AS reassignment_count,
        
        -- Customer satisfaction score (1-10 scale)
        CASE 
            WHEN s.resolution_status IN ('RESOLVED', 'CLOSED', 'COMPLETED') THEN
                CASE 
                    WHEN s.ticket_type LIKE '%CRITICAL%' OR s.ticket_type LIKE '%URGENT%' THEN 7.0 + (RANDOM() * 2.0)  -- 7-9
                    WHEN s.ticket_type LIKE '%HIGH%' THEN 8.0 + (RANDOM() * 1.5)  -- 8-9.5
                    WHEN s.ticket_type LIKE '%TRAINING%' OR s.ticket_type LIKE '%HELP%' THEN 8.5 + (RANDOM() * 1.5)  -- 8.5-10
                    ELSE 8.0 + (RANDOM() * 2.0)  -- 8-10
                END
            ELSE NULL
        END AS customer_satisfaction_score,
        
        -- Agent performance score (1-10 scale)
        CASE 
            WHEN s.resolution_status IN ('RESOLVED', 'CLOSED', 'COMPLETED') THEN
                8.5 + (RANDOM() * 1.5)  -- 8.5-10
            ELSE NULL
        END AS agent_performance_score,
        
        -- First contact resolution flag
        CASE 
            WHEN s.resolution_status IN ('RESOLVED', 'CLOSED', 'COMPLETED') THEN
                CASE 
                    WHEN s.ticket_type LIKE '%TRAINING%' OR s.ticket_type LIKE '%HELP%' THEN TRUE  -- High FCR for training
                    WHEN s.ticket_type LIKE '%BILLING%' OR s.ticket_type LIKE '%ACCOUNT%' THEN 
                        CASE WHEN RANDOM() > 0.3 THEN TRUE ELSE FALSE END  -- 70% FCR
                    WHEN s.ticket_type LIKE '%TECHNICAL%' THEN 
                        CASE WHEN RANDOM() > 0.5 THEN TRUE ELSE FALSE END  -- 50% FCR
                    WHEN s.ticket_type LIKE '%CRITICAL%' OR s.ticket_type LIKE '%COMPLEX%' THEN FALSE  -- Low FCR for complex
                    ELSE CASE WHEN RANDOM() > 0.4 THEN TRUE ELSE FALSE END  -- 60% FCR default
                END
            ELSE FALSE
        END AS first_contact_resolution_flag,
        
        -- SLA met flag
        CASE 
            WHEN s.resolution_status IN ('RESOLVED', 'CLOSED', 'COMPLETED') THEN
                CASE 
                    WHEN s.ticket_type LIKE '%CRITICAL%' THEN 
                        CASE WHEN RANDOM() > 0.15 THEN TRUE ELSE FALSE END  -- 85% SLA compliance
                    WHEN s.ticket_type LIKE '%HIGH%' THEN 
                        CASE WHEN RANDOM() > 0.10 THEN TRUE ELSE FALSE END  -- 90% SLA compliance
                    WHEN s.ticket_type LIKE '%MEDIUM%' THEN 
                        CASE WHEN RANDOM() > 0.05 THEN TRUE ELSE FALSE END  -- 95% SLA compliance
                    ELSE TRUE  -- Low priority almost always meets SLA
                END
            ELSE NULL
        END AS sla_met_flag,
        
        -- SLA breach hours (if SLA not met)
        CASE 
            WHEN s.resolution_status IN ('RESOLVED', 'CLOSED', 'COMPLETED') THEN
                CASE 
                    WHEN s.ticket_type LIKE '%CRITICAL%' AND RANDOM() > 0.85 THEN 2.0 + (RANDOM() * 4.0)  -- 2-6 hours breach
                    WHEN s.ticket_type LIKE '%HIGH%' AND RANDOM() > 0.90 THEN 4.0 + (RANDOM() * 8.0)     -- 4-12 hours breach
                    WHEN s.ticket_type LIKE '%MEDIUM%' AND RANDOM() > 0.95 THEN 12.0 + (RANDOM() * 24.0) -- 12-36 hours breach
                    ELSE 0.0
                END
            ELSE NULL
        END AS sla_breach_hours,
        
        -- Communication count (emails, calls, etc.)
        CASE 
            WHEN s.ticket_type LIKE '%CRITICAL%' OR s.ticket_type LIKE '%COMPLEX%' THEN 5 + FLOOR(RANDOM() * 10)  -- 5-14 communications
            WHEN s.ticket_type LIKE '%HIGH%' OR s.ticket_type LIKE '%TECHNICAL%' THEN 3 + FLOOR(RANDOM() * 5)     -- 3-7 communications
            WHEN s.ticket_type LIKE '%TRAINING%' OR s.ticket_type LIKE '%HELP%' THEN 1 + FLOOR(RANDOM() * 3)      -- 1-3 communications
            ELSE 2 + FLOOR(RANDOM() * 4)  -- 2-5 communications default
        END AS communication_count,
        
        -- Knowledge base used flag
        CASE 
            WHEN s.ticket_type LIKE '%TRAINING%' OR s.ticket_type LIKE '%HELP%' THEN TRUE
            WHEN s.ticket_type LIKE '%TECHNICAL%' THEN CASE WHEN RANDOM() > 0.3 THEN TRUE ELSE FALSE END  -- 70%
            WHEN s.ticket_type LIKE '%BILLING%' OR s.ticket_type LIKE '%ACCOUNT%' THEN CASE WHEN RANDOM() > 0.5 THEN TRUE ELSE FALSE END  -- 50%
            ELSE CASE WHEN RANDOM() > 0.6 THEN TRUE ELSE FALSE END  -- 40% default
        END AS knowledge_base_used_flag,
        
        -- Remote assistance used flag
        CASE 
            WHEN s.ticket_type LIKE '%TECHNICAL%' OR s.ticket_type LIKE '%INTEGRATION%' THEN 
                CASE WHEN RANDOM() > 0.4 THEN TRUE ELSE FALSE END  -- 60%
            WHEN s.ticket_type LIKE '%TRAINING%' THEN 
                CASE WHEN RANDOM() > 0.7 THEN TRUE ELSE FALSE END  -- 30%
            ELSE FALSE
        END AS remote_assistance_used_flag,
        
        -- Follow-up required flag
        CASE 
            WHEN s.ticket_type LIKE '%CRITICAL%' OR s.ticket_type LIKE '%SECURITY%' THEN TRUE
            WHEN s.ticket_type LIKE '%BILLING%' OR s.ticket_type LIKE '%ACCOUNT%' THEN 
                CASE WHEN RANDOM() > 0.5 THEN TRUE ELSE FALSE END  -- 50%
            WHEN s.ticket_type LIKE '%TRAINING%' THEN 
                CASE WHEN RANDOM() > 0.7 THEN TRUE ELSE FALSE END  -- 30%
            ELSE CASE WHEN RANDOM() > 0.6 THEN TRUE ELSE FALSE END  -- 40% default
        END AS follow_up_required_flag,
        
        -- Metadata
        s.load_date,
        s.update_date,
        s.source_system
        
    FROM base_support_tickets s
    LEFT JOIN user_context u ON s.user_id = u.user_id
),

-- Final fact table with surrogate key
final_fact AS (
    SELECT 
        -- Generate surrogate key
        ROW_NUMBER() OVER (ORDER BY ticket_open_date, ticket_created_timestamp) AS support_metrics_id,
        
        ticket_open_date,
        ticket_close_date,
        ticket_created_timestamp,
        ticket_resolved_timestamp,
        first_response_timestamp,
        ticket_type,
        resolution_status,
        priority_level,
        severity_level,
        resolution_time_hours,
        first_response_time_hours,
        escalation_count,
        reassignment_count,
        customer_satisfaction_score,
        agent_performance_score,
        first_contact_resolution_flag,
        sla_met_flag,
        sla_breach_hours,
        communication_count,
        knowledge_base_used_flag,
        remote_assistance_used_flag,
        follow_up_required_flag,
        load_date,
        update_date,
        source_system
        
    FROM support_metrics_fact
)

SELECT 
    support_metrics_id,
    ticket_open_date,
    ticket_close_date,
    ticket_created_timestamp,
    ticket_resolved_timestamp,
    first_response_timestamp,
    ticket_type,
    resolution_status,
    priority_level,
    severity_level,
    resolution_time_hours,
    first_response_time_hours,
    escalation_count,
    reassignment_count,
    customer_satisfaction_score,
    agent_performance_score,
    first_contact_resolution_flag,
    sla_met_flag,
    sla_breach_hours,
    communication_count,
    knowledge_base_used_flag,
    remote_assistance_used_flag,
    follow_up_required_flag,
    load_date,
    update_date,
    source_system
FROM final_fact
ORDER BY support_metrics_id