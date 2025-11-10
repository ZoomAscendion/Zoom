{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTION_TRIGGER, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_SUPPORT_TICKETS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'RUNNING', 'BZ_SUPPORT_TICKETS', 'SI_SUPPORT_TICKETS', 'SCHEDULED', 'DBT_CLOUD', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_END_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, RECORDS_PROCESSED, RECORDS_SUCCESS, EXECUTION_TRIGGER, EXECUTED_BY, UPDATE_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_SUPPORT_TICKETS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'SUCCESS', 'BZ_SUPPORT_TICKETS', 'SI_SUPPORT_TICKETS', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 'SCHEDULED', 'DBT_CLOUD', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'"
) }}

-- Silver layer transformation for Support Tickets table
-- Applies data quality checks, status validation, and business rules

WITH bronze_support_tickets AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        TICKET_TYPE,
        RESOLUTION_STATUS,
        -- Handle different date formats
        CASE 
            WHEN OPEN_DATE IS NOT NULL THEN
                TRY_TO_DATE(OPEN_DATE, 'DD/MM/YYYY')
            ELSE NULL
        END AS OPEN_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('bronze', 'BZ_SUPPORT_TICKETS') }}
    WHERE TICKET_ID IS NOT NULL
),

-- Data quality validation and scoring
validated_support_tickets AS (
    SELECT 
        *,
        -- Data quality score calculation (0-100)
        CASE 
            WHEN TICKET_ID IS NULL OR USER_ID IS NULL THEN 0
            WHEN TICKET_TYPE IS NULL OR LENGTH(TRIM(TICKET_TYPE)) = 0 THEN 20
            WHEN RESOLUTION_STATUS NOT IN ('Open', 'In Progress', 'Resolved', 'Closed') THEN 30
            WHEN OPEN_DATE IS NULL OR OPEN_DATE > CURRENT_DATE() THEN 40
            ELSE 100
        END AS DATA_QUALITY_SCORE,
        
        -- Validation status
        CASE 
            WHEN TICKET_ID IS NULL OR USER_ID IS NULL THEN 'FAILED'
            WHEN TICKET_TYPE IS NULL OR LENGTH(TRIM(TICKET_TYPE)) = 0 THEN 'FAILED'
            WHEN OPEN_DATE IS NULL OR OPEN_DATE > CURRENT_DATE() THEN 'FAILED'
            WHEN RESOLUTION_STATUS NOT IN ('Open', 'In Progress', 'Resolved', 'Closed') THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM bronze_support_tickets
),

-- Remove duplicates keeping latest record
deduped_support_tickets AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY TICKET_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM validated_support_tickets
    WHERE VALIDATION_STATUS != 'FAILED'
)

SELECT 
    TICKET_ID,
    USER_ID,
    UPPER(TRIM(TICKET_TYPE)) AS TICKET_TYPE,
    CASE 
        WHEN UPPER(TRIM(RESOLUTION_STATUS)) IN ('OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED') 
        THEN INITCAP(UPPER(TRIM(RESOLUTION_STATUS)))
        ELSE 'Open'
    END AS RESOLUTION_STATUS,
    OPEN_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    -- Additional Silver layer metadata columns
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_support_tickets
WHERE rn = 1
