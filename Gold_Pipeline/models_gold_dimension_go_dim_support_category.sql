{{ config(
    materialized='table',
    schema='gold',
    database='DB_POC_ZOOM',
    tags=['dimension', 'support_category']
) }}

-- Support category dimension table
-- Categorizes support tickets with comprehensive metadata for SLA and resolution tracking

WITH source_tickets AS (
    SELECT DISTINCT
        ticket_type,
        source_system,
        load_date,
        update_date
    FROM {{ source('silver_layer', 'si_support_tickets') }}
    WHERE validation_status = 'VALID'
      AND ticket_type IS NOT NULL
      AND TRIM(ticket_type) != ''
),

support_categorization AS (
    SELECT 
        TRIM(ticket_type) AS ticket_type,
        
        -- Support category classification
        CASE 
            WHEN UPPER(ticket_type) LIKE '%TECHNICAL%' OR UPPER(ticket_type) LIKE '%BUG%' 
                 OR UPPER(ticket_type) LIKE '%ERROR%' OR UPPER(ticket_type) LIKE '%CRASH%' THEN 'Technical'
            WHEN UPPER(ticket_type) LIKE '%BILLING%' OR UPPER(ticket_type) LIKE '%PAYMENT%' 
                 OR UPPER(ticket_type) LIKE '%INVOICE%' OR UPPER(ticket_type) LIKE '%SUBSCRIPTION%' THEN 'Billing'
            WHEN UPPER(ticket_type) LIKE '%ACCOUNT%' OR UPPER(ticket_type) LIKE '%LOGIN%' 
                 OR UPPER(ticket_type) LIKE '%PASSWORD%' OR UPPER(ticket_type) LIKE '%ACCESS%' THEN 'Account'
            WHEN UPPER(ticket_type) LIKE '%FEATURE%' OR UPPER(ticket_type) LIKE '%ENHANCEMENT%' 
                 OR UPPER(ticket_type) LIKE '%REQUEST%' THEN 'Feature Request'
            WHEN UPPER(ticket_type) LIKE '%TRAINING%' OR UPPER(ticket_type) LIKE '%HOWTO%' 
                 OR UPPER(ticket_type) LIKE '%TUTORIAL%' OR UPPER(ticket_type) LIKE '%HELP%' THEN 'Training'
            WHEN UPPER(ticket_type) LIKE '%INTEGRATION%' OR UPPER(ticket_type) LIKE '%API%' 
                 OR UPPER(ticket_type) LIKE '%WEBHOOK%' THEN 'Integration'
            WHEN UPPER(ticket_type) LIKE '%PERFORMANCE%' OR UPPER(ticket_type) LIKE '%SLOW%' 
                 OR UPPER(ticket_type) LIKE '%LATENCY%' THEN 'Performance'
            ELSE 'General'
        END AS support_category,
        
        -- Support subcategory
        CASE 
            WHEN UPPER(ticket_type) LIKE '%AUDIO%' THEN 'Audio Issues'
            WHEN UPPER(ticket_type) LIKE '%VIDEO%' THEN 'Video Issues'
            WHEN UPPER(ticket_type) LIKE '%CONNECTION%' OR UPPER(ticket_type) LIKE '%NETWORK%' THEN 'Connectivity'
            WHEN UPPER(ticket_type) LIKE '%RECORDING%' THEN 'Recording Issues'
            WHEN UPPER(ticket_type) LIKE '%SCREEN%SHARE%' THEN 'Screen Sharing'
            WHEN UPPER(ticket_type) LIKE '%MOBILE%' OR UPPER(ticket_type) LIKE '%APP%' THEN 'Mobile App'
            WHEN UPPER(ticket_type) LIKE '%BROWSER%' OR UPPER(ticket_type) LIKE '%WEB%' THEN 'Web Client'
            WHEN UPPER(ticket_type) LIKE '%DESKTOP%' THEN 'Desktop Client'
            WHEN UPPER(ticket_type) LIKE '%ADMIN%' THEN 'Administration'
            WHEN UPPER(ticket_type) LIKE '%SECURITY%' THEN 'Security'
            ELSE 'Other'
        END AS support_subcategory,
        
        -- Priority level based on category
        CASE 
            WHEN UPPER(ticket_type) LIKE '%CRITICAL%' OR UPPER(ticket_type) LIKE '%URGENT%' 
                 OR UPPER(ticket_type) LIKE '%SECURITY%' THEN 'Critical'
            WHEN UPPER(ticket_type) LIKE '%BILLING%' OR UPPER(ticket_type) LIKE '%ACCOUNT%' 
                 OR UPPER(ticket_type) LIKE '%LOGIN%' THEN 'High'
            WHEN UPPER(ticket_type) LIKE '%TECHNICAL%' OR UPPER(ticket_type) LIKE '%BUG%' 
                 OR UPPER(ticket_type) LIKE '%PERFORMANCE%' THEN 'Medium'
            WHEN UPPER(ticket_type) LIKE '%FEATURE%' OR UPPER(ticket_type) LIKE '%TRAINING%' THEN 'Low'
            ELSE 'Medium'
        END AS priority_level,
        
        -- Expected resolution time in hours
        CASE 
            WHEN UPPER(ticket_type) LIKE '%CRITICAL%' OR UPPER(ticket_type) LIKE '%SECURITY%' THEN 4
            WHEN UPPER(ticket_type) LIKE '%BILLING%' OR UPPER(ticket_type) LIKE '%ACCOUNT%' THEN 8
            WHEN UPPER(ticket_type) LIKE '%TECHNICAL%' OR UPPER(ticket_type) LIKE '%BUG%' THEN 24
            WHEN UPPER(ticket_type) LIKE '%PERFORMANCE%' THEN 48
            WHEN UPPER(ticket_type) LIKE '%FEATURE%' OR UPPER(ticket_type) LIKE '%TRAINING%' THEN 72
            ELSE 24
        END AS expected_resolution_time_hours,
        
        -- Requires escalation flag
        CASE 
            WHEN UPPER(ticket_type) LIKE '%CRITICAL%' OR UPPER(ticket_type) LIKE '%SECURITY%' 
                 OR UPPER(ticket_type) LIKE '%BILLING%' THEN TRUE
            ELSE FALSE
        END AS requires_escalation,
        
        -- Self-service available
        CASE 
            WHEN UPPER(ticket_type) LIKE '%TRAINING%' OR UPPER(ticket_type) LIKE '%HOWTO%' 
                 OR UPPER(ticket_type) LIKE '%PASSWORD%' OR UPPER(ticket_type) LIKE '%BASIC%' THEN TRUE
            ELSE FALSE
        END AS self_service_available,
        
        -- Knowledge base articles count (estimated)
        CASE 
            WHEN UPPER(ticket_type) LIKE '%TRAINING%' OR UPPER(ticket_type) LIKE '%HOWTO%' THEN 10
            WHEN UPPER(ticket_type) LIKE '%TECHNICAL%' OR UPPER(ticket_type) LIKE '%ACCOUNT%' THEN 5
            WHEN UPPER(ticket_type) LIKE '%BILLING%' OR UPPER(ticket_type) LIKE '%FEATURE%' THEN 3
            ELSE 1
        END AS knowledge_base_articles,
        
        -- Common resolution steps
        CASE 
            WHEN UPPER(ticket_type) LIKE '%AUDIO%' THEN 'Check microphone settings, restart application, test audio devices'
            WHEN UPPER(ticket_type) LIKE '%VIDEO%' THEN 'Check camera permissions, restart application, update drivers'
            WHEN UPPER(ticket_type) LIKE '%CONNECTION%' THEN 'Check network connectivity, restart router, try different network'
            WHEN UPPER(ticket_type) LIKE '%LOGIN%' THEN 'Reset password, clear browser cache, check account status'
            WHEN UPPER(ticket_type) LIKE '%BILLING%' THEN 'Verify payment method, check billing history, contact billing team'
            WHEN UPPER(ticket_type) LIKE '%PERFORMANCE%' THEN 'Close other applications, check system resources, update software'
            ELSE 'Follow standard troubleshooting procedures'
        END AS common_resolution_steps,
        
        -- Customer impact level
        CASE 
            WHEN UPPER(ticket_type) LIKE '%CRITICAL%' OR UPPER(ticket_type) LIKE '%SECURITY%' THEN 'High'
            WHEN UPPER(ticket_type) LIKE '%BILLING%' OR UPPER(ticket_type) LIKE '%ACCOUNT%' 
                 OR UPPER(ticket_type) LIKE '%LOGIN%' THEN 'Medium'
            WHEN UPPER(ticket_type) LIKE '%FEATURE%' OR UPPER(ticket_type) LIKE '%TRAINING%' THEN 'Low'
            ELSE 'Medium'
        END AS customer_impact_level,
        
        -- Department responsible
        CASE 
            WHEN UPPER(ticket_type) LIKE '%TECHNICAL%' OR UPPER(ticket_type) LIKE '%BUG%' 
                 OR UPPER(ticket_type) LIKE '%PERFORMANCE%' THEN 'Engineering'
            WHEN UPPER(ticket_type) LIKE '%BILLING%' OR UPPER(ticket_type) LIKE '%PAYMENT%' THEN 'Finance'
            WHEN UPPER(ticket_type) LIKE '%ACCOUNT%' OR UPPER(ticket_type) LIKE '%LOGIN%' THEN 'Customer Success'
            WHEN UPPER(ticket_type) LIKE '%FEATURE%' OR UPPER(ticket_type) LIKE '%ENHANCEMENT%' THEN 'Product'
            WHEN UPPER(ticket_type) LIKE '%TRAINING%' OR UPPER(ticket_type) LIKE '%HELP%' THEN 'Support'
            WHEN UPPER(ticket_type) LIKE '%SECURITY%' THEN 'Security'
            ELSE 'Support'
        END AS department_responsible,
        
        -- SLA target hours
        CASE 
            WHEN UPPER(ticket_type) LIKE '%CRITICAL%' OR UPPER(ticket_type) LIKE '%SECURITY%' THEN 2
            WHEN UPPER(ticket_type) LIKE '%BILLING%' OR UPPER(ticket_type) LIKE '%ACCOUNT%' THEN 4
            WHEN UPPER(ticket_type) LIKE '%TECHNICAL%' OR UPPER(ticket_type) LIKE '%BUG%' THEN 8
            WHEN UPPER(ticket_type) LIKE '%PERFORMANCE%' THEN 24
            WHEN UPPER(ticket_type) LIKE '%FEATURE%' OR UPPER(ticket_type) LIKE '%TRAINING%' THEN 48
            ELSE 8
        END AS sla_target_hours,
        
        -- Audit fields
        source_system,
        load_date,
        update_date
        
    FROM source_tickets
)

SELECT 
    MD5(UPPER(TRIM(ticket_type))) AS support_category_id,
    INITCAP(ticket_type) AS support_category,
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
FROM support_categorization
ORDER BY support_category, support_subcategory