{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

/* Transform Bronze Support Tickets to Silver Support Tickets with status standardization */

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
),

data_quality_checks AS (
    SELECT 
        *,
        /* Data Quality Score Calculation */
        (
            CASE WHEN TICKET_ID IS NOT NULL THEN 25 ELSE 0 END +
            CASE WHEN USER_ID IS NOT NULL THEN 25 ELSE 0 END +
            CASE WHEN TICKET_TYPE IS NOT NULL AND LENGTH(TRIM(TICKET_TYPE)) > 0 THEN 20 ELSE 0 END +
            CASE WHEN RESOLUTION_STATUS IN ('Open', 'In Progress', 'Resolved', 'Closed') THEN 20 ELSE 0 END +
            CASE WHEN OPEN_DATE IS NOT NULL AND OPEN_DATE <= CURRENT_DATE() THEN 10 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        /* Validation Status */
        CASE 
            WHEN (
                CASE WHEN TICKET_ID IS NOT NULL THEN 25 ELSE 0 END +
                CASE WHEN USER_ID IS NOT NULL THEN 25 ELSE 0 END +
                CASE WHEN TICKET_TYPE IS NOT NULL AND LENGTH(TRIM(TICKET_TYPE)) > 0 THEN 20 ELSE 0 END +
                CASE WHEN RESOLUTION_STATUS IN ('Open', 'In Progress', 'Resolved', 'Closed') THEN 20 ELSE 0 END +
                CASE WHEN OPEN_DATE IS NOT NULL AND OPEN_DATE <= CURRENT_DATE() THEN 10 ELSE 0 END
            ) >= 90 THEN 'PASSED'
            WHEN (
                CASE WHEN TICKET_ID IS NOT NULL THEN 25 ELSE 0 END +
                CASE WHEN USER_ID IS NOT NULL THEN 25 ELSE 0 END +
                CASE WHEN TICKET_TYPE IS NOT NULL AND LENGTH(TRIM(TICKET_TYPE)) > 0 THEN 20 ELSE 0 END +
                CASE WHEN RESOLUTION_STATUS IN ('Open', 'In Progress', 'Resolved', 'Closed') THEN 20 ELSE 0 END +
                CASE WHEN OPEN_DATE IS NOT NULL AND OPEN_DATE <= CURRENT_DATE() THEN 10 ELSE 0 END
            ) >= 70 THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM bronze_support_tickets
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY TICKET_ID 
            ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC
        ) as rn
    FROM data_quality_checks
)

SELECT 
    TICKET_ID,
    USER_ID,
    UPPER(TRIM(TICKET_TYPE)) AS TICKET_TYPE,
    CASE 
        WHEN RESOLUTION_STATUS IN ('Open', 'In Progress', 'Resolved', 'Closed') THEN RESOLUTION_STATUS
        ELSE 'Open'
    END AS RESOLUTION_STATUS,
    OPEN_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduplication
WHERE rn = 1
  AND VALIDATION_STATUS IN ('PASSED', 'WARNING')
