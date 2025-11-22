{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_BILLING_EVENTS', 'PROCESS_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_BILLING_EVENTS', 'PROCESS_END', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE'"
) }}

/* Silver Billing Events table with data quality checks */
WITH bronze_billing_events AS (
    SELECT *
    FROM {{ source('bronze', 'BZ_BILLING_EVENTS') }}
),

/* Clean and validate billing events data */
validated_billing_events AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        UPPER(TRIM(EVENT_TYPE)) AS EVENT_TYPE,
        
        /* Clean and validate amount */
        CASE 
            WHEN TRY_TO_NUMBER(REPLACE(AMOUNT::STRING, '"', '')) IS NOT NULL AND TRY_TO_NUMBER(REPLACE(AMOUNT::STRING, '"', '')) > 0 THEN
                ROUND(TRY_TO_NUMBER(REPLACE(AMOUNT::STRING, '"', '')), 2)
            ELSE NULL
        END AS CLEAN_AMOUNT,
        
        EVENT_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        /* Row number for deduplication */
        ROW_NUMBER() OVER (PARTITION BY EVENT_ID ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC NULLS LAST) AS rn
    FROM bronze_billing_events
    WHERE EVENT_ID IS NOT NULL
),

/* Apply business rules and calculate data quality */
final_billing_events AS (
    SELECT 
        *,
        /* Data quality score calculation */
        CASE 
            WHEN EVENT_ID IS NULL THEN 0
            WHEN USER_ID IS NULL THEN 20
            WHEN EVENT_TYPE IS NULL OR LENGTH(TRIM(EVENT_TYPE)) = 0 THEN 40
            WHEN CLEAN_AMOUNT IS NULL OR CLEAN_AMOUNT <= 0 THEN 60
            WHEN EVENT_DATE IS NULL OR EVENT_DATE > CURRENT_DATE() THEN 80
            ELSE 100
        END AS DATA_QUALITY_SCORE,
        
        /* Validation status */
        CASE 
            WHEN EVENT_ID IS NULL OR USER_ID IS NULL THEN 'FAILED'
            WHEN EVENT_TYPE IS NULL OR LENGTH(TRIM(EVENT_TYPE)) = 0 THEN 'FAILED'
            WHEN CLEAN_AMOUNT IS NULL OR CLEAN_AMOUNT <= 0 THEN 'FAILED'
            WHEN EVENT_DATE IS NULL OR EVENT_DATE > CURRENT_DATE() THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM validated_billing_events
    WHERE rn = 1
)

SELECT 
    EVENT_ID,
    USER_ID,
    EVENT_TYPE,
    CLEAN_AMOUNT AS AMOUNT,
    EVENT_DATE,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
    CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATE(CURRENT_TIMESTAMP()) AS LOAD_DATE,
    DATE(CURRENT_TIMESTAMP()) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM final_billing_events
WHERE VALIDATION_STATUS != 'FAILED'
