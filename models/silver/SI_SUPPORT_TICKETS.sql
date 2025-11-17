{{ config(
    materialized='table',
    on_schema_change='sync_all_columns',
    pre_hook="
        INSERT INTO {{ ref('SI_AUDIT_LOG') }} (EXECUTION_ID, PIPELINE_NAME, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP)
        VALUES (UUID_STRING(), 'SI_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'STARTED', 'BRONZE.BZ_SUPPORT_TICKETS', '{{ this.schema }}.SI_SUPPORT_TICKETS', 'DBT_PIPELINE', CURRENT_TIMESTAMP())
    ",
    post_hook="
        UPDATE {{ ref('SI_AUDIT_LOG') }} 
        SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(), 
            EXECUTION_STATUS = 'SUCCESS',
            RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}),
            UPDATE_TIMESTAMP = CURRENT_TIMESTAMP()
        WHERE TARGET_TABLE = '{{ this.schema }}.SI_SUPPORT_TICKETS' 
        AND EXECUTION_STATUS = 'STARTED'
        AND EXECUTION_START_TIME >= CURRENT_TIMESTAMP() - INTERVAL '1 HOUR'
    "
) }}

-- Silver Layer Support Tickets Table
-- Purpose: Clean and standardized customer support requests and resolution tracking
-- Transformation: Bronze to Silver with data quality validations

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

data_quality_checks AS (
    SELECT 
        *,
        -- Data Quality Score Calculation
        CASE 
            WHEN TICKET_ID IS NOT NULL THEN 25 ELSE 0 END +
            CASE WHEN USER_ID IS NOT NULL THEN 25 ELSE 0 END +
            CASE WHEN TICKET_TYPE IS NOT NULL AND LENGTH(TRIM(TICKET_TYPE)) > 0 THEN 20 ELSE 0 END +
            CASE WHEN RESOLUTION_STATUS IN ('Open', 'In Progress', 'Resolved', 'Closed') THEN 20 ELSE 0 END +
            CASE WHEN OPEN_DATE IS NOT NULL AND OPEN_DATE <= CURRENT_DATE() THEN 10 ELSE 0 END
        AS DATA_QUALITY_SCORE,
        
        -- Validation Status
        CASE 
            WHEN TICKET_ID IS NULL OR USER_ID IS NULL THEN 'FAILED'
            WHEN TICKET_TYPE IS NULL OR LENGTH(TRIM(TICKET_TYPE)) = 0 THEN 'FAILED'
            WHEN OPEN_DATE IS NULL OR OPEN_DATE > CURRENT_DATE() THEN 'FAILED'
            WHEN RESOLUTION_STATUS NOT IN ('Open', 'In Progress', 'Resolved', 'Closed') THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM bronze_support_tickets
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY TICKET_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) as rn
    FROM data_quality_checks
),

final_transformation AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        UPPER(TRIM(TICKET_TYPE)) AS TICKET_TYPE,
        CASE 
            WHEN UPPER(TRIM(RESOLUTION_STATUS)) IN ('OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED') THEN 
                CASE UPPER(TRIM(RESOLUTION_STATUS))
                    WHEN 'OPEN' THEN 'Open'
                    WHEN 'IN PROGRESS' THEN 'In Progress'
                    WHEN 'RESOLVED' THEN 'Resolved'
                    WHEN 'CLOSED' THEN 'Closed'
                END
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
    FROM deduplication
    WHERE rn = 1
    AND VALIDATION_STATUS IN ('PASSED', 'WARNING') -- Exclude FAILED records
)

SELECT * FROM final_transformation
