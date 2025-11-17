{{ config(
    materialized='table',
    on_schema_change='sync_all_columns',
    pre_hook="
        INSERT INTO {{ ref('SI_AUDIT_LOG') }} (EXECUTION_ID, PIPELINE_NAME, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP)
        VALUES (UUID_STRING(), 'SI_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'STARTED', 'BRONZE.BZ_BILLING_EVENTS', '{{ this.schema }}.SI_BILLING_EVENTS', 'DBT_PIPELINE', CURRENT_TIMESTAMP())
    ",
    post_hook="
        UPDATE {{ ref('SI_AUDIT_LOG') }} 
        SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(), 
            EXECUTION_STATUS = 'SUCCESS',
            RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}),
            UPDATE_TIMESTAMP = CURRENT_TIMESTAMP()
        WHERE TARGET_TABLE = '{{ this.schema }}.SI_BILLING_EVENTS' 
        AND EXECUTION_STATUS = 'STARTED'
        AND EXECUTION_START_TIME >= CURRENT_TIMESTAMP() - INTERVAL '1 HOUR'
    "
) }}

-- Silver Layer Billing Events Table
-- Purpose: Clean and standardized financial transactions and billing activities
-- Transformation: Bronze to Silver with data quality validations

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

data_quality_checks AS (
    SELECT 
        *,
        -- Data Quality Score Calculation
        CASE 
            WHEN EVENT_ID IS NOT NULL THEN 25 ELSE 0 END +
            CASE WHEN USER_ID IS NOT NULL THEN 25 ELSE 0 END +
            CASE WHEN EVENT_TYPE IS NOT NULL AND LENGTH(TRIM(EVENT_TYPE)) > 0 THEN 20 ELSE 0 END +
            CASE WHEN AMOUNT IS NOT NULL AND AMOUNT > 0 THEN 20 ELSE 0 END +
            CASE WHEN EVENT_DATE IS NOT NULL AND EVENT_DATE <= CURRENT_DATE() THEN 10 ELSE 0 END
        AS DATA_QUALITY_SCORE,
        
        -- Validation Status
        CASE 
            WHEN EVENT_ID IS NULL OR USER_ID IS NULL THEN 'FAILED'
            WHEN EVENT_TYPE IS NULL OR LENGTH(TRIM(EVENT_TYPE)) = 0 THEN 'FAILED'
            WHEN AMOUNT IS NULL OR AMOUNT <= 0 THEN 'FAILED'
            WHEN EVENT_DATE IS NULL OR EVENT_DATE > CURRENT_DATE() THEN 'FAILED'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM bronze_billing_events
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY EVENT_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) as rn
    FROM data_quality_checks
),

final_transformation AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        UPPER(TRIM(EVENT_TYPE)) AS EVENT_TYPE,
        ROUND(AMOUNT, 2) AS AMOUNT,
        EVENT_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Additional Silver layer metadata columns
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        DATA_QUALITY_SCORE,
        VALIDATION_STATUS
    FROM deduplication
    WHERE rn = 1
    AND VALIDATION_STATUS IN ('PASSED', 'WARNING') -- Exclude FAILED records
)

SELECT * FROM final_transformation
