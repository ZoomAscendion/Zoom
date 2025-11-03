{{
    config(
        materialized='table',
        on_schema_change='sync_all_columns'
    )
}}

-- Silver Layer Support Tickets Transformation
-- Transforms Bronze layer support ticket data with resolution metrics

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
      AND USER_ID IS NOT NULL
),

-- Data Quality Validations and Cleansing
support_tickets_cleaned AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        
        -- Standardize ticket type
        CASE 
            WHEN UPPER(TRIM(TICKET_TYPE)) IN ('TECHNICAL', 'TECH') THEN 'Technical'
            WHEN UPPER(TRIM(TICKET_TYPE)) IN ('BILLING', 'PAYMENT') THEN 'Billing'
            WHEN UPPER(TRIM(TICKET_TYPE)) IN ('FEATURE REQUEST', 'FEATURE', 'REQUEST') THEN 'Feature Request'
            WHEN UPPER(TRIM(TICKET_TYPE)) IN ('BUG REPORT', 'BUG') THEN 'Bug Report'
            ELSE 'General'
        END AS TICKET_TYPE,
        
        -- Derive priority level from ticket type
        CASE 
            WHEN UPPER(TRIM(TICKET_TYPE)) IN ('BUG REPORT', 'BUG') THEN 'High'
            WHEN UPPER(TRIM(TICKET_TYPE)) IN ('TECHNICAL', 'TECH') THEN 'Medium'
            WHEN UPPER(TRIM(TICKET_TYPE)) IN ('BILLING', 'PAYMENT') THEN 'High'
            WHEN UPPER(TRIM(TICKET_TYPE)) IN ('FEATURE REQUEST', 'FEATURE', 'REQUEST') THEN 'Low'
            ELSE 'Medium'
        END AS PRIORITY_LEVEL,
        
        -- Validate open date
        CASE 
            WHEN OPEN_DATE > CURRENT_DATE() THEN CURRENT_DATE()
            WHEN OPEN_DATE < '2020-01-01' THEN '2020-01-01'
            ELSE OPEN_DATE
        END AS OPEN_DATE,
        
        -- Derive close date based on resolution status
        CASE 
            WHEN UPPER(TRIM(RESOLUTION_STATUS)) IN ('RESOLVED', 'CLOSED') THEN 
                DATEADD('day', 
                    CASE 
                        WHEN UPPER(TRIM(TICKET_TYPE)) IN ('BUG REPORT', 'BUG') THEN 2
                        WHEN UPPER(TRIM(TICKET_TYPE)) IN ('TECHNICAL', 'TECH') THEN 3
                        WHEN UPPER(TRIM(TICKET_TYPE)) IN ('BILLING', 'PAYMENT') THEN 1
                        ELSE 5
                    END, 
                    OPEN_DATE)
            ELSE NULL
        END AS CLOSE_DATE,
        
        -- Standardize resolution status
        CASE 
            WHEN UPPER(TRIM(RESOLUTION_STATUS)) IN ('RESOLVED', 'CLOSED', 'COMPLETE') THEN 'Resolved'
            WHEN UPPER(TRIM(RESOLUTION_STATUS)) IN ('IN PROGRESS', 'PROGRESS', 'WORKING') THEN 'In Progress'
            WHEN UPPER(TRIM(RESOLUTION_STATUS)) IN ('OPEN', 'NEW') THEN 'Open'
            ELSE 'Open'
        END AS RESOLUTION_STATUS,
        
        -- Generate issue description based on ticket type
        CASE 
            WHEN UPPER(TRIM(TICKET_TYPE)) IN ('TECHNICAL', 'TECH') THEN 'Technical issue requiring support assistance'
            WHEN UPPER(TRIM(TICKET_TYPE)) IN ('BILLING', 'PAYMENT') THEN 'Billing or payment related inquiry'
            WHEN UPPER(TRIM(TICKET_TYPE)) IN ('FEATURE REQUEST', 'FEATURE', 'REQUEST') THEN 'Request for new feature or enhancement'
            WHEN UPPER(TRIM(TICKET_TYPE)) IN ('BUG REPORT', 'BUG') THEN 'Bug report requiring investigation and fix'
            ELSE 'General support inquiry'
        END AS ISSUE_DESCRIPTION,
        
        -- Generate resolution notes based on status
        CASE 
            WHEN UPPER(TRIM(RESOLUTION_STATUS)) IN ('RESOLVED', 'CLOSED', 'COMPLETE') THEN 'Issue resolved successfully'
            WHEN UPPER(TRIM(RESOLUTION_STATUS)) IN ('IN PROGRESS', 'PROGRESS', 'WORKING') THEN 'Issue currently being investigated'
            ELSE 'Awaiting initial review'
        END AS RESOLUTION_NOTES,
        
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM bronze_support_tickets
),

-- Calculate resolution time
support_tickets_with_metrics AS (
    SELECT 
        *,
        -- Calculate resolution time in hours
        CASE 
            WHEN CLOSE_DATE IS NOT NULL THEN 
                DATEDIFF('hour', OPEN_DATE, CLOSE_DATE)
            ELSE NULL
        END AS RESOLUTION_TIME_HOURS,
        
        -- Calculate data quality score
        (
            CASE WHEN TICKET_ID IS NOT NULL THEN 0.2 ELSE 0 END +
            CASE WHEN USER_ID IS NOT NULL THEN 0.2 ELSE 0 END +
            CASE WHEN TICKET_TYPE IS NOT NULL THEN 0.2 ELSE 0 END +
            CASE WHEN OPEN_DATE IS NOT NULL THEN 0.2 ELSE 0 END +
            CASE WHEN RESOLUTION_STATUS IS NOT NULL THEN 0.2 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM support_tickets_cleaned
),

-- Remove duplicates keeping the latest record
support_tickets_deduped AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY TICKET_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM support_tickets_with_metrics
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
FROM support_tickets_deduped
WHERE rn = 1
  AND DATA_QUALITY_SCORE >= 0.80  -- Only allow records with at least 80% data quality
