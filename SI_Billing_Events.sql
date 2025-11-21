{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_BILLING_EVENTS', 'PIPELINE_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_BILLING_EVENTS', 'PIPELINE_END', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_Audit_Log'"
) }}

/* Silver Layer Billing Events Table - Cleaned billing data */
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
    WHERE EVENT_ID IS NOT NULL
),

cleaned_billing_events AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        UPPER(TRIM(EVENT_TYPE)) AS EVENT_TYPE,
        
        /* Numeric field cleaning for AMOUNT */
        CASE 
            WHEN TRY_TO_NUMBER(REGEXP_REPLACE(AMOUNT::STRING, '[^0-9.]', '')) IS NOT NULL THEN
                TRY_TO_NUMBER(REGEXP_REPLACE(AMOUNT::STRING, '[^0-9.]', ''))
            ELSE TRY_TO_NUMBER(AMOUNT::STRING)
        END AS AMOUNT,
        
        EVENT_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM bronze_billing_events
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
            ELSE 50
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
            WHEN EVENT_ID IS NOT NULL AND USER_ID IS NOT NULL AND EVENT_TYPE IS NOT NULL 
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM cleaned_billing_events
),

/* Remove duplicates - keep latest record based on UPDATE_TIMESTAMP */
deduped_billing_events AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY EVENT_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
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
    AND VALIDATION_STATUS != 'FAILED'
