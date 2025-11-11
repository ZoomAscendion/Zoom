{{
  config(
    materialized='table',
    cluster_by=['SUPPORT_CATEGORY_KEY'],
    tags=['dimension', 'gold']
  )
}}

-- Support Category Dimension Transformation
WITH support_category_data AS (
    SELECT DISTINCT
        {{ dbt_utils.generate_surrogate_key(['TICKET_TYPE']) }} AS SUPPORT_CATEGORY_KEY,
        ROW_NUMBER() OVER (ORDER BY TICKET_TYPE) AS SUPPORT_CATEGORY_ID,
        INITCAP(TRIM(COALESCE(TICKET_TYPE, 'Unknown'))) AS SUPPORT_CATEGORY,
        CASE 
            WHEN UPPER(COALESCE(TICKET_TYPE, '')) LIKE '%TECHNICAL%' THEN 'Technical Issue'
            WHEN UPPER(COALESCE(TICKET_TYPE, '')) LIKE '%BILLING%' THEN 'Billing Inquiry'
            WHEN UPPER(COALESCE(TICKET_TYPE, '')) LIKE '%FEATURE%' THEN 'Feature Request'
            ELSE 'General Support'
        END AS SUPPORT_SUBCATEGORY,
        CASE 
            WHEN UPPER(COALESCE(TICKET_TYPE, '')) LIKE '%CRITICAL%' THEN 'Critical'
            WHEN UPPER(COALESCE(TICKET_TYPE, '')) LIKE '%URGENT%' THEN 'High'
            WHEN UPPER(COALESCE(TICKET_TYPE, '')) LIKE '%BILLING%' THEN 'Medium'
            ELSE 'Low'
        END AS PRIORITY_LEVEL,
        CASE 
            WHEN UPPER(COALESCE(TICKET_TYPE, '')) LIKE '%CRITICAL%' THEN 4.0
            WHEN UPPER(COALESCE(TICKET_TYPE, '')) LIKE '%URGENT%' THEN 24.0
            WHEN UPPER(COALESCE(TICKET_TYPE, '')) LIKE '%BILLING%' THEN 48.0
            ELSE 72.0
        END AS EXPECTED_RESOLUTION_TIME_HOURS,
        CASE 
            WHEN UPPER(COALESCE(TICKET_TYPE, '')) LIKE '%CRITICAL%' THEN TRUE
            ELSE FALSE
        END AS REQUIRES_ESCALATION,
        CASE 
            WHEN UPPER(COALESCE(TICKET_TYPE, '')) LIKE '%BILLING%' OR UPPER(COALESCE(TICKET_TYPE, '')) LIKE '%FEATURE%' THEN TRUE
            ELSE FALSE
        END AS SELF_SERVICE_AVAILABLE,
        CASE 
            WHEN UPPER(COALESCE(TICKET_TYPE, '')) LIKE '%TECHNICAL%' THEN 15
            WHEN UPPER(COALESCE(TICKET_TYPE, '')) LIKE '%BILLING%' THEN 10
            ELSE 5
        END AS KNOWLEDGE_BASE_ARTICLES,
        'Standard resolution steps for ' || COALESCE(TICKET_TYPE, 'Unknown') AS COMMON_RESOLUTION_STEPS,
        CASE 
            WHEN UPPER(COALESCE(TICKET_TYPE, '')) LIKE '%CRITICAL%' THEN 'High'
            WHEN UPPER(COALESCE(TICKET_TYPE, '')) LIKE '%TECHNICAL%' THEN 'Medium'
            ELSE 'Low'
        END AS CUSTOMER_IMPACT_LEVEL,
        CASE 
            WHEN UPPER(COALESCE(TICKET_TYPE, '')) LIKE '%TECHNICAL%' THEN 'Technical Support'
            WHEN UPPER(COALESCE(TICKET_TYPE, '')) LIKE '%BILLING%' THEN 'Billing Department'
            ELSE 'Customer Success'
        END AS DEPARTMENT_RESPONSIBLE,
        CASE 
            WHEN UPPER(COALESCE(TICKET_TYPE, '')) LIKE '%CRITICAL%' THEN 4.0
            WHEN UPPER(COALESCE(TICKET_TYPE, '')) LIKE '%URGENT%' THEN 24.0
            WHEN UPPER(COALESCE(TICKET_TYPE, '')) LIKE '%BILLING%' THEN 48.0
            ELSE 72.0
        END AS SLA_TARGET_HOURS,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        COALESCE(SOURCE_SYSTEM, 'SILVER') AS SOURCE_SYSTEM
    FROM {{ source('silver', 'si_support_tickets') }}
    WHERE COALESCE(VALIDATION_STATUS, '') = 'PASSED'
      AND TICKET_TYPE IS NOT NULL
      AND TRIM(TICKET_TYPE) != ''
)

SELECT * FROM support_category_data
