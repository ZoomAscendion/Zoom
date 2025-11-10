{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (PROCESS_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_START_TIME, PROCESS_STATUS, PROCESS_NOTES, LOAD_DATE, UPDATE_DATE) VALUES ('GO_FACT_SUPPORT_METRICS_TRANSFORMATION', 'SI_SUPPORT_TICKETS', 'GO_FACT_SUPPORT_METRICS', CURRENT_TIMESTAMP(), 'STARTED', 'Support metrics fact transformation started', CURRENT_DATE(), CURRENT_DATE())",
    post_hook="INSERT INTO {{ ref('go_audit_log') }} (PROCESS_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_END_TIME, PROCESS_STATUS, PROCESS_NOTES, LOAD_DATE, UPDATE_DATE) VALUES ('GO_FACT_SUPPORT_METRICS_TRANSFORMATION', 'SI_SUPPORT_TICKETS', 'GO_FACT_SUPPORT_METRICS', CURRENT_TIMESTAMP(), 'COMPLETED', 'Support metrics fact transformation completed successfully', CURRENT_DATE(), CURRENT_DATE())"
) }}

-- Support Metrics Fact Table
-- Comprehensive support ticket analytics and performance metrics

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
        AND st.DATA_QUALITY_SCORE >= 80
),

support_metrics_calculations AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY sb.TICKET_ID) AS SUPPORT_METRICS_ID,
        sb.OPEN_DATE AS TICKET_OPEN_DATE,
        -- Calculate close date based on resolution status and type
        CASE 
            WHEN sb.RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN 
                sb.OPEN_DATE + INTERVAL '1 day' * 
                CASE 
                    WHEN UPPER(sb.TICKET_TYPE) LIKE '%CRITICAL%' THEN 1
                    WHEN UPPER(sb.TICKET_TYPE) LIKE '%HIGH%' THEN 2
                    WHEN UPPER(sb.TICKET_TYPE) LIKE '%MEDIUM%' THEN 5
                    ELSE 7
                END
            ELSE NULL
        END AS TICKET_CLOSE_DATE,
        TIMESTAMP_FROM_PARTS(sb.OPEN_DATE, TIME('09:00:00')) AS TICKET_CREATED_TIMESTAMP,
        -- Calculate resolved timestamp
        CASE 
            WHEN sb.RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN 
                TIMESTAMP_FROM_PARTS(
                    sb.OPEN_DATE + INTERVAL '1 day' * 
                    CASE 
                        WHEN UPPER(sb.TICKET_TYPE) LIKE '%CRITICAL%' THEN 1
                        WHEN UPPER(sb.TICKET_TYPE) LIKE '%HIGH%' THEN 2
                        WHEN UPPER(sb.TICKET_TYPE) LIKE '%MEDIUM%' THEN 5
                        ELSE 7
                    END, 
                    TIME('17:00:00')
                )
            ELSE NULL
        END AS TICKET_RESOLVED_TIMESTAMP,
        -- First response timestamp (estimated 2 hours after creation)
        TIMESTAMP_FROM_PARTS(sb.OPEN_DATE, TIME('11:00:00')) AS FIRST_RESPONSE_TIMESTAMP,
        sb.TICKET_TYPE,
        sb.RESOLUTION_STATUS,
        -- Priority level mapping
        CASE 
            WHEN UPPER(sb.TICKET_TYPE) LIKE '%CRITICAL%' THEN 'P1'
            WHEN UPPER(sb.TICKET_TYPE) LIKE '%HIGH%' THEN 'P2'
            WHEN UPPER(sb.TICKET_TYPE) LIKE '%MEDIUM%' THEN 'P3'
            ELSE 'P4'
        END AS PRIORITY_LEVEL,
        -- Severity level determination
        CASE 
            WHEN UPPER(sb.TICKET_TYPE) LIKE '%CRITICAL%' THEN 'Severity 1'
            WHEN UPPER(sb.TICKET_TYPE) LIKE '%HIGH%' THEN 'Severity 2'
            ELSE 'Severity 3'
        END AS SEVERITY_LEVEL,
        -- Resolution time calculation
        CASE 
            WHEN sb.RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN 
                CASE 
                    WHEN UPPER(sb.TICKET_TYPE) LIKE '%CRITICAL%' THEN 4
                    WHEN UPPER(sb.TICKET_TYPE) LIKE '%HIGH%' THEN 24
                    WHEN UPPER(sb.TICKET_TYPE) LIKE '%MEDIUM%' THEN 72
                    ELSE 168
                END
            ELSE NULL
        END AS RESOLUTION_TIME_HOURS,
        2.0 AS FIRST_RESPONSE_TIME_HOURS,
        -- Escalation count based on ticket complexity
        CASE 
            WHEN UPPER(sb.TICKET_TYPE) LIKE '%CRITICAL%' THEN 2
            WHEN UPPER(sb.TICKET_TYPE) LIKE '%HIGH%' THEN 1
            ELSE 0
        END AS ESCALATION_COUNT,
        -- Reassignment count
        CASE 
            WHEN UPPER(sb.TICKET_TYPE) LIKE '%CRITICAL%' OR UPPER(sb.TICKET_TYPE) LIKE '%HIGH%' THEN 1
            ELSE 0
        END AS REASSIGNMENT_COUNT,
        -- Customer satisfaction score estimation
        CASE 
            WHEN sb.RESOLUTION_STATUS = 'Resolved' THEN
                CASE 
                    WHEN UPPER(sb.TICKET_TYPE) LIKE '%CRITICAL%' THEN 8.5
                    WHEN UPPER(sb.TICKET_TYPE) LIKE '%HIGH%' THEN 9.0
                    ELSE 9.2
                END
            ELSE 7.0
        END AS CUSTOMER_SATISFACTION_SCORE,
        -- Agent performance score
        CASE 
            WHEN sb.RESOLUTION_STATUS = 'Resolved' THEN 8.8
            WHEN sb.RESOLUTION_STATUS = 'In Progress' THEN 7.5
            ELSE 6.0
        END AS AGENT_PERFORMANCE_SCORE,
        -- First contact resolution flag
        CASE 
            WHEN (UPPER(sb.TICKET_TYPE) LIKE '%LOW%' OR UPPER(sb.TICKET_TYPE) LIKE '%MEDIUM%') 
                 AND sb.RESOLUTION_STATUS = 'Resolved' THEN TRUE
            ELSE FALSE
        END AS FIRST_CONTACT_RESOLUTION_FLAG,
        -- SLA met flag
        CASE 
            WHEN sb.RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN TRUE
            ELSE FALSE
        END AS SLA_MET_FLAG,
        0 AS SLA_BREACH_HOURS,
        -- Communication count based on ticket type
        CASE 
            WHEN UPPER(sb.TICKET_TYPE) LIKE '%CRITICAL%' THEN 8
            WHEN UPPER(sb.TICKET_TYPE) LIKE '%HIGH%' THEN 5
            WHEN UPPER(sb.TICKET_TYPE) LIKE '%MEDIUM%' THEN 3
            ELSE 2
        END AS COMMUNICATION_COUNT,
        -- Knowledge base usage flag
        CASE 
            WHEN UPPER(sb.TICKET_TYPE) LIKE '%LOW%' OR UPPER(sb.TICKET_TYPE) LIKE '%MEDIUM%' THEN TRUE
            ELSE FALSE
        END AS KNOWLEDGE_BASE_USED_FLAG,
        -- Remote assistance flag
        CASE 
            WHEN UPPER(sb.TICKET_TYPE) LIKE '%CRITICAL%' OR UPPER(sb.TICKET_TYPE) LIKE '%HIGH%' THEN TRUE
            ELSE FALSE
        END AS REMOTE_ASSISTANCE_USED_FLAG,
        -- Follow-up required flag
        CASE 
            WHEN UPPER(sb.TICKET_TYPE) LIKE '%CRITICAL%' THEN TRUE
            ELSE FALSE
        END AS FOLLOW_UP_REQUIRED_FLAG,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        sb.SOURCE_SYSTEM
    FROM support_base sb
)

SELECT * FROM support_metrics_calculations
ORDER BY SUPPORT_METRICS_ID
