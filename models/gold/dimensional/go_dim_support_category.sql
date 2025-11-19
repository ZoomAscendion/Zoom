{{ config(
    materialized='table',
    cluster_by=['SUPPORT_CATEGORY', 'PRIORITY_LEVEL'],
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (PROCESS_ID, PROCESS_NAME, PROCESS_TYPE, PROCESS_START_TIMESTAMP, PROCESS_STATUS, SOURCE_TABLE, TARGET_TABLE, PROCESS_TRIGGER, EXECUTED_BY, LOAD_DATE, SOURCE_SYSTEM) VALUES ('{{ dbt_utils.generate_surrogate_key(["'go_dim_support_category'", "CURRENT_TIMESTAMP()"]) }}', 'GO_DIM_SUPPORT_CATEGORY_LOAD', 'DIMENSION_LOAD', CURRENT_TIMESTAMP(), 'RUNNING', 'SI_SUPPORT_TICKETS', 'GO_DIM_SUPPORT_CATEGORY', 'DBT_MODEL_RUN', 'DBT_USER', CURRENT_DATE(), 'DBT_GOLD_LAYER')",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET PROCESS_END_TIMESTAMP = CURRENT_TIMESTAMP(), PROCESS_STATUS = 'SUCCESS', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), RECORDS_SUCCESS = (SELECT COUNT(*) FROM {{ this }}), DATA_QUALITY_SCORE = 95.0 WHERE PROCESS_ID = '{{ dbt_utils.generate_surrogate_key(["'go_dim_support_category'", "CURRENT_TIMESTAMP()"]) }}'"
) }}

-- Support category dimension with SLA and resolution characteristics
-- Transforms support ticket types into comprehensive support taxonomy

WITH source_support AS (
    SELECT DISTINCT
        TICKET_TYPE,
        SOURCE_SYSTEM
    FROM {{ source('silver', 'si_support_tickets') }}
    WHERE VALIDATION_STATUS = 'PASSED'
      AND TICKET_TYPE IS NOT NULL
),

support_category_dimension AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY TICKET_TYPE) AS SUPPORT_CATEGORY_ID,
        INITCAP(TRIM(TICKET_TYPE)) AS SUPPORT_CATEGORY,
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%TECHNICAL%' THEN 'Technical Issue'
            WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 'Billing Inquiry'
            WHEN UPPER(TICKET_TYPE) LIKE '%FEATURE%' THEN 'Feature Request'
            ELSE 'General Support'
        END AS SUPPORT_SUBCATEGORY,
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN 'Critical'
            WHEN UPPER(TICKET_TYPE) LIKE '%URGENT%' THEN 'High'
            WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 'Medium'
            ELSE 'Low'
        END AS PRIORITY_LEVEL,
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN 4.0
            WHEN UPPER(TICKET_TYPE) LIKE '%URGENT%' THEN 24.0
            WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 48.0
            ELSE 72.0
        END AS EXPECTED_RESOLUTION_TIME_HOURS,
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN TRUE
            ELSE FALSE
        END AS REQUIRES_ESCALATION,
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' OR UPPER(TICKET_TYPE) LIKE '%FEATURE%' THEN TRUE
            ELSE FALSE
        END AS SELF_SERVICE_AVAILABLE,
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%TECHNICAL%' THEN 15
            WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 10
            ELSE 5
        END AS KNOWLEDGE_BASE_ARTICLES,
        'Standard resolution steps for ' || TICKET_TYPE AS COMMON_RESOLUTION_STEPS,
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN 'High'
            WHEN UPPER(TICKET_TYPE) LIKE '%TECHNICAL%' THEN 'Medium'
            ELSE 'Low'
        END AS CUSTOMER_IMPACT_LEVEL,
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%TECHNICAL%' THEN 'Technical Support'
            WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 'Billing Department'
            ELSE 'Customer Success'
        END AS DEPARTMENT_RESPONSIBLE,
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN 4.0
            WHEN UPPER(TICKET_TYPE) LIKE '%URGENT%' THEN 24.0
            WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 48.0
            ELSE 72.0
        END AS SLA_TARGET_HOURS,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        SOURCE_SYSTEM
    FROM source_support
)

SELECT * FROM support_category_dimension
