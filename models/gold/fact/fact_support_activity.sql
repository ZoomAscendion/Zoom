{{
  config(
    materialized='table',
    cluster_by=['DATE_KEY', 'SUPPORT_CATEGORY_KEY'],
    tags=['fact', 'gold']
  )
}}

-- Support Activity Fact Table
WITH support_base AS (
    SELECT 
        st.TICKET_ID,
        st.USER_ID,
        st.TICKET_TYPE,
        st.RESOLUTION_STATUS,
        st.OPEN_DATE,
        st.SOURCE_SYSTEM
    FROM {{ source('silver', 'si_support_tickets') }} st
    WHERE COALESCE(st.VALIDATION_STATUS, '') = 'PASSED'
      AND st.TICKET_ID IS NOT NULL
      AND st.USER_ID IS NOT NULL
),

fact_data AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY sb.TICKET_ID) AS SUPPORT_ACTIVITY_ID,
        -- Foreign Keys
        du.USER_KEY,
        dd.DATE_KEY,
        dsc.SUPPORT_CATEGORY_KEY,
        -- Fact Measures
        sb.OPEN_DATE AS TICKET_OPEN_DATE,
        CASE 
            WHEN sb.RESOLUTION_STATUS IN ('Resolved', 'Closed') 
            THEN sb.OPEN_DATE + INTERVAL '1 DAY' -- Placeholder for actual close date
            ELSE NULL 
        END AS TICKET_CLOSE_DATE,
        COALESCE(sb.TICKET_TYPE, 'Unknown') AS TICKET_TYPE,
        COALESCE(sb.RESOLUTION_STATUS, 'Open') AS RESOLUTION_STATUS,
        COALESCE(dsc.PRIORITY_LEVEL, 'Medium') AS PRIORITY_LEVEL,
        CASE 
            WHEN sb.RESOLUTION_STATUS IN ('Resolved', 'Closed')
            THEN 24.0 -- Default 24 hours resolution time
            ELSE NULL 
        END AS RESOLUTION_TIME_HOURS,
        0 AS ESCALATION_COUNT, -- Default value
        CASE 
            WHEN sb.RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN 4.0
            ELSE NULL
        END AS CUSTOMER_SATISFACTION_SCORE,
        FALSE AS FIRST_CONTACT_RESOLUTION_FLAG, -- Default value
        4.0 AS FIRST_RESPONSE_TIME_HOURS, -- Default value
        CASE 
            WHEN sb.RESOLUTION_STATUS IN ('Resolved', 'Closed')
            THEN 20.0 -- Default active work time
            ELSE NULL 
        END AS ACTIVE_WORK_TIME_HOURS,
        CASE 
            WHEN sb.RESOLUTION_STATUS IN ('Resolved', 'Closed')
            THEN 4.0 -- Default customer wait time
            ELSE NULL 
        END AS CUSTOMER_WAIT_TIME_HOURS,
        0 AS REASSIGNMENT_COUNT, -- Default value
        0 AS REOPENED_COUNT, -- Default value
        3 AS AGENT_INTERACTIONS_COUNT, -- Default value
        2 AS CUSTOMER_INTERACTIONS_COUNT, -- Default value
        1 AS KNOWLEDGE_BASE_ARTICLES_USED, -- Default value
        CASE 
            WHEN sb.RESOLUTION_STATUS IN ('Resolved', 'Closed') AND dsc.SLA_TARGET_HOURS >= 24.0
            THEN TRUE 
            ELSE FALSE 
        END AS SLA_MET,
        CASE 
            WHEN sb.RESOLUTION_STATUS IN ('Resolved', 'Closed') AND dsc.SLA_TARGET_HOURS < 24.0
            THEN 24.0 - dsc.SLA_TARGET_HOURS
            ELSE 0.0 
        END AS SLA_BREACH_HOURS,
        'Standard Resolution' AS RESOLUTION_METHOD,
        CASE 
            WHEN UPPER(sb.TICKET_TYPE) LIKE '%TECHNICAL%' THEN 'Technical Issue'
            WHEN UPPER(sb.TICKET_TYPE) LIKE '%BILLING%' THEN 'Billing Issue'
            ELSE 'General Issue'
        END AS ROOT_CAUSE_CATEGORY,
        CASE 
            WHEN sb.TICKET_TYPE IN ('Password Reset', 'Account Lockout', 'Basic Setup') THEN TRUE
            ELSE FALSE
        END AS PREVENTABLE_ISSUE,
        FALSE AS FOLLOW_UP_REQUIRED, -- Default value
        25.00 AS COST_TO_RESOLVE, -- Default value
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        COALESCE(sb.SOURCE_SYSTEM, 'SILVER_ETL') AS SOURCE_SYSTEM
    FROM support_base sb
    LEFT JOIN {{ ref('dim_user') }} du ON sb.USER_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
    LEFT JOIN {{ ref('dim_date') }} dd ON sb.OPEN_DATE = dd.DATE_KEY
    LEFT JOIN {{ ref('dim_support_category') }} dsc ON {{ dbt_utils.generate_surrogate_key(['sb.TICKET_TYPE']) }} = dsc.SUPPORT_CATEGORY_KEY
    WHERE du.USER_KEY IS NOT NULL
      AND dd.DATE_KEY IS NOT NULL
      AND dsc.SUPPORT_CATEGORY_KEY IS NOT NULL
)

SELECT * FROM fact_data
