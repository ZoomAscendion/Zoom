{{
  config(
    materialized='table',
    cluster_by=['DATE_ID', 'SUPPORT_CATEGORY_ID', 'USER_DIM_ID'],
    tags=['fact', 'gold']
  )
}}

-- Support Metrics Fact Table
-- Captures detailed support ticket metrics and resolution performance with dimensional relationships

WITH support_tickets_base AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        COALESCE(TICKET_TYPE, 'Unknown') AS TICKET_TYPE,
        COALESCE(RESOLUTION_STATUS, 'Open') AS RESOLUTION_STATUS,
        OPEN_DATE,
        COALESCE(SOURCE_SYSTEM, 'UNKNOWN') AS SOURCE_SYSTEM
    FROM {{ source('silver', 'si_support_tickets') }}
    WHERE COALESCE(VALIDATION_STATUS, 'PASSED') = 'PASSED'
),

support_metrics_facts AS (
    SELECT 
        -- Surrogate Key
        {{ dbt_utils.generate_surrogate_key(['stb.TICKET_ID']) }} AS SUPPORT_METRICS_ID,
        
        -- Foreign Keys
        COALESCE(dd.DATE_ID, 1) AS DATE_ID,
        COALESCE(dsc.SUPPORT_CATEGORY_ID, 1) AS SUPPORT_CATEGORY_ID,
        COALESCE(du.USER_DIM_ID, '1') AS USER_DIM_ID,
        
        -- Ticket Information
        stb.TICKET_ID,
        COALESCE(stb.OPEN_DATE, CURRENT_DATE()) AS TICKET_CREATED_DATE,
        COALESCE(stb.OPEN_DATE, CURRENT_DATE())::TIMESTAMP_NTZ AS TICKET_CREATED_TIMESTAMP,
        
        -- Resolution Information
        CASE 
            WHEN UPPER(stb.RESOLUTION_STATUS) IN ('RESOLVED', 'CLOSED') 
            THEN COALESCE(stb.OPEN_DATE, CURRENT_DATE()) + INTERVAL '1 DAY' -- Placeholder for actual close date
            ELSE NULL 
        END AS TICKET_CLOSED_DATE,
        
        CASE 
            WHEN UPPER(stb.RESOLUTION_STATUS) IN ('RESOLVED', 'CLOSED') 
            THEN (COALESCE(stb.OPEN_DATE, CURRENT_DATE()) + INTERVAL '1 DAY')::TIMESTAMP_NTZ
            ELSE NULL 
        END AS TICKET_CLOSED_TIMESTAMP,
        
        -- Response and Resolution Times
        (COALESCE(stb.OPEN_DATE, CURRENT_DATE()) + INTERVAL '2 HOURS')::TIMESTAMP_NTZ AS FIRST_RESPONSE_TIMESTAMP, -- Placeholder
        
        CASE 
            WHEN UPPER(stb.RESOLUTION_STATUS) IN ('RESOLVED', 'CLOSED') 
            THEN (COALESCE(stb.OPEN_DATE, CURRENT_DATE()) + INTERVAL '1 DAY')::TIMESTAMP_NTZ
            ELSE NULL 
        END AS RESOLUTION_TIMESTAMP,
        
        -- Ticket Categories
        stb.TICKET_TYPE AS TICKET_CATEGORY,
        
        CASE 
            WHEN UPPER(stb.TICKET_TYPE) LIKE '%TECHNICAL%' THEN 'Technical Issue'
            WHEN UPPER(stb.TICKET_TYPE) LIKE '%BILLING%' THEN 'Billing Inquiry'
            WHEN UPPER(stb.TICKET_TYPE) LIKE '%FEATURE%' THEN 'Feature Request'
            ELSE 'General Support'
        END AS TICKET_SUBCATEGORY,
        
        -- Priority and Severity
        CASE 
            WHEN UPPER(stb.TICKET_TYPE) LIKE '%CRITICAL%' THEN 'Critical'
            WHEN UPPER(stb.TICKET_TYPE) LIKE '%URGENT%' THEN 'High'
            WHEN UPPER(stb.TICKET_TYPE) LIKE '%BILLING%' THEN 'Medium'
            ELSE 'Low'
        END AS PRIORITY_LEVEL,
        
        CASE 
            WHEN UPPER(stb.TICKET_TYPE) LIKE '%CRITICAL%' THEN 'High'
            WHEN UPPER(stb.TICKET_TYPE) LIKE '%URGENT%' THEN 'Medium'
            ELSE 'Low'
        END AS SEVERITY_LEVEL,
        
        stb.RESOLUTION_STATUS,
        
        -- Time Metrics
        2.0 AS FIRST_RESPONSE_TIME_HOURS, -- Placeholder
        
        CASE 
            WHEN UPPER(stb.RESOLUTION_STATUS) IN ('RESOLVED', 'CLOSED')
            THEN DATEDIFF('hour', COALESCE(stb.OPEN_DATE, CURRENT_DATE()), COALESCE(stb.OPEN_DATE, CURRENT_DATE()) + INTERVAL '1 DAY')
            ELSE NULL
        END AS RESOLUTION_TIME_HOURS,
        
        CASE 
            WHEN UPPER(stb.RESOLUTION_STATUS) IN ('RESOLVED', 'CLOSED')
            THEN DATEDIFF('hour', COALESCE(stb.OPEN_DATE, CURRENT_DATE()), COALESCE(stb.OPEN_DATE, CURRENT_DATE()) + INTERVAL '1 DAY') * 0.8
            ELSE NULL
        END AS ACTIVE_WORK_TIME_HOURS,
        
        CASE 
            WHEN UPPER(stb.RESOLUTION_STATUS) IN ('RESOLVED', 'CLOSED')
            THEN DATEDIFF('hour', COALESCE(stb.OPEN_DATE, CURRENT_DATE()), COALESCE(stb.OPEN_DATE, CURRENT_DATE()) + INTERVAL '1 DAY') * 0.2
            ELSE NULL
        END AS CUSTOMER_WAIT_TIME_HOURS,
        
        -- Interaction Metrics
        0 AS ESCALATION_COUNT, -- Default value
        0 AS REASSIGNMENT_COUNT, -- Default value
        0 AS REOPENED_COUNT, -- Default value
        3 AS AGENT_INTERACTIONS_COUNT, -- Default value
        2 AS CUSTOMER_INTERACTIONS_COUNT, -- Default value
        1 AS KNOWLEDGE_BASE_ARTICLES_USED, -- Default value
        
        -- Quality Metrics
        CASE 
            WHEN DATEDIFF('hour', COALESCE(stb.OPEN_DATE, CURRENT_DATE()), COALESCE(stb.OPEN_DATE, CURRENT_DATE()) + INTERVAL '1 DAY') <= 4 THEN 5.0
            WHEN DATEDIFF('hour', COALESCE(stb.OPEN_DATE, CURRENT_DATE()), COALESCE(stb.OPEN_DATE, CURRENT_DATE()) + INTERVAL '1 DAY') <= 24 THEN 4.0
            WHEN DATEDIFF('hour', COALESCE(stb.OPEN_DATE, CURRENT_DATE()), COALESCE(stb.OPEN_DATE, CURRENT_DATE()) + INTERVAL '1 DAY') <= 72 THEN 3.0
            WHEN DATEDIFF('hour', COALESCE(stb.OPEN_DATE, CURRENT_DATE()), COALESCE(stb.OPEN_DATE, CURRENT_DATE()) + INTERVAL '1 DAY') <= 168 THEN 2.0
            ELSE 1.0
        END AS CUSTOMER_SATISFACTION_SCORE,
        
        FALSE AS FIRST_CONTACT_RESOLUTION, -- Default value
        
        -- SLA Compliance
        CASE 
            WHEN DATEDIFF('hour', COALESCE(stb.OPEN_DATE, CURRENT_DATE()), COALESCE(stb.OPEN_DATE, CURRENT_DATE()) + INTERVAL '1 DAY') <= COALESCE(dsc.SLA_TARGET_HOURS, 72)
            THEN TRUE 
            ELSE FALSE 
        END AS SLA_MET,
        
        CASE 
            WHEN DATEDIFF('hour', COALESCE(stb.OPEN_DATE, CURRENT_DATE()), COALESCE(stb.OPEN_DATE, CURRENT_DATE()) + INTERVAL '1 DAY') > COALESCE(dsc.SLA_TARGET_HOURS, 72)
            THEN DATEDIFF('hour', COALESCE(stb.OPEN_DATE, CURRENT_DATE()), COALESCE(stb.OPEN_DATE, CURRENT_DATE()) + INTERVAL '1 DAY') - COALESCE(dsc.SLA_TARGET_HOURS, 72)
            ELSE 0
        END AS SLA_BREACH_HOURS,
        
        -- Resolution Details
        'Agent Resolution' AS RESOLUTION_METHOD, -- Default value
        'User Error' AS ROOT_CAUSE_CATEGORY, -- Default value
        
        CASE 
            WHEN UPPER(stb.TICKET_TYPE) IN ('PASSWORD_RESET', 'ACCOUNT_LOCKOUT', 'BASIC_SETUP') THEN TRUE
            ELSE FALSE
        END AS PREVENTABLE_ISSUE,
        
        FALSE AS FOLLOW_UP_REQUIRED, -- Default value
        50.00 AS COST_TO_RESOLVE, -- Default value
        
        -- Metadata
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        stb.SOURCE_SYSTEM
    FROM support_tickets_base stb
    LEFT JOIN {{ ref('go_dim_date') }} dd ON COALESCE(stb.OPEN_DATE, CURRENT_DATE()) = dd.DATE_VALUE
    LEFT JOIN {{ ref('go_dim_user') }} du ON stb.USER_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
    LEFT JOIN {{ ref('go_dim_support_category') }} dsc ON stb.TICKET_TYPE = dsc.SUPPORT_CATEGORY
)

SELECT * FROM support_metrics_facts
