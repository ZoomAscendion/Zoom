{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTION_TRIGGER, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_SUPPORT_TICKETS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'RUNNING', 'BZ_SUPPORT_TICKETS', 'SI_SUPPORT_TICKETS', 'DBT', 'SYSTEM', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_END_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, RECORDS_PROCESSED, RECORDS_SUCCESS, EXECUTION_TRIGGER, EXECUTED_BY, UPDATE_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_SUPPORT_TICKETS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'SUCCESS', 'BZ_SUPPORT_TICKETS', 'SI_SUPPORT_TICKETS', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 'DBT', 'SYSTEM', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'"
) }}

-- Silver layer transformation for Support Tickets table
-- Applies data quality checks, status validation, and date consistency

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
    WHERE TICKET_ID IS NOT NULL
),

-- Validate support ticket data
validated_support_tickets AS (
    SELECT 
        *,
        
        -- Calculate data quality score
        CASE 
            WHEN TICKET_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND TICKET_TYPE IS NOT NULL 
                AND RESOLUTION_STATUS IS NOT NULL 
                AND RESOLUTION_STATUS IN ('Open', 'In Progress', 'Resolved', 'Closed')
                AND OPEN_DATE IS NOT NULL 
                AND OPEN_DATE <= CURRENT_DATE()
                AND LENGTH(TRIM(TICKET_TYPE)) <= 100
            THEN 100
            WHEN TICKET_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND TICKET_TYPE IS NOT NULL 
                AND RESOLUTION_STATUS IS NOT NULL 
                AND OPEN_DATE IS NOT NULL 
                AND OPEN_DATE <= CURRENT_DATE()
            THEN 75
            WHEN TICKET_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND TICKET_TYPE IS NOT NULL 
            THEN 50
            ELSE 25
        END AS data_quality_score,
        
        -- Set validation status
        CASE 
            WHEN TICKET_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND TICKET_TYPE IS NOT NULL 
                AND RESOLUTION_STATUS IS NOT NULL 
                AND RESOLUTION_STATUS IN ('Open', 'In Progress', 'Resolved', 'Closed')
                AND OPEN_DATE IS NOT NULL 
                AND OPEN_DATE <= CURRENT_DATE()
                AND LENGTH(TRIM(TICKET_TYPE)) <= 100
            THEN 'PASSED'
            WHEN TICKET_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND TICKET_TYPE IS NOT NULL 
                AND RESOLUTION_STATUS IS NOT NULL 
                AND OPEN_DATE IS NOT NULL 
                AND OPEN_DATE <= CURRENT_DATE()
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS validation_status
    FROM bronze_support_tickets
),

-- Remove duplicates keeping the latest record
deduped_support_tickets AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY TICKET_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM validated_support_tickets
    WHERE validation_status IN ('PASSED', 'WARNING')
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
    data_quality_score AS DATA_QUALITY_SCORE,
    validation_status AS VALIDATION_STATUS
FROM deduped_support_tickets
WHERE rn = 1
