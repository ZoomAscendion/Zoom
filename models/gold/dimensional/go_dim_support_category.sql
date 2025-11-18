{{ config(
    materialized='table',
    tags=['dimension', 'gold']
) }}

-- Support Category Dimension Transformation
-- Creates support category dimension from ticket types

WITH source_support AS (
    SELECT DISTINCT
        TICKET_TYPE,
        SOURCE_SYSTEM,
        ROW_NUMBER() OVER (
            PARTITION BY UPPER(TRIM(TICKET_TYPE)) 
            ORDER BY UPDATE_TIMESTAMP DESC
        ) as rn
    FROM {{ source('silver', 'si_support_tickets') }}
    WHERE VALIDATION_STATUS = 'PASSED'
      AND TICKET_TYPE IS NOT NULL
),

transformed_support AS (
    SELECT 
        MD5(UPPER(TRIM(TICKET_TYPE))) as SUPPORT_CATEGORY_KEY,
        INITCAP(TRIM(TICKET_TYPE)) as SUPPORT_CATEGORY,
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%TECHNICAL%' THEN 'Technical Issue'
            WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 'Billing Inquiry'
            WHEN UPPER(TICKET_TYPE) LIKE '%FEATURE%' THEN 'Feature Request'
            ELSE 'General Support'
        END as SUPPORT_SUBCATEGORY,
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN 'Critical'
            WHEN UPPER(TICKET_TYPE) LIKE '%URGENT%' THEN 'High'
            WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 'Medium'
            ELSE 'Low'
        END as PRIORITY_LEVEL,
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN 4.0
            WHEN UPPER(TICKET_TYPE) LIKE '%URGENT%' THEN 24.0
            WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 48.0
            ELSE 72.0
        END as EXPECTED_RESOLUTION_TIME_HOURS,
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN TRUE
            ELSE FALSE
        END as REQUIRES_ESCALATION,
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' OR UPPER(TICKET_TYPE) LIKE '%FEATURE%' THEN TRUE
            ELSE FALSE
        END as SELF_SERVICE_AVAILABLE,
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%TECHNICAL%' THEN 15
            WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 10
            ELSE 5
        END as KNOWLEDGE_BASE_ARTICLES,
        'Standard resolution steps for ' || TICKET_TYPE as COMMON_RESOLUTION_STEPS,
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN 'High'
            WHEN UPPER(TICKET_TYPE) LIKE '%TECHNICAL%' THEN 'Medium'
            ELSE 'Low'
        END as CUSTOMER_IMPACT_LEVEL,
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%TECHNICAL%' THEN 'Technical Support'
            WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 'Billing Department'
            ELSE 'Customer Success'
        END as DEPARTMENT_RESPONSIBLE,
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN 4.0
            WHEN UPPER(TICKET_TYPE) LIKE '%URGENT%' THEN 24.0
            WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 48.0
            ELSE 72.0
        END as SLA_TARGET_HOURS,
        CURRENT_DATE() as LOAD_DATE,
        CURRENT_DATE() as UPDATE_DATE,
        SOURCE_SYSTEM
    FROM source_support
    WHERE rn = 1
)

SELECT * FROM transformed_support
