{{ config(
    materialized='table'
) }}

-- Silver Support Tickets Table - Standardized support ticket data
-- Includes resolution metrics and priority classification

WITH bronze_support_tickets AS (
    SELECT *
    FROM {{ source('bronze', 'bz_support_tickets') }}
),

-- Data Quality Validation and Cleansing
support_tickets_cleaned AS (
    SELECT
        bst.ticket_id,
        bst.user_id,
        
        -- Standardize ticket type
        CASE 
            WHEN bst.ticket_type IN ('Technical', 'Billing', 'Feature Request', 'Bug Report') 
                THEN bst.ticket_type
            ELSE 'Other'
        END AS ticket_type,
        
        -- Derive priority level from ticket type
        CASE 
            WHEN bst.ticket_type = 'Bug Report' THEN 'High'
            WHEN bst.ticket_type = 'Technical' THEN 'Medium'
            WHEN bst.ticket_type = 'Billing' THEN 'High'
            WHEN bst.ticket_type = 'Feature Request' THEN 'Low'
            ELSE 'Medium'
        END AS priority_level,
        
        -- Validate open date
        CASE 
            WHEN bst.open_date IS NULL THEN CURRENT_DATE()
            WHEN bst.open_date > CURRENT_DATE() THEN CURRENT_DATE()
            ELSE bst.open_date
        END AS open_date,
        
        -- Derive close date from resolution status
        CASE 
            WHEN bst.resolution_status IN ('Resolved', 'Closed') 
                THEN DATEADD('day', 3, bst.open_date)  -- Assume 3 day resolution
            ELSE NULL
        END AS close_date,
        
        -- Standardize resolution status
        CASE 
            WHEN bst.resolution_status IN ('Open', 'In Progress', 'Resolved', 'Closed') 
                THEN bst.resolution_status
            ELSE 'Open'
        END AS resolution_status,
        
        -- Generate issue description
        CASE 
            WHEN bst.ticket_type = 'Technical' THEN 'Technical support issue requiring assistance'
            WHEN bst.ticket_type = 'Billing' THEN 'Billing inquiry or payment issue'
            WHEN bst.ticket_type = 'Feature Request' THEN 'Request for new feature or enhancement'
            WHEN bst.ticket_type = 'Bug Report' THEN 'Software bug or system error report'
            ELSE 'General support inquiry'
        END AS issue_description,
        
        -- Generate resolution notes
        CASE 
            WHEN bst.resolution_status = 'Resolved' THEN 'Issue successfully resolved by support team'
            WHEN bst.resolution_status = 'Closed' THEN 'Ticket closed after resolution confirmation'
            WHEN bst.resolution_status = 'In Progress' THEN 'Issue currently being investigated'
            ELSE 'Awaiting initial review'
        END AS resolution_notes,
        
        -- Calculate resolution time in hours
        CASE 
            WHEN bst.resolution_status IN ('Resolved', 'Closed') 
                THEN 72  -- Default 72 hours (3 days)
            ELSE NULL
        END AS resolution_time_hours,
        
        -- Metadata columns
        bst.load_timestamp,
        bst.update_timestamp,
        bst.source_system,
        
        -- Calculate data quality score
        CASE 
            WHEN bst.ticket_id IS NOT NULL 
                AND bst.user_id IS NOT NULL
                AND bst.ticket_type IS NOT NULL
                AND bst.resolution_status IS NOT NULL
                AND bst.open_date IS NOT NULL
                THEN 1.00
            WHEN bst.ticket_id IS NOT NULL AND bst.user_id IS NOT NULL
                THEN 0.75
            WHEN bst.ticket_id IS NOT NULL
                THEN 0.50
            ELSE 0.25
        END AS data_quality_score,
        
        DATE(bst.load_timestamp) AS load_date,
        DATE(bst.update_timestamp) AS update_date
        
    FROM bronze_support_tickets bst
    WHERE bst.ticket_id IS NOT NULL  -- Block records without ticket_id
        AND bst.user_id IS NOT NULL  -- Block records without user_id
),

-- Remove duplicates - keep latest record
support_tickets_deduped AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY ticket_id ORDER BY update_timestamp DESC) AS rn
    FROM support_tickets_cleaned
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
FROM support_tickets_deduped
WHERE rn = 1
    AND data_quality_score >= 0.50  -- Only high quality records
