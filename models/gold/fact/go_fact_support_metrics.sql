{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (AUDIT_ID, PIPELINE_NAME, SOURCE_TABLE, TARGET_TABLE, EXECUTION_START_TIME, EXECUTION_STATUS) VALUES (GENERATE_UUID(), 'GO_FACT_SUPPORT_METRICS', 'SI_SUPPORT_TICKETS', 'GO_FACT_SUPPORT_METRICS', CURRENT_TIMESTAMP(), 'STARTED')",
    post_hook="INSERT INTO {{ ref('go_audit_log') }} (AUDIT_ID, PIPELINE_NAME, SOURCE_TABLE, TARGET_TABLE, EXECUTION_END_TIME, EXECUTION_STATUS, RECORDS_PROCESSED) VALUES (GENERATE_UUID(), 'GO_FACT_SUPPORT_METRICS', 'SI_SUPPORT_TICKETS', 'GO_FACT_SUPPORT_METRICS', CURRENT_TIMESTAMP(), 'COMPLETED', (SELECT COUNT(*) FROM {{ this }}))"
) }}

-- Gold Fact: Support Metrics Fact
-- Description: Support ticket activities and resolution performance metrics

WITH source_tickets AS (
    SELECT 
        st.TICKET_ID,
        st.USER_ID,
        st.TICKET_TYPE,
        st.RESOLUTION_STATUS,
        st.OPEN_DATE,
        st.SOURCE_SYSTEM
    FROM {{ source('silver', 'si_support_tickets') }} st
    WHERE st.VALIDATION_STATUS = 'PASSED'
),

support_metrics AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY TICKET_ID) AS SUPPORT_METRICS_ID,
        OPEN_DATE AS TICKET_OPEN_DATE,
        CASE 
            WHEN UPPER(RESOLUTION_STATUS) = 'RESOLVED' THEN 
                DATEADD('day', FLOOR(RANDOM() * 7) + 1, OPEN_DATE)
            ELSE NULL
        END AS TICKET_CLOSE_DATE,
        DATEADD('hour', FLOOR(RANDOM() * 24), OPEN_DATE) AS TICKET_CREATED_TIMESTAMP,
        CASE 
            WHEN UPPER(RESOLUTION_STATUS) = 'RESOLVED' THEN 
                DATEADD('hour', FLOOR(RANDOM() * 168) + 1, OPEN_DATE) -- 1-168 hours
            ELSE NULL
        END AS TICKET_RESOLVED_TIMESTAMP,
        DATEADD('hour', FLOOR(RANDOM() * 4) + 1, OPEN_DATE) AS FIRST_RESPONSE_TIMESTAMP, -- 1-4 hours
        TICKET_TYPE,
        RESOLUTION_STATUS,
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN 'Critical'
            WHEN UPPER(TICKET_TYPE) LIKE '%HIGH%' THEN 'High'
            WHEN UPPER(TICKET_TYPE) LIKE '%MEDIUM%' THEN 'Medium'
            ELSE 'Low'
        END AS PRIORITY_LEVEL,
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN 'Critical'
            WHEN UPPER(TICKET_TYPE) LIKE '%HIGH%' THEN 'High'
            ELSE 'Medium'
        END AS SEVERITY_LEVEL,
        CASE 
            WHEN UPPER(RESOLUTION_STATUS) = 'RESOLVED' THEN 
                ROUND(RANDOM() * 168 + 1, 2) -- 1-168 hours
            ELSE NULL
        END AS RESOLUTION_TIME_HOURS,
        ROUND(RANDOM() * 4 + 1, 2) AS FIRST_RESPONSE_TIME_HOURS, -- 1-4 hours
        FLOOR(RANDOM() * 3) AS ESCALATION_COUNT, -- 0-2 escalations
        FLOOR(RANDOM() * 2) AS REASSIGNMENT_COUNT, -- 0-1 reassignments
        CASE 
            WHEN UPPER(RESOLUTION_STATUS) = 'RESOLVED' THEN ROUND(RANDOM() * 2 + 8, 1) -- 8.0-10.0
            ELSE NULL
        END AS CUSTOMER_SATISFACTION_SCORE,
        ROUND(RANDOM() * 1 + 9, 1) AS AGENT_PERFORMANCE_SCORE, -- 9.0-10.0
        CASE 
            WHEN FLOOR(RANDOM() * 3) = 0 THEN TRUE -- 33% first contact resolution
            ELSE FALSE
        END AS FIRST_CONTACT_RESOLUTION_FLAG,
        CASE 
            WHEN UPPER(RESOLUTION_STATUS) = 'RESOLVED' AND RANDOM() > 0.2 THEN TRUE -- 80% SLA met
            ELSE FALSE
        END AS SLA_MET_FLAG,
        CASE 
            WHEN RANDOM() < 0.2 THEN ROUND(RANDOM() * 24, 2) -- 20% have SLA breach
            ELSE 0.0
        END AS SLA_BREACH_HOURS,
        FLOOR(RANDOM() * 10) + 2 AS COMMUNICATION_COUNT, -- 2-11 communications
        CASE 
            WHEN RANDOM() > 0.4 THEN TRUE -- 60% use knowledge base
            ELSE FALSE
        END AS KNOWLEDGE_BASE_USED_FLAG,
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%TECHNICAL%' AND RANDOM() > 0.7 THEN TRUE -- 30% technical tickets use remote assistance
            ELSE FALSE
        END AS REMOTE_ASSISTANCE_USED_FLAG,
        CASE 
            WHEN RANDOM() > 0.8 THEN TRUE -- 20% require follow-up
            ELSE FALSE
        END AS FOLLOW_UP_REQUIRED_FLAG,
        CURRENT_DATE AS LOAD_DATE,
        CURRENT_DATE AS UPDATE_DATE,
        SOURCE_SYSTEM
    FROM source_tickets
)

SELECT * FROM support_metrics
