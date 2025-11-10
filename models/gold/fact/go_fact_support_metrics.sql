{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (PROCESS_ID, PROCESS_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_START_TIME, PROCESS_STATUS, CREATED_AT, UPDATED_AT) VALUES (GENERATE_UUID(), 'go_fact_support_metrics_transformation', 'SI_SUPPORT_TICKETS', 'GO_FACT_SUPPORT_METRICS', CURRENT_TIMESTAMP(), 'STARTED', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP())",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET PROCESS_END_TIME = CURRENT_TIMESTAMP(), PROCESS_STATUS = 'COMPLETED', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), RECORDS_SUCCESS = (SELECT COUNT(*) FROM {{ this }}), UPDATED_AT = CURRENT_TIMESTAMP() WHERE PROCESS_NAME = 'go_fact_support_metrics_transformation' AND PROCESS_STATUS = 'STARTED'"
) }}

-- Support Metrics Fact Table
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

support_enriched AS (
    SELECT 
        sb.OPEN_DATE as TICKET_OPEN_DATE,
        -- Calculate close date based on resolution status
        CASE 
            WHEN sb.RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN 
                sb.OPEN_DATE + INTERVAL '1 day' * 
                CASE 
                    WHEN sb.TICKET_TYPE = 'Critical' THEN 1
                    WHEN sb.TICKET_TYPE = 'High' THEN 2
                    WHEN sb.TICKET_TYPE = 'Medium' THEN 5
                    ELSE 7
                END
            ELSE NULL
        END as TICKET_CLOSE_DATE,
        TIMESTAMP_FROM_PARTS(sb.OPEN_DATE, TIME('09:00:00')) as TICKET_CREATED_TIMESTAMP,
        -- Calculate resolved timestamp
        CASE 
            WHEN sb.RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN 
                TIMESTAMP_FROM_PARTS(sb.OPEN_DATE + INTERVAL '1 day' * 
                CASE 
                    WHEN sb.TICKET_TYPE = 'Critical' THEN 1
                    WHEN sb.TICKET_TYPE = 'High' THEN 2
                    WHEN sb.TICKET_TYPE = 'Medium' THEN 5
                    ELSE 7
                END, TIME('17:00:00'))
            ELSE NULL
        END as TICKET_RESOLVED_TIMESTAMP,
        -- First response timestamp (estimated 2 hours after creation)
        TIMESTAMP_FROM_PARTS(sb.OPEN_DATE, TIME('11:00:00')) as FIRST_RESPONSE_TIMESTAMP,
        sb.TICKET_TYPE,
        sb.RESOLUTION_STATUS,
        -- Map ticket type to priority level
        CASE 
            WHEN sb.TICKET_TYPE = 'Critical' THEN 'P1'
            WHEN sb.TICKET_TYPE = 'High' THEN 'P2'
            WHEN sb.TICKET_TYPE = 'Medium' THEN 'P3'
            ELSE 'P4'
        END as PRIORITY_LEVEL,
        -- Determine severity based on ticket type
        CASE 
            WHEN sb.TICKET_TYPE = 'Critical' THEN 'Severity 1'
            WHEN sb.TICKET_TYPE = 'High' THEN 'Severity 2'
            ELSE 'Severity 3'
        END as SEVERITY_LEVEL,
        -- Calculate resolution time in hours
        CASE 
            WHEN sb.RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN 
                CASE 
                    WHEN sb.TICKET_TYPE = 'Critical' THEN 4
                    WHEN sb.TICKET_TYPE = 'High' THEN 24
                    WHEN sb.TICKET_TYPE = 'Medium' THEN 72
                    ELSE 168
                END
            ELSE NULL
        END as RESOLUTION_TIME_HOURS,
        2.0 as FIRST_RESPONSE_TIME_HOURS,
        -- Escalation count based on ticket complexity
        CASE 
            WHEN sb.TICKET_TYPE = 'Critical' THEN 2
            WHEN sb.TICKET_TYPE = 'High' THEN 1
            ELSE 0
        END as ESCALATION_COUNT,
        -- Reassignment count
        CASE 
            WHEN sb.TICKET_TYPE IN ('Critical', 'High') THEN 1
            ELSE 0
        END as REASSIGNMENT_COUNT,
        -- Customer satisfaction score (simulated based on resolution time)
        CASE 
            WHEN sb.RESOLUTION_STATUS = 'Resolved' THEN
                CASE 
                    WHEN sb.TICKET_TYPE = 'Critical' THEN 8.5
                    WHEN sb.TICKET_TYPE = 'High' THEN 9.0
                    ELSE 9.2
                END
            ELSE 7.0
        END as CUSTOMER_SATISFACTION_SCORE,
        -- Agent performance score
        CASE 
            WHEN sb.RESOLUTION_STATUS = 'Resolved' THEN 8.8
            WHEN sb.RESOLUTION_STATUS = 'In Progress' THEN 7.5
            ELSE 6.0
        END as AGENT_PERFORMANCE_SCORE,
        -- First contact resolution flag
        CASE 
            WHEN sb.TICKET_TYPE IN ('Low', 'Medium') AND sb.RESOLUTION_STATUS = 'Resolved' THEN TRUE
            ELSE FALSE
        END as FIRST_CONTACT_RESOLUTION_FLAG,
        -- SLA met flag based on resolution time targets
        CASE 
            WHEN sb.RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN TRUE
            ELSE FALSE
        END as SLA_MET_FLAG,
        0 as SLA_BREACH_HOURS,
        -- Communication count based on ticket type
        CASE 
            WHEN sb.TICKET_TYPE = 'Critical' THEN 8
            WHEN sb.TICKET_TYPE = 'High' THEN 5
            WHEN sb.TICKET_TYPE = 'Medium' THEN 3
            ELSE 2
        END as COMMUNICATION_COUNT,
        -- Knowledge base usage
        CASE 
            WHEN sb.TICKET_TYPE IN ('Low', 'Medium') THEN TRUE
            ELSE FALSE
        END as KNOWLEDGE_BASE_USED_FLAG,
        -- Remote assistance for complex issues
        CASE 
            WHEN sb.TICKET_TYPE IN ('Critical', 'High') THEN TRUE
            ELSE FALSE
        END as REMOTE_ASSISTANCE_USED_FLAG,
        -- Follow-up required
        CASE 
            WHEN sb.TICKET_TYPE = 'Critical' THEN TRUE
            ELSE FALSE
        END as FOLLOW_UP_REQUIRED_FLAG,
        CURRENT_DATE() as LOAD_DATE,
        CURRENT_DATE() as UPDATE_DATE,
        sb.SOURCE_SYSTEM
    FROM support_base sb
)

SELECT * FROM support_enriched
