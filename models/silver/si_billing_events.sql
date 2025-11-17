{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

/* Transform Bronze Billing Events to Silver Billing Events with amount validation */

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
    WHERE EVENT_ID IS NOT NULL
),

data_quality_checks AS (
    SELECT 
        *,
        /* Data Quality Score Calculation */
        (
            CASE WHEN EVENT_ID IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN USER_ID IS NOT NULL THEN 25 ELSE 0 END +
            CASE WHEN EVENT_TYPE IS NOT NULL AND LENGTH(TRIM(EVENT_TYPE)) > 0 THEN 20 ELSE 0 END +
            CASE WHEN AMOUNT IS NOT NULL AND AMOUNT > 0 THEN 25 ELSE 0 END +
            CASE WHEN EVENT_DATE IS NOT NULL AND EVENT_DATE <= CURRENT_DATE() THEN 10 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        /* Validation Status */
        CASE 
            WHEN (
                CASE WHEN EVENT_ID IS NOT NULL THEN 20 ELSE 0 END +
                CASE WHEN USER_ID IS NOT NULL THEN 25 ELSE 0 END +
                CASE WHEN EVENT_TYPE IS NOT NULL AND LENGTH(TRIM(EVENT_TYPE)) > 0 THEN 20 ELSE 0 END +
                CASE WHEN AMOUNT IS NOT NULL AND AMOUNT > 0 THEN 25 ELSE 0 END +
                CASE WHEN EVENT_DATE IS NOT NULL AND EVENT_DATE <= CURRENT_DATE() THEN 10 ELSE 0 END
            ) >= 90 THEN 'PASSED'
            WHEN (
                CASE WHEN EVENT_ID IS NOT NULL THEN 20 ELSE 0 END +
                CASE WHEN USER_ID IS NOT NULL THEN 25 ELSE 0 END +
                CASE WHEN EVENT_TYPE IS NOT NULL AND LENGTH(TRIM(EVENT_TYPE)) > 0 THEN 20 ELSE 0 END +
                CASE WHEN AMOUNT IS NOT NULL AND AMOUNT > 0 THEN 25 ELSE 0 END +
                CASE WHEN EVENT_DATE IS NOT NULL AND EVENT_DATE <= CURRENT_DATE() THEN 10 ELSE 0 END
            ) >= 70 THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM bronze_billing_events
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY EVENT_ID 
            ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC
        ) as rn
    FROM data_quality_checks
)

SELECT 
    EVENT_ID,
    USER_ID,
    UPPER(TRIM(EVENT_TYPE)) AS EVENT_TYPE,
    ROUND(AMOUNT, 2) AS AMOUNT,
    EVENT_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduplication
WHERE rn = 1
  AND VALIDATION_STATUS IN ('PASSED', 'WARNING')
  AND AMOUNT > 0
