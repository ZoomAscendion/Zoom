{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (TABLE_NAME, STATUS, PROCESS_START_TIME, PROCESSED_BY, CREATED_AT) SELECT 'SI_BILLING_EVENTS', 'STARTED', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (TABLE_NAME, STATUS, PROCESS_END_TIME, PROCESSED_BY, RECORDS_PROCESSED, UPDATED_AT) SELECT 'SI_BILLING_EVENTS', 'COMPLETED', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE', (SELECT COUNT(*) FROM {{ this }}), CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'"
) }}

-- Silver layer transformation for Billing Events table
-- Applies data quality checks and standardization

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
    WHERE EVENT_ID IS NOT NULL  -- Remove null event IDs
),

data_quality_checks AS (
    SELECT 
        *,
        -- Row number for deduplication
        ROW_NUMBER() OVER (PARTITION BY EVENT_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_billing_events
),

cleansed_billing_events AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        TRIM(UPPER(EVENT_TYPE)) AS EVENT_TYPE,
        AMOUNT,
        EVENT_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Additional Silver layer metadata
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        -- Data quality score calculation
        CASE 
            WHEN EVENT_TYPE IS NOT NULL 
                 AND AMOUNT IS NOT NULL 
                 AND AMOUNT > 0 
                 AND EVENT_DATE IS NOT NULL 
                 AND EVENT_DATE <= CURRENT_DATE() THEN 100
            WHEN EVENT_TYPE IS NOT NULL 
                 AND AMOUNT IS NOT NULL 
                 AND EVENT_DATE IS NOT NULL THEN 75
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        CASE 
            WHEN EVENT_TYPE IS NOT NULL 
                 AND AMOUNT IS NOT NULL 
                 AND AMOUNT > 0 
                 AND EVENT_DATE IS NOT NULL 
                 AND EVENT_DATE <= CURRENT_DATE() THEN 'PASSED'
            WHEN EVENT_TYPE IS NOT NULL 
                 AND AMOUNT IS NOT NULL 
                 AND EVENT_DATE IS NOT NULL THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS,
        CURRENT_TIMESTAMP() AS CREATED_AT,
        CURRENT_TIMESTAMP() AS UPDATED_AT
    FROM data_quality_checks
    WHERE rn = 1  -- Keep only the latest record for each event
      AND EVENT_TYPE IS NOT NULL
      AND AMOUNT IS NOT NULL
      AND AMOUNT > 0  -- Positive amounts only
      AND EVENT_DATE IS NOT NULL
      AND EVENT_DATE <= CURRENT_DATE()  -- No future dates
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
    VALIDATION_STATUS,
    CREATED_AT,
    UPDATED_AT
FROM cleansed_billing_events
