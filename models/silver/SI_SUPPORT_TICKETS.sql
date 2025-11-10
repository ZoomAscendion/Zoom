{{ config(
    materialized='table'
) }}

-- Silver layer transformation for Support Tickets table
-- Applies data quality checks, status standardization, and business rules

WITH bronze_support_tickets AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        TICKET_TYPE,
        RESOLUTION_STATUS,
        TRY_TO_DATE(OPEN_DATE) AS OPEN_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM BRONZE.BZ_SUPPORT_TICKETS
),

-- Data quality validation and cleansing
cleansed_support_tickets AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        UPPER(TRIM(TICKET_TYPE)) AS TICKET_TYPE,
        CASE 
            WHEN UPPER(TRIM(RESOLUTION_STATUS)) IN ('OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED') 
            THEN UPPER(TRIM(RESOLUTION_STATUS))
            ELSE 'OPEN'
        END AS RESOLUTION_STATUS,
        OPEN_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data quality scoring
        CASE 
            WHEN TICKET_ID IS NULL THEN 0
            WHEN USER_ID IS NULL THEN 20
            WHEN TICKET_TYPE IS NULL OR LENGTH(TRIM(TICKET_TYPE)) = 0 THEN 30
            WHEN RESOLUTION_STATUS IS NULL THEN 40
            WHEN OPEN_DATE IS NULL THEN 50
            WHEN OPEN_DATE > CURRENT_DATE() THEN 60
            WHEN LENGTH(TICKET_TYPE) > 100 THEN 80
            ELSE 100
        END AS DATA_QUALITY_SCORE,
        
        -- Validation status
        CASE 
            WHEN TICKET_ID IS NULL OR USER_ID IS NULL THEN 'FAILED'
            WHEN TICKET_TYPE IS NULL OR LENGTH(TRIM(TICKET_TYPE)) = 0 THEN 'FAILED'
            WHEN RESOLUTION_STATUS IS NULL OR OPEN_DATE IS NULL THEN 'FAILED'
            WHEN OPEN_DATE > CURRENT_DATE() THEN 'FAILED'
            WHEN LENGTH(TICKET_TYPE) > 100 THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM bronze_support_tickets
),

-- Remove duplicates using ROW_NUMBER
deduped_support_tickets AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY TICKET_ID ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC) AS rn
    FROM cleansed_support_tickets
    WHERE TICKET_ID IS NOT NULL
      AND USER_ID IS NOT NULL
      AND TICKET_TYPE IS NOT NULL
      AND LENGTH(TRIM(TICKET_TYPE)) > 0
      AND RESOLUTION_STATUS IS NOT NULL
      AND OPEN_DATE IS NOT NULL
      AND OPEN_DATE <= CURRENT_DATE()
)

SELECT 
    TICKET_ID,
    USER_ID,
    TICKET_TYPE,
    RESOLUTION_STATUS,
    OPEN_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_support_tickets
WHERE rn = 1
  AND VALIDATION_STATUS IN ('PASSED', 'WARNING')
