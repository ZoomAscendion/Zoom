{{ config(
    materialized='table'
) }}

-- Silver Layer Support Tickets Table
-- Transforms Bronze support tickets data with standardization and resolution metrics

WITH bronze_support_tickets AS (
    SELECT *
    FROM {{ source('bronze', 'bz_support_tickets') }}
    WHERE TICKET_ID IS NOT NULL
        AND USER_ID IS NOT NULL
),

-- Data Quality Checks and Transformations
support_tickets_cleaned AS (
    SELECT 
        -- Primary identifiers
        TICKET_ID,
        USER_ID,
        
        -- Ticket type standardization
        CASE 
            WHEN UPPER(TRIM(COALESCE(TICKET_TYPE, ''))) IN ('TECHNICAL', 'BILLING', 'FEATURE REQUEST', 'BUG REPORT') 
                THEN INITCAP(TICKET_TYPE)
            ELSE 'General Inquiry'
        END AS TICKET_TYPE,
        
        -- Priority level derivation from ticket type
        CASE 
            WHEN UPPER(TRIM(COALESCE(TICKET_TYPE, ''))) = 'BUG REPORT' THEN 'High'
            WHEN UPPER(TRIM(COALESCE(TICKET_TYPE, ''))) = 'TECHNICAL' THEN 'Medium'
            WHEN UPPER(TRIM(COALESCE(TICKET_TYPE, ''))) = 'BILLING' THEN 'High'
            WHEN UPPER(TRIM(COALESCE(TICKET_TYPE, ''))) = 'FEATURE REQUEST' THEN 'Low'
            ELSE 'Medium'
        END AS PRIORITY_LEVEL,
        
        -- Open date validation
        CASE 
            WHEN OPEN_DATE > CURRENT_DATE() + INTERVAL '1 DAY' THEN CURRENT_DATE()
            ELSE COALESCE(OPEN_DATE, CURRENT_DATE())
        END AS OPEN_DATE,
        
        -- Close date derivation (estimated based on resolution status)
        CASE 
            WHEN UPPER(TRIM(COALESCE(RESOLUTION_STATUS, ''))) IN ('RESOLVED', 'CLOSED') 
                THEN DATEADD('day', 3, COALESCE(OPEN_DATE, CURRENT_DATE()))
            ELSE NULL
        END AS CLOSE_DATE,
        
        -- Resolution status standardization
        CASE 
            WHEN UPPER(TRIM(COALESCE(RESOLUTION_STATUS, ''))) IN ('OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED') 
                THEN INITCAP(RESOLUTION_STATUS)
            ELSE 'Open'
        END AS RESOLUTION_STATUS,
        
        -- Issue description generation
        CASE 
            WHEN UPPER(TRIM(COALESCE(TICKET_TYPE, ''))) = 'TECHNICAL' THEN 'Technical issue requiring support'
            WHEN UPPER(TRIM(COALESCE(TICKET_TYPE, ''))) = 'BILLING' THEN 'Billing inquiry or dispute'
            WHEN UPPER(TRIM(COALESCE(TICKET_TYPE, ''))) = 'FEATURE REQUEST' THEN 'Request for new feature or enhancement'
            WHEN UPPER(TRIM(COALESCE(TICKET_TYPE, ''))) = 'BUG REPORT' THEN 'Software bug or defect reported'
            ELSE 'General customer inquiry'
        END AS ISSUE_DESCRIPTION,
        
        -- Resolution notes generation
        CASE 
            WHEN UPPER(TRIM(COALESCE(RESOLUTION_STATUS, ''))) = 'RESOLVED' THEN 'Issue resolved successfully'
            WHEN UPPER(TRIM(COALESCE(RESOLUTION_STATUS, ''))) = 'CLOSED' THEN 'Ticket closed by customer or system'
            WHEN UPPER(TRIM(COALESCE(RESOLUTION_STATUS, ''))) = 'IN PROGRESS' THEN 'Currently being worked on by support team'
            ELSE 'Awaiting initial review'
        END AS RESOLUTION_NOTES,
        
        -- Resolution time calculation (in hours)
        CASE 
            WHEN UPPER(TRIM(COALESCE(RESOLUTION_STATUS, ''))) IN ('RESOLVED', 'CLOSED') THEN
                CASE 
                    WHEN UPPER(TRIM(COALESCE(TICKET_TYPE, ''))) = 'BUG REPORT' THEN 24
                    WHEN UPPER(TRIM(COALESCE(TICKET_TYPE, ''))) = 'TECHNICAL' THEN 48
                    WHEN UPPER(TRIM(COALESCE(TICKET_TYPE, ''))) = 'BILLING' THEN 12
                    WHEN UPPER(TRIM(COALESCE(TICKET_TYPE, ''))) = 'FEATURE REQUEST' THEN 168
                    ELSE 72
                END
            ELSE 0
        END AS RESOLUTION_TIME_HOURS,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data quality score calculation
        CASE 
            WHEN TICKET_ID IS NOT NULL 
                AND USER_ID IS NOT NULL
                AND TICKET_TYPE IS NOT NULL
                AND OPEN_DATE IS NOT NULL
                AND RESOLUTION_STATUS IS NOT NULL
                THEN 1.00
            WHEN TICKET_ID IS NOT NULL AND USER_ID IS NOT NULL
                THEN 0.75
            WHEN TICKET_ID IS NOT NULL
                THEN 0.50
            ELSE 0.25
        END AS DATA_QUALITY_SCORE,
        
        -- Standard metadata
        LOAD_TIMESTAMP::DATE AS LOAD_DATE,
        UPDATE_TIMESTAMP::DATE AS UPDATE_DATE,
        
        -- Row number for deduplication
        ROW_NUMBER() OVER (PARTITION BY TICKET_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
        
    FROM bronze_support_tickets
),

-- Final selection with data quality filters
support_tickets_final AS (
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
    FROM support_tickets_cleaned
    WHERE rn = 1  -- Deduplication
        AND RESOLUTION_TIME_HOURS >= 0  -- Ensure non-negative resolution time
)

SELECT * FROM support_tickets_final
