{{ config(
    materialized='table',
    schema='gold',
    tags=['dimension', 'support_category'],
    unique_key='support_category_id'
) }}

-- Support category dimension table for Gold layer
-- Categorizes support tickets with comprehensive metadata

WITH source_tickets AS (
    SELECT DISTINCT
        TICKET_TYPE,
        RESOLUTION_STATUS,
        SOURCE_SYSTEM
    FROM {{ source('silver', 'SI_SUPPORT_TICKETS') }}
    WHERE VALIDATION_STATUS = 'VALID'
        AND DATA_QUALITY_SCORE >= 0.7
),

support_category_transformations AS (
    SELECT 
        -- Generate surrogate key
        {{ dbt_utils.generate_surrogate_key(['support_category', 'support_subcategory']) }} AS support_category_id,
        
        -- Main support category based on ticket type
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%TECHNICAL%' OR UPPER(TICKET_TYPE) LIKE '%BUG%' OR UPPER(TICKET_TYPE) LIKE '%ERROR%' THEN 'Technical'
            WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' OR UPPER(TICKET_TYPE) LIKE '%PAYMENT%' OR UPPER(TICKET_TYPE) LIKE '%INVOICE%' THEN 'Billing'
            WHEN UPPER(TICKET_TYPE) LIKE '%ACCOUNT%' OR UPPER(TICKET_TYPE) LIKE '%LOGIN%' OR UPPER(TICKET_TYPE) LIKE '%ACCESS%' THEN 'Account'
            WHEN UPPER(TICKET_TYPE) LIKE '%FEATURE%' OR UPPER(TICKET_TYPE) LIKE '%FUNCTIONALITY%' THEN 'Feature Request'
            WHEN UPPER(TICKET_TYPE) LIKE '%TRAINING%' OR UPPER(TICKET_TYPE) LIKE '%HOWTO%' OR UPPER(TICKET_TYPE) LIKE '%HELP%' THEN 'Training'
            WHEN UPPER(TICKET_TYPE) LIKE '%INTEGRATION%' OR UPPER(TICKET_TYPE) LIKE '%API%' THEN 'Integration'
            WHEN UPPER(TICKET_TYPE) LIKE '%SECURITY%' OR UPPER(TICKET_TYPE) LIKE '%PRIVACY%' THEN 'Security'
            WHEN UPPER(TICKET_TYPE) LIKE '%PERFORMANCE%' OR UPPER(TICKET_TYPE) LIKE '%SLOW%' THEN 'Performance'
            ELSE 'General'
        END AS support_category,
        
        -- Support subcategory for more granular classification
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%AUDIO%' THEN 'Audio Issues'
            WHEN UPPER(TICKET_TYPE) LIKE '%VIDEO%' THEN 'Video Issues'
            WHEN UPPER(TICKET_TYPE) LIKE '%CONNECTION%' OR UPPER(TICKET_TYPE) LIKE '%NETWORK%' THEN 'Connectivity'
            WHEN UPPER(TICKET_TYPE) LIKE '%RECORDING%' THEN 'Recording Issues'
            WHEN UPPER(TICKET_TYPE) LIKE '%SCREEN%SHARE%' THEN 'Screen Sharing'
            WHEN UPPER(TICKET_TYPE) LIKE '%MOBILE%' OR UPPER(TICKET_TYPE) LIKE '%APP%' THEN 'Mobile Application'
            WHEN UPPER(TICKET_TYPE) LIKE '%BROWSER%' OR UPPER(TICKET_TYPE) LIKE '%WEB%' THEN 'Web Application'
            WHEN UPPER(TICKET_TYPE) LIKE '%INSTALLATION%' OR UPPER(TICKET_TYPE) LIKE '%SETUP%' THEN 'Installation'
            WHEN UPPER(TICKET_TYPE) LIKE '%PASSWORD%' OR UPPER(TICKET_TYPE) LIKE '%RESET%' THEN 'Password Reset'
            WHEN UPPER(TICKET_TYPE) LIKE '%UPGRADE%' OR UPPER(TICKET_TYPE) LIKE '%DOWNGRADE%' THEN 'Plan Changes'
            ELSE 'General Support'
        END AS support_subcategory,
        
        -- Priority level based on ticket type
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' OR UPPER(TICKET_TYPE) LIKE '%URGENT%' OR UPPER(TICKET_TYPE) LIKE '%OUTAGE%' THEN 'Critical'
            WHEN UPPER(TICKET_TYPE) LIKE '%HIGH%' OR UPPER(TICKET_TYPE) LIKE '%SECURITY%' OR UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 'High'
            WHEN UPPER(TICKET_TYPE) LIKE '%MEDIUM%' OR UPPER(TICKET_TYPE) LIKE '%FEATURE%' THEN 'Medium'
            ELSE 'Low'
        END AS priority_level,
        
        -- Expected resolution time in hours
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' OR UPPER(TICKET_TYPE) LIKE '%URGENT%' THEN 4
            WHEN UPPER(TICKET_TYPE) LIKE '%HIGH%' OR UPPER(TICKET_TYPE) LIKE '%SECURITY%' THEN 24
            WHEN UPPER(TICKET_TYPE) LIKE '%MEDIUM%' OR UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 48
            WHEN UPPER(TICKET_TYPE) LIKE '%FEATURE%' OR UPPER(TICKET_TYPE) LIKE '%TRAINING%' THEN 72
            ELSE 48
        END AS expected_resolution_time_hours,
        
        -- Requires escalation indicator
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' OR 
                 UPPER(TICKET_TYPE) LIKE '%SECURITY%' OR 
                 UPPER(TICKET_TYPE) LIKE '%LEGAL%' OR
                 UPPER(TICKET_TYPE) LIKE '%COMPLIANCE%' THEN TRUE
            ELSE FALSE
        END AS requires_escalation,
        
        -- Self-service available
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%PASSWORD%' OR 
                 UPPER(TICKET_TYPE) LIKE '%RESET%' OR 
                 UPPER(TICKET_TYPE) LIKE '%HOWTO%' OR
                 UPPER(TICKET_TYPE) LIKE '%TRAINING%' THEN TRUE
            ELSE FALSE
        END AS self_service_available,
        
        -- Knowledge base articles count (estimated)
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%AUDIO%' OR UPPER(TICKET_TYPE) LIKE '%VIDEO%' THEN 15
            WHEN UPPER(TICKET_TYPE) LIKE '%CONNECTION%' OR UPPER(TICKET_TYPE) LIKE '%NETWORK%' THEN 12
            WHEN UPPER(TICKET_TYPE) LIKE '%RECORDING%' THEN 8
            WHEN UPPER(TICKET_TYPE) LIKE '%SCREEN%SHARE%' THEN 6
            WHEN UPPER(TICKET_TYPE) LIKE '%MOBILE%' OR UPPER(TICKET_TYPE) LIKE '%APP%' THEN 10
            WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' OR UPPER(TICKET_TYPE) LIKE '%ACCOUNT%' THEN 5
            ELSE 3
        END AS knowledge_base_articles,
        
        -- Common resolution steps
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%AUDIO%' THEN '1. Check microphone settings 2. Test audio device 3. Restart application'
            WHEN UPPER(TICKET_TYPE) LIKE '%VIDEO%' THEN '1. Check camera permissions 2. Test video device 3. Update drivers'
            WHEN UPPER(TICKET_TYPE) LIKE '%CONNECTION%' THEN '1. Check internet connection 2. Test firewall settings 3. Try different network'
            WHEN UPPER(TICKET_TYPE) LIKE '%PASSWORD%' THEN '1. Use password reset link 2. Check email for reset instructions 3. Contact admin'
            WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN '1. Review billing statement 2. Check payment method 3. Contact billing team'
            ELSE '1. Gather detailed information 2. Reproduce issue 3. Apply standard troubleshooting'
        END AS common_resolution_steps,
        
        -- Customer impact level
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' OR UPPER(TICKET_TYPE) LIKE '%OUTAGE%' THEN 'High'
            WHEN UPPER(TICKET_TYPE) LIKE '%AUDIO%' OR UPPER(TICKET_TYPE) LIKE '%VIDEO%' OR UPPER(TICKET_TYPE) LIKE '%CONNECTION%' THEN 'Medium'
            WHEN UPPER(TICKET_TYPE) LIKE '%FEATURE%' OR UPPER(TICKET_TYPE) LIKE '%TRAINING%' THEN 'Low'
            ELSE 'Medium'
        END AS customer_impact_level,
        
        -- Department responsible
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%TECHNICAL%' OR UPPER(TICKET_TYPE) LIKE '%BUG%' THEN 'Technical Support'
            WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' OR UPPER(TICKET_TYPE) LIKE '%PAYMENT%' THEN 'Billing Support'
            WHEN UPPER(TICKET_TYPE) LIKE '%SECURITY%' OR UPPER(TICKET_TYPE) LIKE '%PRIVACY%' THEN 'Security Team'
            WHEN UPPER(TICKET_TYPE) LIKE '%INTEGRATION%' OR UPPER(TICKET_TYPE) LIKE '%API%' THEN 'Developer Support'
            WHEN UPPER(TICKET_TYPE) LIKE '%TRAINING%' OR UPPER(TICKET_TYPE) LIKE '%HOWTO%' THEN 'Customer Success'
            ELSE 'General Support'
        END AS department_responsible,
        
        -- SLA target hours
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN 4
            WHEN UPPER(TICKET_TYPE) LIKE '%HIGH%' THEN 24
            WHEN UPPER(TICKET_TYPE) LIKE '%MEDIUM%' THEN 48
            ELSE 72
        END AS sla_target_hours,
        
        -- Audit fields
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        SOURCE_SYSTEM AS source_system
        
    FROM source_tickets
)

-- Create distinct support categories
SELECT DISTINCT
    support_category_id,
    support_category,
    support_subcategory,
    priority_level,
    expected_resolution_time_hours,
    requires_escalation,
    self_service_available,
    knowledge_base_articles,
    common_resolution_steps,
    customer_impact_level,
    department_responsible,
    sla_target_hours,
    load_date,
    update_date,
    source_system
FROM support_category_transformations
ORDER BY support_category, support_subcategory