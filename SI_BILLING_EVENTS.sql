{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_AUDIT_LOG') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_BILLING_EVENTS', 'PIPELINE_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_AUDIT_LOG'",
    post_hook="INSERT INTO {{ ref('SI_AUDIT_LOG') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_BILLING_EVENTS', 'PIPELINE_END', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_AUDIT_LOG'"
) }}

/* Transform Bronze billing events data to Silver layer with data quality checks */
WITH bronze_billing_events AS (
    SELECT *
    FROM {{ source('bronze', 'BZ_BILLING_EVENTS') }}
),

validated_billing_events AS (
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
        /* Data Quality Score Calculation */
        CASE 
            WHEN EVENT_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND EVENT_TYPE IS NOT NULL 
                AND AMOUNT > 0
                AND EVENT_DATE IS NOT NULL
                AND EVENT_DATE <= CURRENT_DATE()
            THEN 100
            WHEN EVENT_ID IS NOT NULL AND USER_ID IS NOT NULL AND EVENT_TYPE IS NOT NULL THEN 80
            WHEN EVENT_ID IS NOT NULL THEN 60
            ELSE 40
        END AS DATA_QUALITY_SCORE,
        /* Validation Status */
        CASE 
            WHEN EVENT_ID IS NULL OR USER_ID IS NULL OR EVENT_TYPE IS NULL THEN 'FAILED'
            WHEN AMOUNT <= 0 OR EVENT_DATE IS NULL OR EVENT_DATE > CURRENT_DATE() THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS,
        ROW_NUMBER() OVER (PARTITION BY EVENT_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_billing_events
    WHERE EVENT_ID IS NOT NULL
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
WHERE rn = 1
