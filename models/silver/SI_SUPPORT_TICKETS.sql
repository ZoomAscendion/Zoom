{{ config(
    materialized='table',
    on_schema_change='sync_all_columns',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP) VALUES ('{{ invocation_id }}', 'SI_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'RUNNING', 'BRONZE.BZ_SUPPORT_TICKETS', 'SILVER.SI_SUPPORT_TICKETS', 'DBT_PIPELINE', CURRENT_TIMESTAMP())",
    post_hook="UPDATE {{ ref('SI_Audit_Log') }} SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(), EXECUTION_STATUS = 'SUCCESS', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), RECORDS_SUCCESS = (SELECT COUNT(*) FROM {{ this }}) WHERE EXECUTION_ID = '{{ invocation_id }}' AND TARGET_TABLE = 'SILVER.SI_SUPPORT_TICKETS'"
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
    FROM {{ source('bronze', 'BZ_SUPPORT_TICKETS') }}
),

cleansed_support_tickets AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        
        -- Ticket type standardization
        CASE 
            WHEN TICKET_TYPE IS NULL OR TRIM(TICKET_TYPE) = '' THEN 'GENERAL'
            ELSE UPPER(TRIM(TICKET_TYPE))
        END AS TICKET_TYPE,
        
        -- Resolution status standardization
        CASE 
            WHEN UPPER(TRIM(RESOLUTION_STATUS)) IN ('OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED') THEN UPPER(TRIM(RESOLUTION_STATUS))
            WHEN RESOLUTION_STATUS IS NULL OR TRIM(RESOLUTION_STATUS) = '' THEN 'OPEN'
            ELSE 'OPEN'
        END AS RESOLUTION_STATUS,
        
        -- Open date validation
        CASE 
            WHEN OPEN_DATE IS NULL THEN DATE(LOAD_TIMESTAMP)
            WHEN OPEN_DATE > CURRENT_DATE() THEN CURRENT_DATE()
            ELSE OPEN_DATE
        END AS OPEN_DATE,
        
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Silver layer specific fields
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM bronze_support_tickets
    WHERE TICKET_ID IS NOT NULL
),

data_quality_scored AS (
    SELECT 
        *,
        -- Calculate data quality score (0-100)
        CASE 
            WHEN TICKET_ID IS NOT NULL 
                AND USER_ID IS NOT NULL
                AND TICKET_TYPE IS NOT NULL
                AND RESOLUTION_STATUS IN ('OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED')
                AND OPEN_DATE IS NOT NULL
            THEN 100
            WHEN TICKET_ID IS NOT NULL 
                AND USER_ID IS NOT NULL
                AND RESOLUTION_STATUS IN ('OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED')
            THEN 85
            WHEN TICKET_ID IS NOT NULL 
                AND USER_ID IS NOT NULL
            THEN 70
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        
        -- Validation status
        CASE 
            WHEN TICKET_ID IS NOT NULL 
                AND USER_ID IS NOT NULL
                AND RESOLUTION_STATUS IN ('OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED')
            THEN 'PASSED'
            WHEN TICKET_ID IS NOT NULL 
                AND USER_ID IS NOT NULL
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM cleansed_support_tickets
),

-- Remove duplicates keeping the latest record
deduped_support_tickets AS (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY TICKET_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) as rn
        FROM data_quality_scored
    )
    WHERE rn = 1
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
WHERE VALIDATION_STATUS != 'FAILED'
