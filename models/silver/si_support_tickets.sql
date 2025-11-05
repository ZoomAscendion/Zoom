{{ config(
    materialized='table'
) }}

WITH bronze_support_tickets AS (
    SELECT *
    FROM {{ source('bronze', 'bz_support_tickets') }}
),

data_quality_checks AS (
    SELECT 
        *,
        -- User ID validation
        CASE 
            WHEN user_id IS NOT NULL THEN 1
            ELSE 0
        END AS user_quality,
        
        -- Ticket type validation
        CASE 
            WHEN ticket_type IN ('Technical', 'Billing', 'Feature Request', 'Bug Report') THEN 1
            ELSE 0
        END AS type_quality,
        
        -- Date validation
        CASE 
            WHEN open_date IS NOT NULL AND open_date <= CURRENT_DATE() THEN 1
            ELSE 0
        END AS date_quality,
        
        -- Status validation
        CASE 
            WHEN resolution_status IN ('Open', 'In Progress', 'Resolved', 'Closed') THEN 1
            ELSE 0
        END AS status_quality
    FROM bronze_support_tickets
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER(
            PARTITION BY ticket_id 
            ORDER BY load_timestamp DESC, update_timestamp DESC
        ) AS rn
    FROM data_quality_checks
),

final_transformation AS (
    SELECT 
        ticket_id,
        user_id,
        CASE 
            WHEN ticket_type IN ('Technical', 'Billing', 'Feature Request', 'Bug Report') THEN ticket_type
            ELSE 'General'
        END AS ticket_type,
        CASE 
            WHEN ticket_type = 'Technical' THEN 'High'
            WHEN ticket_type = 'Billing' THEN 'Critical'
            WHEN ticket_type = 'Bug Report' THEN 'High'
            ELSE 'Medium'
        END AS priority_level,
        CASE 
            WHEN open_date > CURRENT_DATE() THEN CURRENT_DATE()
            ELSE open_date
        END AS open_date,
        CASE 
            WHEN resolution_status IN ('Resolved', 'Closed') THEN DATEADD('day', 3, open_date)
            ELSE NULL
        END AS close_date,
        CASE 
            WHEN resolution_status IN ('Open', 'In Progress', 'Resolved', 'Closed') THEN resolution_status
            ELSE 'Open'
        END AS resolution_status,
        CASE 
            WHEN ticket_type = 'Technical' THEN 'Technical issue reported by user'
            WHEN ticket_type = 'Billing' THEN 'Billing inquiry or dispute'
            WHEN ticket_type = 'Feature Request' THEN 'User requested new feature'
            WHEN ticket_type = 'Bug Report' THEN 'Bug or system issue reported'
            ELSE 'General support request'
        END AS issue_description,
        CASE 
            WHEN resolution_status = 'Resolved' THEN 'Issue resolved successfully'
            WHEN resolution_status = 'Closed' THEN 'Ticket closed'
            ELSE 'In progress'
        END AS resolution_notes,
        CASE 
            WHEN resolution_status IN ('Resolved', 'Closed') THEN DATEDIFF('hour', open_date, DATEADD('day', 3, open_date))
            ELSE NULL
        END AS resolution_time_hours,
        load_timestamp,
        update_timestamp,
        source_system,
        -- Calculate data quality score
        ROUND(
            (user_quality + type_quality + date_quality + status_quality) / 4.0, 2
        ) AS data_quality_score,
        DATE(load_timestamp) AS load_date,
        DATE(update_timestamp) AS update_date
    FROM deduplication
    WHERE rn = 1
      AND ticket_id IS NOT NULL
      AND user_id IS NOT NULL
      AND open_date IS NOT NULL
)

SELECT * FROM final_transformation
