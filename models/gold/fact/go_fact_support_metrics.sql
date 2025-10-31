{{ config(
    materialized='table',
    cluster_by=['DATE_KEY', 'SUPPORT_CATEGORY_KEY']
) }}

-- Support Metrics Fact Table
WITH support_base AS (
    SELECT 
        st.TICKET_ID,
        st.USER_ID,
        st.TICKET_TYPE,
        st.PRIORITY_LEVEL,
        st.OPEN_DATE,
        st.CLOSE_DATE,
        st.RESOLUTION_STATUS,
        st.RESOLUTION_TIME_HOURS,
        st.DATA_QUALITY_SCORE,
        st.SOURCE_SYSTEM
    FROM {{ source('silver', 'si_support_tickets') }} st
    WHERE st.DATA_QUALITY_SCORE >= 0.8
      AND st.RESOLUTION_STATUS IN ('Resolved', 'Closed')
),

user_info AS (
    SELECT 
        USER_ID,
        PLAN_TYPE
    FROM {{ source('silver', 'si_users') }}
    WHERE DATA_QUALITY_SCORE >= 0.8
),

fact_support_metrics AS (
    SELECT 
        CONCAT('FACT_SUPP_', st.TICKET_ID, '_', TO_CHAR(st.OPEN_DATE, 'YYYYMMDD')) AS FACT_SUPPORT_METRICS_ID,
        st.OPEN_DATE AS DATE_KEY,
        st.USER_ID AS USER_KEY,
        CONCAT(st.TICKET_TYPE, '_', st.PRIORITY_LEVEL) AS SUPPORT_CATEGORY_KEY,
        st.OPEN_DATE AS TICKET_DATE,
        COALESCE(st.RESOLUTION_TIME_HOURS, 0) AS RESOLUTION_TIME_HOURS,
        st.TICKET_TYPE,
        st.PRIORITY_LEVEL,
        st.RESOLUTION_STATUS,
        CASE WHEN st.RESOLUTION_TIME_HOURS <= 4 THEN TRUE ELSE FALSE END AS FIRST_CONTACT_RESOLUTION_FLAG,
        CASE 
            WHEN (st.PRIORITY_LEVEL = 'Critical' AND st.RESOLUTION_TIME_HOURS > 4) 
                OR (st.PRIORITY_LEVEL = 'High' AND st.RESOLUTION_TIME_HOURS > 24) 
                OR (st.PRIORITY_LEVEL = 'Medium' AND st.RESOLUTION_TIME_HOURS > 72) 
                OR (st.PRIORITY_LEVEL = 'Low' AND st.RESOLUTION_TIME_HOURS > 168) 
            THEN TRUE 
            ELSE FALSE 
        END AS ESCALATION_FLAG,
        COALESCE(u.PLAN_TYPE, 'Unknown') AS CUSTOMER_PLAN_TYPE,
        CASE 
            WHEN st.RESOLUTION_TIME_HOURS <= 2 THEN 5
            WHEN st.RESOLUTION_TIME_HOURS <= 8 THEN 4
            WHEN st.RESOLUTION_TIME_HOURS <= 24 THEN 3
            WHEN st.RESOLUTION_TIME_HOURS <= 72 THEN 2
            ELSE 1
        END AS SATISFACTION_SCORE,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        'SILVER_LAYER' AS SOURCE_SYSTEM
    FROM support_base st
    LEFT JOIN user_info u ON st.USER_ID = u.USER_ID
)

SELECT * FROM fact_support_metrics
