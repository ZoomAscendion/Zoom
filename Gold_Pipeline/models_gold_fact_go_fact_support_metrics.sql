{{ config(
    materialized='table',
    schema='gold',
    tags=['fact', 'support_metrics'],
    unique_key='support_metrics_id'
) }}

-- Support metrics fact table for Gold layer
-- Contains comprehensive support ticket analytics and performance metrics

WITH source_support_tickets AS (
    SELECT 
        st.TICKET_ID,
        st.USER_ID,
        st.TICKET_TYPE,
        st.RESOLUTION_STATUS,
        st.OPEN_DATE,
        st.LOAD_TIMESTAMP,
        st.UPDATE_TIMESTAMP,
        st.SOURCE_SYSTEM,
        st.LOAD_DATE,
        st.UPDATE_DATE,
        st.DATA_QUALITY_SCORE,
        st.VALIDATION_STATUS
    FROM {{ source('silver', 'SI_SUPPORT_TICKETS') }} st
    WHERE st.VALIDATION_STATUS = 'VALID'
        AND st.DATA_QUALITY_SCORE >= 0.7
),

support_metrics_transformations AS (
    SELECT 
        -- Generate surrogate key for fact table
        {{ dbt_utils.generate_surrogate_key(['st.TICKET_ID']) }} AS support_metrics_id,
        
        -- Dimension keys
        dd.date_id,
        dsc.support_category_id,
        du.user_dim_id,
        
        -- Original ticket ID
        st.TICKET_ID,
        
        -- Date and time fields
        st.OPEN_DATE AS ticket_created_date,
        COALESCE(st.LOAD_TIMESTAMP, st.OPEN_DATE::TIMESTAMP) AS ticket_created_timestamp,
        
        -- Estimated closed date (based on resolution status and typical resolution times)
        CASE 
            WHEN UPPER(st.RESOLUTION_STATUS) = 'RESOLVED' OR UPPER(st.RESOLUTION_STATUS) = 'CLOSED' THEN 
                CASE 
                    WHEN UPPER(st.TICKET_TYPE) LIKE '%CRITICAL%' OR UPPER(st.TICKET_TYPE) LIKE '%URGENT%' 
                    THEN st.OPEN_DATE + INTERVAL '4 hours'
                    WHEN UPPER(st.TICKET_TYPE) LIKE '%HIGH%' OR UPPER(st.TICKET_TYPE) LIKE '%SECURITY%' 
                    THEN st.OPEN_DATE + INTERVAL '1 day'
                    WHEN UPPER(st.TICKET_TYPE) LIKE '%MEDIUM%' OR UPPER(st.TICKET_TYPE) LIKE '%BILLING%' 
                    THEN st.OPEN_DATE + INTERVAL '2 days'
                    ELSE st.OPEN_DATE + INTERVAL '3 days'
                END
            ELSE NULL
        END AS ticket_closed_date,
        
        CASE 
            WHEN UPPER(st.RESOLUTION_STATUS) = 'RESOLVED' OR UPPER(st.RESOLUTION_STATUS) = 'CLOSED' THEN 
                CASE 
                    WHEN UPPER(st.TICKET_TYPE) LIKE '%CRITICAL%' OR UPPER(st.TICKET_TYPE) LIKE '%URGENT%' 
                    THEN COALESCE(st.LOAD_TIMESTAMP, st.OPEN_DATE::TIMESTAMP) + INTERVAL '4 hours'
                    WHEN UPPER(st.TICKET_TYPE) LIKE '%HIGH%' OR UPPER(st.TICKET_TYPE) LIKE '%SECURITY%' 
                    THEN COALESCE(st.LOAD_TIMESTAMP, st.OPEN_DATE::TIMESTAMP) + INTERVAL '1 day'
                    WHEN UPPER(st.TICKET_TYPE) LIKE '%MEDIUM%' OR UPPER(st.TICKET_TYPE) LIKE '%BILLING%' 
                    THEN COALESCE(st.LOAD_TIMESTAMP, st.OPEN_DATE::TIMESTAMP) + INTERVAL '2 days'
                    ELSE COALESCE(st.LOAD_TIMESTAMP, st.OPEN_DATE::TIMESTAMP) + INTERVAL '3 days'
                END
            ELSE NULL
        END AS ticket_closed_timestamp,
        
        -- First response timestamp (estimated as 2 hours after creation for most tickets)
        COALESCE(st.LOAD_TIMESTAMP, st.OPEN_DATE::TIMESTAMP) + 
        CASE 
            WHEN UPPER(st.TICKET_TYPE) LIKE '%CRITICAL%' OR UPPER(st.TICKET_TYPE) LIKE '%URGENT%' 
            THEN INTERVAL '30 minutes'
            WHEN UPPER(st.TICKET_TYPE) LIKE '%HIGH%' OR UPPER(st.TICKET_TYPE) LIKE '%SECURITY%' 
            THEN INTERVAL '2 hours'
            ELSE INTERVAL '4 hours'
        END AS first_response_timestamp,
        
        -- Resolution timestamp (same as closed timestamp)
        CASE 
            WHEN UPPER(st.RESOLUTION_STATUS) = 'RESOLVED' OR UPPER(st.RESOLUTION_STATUS) = 'CLOSED' THEN 
                CASE 
                    WHEN UPPER(st.TICKET_TYPE) LIKE '%CRITICAL%' OR UPPER(st.TICKET_TYPE) LIKE '%URGENT%' 
                    THEN COALESCE(st.LOAD_TIMESTAMP, st.OPEN_DATE::TIMESTAMP) + INTERVAL '4 hours'
                    WHEN UPPER(st.TICKET_TYPE) LIKE '%HIGH%' OR UPPER(st.TICKET_TYPE) LIKE '%SECURITY%' 
                    THEN COALESCE(st.LOAD_TIMESTAMP, st.OPEN_DATE::TIMESTAMP) + INTERVAL '1 day'
                    WHEN UPPER(st.TICKET_TYPE) LIKE '%MEDIUM%' OR UPPER(st.TICKET_TYPE) LIKE '%BILLING%' 
                    THEN COALESCE(st.LOAD_TIMESTAMP, st.OPEN_DATE::TIMESTAMP) + INTERVAL '2 days'
                    ELSE COALESCE(st.LOAD_TIMESTAMP, st.OPEN_DATE::TIMESTAMP) + INTERVAL '3 days'
                END
            ELSE NULL
        END AS resolution_timestamp,
        
        -- Ticket categorization
        UPPER(TRIM(st.TICKET_TYPE)) AS ticket_category,
        
        -- Ticket subcategory (derived from ticket type)
        CASE 
            WHEN UPPER(st.TICKET_TYPE) LIKE '%AUDIO%' THEN 'Audio Issues'
            WHEN UPPER(st.TICKET_TYPE) LIKE '%VIDEO%' THEN 'Video Issues'
            WHEN UPPER(st.TICKET_TYPE) LIKE '%CONNECTION%' OR UPPER(st.TICKET_TYPE) LIKE '%NETWORK%' THEN 'Connectivity'
            WHEN UPPER(st.TICKET_TYPE) LIKE '%RECORDING%' THEN 'Recording Issues'
            WHEN UPPER(st.TICKET_TYPE) LIKE '%SCREEN%SHARE%' THEN 'Screen Sharing'
            WHEN UPPER(st.TICKET_TYPE) LIKE '%MOBILE%' OR UPPER(st.TICKET_TYPE) LIKE '%APP%' THEN 'Mobile Application'
            WHEN UPPER(st.TICKET_TYPE) LIKE '%BROWSER%' OR UPPER(st.TICKET_TYPE) LIKE '%WEB%' THEN 'Web Application'
            WHEN UPPER(st.TICKET_TYPE) LIKE '%BILLING%' OR UPPER(st.TICKET_TYPE) LIKE '%PAYMENT%' THEN 'Billing'
            WHEN UPPER(st.TICKET_TYPE) LIKE '%PASSWORD%' OR UPPER(st.TICKET_TYPE) LIKE '%RESET%' THEN 'Account Access'
            ELSE 'General Support'
        END AS ticket_subcategory,
        
        -- Priority and severity levels
        CASE 
            WHEN UPPER(st.TICKET_TYPE) LIKE '%CRITICAL%' OR UPPER(st.TICKET_TYPE) LIKE '%URGENT%' THEN 'Critical'
            WHEN UPPER(st.TICKET_TYPE) LIKE '%HIGH%' OR UPPER(st.TICKET_TYPE) LIKE '%SECURITY%' THEN 'High'
            WHEN UPPER(st.TICKET_TYPE) LIKE '%MEDIUM%' OR UPPER(st.TICKET_TYPE) LIKE '%BILLING%' THEN 'Medium'
            ELSE 'Low'
        END AS priority_level,
        
        CASE 
            WHEN UPPER(st.TICKET_TYPE) LIKE '%CRITICAL%' OR UPPER(st.TICKET_TYPE) LIKE '%OUTAGE%' THEN 'Severity 1'
            WHEN UPPER(st.TICKET_TYPE) LIKE '%HIGH%' OR UPPER(st.TICKET_TYPE) LIKE '%SECURITY%' THEN 'Severity 2'
            WHEN UPPER(st.TICKET_TYPE) LIKE '%MEDIUM%' THEN 'Severity 3'
            ELSE 'Severity 4'
        END AS severity_level,
        
        -- Resolution status
        UPPER(TRIM(st.RESOLUTION_STATUS)) AS resolution_status,
        
        -- Time metrics (in hours)
        CASE 
            WHEN UPPER(st.TICKET_TYPE) LIKE '%CRITICAL%' OR UPPER(st.TICKET_TYPE) LIKE '%URGENT%' THEN 0.5
            WHEN UPPER(st.TICKET_TYPE) LIKE '%HIGH%' OR UPPER(st.TICKET_TYPE) LIKE '%SECURITY%' THEN 2.0
            ELSE 4.0
        END AS first_response_time_hours,
        
        -- Resolution time hours
        CASE 
            WHEN UPPER(st.RESOLUTION_STATUS) = 'RESOLVED' OR UPPER(st.RESOLUTION_STATUS) = 'CLOSED' THEN 
                CASE 
                    WHEN UPPER(st.TICKET_TYPE) LIKE '%CRITICAL%' OR UPPER(st.TICKET_TYPE) LIKE '%URGENT%' THEN 4.0
                    WHEN UPPER(st.TICKET_TYPE) LIKE '%HIGH%' OR UPPER(st.TICKET_TYPE) LIKE '%SECURITY%' THEN 24.0
                    WHEN UPPER(st.TICKET_TYPE) LIKE '%MEDIUM%' OR UPPER(st.TICKET_TYPE) LIKE '%BILLING%' THEN 48.0
                    ELSE 72.0
                END
            ELSE NULL
        END AS resolution_time_hours,
        
        -- Active work time (estimated as 60% of resolution time)
        CASE 
            WHEN UPPER(st.RESOLUTION_STATUS) = 'RESOLVED' OR UPPER(st.RESOLUTION_STATUS) = 'CLOSED' THEN 
                CASE 
                    WHEN UPPER(st.TICKET_TYPE) LIKE '%CRITICAL%' OR UPPER(st.TICKET_TYPE) LIKE '%URGENT%' THEN 2.4
                    WHEN UPPER(st.TICKET_TYPE) LIKE '%HIGH%' OR UPPER(st.TICKET_TYPE) LIKE '%SECURITY%' THEN 14.4
                    WHEN UPPER(st.TICKET_TYPE) LIKE '%MEDIUM%' OR UPPER(st.TICKET_TYPE) LIKE '%BILLING%' THEN 28.8
                    ELSE 43.2
                END
            ELSE NULL
        END AS active_work_time_hours,
        
        -- Customer wait time (estimated as 40% of resolution time)
        CASE 
            WHEN UPPER(st.RESOLUTION_STATUS) = 'RESOLVED' OR UPPER(st.RESOLUTION_STATUS) = 'CLOSED' THEN 
                CASE 
                    WHEN UPPER(st.TICKET_TYPE) LIKE '%CRITICAL%' OR UPPER(st.TICKET_TYPE) LIKE '%URGENT%' THEN 1.6
                    WHEN UPPER(st.TICKET_TYPE) LIKE '%HIGH%' OR UPPER(st.TICKET_TYPE) LIKE '%SECURITY%' THEN 9.6
                    WHEN UPPER(st.TICKET_TYPE) LIKE '%MEDIUM%' OR UPPER(st.TICKET_TYPE) LIKE '%BILLING%' THEN 19.2
                    ELSE 28.8
                END
            ELSE NULL
        END AS customer_wait_time_hours,
        
        -- Escalation and interaction counts (estimated)
        CASE 
            WHEN UPPER(st.TICKET_TYPE) LIKE '%CRITICAL%' OR UPPER(st.TICKET_TYPE) LIKE '%SECURITY%' THEN 1
            WHEN UPPER(st.TICKET_TYPE) LIKE '%HIGH%' THEN 
                CASE WHEN st.DATA_QUALITY_SCORE < 0.8 THEN 1 ELSE 0 END
            ELSE 0
        END AS escalation_count,
        
        CASE 
            WHEN st.DATA_QUALITY_SCORE < 0.8 THEN 1
            ELSE 0
        END AS reassignment_count,
        
        CASE 
            WHEN UPPER(st.RESOLUTION_STATUS) = 'REOPENED' OR st.DATA_QUALITY_SCORE < 0.7 THEN 1
            ELSE 0
        END AS reopened_count,
        
        -- Agent and customer interactions (estimated)
        CASE 
            WHEN UPPER(st.TICKET_TYPE) LIKE '%CRITICAL%' OR UPPER(st.TICKET_TYPE) LIKE '%URGENT%' THEN 8
            WHEN UPPER(st.TICKET_TYPE) LIKE '%HIGH%' OR UPPER(st.TICKET_TYPE) LIKE '%SECURITY%' THEN 5
            WHEN UPPER(st.TICKET_TYPE) LIKE '%MEDIUM%' THEN 3
            ELSE 2
        END AS agent_interactions_count,
        
        CASE 
            WHEN UPPER(st.TICKET_TYPE) LIKE '%CRITICAL%' OR UPPER(st.TICKET_TYPE) LIKE '%URGENT%' THEN 6
            WHEN UPPER(st.TICKET_TYPE) LIKE '%HIGH%' OR UPPER(st.TICKET_TYPE) LIKE '%SECURITY%' THEN 4
            WHEN UPPER(st.TICKET_TYPE) LIKE '%MEDIUM%' THEN 2
            ELSE 1
        END AS customer_interactions_count,
        
        -- Knowledge base articles used (estimated)
        CASE 
            WHEN UPPER(st.TICKET_TYPE) LIKE '%AUDIO%' OR UPPER(st.TICKET_TYPE) LIKE '%VIDEO%' THEN 3
            WHEN UPPER(st.TICKET_TYPE) LIKE '%CONNECTION%' OR UPPER(st.TICKET_TYPE) LIKE '%NETWORK%' THEN 2
            WHEN UPPER(st.TICKET_TYPE) LIKE '%BILLING%' OR UPPER(st.TICKET_TYPE) LIKE '%ACCOUNT%' THEN 1
            ELSE 1
        END AS knowledge_base_articles_used,
        
        -- Customer satisfaction score (1-5 scale)
        CASE 
            WHEN UPPER(st.RESOLUTION_STATUS) = 'RESOLVED' AND st.DATA_QUALITY_SCORE >= 0.9 THEN 5
            WHEN UPPER(st.RESOLUTION_STATUS) = 'RESOLVED' AND st.DATA_QUALITY_SCORE >= 0.8 THEN 4
            WHEN UPPER(st.RESOLUTION_STATUS) = 'RESOLVED' AND st.DATA_QUALITY_SCORE >= 0.7 THEN 3
            WHEN UPPER(st.RESOLUTION_STATUS) = 'CLOSED' THEN 2
            ELSE 1
        END AS customer_satisfaction_score,
        
        -- First contact resolution
        CASE 
            WHEN UPPER(st.RESOLUTION_STATUS) = 'RESOLVED' AND 
                 UPPER(st.TICKET_TYPE) NOT LIKE '%CRITICAL%' AND 
                 UPPER(st.TICKET_TYPE) NOT LIKE '%COMPLEX%' AND
                 st.DATA_QUALITY_SCORE >= 0.8 THEN TRUE
            ELSE FALSE
        END AS first_contact_resolution,
        
        -- SLA metrics
        CASE 
            WHEN UPPER(st.RESOLUTION_STATUS) = 'RESOLVED' OR UPPER(st.RESOLUTION_STATUS) = 'CLOSED' THEN 
                CASE 
                    WHEN UPPER(st.TICKET_TYPE) LIKE '%CRITICAL%' AND st.DATA_QUALITY_SCORE >= 0.9 THEN TRUE
                    WHEN UPPER(st.TICKET_TYPE) LIKE '%HIGH%' AND st.DATA_QUALITY_SCORE >= 0.8 THEN TRUE
                    WHEN UPPER(st.TICKET_TYPE) LIKE '%MEDIUM%' AND st.DATA_QUALITY_SCORE >= 0.7 THEN TRUE
                    WHEN UPPER(st.TICKET_TYPE) LIKE '%LOW%' THEN TRUE
                    ELSE FALSE
                END
            ELSE FALSE
        END AS sla_met,
        
        -- SLA breach hours
        CASE 
            WHEN UPPER(st.RESOLUTION_STATUS) = 'RESOLVED' OR UPPER(st.RESOLUTION_STATUS) = 'CLOSED' THEN 
                CASE 
                    WHEN UPPER(st.TICKET_TYPE) LIKE '%CRITICAL%' AND st.DATA_QUALITY_SCORE < 0.9 THEN 2.0
                    WHEN UPPER(st.TICKET_TYPE) LIKE '%HIGH%' AND st.DATA_QUALITY_SCORE < 0.8 THEN 8.0
                    WHEN UPPER(st.TICKET_TYPE) LIKE '%MEDIUM%' AND st.DATA_QUALITY_SCORE < 0.7 THEN 12.0
                    ELSE 0.0
                END
            ELSE 0.0
        END AS sla_breach_hours,
        
        -- Resolution method
        CASE 
            WHEN UPPER(st.TICKET_TYPE) LIKE '%PASSWORD%' OR UPPER(st.TICKET_TYPE) LIKE '%RESET%' THEN 'Self-Service'
            WHEN UPPER(st.TICKET_TYPE) LIKE '%CRITICAL%' OR UPPER(st.TICKET_TYPE) LIKE '%URGENT%' THEN 'Phone Support'
            WHEN UPPER(st.TICKET_TYPE) LIKE '%BILLING%' OR UPPER(st.TICKET_TYPE) LIKE '%ACCOUNT%' THEN 'Email Support'
            ELSE 'Chat Support'
        END AS resolution_method,
        
        -- Root cause category
        CASE 
            WHEN UPPER(st.TICKET_TYPE) LIKE '%AUDIO%' OR UPPER(st.TICKET_TYPE) LIKE '%VIDEO%' THEN 'Hardware/Software'
            WHEN UPPER(st.TICKET_TYPE) LIKE '%CONNECTION%' OR UPPER(st.TICKET_TYPE) LIKE '%NETWORK%' THEN 'Network'
            WHEN UPPER(st.TICKET_TYPE) LIKE '%BILLING%' OR UPPER(st.TICKET_TYPE) LIKE '%PAYMENT%' THEN 'Process'
            WHEN UPPER(st.TICKET_TYPE) LIKE '%TRAINING%' OR UPPER(st.TICKET_TYPE) LIKE '%HOWTO%' THEN 'User Education'
            ELSE 'Product'
        END AS root_cause_category,
        
        -- Preventable issue indicator
        CASE 
            WHEN UPPER(st.TICKET_TYPE) LIKE '%TRAINING%' OR UPPER(st.TICKET_TYPE) LIKE '%HOWTO%' THEN TRUE
            WHEN UPPER(st.TICKET_TYPE) LIKE '%PASSWORD%' OR UPPER(st.TICKET_TYPE) LIKE '%RESET%' THEN TRUE
            ELSE FALSE
        END AS preventable_issue,
        
        -- Follow-up required
        CASE 
            WHEN UPPER(st.TICKET_TYPE) LIKE '%CRITICAL%' OR UPPER(st.TICKET_TYPE) LIKE '%SECURITY%' THEN TRUE
            WHEN st.DATA_QUALITY_SCORE < 0.8 THEN TRUE
            ELSE FALSE
        END AS follow_up_required,
        
        -- Cost to resolve (estimated in USD)
        CASE 
            WHEN UPPER(st.TICKET_TYPE) LIKE '%CRITICAL%' OR UPPER(st.TICKET_TYPE) LIKE '%URGENT%' THEN 150.00
            WHEN UPPER(st.TICKET_TYPE) LIKE '%HIGH%' OR UPPER(st.TICKET_TYPE) LIKE '%SECURITY%' THEN 75.00
            WHEN UPPER(st.TICKET_TYPE) LIKE '%MEDIUM%' THEN 35.00
            ELSE 15.00
        END AS cost_to_resolve,
        
        -- Audit fields
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        st.SOURCE_SYSTEM AS source_system
        
    FROM source_support_tickets st
    
    -- Join with dimension tables
    LEFT JOIN {{ ref('go_dim_date') }} dd ON st.OPEN_DATE = dd.date_value
    LEFT JOIN {{ ref('go_dim_support_category') }} dsc ON (
        CASE 
            WHEN UPPER(st.TICKET_TYPE) LIKE '%TECHNICAL%' OR UPPER(st.TICKET_TYPE) LIKE '%BUG%' THEN 'Technical'
            WHEN UPPER(st.TICKET_TYPE) LIKE '%BILLING%' OR UPPER(st.TICKET_TYPE) LIKE '%PAYMENT%' THEN 'Billing'
            WHEN UPPER(st.TICKET_TYPE) LIKE '%ACCOUNT%' OR UPPER(st.TICKET_TYPE) LIKE '%LOGIN%' THEN 'Account'
            WHEN UPPER(st.TICKET_TYPE) LIKE '%FEATURE%' OR UPPER(st.TICKET_TYPE) LIKE '%FUNCTIONALITY%' THEN 'Feature Request'
            WHEN UPPER(st.TICKET_TYPE) LIKE '%TRAINING%' OR UPPER(st.TICKET_TYPE) LIKE '%HOWTO%' THEN 'Training'
            WHEN UPPER(st.TICKET_TYPE) LIKE '%INTEGRATION%' OR UPPER(st.TICKET_TYPE) LIKE '%API%' THEN 'Integration'
            WHEN UPPER(st.TICKET_TYPE) LIKE '%SECURITY%' OR UPPER(st.TICKET_TYPE) LIKE '%PRIVACY%' THEN 'Security'
            ELSE 'General'
        END = dsc.support_category
    )
    LEFT JOIN {{ ref('go_dim_user') }} du ON st.USER_ID = du.user_id AND du.is_current_record = TRUE
)

SELECT 
    support_metrics_id,
    date_id,
    support_category_id,
    user_dim_id,
    ticket_id,
    ticket_created_date,
    ticket_created_timestamp,
    ticket_closed_date,
    ticket_closed_timestamp,
    first_response_timestamp,
    resolution_timestamp,
    ticket_category,
    ticket_subcategory,
    priority_level,
    severity_level,
    resolution_status,
    first_response_time_hours,
    resolution_time_hours,
    active_work_time_hours,
    customer_wait_time_hours,
    escalation_count,
    reassignment_count,
    reopened_count,
    agent_interactions_count,
    customer_interactions_count,
    knowledge_base_articles_used,
    customer_satisfaction_score,
    first_contact_resolution,
    sla_met,
    sla_breach_hours,
    resolution_method,
    root_cause_category,
    preventable_issue,
    follow_up_required,
    cost_to_resolve,
    load_date,
    update_date,
    source_system
FROM support_metrics_transformations
ORDER BY ticket_created_date DESC, ticket_created_timestamp DESC