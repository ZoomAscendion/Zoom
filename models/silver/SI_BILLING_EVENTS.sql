{{ config(
    materialized='table'
) }}

-- Silver layer transformation for Billing Events table
-- Applies data quality checks, amount validation, and business rules

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
),

-- Data quality validation and cleansing
cleansed_billing_events AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        UPPER(TRIM(EVENT_TYPE)) AS EVENT_TYPE,
        ROUND(AMOUNT, 2) AS AMOUNT,
        EVENT_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data quality scoring
        CASE 
            WHEN EVENT_ID IS NULL THEN 0
            WHEN USER_ID IS NULL THEN 20
            WHEN EVENT_TYPE IS NULL OR LENGTH(TRIM(EVENT_TYPE)) = 0 THEN 30
            WHEN AMOUNT IS NULL OR AMOUNT <= 0 THEN 40
            WHEN EVENT_DATE IS NULL THEN 50
            WHEN EVENT_DATE > CURRENT_DATE() THEN 60
            WHEN LENGTH(EVENT_TYPE) > 100 THEN 80
            ELSE 100
        END AS DATA_QUALITY_SCORE,
        
        -- Validation status
        CASE 
            WHEN EVENT_ID IS NULL OR USER_ID IS NULL THEN 'FAILED'
            WHEN EVENT_TYPE IS NULL OR LENGTH(TRIM(EVENT_TYPE)) = 0 THEN 'FAILED'
            WHEN AMOUNT IS NULL OR AMOUNT <= 0 THEN 'FAILED'
            WHEN EVENT_DATE IS NULL OR EVENT_DATE > CURRENT_DATE() THEN 'FAILED'
            WHEN LENGTH(EVENT_TYPE) > 100 THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM bronze_billing_events
),

-- Remove duplicates using ROW_NUMBER
deduped_billing_events AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY EVENT_ID ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC) AS rn
    FROM cleansed_billing_events
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
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_billing_events
WHERE rn = 1
  AND VALIDATION_STATUS IN ('PASSED', 'WARNING')
