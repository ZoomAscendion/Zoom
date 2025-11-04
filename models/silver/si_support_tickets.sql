{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, EXECUTED_BY, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, LOAD_DATE) SELECT 'EXEC_' || REPLACE(CAST(CURRENT_TIMESTAMP() AS STRING), ' ', '_'), 'SI_SUPPORT_TICKETS_TRANSFORMATION', CURRENT_TIMESTAMP(), 'STARTED', 'DBT_PIPELINE', 'BZ_SUPPORT_TICKETS', 'SI_SUPPORT_TICKETS', CURRENT_DATE() WHERE EXISTS (SELECT 1 FROM {{ ref('audit_log') }} LIMIT 1)",
    post_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, END_TIME, STATUS, EXECUTED_BY, RECORDS_PROCESSED, LOAD_DATE) SELECT 'EXEC_' || REPLACE(CAST(CURRENT_TIMESTAMP() AS STRING), ' ', '_'), 'SI_SUPPORT_TICKETS_TRANSFORMATION', CURRENT_TIMESTAMP(), 'COMPLETED', 'DBT_PIPELINE', (SELECT COUNT(*) FROM {{ this }}), CURRENT_DATE() WHERE EXISTS (SELECT 1 FROM {{ ref('audit_log') }} LIMIT 1)"
) }}

-- Silver Layer Support Tickets Table Transformation
-- Source: Bronze.BZ_SUPPORT_TICKETS

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
    FROM {{ source('bronze', 'BZ_SUPPORT_TICKETS') }}
),

-- Data Quality Validation and Cleansing
validated_support_tickets AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        
        -- Standardize ticket type
        CASE 
            WHEN TICKET_TYPE IN ('Technical', 'Billing', 'Feature Request', 'Bug Report') 
            THEN TICKET_TYPE
            ELSE 'Other'
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
            WHEN OPEN_DATE > DATEADD('day', 1, CURRENT_DATE()) 
            THEN CURRENT_DATE()
            ELSE OPEN_DATE
        END AS OPEN_DATE,
        
        -- Derive close date from resolution status
        CASE 
            WHEN RESOLUTION_STATUS IN ('Resolved', 'Closed') 
            THEN DATEADD('day', 3, OPEN_DATE)  -- Assume 3 days resolution time
            ELSE NULL
        END AS CLOSE_DATE,
        
        -- Standardize resolution status
        CASE 
            WHEN RESOLUTION_STATUS IN ('Open', 'In Progress', 'Resolved', 'Closed') 
            THEN RESOLUTION_STATUS
            ELSE 'Open'
        END AS RESOLUTION_STATUS,
        
        -- Generate issue description based on ticket type
        CASE 
            WHEN TICKET_TYPE = 'Technical' THEN 'Technical issue reported by user'
            WHEN TICKET_TYPE = 'Billing' THEN 'Billing inquiry or dispute'
            WHEN TICKET_TYPE = 'Feature Request' THEN 'User requested new feature'
            WHEN TICKET_TYPE = 'Bug Report' THEN 'Software bug reported'
            ELSE 'General support inquiry'
        END AS ISSUE_DESCRIPTION,
        
        -- Generate resolution notes based on status
        CASE 
            WHEN RESOLUTION_STATUS = 'Resolved' THEN 'Issue successfully resolved'
            WHEN RESOLUTION_STATUS = 'Closed' THEN 'Ticket closed by user or system'
            WHEN RESOLUTION_STATUS = 'In Progress' THEN 'Currently being worked on'
            ELSE 'Awaiting initial review'
        END AS RESOLUTION_NOTES,
        
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Add row number for deduplication
        ROW_NUMBER() OVER (PARTITION BY TICKET_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_support_tickets
    WHERE TICKET_ID IS NOT NULL
        AND USER_ID IS NOT NULL
),

-- Calculate derived fields
final_support_tickets AS (
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
        
        -- Calculate resolution time in hours
        CASE 
            WHEN CLOSE_DATE IS NOT NULL 
            THEN DATEDIFF('hour', OPEN_DATE, CLOSE_DATE)
            ELSE NULL
        END AS RESOLUTION_TIME_HOURS,
        
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Calculate data quality score
        CASE 
            WHEN TICKET_ID IS NOT NULL 
                AND USER_ID IS NOT NULL
                AND TICKET_TYPE IS NOT NULL
                AND OPEN_DATE IS NOT NULL
                AND RESOLUTION_STATUS IS NOT NULL
            THEN 1.00
            WHEN TICKET_ID IS NOT NULL AND USER_ID IS NOT NULL
            THEN 0.75
            ELSE 0.50
        END AS DATA_QUALITY_SCORE,
        
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM validated_support_tickets
    WHERE rn = 1
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
FROM final_support_tickets
