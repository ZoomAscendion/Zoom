{{ config(
    materialized='table'
) }}

/*
 * SI_BILLING_EVENTS - Silver Layer Billing Events Table
 * Transforms and cleanses billing event data from Bronze layer
 */

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
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM bronze_billing_events
    WHERE EVENT_ID IS NOT NULL
      AND AMOUNT > 0
      AND EVENT_DATE <= CURRENT_DATE()
),

validated_billing_events AS (
    SELECT 
        *,
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
    FROM cleansed_billing_events
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
FROM validated_billing_events
