{{ config(
    materialized='table'
) }}

-- Silver Layer Support Tickets Table Transformation
-- Transforms Bronze BZ_SUPPORT_TICKETS to Silver SI_SUPPORT_TICKETS with data quality checks

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

validated_support_tickets AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        UPPER(TRIM(TICKET_TYPE)) as TICKET_TYPE,
        CASE 
            WHEN UPPER(TRIM(RESOLUTION_STATUS)) IN ('OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED') 
            THEN UPPER(TRIM(RESOLUTION_STATUS))
            ELSE 'OPEN'
        END as RESOLUTION_STATUS,
        OPEN_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data Quality Score Calculation
        CASE 
            WHEN TICKET_ID IS NULL THEN 0
            WHEN USER_ID IS NULL THEN 20
            WHEN TICKET_TYPE IS NULL OR LENGTH(TRIM(TICKET_TYPE)) = 0 THEN 30
            WHEN OPEN_DATE IS NULL THEN 40
            WHEN OPEN_DATE > CURRENT_DATE() THEN 50
            ELSE 100
        END as DATA_QUALITY_SCORE,
        
        -- Validation Status
        CASE 
            WHEN TICKET_ID IS NULL OR USER_ID IS NULL OR TICKET_TYPE IS NULL OR LENGTH(TRIM(TICKET_TYPE)) = 0 THEN 'FAILED'
            WHEN OPEN_DATE IS NULL OR OPEN_DATE > CURRENT_DATE() THEN 'FAILED'
            ELSE 'PASSED'
        END as VALIDATION_STATUS
    FROM bronze_support_tickets
),

deduped_support_tickets AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        TICKET_TYPE,
        RESOLUTION_STATUS,
        OPEN_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATA_QUALITY_SCORE,
        VALIDATION_STATUS,
        ROW_NUMBER() OVER (PARTITION BY TICKET_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) as rn
    FROM validated_support_tickets
    WHERE TICKET_ID IS NOT NULL
      AND USER_ID IS NOT NULL
      AND TICKET_TYPE IS NOT NULL
      AND LENGTH(TRIM(TICKET_TYPE)) > 0
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
    DATE(LOAD_TIMESTAMP) as LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) as UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_support_tickets
WHERE rn = 1
