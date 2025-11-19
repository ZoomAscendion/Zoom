{{
  config(
    materialized='table',
    cluster_by=['SUPPORT_CATEGORY_ID', 'PRIORITY_LEVEL'],
    tags=['dimension', 'gold'],
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (AUDIT_LOG_ID, PROCESS_NAME, PROCESS_TYPE, EXECUTION_START_TIMESTAMP, EXECUTION_STATUS, SOURCE_TABLE_NAME, TARGET_TABLE_NAME, PROCESS_TRIGGER, EXECUTED_BY, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key(['go_dim_support_category', run_started_at]) }}', 'go_dim_support_category', 'DIMENSION_LOAD', CURRENT_TIMESTAMP(), 'RUNNING', 'SI_SUPPORT_TICKETS', 'GO_DIM_SUPPORT_CATEGORY', 'DBT_RUN', 'DBT_SYSTEM', CURRENT_DATE(), CURRENT_DATE(), 'DBT_GOLD_LAYER'",
    post_hook="INSERT INTO {{ ref('go_audit_log') }} (AUDIT_LOG_ID, PROCESS_NAME, PROCESS_TYPE, EXECUTION_START_TIMESTAMP, EXECUTION_END_TIMESTAMP, EXECUTION_STATUS, SOURCE_TABLE_NAME, TARGET_TABLE_NAME, RECORDS_PROCESSED, PROCESS_TRIGGER, EXECUTED_BY, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key(['go_dim_support_category_complete', run_started_at]) }}', 'go_dim_support_category', 'DIMENSION_LOAD', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 'SUCCESS', 'SI_SUPPORT_TICKETS', 'GO_DIM_SUPPORT_CATEGORY', (SELECT COUNT(*) FROM {{ this }}), 'DBT_RUN', 'DBT_SYSTEM', CURRENT_DATE(), CURRENT_DATE(), 'DBT_GOLD_LAYER'"
  )
}}

-- Support Category Dimension Table
-- Transforms distinct support ticket types into comprehensive support category dimension

WITH source_tickets AS (
    SELECT DISTINCT
        TICKET_TYPE,
        SOURCE_SYSTEM
    FROM {{ source('silver', 'si_support_tickets') }}
    WHERE VALIDATION_STATUS = 'PASSED'
      AND TICKET_TYPE IS NOT NULL
),

support_category_attributes AS (
    SELECT 
        -- Primary Key
        ROW_NUMBER() OVER (ORDER BY TICKET_TYPE) AS SUPPORT_CATEGORY_ID,
        
        -- Support Category Information
        INITCAP(TRIM(TICKET_TYPE)) AS SUPPORT_CATEGORY,
        
        -- Support Subcategory
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%TECHNICAL%' THEN 'Technical Issue'
            WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 'Billing Inquiry'
            WHEN UPPER(TICKET_TYPE) LIKE '%FEATURE%' THEN 'Feature Request'
            ELSE 'General Support'
        END AS SUPPORT_SUBCATEGORY,
        
        -- Priority Level
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN 'Critical'
            WHEN UPPER(TICKET_TYPE) LIKE '%URGENT%' THEN 'High'
            WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 'Medium'
            ELSE 'Low'
        END AS PRIORITY_LEVEL,
        
        -- Expected Resolution Time
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN 4.0
            WHEN UPPER(TICKET_TYPE) LIKE '%URGENT%' THEN 24.0
            WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 48.0
            ELSE 72.0
        END AS EXPECTED_RESOLUTION_TIME_HOURS,
        
        -- Escalation Requirements
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN TRUE
            ELSE FALSE
        END AS REQUIRES_ESCALATION,
        
        -- Self-Service Availability
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' OR UPPER(TICKET_TYPE) LIKE '%FEATURE%' THEN TRUE
            ELSE FALSE
        END AS SELF_SERVICE_AVAILABLE,
        
        -- Knowledge Base Articles
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%TECHNICAL%' THEN 15
            WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 10
            ELSE 5
        END AS KNOWLEDGE_BASE_ARTICLES,
        
        -- Resolution Steps
        'Standard resolution steps for ' || TICKET_TYPE AS COMMON_RESOLUTION_STEPS,
        
        -- Customer Impact Level
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN 'High'
            WHEN UPPER(TICKET_TYPE) LIKE '%TECHNICAL%' THEN 'Medium'
            ELSE 'Low'
        END AS CUSTOMER_IMPACT_LEVEL,
        
        -- Department Responsible
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%TECHNICAL%' THEN 'Technical Support'
            WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 'Billing Department'
            ELSE 'Customer Success'
        END AS DEPARTMENT_RESPONSIBLE,
        
        -- SLA Target Hours
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN 4.0
            WHEN UPPER(TICKET_TYPE) LIKE '%URGENT%' THEN 24.0
            WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 48.0
            ELSE 72.0
        END AS SLA_TARGET_HOURS,
        
        -- Metadata
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        SOURCE_SYSTEM
    FROM source_tickets
)

SELECT * FROM support_category_attributes
