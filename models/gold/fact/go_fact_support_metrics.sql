{{ config(
    materialized='table'
) }}

-- Support metrics fact table transformation from Silver to Gold layer
WITH support_base AS (
    SELECT 
        st.TICKET_ID,
        st.USER_ID,
        st.TICKET_TYPE,
        st.RESOLUTION_STATUS,
        st.OPEN_DATE,
        st.SOURCE_SYSTEM
    FROM {{ source('silver', 'si_support_tickets') }} st
    WHERE st.TICKET_ID IS NOT NULL
),

support_metrics_fact AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY sb.TICKET_ID) AS SUPPORT_METRICS_ID,
        COALESCE(dd.DATE_ID, 1) AS DATE_ID,
        COALESCE(dsc.SUPPORT_CATEGORY_ID, 1) AS SUPPORT_CATEGORY_ID,
        COALESCE(du.USER_DIM_ID, 1) AS USER_DIM_ID,
        sb.TICKET_ID,
        COALESCE(sb.OPEN_DATE, CURRENT_DATE()) AS TICKET_CREATED_DATE,
        COALESCE(sb.OPEN_DATE, CURRENT_DATE())::TIMESTAMP_NTZ AS TICKET_CREATED_TIMESTAMP,
        CASE 
            WHEN COALESCE(sb.RESOLUTION_STATUS, 'Open') IN ('Resolved', 'Closed') THEN COALESCE(sb.OPEN_DATE, CURRENT_DATE()) + INTERVAL '1 DAY'
            ELSE NULL
        END AS TICKET_CLOSED_DATE,
        CASE 
            WHEN COALESCE(sb.RESOLUTION_STATUS, 'Open') IN ('Resolved', 'Closed') THEN (COALESCE(sb.OPEN_DATE, CURRENT_DATE()) + INTERVAL '1 DAY')::TIMESTAMP_NTZ
            ELSE NULL
        END AS TICKET_CLOSED_TIMESTAMP,
        (COALESCE(sb.OPEN_DATE, CURRENT_DATE()) + INTERVAL '2 HOURS')::TIMESTAMP_NTZ AS FIRST_RESPONSE_TIMESTAMP,
        CASE 
            WHEN COALESCE(sb.RESOLUTION_STATUS, 'Open') IN ('Resolved', 'Closed') THEN (COALESCE(sb.OPEN_DATE, CURRENT_DATE()) + INTERVAL '1 DAY')::TIMESTAMP_NTZ
            ELSE NULL
        END AS RESOLUTION_TIMESTAMP,
        COALESCE(sb.TICKET_TYPE, 'General') AS TICKET_CATEGORY,
        'General Support' AS TICKET_SUBCATEGORY,
        'Medium' AS PRIORITY_LEVEL,
        'Medium' AS SEVERITY_LEVEL,
        COALESCE(sb.RESOLUTION_STATUS, 'Open') AS RESOLUTION_STATUS,
        2.0 AS FIRST_RESPONSE_TIME_HOURS,
        CASE 
            WHEN COALESCE(sb.RESOLUTION_STATUS, 'Open') IN ('Resolved', 'Closed') THEN 24.0
            ELSE NULL
        END AS RESOLUTION_TIME_HOURS,
        CASE 
            WHEN COALESCE(sb.RESOLUTION_STATUS, 'Open') IN ('Resolved', 'Closed') THEN 20.0
            ELSE NULL
        END AS ACTIVE_WORK_TIME_HOURS,
        CASE 
            WHEN COALESCE(sb.RESOLUTION_STATUS, 'Open') IN ('Resolved', 'Closed') THEN 4.0
            ELSE NULL
        END AS CUSTOMER_WAIT_TIME_HOURS,
        0 AS ESCALATION_COUNT,
        0 AS REASSIGNMENT_COUNT,
        0 AS REOPENED_COUNT,
        3 AS AGENT_INTERACTIONS_COUNT,
        2 AS CUSTOMER_INTERACTIONS_COUNT,
        1 AS KNOWLEDGE_BASE_ARTICLES_USED,
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
        COALESCE(sb.SOURCE_SYSTEM, 'UNKNOWN') AS SOURCE_SYSTEM
    FROM support_base sb
    LEFT JOIN {{ ref('go_dim_date') }} dd ON COALESCE(sb.OPEN_DATE, CURRENT_DATE()) = dd.DATE_VALUE
    LEFT JOIN {{ ref('go_dim_support_category') }} dsc ON COALESCE(sb.TICKET_TYPE, 'General') = dsc.SUPPORT_CATEGORY
    LEFT JOIN {{ ref('go_dim_user') }} du ON sb.USER_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
)

SELECT * FROM support_metrics_fact
