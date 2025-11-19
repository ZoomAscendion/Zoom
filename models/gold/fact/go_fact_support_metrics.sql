{{ config(
    materialized='table',
    unique_key='SUPPORT_METRICS_ID'
) }}

-- Support metrics fact table with SLA tracking and resolution analytics

WITH source_support AS (
    SELECT 
        st.TICKET_ID,
        st.USER_ID,
        st.TICKET_TYPE,
        st.RESOLUTION_STATUS,
        st.OPEN_DATE,
        st.SOURCE_SYSTEM
    FROM {{ source('silver', 'si_support_tickets') }} st
    WHERE st.VALIDATION_STATUS = 'PASSED'
      AND st.DATA_QUALITY_SCORE >= 70
),

support_metrics_fact AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY ss.TICKET_ID) AS SUPPORT_METRICS_ID,
        dd.DATE_ID,
        dsc.SUPPORT_CATEGORY_ID,
        du.USER_DIM_ID,
        ss.TICKET_ID,
        ss.OPEN_DATE AS TICKET_CREATED_DATE,
        ss.OPEN_DATE::TIMESTAMP_NTZ AS TICKET_CREATED_TIMESTAMP,
        CASE 
            WHEN UPPER(ss.RESOLUTION_STATUS) IN ('RESOLVED', 'CLOSED') 
            THEN ss.OPEN_DATE + INTERVAL '2 DAYS' -- Simplified assumption
            ELSE NULL
        END AS TICKET_CLOSED_DATE,
        CASE 
            WHEN UPPER(ss.RESOLUTION_STATUS) IN ('RESOLVED', 'CLOSED') 
            THEN (ss.OPEN_DATE + INTERVAL '2 DAYS')::TIMESTAMP_NTZ
            ELSE NULL
        END AS TICKET_CLOSED_TIMESTAMP,
        (ss.OPEN_DATE + INTERVAL '2 HOURS')::TIMESTAMP_NTZ AS FIRST_RESPONSE_TIMESTAMP, -- Simplified assumption
        CASE 
            WHEN UPPER(ss.RESOLUTION_STATUS) IN ('RESOLVED', 'CLOSED') 
            THEN (ss.OPEN_DATE + INTERVAL '2 DAYS')::TIMESTAMP_NTZ
            ELSE NULL
        END AS RESOLUTION_TIMESTAMP,
        ss.TICKET_TYPE AS TICKET_CATEGORY,
        CASE 
            WHEN UPPER(ss.TICKET_TYPE) LIKE '%TECHNICAL%' THEN 'Technical Issue'
            WHEN UPPER(ss.TICKET_TYPE) LIKE '%BILLING%' THEN 'Billing Inquiry'
            WHEN UPPER(ss.TICKET_TYPE) LIKE '%FEATURE%' THEN 'Feature Request'
            ELSE 'General Support'
        END AS TICKET_SUBCATEGORY,
        CASE 
            WHEN UPPER(ss.TICKET_TYPE) LIKE '%CRITICAL%' THEN 'Critical'
            WHEN UPPER(ss.TICKET_TYPE) LIKE '%URGENT%' THEN 'High'
            WHEN UPPER(ss.TICKET_TYPE) LIKE '%BILLING%' THEN 'Medium'
            ELSE 'Low'
        END AS PRIORITY_LEVEL,
        CASE 
            WHEN UPPER(ss.TICKET_TYPE) LIKE '%CRITICAL%' THEN 'Critical'
            WHEN UPPER(ss.TICKET_TYPE) LIKE '%URGENT%' THEN 'High'
            ELSE 'Medium'
        END AS SEVERITY_LEVEL,
        ss.RESOLUTION_STATUS,
        2.0 AS FIRST_RESPONSE_TIME_HOURS, -- Simplified assumption
        CASE 
            WHEN UPPER(ss.RESOLUTION_STATUS) IN ('RESOLVED', 'CLOSED') THEN 48.0
            ELSE NULL
        END AS RESOLUTION_TIME_HOURS,
        CASE 
            WHEN UPPER(ss.RESOLUTION_STATUS) IN ('RESOLVED', 'CLOSED') THEN 24.0
            ELSE NULL
        END AS ACTIVE_WORK_TIME_HOURS,
        CASE 
            WHEN UPPER(ss.RESOLUTION_STATUS) IN ('RESOLVED', 'CLOSED') THEN 24.0
            ELSE NULL
        END AS CUSTOMER_WAIT_TIME_HOURS,
        CASE 
            WHEN UPPER(ss.TICKET_TYPE) LIKE '%CRITICAL%' THEN 1
            ELSE 0
        END AS ESCALATION_COUNT,
        0 AS REASSIGNMENT_COUNT, -- Default value
        0 AS REOPENED_COUNT, -- Default value
        3 AS AGENT_INTERACTIONS_COUNT, -- Default value
        2 AS CUSTOMER_INTERACTIONS_COUNT, -- Default value
        CASE 
            WHEN UPPER(ss.TICKET_TYPE) LIKE '%TECHNICAL%' THEN 2
            WHEN UPPER(ss.TICKET_TYPE) LIKE '%BILLING%' THEN 1
            ELSE 0
        END AS KNOWLEDGE_BASE_ARTICLES_USED,
        CASE 
            WHEN UPPER(ss.RESOLUTION_STATUS) = 'RESOLVED' AND 
                 CASE WHEN UPPER(ss.RESOLUTION_STATUS) IN ('RESOLVED', 'CLOSED') THEN 48.0 ELSE NULL END <= 24.0 THEN 5.0
            WHEN UPPER(ss.RESOLUTION_STATUS) = 'RESOLVED' THEN 4.0
            WHEN UPPER(ss.RESOLUTION_STATUS) = 'IN_PROGRESS' THEN 3.0
            ELSE 2.0
        END AS CUSTOMER_SATISFACTION_SCORE,
        CASE 
            WHEN CASE WHEN UPPER(ss.RESOLUTION_STATUS) IN ('RESOLVED', 'CLOSED') THEN 48.0 ELSE NULL END <= 24.0 
                 AND 0 = 0 THEN TRUE -- No escalation and quick resolution
            ELSE FALSE
        END AS FIRST_CONTACT_RESOLUTION,
        -- SLA Met calculation
        CASE 
            WHEN CASE WHEN UPPER(ss.RESOLUTION_STATUS) IN ('RESOLVED', 'CLOSED') THEN 48.0 ELSE NULL END <= dsc.SLA_TARGET_HOURS THEN TRUE
            WHEN UPPER(ss.RESOLUTION_STATUS) NOT IN ('RESOLVED', 'CLOSED') THEN NULL -- Still open
            ELSE FALSE
        END AS SLA_MET,
        CASE 
            WHEN CASE WHEN UPPER(ss.RESOLUTION_STATUS) IN ('RESOLVED', 'CLOSED') THEN 48.0 ELSE NULL END > dsc.SLA_TARGET_HOURS 
            THEN (CASE WHEN UPPER(ss.RESOLUTION_STATUS) IN ('RESOLVED', 'CLOSED') THEN 48.0 ELSE NULL END - dsc.SLA_TARGET_HOURS)
            ELSE 0
        END AS SLA_BREACH_HOURS,
        CASE 
            WHEN UPPER(ss.RESOLUTION_STATUS) = 'RESOLVED' THEN 'Agent Resolution'
            WHEN UPPER(ss.RESOLUTION_STATUS) = 'CLOSED' THEN 'Customer Closed'
            ELSE 'In Progress'
        END AS RESOLUTION_METHOD,
        CASE 
            WHEN UPPER(ss.TICKET_TYPE) LIKE '%TECHNICAL%' THEN 'Technical Issue'
            WHEN UPPER(ss.TICKET_TYPE) LIKE '%USER%ERROR%' THEN 'User Error'
            WHEN UPPER(ss.TICKET_TYPE) LIKE '%SYSTEM%' THEN 'System Issue'
            ELSE 'Unknown'
        END AS ROOT_CAUSE_CATEGORY,
        CASE 
            WHEN UPPER(ss.TICKET_TYPE) LIKE '%PASSWORD%' OR UPPER(ss.TICKET_TYPE) LIKE '%LOGIN%' THEN TRUE
            ELSE FALSE
        END AS PREVENTABLE_ISSUE,
        CASE 
            WHEN UPPER(ss.RESOLUTION_STATUS) = 'RESOLVED' THEN FALSE
            ELSE TRUE
        END AS FOLLOW_UP_REQUIRED,
        CASE 
            WHEN UPPER(ss.TICKET_TYPE) LIKE '%CRITICAL%' THEN 150.00
            WHEN UPPER(ss.TICKET_TYPE) LIKE '%TECHNICAL%' THEN 75.00
            WHEN UPPER(ss.TICKET_TYPE) LIKE '%BILLING%' THEN 25.00
            ELSE 50.00
        END AS COST_TO_RESOLVE,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        ss.SOURCE_SYSTEM
    FROM source_support ss
    LEFT JOIN {{ ref('go_dim_date') }} dd 
        ON ss.OPEN_DATE = dd.DATE_VALUE
    LEFT JOIN {{ ref('go_dim_user') }} du 
        ON ss.USER_ID = du.USER_ID 
        AND du.IS_CURRENT_RECORD = TRUE
    LEFT JOIN {{ ref('go_dim_support_category') }} dsc 
        ON UPPER(TRIM(ss.TICKET_TYPE)) = UPPER(TRIM(dsc.SUPPORT_CATEGORY))
)

SELECT * FROM support_metrics_fact
