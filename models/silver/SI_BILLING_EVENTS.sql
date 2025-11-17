{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_BILLING_EVENTS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'RUNNING', 'BZ_BILLING_EVENTS', 'SI_BILLING_EVENTS', 'DBT_PIPELINE', CURRENT_TIMESTAMP()",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_END_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, RECORDS_PROCESSED, RECORDS_SUCCESS, EXECUTED_BY, UPDATE_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_BILLING_EVENTS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'SUCCESS', 'BZ_BILLING_EVENTS', 'SI_BILLING_EVENTS', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 'DBT_PIPELINE', CURRENT_TIMESTAMP()"
) }}

-- Silver Layer Billing Events Table
-- Transforms and cleanses billing event data from Bronze layer
-- Applies data quality validations and business rules

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

-- Data Quality and Validation Layer
validated_billing_events AS (
    SELECT 
        *,
        -- Null checks
        CASE WHEN EVENT_ID IS NULL THEN 0 ELSE 1 END AS event_id_valid,
        CASE WHEN USER_ID IS NULL THEN 0 ELSE 1 END AS user_id_valid,
        CASE WHEN EVENT_TYPE IS NULL THEN 0 ELSE 1 END AS event_type_valid,
        CASE WHEN AMOUNT IS NULL THEN 0 ELSE 1 END AS amount_valid,
        CASE WHEN EVENT_DATE IS NULL THEN 0 ELSE 1 END AS event_date_valid,
        
        -- Business logic validation
        CASE WHEN AMOUNT > 0 THEN 1 ELSE 0 END AS amount_positive_valid,
        CASE WHEN EVENT_DATE <= CURRENT_DATE() THEN 1 ELSE 0 END AS event_date_logic_valid,
        CASE WHEN LENGTH(EVENT_TYPE) <= 100 THEN 1 ELSE 0 END AS event_type_length_valid,
        
        -- Calculate data quality score
        ROUND((
            CASE WHEN EVENT_ID IS NULL THEN 0 ELSE 20 END +
            CASE WHEN USER_ID IS NULL THEN 0 ELSE 20 END +
            CASE WHEN EVENT_TYPE IS NULL THEN 0 ELSE 15 END +
            CASE WHEN AMOUNT IS NULL THEN 0 ELSE 15 END +
            CASE WHEN EVENT_DATE IS NULL THEN 0 ELSE 15 END +
            CASE WHEN AMOUNT > 0 THEN 10 ELSE 0 END +
            CASE WHEN EVENT_DATE <= CURRENT_DATE() THEN 5 ELSE 0 END
        ), 0) AS data_quality_score
    FROM bronze_billing_events
),

-- Deduplication layer using ROW_NUMBER to keep latest record
deduped_billing_events AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY EVENT_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS row_num
    FROM validated_billing_events
    WHERE EVENT_ID IS NOT NULL  -- Remove null event IDs
),

-- Final transformation layer
final_billing_events AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        UPPER(TRIM(EVENT_TYPE)) AS EVENT_TYPE,
        ROUND(AMOUNT, 2) AS AMOUNT,
        EVENT_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Additional Silver layer metadata
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        data_quality_score AS DATA_QUALITY_SCORE,
        CASE 
            WHEN data_quality_score >= 90 THEN 'PASSED'
            WHEN data_quality_score >= 70 THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM deduped_billing_events
    WHERE row_num = 1  -- Keep only the latest record per event
    AND data_quality_score >= 70  -- Only pass records with acceptable quality
    AND AMOUNT > 0  -- Ensure positive amounts
    AND EVENT_DATE <= CURRENT_DATE()  -- Ensure valid event dates
)

SELECT * FROM final_billing_events
