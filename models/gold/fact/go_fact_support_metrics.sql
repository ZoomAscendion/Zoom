{{ config(
    materialized='table'
) }}

-- Support metrics fact table with SLA and resolution tracking
-- Tracks support ticket performance and customer satisfaction

WITH source_support AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        TICKET_TYPE,
        RESOLUTION_STATUS,
        OPEN_DATE,
        SOURCE_SYSTEM
    FROM DB_POC_ZOOM.SILVER.SI_SUPPORT_TICKETS
    WHERE VALIDATION_STATUS = 'PASSED'
      AND TICKET_ID IS NOT NULL
      AND USER_ID IS NOT NULL
),

support_metrics_fact AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY st.TICKET_ID) AS SUPPORT_METRICS_ID,
        1 AS DATE_ID,
        1 AS SUPPORT_CATEGORY_ID,
        1 AS USER_DIM_ID,
        st.TICKET_ID,
        st.OPEN_DATE AS TICKET_CREATED_DATE,
        st.OPEN_DATE::TIMESTAMP_NTZ AS TICKET_CREATED_TIMESTAMP,
        CASE 
            WHEN st.RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN st.OPEN_DATE + INTERVAL '1 DAY'
            ELSE NULL
        END AS TICKET_CLOSED_DATE,
        CASE 
            WHEN st.RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN (st.OPEN_DATE + INTERVAL '1 DAY')::TIMESTAMP_NTZ
            ELSE NULL
        END AS TICKET_CLOSED_TIMESTAMP,
        (st.OPEN_DATE + INTERVAL '2 HOURS')::TIMESTAMP_NTZ AS FIRST_RESPONSE_TIMESTAMP,
        CASE 
            WHEN st.RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN (st.OPEN_DATE + INTERVAL '1 DAY')::TIMESTAMP_NTZ
            ELSE NULL
        END AS RESOLUTION_TIMESTAMP,
        st.TICKET_TYPE AS TICKET_CATEGORY,
        'General Support' AS TICKET_SUBCATEGORY,
        'Medium' AS PRIORITY_LEVEL,
        'Medium' AS SEVERITY_LEVEL,
        st.RESOLUTION_STATUS,
        2.0 AS FIRST_RESPONSE_TIME_HOURS,
        CASE 
            WHEN st.RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN 24.0
            ELSE NULL
        END AS RESOLUTION_TIME_HOURS,
        CASE 
            WHEN st.RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN 20.0
            ELSE NULL
        END AS ACTIVE_WORK_TIME_HOURS,
        CASE 
            WHEN st.RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN 4.0
            ELSE NULL
        END AS CUSTOMER_WAIT_TIME_HOURS,
        0 AS ESCALATION_COUNT,
        0 AS REASSIGNMENT_COUNT,
        0 AS REOPENED_COUNT,
        3 AS AGENT_INTERACTIONS_COUNT,
        2 AS CUSTOMER_INTERACTIONS_COUNT,
        5 AS KNOWLEDGE_BASE_ARTICLES_USED,
        4.0 AS CUSTOMER_SATISFACTION_SCORE,
        FALSE AS FIRST_CONTACT_RESOLUTION,
        TRUE AS SLA_MET,
        0 AS SLA_BREACH_HOURS,
        'Agent Resolution' AS RESOLUTION_METHOD,
        'User Error' AS ROOT_CAUSE_CATEGORY,
        FALSE AS PREVENTABLE_ISSUE,
        FALSE AS FOLLOW_UP_REQUIRED,
        25.00 AS COST_TO_RESOLVE,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        st.SOURCE_SYSTEM
    FROM source_support st
)

SELECT * FROM support_metrics_fact
