{{ config(
    materialized='table'
) }}

/* Silver layer transformation for Support Tickets */
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

cleaned_support_tickets AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        COALESCE(UPPER(TRIM(TICKET_TYPE)), 'GENERAL') AS TICKET_TYPE,
        CASE 
            WHEN RESOLUTION_STATUS IN ('Open', 'In Progress', 'Resolved', 'Closed') THEN RESOLUTION_STATUS
            ELSE 'Open'
        END AS RESOLUTION_STATUS,
        COALESCE(OPEN_DATE, CURRENT_DATE()) AS OPEN_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        COALESCE(DATE(UPDATE_TIMESTAMP), DATE(LOAD_TIMESTAMP)) AS UPDATE_DATE
    FROM bronze_support_tickets
    WHERE COALESCE(OPEN_DATE, CURRENT_DATE()) <= CURRENT_DATE()
),

validated_support_tickets AS (
    SELECT 
        *,
        /* Data quality score calculation */
        CASE 
            WHEN TICKET_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND TICKET_TYPE != 'GENERAL'
                AND RESOLUTION_STATUS IN ('Open', 'In Progress', 'Resolved', 'Closed')
                AND OPEN_DATE <= CURRENT_DATE()
            THEN 100
            WHEN TICKET_ID IS NOT NULL AND USER_ID IS NOT NULL 
            THEN 75
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        
        /* Validation status */
        CASE 
            WHEN TICKET_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND TICKET_TYPE != 'GENERAL'
                AND RESOLUTION_STATUS IN ('Open', 'In Progress', 'Resolved', 'Closed')
                AND OPEN_DATE <= CURRENT_DATE()
            THEN 'PASSED'
            WHEN TICKET_ID IS NOT NULL AND USER_ID IS NOT NULL 
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM cleaned_support_tickets
),

deduped_support_tickets AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY TICKET_ID ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC) AS rn
    FROM validated_support_tickets
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
FROM deduped_support_tickets
WHERE rn = 1
