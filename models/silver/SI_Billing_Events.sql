{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_BILLING_EVENTS', 'PIPELINE_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_BILLING_EVENTS', 'PIPELINE_END', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_Audit_Log'"
) }}

/* Silver Billing Events Table - Cleaned and standardized financial transactions */

WITH bronze_billing_events AS (
    SELECT *
    FROM {{ source('bronze', 'BZ_BILLING_EVENTS') }}
),

cleaned_billing_events AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        UPPER(TRIM(EVENT_TYPE)) AS EVENT_TYPE,
        ROUND(AMOUNT, 2) AS AMOUNT,
        EVENT_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
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
            THEN 80
            WHEN EVENT_ID IS NOT NULL 
            THEN 60
            ELSE 40
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
),

deduped_billing_events AS (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY EVENT_ID ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC) AS rn
        FROM validated_billing_events
    )
    WHERE rn = 1
)

SELECT 
    EVENT_ID,
    USER_ID,
    EVENT_TYPE,
    AMOUNT,
    EVENT_DATE,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
    CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATE(CURRENT_TIMESTAMP()) AS LOAD_DATE,
    DATE(CURRENT_TIMESTAMP()) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_billing_events
WHERE VALIDATION_STATUS != 'FAILED'
