{{ config(
    materialized='table'
) }}

/*
 * SI_SUPPORT_TICKETS - Silver Layer Support Tickets Table
 * Transforms and cleanses support ticket data from Bronze layer
 */

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
),

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
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM bronze_support_tickets
    WHERE TICKET_ID IS NOT NULL
      AND OPEN_DATE <= CURRENT_DATE()
),

validated_support_tickets AS (
    SELECT 
        *,
        /* Data Quality Score Calculation */
        CASE 
            WHEN TICKET_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND TICKET_TYPE IS NOT NULL 
                AND RESOLUTION_STATUS IN ('OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED')
                AND OPEN_DATE IS NOT NULL
                AND OPEN_DATE <= CURRENT_DATE()
            THEN 100
            WHEN TICKET_ID IS NOT NULL AND USER_ID IS NOT NULL AND TICKET_TYPE IS NOT NULL 
            THEN 75
            WHEN TICKET_ID IS NOT NULL 
            THEN 50
            ELSE 25
        END AS DATA_QUALITY_SCORE,
        
        /* Validation Status */
        CASE 
            WHEN TICKET_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND TICKET_TYPE IS NOT NULL 
                AND RESOLUTION_STATUS IN ('OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED')
                AND OPEN_DATE IS NOT NULL
                AND OPEN_DATE <= CURRENT_DATE()
            THEN 'PASSED'
            WHEN TICKET_ID IS NOT NULL AND USER_ID IS NOT NULL 
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM cleansed_support_tickets
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
    LOAD_DATE,
    UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM validated_support_tickets
