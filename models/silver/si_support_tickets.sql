{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (execution_id, pipeline_name, start_time, status, source_tables_processed, target_tables_updated, executed_by, execution_environment, load_date, update_date, source_system) SELECT 'EXEC_SI_SUPPORT_TICKETS_' || TO_VARCHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), 'SI_SUPPORT_TICKETS_TRANSFORMATION', CURRENT_TIMESTAMP(), 'STARTED', 'BZ_SUPPORT_TICKETS', 'SI_SUPPORT_TICKETS', 'DBT_PIPELINE', 'PRODUCTION', CURRENT_DATE(), CURRENT_DATE(), 'DBT_PIPELINE' WHERE NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = CURRENT_SCHEMA() AND TABLE_NAME = 'SI_PIPELINE_AUDIT')",
    post_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (execution_id, pipeline_name, end_time, status, records_processed, records_inserted, executed_by, execution_environment, load_date, update_date, source_system) SELECT 'EXEC_SI_SUPPORT_TICKETS_' || TO_VARCHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), 'SI_SUPPORT_TICKETS_TRANSFORMATION', CURRENT_TIMESTAMP(), 'COMPLETED', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 'DBT_PIPELINE', 'PRODUCTION', CURRENT_DATE(), CURRENT_DATE(), 'DBT_PIPELINE' WHERE NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = CURRENT_SCHEMA() AND TABLE_NAME = 'SI_PIPELINE_AUDIT')"
) }}

-- Silver Support Tickets Model
-- Transforms bronze support ticket data with enrichment and standardization

WITH bronze_support_tickets AS (
    SELECT * FROM {{ source('bronze', 'bz_support_tickets') }}
),

silver_users AS (
    SELECT * FROM {{ ref('si_users') }}
),

-- Data Quality Validation
data_quality_checks AS (
    SELECT 
        *,
        -- Date validation
        CASE 
            WHEN open_date > CURRENT_DATE() + INTERVAL '1' DAY THEN 'FUTURE_OPEN_DATE'
            ELSE 'VALID'
        END AS date_quality_flag,
        
        -- Status validation
        CASE 
            WHEN resolution_status NOT IN ('Open', 'In Progress', 'Resolved', 'Closed') THEN 'INVALID_STATUS'
            ELSE 'VALID'
        END AS status_quality_flag,
        
        -- Type validation
        CASE 
            WHEN ticket_type NOT IN ('Technical', 'Billing', 'Feature Request', 'Bug Report') THEN 'INVALID_TYPE'
            ELSE 'VALID'
        END AS type_quality_flag
    FROM bronze_support_tickets
    WHERE ticket_id IS NOT NULL
      AND user_id IS NOT NULL  -- Block tickets without user association
),

-- Data Cleansing and Enrichment
cleansed_support_tickets AS (
    SELECT 
        s.ticket_id,
        s.user_id,
        
        -- Standardized ticket type
        CASE 
            WHEN s.type_quality_flag = 'VALID' THEN s.ticket_type
            ELSE 'General Inquiry'
        END AS ticket_type,
        
        -- Derived priority level
        CASE 
            WHEN s.ticket_type = 'Bug Report' THEN 'High'
            WHEN s.ticket_type = 'Technical' THEN 'Medium'
            WHEN s.ticket_type = 'Billing' THEN 'High'
            WHEN s.ticket_type = 'Feature Request' THEN 'Low'
            ELSE 'Medium'
        END AS priority_level,
        
        -- Corrected open date
        CASE 
            WHEN s.date_quality_flag = 'FUTURE_OPEN_DATE' THEN CURRENT_DATE()
            ELSE s.open_date
        END AS open_date,
        
        -- Derived close date
        CASE 
            WHEN s.resolution_status IN ('Resolved', 'Closed') 
            THEN s.open_date + INTERVAL '7' DAY  -- Default 7-day resolution
            ELSE NULL
        END AS close_date,
        
        -- Standardized resolution status
        CASE 
            WHEN s.status_quality_flag = 'VALID' THEN s.resolution_status
            ELSE 'Open'
        END AS resolution_status,
        
        -- Generated descriptions
        'Issue reported for ' || s.ticket_type || ' category' AS issue_description,
        CASE 
            WHEN s.resolution_status IN ('Resolved', 'Closed') 
            THEN 'Ticket resolved through standard support process'
            ELSE NULL
        END AS resolution_notes,
        
        -- Calculated resolution time
        CASE 
            WHEN s.resolution_status IN ('Resolved', 'Closed')
            THEN DATEDIFF('hour', s.open_date, s.open_date + INTERVAL '7' DAY)
            ELSE NULL
        END AS resolution_time_hours,
        
        -- Silver layer metadata
        s.load_timestamp,
        s.update_timestamp,
        s.source_system,
        
        -- Data quality score
        ROUND(
            (CASE WHEN s.date_quality_flag = 'VALID' THEN 0.3 ELSE 0.0 END +
             CASE WHEN s.status_quality_flag = 'VALID' THEN 0.3 ELSE 0.0 END +
             CASE WHEN s.type_quality_flag = 'VALID' THEN 0.2 ELSE 0.0 END +
             CASE WHEN u.user_id IS NOT NULL THEN 0.2 ELSE 0.0 END), 2
        ) AS data_quality_score,
        
        -- Standard metadata
        DATE(s.load_timestamp) AS load_date,
        DATE(s.update_timestamp) AS update_date
        
    FROM data_quality_checks s
    LEFT JOIN silver_users u ON s.user_id = u.user_id
    WHERE u.user_id IS NOT NULL  -- Block tickets with invalid user references
),

-- Deduplication
deduped_support_tickets AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY ticket_id ORDER BY update_timestamp DESC) AS rn
    FROM cleansed_support_tickets
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
FROM deduped_support_tickets
WHERE rn = 1
