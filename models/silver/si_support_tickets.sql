{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_audit_log') }} (MODEL_NAME, TABLE_NAME, PROCESS_STATUS, LOAD_TIMESTAMP) SELECT 'si_support_tickets', 'SI_SUPPORT_TICKETS', 'STARTED', CURRENT_TIMESTAMP()",
    post_hook="INSERT INTO {{ ref('si_audit_log') }} (MODEL_NAME, TABLE_NAME, PROCESS_STATUS, LOAD_TIMESTAMP) SELECT 'si_support_tickets', 'SI_SUPPORT_TICKETS', 'COMPLETED', CURRENT_TIMESTAMP()"
) }}

-- Silver Layer Support Tickets Table
-- Transforms and cleanses support ticket data from Bronze layer
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

cleansed_support_tickets AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        TRIM(UPPER(TICKET_TYPE)) AS TICKET_TYPE,
        CASE 
            WHEN UPPER(TRIM(RESOLUTION_STATUS)) IN ('OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED') 
            THEN UPPER(TRIM(RESOLUTION_STATUS))
            ELSE 'UNKNOWN'
        END AS RESOLUTION_STATUS,
        OPEN_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Additional Silver layer metadata
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE
    FROM bronze_support_tickets
),

validated_support_tickets AS (
    SELECT *,
        CASE 
            WHEN TICKET_TYPE IS NOT NULL AND RESOLUTION_STATUS IN ('OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED') 
                 AND OPEN_DATE IS NOT NULL AND OPEN_DATE <= CURRENT_DATE()
            THEN 100
            WHEN TICKET_TYPE IS NOT NULL AND RESOLUTION_STATUS IS NOT NULL
            THEN 75
            WHEN TICKET_TYPE IS NOT NULL OR RESOLUTION_STATUS IS NOT NULL
            THEN 50
            ELSE 25
        END AS DATA_QUALITY_SCORE,
        CASE 
            WHEN TICKET_TYPE IS NOT NULL AND RESOLUTION_STATUS IN ('OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED') 
                 AND OPEN_DATE IS NOT NULL AND OPEN_DATE <= CURRENT_DATE()
            THEN 'PASSED'
            WHEN OPEN_DATE > CURRENT_DATE()
            THEN 'FAILED'
            ELSE 'WARNING'
        END AS VALIDATION_STATUS
    FROM cleansed_support_tickets
),

deduped_support_tickets AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY TICKET_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
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
  AND VALIDATION_STATUS != 'FAILED'
