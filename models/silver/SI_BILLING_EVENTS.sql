{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_BILLING_EVENTS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'RUNNING', 'BZ_BILLING_EVENTS', 'SI_BILLING_EVENTS', 'DBT_PIPELINE', CURRENT_TIMESTAMP() WHERE EXISTS (SELECT 1 FROM {{ ref('SI_Audit_Log') }} LIMIT 1)",
    post_hook="UPDATE {{ ref('SI_Audit_Log') }} SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(), EXECUTION_STATUS = 'SUCCESS', EXECUTION_DURATION_SECONDS = DATEDIFF('second', EXECUTION_START_TIME, CURRENT_TIMESTAMP()) WHERE PIPELINE_NAME = 'BRONZE_TO_SILVER_BILLING_EVENTS' AND EXECUTION_STATUS = 'RUNNING' AND EXISTS (SELECT 1 FROM {{ ref('SI_Audit_Log') }} WHERE PIPELINE_NAME = 'BRONZE_TO_SILVER_BILLING_EVENTS')"
) }}

-- Silver layer transformation for Billing Events table
-- Applies data quality checks and amount validation

WITH source_data AS (
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
        -- Data quality validations
        CASE WHEN EVENT_ID IS NULL THEN 0 ELSE 25 END +
        CASE WHEN USER_ID IS NULL THEN 0 ELSE 25 END +
        CASE WHEN EVENT_TYPE IS NULL OR LENGTH(TRIM(EVENT_TYPE)) = 0 THEN 0 ELSE 25 END +
        CASE WHEN AMOUNT IS NULL OR AMOUNT <= 0 THEN 0 ELSE 25 END AS data_quality_score,
        
        -- Validation status
        CASE 
            WHEN EVENT_ID IS NULL OR USER_ID IS NULL THEN 'FAILED'
            WHEN EVENT_TYPE IS NULL OR LENGTH(TRIM(EVENT_TYPE)) = 0 THEN 'FAILED'
            WHEN AMOUNT IS NULL OR AMOUNT <= 0 THEN 'FAILED'
            WHEN EVENT_DATE > CURRENT_DATE() THEN 'WARNING'
            ELSE 'PASSED'
        END AS validation_status
    FROM source_data
),

deduplication AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY EVENT_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS row_num
    FROM data_quality_checks
    WHERE validation_status != 'FAILED'  -- Exclude failed records
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
        -- Additional Silver layer metadata
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        data_quality_score AS DATA_QUALITY_SCORE,
        validation_status AS VALIDATION_STATUS
    FROM deduplication
    WHERE row_num = 1  -- Keep only the latest record per EVENT_ID
)

SELECT * FROM final_transformation
