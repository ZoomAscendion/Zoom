{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

/* Silver Billing Events Table - Cleaned and standardized financial transactions */

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

deduped_billing_events AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY EVENT_ID 
            ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC NULLS LAST
        ) AS rn
    FROM bronze_billing_events
    WHERE EVENT_ID IS NOT NULL
),

cleaned_billing_events AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        UPPER(TRIM(EVENT_TYPE)) AS EVENT_TYPE,
        /* Clean numeric fields with quotes */
        CASE 
            WHEN TRY_TO_NUMBER(REPLACE(AMOUNT::STRING, '"', '')) IS NOT NULL THEN
                TRY_TO_NUMBER(REPLACE(AMOUNT::STRING, '"', ''))
            ELSE TRY_TO_NUMBER(AMOUNT::STRING)
        END AS AMOUNT,
        EVENT_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM deduped_billing_events
    WHERE rn = 1
),

validated_billing_events AS (
    SELECT *,
        /* Data Quality Score Calculation */
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
        
        /* Validation Status */
        CASE 
            WHEN EVENT_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND EVENT_TYPE IS NOT NULL 
                AND AMOUNT IS NOT NULL 
                AND AMOUNT > 0
                AND EVENT_DATE IS NOT NULL 
                AND EVENT_DATE <= CURRENT_DATE()
            THEN 'PASSED'
            WHEN EVENT_ID IS NOT NULL AND USER_ID IS NOT NULL 
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM cleaned_billing_events
)

SELECT 
    EVENT_ID,
    USER_ID,
    EVENT_TYPE,
    ROUND(AMOUNT, 2) AS AMOUNT,
    EVENT_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    LOAD_DATE,
    UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM validated_billing_events
WHERE VALIDATION_STATUS IN ('PASSED', 'WARNING')
