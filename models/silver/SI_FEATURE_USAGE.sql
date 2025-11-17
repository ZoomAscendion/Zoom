{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_FEATURE_USAGE', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'RUNNING', 'BZ_FEATURE_USAGE', 'SI_FEATURE_USAGE', 'DBT_PIPELINE', CURRENT_TIMESTAMP()",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_END_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, RECORDS_PROCESSED, RECORDS_SUCCESS, EXECUTED_BY, UPDATE_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_FEATURE_USAGE', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'SUCCESS', 'BZ_FEATURE_USAGE', 'SI_FEATURE_USAGE', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 'DBT_PIPELINE', CURRENT_TIMESTAMP()"
) }}

-- Silver Layer Feature Usage Table
-- Transforms and cleanses feature usage data from Bronze layer
-- Applies data quality validations and business rules

WITH bronze_feature_usage AS (
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

-- Data Quality and Validation Layer
validated_feature_usage AS (
    SELECT 
        *,
        -- Null checks
        CASE WHEN USAGE_ID IS NULL THEN 0 ELSE 1 END AS usage_id_valid,
        CASE WHEN MEETING_ID IS NULL THEN 0 ELSE 1 END AS meeting_id_valid,
        CASE WHEN FEATURE_NAME IS NULL THEN 0 ELSE 1 END AS feature_name_valid,
        CASE WHEN USAGE_COUNT IS NULL THEN 0 ELSE 1 END AS usage_count_valid,
        CASE WHEN USAGE_DATE IS NULL THEN 0 ELSE 1 END AS usage_date_valid,
        
        -- Business logic validation
        CASE WHEN USAGE_COUNT >= 0 THEN 1 ELSE 0 END AS usage_count_range_valid,
        CASE WHEN LENGTH(FEATURE_NAME) <= 100 THEN 1 ELSE 0 END AS feature_name_length_valid,
        
        -- Calculate data quality score
        ROUND((
            CASE WHEN USAGE_ID IS NULL THEN 0 ELSE 20 END +
            CASE WHEN MEETING_ID IS NULL THEN 0 ELSE 20 END +
            CASE WHEN FEATURE_NAME IS NULL THEN 0 ELSE 20 END +
            CASE WHEN USAGE_COUNT IS NULL THEN 0 ELSE 15 END +
            CASE WHEN USAGE_DATE IS NULL THEN 0 ELSE 15 END +
            CASE WHEN USAGE_COUNT >= 0 THEN 5 ELSE 0 END +
            CASE WHEN LENGTH(FEATURE_NAME) <= 100 THEN 5 ELSE 0 END
        ), 0) AS data_quality_score
    FROM bronze_feature_usage
),

-- Deduplication layer using ROW_NUMBER to keep latest record
deduped_feature_usage AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY USAGE_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS row_num
    FROM validated_feature_usage
    WHERE USAGE_ID IS NOT NULL  -- Remove null usage IDs
),

-- Final transformation layer
final_feature_usage AS (
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
        CASE 
            WHEN data_quality_score >= 90 THEN 'PASSED'
            WHEN data_quality_score >= 70 THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM deduped_feature_usage
    WHERE row_num = 1  -- Keep only the latest record per usage
    AND data_quality_score >= 70  -- Only pass records with acceptable quality
    AND USAGE_COUNT >= 0  -- Ensure non-negative usage counts
)

SELECT * FROM final_feature_usage
