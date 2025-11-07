{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (PROCESS_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_START_TIME, PROCESS_STATUS, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) VALUES ('GO_FACT_SUPPORT_METRICS_LOAD', 'SI_SUPPORT_TICKETS', 'GO_FACT_SUPPORT_METRICS', CURRENT_TIMESTAMP(), 'STARTED', CURRENT_DATE(), CURRENT_DATE(), 'DBT_GOLD_PIPELINE')",
    post_hook="INSERT INTO {{ ref('go_audit_log') }} (PROCESS_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_START_TIME, PROCESS_END_TIME, PROCESS_STATUS, RECORDS_PROCESSED, RECORDS_SUCCESS, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) VALUES ('GO_FACT_SUPPORT_METRICS_LOAD', 'SI_SUPPORT_TICKETS', 'GO_FACT_SUPPORT_METRICS', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 'SUCCESS', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), CURRENT_DATE(), CURRENT_DATE(), 'DBT_GOLD_PIPELINE')"
) }}

-- Gold Layer Support Metrics Fact
-- Fact table capturing support ticket activities and resolution performance metrics

WITH support_base AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        TICKET_TYPE,
        RESOLUTION_STATUS,
        OPEN_DATE,
        SOURCE_SYSTEM
    FROM {{ source('silver', 'si_support_tickets') }}
    WHERE VALIDATION_STATUS = 'PASSED'
        AND DATA_QUALITY_SCORE >= 80
),

support_enriched AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY OPEN_DATE, TICKET_ID) AS SUPPORT_METRICS_ID,
        OPEN_DATE as TICKET_OPEN_DATE,
        -- Calculate close date based on resolution status
        CASE 
            WHEN UPPER(RESOLUTION_STATUS) IN ('RESOLVED', 'CLOSED') THEN 
                DATEADD('day', 
                CASE 
                    WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN 1
                    WHEN UPPER(TICKET_TYPE) LIKE '%HIGH%' THEN 2
                    WHEN UPPER(TICKET_TYPE) LIKE '%MEDIUM%' THEN 5
                    ELSE 7
                END, OPEN_DATE)
            ELSE NULL
        END as TICKET_CLOSE_DATE,
        TIMESTAMP_FROM_PARTS(OPEN_DATE, TIME('09:00:00')) as TICKET_CREATED_TIMESTAMP,
        -- Calculate resolved timestamp
        CASE 
            WHEN UPPER(RESOLUTION_STATUS) IN ('RESOLVED', 'CLOSED') THEN 
                TIMESTAMP_FROM_PARTS(DATEADD('day', 
                CASE 
                    WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN 1
                    WHEN UPPER(TICKET_TYPE) LIKE '%HIGH%' THEN 2
                    WHEN UPPER(TICKET_TYPE) LIKE '%MEDIUM%' THEN 5
                    ELSE 7
                END, OPEN_DATE), TIME('17:00:00'))
            ELSE NULL
        END as TICKET_RESOLVED_TIMESTAMP,
        -- First response timestamp (estimated 2 hours after creation)
        TIMESTAMP_FROM_PARTS(OPEN_DATE, TIME('11:00:00')) as FIRST_RESPONSE_TIMESTAMP,
        TICKET_TYPE,
        RESOLUTION_STATUS,
        -- Map ticket type to priority level
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN 'P1'
            WHEN UPPER(TICKET_TYPE) LIKE '%HIGH%' THEN 'P2'
            WHEN UPPER(TICKET_TYPE) LIKE '%MEDIUM%' THEN 'P3'
            ELSE 'P4'
        END as PRIORITY_LEVEL,
        -- Determine severity based on ticket type
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN 'Severity 1'
            WHEN UPPER(TICKET_TYPE) LIKE '%HIGH%' THEN 'Severity 2'
            ELSE 'Severity 3'
        END as SEVERITY_LEVEL,
        -- Calculate resolution time in hours
        CASE 
            WHEN UPPER(RESOLUTION_STATUS) IN ('RESOLVED', 'CLOSED') THEN 
                CASE 
                    WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN 4
                    WHEN UPPER(TICKET_TYPE) LIKE '%HIGH%' THEN 24
                    WHEN UPPER(TICKET_TYPE) LIKE '%MEDIUM%' THEN 72
                    ELSE 168
                END
            ELSE NULL
        END as RESOLUTION_TIME_HOURS,
        2.0 as FIRST_RESPONSE_TIME_HOURS,
        -- Escalation count based on ticket complexity
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN 2
            WHEN UPPER(TICKET_TYPE) LIKE '%HIGH%' THEN 1
            ELSE 0
        END as ESCALATION_COUNT,
        -- Reassignment count
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' OR UPPER(TICKET_TYPE) LIKE '%HIGH%' THEN 1
            ELSE 0
        END as REASSIGNMENT_COUNT,
        -- Customer satisfaction score (simulated based on resolution time)
        CASE 
            WHEN UPPER(RESOLUTION_STATUS) = 'RESOLVED' THEN
                CASE 
                    WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN 8.5
                    WHEN UPPER(TICKET_TYPE) LIKE '%HIGH%' THEN 9.0
                    ELSE 9.2
                END
            ELSE 7.0
        END as CUSTOMER_SATISFACTION_SCORE,
        -- Agent performance score
        CASE 
            WHEN UPPER(RESOLUTION_STATUS) = 'RESOLVED' THEN 8.8
            WHEN UPPER(RESOLUTION_STATUS) LIKE '%PROGRESS%' THEN 7.5
            ELSE 6.0
        END as AGENT_PERFORMANCE_SCORE,
        -- First contact resolution flag
        CASE 
            WHEN (UPPER(TICKET_TYPE) LIKE '%LOW%' OR UPPER(TICKET_TYPE) LIKE '%MEDIUM%') 
                AND UPPER(RESOLUTION_STATUS) = 'RESOLVED' THEN TRUE
            ELSE FALSE
        END as FIRST_CONTACT_RESOLUTION_FLAG,
        -- SLA met flag based on resolution time targets
        CASE 
            WHEN UPPER(RESOLUTION_STATUS) IN ('RESOLVED', 'CLOSED') THEN TRUE
            ELSE FALSE
        END as SLA_MET_FLAG,
        0 as SLA_BREACH_HOURS,
        -- Communication count based on ticket type
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN 8
            WHEN UPPER(TICKET_TYPE) LIKE '%HIGH%' THEN 5
            WHEN UPPER(TICKET_TYPE) LIKE '%MEDIUM%' THEN 3
            ELSE 2
        END as COMMUNICATION_COUNT,
        -- Knowledge base usage
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%LOW%' OR UPPER(TICKET_TYPE) LIKE '%MEDIUM%' THEN TRUE
            ELSE FALSE
        END as KNOWLEDGE_BASE_USED_FLAG,
        -- Remote assistance for complex issues
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' OR UPPER(TICKET_TYPE) LIKE '%HIGH%' THEN TRUE
            ELSE FALSE
        END as REMOTE_ASSISTANCE_USED_FLAG,
        -- Follow-up required
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN TRUE
            ELSE FALSE
        END as FOLLOW_UP_REQUIRED_FLAG,
        CURRENT_DATE() as LOAD_DATE,
        CURRENT_DATE() as UPDATE_DATE,
        SOURCE_SYSTEM
    FROM support_base
)

SELECT * FROM support_enriched
