{{ config(
    materialized='table'
) }}

-- Support Metrics Fact Table
WITH sample_data AS (
    SELECT 
        'TICKET_001' AS TICKET_ID,
        'USER_001' AS USER_ID,
        'Technical' AS TICKET_TYPE,
        'Resolved' AS RESOLUTION_STATUS,
        '2024-01-15'::DATE AS OPEN_DATE
    UNION ALL
    SELECT 
        'TICKET_002' AS TICKET_ID,
        'USER_002' AS USER_ID,
        'Billing' AS TICKET_TYPE,
        'In Progress' AS RESOLUTION_STATUS,
        '2024-01-16'::DATE AS OPEN_DATE
    UNION ALL
    SELECT 
        'TICKET_003' AS TICKET_ID,
        'USER_003' AS USER_ID,
        'Critical' AS TICKET_TYPE,
        'Resolved' AS RESOLUTION_STATUS,
        '2024-01-17'::DATE AS OPEN_DATE
)
SELECT 
    OPEN_DATE as TICKET_OPEN_DATE,
    CASE 
        WHEN RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN 
            DATEADD('day', 
            CASE 
                WHEN TICKET_TYPE = 'Critical' THEN 1
                WHEN TICKET_TYPE = 'High' THEN 2
                WHEN TICKET_TYPE = 'Medium' THEN 5
                ELSE 7
            END, OPEN_DATE)
        ELSE NULL
    END as TICKET_CLOSE_DATE,
    TIMESTAMP_FROM_PARTS(OPEN_DATE, TIME('09:00:00')) as TICKET_CREATED_TIMESTAMP,
    CASE 
        WHEN RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN 
            TIMESTAMP_FROM_PARTS(
                DATEADD('day', 
                CASE 
                    WHEN TICKET_TYPE = 'Critical' THEN 1
                    WHEN TICKET_TYPE = 'High' THEN 2
                    WHEN TICKET_TYPE = 'Medium' THEN 5
                    ELSE 7
                END, OPEN_DATE), 
                TIME('17:00:00')
            )
        ELSE NULL
    END as TICKET_RESOLVED_TIMESTAMP,
    TIMESTAMP_FROM_PARTS(OPEN_DATE, TIME('11:00:00')) as FIRST_RESPONSE_TIMESTAMP,
    TICKET_TYPE,
    RESOLUTION_STATUS,
    CASE 
        WHEN TICKET_TYPE = 'Critical' THEN 'P1'
        WHEN TICKET_TYPE = 'High' THEN 'P2'
        WHEN TICKET_TYPE = 'Medium' THEN 'P3'
        ELSE 'P4'
    END as PRIORITY_LEVEL,
    CASE 
        WHEN TICKET_TYPE = 'Critical' THEN 'Severity 1'
        WHEN TICKET_TYPE = 'High' THEN 'Severity 2'
        ELSE 'Severity 3'
    END as SEVERITY_LEVEL,
    CASE 
        WHEN RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN 
            CASE 
                WHEN TICKET_TYPE = 'Critical' THEN 4
                WHEN TICKET_TYPE = 'High' THEN 24
                WHEN TICKET_TYPE = 'Medium' THEN 72
                ELSE 168
            END
        ELSE NULL
    END as RESOLUTION_TIME_HOURS,
    2.0 as FIRST_RESPONSE_TIME_HOURS,
    CASE 
        WHEN TICKET_TYPE = 'Critical' THEN 2
        WHEN TICKET_TYPE = 'High' THEN 1
        ELSE 0
    END as ESCALATION_COUNT,
    CASE 
        WHEN TICKET_TYPE IN ('Critical', 'High') THEN 1
        ELSE 0
    END as REASSIGNMENT_COUNT,
    CASE 
        WHEN RESOLUTION_STATUS = 'Resolved' THEN
            CASE 
                WHEN TICKET_TYPE = 'Critical' THEN 8.5
                WHEN TICKET_TYPE = 'High' THEN 9.0
                ELSE 9.2
            END
        ELSE 7.0
    END as CUSTOMER_SATISFACTION_SCORE,
    CASE 
        WHEN RESOLUTION_STATUS = 'Resolved' THEN 8.8
        WHEN RESOLUTION_STATUS = 'In Progress' THEN 7.5
        ELSE 6.0
    END as AGENT_PERFORMANCE_SCORE,
    CASE 
        WHEN TICKET_TYPE IN ('Low', 'Medium') AND RESOLUTION_STATUS = 'Resolved' THEN TRUE
        ELSE FALSE
    END as FIRST_CONTACT_RESOLUTION_FLAG,
    CASE 
        WHEN RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN TRUE
        ELSE FALSE
    END as SLA_MET_FLAG,
    0 as SLA_BREACH_HOURS,
    CASE 
        WHEN TICKET_TYPE = 'Critical' THEN 8
        WHEN TICKET_TYPE = 'High' THEN 5
        WHEN TICKET_TYPE = 'Medium' THEN 3
        ELSE 2
    END as COMMUNICATION_COUNT,
    CASE 
        WHEN TICKET_TYPE IN ('Low', 'Medium') THEN TRUE
        ELSE FALSE
    END as KNOWLEDGE_BASE_USED_FLAG,
    CASE 
        WHEN TICKET_TYPE IN ('Critical', 'High') THEN TRUE
        ELSE FALSE
    END as REMOTE_ASSISTANCE_USED_FLAG,
    CASE 
        WHEN TICKET_TYPE = 'Critical' THEN TRUE
        ELSE FALSE
    END as FOLLOW_UP_REQUIRED_FLAG,
    CURRENT_DATE() as LOAD_DATE,
    CURRENT_DATE() as UPDATE_DATE,
    'SYSTEM' AS SOURCE_SYSTEM
FROM sample_data
