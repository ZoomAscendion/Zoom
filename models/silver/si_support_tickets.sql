{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

-- Bronze to Silver transformation for Support Tickets
-- Implements data quality checks and calculated fields

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
      AND TRIM(TICKET_ID) != ''
),

data_quality_checks AS (
    SELECT 
        bst.*,
        -- Standardize resolution status
        CASE 
            WHEN UPPER(TRIM(bst.RESOLUTION_STATUS)) IN ('OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED')
            THEN UPPER(TRIM(bst.RESOLUTION_STATUS))
            ELSE 'UNKNOWN'
        END AS standardized_status,
        
        -- Calculate resolution time (simplified - assuming closed tickets have resolution time)
        CASE 
            WHEN UPPER(TRIM(bst.RESOLUTION_STATUS)) IN ('RESOLVED', 'CLOSED') AND bst.OPEN_DATE IS NOT NULL
            THEN DATEDIFF('hour', bst.OPEN_DATE, CURRENT_TIMESTAMP())
            ELSE NULL
        END AS calculated_resolution_time,
        
        -- Validation checks
        CASE 
            WHEN bst.USER_ID IS NULL THEN 'MISSING_USER_ID'
            WHEN bst.TICKET_TYPE IS NULL OR TRIM(bst.TICKET_TYPE) = '' THEN 'MISSING_TICKET_TYPE'
            WHEN bst.OPEN_DATE IS NULL THEN 'MISSING_OPEN_DATE'
            WHEN bst.OPEN_DATE > CURRENT_DATE() THEN 'FUTURE_OPEN_DATE'
            ELSE 'VALID'
        END AS validation_status
    FROM bronze_support_tickets bst
),

valid_records AS (
    SELECT 
        dqc.TICKET_ID,
        dqc.USER_ID,
        UPPER(TRIM(dqc.TICKET_TYPE)) AS TICKET_TYPE,
        dqc.standardized_status AS RESOLUTION_STATUS,
        dqc.OPEN_DATE,
        GREATEST(dqc.calculated_resolution_time, 0) AS RESOLUTION_TIME_HOURS,
        DATE(dqc.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(dqc.UPDATE_TIMESTAMP) AS UPDATE_DATE,
        dqc.SOURCE_SYSTEM,
        dqc.LOAD_TIMESTAMP,
        dqc.UPDATE_TIMESTAMP,
        ROW_NUMBER() OVER (PARTITION BY dqc.TICKET_ID ORDER BY dqc.UPDATE_TIMESTAMP DESC) AS rn
    FROM data_quality_checks dqc
    INNER JOIN {{ ref('si_users') }} u ON dqc.USER_ID = u.USER_ID
    WHERE dqc.validation_status = 'VALID'
      AND dqc.standardized_status != 'UNKNOWN'
)

SELECT 
    TICKET_ID,
    USER_ID,
    TICKET_TYPE,
    RESOLUTION_STATUS,
    OPEN_DATE,
    RESOLUTION_TIME_HOURS,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP
FROM valid_records
WHERE rn = 1
