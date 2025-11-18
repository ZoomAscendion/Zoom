{{ config(
    materialized='table'
) }}

/* Silver layer transformation for Billing Events */
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

cleaned_billing_events AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        COALESCE(UPPER(TRIM(EVENT_TYPE)), 'PAYMENT') AS EVENT_TYPE,
        COALESCE(ROUND(AMOUNT, 2), 0.00) AS AMOUNT,
        COALESCE(EVENT_DATE, CURRENT_DATE()) AS EVENT_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        COALESCE(DATE(UPDATE_TIMESTAMP), DATE(LOAD_TIMESTAMP)) AS UPDATE_DATE
    FROM bronze_billing_events
    WHERE COALESCE(AMOUNT, 0) > 0
        AND COALESCE(EVENT_DATE, CURRENT_DATE()) <= CURRENT_DATE()
),

validated_billing_events AS (
    SELECT 
        *,
        /* Data quality score calculation */
        CASE 
            WHEN EVENT_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND EVENT_TYPE != 'PAYMENT'
                AND AMOUNT > 0
                AND EVENT_DATE <= CURRENT_DATE()
            THEN 100
            WHEN EVENT_ID IS NOT NULL AND USER_ID IS NOT NULL 
            THEN 75
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        
        /* Validation status */
        CASE 
            WHEN EVENT_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND EVENT_TYPE != 'PAYMENT'
                AND AMOUNT > 0
                AND EVENT_DATE <= CURRENT_DATE()
            THEN 'PASSED'
            WHEN EVENT_ID IS NOT NULL AND USER_ID IS NOT NULL 
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM cleaned_billing_events
),

deduped_billing_events AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY EVENT_ID ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC) AS rn
    FROM validated_billing_events
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
FROM deduped_billing_events
WHERE rn = 1
