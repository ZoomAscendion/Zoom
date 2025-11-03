{{ config(
    materialized='table'
) }}

-- Pre-hook: Log process start
{% if this.name != 'audit_log' %}
{{ log("Starting transformation for si_support_tickets", info=True) }}
{% endif %}

WITH source_data AS (
    SELECT 
        s.TICKET_ID,
        s.USER_ID,
        s.TICKET_TYPE,
        s.RESOLUTION_STATUS,
        s.OPEN_DATE,
        s.LOAD_TIMESTAMP,
        s.UPDATE_TIMESTAMP,
        s.SOURCE_SYSTEM
    FROM {{ ref('bz_support_tickets') }} s
    WHERE s.TICKET_ID IS NOT NULL
),

data_quality_checks AS (
    SELECT 
        s.*,
        
        -- Ticket type validation
        CASE 
            WHEN s.TICKET_TYPE IN ('Technical', 'Billing', 'Feature Request', 'Bug Report') THEN 1
            ELSE 0
        END AS ticket_type_valid,
        
        -- Resolution status validation
        CASE 
            WHEN s.RESOLUTION_STATUS IN ('Open', 'In Progress', 'Resolved', 'Closed') THEN 1
            ELSE 0
        END AS resolution_status_valid,
        
        -- Date validation
        CASE 
            WHEN s.OPEN_DATE IS NOT NULL AND s.OPEN_DATE <= CURRENT_DATE() THEN 1
            ELSE 0
        END AS date_valid
    FROM source_data s
),

cleaned_data AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        
        -- Standardize ticket type
        CASE 
            WHEN ticket_type_valid = 1 THEN TICKET_TYPE
            ELSE 'General'
        END AS TICKET_TYPE,
        
        -- Derive priority level from ticket type
        CASE 
            WHEN TICKET_TYPE = 'Bug Report' THEN 'High'
            WHEN TICKET_TYPE = 'Technical' THEN 'Medium'
            WHEN TICKET_TYPE = 'Billing' THEN 'High'
            WHEN TICKET_TYPE = 'Feature Request' THEN 'Low'
            ELSE 'Medium'
        END AS PRIORITY_LEVEL,
        
        -- Validate open date
        CASE 
            WHEN date_valid = 1 THEN OPEN_DATE
            ELSE CURRENT_DATE()
        END AS OPEN_DATE,
        
        -- Derive close date from resolution status
        CASE 
            WHEN RESOLUTION_STATUS IN ('Resolved', 'Closed') 
            THEN DATEADD('day', 3, OPEN_DATE)  -- Assume 3 days to resolve
            ELSE NULL
        END AS CLOSE_DATE,
        
        -- Standardize resolution status
        CASE 
            WHEN resolution_status_valid = 1 THEN RESOLUTION_STATUS
            ELSE 'Open'
        END AS RESOLUTION_STATUS,
        
        -- Generate issue description
        CASE 
            WHEN TICKET_TYPE = 'Technical' THEN 'Technical support request'
            WHEN TICKET_TYPE = 'Billing' THEN 'Billing inquiry or issue'
            WHEN TICKET_TYPE = 'Feature Request' THEN 'Feature enhancement request'
            WHEN TICKET_TYPE = 'Bug Report' THEN 'Software bug report'
            ELSE 'General support inquiry'
        END AS ISSUE_DESCRIPTION,
        
        -- Generate resolution notes
        CASE 
            WHEN RESOLUTION_STATUS IN ('Resolved', 'Closed') 
            THEN 'Issue resolved through standard support process'
            ELSE 'Resolution in progress'
        END AS RESOLUTION_NOTES,
        
        -- Calculate resolution time
        CASE 
            WHEN RESOLUTION_STATUS IN ('Resolved', 'Closed') AND CLOSE_DATE IS NOT NULL
            THEN DATEDIFF('hour', OPEN_DATE, CLOSE_DATE)
            ELSE NULL
        END AS RESOLUTION_TIME_HOURS,
        
        -- Calculate data quality score
        ROUND((ticket_type_valid + resolution_status_valid + date_valid) / 3.0, 2) AS DATA_QUALITY_SCORE,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at
        
    FROM data_quality_checks
    WHERE TICKET_ID IS NOT NULL  -- Remove records with null primary key
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY TICKET_ID 
            ORDER BY UPDATE_TIMESTAMP DESC
        ) AS row_num
    FROM cleaned_data
    QUALIFY row_num = 1
)

-- Final SELECT
SELECT 
    TICKET_ID,
    USER_ID,
    TICKET_TYPE,
    PRIORITY_LEVEL,
    OPEN_DATE,
    CLOSE_DATE,
    RESOLUTION_STATUS,
    ISSUE_DESCRIPTION,
    RESOLUTION_NOTES,
    RESOLUTION_TIME_HOURS,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATA_QUALITY_SCORE,
    LOAD_DATE,
    UPDATE_DATE,
    created_at,
    updated_at
FROM deduplication

-- Post-hook: Log process completion
{% if this.name != 'audit_log' %}
{{ log("Completed transformation for si_support_tickets", info=True) }}
{% endif %}
