{{ config(
    materialized='table'
) }}

-- Silver Billing Events table transformation from Bronze layer
-- Validates amounts and standardizes event types

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

-- Data cleansing and standardization
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
            WHEN EVENT_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND EVENT_TYPE IS NOT NULL 
                AND AMOUNT IS NOT NULL 
                AND AMOUNT > 0
                AND EVENT_DATE IS NOT NULL
                AND EVENT_DATE <= CURRENT_DATE()
            THEN 100
            WHEN EVENT_ID IS NOT NULL AND USER_ID IS NOT NULL AND EVENT_TYPE IS NOT NULL 
            THEN 75
            WHEN EVENT_ID IS NOT NULL 
            THEN 50
            ELSE 25
        END AS DATA_QUALITY_SCORE,
        
        -- Validation status
        CASE 
            WHEN EVENT_ID IS NULL OR USER_ID IS NULL THEN 'FAILED'
            WHEN EVENT_TYPE IS NULL OR LENGTH(TRIM(EVENT_TYPE)) = 0 THEN 'FAILED'
            WHEN AMOUNT IS NULL OR AMOUNT <= 0 THEN 'FAILED'
            WHEN EVENT_DATE IS NULL THEN 'FAILED'
            WHEN EVENT_DATE > CURRENT_DATE() THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM bronze_billing_events
    WHERE EVENT_ID IS NOT NULL
),

-- Remove duplicates keeping the latest record
deduped_billing_events AS (
    SELECT *
    FROM (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY EVENT_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
        FROM cleansed_billing_events
    )
    WHERE rn = 1
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
WHERE VALIDATION_STATUS != 'FAILED'  -- Exclude failed records
