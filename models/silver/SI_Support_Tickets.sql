{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_SUPPORT_TICKETS', 'PIPELINE_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_SUPPORT_TICKETS', 'PIPELINE_END', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_Audit_Log'"
) }}

/* Silver layer transformation for Support Tickets table */
WITH bronze_support_tickets AS (
    SELECT *
    FROM {{ source('bronze', 'BZ_SUPPORT_TICKETS') }}
),

data_quality_checks AS (
    SELECT 
        *,
        /* Data quality score calculation */
        (
            CASE WHEN TICKET_ID IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN USER_ID IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN TICKET_TYPE IS NOT NULL AND LENGTH(TRIM(TICKET_TYPE)) > 0 THEN 20 ELSE 0 END +
            CASE WHEN RESOLUTION_STATUS IN ('Open', 'In Progress', 'Resolved', 'Closed') THEN 20 ELSE 0 END +
            CASE WHEN OPEN_DATE IS NOT NULL AND OPEN_DATE <= CURRENT_DATE() THEN 20 ELSE 0 END
        ) AS data_quality_score,
        
        /* Validation status */
        CASE 
            WHEN TICKET_ID IS NULL OR USER_ID IS NULL OR TICKET_TYPE IS NULL THEN 'FAILED'
            WHEN RESOLUTION_STATUS NOT IN ('Open', 'In Progress', 'Resolved', 'Closed') THEN 'FAILED'
            WHEN OPEN_DATE IS NULL OR OPEN_DATE > CURRENT_DATE() THEN 'FAILED'
            ELSE 'PASSED'
        END AS validation_status
    FROM bronze_support_tickets
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY TICKET_ID 
            ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC
        ) AS row_num
    FROM data_quality_checks
    WHERE TICKET_ID IS NOT NULL
),

final_transformation AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        UPPER(TRIM(TICKET_TYPE)) AS TICKET_TYPE,
        RESOLUTION_STATUS,
        OPEN_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        data_quality_score AS DATA_QUALITY_SCORE,
        validation_status AS VALIDATION_STATUS
    FROM deduplication
    WHERE row_num = 1
    AND validation_status != 'FAILED'
)

SELECT * FROM final_transformation
