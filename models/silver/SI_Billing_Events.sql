{{ config(
    materialized='table'
) }}

/* Silver Layer Billing Events Table Transformation */
WITH bronze_billing_events AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        EVENT_TYPE,
        AMOUNT,
        EVENT_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM BRONZE.BZ_BILLING_EVENTS
    WHERE EVENT_ID IS NOT NULL
),

data_quality_checks AS (
    SELECT 
        *,
        /* Clean amount - handle numeric fields with text or quotes */
        CASE 
            WHEN TRY_TO_NUMBER(REPLACE(AMOUNT::STRING, '"', '')) IS NOT NULL THEN
                TRY_TO_NUMBER(REPLACE(AMOUNT::STRING, '"', ''))
            ELSE TRY_TO_NUMBER(AMOUNT::STRING)
        END AS CLEAN_AMOUNT,
        
        /* Data Quality Score Calculation */
        (
            CASE WHEN EVENT_ID IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN USER_ID IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN EVENT_TYPE IS NOT NULL AND LENGTH(TRIM(EVENT_TYPE)) > 0 THEN 20 ELSE 0 END +
            CASE WHEN AMOUNT IS NOT NULL AND AMOUNT > 0 THEN 20 ELSE 0 END +
            CASE WHEN EVENT_DATE IS NOT NULL AND EVENT_DATE <= CURRENT_DATE() THEN 20 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        /* Validation Status */
        CASE 
            WHEN EVENT_ID IS NULL OR USER_ID IS NULL THEN 'FAILED'
            WHEN AMOUNT IS NULL OR AMOUNT <= 0 THEN 'FAILED'
            WHEN EVENT_DATE > CURRENT_DATE() THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM bronze_billing_events
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY EVENT_ID ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC, LOAD_TIMESTAMP DESC) as rn
    FROM data_quality_checks
)

SELECT 
    EVENT_ID,
    USER_ID,
    UPPER(TRIM(EVENT_TYPE)) AS EVENT_TYPE,
    ROUND(CLEAN_AMOUNT, 2) AS AMOUNT,
    EVENT_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    COALESCE(DATE(UPDATE_TIMESTAMP), DATE(LOAD_TIMESTAMP)) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduplication
WHERE rn = 1
  AND VALIDATION_STATUS != 'FAILED'
  AND CLEAN_AMOUNT IS NOT NULL
  AND CLEAN_AMOUNT > 0
