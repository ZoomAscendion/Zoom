{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_audit_log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_SUPPORT_TICKETS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'RUNNING', 'BZ_SUPPORT_TICKETS', 'SI_SUPPORT_TICKETS', 'DBT_PIPELINE', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'si_audit_log'",
    post_hook="INSERT INTO {{ ref('si_audit_log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_END_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, UPDATE_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_SUPPORT_TICKETS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'SUCCESS', 'BZ_SUPPORT_TICKETS', 'SI_SUPPORT_TICKETS', 'DBT_PIPELINE', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'si_audit_log'"
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
        UPPER(TRIM(TICKET_TYPE)) AS TICKET_TYPE,
        CASE 
            WHEN UPPER(TRIM(RESOLUTION_STATUS)) IN ('OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED') 
            THEN UPPER(TRIM(RESOLUTION_STATUS))
            ELSE 'OPEN'
        END AS RESOLUTION_STATUS,
        OPEN_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM bronze_support_tickets
),

validated_support_tickets AS (
    SELECT 
        *,
        -- Data Quality Score
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
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        
        -- Validation Status
        CASE 
            WHEN TICKET_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND TICKET_TYPE IS NOT NULL 
                AND RESOLUTION_STATUS IN ('OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED')
                AND OPEN_DATE IS NOT NULL
                AND OPEN_DATE <= CURRENT_DATE()
            THEN 'PASSED'
            WHEN TICKET_ID IS NOT NULL AND USER_ID IS NOT NULL AND TICKET_TYPE IS NOT NULL
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM cleansed_support_tickets
),

deduped_support_tickets AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY TICKET_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
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
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_support_tickets
WHERE rn = 1
    AND VALIDATION_STATUS != 'FAILED'
