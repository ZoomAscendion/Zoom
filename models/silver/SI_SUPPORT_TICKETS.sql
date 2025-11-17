{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_AUDIT_LOG') }} (MODEL_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_START_TIME, STATUS, LOAD_TIMESTAMP) VALUES ('SI_SUPPORT_TICKETS', 'BZ_SUPPORT_TICKETS', 'SI_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'STARTED', CURRENT_TIMESTAMP())",
    post_hook="INSERT INTO {{ ref('SI_AUDIT_LOG') }} (MODEL_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_END_TIME, STATUS, RECORDS_SUCCESS, LOAD_TIMESTAMP) VALUES ('SI_SUPPORT_TICKETS', 'BZ_SUPPORT_TICKETS', 'SI_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'COMPLETED', (SELECT COUNT(*) FROM {{ this }}), CURRENT_TIMESTAMP())"
) }}

-- Silver layer transformation for Support Tickets table
-- Applies data quality checks and status standardization

WITH source_data AS (
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

data_quality_checks AS (
    SELECT 
        *,
        -- Data quality score calculation
        CASE 
            WHEN TICKET_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND TICKET_TYPE IS NOT NULL 
                AND RESOLUTION_STATUS IN ('Open', 'In Progress', 'Resolved', 'Closed')
                AND OPEN_DATE IS NOT NULL 
                AND OPEN_DATE <= CURRENT_DATE()
            THEN 100
            WHEN TICKET_ID IS NOT NULL AND USER_ID IS NOT NULL
            THEN 75
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        
        -- Validation status
        CASE 
            WHEN TICKET_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND TICKET_TYPE IS NOT NULL 
                AND RESOLUTION_STATUS IN ('Open', 'In Progress', 'Resolved', 'Closed')
                AND OPEN_DATE IS NOT NULL 
                AND OPEN_DATE <= CURRENT_DATE()
            THEN 'PASSED'
            WHEN TICKET_ID IS NOT NULL AND USER_ID IS NOT NULL
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM source_data
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY TICKET_ID ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC) AS rn
    FROM data_quality_checks
),

final_transformation AS (
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
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        DATA_QUALITY_SCORE,
        VALIDATION_STATUS
    FROM deduplication
    WHERE rn = 1  -- Keep only the latest record per ticket
        AND VALIDATION_STATUS != 'FAILED'  -- Exclude failed records
)

SELECT * FROM final_transformation
