{{ config(
    materialized='table'
) }}

-- Silver Layer Billing Events Table Transformation
-- Transforms Bronze BZ_BILLING_EVENTS to Silver SI_BILLING_EVENTS with data quality checks

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

validated_billing_events AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        UPPER(TRIM(EVENT_TYPE)) as EVENT_TYPE,
        ROUND(AMOUNT, 2) as AMOUNT,
        EVENT_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data Quality Score Calculation
        CASE 
            WHEN EVENT_ID IS NULL THEN 0
            WHEN USER_ID IS NULL THEN 20
            WHEN EVENT_TYPE IS NULL OR LENGTH(TRIM(EVENT_TYPE)) = 0 THEN 30
            WHEN AMOUNT IS NULL OR AMOUNT <= 0 THEN 40
            WHEN EVENT_DATE IS NULL THEN 50
            WHEN EVENT_DATE > CURRENT_DATE() THEN 60
            ELSE 100
        END as DATA_QUALITY_SCORE,
        
        -- Validation Status
        CASE 
            WHEN EVENT_ID IS NULL OR USER_ID IS NULL OR EVENT_TYPE IS NULL OR LENGTH(TRIM(EVENT_TYPE)) = 0 THEN 'FAILED'
            WHEN AMOUNT IS NULL OR AMOUNT <= 0 OR EVENT_DATE IS NULL OR EVENT_DATE > CURRENT_DATE() THEN 'FAILED'
            ELSE 'PASSED'
        END as VALIDATION_STATUS
    FROM bronze_billing_events
),

deduped_billing_events AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        EVENT_TYPE,
        AMOUNT,
        EVENT_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATA_QUALITY_SCORE,
        VALIDATION_STATUS,
        ROW_NUMBER() OVER (PARTITION BY EVENT_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) as rn
    FROM validated_billing_events
    WHERE EVENT_ID IS NOT NULL
      AND USER_ID IS NOT NULL
      AND EVENT_TYPE IS NOT NULL
      AND LENGTH(TRIM(EVENT_TYPE)) > 0
      AND AMOUNT IS NOT NULL
      AND AMOUNT > 0
      AND EVENT_DATE IS NOT NULL
      AND EVENT_DATE <= CURRENT_DATE()
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
    DATE(LOAD_TIMESTAMP) as LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) as UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_billing_events
WHERE rn = 1
