{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (TABLE_NAME, STATUS, EXECUTION_START_TIME, EXECUTED_BY, LOAD_TIMESTAMP) SELECT 'SI_SUPPORT_TICKETS', 'STARTED', CURRENT_TIMESTAMP(), 'DBT_PIPELINE', CURRENT_TIMESTAMP()",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (TABLE_NAME, STATUS, EXECUTION_END_TIME, RECORDS_PROCESSED, RECORDS_SUCCESS, EXECUTED_BY, UPDATE_TIMESTAMP) SELECT 'SI_SUPPORT_TICKETS', 'COMPLETED', CURRENT_TIMESTAMP(), (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }} WHERE VALIDATION_STATUS = 'PASSED'), 'DBT_PIPELINE', CURRENT_TIMESTAMP()"
) }}

-- Silver Layer Support Tickets Table
-- Purpose: Clean and standardized customer support requests and resolution tracking
-- Transformation: Bronze BZ_SUPPORT_TICKETS -> Silver SI_SUPPORT_TICKETS

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
        t.*,
        -- Resolution status validation
        CASE 
            WHEN t.RESOLUTION_STATUS IN ('Open', 'In Progress', 'Resolved', 'Closed') THEN 1
            ELSE 0
        END AS status_valid,
        
        -- User reference validation
        CASE 
            WHEN u.USER_ID IS NOT NULL THEN 1
            ELSE 0
        END AS user_ref_valid,
        
        -- Open date validation
        CASE 
            WHEN t.OPEN_DATE <= CURRENT_DATE() THEN 1
            ELSE 0
        END AS date_valid,
        
        -- Calculate data quality score
        CASE 
            WHEN t.TICKET_ID IS NOT NULL AND t.USER_ID IS NOT NULL AND t.TICKET_TYPE IS NOT NULL 
                 AND t.RESOLUTION_STATUS IS NOT NULL AND t.OPEN_DATE IS NOT NULL THEN
                CASE 
                    WHEN t.RESOLUTION_STATUS IN ('Open', 'In Progress', 'Resolved', 'Closed') 
                         AND u.USER_ID IS NOT NULL AND t.OPEN_DATE <= CURRENT_DATE() THEN 100
                    WHEN t.RESOLUTION_STATUS IN ('Open', 'In Progress', 'Resolved', 'Closed') 
                         AND t.OPEN_DATE <= CURRENT_DATE() THEN 80
                    WHEN t.OPEN_DATE <= CURRENT_DATE() THEN 60
                    ELSE 40
                END
            ELSE 0
        END AS data_quality_score
    FROM bronze_support_tickets t
    LEFT JOIN {{ ref('SI_USERS') }} u ON t.USER_ID = u.USER_ID
),

deduplication AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY TICKET_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM data_quality_checks
),

cleaned_support_tickets AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        COALESCE(TRIM(TICKET_TYPE), 'General') AS TICKET_TYPE,
        CASE 
            WHEN RESOLUTION_STATUS IN ('Open', 'In Progress', 'Resolved', 'Closed') THEN RESOLUTION_STATUS
            ELSE 'Open'
        END AS RESOLUTION_STATUS,
        OPEN_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Additional Silver layer metadata
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        data_quality_score AS DATA_QUALITY_SCORE,
        CASE 
            WHEN data_quality_score >= 80 THEN 'PASSED'
            WHEN data_quality_score >= 50 THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM deduplication
    WHERE rn = 1
      AND TICKET_ID IS NOT NULL
      AND USER_ID IS NOT NULL
      AND OPEN_DATE <= CURRENT_DATE()
)

SELECT * FROM cleaned_support_tickets
