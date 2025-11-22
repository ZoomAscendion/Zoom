{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT 'SI_BILLING_EVENTS', 'PROCESSING_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT 'SI_BILLING_EVENTS', 'PROCESSING_END', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_Audit_Log'"
) }}

/* Transform Bronze Billing Events to Silver Billing Events */
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
    FROM {{ source('bronze', 'BZ_BILLING_EVENTS') }}
),

numeric_cleaning AS (
    SELECT 
        *,
        /* Clean numeric fields with potential text units */
        CASE 
            WHEN TRY_TO_NUMBER(REGEXP_REPLACE(AMOUNT::STRING, '[^0-9.]', '')) IS NOT NULL THEN
                TRY_TO_NUMBER(REGEXP_REPLACE(AMOUNT::STRING, '[^0-9.]', ''))
            ELSE TRY_TO_NUMBER(AMOUNT::STRING)
        END AS CLEAN_AMOUNT
    FROM bronze_billing_events
),

data_quality_checks AS (
    SELECT 
        *,
        /* Data Quality Score Calculation */
        CASE 
            WHEN EVENT_ID IS NULL THEN 0
            WHEN USER_ID IS NULL OR EVENT_TYPE IS NULL THEN 20
            WHEN CLEAN_AMOUNT IS NULL OR CLEAN_AMOUNT <= 0 THEN 40
            WHEN EVENT_DATE IS NULL OR EVENT_DATE > CURRENT_DATE() THEN 60
            ELSE 100
        END AS DATA_QUALITY_SCORE,
        
        /* Validation Status */
        CASE 
            WHEN EVENT_ID IS NULL OR USER_ID IS NULL OR EVENT_TYPE IS NULL THEN 'FAILED'
            WHEN CLEAN_AMOUNT IS NULL OR CLEAN_AMOUNT <= 0 THEN 'FAILED'
            WHEN EVENT_DATE IS NULL OR EVENT_DATE > CURRENT_DATE() THEN 'FAILED'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM numeric_cleaning
),

cleaned_data AS (
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
        VALIDATION_STATUS,
        /* Silver layer timestamp overwrite */
        CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
        CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP
    FROM data_quality_checks
    WHERE EVENT_ID IS NOT NULL
    AND USER_ID IS NOT NULL
    AND EVENT_TYPE IS NOT NULL
    AND CLEAN_AMOUNT IS NOT NULL
    AND CLEAN_AMOUNT > 0
    AND EVENT_DATE IS NOT NULL
    AND EVENT_DATE <= CURRENT_DATE()
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY EVENT_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM cleaned_data
)

SELECT 
    EVENT_ID,
    USER_ID,
    EVENT_TYPE,
    AMOUNT,
    EVENT_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    LOAD_DATE,
    UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduplication
WHERE rn = 1
