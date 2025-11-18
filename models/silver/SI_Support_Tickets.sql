{{ config(
    materialized='table'
) }}

/* Silver Layer Support Tickets Table Transformation */
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
    FROM BRONZE.BZ_SUPPORT_TICKETS
    WHERE TICKET_ID IS NOT NULL
),

data_quality_checks AS (
    SELECT 
        *,
        /* Data Quality Score Calculation */
        (
            CASE WHEN TICKET_ID IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN USER_ID IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN TICKET_TYPE IS NOT NULL AND LENGTH(TRIM(TICKET_TYPE)) > 0 THEN 20 ELSE 0 END +
            CASE WHEN RESOLUTION_STATUS IN ('Open', 'In Progress', 'Resolved', 'Closed') THEN 20 ELSE 0 END +
            CASE WHEN OPEN_DATE IS NOT NULL AND OPEN_DATE <= CURRENT_DATE() THEN 20 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        /* Validation Status */
        CASE 
            WHEN TICKET_ID IS NULL OR USER_ID IS NULL THEN 'FAILED'
            WHEN RESOLUTION_STATUS NOT IN ('Open', 'In Progress', 'Resolved', 'Closed') THEN 'WARNING'
            WHEN OPEN_DATE > CURRENT_DATE() THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM bronze_support_tickets
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY TICKET_ID ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC, LOAD_TIMESTAMP DESC) as rn
    FROM data_quality_checks
)

SELECT 
    TICKET_ID,
    USER_ID,
    UPPER(TRIM(TICKET_TYPE)) AS TICKET_TYPE,
    COALESCE(RESOLUTION_STATUS, 'Open') AS RESOLUTION_STATUS,
    OPEN_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    COALESCE(DATE(UPDATE_TIMESTAMP), DATE(LOAD_TIMESTAMP)) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduplication
WHERE rn = 1
  AND VALIDATION_STATUS != 'FAILED'
