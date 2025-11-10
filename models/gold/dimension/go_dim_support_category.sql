{{ config(
    materialized='table',
    tags=['dimension'],
    cluster_by=['SUPPORT_CATEGORY', 'PRIORITY_LEVEL']
) }}

-- Support category dimension with comprehensive support characteristics
-- Transforms Silver support ticket data into business-ready dimensional format

WITH support_base AS (
    SELECT DISTINCT
        st.ticket_type
    FROM {{ source('silver', 'si_support_tickets') }} st
    WHERE st.validation_status = 'PASSED'
      AND st.data_quality_score >= 80
      AND st.ticket_type IS NOT NULL
      AND TRIM(st.ticket_type) != ''
),

support_enriched AS (
    SELECT 
        sb.ticket_type,
        
        -- Support category standardization
        CASE 
            WHEN UPPER(sb.ticket_type) LIKE '%TECHNICAL%' OR UPPER(sb.ticket_type) LIKE '%BUG%' THEN 'Technical'
            WHEN UPPER(sb.ticket_type) LIKE '%BILLING%' OR UPPER(sb.ticket_type) LIKE '%PAYMENT%' THEN 'Billing'
            WHEN UPPER(sb.ticket_type) LIKE '%ACCOUNT%' OR UPPER(sb.ticket_type) LIKE '%LOGIN%' THEN 'Account'
            WHEN UPPER(sb.ticket_type) LIKE '%FEATURE%' OR UPPER(sb.ticket_type) LIKE '%REQUEST%' THEN 'Feature Request'
            WHEN UPPER(sb.ticket_type) LIKE '%TRAINING%' OR UPPER(sb.ticket_type) LIKE '%HOW%TO%' THEN 'Training'
            WHEN UPPER(sb.ticket_type) LIKE '%INTEGRATION%' OR UPPER(sb.ticket_type) LIKE '%API%' THEN 'Integration'
            ELSE 'General'
        END AS support_category,
        
        -- Support subcategory
        CASE 
            WHEN UPPER(sb.ticket_type) LIKE '%CRITICAL%' OR UPPER(sb.ticket_type) LIKE '%URGENT%' THEN 'Critical Issue'
            WHEN UPPER(sb.ticket_type) LIKE '%HIGH%' OR UPPER(sb.ticket_type) LIKE '%PRIORITY%' THEN 'High Priority'
            WHEN UPPER(sb.ticket_type) LIKE '%MEDIUM%' OR UPPER(sb.ticket_type) LIKE '%NORMAL%' THEN 'Standard'
            WHEN UPPER(sb.ticket_type) LIKE '%LOW%' OR UPPER(sb.ticket_type) LIKE '%MINOR%' THEN 'Low Priority'
            ELSE 'Standard'
        END AS support_subcategory,
        
        -- Priority level mapping
        CASE 
            WHEN UPPER(sb.ticket_type) LIKE '%CRITICAL%' OR UPPER(sb.ticket_type) LIKE '%URGENT%' THEN 'P1'
            WHEN UPPER(sb.ticket_type) LIKE '%HIGH%' OR UPPER(sb.ticket_type) LIKE '%PRIORITY%' THEN 'P2'
            WHEN UPPER(sb.ticket_type) LIKE '%MEDIUM%' OR UPPER(sb.ticket_type) LIKE '%NORMAL%' THEN 'P3'
            WHEN UPPER(sb.ticket_type) LIKE '%LOW%' OR UPPER(sb.ticket_type) LIKE '%MINOR%' THEN 'P4'
            ELSE 'P3'
        END AS priority_level
        
    FROM support_base sb
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY support_category, priority_level) AS support_category_id,
    ticket_type AS support_category,
    support_subcategory,
    priority_level,
    
    -- Expected resolution hours based on priority
    CASE 
        WHEN priority_level = 'P1' THEN 4
        WHEN priority_level = 'P2' THEN 24
        WHEN priority_level = 'P3' THEN 72
        WHEN priority_level = 'P4' THEN 168
        ELSE 72
    END AS expected_resolution_hours,
    
    -- Escalation requirements
    CASE 
        WHEN priority_level IN ('P1', 'P2') THEN TRUE
        ELSE FALSE
    END AS requires_escalation,
    
    -- Self-service availability
    CASE 
        WHEN support_category IN ('Training', 'General') AND priority_level IN ('P3', 'P4') THEN TRUE
        ELSE FALSE
    END AS self_service_available,
    
    -- Specialist requirement
    CASE 
        WHEN support_category IN ('Technical', 'Integration') OR priority_level = 'P1' THEN TRUE
        ELSE FALSE
    END AS specialist_required,
    
    -- Category complexity
    CASE 
        WHEN support_category IN ('Technical', 'Integration') THEN 'High'
        WHEN support_category IN ('Account', 'Feature Request') THEN 'Medium'
        ELSE 'Low'
    END AS category_complexity,
    
    -- Customer impact level
    CASE 
        WHEN priority_level = 'P1' THEN 'Critical'
        WHEN priority_level = 'P2' THEN 'High'
        WHEN priority_level = 'P3' THEN 'Medium'
        WHEN priority_level = 'P4' THEN 'Low'
        ELSE 'Medium'
    END AS customer_impact_level,
    
    -- Resolution method
    CASE 
        WHEN support_category = 'Technical' THEN 'Technical Investigation'
        WHEN support_category = 'Billing' THEN 'Account Review'
        WHEN support_category = 'Training' THEN 'Knowledge Transfer'
        WHEN support_category = 'Integration' THEN 'Technical Consultation'
        ELSE 'Standard Support'
    END AS resolution_method,
    
    -- Knowledge base articles count (estimated)
    CASE 
        WHEN support_category = 'Training' THEN 50
        WHEN support_category = 'Technical' THEN 30
        WHEN support_category = 'Account' THEN 20
        WHEN support_category = 'Billing' THEN 15
        WHEN support_category = 'Integration' THEN 25
        ELSE 10
    END AS knowledge_base_articles,
    
    -- Metadata columns
    CURRENT_DATE() AS load_date,
    CURRENT_DATE() AS update_date,
    'DBT_GOLD_PIPELINE' AS source_system
    
FROM support_enriched
ORDER BY support_category_id
