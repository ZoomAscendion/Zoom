{{ config(
    materialized='table'
) }}

-- Gold Dimension: Support Category Dimension
-- Description: Support ticket categories and characteristics

WITH source_tickets AS (
    SELECT DISTINCT 
        TICKET_TYPE,
        SOURCE_SYSTEM
    FROM {{ source('silver', 'si_support_tickets') }}
    WHERE TICKET_TYPE IS NOT NULL
),

support_categorization AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY TICKET_TYPE) AS SUPPORT_CATEGORY_ID,
        TICKET_TYPE AS SUPPORT_CATEGORY,
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%TECHNICAL%' THEN 'Technical'
            WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 'Billing'
            WHEN UPPER(TICKET_TYPE) LIKE '%FEATURE%' THEN 'Feature Request'
            WHEN UPPER(TICKET_TYPE) LIKE '%ACCOUNT%' THEN 'Account'
            ELSE 'General'
        END AS SUPPORT_SUBCATEGORY,
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN 'Critical'
            WHEN UPPER(TICKET_TYPE) LIKE '%HIGH%' THEN 'High'
            WHEN UPPER(TICKET_TYPE) LIKE '%MEDIUM%' THEN 'Medium'
            ELSE 'Low'
        END AS PRIORITY_LEVEL,
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN 4
            WHEN UPPER(TICKET_TYPE) LIKE '%HIGH%' THEN 24
            WHEN UPPER(TICKET_TYPE) LIKE '%MEDIUM%' THEN 72
            ELSE 168
        END AS EXPECTED_RESOLUTION_HOURS,
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' OR UPPER(TICKET_TYPE) LIKE '%HIGH%' THEN TRUE
            ELSE FALSE
        END AS REQUIRES_ESCALATION,
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' OR UPPER(TICKET_TYPE) LIKE '%ACCOUNT%' THEN TRUE
            ELSE FALSE
        END AS SELF_SERVICE_AVAILABLE,
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%TECHNICAL%' THEN TRUE
            ELSE FALSE
        END AS SPECIALIST_REQUIRED,
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%TECHNICAL%' THEN 'High'
            WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 'Low'
            ELSE 'Medium'
        END AS CATEGORY_COMPLEXITY,
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN 'High'
            WHEN UPPER(TICKET_TYPE) LIKE '%HIGH%' THEN 'Medium'
            ELSE 'Low'
        END AS CUSTOMER_IMPACT_LEVEL,
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%TECHNICAL%' THEN 'Remote Support'
            WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 'Self Service'
            ELSE 'Email Support'
        END AS RESOLUTION_METHOD,
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%TECHNICAL%' THEN 50
            WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 20
            ELSE 10
        END AS KNOWLEDGE_BASE_ARTICLES,
        CURRENT_DATE AS LOAD_DATE,
        CURRENT_DATE AS UPDATE_DATE,
        COALESCE(SOURCE_SYSTEM, 'UNKNOWN') AS SOURCE_SYSTEM
    FROM source_tickets
)

SELECT * FROM support_categorization
