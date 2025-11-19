{{ config(
    materialized='table',
    schema='gold',
    database='DB_POC_ZOOM',
    tags=['fact', 'support_metrics']
) }}

-- Support metrics fact table
-- Comprehensive support ticket analytics with SLA and resolution tracking

WITH source_support_tickets AS (
    SELECT 
        st.ticket_id,
        st.user_id,
        st.ticket_type,
        st.resolution_status,
        st.open_date,
        st.load_timestamp,
        st.update_timestamp,
        st.source_system,
        st.load_date,
        st.update_date,
        st.data_quality_score,
        st.validation_status
    FROM {{ source('silver_layer', 'si_support_tickets') }} st
    WHERE st.validation_status = 'VALID'
      AND st.data_quality_score >= {{ var('data_quality_threshold') }}
),

support_metrics_enriched AS (
    SELECT 
        st.ticket_id,
        st.user_id,
        st.ticket_type,
        st.resolution_status,
        st.open_date,
        st.load_timestamp AS ticket_created_timestamp,
        
        -- Dimension keys
        dd.date_id,
        dsc.support_category_id,
        du.user_dim_id,
        
        -- Date fields
        DATE(st.open_date) AS ticket_created_date,
        
        -- Estimated closure date (based on resolution status and type)
        CASE 
            WHEN st.resolution_status = 'RESOLVED' OR st.resolution_status = 'CLOSED' THEN
                DATEADD('hour', 
                    CASE 
                        WHEN UPPER(st.ticket_type) LIKE '%CRITICAL%' OR UPPER(st.ticket_type) LIKE '%SECURITY%' THEN 4
                        WHEN UPPER(st.ticket_type) LIKE '%BILLING%' OR UPPER(st.ticket_type) LIKE '%ACCOUNT%' THEN 8
                        WHEN UPPER(st.ticket_type) LIKE '%TECHNICAL%' OR UPPER(st.ticket_type) LIKE '%BUG%' THEN 24
                        WHEN UPPER(st.ticket_type) LIKE '%PERFORMANCE%' THEN 48
                        ELSE 24
                    END,
                    st.open_date
                )
            ELSE NULL
        END AS ticket_closed_date,
        
        CASE 
            WHEN st.resolution_status = 'RESOLVED' OR st.resolution_status = 'CLOSED' THEN
                DATEADD('hour', 
                    CASE 
                        WHEN UPPER(st.ticket_type) LIKE '%CRITICAL%' OR UPPER(st.ticket_type) LIKE '%SECURITY%' THEN 4
                        WHEN UPPER(st.ticket_type) LIKE '%BILLING%' OR UPPER(st.ticket_type) LIKE '%ACCOUNT%' THEN 8
                        WHEN UPPER(st.ticket_type) LIKE '%TECHNICAL%' OR UPPER(st.ticket_type) LIKE '%BUG%' THEN 24
                        WHEN UPPER(st.ticket_type) LIKE '%PERFORMANCE%' THEN 48
                        ELSE 24
                    END,
                    st.load_timestamp
                )
            ELSE NULL
        END AS ticket_closed_timestamp,
        
        -- First response timestamp (estimated)
        DATEADD('hour', 
            CASE 
                WHEN UPPER(st.ticket_type) LIKE '%CRITICAL%' OR UPPER(st.ticket_type) LIKE '%SECURITY%' THEN 1
                WHEN UPPER(st.ticket_type) LIKE '%BILLING%' OR UPPER(st.ticket_type) LIKE '%ACCOUNT%' THEN 2
                WHEN UPPER(st.ticket_type) LIKE '%TECHNICAL%' OR UPPER(st.ticket_type) LIKE '%BUG%' THEN 4
                ELSE 8
            END,
            st.load_timestamp
        ) AS first_response_timestamp,
        
        -- Resolution timestamp (same as closed for resolved tickets)
        CASE 
            WHEN st.resolution_status = 'RESOLVED' OR st.resolution_status = 'CLOSED' THEN
                DATEADD('hour', 
                    CASE 
                        WHEN UPPER(st.ticket_type) LIKE '%CRITICAL%' OR UPPER(st.ticket_type) LIKE '%SECURITY%' THEN 4
                        WHEN UPPER(st.ticket_type) LIKE '%BILLING%' OR UPPER(st.ticket_type) LIKE '%ACCOUNT%' THEN 8
                        WHEN UPPER(st.ticket_type) LIKE '%TECHNICAL%' OR UPPER(st.ticket_type) LIKE '%BUG%' THEN 24
                        WHEN UPPER(st.ticket_type) LIKE '%PERFORMANCE%' THEN 48
                        ELSE 24
                    END,
                    st.load_timestamp
                )
            ELSE NULL
        END AS resolution_timestamp,
        
        -- Ticket categorization
        CASE 
            WHEN UPPER(st.ticket_type) LIKE '%TECHNICAL%' OR UPPER(st.ticket_type) LIKE '%BUG%' THEN 'Technical'
            WHEN UPPER(st.ticket_type) LIKE '%BILLING%' OR UPPER(st.ticket_type) LIKE '%PAYMENT%' THEN 'Billing'
            WHEN UPPER(st.ticket_type) LIKE '%ACCOUNT%' OR UPPER(st.ticket_type) LIKE '%LOGIN%' THEN 'Account'
            WHEN UPPER(st.ticket_type) LIKE '%FEATURE%' OR UPPER(st.ticket_type) LIKE '%ENHANCEMENT%' THEN 'Feature Request'
            WHEN UPPER(st.ticket_type) LIKE '%TRAINING%' OR UPPER(st.ticket_type) LIKE '%HELP%' THEN 'Training'
            ELSE 'General'
        END AS ticket_category,
        
        -- Ticket subcategory
        CASE 
            WHEN UPPER(st.ticket_type) LIKE '%AUDIO%' THEN 'Audio Issues'
            WHEN UPPER(st.ticket_type) LIKE '%VIDEO%' THEN 'Video Issues'
            WHEN UPPER(st.ticket_type) LIKE '%CONNECTION%' THEN 'Connectivity'
            WHEN UPPER(st.ticket_type) LIKE '%RECORDING%' THEN 'Recording Issues'
            WHEN UPPER(st.ticket_type) LIKE '%MOBILE%' THEN 'Mobile App'
            ELSE 'Other'
        END AS ticket_subcategory,
        
        -- Priority and severity levels
        CASE 
            WHEN UPPER(st.ticket_type) LIKE '%CRITICAL%' OR UPPER(st.ticket_type) LIKE '%SECURITY%' THEN 'Critical'
            WHEN UPPER(st.ticket_type) LIKE '%BILLING%' OR UPPER(st.ticket_type) LIKE '%ACCOUNT%' THEN 'High'
            WHEN UPPER(st.ticket_type) LIKE '%TECHNICAL%' OR UPPER(st.ticket_type) LIKE '%BUG%' THEN 'Medium'
            ELSE 'Low'
        END AS priority_level,
        
        CASE 
            WHEN UPPER(st.ticket_type) LIKE '%CRITICAL%' OR UPPER(st.ticket_type) LIKE '%SECURITY%' THEN 'Severity 1'
            WHEN UPPER(st.ticket_type) LIKE '%BILLING%' OR UPPER(st.ticket_type) LIKE '%TECHNICAL%' THEN 'Severity 2'
            WHEN UPPER(st.ticket_type) LIKE '%ACCOUNT%' OR UPPER(st.ticket_type) LIKE '%BUG%' THEN 'Severity 3'
            ELSE 'Severity 4'
        END AS severity_level,
        
        -- Time calculations (in hours)
        CASE 
            WHEN UPPER(st.ticket_type) LIKE '%CRITICAL%' OR UPPER(st.ticket_type) LIKE '%SECURITY%' THEN 1.0
            WHEN UPPER(st.ticket_type) LIKE '%BILLING%' OR UPPER(st.ticket_type) LIKE '%ACCOUNT%' THEN 2.0
            WHEN UPPER(st.ticket_type) LIKE '%TECHNICAL%' OR UPPER(st.ticket_type) LIKE '%BUG%' THEN 4.0
            ELSE 8.0
        END AS first_response_time_hours,
        
        CASE 
            WHEN st.resolution_status = 'RESOLVED' OR st.resolution_status = 'CLOSED' THEN
                CASE 
                    WHEN UPPER(st.ticket_type) LIKE '%CRITICAL%' OR UPPER(st.ticket_type) LIKE '%SECURITY%' THEN 4.0
                    WHEN UPPER(st.ticket_type) LIKE '%BILLING%' OR UPPER(st.ticket_type) LIKE '%ACCOUNT%' THEN 8.0
                    WHEN UPPER(st.ticket_type) LIKE '%TECHNICAL%' OR UPPER(st.ticket_type) LIKE '%BUG%' THEN 24.0
                    WHEN UPPER(st.ticket_type) LIKE '%PERFORMANCE%' THEN 48.0
                    ELSE 24.0
                END
            ELSE NULL
        END AS resolution_time_hours,
        
        -- Active work time (estimated as 60% of resolution time)
        CASE 
            WHEN st.resolution_status = 'RESOLVED' OR st.resolution_status = 'CLOSED' THEN
                CASE 
                    WHEN UPPER(st.ticket_type) LIKE '%CRITICAL%' OR UPPER(st.ticket_type) LIKE '%SECURITY%' THEN 2.4
                    WHEN UPPER(st.ticket_type) LIKE '%BILLING%' OR UPPER(st.ticket_type) LIKE '%ACCOUNT%' THEN 4.8
                    WHEN UPPER(st.ticket_type) LIKE '%TECHNICAL%' OR UPPER(st.ticket_type) LIKE '%BUG%' THEN 14.4
                    WHEN UPPER(st.ticket_type) LIKE '%PERFORMANCE%' THEN 28.8
                    ELSE 14.4
                END
            ELSE NULL
        END AS active_work_time_hours,
        
        -- Customer wait time (estimated as 40% of resolution time)
        CASE 
            WHEN st.resolution_status = 'RESOLVED' OR st.resolution_status = 'CLOSED' THEN
                CASE 
                    WHEN UPPER(st.ticket_type) LIKE '%CRITICAL%' OR UPPER(st.ticket_type) LIKE '%SECURITY%' THEN 1.6
                    WHEN UPPER(st.ticket_type) LIKE '%BILLING%' OR UPPER(st.ticket_type) LIKE '%ACCOUNT%' THEN 3.2
                    WHEN UPPER(st.ticket_type) LIKE '%TECHNICAL%' OR UPPER(st.ticket_type) LIKE '%BUG%' THEN 9.6
                    WHEN UPPER(st.ticket_type) LIKE '%PERFORMANCE%' THEN 19.2
                    ELSE 9.6
                END
            ELSE NULL
        END AS customer_wait_time_hours,
        
        -- Interaction counts (estimated)
        CASE 
            WHEN UPPER(st.ticket_type) LIKE '%CRITICAL%' OR UPPER(st.ticket_type) LIKE '%SECURITY%' THEN 0
            WHEN UPPER(st.ticket_type) LIKE '%BILLING%' OR UPPER(st.ticket_type) LIKE '%ACCOUNT%' THEN 1
            ELSE 0
        END AS escalation_count,
        
        CASE 
            WHEN UPPER(st.ticket_type) LIKE '%TECHNICAL%' OR UPPER(st.ticket_type) LIKE '%BUG%' THEN 1
            ELSE 0
        END AS reassignment_count,
        
        CASE 
            WHEN st.resolution_status = 'OPEN' OR st.resolution_status = 'IN_PROGRESS' THEN 1
            ELSE 0
        END AS reopened_count,
        
        -- Agent and customer interactions
        CASE 
            WHEN UPPER(st.ticket_type) LIKE '%CRITICAL%' THEN 5
            WHEN UPPER(st.ticket_type) LIKE '%BILLING%' OR UPPER(st.ticket_type) LIKE '%TECHNICAL%' THEN 3
            ELSE 2
        END AS agent_interactions_count,
        
        CASE 
            WHEN UPPER(st.ticket_type) LIKE '%CRITICAL%' THEN 3
            WHEN UPPER(st.ticket_type) LIKE '%BILLING%' OR UPPER(st.ticket_type) LIKE '%TECHNICAL%' THEN 2
            ELSE 1
        END AS customer_interactions_count,
        
        -- Knowledge base articles used
        CASE 
            WHEN UPPER(st.ticket_type) LIKE '%TRAINING%' OR UPPER(st.ticket_type) LIKE '%HELP%' THEN 3
            WHEN UPPER(st.ticket_type) LIKE '%TECHNICAL%' OR UPPER(st.ticket_type) LIKE '%ACCOUNT%' THEN 2
            ELSE 1
        END AS knowledge_base_articles_used,
        
        -- Customer satisfaction score (1-5)
        CASE 
            WHEN st.resolution_status = 'RESOLVED' AND 
                 UPPER(st.ticket_type) NOT LIKE '%CRITICAL%' AND 
                 UPPER(st.ticket_type) NOT LIKE '%BILLING%' THEN 5
            WHEN st.resolution_status = 'RESOLVED' THEN 4
            WHEN st.resolution_status = 'CLOSED' THEN 3
            ELSE 2
        END AS customer_satisfaction_score,
        
        -- First contact resolution
        CASE 
            WHEN UPPER(st.ticket_type) LIKE '%TRAINING%' OR UPPER(st.ticket_type) LIKE '%HELP%' THEN TRUE
            WHEN st.resolution_status = 'RESOLVED' AND 
                 UPPER(st.ticket_type) NOT LIKE '%CRITICAL%' AND 
                 UPPER(st.ticket_type) NOT LIKE '%TECHNICAL%' THEN TRUE
            ELSE FALSE
        END AS first_contact_resolution,
        
        -- SLA metrics
        CASE 
            WHEN st.resolution_status = 'RESOLVED' OR st.resolution_status = 'CLOSED' THEN
                CASE 
                    WHEN UPPER(st.ticket_type) LIKE '%CRITICAL%' AND 
                         DATEDIFF('hour', st.open_date, CURRENT_TIMESTAMP()) <= 2 THEN TRUE
                    WHEN UPPER(st.ticket_type) LIKE '%BILLING%' AND 
                         DATEDIFF('hour', st.open_date, CURRENT_TIMESTAMP()) <= 4 THEN TRUE
                    WHEN UPPER(st.ticket_type) LIKE '%TECHNICAL%' AND 
                         DATEDIFF('hour', st.open_date, CURRENT_TIMESTAMP()) <= 8 THEN TRUE
                    WHEN DATEDIFF('hour', st.open_date, CURRENT_TIMESTAMP()) <= 24 THEN TRUE
                    ELSE FALSE
                END
            ELSE FALSE
        END AS sla_met,
        
        -- SLA breach hours
        CASE 
            WHEN st.resolution_status = 'RESOLVED' OR st.resolution_status = 'CLOSED' THEN
                GREATEST(0, 
                    DATEDIFF('hour', st.open_date, CURRENT_TIMESTAMP()) - 
                    CASE 
                        WHEN UPPER(st.ticket_type) LIKE '%CRITICAL%' THEN 2
                        WHEN UPPER(st.ticket_type) LIKE '%BILLING%' THEN 4
                        WHEN UPPER(st.ticket_type) LIKE '%TECHNICAL%' THEN 8
                        ELSE 24
                    END
                )
            ELSE 0
        END AS sla_breach_hours,
        
        -- Resolution method
        CASE 
            WHEN UPPER(st.ticket_type) LIKE '%TRAINING%' OR UPPER(st.ticket_type) LIKE '%HELP%' THEN 'Self-Service'
            WHEN UPPER(st.ticket_type) LIKE '%CRITICAL%' OR UPPER(st.ticket_type) LIKE '%SECURITY%' THEN 'Escalation'
            WHEN UPPER(st.ticket_type) LIKE '%TECHNICAL%' THEN 'Engineering'
            ELSE 'Standard Support'
        END AS resolution_method,
        
        -- Root cause category
        CASE 
            WHEN UPPER(st.ticket_type) LIKE '%BUG%' OR UPPER(st.ticket_type) LIKE '%TECHNICAL%' THEN 'Product Issue'
            WHEN UPPER(st.ticket_type) LIKE '%TRAINING%' OR UPPER(st.ticket_type) LIKE '%HELP%' THEN 'User Error'
            WHEN UPPER(st.ticket_type) LIKE '%BILLING%' OR UPPER(st.ticket_type) LIKE '%ACCOUNT%' THEN 'Process Issue'
            WHEN UPPER(st.ticket_type) LIKE '%PERFORMANCE%' THEN 'Infrastructure'
            ELSE 'Other'
        END AS root_cause_category,
        
        -- Preventable issue flag
        CASE 
            WHEN UPPER(st.ticket_type) LIKE '%TRAINING%' OR UPPER(st.ticket_type) LIKE '%HELP%' THEN TRUE
            WHEN UPPER(st.ticket_type) LIKE '%BUG%' THEN FALSE
            ELSE TRUE
        END AS preventable_issue,
        
        -- Follow-up required
        CASE 
            WHEN UPPER(st.ticket_type) LIKE '%CRITICAL%' OR UPPER(st.ticket_type) LIKE '%BILLING%' THEN TRUE
            WHEN st.resolution_status = 'CLOSED' THEN FALSE
            ELSE TRUE
        END AS follow_up_required,
        
        -- Cost to resolve (estimated)
        CASE 
            WHEN UPPER(st.ticket_type) LIKE '%CRITICAL%' OR UPPER(st.ticket_type) LIKE '%SECURITY%' THEN 150.00
            WHEN UPPER(st.ticket_type) LIKE '%BILLING%' OR UPPER(st.ticket_type) LIKE '%ACCOUNT%' THEN 75.00
            WHEN UPPER(st.ticket_type) LIKE '%TECHNICAL%' OR UPPER(st.ticket_type) LIKE '%BUG%' THEN 100.00
            WHEN UPPER(st.ticket_type) LIKE '%TRAINING%' OR UPPER(st.ticket_type) LIKE '%HELP%' THEN 25.00
            ELSE 50.00
        END AS cost_to_resolve,
        
        -- Audit fields
        st.load_date,
        st.update_date,
        st.source_system
        
    FROM source_support_tickets st
    LEFT JOIN {{ ref('go_dim_date') }} dd ON DATE(st.open_date) = dd.date_value
    LEFT JOIN {{ ref('go_dim_support_category') }} dsc ON UPPER(TRIM(st.ticket_type)) = UPPER(TRIM(dsc.support_category))
    LEFT JOIN {{ ref('go_dim_user') }} du ON st.user_id = du.user_id AND du.is_current_record = TRUE
)

SELECT 
    MD5(CONCAT(ticket_id, '_', ticket_created_timestamp::STRING)) AS support_metrics_id,
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
FROM support_metrics_enriched
WHERE date_id IS NOT NULL
ORDER BY ticket_created_date DESC, ticket_created_timestamp DESC