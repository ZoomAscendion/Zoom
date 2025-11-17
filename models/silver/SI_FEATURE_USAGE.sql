{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_FEATURE_USAGE', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'RUNNING', 'BZ_FEATURE_USAGE', 'SI_FEATURE_USAGE', 'DBT_PIPELINE', CURRENT_TIMESTAMP() WHERE EXISTS (SELECT 1 FROM {{ ref('SI_Audit_Log') }} LIMIT 1)",
    post_hook="UPDATE {{ ref('SI_Audit_Log') }} SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(), EXECUTION_STATUS = 'SUCCESS', EXECUTION_DURATION_SECONDS = DATEDIFF('second', EXECUTION_START_TIME, CURRENT_TIMESTAMP()) WHERE PIPELINE_NAME = 'BRONZE_TO_SILVER_FEATURE_USAGE' AND EXECUTION_STATUS = 'RUNNING' AND EXISTS (SELECT 1 FROM {{ ref('SI_Audit_Log') }} WHERE PIPELINE_NAME = 'BRONZE_TO_SILVER_FEATURE_USAGE')"
) }}

-- Silver layer transformation for Feature Usage table
-- Applies data quality checks and standardization

WITH source_data AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('bronze', 'BZ_FEATURE_USAGE') }}
),

data_quality_checks AS (
    SELECT 
        *,
        -- Data quality validations
        CASE WHEN USAGE_ID IS NULL THEN 0 ELSE 25 END +
        CASE WHEN MEETING_ID IS NULL THEN 0 ELSE 25 END +
        CASE WHEN FEATURE_NAME IS NULL OR LENGTH(TRIM(FEATURE_NAME)) = 0 THEN 0 ELSE 25 END +
        CASE WHEN USAGE_COUNT IS NULL OR USAGE_COUNT < 0 THEN 0 ELSE 25 END AS data_quality_score,
        
        -- Validation status
        CASE 
            WHEN USAGE_ID IS NULL OR MEETING_ID IS NULL OR FEATURE_NAME IS NULL THEN 'FAILED'
            WHEN USAGE_COUNT IS NULL OR USAGE_COUNT < 0 THEN 'FAILED'
            WHEN LENGTH(TRIM(FEATURE_NAME)) = 0 THEN 'WARNING'
            ELSE 'PASSED'
        END AS validation_status
    FROM source_data
),

deduplication AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY USAGE_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS row_num
    FROM data_quality_checks
    WHERE validation_status != 'FAILED'  -- Exclude failed records
),

final_transformation AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        UPPER(TRIM(FEATURE_NAME)) AS FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Additional Silver layer metadata
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        data_quality_score AS DATA_QUALITY_SCORE,
        validation_status AS VALIDATION_STATUS
    FROM deduplication
    WHERE row_num = 1  -- Keep only the latest record per USAGE_ID
)

SELECT * FROM final_transformation
