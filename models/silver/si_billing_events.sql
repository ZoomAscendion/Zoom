{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

/* Silver Billing Events Table - Cleaned and standardized financial transactions */

WITH bronze_billing_events AS (
    SELECT *
    FROM {{ source('bronze', 'bz_billing_events') }}
),

numeric_field_cleaning AS (
    SELECT 
        bbe.*,
        /* Clean numeric fields with potential text or quote issues */
        CASE 
            WHEN TRY_TO_NUMBER(REPLACE(bbe.AMOUNT::STRING, '"', '')) IS NOT NULL THEN
                TRY_TO_NUMBER(REPLACE(bbe.AMOUNT::STRING, '"', ''))
            ELSE TRY_TO_NUMBER(bbe.AMOUNT::STRING)
        END AS CLEAN_AMOUNT
    FROM bronze_billing_events bbe
),

data_quality_checks AS (
    SELECT 
        nfc.*,
        /* Data Quality Score Calculation */
        (
            CASE WHEN nfc.EVENT_ID IS NOT NULL THEN 25 ELSE 0 END +
            CASE WHEN nfc.USER_ID IS NOT NULL THEN 25 ELSE 0 END +
            CASE WHEN nfc.EVENT_TYPE IS NOT NULL AND LENGTH(TRIM(nfc.EVENT_TYPE)) > 0 THEN 20 ELSE 0 END +
            CASE WHEN nfc.CLEAN_AMOUNT IS NOT NULL AND nfc.CLEAN_AMOUNT > 0 THEN 15 ELSE 0 END +
            CASE WHEN nfc.EVENT_DATE IS NOT NULL AND nfc.EVENT_DATE <= CURRENT_DATE() THEN 15 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        /* Validation Status */
        CASE 
            WHEN nfc.EVENT_ID IS NULL OR nfc.USER_ID IS NULL THEN 'FAILED'
            WHEN nfc.EVENT_TYPE IS NULL OR LENGTH(TRIM(nfc.EVENT_TYPE)) = 0 THEN 'FAILED'
            WHEN nfc.CLEAN_AMOUNT IS NULL OR nfc.CLEAN_AMOUNT <= 0 THEN 'FAILED'
            WHEN nfc.EVENT_DATE IS NULL OR nfc.EVENT_DATE > CURRENT_DATE() THEN 'FAILED'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM numeric_field_cleaning nfc
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY EVENT_ID 
            ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC
        ) AS row_num
    FROM data_quality_checks
    WHERE EVENT_ID IS NOT NULL
),

final_billing_events AS (
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
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        DATA_QUALITY_SCORE,
        VALIDATION_STATUS
    FROM deduplication
    WHERE row_num = 1
      AND VALIDATION_STATUS != 'FAILED'
)

SELECT * FROM final_billing_events
