{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (TABLE_NAME, STATUS, PROCESS_START_TIME, PROCESSED_BY, CREATED_AT) SELECT 'SI_SUPPORT_TICKETS', 'STARTED', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (TABLE_NAME, STATUS, PROCESS_END_TIME, PROCESSED_BY, RECORDS_PROCESSED, UPDATED_AT) SELECT 'SI_SUPPORT_TICKETS', 'COMPLETED', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE', (SELECT COUNT(*) FROM {{ this }}), CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'"
) }}

-- Silver layer transformation for Support Tickets table
-- Applies data quality checks and standardization

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
    WHERE TICKET_ID IS NOT NULL  -- Remove null ticket IDs
),

data_quality_checks AS (
    SELECT 
        *,
        -- Row number for deduplication
        ROW_NUMBER() OVER (PARTITION BY TICKET_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_support_tickets
),

cleansed_support_tickets AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        TRIM(UPPER(TICKET_TYPE)) AS TICKET_TYPE,
        CASE 
            WHEN UPPER(RESOLUTION_STATUS) IN ('OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED') THEN UPPER(RESOLUTION_STATUS)
            ELSE 'UNKNOWN'
        END AS RESOLUTION_STATUS,
        OPEN_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Additional Silver layer metadata
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        -- Data quality score calculation
        CASE 
            WHEN TICKET_TYPE IS NOT NULL 
                 AND RESOLUTION_STATUS IN ('OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED') 
                 AND OPEN_DATE IS NOT NULL 
                 AND OPEN_DATE <= CURRENT_DATE() THEN 100
            WHEN TICKET_TYPE IS NOT NULL 
                 AND RESOLUTION_STATUS IS NOT NULL 
                 AND OPEN_DATE IS NOT NULL THEN 75
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        CASE 
            WHEN TICKET_TYPE IS NOT NULL 
                 AND RESOLUTION_STATUS IN ('OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED') 
                 AND OPEN_DATE IS NOT NULL 
                 AND OPEN_DATE <= CURRENT_DATE() THEN 'PASSED'
            WHEN TICKET_TYPE IS NOT NULL 
                 AND RESOLUTION_STATUS IS NOT NULL 
                 AND OPEN_DATE IS NOT NULL THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS,
        CURRENT_TIMESTAMP() AS CREATED_AT,
        CURRENT_TIMESTAMP() AS UPDATED_AT
    FROM data_quality_checks
    WHERE rn = 1  -- Keep only the latest record for each ticket
      AND TICKET_TYPE IS NOT NULL
      AND RESOLUTION_STATUS IS NOT NULL
      AND OPEN_DATE IS NOT NULL
      AND OPEN_DATE <= CURRENT_DATE()  -- No future dates
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
    VALIDATION_STATUS,
    CREATED_AT,
    UPDATED_AT
FROM cleansed_support_tickets
