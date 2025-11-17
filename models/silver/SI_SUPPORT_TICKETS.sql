{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_AUDIT_LOG') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_SUPPORT_TICKETS', 'PIPELINE_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_AUDIT_LOG'",
    post_hook="INSERT INTO {{ ref('SI_AUDIT_LOG') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_SUPPORT_TICKETS', 'PIPELINE_END', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_AUDIT_LOG'"
) }}

/* Silver layer support tickets table with status standardization */

WITH bronze_support_tickets AS (
    SELECT *
    FROM {{ source('bronze', 'BZ_SUPPORT_TICKETS') }}
),

data_quality_checks AS (
    SELECT 
        *,
        /* Data quality score calculation */
        (
            CASE WHEN TICKET_ID IS NOT NULL THEN 25 ELSE 0 END +
            CASE WHEN USER_ID IS NOT NULL THEN 25 ELSE 0 END +
            CASE WHEN TICKET_TYPE IS NOT NULL AND LENGTH(TRIM(TICKET_TYPE)) > 0 THEN 20 ELSE 0 END +
            CASE WHEN RESOLUTION_STATUS IN ('Open', 'In Progress', 'Resolved', 'Closed') THEN 20 ELSE 0 END +
            CASE WHEN OPEN_DATE IS NOT NULL AND OPEN_DATE <= CURRENT_DATE() THEN 10 ELSE 0 END
        ) AS data_quality_score,
        
        /* Validation status */
        CASE 
            WHEN TICKET_ID IS NULL OR USER_ID IS NULL THEN 'FAILED'
            WHEN TICKET_TYPE IS NULL OR LENGTH(TRIM(TICKET_TYPE)) = 0 THEN 'FAILED'
            WHEN RESOLUTION_STATUS NOT IN ('Open', 'In Progress', 'Resolved', 'Closed') THEN 'FAILED'
            WHEN OPEN_DATE IS NULL OR OPEN_DATE > CURRENT_DATE() THEN 'FAILED'
            ELSE 'PASSED'
        END AS validation_status
    FROM bronze_support_tickets
),

cleaned_data AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        UPPER(TRIM(TICKET_TYPE)) AS TICKET_TYPE,
        CASE 
            WHEN UPPER(TRIM(RESOLUTION_STATUS)) IN ('OPEN', 'NEW', 'CREATED') THEN 'Open'
            WHEN UPPER(TRIM(RESOLUTION_STATUS)) IN ('IN PROGRESS', 'INPROGRESS', 'WORKING', 'ASSIGNED') THEN 'In Progress'
            WHEN UPPER(TRIM(RESOLUTION_STATUS)) IN ('RESOLVED', 'FIXED', 'COMPLETED') THEN 'Resolved'
            WHEN UPPER(TRIM(RESOLUTION_STATUS)) IN ('CLOSED', 'DONE', 'FINISHED') THEN 'Closed'
            ELSE COALESCE(RESOLUTION_STATUS, 'Open')
        END AS RESOLUTION_STATUS,
        OPEN_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        data_quality_score,
        validation_status
    FROM data_quality_checks
    WHERE TICKET_ID IS NOT NULL
    AND USER_ID IS NOT NULL
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY TICKET_ID ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC) AS rn
    FROM cleaned_data
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
    data_quality_score AS DATA_QUALITY_SCORE,
    validation_status AS VALIDATION_STATUS
FROM deduplication
WHERE rn = 1
AND validation_status != 'FAILED'
