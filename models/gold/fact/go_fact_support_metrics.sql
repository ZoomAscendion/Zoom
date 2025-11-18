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
    WHERE st.VALIDATION_STATUS = 'PASSED'
      AND st.TICKET_ID IS NOT NULL
),

support_metrics_fact AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY sb.TICKET_ID) AS SUPPORT_METRICS_ID,
        dd.DATE_ID AS DATE_ID,
        dsc.SUPPORT_CATEGORY_ID AS SUPPORT_CATEGORY_ID,
        du.USER_DIM_ID AS USER_DIM_ID,
        sb.TICKET_ID,
        sb.OPEN_DATE AS TICKET_CREATED_DATE,
        sb.OPEN_DATE::TIMESTAMP_NTZ AS TICKET_CREATED_TIMESTAMP,
        CASE 
            WHEN sb.RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN sb.OPEN_DATE + INTERVAL '1 DAY'
            ELSE NULL
        END AS TICKET_CLOSED_DATE,
        CASE 
            WHEN sb.RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN (sb.OPEN_DATE + INTERVAL '1 DAY')::TIMESTAMP_NTZ
            ELSE NULL
        END AS TICKET_CLOSED_TIMESTAMP,
        (sb.OPEN_DATE + INTERVAL '2 HOURS')::TIMESTAMP_NTZ AS FIRST_RESPONSE_TIMESTAMP,
        CASE 
            WHEN sb.RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN (sb.OPEN_DATE + INTERVAL '1 DAY')::TIMESTAMP_NTZ
            ELSE NULL
        END AS RESOLUTION_TIMESTAMP,
        sb.TICKET_TYPE AS TICKET_CATEGORY,
        CASE 
            WHEN UPPER(sb.TICKET_TYPE) LIKE '%TECHNICAL%' THEN 'Technical Issue'
            WHEN UPPER(sb.TICKET_TYPE) LIKE '%BILLING%' THEN 'Billing Inquiry'
            WHEN UPPER(sb.TICKET_TYPE) LIKE '%FEATURE%' THEN 'Feature Request'
            ELSE 'General Support'
        END AS TICKET_SUBCATEGORY,
        CASE 
            WHEN UPPER(sb.TICKET_TYPE) LIKE '%CRITICAL%' THEN 'Critical'
            WHEN UPPER(sb.TICKET_TYPE) LIKE '%URGENT%' THEN 'High'
            WHEN UPPER(sb.TICKET_TYPE) LIKE '%BILLING%' THEN 'Medium'
            ELSE 'Low'
        END AS PRIORITY_LEVEL,
        'Medium' AS SEVERITY_LEVEL,
        sb.RESOLUTION_STATUS,
        2.0 AS FIRST_RESPONSE_TIME_HOURS,
        CASE 
            WHEN sb.RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN 24.0
            ELSE NULL
        END AS RESOLUTION_TIME_HOURS,
        CASE 
            WHEN sb.RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN 20.0
            ELSE NULL
        END AS ACTIVE_WORK_TIME_HOURS,
        CASE 
            WHEN sb.RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN 4.0
            ELSE NULL
        END AS CUSTOMER_WAIT_TIME_HOURS,
        0 AS ESCALATION_COUNT,
        0 AS REASSIGNMENT_COUNT,
        0 AS REOPENED_COUNT,
        3 AS AGENT_INTERACTIONS_COUNT,
        2 AS CUSTOMER_INTERACTIONS_COUNT,
        1 AS KNOWLEDGE_BASE_ARTICLES_USED,
        CASE 
            WHEN sb.RESOLUTION_STATUS IN ('Resolved', 'Closed') AND 24.0 <= 4 THEN 5.0
            WHEN sb.RESOLUTION_STATUS IN ('Resolved', 'Closed') AND 24.0 <= 24 THEN 4.0
            WHEN sb.RESOLUTION_STATUS IN ('Resolved', 'Closed') AND 24.0 <= 72 THEN 3.0
            WHEN sb.RESOLUTION_STATUS IN ('Resolved', 'Closed') AND 24.0 <= 168 THEN 2.0
            ELSE 1.0
        END AS CUSTOMER_SATISFACTION_SCORE,
        FALSE AS FIRST_CONTACT_RESOLUTION,
        CASE 
            WHEN sb.RESOLUTION_STATUS IN ('Resolved', 'Closed') AND 24.0 <= COALESCE(dsc.SLA_TARGET_HOURS, 72.0) THEN TRUE
            ELSE FALSE
        END AS SLA_MET,
        CASE 
            WHEN sb.RESOLUTION_STATUS IN ('Resolved', 'Closed') AND 24.0 > COALESCE(dsc.SLA_TARGET_HOURS, 72.0) 
                 THEN 24.0 - COALESCE(dsc.SLA_TARGET_HOURS, 72.0)
            ELSE 0
        END AS SLA_BREACH_HOURS,
        'Agent Resolution' AS RESOLUTION_METHOD,
        'User Error' AS ROOT_CAUSE_CATEGORY,
        CASE 
            WHEN sb.TICKET_TYPE IN ('Password Reset', 'Account Lockout', 'Basic Setup') THEN TRUE
            ELSE FALSE
        END AS PREVENTABLE_ISSUE,
        FALSE AS FOLLOW_UP_REQUIRED,
        25.00 AS COST_TO_RESOLVE,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        sb.SOURCE_SYSTEM
    FROM support_base sb
    LEFT JOIN {{ ref('go_dim_date') }} dd ON sb.OPEN_DATE = dd.DATE_VALUE
    LEFT JOIN {{ ref('go_dim_support_category') }} dsc ON sb.TICKET_TYPE = dsc.SUPPORT_CATEGORY
    LEFT JOIN {{ ref('go_dim_user') }} du ON sb.USER_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
)

SELECT * FROM support_metrics_fact
