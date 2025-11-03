{{ config(materialized='table') }}

WITH source_data AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        TICKET_TYPE,
        RESOLUTION_STATUS,
        OPEN_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ ref('bz_support_tickets') }}
    WHERE TICKET_ID IS NOT NULL
        AND USER_ID IS NOT NULL
),

cleaned_data AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        CASE 
            WHEN TICKET_TYPE IN ('Technical', 'Billing', 'Feature Request', 'Bug Report') THEN TICKET_TYPE
            ELSE 'Other'
        END AS TICKET_TYPE,
        CASE 
            WHEN TICKET_TYPE = 'Bug Report' THEN 'Critical'
            WHEN TICKET_TYPE = 'Technical' THEN 'High'
            WHEN TICKET_TYPE = 'Billing' THEN 'Medium'
            ELSE 'Low'
        END AS PRIORITY_LEVEL,
        CASE 
            WHEN OPEN_DATE > CURRENT_DATE() THEN CURRENT_DATE()
            ELSE OPEN_DATE
        END AS OPEN_DATE,
        CASE 
            WHEN RESOLUTION_STATUS = 'Resolved' OR RESOLUTION_STATUS = 'Closed' 
            THEN DATEADD('day', 3, OPEN_DATE)
            ELSE NULL
        END AS CLOSE_DATE,
        CASE 
            WHEN RESOLUTION_STATUS IN ('Open', 'In Progress', 'Resolved', 'Closed') THEN RESOLUTION_STATUS
            ELSE 'Open'
        END AS RESOLUTION_STATUS,
        CASE 
            WHEN TICKET_TYPE = 'Technical' THEN 'Technical issue reported by user'
            WHEN TICKET_TYPE = 'Billing' THEN 'Billing inquiry or dispute'
            WHEN TICKET_TYPE = 'Feature Request' THEN 'User requested new feature'
            WHEN TICKET_TYPE = 'Bug Report' THEN 'Software bug reported'
            ELSE 'General support inquiry'
        END AS ISSUE_DESCRIPTION,
        CASE 
            WHEN RESOLUTION_STATUS = 'Resolved' THEN 'Issue resolved successfully'
            WHEN RESOLUTION_STATUS = 'Closed' THEN 'Ticket closed'
            ELSE 'In progress'
        END AS RESOLUTION_NOTES,
        CASE 
            WHEN RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN 72
            ELSE NULL
        END AS RESOLUTION_TIME_HOURS,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        1.00 AS DATA_QUALITY_SCORE,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM source_data
    WHERE OPEN_DATE <= CURRENT_DATE()
),

deduplicated AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY TICKET_ID 
            ORDER BY UPDATE_TIMESTAMP DESC
        ) AS row_num
    FROM cleaned_data
    QUALIFY row_num = 1
)

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
    UPDATE_DATE
FROM deduplicated
