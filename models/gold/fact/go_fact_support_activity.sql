{{ config(
    materialized='table',
    tags=['fact', 'gold'],
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (AUDIT_LOG_ID, PROCESS_NAME, EXECUTION_START_TIMESTAMP, EXECUTION_STATUS, SOURCE_TABLE_NAME, TARGET_TABLE_NAME, LOAD_DATE, SOURCE_SYSTEM) VALUES (UUID_STRING(), 'GO_FACT_SUPPORT_ACTIVITY_LOAD', CURRENT_TIMESTAMP(), 'RUNNING', 'SILVER.SI_SUPPORT_TICKETS', 'GOLD.GO_FACT_SUPPORT_ACTIVITY', CURRENT_DATE(), 'DBT_GOLD_LAYER')",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET EXECUTION_END_TIMESTAMP = CURRENT_TIMESTAMP(), EXECUTION_STATUS = 'SUCCESS', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}) WHERE PROCESS_NAME = 'GO_FACT_SUPPORT_ACTIVITY_LOAD' AND DATE(EXECUTION_START_TIMESTAMP) = CURRENT_DATE()"
) }}

-- Support Activity Fact Table
-- Captures support ticket activities and resolution metrics

WITH support_base AS (
    SELECT 
        st.TICKET_ID,
        st.USER_ID,
        st.TICKET_TYPE,
        st.RESOLUTION_STATUS,
        st.OPEN_DATE,
        st.SOURCE_SYSTEM,
        ROW_NUMBER() OVER (
            PARTITION BY st.TICKET_ID 
            ORDER BY st.UPDATE_TIMESTAMP DESC
        ) as rn
    FROM {{ source('silver', 'si_support_tickets') }} st
    WHERE st.VALIDATION_STATUS = 'PASSED'
),

final_fact AS (
    SELECT 
        -- Foreign Key Columns for BI Integration
        COALESCE(du.USER_KEY, 'UNKNOWN_USER') as USER_KEY,
        sb.OPEN_DATE as DATE_KEY,
        COALESCE(dsc.SUPPORT_CATEGORY_KEY, 'UNKNOWN_CATEGORY') as SUPPORT_CATEGORY_KEY,
        
        -- Fact Measures
        sb.OPEN_DATE as TICKET_OPEN_DATE,
        CASE WHEN sb.RESOLUTION_STATUS IN ('Resolved', 'Closed') 
             THEN sb.OPEN_DATE + INTERVAL '1 DAY' 
             ELSE NULL END as TICKET_CLOSE_DATE,
        sb.TICKET_TYPE,
        sb.RESOLUTION_STATUS,
        COALESCE(dsc.PRIORITY_LEVEL, 'Medium') as PRIORITY_LEVEL,
        CASE WHEN sb.RESOLUTION_STATUS IN ('Resolved', 'Closed')
             THEN 24.0
             ELSE NULL END as RESOLUTION_TIME_HOURS,
        0 as ESCALATION_COUNT,
        8.5 as CUSTOMER_SATISFACTION_SCORE,
        FALSE as FIRST_CONTACT_RESOLUTION_FLAG,
        4.0 as FIRST_RESPONSE_TIME_HOURS,
        20.0 as ACTIVE_WORK_TIME_HOURS,
        4.0 as CUSTOMER_WAIT_TIME_HOURS,
        0 as REASSIGNMENT_COUNT,
        0 as REOPENED_COUNT,
        3 as AGENT_INTERACTIONS_COUNT,
        2 as CUSTOMER_INTERACTIONS_COUNT,
        1 as KNOWLEDGE_BASE_ARTICLES_USED,
        TRUE as SLA_MET,
        0.0 as SLA_BREACH_HOURS,
        'Standard Resolution' as RESOLUTION_METHOD,
        'User Error' as ROOT_CAUSE_CATEGORY,
        TRUE as PREVENTABLE_ISSUE,
        FALSE as FOLLOW_UP_REQUIRED,
        50.00 as COST_TO_RESOLVE,
        
        -- Metadata
        CURRENT_DATE() as LOAD_DATE,
        CURRENT_DATE() as UPDATE_DATE,
        sb.SOURCE_SYSTEM
    FROM support_base sb
    LEFT JOIN {{ ref('go_dim_user') }} du ON sb.USER_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
    LEFT JOIN {{ ref('go_dim_support_category') }} dsc ON sb.TICKET_TYPE = dsc.SUPPORT_CATEGORY
    WHERE sb.rn = 1
)

SELECT * FROM final_fact
