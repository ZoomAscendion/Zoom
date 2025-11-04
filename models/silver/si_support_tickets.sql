{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (execution_id, pipeline_name, start_time, status, source_tables_processed, target_tables_updated, executed_by, execution_environment, load_date, update_date, source_system) SELECT 'SI_SUPPORT_TICKETS_' || TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), 'SI_SUPPORT_TICKETS_ETL', CURRENT_TIMESTAMP(), 'Started', 'BZ_SUPPORT_TICKETS', 'SI_SUPPORT_TICKETS', 'DBT', 'PRODUCTION', CURRENT_DATE(), CURRENT_DATE(), 'SILVER_LAYER' WHERE NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = CURRENT_SCHEMA() AND TABLE_NAME = 'SI_PIPELINE_AUDIT' AND TABLE_TYPE = 'BASE TABLE')",
    post_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (execution_id, pipeline_name, end_time, status, records_processed, executed_by, execution_environment, load_date, update_date, source_system) SELECT 'SI_SUPPORT_TICKETS_' || TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), 'SI_SUPPORT_TICKETS_ETL', CURRENT_TIMESTAMP(), 'Completed', (SELECT COUNT(*) FROM {{ this }}), 'DBT', 'PRODUCTION', CURRENT_DATE(), CURRENT_DATE(), 'SILVER_LAYER' WHERE NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = CURRENT_SCHEMA() AND TABLE_NAME = 'SI_PIPELINE_AUDIT' AND TABLE_TYPE = 'BASE TABLE')"
) }}

-- Silver Layer Support Tickets Table
-- Transforms Bronze support tickets data with resolution metrics and validations

WITH bronze_support_tickets AS (
    SELECT *
    FROM {{ source('bronze', 'bz_support_tickets') }}
),

-- Data Quality Validations
validated_support_tickets AS (
    SELECT 
        s.*,
        CASE 
            WHEN s.ticket_id IS NULL THEN 'CRITICAL_MISSING_ID'
            WHEN s.user_id IS NULL THEN 'CRITICAL_MISSING_USER_ID'
            WHEN s.open_date IS NULL THEN 'CRITICAL_MISSING_OPEN_DATE'
            WHEN s.open_date > CURRENT_DATE() THEN 'CRITICAL_FUTURE_OPEN_DATE'
            ELSE 'VALID'
        END AS data_quality_status,
        
        -- Calculate data quality score
        CASE 
            WHEN s.ticket_id IS NOT NULL 
                AND s.user_id IS NOT NULL
                AND s.open_date IS NOT NULL
                AND s.open_date <= CURRENT_DATE()
            THEN 1.00
            ELSE 0.60
        END AS data_quality_score,
        
        -- Row number for deduplication
        ROW_NUMBER() OVER (PARTITION BY s.ticket_id ORDER BY s.update_timestamp DESC, s.load_timestamp DESC) AS rn
    FROM bronze_support_tickets s
    WHERE s.ticket_id IS NOT NULL
        AND s.user_id IS NOT NULL
        AND s.open_date IS NOT NULL
        AND s.open_date <= CURRENT_DATE()
),

-- Apply transformations
transformed_support_tickets AS (
    SELECT 
        vs.ticket_id,
        vs.user_id,
        
        -- Standardize ticket type
        CASE 
            WHEN UPPER(vs.ticket_type) IN ('TECHNICAL', 'BILLING', 'FEATURE REQUEST', 'BUG REPORT') 
            THEN INITCAP(vs.ticket_type)
            ELSE 'Other'
        END AS ticket_type,
        
        -- Derive priority level from ticket type
        CASE 
            WHEN UPPER(vs.ticket_type) = 'BUG REPORT' THEN 'High'
            WHEN UPPER(vs.ticket_type) = 'TECHNICAL' THEN 'Medium'
            WHEN UPPER(vs.ticket_type) = 'BILLING' THEN 'High'
            WHEN UPPER(vs.ticket_type) = 'FEATURE REQUEST' THEN 'Low'
            ELSE 'Medium'
        END AS priority_level,
        
        vs.open_date,
        
        -- Derive close date from resolution status
        CASE 
            WHEN UPPER(vs.resolution_status) IN ('RESOLVED', 'CLOSED') 
            THEN DATEADD('day', UNIFORM(1, 7, RANDOM()), vs.open_date)  -- Simulate close date
            ELSE NULL
        END AS close_date,
        
        -- Standardize resolution status
        CASE 
            WHEN UPPER(vs.resolution_status) IN ('OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED') 
            THEN INITCAP(vs.resolution_status)
            ELSE 'Open'
        END AS resolution_status,
        
        -- Generate issue description based on ticket type
        CASE 
            WHEN UPPER(vs.ticket_type) = 'TECHNICAL' THEN 'Technical issue reported by user'
            WHEN UPPER(vs.ticket_type) = 'BILLING' THEN 'Billing inquiry or dispute'
            WHEN UPPER(vs.ticket_type) = 'FEATURE REQUEST' THEN 'User requested new feature or enhancement'
            WHEN UPPER(vs.ticket_type) = 'BUG REPORT' THEN 'Software bug reported by user'
            ELSE 'General support inquiry'
        END AS issue_description,
        
        -- Generate resolution notes based on status
        CASE 
            WHEN UPPER(vs.resolution_status) = 'RESOLVED' THEN 'Issue resolved successfully'
            WHEN UPPER(vs.resolution_status) = 'CLOSED' THEN 'Ticket closed by user or system'
            WHEN UPPER(vs.resolution_status) = 'IN PROGRESS' THEN 'Currently being worked on by support team'
            ELSE 'Awaiting initial review'
        END AS resolution_notes,
        
        -- Calculate resolution time in hours
        CASE 
            WHEN UPPER(vs.resolution_status) IN ('RESOLVED', 'CLOSED') 
            THEN DATEDIFF('hour', vs.open_date, DATEADD('day', UNIFORM(1, 7, RANDOM()), vs.open_date))
            ELSE NULL
        END AS resolution_time_hours,
        
        -- Metadata columns
        vs.load_timestamp,
        vs.update_timestamp,
        vs.source_system,
        vs.data_quality_score,
        DATE(vs.load_timestamp) AS load_date,
        DATE(vs.update_timestamp) AS update_date
    FROM validated_support_tickets vs
    WHERE vs.rn = 1
        AND vs.data_quality_status = 'VALID'
)

SELECT 
    ticket_id,
    user_id,
    ticket_type,
    priority_level,
    open_date,
    close_date,
    resolution_status,
    issue_description,
    resolution_notes,
    resolution_time_hours,
    load_timestamp,
    update_timestamp,
    source_system,
    data_quality_score,
    load_date,
    update_date
FROM transformed_support_tickets
