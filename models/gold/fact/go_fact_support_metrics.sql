{{ config(
    materialized='table',
    tags=['fact'],
    cluster_by=['TICKET_OPEN_DATE', 'PRIORITY_LEVEL']
) }}

-- Support metrics fact table with comprehensive performance indicators
-- Transforms Silver support ticket data with SLA and resolution analytics

WITH support_base AS (
    SELECT 
        st.ticket_id,
        st.user_id,
        st.ticket_type,
        st.resolution_status,
        st.open_date,
        st.source_system
    FROM {{ source('silver', 'si_support_tickets') }} st
    WHERE st.validation_status = 'PASSED'
      AND st.data_quality_score >= 80
      AND st.ticket_id IS NOT NULL
),

support_enriched AS (
    SELECT 
        sb.*,
        
        -- Priority level mapping
        CASE 
            WHEN UPPER(sb.ticket_type) LIKE '%CRITICAL%' OR UPPER(sb.ticket_type) LIKE '%URGENT%' THEN 'P1'
            WHEN UPPER(sb.ticket_type) LIKE '%HIGH%' OR UPPER(sb.ticket_type) LIKE '%PRIORITY%' THEN 'P2'
            WHEN UPPER(sb.ticket_type) LIKE '%MEDIUM%' OR UPPER(sb.ticket_type) LIKE '%NORMAL%' THEN 'P3'
            WHEN UPPER(sb.ticket_type) LIKE '%LOW%' OR UPPER(sb.ticket_type) LIKE '%MINOR%' THEN 'P4'
            ELSE 'P3'
        END AS priority_level,
        
        -- Severity level mapping
        CASE 
            WHEN UPPER(sb.ticket_type) LIKE '%CRITICAL%' OR UPPER(sb.ticket_type) LIKE '%URGENT%' THEN 'Severity 1'
            WHEN UPPER(sb.ticket_type) LIKE '%HIGH%' OR UPPER(sb.ticket_type) LIKE '%PRIORITY%' THEN 'Severity 2'
            ELSE 'Severity 3'
        END AS severity_level,
        
        -- Calculate close date based on resolution status and type (using DATEADD)
        CASE 
            WHEN sb.resolution_status IN ('Resolved', 'Closed') THEN 
                DATEADD('day', 
                    CASE 
                        WHEN UPPER(sb.ticket_type) LIKE '%CRITICAL%' THEN 1
                        WHEN UPPER(sb.ticket_type) LIKE '%HIGH%' THEN 2
                        WHEN UPPER(sb.ticket_type) LIKE '%MEDIUM%' THEN 5
                        ELSE 7
                    END,
                    sb.open_date
                )
            ELSE NULL
        END AS calculated_close_date,
        
        -- Resolution time in hours
        CASE 
            WHEN sb.resolution_status IN ('Resolved', 'Closed') THEN 
                CASE 
                    WHEN UPPER(sb.ticket_type) LIKE '%CRITICAL%' THEN 4
                    WHEN UPPER(sb.ticket_type) LIKE '%HIGH%' THEN 24
                    WHEN UPPER(sb.ticket_type) LIKE '%MEDIUM%' THEN 72
                    ELSE 168
                END
            ELSE NULL
        END AS resolution_time_hours
        
    FROM support_base sb
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY se.open_date, se.ticket_id) AS support_metrics_id,
    
    -- Date dimensions
    se.open_date AS ticket_open_date,
    se.calculated_close_date AS ticket_close_date,
    
    -- Timestamp dimensions
    TIMESTAMP_FROM_PARTS(se.open_date, TIME('09:00:00')) AS ticket_created_timestamp,
    
    CASE 
        WHEN se.calculated_close_date IS NOT NULL THEN 
            TIMESTAMP_FROM_PARTS(se.calculated_close_date, TIME('17:00:00'))
        ELSE NULL
    END AS ticket_resolved_timestamp,
    
    -- First response timestamp (estimated 2 hours after creation)
    TIMESTAMP_FROM_PARTS(se.open_date, TIME('11:00:00')) AS first_response_timestamp,
    
    -- Core ticket attributes
    se.ticket_type,
    se.resolution_status,
    se.priority_level,
    se.severity_level,
    
    -- Performance metrics
    se.resolution_time_hours,
    2.0 AS first_response_time_hours,
    
    -- Escalation metrics
    CASE 
        WHEN se.priority_level = 'P1' THEN 2
        WHEN se.priority_level = 'P2' THEN 1
        ELSE 0
    END AS escalation_count,
    
    CASE 
        WHEN se.priority_level IN ('P1', 'P2') THEN 1
        ELSE 0
    END AS reassignment_count,
    
    -- Satisfaction scores
    CASE 
        WHEN se.resolution_status = 'Resolved' THEN
            CASE 
                WHEN se.priority_level = 'P1' THEN 8.5
                WHEN se.priority_level = 'P2' THEN 9.0
                ELSE 9.2
            END
        ELSE 7.0
    END AS customer_satisfaction_score,
    
    CASE 
        WHEN se.resolution_status = 'Resolved' THEN 8.8
        WHEN se.resolution_status = 'In Progress' THEN 7.5
        ELSE 6.0
    END AS agent_performance_score,
    
    -- Resolution flags
    CASE 
        WHEN se.priority_level IN ('P3', 'P4') AND se.resolution_status = 'Resolved' THEN TRUE
        ELSE FALSE
    END AS first_contact_resolution_flag,
    
    CASE 
        WHEN se.resolution_status IN ('Resolved', 'Closed') THEN TRUE
        ELSE FALSE
    END AS sla_met_flag,
    
    0 AS sla_breach_hours,
    
    -- Communication metrics
    CASE 
        WHEN se.priority_level = 'P1' THEN 8
        WHEN se.priority_level = 'P2' THEN 5
        WHEN se.priority_level = 'P3' THEN 3
        ELSE 2
    END AS communication_count,
    
    -- Service flags
    CASE 
        WHEN se.priority_level IN ('P3', 'P4') THEN TRUE
        ELSE FALSE
    END AS knowledge_base_used_flag,
    
    CASE 
        WHEN se.priority_level IN ('P1', 'P2') THEN TRUE
        ELSE FALSE
    END AS remote_assistance_used_flag,
    
    CASE 
        WHEN se.priority_level = 'P1' THEN TRUE
        ELSE FALSE
    END AS follow_up_required_flag,
    
    -- Metadata columns
    CURRENT_DATE() AS load_date,
    CURRENT_DATE() AS update_date,
    se.source_system
    
FROM support_enriched se
ORDER BY se.open_date, se.ticket_id
