{{ config(
    materialized='table'
) }}

-- Silver Layer Billing Events Table
-- Transforms and cleanses billing event data from Bronze layer
-- Handles string-formatted numeric values

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
    FROM {{ source('bronze', 'bz_billing_events') }}
),

-- Data Quality and Transformation Layer
cleansed_billing_events AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        UPPER(TRIM(EVENT_TYPE)) AS EVENT_TYPE,
        -- Handle string-formatted numeric values
        CASE 
            WHEN AMOUNT IS NULL THEN NULL
            WHEN TRY_CAST(AMOUNT AS NUMBER(10,2)) IS NOT NULL THEN ROUND(TRY_CAST(AMOUNT AS NUMBER(10,2)), 2)
            WHEN TRY_CAST(REPLACE(REPLACE(AMOUNT::STRING, '"', ''), ',', '') AS NUMBER(10,2)) IS NOT NULL THEN 
                ROUND(TRY_CAST(REPLACE(REPLACE(AMOUNT::STRING, '"', ''), ',', '') AS NUMBER(10,2)), 2)
            ELSE NULL
        END AS AMOUNT,
        EVENT_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data Quality Scoring
        CASE 
            WHEN EVENT_ID IS NULL THEN 0
            WHEN USER_ID IS NULL THEN 20
            WHEN EVENT_TYPE IS NULL OR LENGTH(TRIM(EVENT_TYPE)) = 0 THEN 30
            WHEN AMOUNT IS NULL OR TRY_CAST(REPLACE(REPLACE(AMOUNT::STRING, '"', ''), ',', '') AS NUMBER(10,2)) IS NULL THEN 40
            WHEN TRY_CAST(REPLACE(REPLACE(AMOUNT::STRING, '"', ''), ',', '') AS NUMBER(10,2)) <= 0 THEN 45
            WHEN EVENT_DATE IS NULL OR EVENT_DATE > CURRENT_DATE() THEN 50
            ELSE 100
        END AS DATA_QUALITY_SCORE,
        
        -- Validation Status
        CASE 
            WHEN EVENT_ID IS NULL OR USER_ID IS NULL THEN 'FAILED'
            WHEN EVENT_TYPE IS NULL OR LENGTH(TRIM(EVENT_TYPE)) = 0 THEN 'FAILED'
            WHEN AMOUNT IS NULL OR TRY_CAST(REPLACE(REPLACE(AMOUNT::STRING, '"', ''), ',', '') AS NUMBER(10,2)) IS NULL THEN 'FAILED'
            WHEN TRY_CAST(REPLACE(REPLACE(AMOUNT::STRING, '"', ''), ',', '') AS NUMBER(10,2)) <= 0 THEN 'FAILED'
            WHEN EVENT_DATE IS NULL OR EVENT_DATE > CURRENT_DATE() THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM bronze_billing_events
),

-- Remove duplicates - keep latest record
deduped_billing_events AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY EVENT_ID ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC) AS rn
    FROM cleansed_billing_events
    WHERE EVENT_ID IS NOT NULL
      AND AMOUNT IS NOT NULL
)

-- Final Select with Silver layer metadata
SELECT 
    EVENT_ID,
    USER_ID,
    EVENT_TYPE,
    AMOUNT,
    EVENT_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_billing_events
WHERE rn = 1
  AND VALIDATION_STATUS != 'FAILED'
