{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_BILLING_EVENTS', 'PIPELINE_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_BILLING_EVENTS', 'PIPELINE_END', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_Audit_Log'"
) }}

/* Silver Layer Billing Events Table */
/* Purpose: Cleaned and standardized financial transactions and billing activities */

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

data_quality_checks AS (
    SELECT 
        *,
        /* Data Quality Score Calculation */
        CASE 
            WHEN EVENT_ID IS NULL THEN 0
            WHEN USER_ID IS NULL THEN 20
            WHEN EVENT_TYPE IS NULL OR LENGTH(TRIM(EVENT_TYPE)) = 0 THEN 40
            WHEN AMOUNT IS NULL OR AMOUNT <= 0 THEN 60
            WHEN EVENT_DATE IS NULL OR EVENT_DATE > CURRENT_DATE() THEN 80
            ELSE 100
        END AS DATA_QUALITY_SCORE,
        
        /* Validation Status */
        CASE 
            WHEN EVENT_ID IS NULL OR USER_ID IS NULL THEN 'FAILED'
            WHEN EVENT_TYPE IS NULL OR LENGTH(TRIM(EVENT_TYPE)) = 0 THEN 'FAILED'
            WHEN AMOUNT IS NULL OR AMOUNT <= 0 THEN 'FAILED'
            WHEN EVENT_DATE IS NULL OR EVENT_DATE > CURRENT_DATE() THEN 'FAILED'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM bronze_billing_events
),

cleaned_billing_events AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        UPPER(TRIM(EVENT_TYPE)) AS EVENT_TYPE,
        ROUND(AMOUNT, 2) AS AMOUNT,
        EVENT_DATE,
        CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
        CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(CURRENT_TIMESTAMP()) AS LOAD_DATE,
        DATE(CURRENT_TIMESTAMP()) AS UPDATE_DATE,
        DATA_QUALITY_SCORE,
        VALIDATION_STATUS
    FROM data_quality_checks
    WHERE EVENT_ID IS NOT NULL
      AND USER_ID IS NOT NULL
      AND EVENT_TYPE IS NOT NULL
      AND LENGTH(TRIM(EVENT_TYPE)) > 0
      AND AMOUNT IS NOT NULL
      AND AMOUNT > 0
      AND EVENT_DATE IS NOT NULL
      AND EVENT_DATE <= CURRENT_DATE()
    QUALIFY ROW_NUMBER() OVER (PARTITION BY EVENT_ID ORDER BY UPDATE_TIMESTAMP DESC) = 1
)

SELECT * FROM cleaned_billing_events
