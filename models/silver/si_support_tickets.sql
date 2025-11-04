{{ config(
    materialized='table'
) }}

-- Silver Layer Support Tickets Transformation
-- Source: Bronze.BZ_SUPPORT_TICKETS
-- Target: Silver.SI_SUPPORT_TICKETS
-- Description: Transforms and standardizes support ticket data with resolution metrics

WITH bronze_support_tickets AS (
    SELECT 
        ticket_id,
        user_id,
        ticket_type,
        resolution_status,
        open_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('bronze', 'bz_support_tickets') }}
    WHERE ticket_id IS NOT NULL
      AND user_id IS NOT NULL
),

-- Data Quality Validation and Cleansing
data_quality_checks AS (
    SELECT 
        ticket_id,
        user_id,
        
        -- Standardize ticket type
        CASE 
            WHEN UPPER(ticket_type) IN ('TECHNICAL', 'BILLING', 'FEATURE REQUEST', 'BUG REPORT') THEN UPPER(ticket_type)
            ELSE 'GENERAL'
        END AS ticket_type_clean,
        
        -- Derive priority level from ticket type
        CASE 
            WHEN UPPER(ticket_type) = 'BUG REPORT' THEN 'High'
            WHEN UPPER(ticket_type) = 'TECHNICAL' THEN 'Medium'
            WHEN UPPER(ticket_type) = 'BILLING' THEN 'High'
            WHEN UPPER(ticket_type) = 'FEATURE REQUEST' THEN 'Low'
            ELSE 'Medium'
        END AS priority_level,
        
        -- Validate open date
        CASE 
            WHEN open_date IS NULL THEN DATE(load_timestamp)
            WHEN open_date > CURRENT_DATE() THEN CURRENT_DATE()
            ELSE open_date
        END AS open_date_clean,
        
        -- Standardize resolution status
        CASE 
            WHEN UPPER(resolution_status) IN ('OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED') THEN UPPER(resolution_status)
            ELSE 'OPEN'
        END AS resolution_status_clean,
        
        load_timestamp,
        update_timestamp,
        source_system
    FROM bronze_support_tickets
),

-- Add derived fields
derived_fields AS (
    SELECT 
        *,
        -- Derive close date based on resolution status
        CASE 
            WHEN resolution_status_clean IN ('RESOLVED', 'CLOSED') THEN DATE(update_timestamp)
            ELSE NULL
        END AS close_date,
        
        -- Generate issue description based on ticket type
        CASE 
            WHEN ticket_type_clean = 'TECHNICAL' THEN 'Technical issue reported by user requiring investigation'
            WHEN ticket_type_clean = 'BILLING' THEN 'Billing inquiry or payment-related issue'
            WHEN ticket_type_clean = 'FEATURE REQUEST' THEN 'User request for new feature or enhancement'
            WHEN ticket_type_clean = 'BUG REPORT' THEN 'Software bug or defect reported by user'
            ELSE 'General support inquiry'
        END AS issue_description,
        
        -- Generate resolution notes based on status
        CASE 
            WHEN resolution_status_clean = 'RESOLVED' THEN 'Issue successfully resolved by support team'
            WHEN resolution_status_clean = 'CLOSED' THEN 'Ticket closed after resolution confirmation'
            WHEN resolution_status_clean = 'IN PROGRESS' THEN 'Issue currently being investigated'
            ELSE 'Ticket awaiting initial review'
        END AS resolution_notes
    FROM data_quality_checks
),

-- Calculate resolution time
resolution_time_calc AS (
    SELECT 
        *,
        -- Calculate resolution time in hours
        CASE 
            WHEN close_date IS NOT NULL THEN 
                DATEDIFF('hour', open_date_clean, close_date)
            ELSE NULL
        END AS resolution_time_hours
    FROM derived_fields
),

-- Calculate data quality score
quality_scored AS (
    SELECT 
        *,
        -- Calculate data quality score
        (
            CASE WHEN ticket_type_clean != 'GENERAL' THEN 0.25 ELSE 0 END +
            CASE WHEN priority_level IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN open_date_clean IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN resolution_status_clean IS NOT NULL THEN 0.25 ELSE 0 END
        ) AS data_quality_score
    FROM resolution_time_calc
),

-- Remove duplicates keeping the most recent record
deduped_support_tickets AS (
    SELECT 
        ticket_id,
        user_id,
        ticket_type_clean AS ticket_type,
        priority_level,
        open_date_clean AS open_date,
        close_date,
        resolution_status_clean AS resolution_status,
        issue_description,
        resolution_notes,
        resolution_time_hours,
        load_timestamp,
        update_timestamp,
        source_system,
        data_quality_score,
        ROW_NUMBER() OVER (PARTITION BY ticket_id ORDER BY update_timestamp DESC) AS rn
    FROM quality_scored
    WHERE data_quality_score >= {{ var('dq_score_threshold') }}
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
    DATE(load_timestamp) AS load_date,
    DATE(update_timestamp) AS update_date
FROM deduped_support_tickets
WHERE rn = 1
  AND open_date IS NOT NULL
