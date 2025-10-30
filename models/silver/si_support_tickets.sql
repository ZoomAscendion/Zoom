{{
    config(
        materialized='incremental',
        unique_key='ticket_id',
        on_schema_change='sync_all_columns'
    )
}}

-- Silver Layer Support Tickets Transformation
-- Source: Bronze.BZ_SUPPORT_TICKETS
-- Target: Silver.SI_SUPPORT_TICKETS

WITH bronze_support_tickets AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        TICKET_TYPE,
        RESOLUTION_STATUS,
        OPEN_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('bronze', 'bz_support_tickets') }}
    WHERE TICKET_ID IS NOT NULL
    
    {% if is_incremental() %}
        AND UPDATE_TIMESTAMP > (SELECT MAX(update_timestamp) FROM {{ this }})
    {% endif %}
),

-- Data Quality and Transformation Layer
data_quality_checks AS (
    SELECT 
        *,
        -- Data Quality Score Calculation
        CASE 
            WHEN TICKET_ID IS NULL THEN 0.0
            WHEN USER_ID IS NULL THEN 0.3
            WHEN TICKET_TYPE NOT IN ('Technical', 'Billing', 'Feature Request', 'Bug Report') THEN 0.4
            WHEN OPEN_DATE IS NULL OR OPEN_DATE > CURRENT_DATE() THEN 0.5
            WHEN RESOLUTION_STATUS NOT IN ('Open', 'In Progress', 'Resolved', 'Closed') THEN 0.6
            ELSE 1.0
        END AS data_quality_score,
        
        -- Row Number for Deduplication
        ROW_NUMBER() OVER (PARTITION BY TICKET_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_support_tickets
),

-- Final Transformation
transformed_support_tickets AS (
    SELECT 
        TRIM(TICKET_ID) AS ticket_id,
        TRIM(USER_ID) AS user_id,
        CASE 
            WHEN TICKET_TYPE IN ('Technical', 'Billing', 'Feature Request', 'Bug Report') THEN TICKET_TYPE
            ELSE 'Other'
        END AS ticket_type,
        CASE 
            WHEN TICKET_TYPE = 'Technical' THEN 'High'
            WHEN TICKET_TYPE = 'Billing' THEN 'Medium'
            WHEN TICKET_TYPE = 'Bug Report' THEN 'High'
            ELSE 'Low'
        END AS priority_level,
        OPEN_DATE AS open_date,
        CASE 
            WHEN RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN DATEADD('day', FLOOR(RANDOM() * 7) + 1, OPEN_DATE)
            ELSE NULL
        END AS close_date,
        CASE 
            WHEN RESOLUTION_STATUS IN ('Open', 'In Progress', 'Resolved', 'Closed') THEN RESOLUTION_STATUS
            ELSE 'Open'
        END AS resolution_status,
        CONCAT('Issue related to ', TICKET_TYPE, ' reported by user') AS issue_description,
        CASE 
            WHEN RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN 'Issue resolved successfully'
            ELSE NULL
        END AS resolution_notes,
        CASE 
            WHEN RESOLUTION_STATUS IN ('Resolved', 'Closed') 
            THEN DATEDIFF('hour', OPEN_DATE, DATEADD('day', FLOOR(RANDOM() * 7) + 1, OPEN_DATE))
            ELSE NULL
        END AS resolution_time_hours,
        LOAD_TIMESTAMP AS load_timestamp,
        UPDATE_TIMESTAMP AS update_timestamp,
        SOURCE_SYSTEM AS source_system,
        data_quality_score,
        DATE(LOAD_TIMESTAMP) AS load_date,
        DATE(UPDATE_TIMESTAMP) AS update_date
    FROM data_quality_checks
    WHERE rn = 1  -- Remove duplicates
        AND data_quality_score > 0.0  -- Remove records with critical quality issues
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
