{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_SUPPORT_TICKETS', 'PROCESS_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_SUPPORT_TICKETS', 'PROCESS_END', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE'"
) }}

/* Silver Support Tickets table with data quality checks */
WITH bronze_support_tickets AS (
    SELECT *
    FROM {{ source('bronze', 'BZ_SUPPORT_TICKETS') }}
),

/* Clean and validate support tickets data */
validated_support_tickets AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        UPPER(TRIM(TICKET_TYPE)) AS TICKET_TYPE,
        
        /* Standardize resolution status */
        CASE 
            WHEN UPPER(TRIM(RESOLUTION_STATUS)) IN ('OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED') THEN
                UPPER(TRIM(RESOLUTION_STATUS))
            ELSE 'OPEN'
        END AS CLEAN_RESOLUTION_STATUS,
        
        OPEN_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        /* Row number for deduplication */
        ROW_NUMBER() OVER (PARTITION BY TICKET_ID ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC NULLS LAST) AS rn
    FROM bronze_support_tickets
    WHERE TICKET_ID IS NOT NULL
),

/* Apply business rules and calculate data quality */
final_support_tickets AS (
    SELECT 
        *,
        /* Data quality score calculation */
        CASE 
            WHEN TICKET_ID IS NULL THEN 0
            WHEN USER_ID IS NULL THEN 20
            WHEN TICKET_TYPE IS NULL OR LENGTH(TRIM(TICKET_TYPE)) = 0 THEN 40
            WHEN CLEAN_RESOLUTION_STATUS IS NULL THEN 60
            WHEN OPEN_DATE IS NULL OR OPEN_DATE > CURRENT_DATE() THEN 80
            ELSE 100
        END AS DATA_QUALITY_SCORE,
        
        /* Validation status */
        CASE 
            WHEN TICKET_ID IS NULL OR USER_ID IS NULL THEN 'FAILED'
            WHEN TICKET_TYPE IS NULL OR LENGTH(TRIM(TICKET_TYPE)) = 0 THEN 'FAILED'
            WHEN OPEN_DATE IS NULL OR OPEN_DATE > CURRENT_DATE() THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM validated_support_tickets
    WHERE rn = 1
)

SELECT 
    TICKET_ID,
    USER_ID,
    TICKET_TYPE,
    CLEAN_RESOLUTION_STATUS AS RESOLUTION_STATUS,
    OPEN_DATE,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
    CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATE(CURRENT_TIMESTAMP()) AS LOAD_DATE,
    DATE(CURRENT_TIMESTAMP()) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM final_support_tickets
WHERE VALIDATION_STATUS != 'FAILED'
