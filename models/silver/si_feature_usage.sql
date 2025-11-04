{{ config(
    materialized='table',
    on_schema_change='sync_all_columns',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, EXECUTED_BY, EXECUTION_ENVIRONMENT, SOURCE_SYSTEM, LOAD_DATE, UPDATE_DATE) SELECT 'FEAT_' || REPLACE(REPLACE(REPLACE(CURRENT_TIMESTAMP()::STRING, ' ', '_'), ':', ''), '.', '_'), 'Silver_Feature_Usage_ETL', CURRENT_TIMESTAMP(), 'STARTED', 'DBT_SILVER_JOB', 'PRODUCTION', 'ZOOM_PLATFORM', CURRENT_DATE(), CURRENT_DATE()",
    post_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, END_TIME, STATUS, EXECUTION_DURATION_SECONDS, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, RECORDS_PROCESSED, RECORDS_INSERTED, RECORDS_UPDATED, RECORDS_REJECTED, EXECUTED_BY, EXECUTION_ENVIRONMENT, DATA_LINEAGE_INFO, SOURCE_SYSTEM, LOAD_DATE, UPDATE_DATE) SELECT 'FEAT_' || REPLACE(REPLACE(REPLACE(CURRENT_TIMESTAMP()::STRING, ' ', '_'), ':', ''), '.', '_'), 'Silver_Feature_Usage_ETL', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 'COMPLETED', 0, 'BZ_FEATURE_USAGE', 'SI_FEATURE_USAGE', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 0, 0, 'DBT_SILVER_JOB', 'PRODUCTION', 'Bronze to Silver Feature Usage transformation', 'ZOOM_PLATFORM', CURRENT_DATE(), CURRENT_DATE()"
) }}

-- Silver Feature Usage Table
-- Transforms Bronze feature usage data with standardizations and categorizations

WITH bronze_feature_usage AS (
    SELECT *
    FROM {{ source('bronze', 'bz_feature_usage') }}
),

-- Data Quality Validations
validated_feature_usage AS (
    SELECT
        fu.*,
        -- Data Quality Flags
        CASE 
            WHEN fu.USAGE_ID IS NULL THEN 'CRITICAL_NO_USAGE_ID'
            WHEN fu.MEETING_ID IS NULL THEN 'CRITICAL_NO_MEETING_ID'
            WHEN fu.FEATURE_NAME IS NULL THEN 'CRITICAL_NO_FEATURE_NAME'
            WHEN fu.USAGE_COUNT < 0 THEN 'CRITICAL_NEGATIVE_USAGE_COUNT'
            WHEN fu.USAGE_DATE > CURRENT_DATE() + INTERVAL '1 DAY' THEN 'WARNING_FUTURE_DATE'
            ELSE 'VALID'
        END AS data_quality_flag,
        
        -- Row Number for Deduplication
        ROW_NUMBER() OVER (PARTITION BY fu.USAGE_ID ORDER BY fu.UPDATE_TIMESTAMP DESC, fu.LOAD_TIMESTAMP DESC) AS rn
    FROM bronze_feature_usage fu
    WHERE fu.USAGE_ID IS NOT NULL  -- Block records without USAGE_ID
      AND fu.MEETING_ID IS NOT NULL -- Block records without MEETING_ID
      AND fu.FEATURE_NAME IS NOT NULL -- Block records without FEATURE_NAME
      AND COALESCE(fu.USAGE_COUNT, 0) >= 0 -- Block negative usage counts
),

-- Apply Transformations
transformed_feature_usage AS (
    SELECT
        -- Primary Keys
        vfu.USAGE_ID,
        vfu.MEETING_ID,
        
        -- Standardized Business Columns
        TRIM(UPPER(vfu.FEATURE_NAME)) AS FEATURE_NAME,
        GREATEST(COALESCE(vfu.USAGE_COUNT, 0), 0) AS USAGE_COUNT,
        
        -- Derived Columns
        CASE 
            WHEN vfu.USAGE_COUNT > 0 THEN vfu.USAGE_COUNT * 2 -- Estimate duration based on usage count
            ELSE 0
        END AS USAGE_DURATION,
        
        CASE 
            WHEN UPPER(vfu.FEATURE_NAME) LIKE '%AUDIO%' OR UPPER(vfu.FEATURE_NAME) LIKE '%MICROPHONE%' OR UPPER(vfu.FEATURE_NAME) LIKE '%SOUND%' THEN 'Audio'
            WHEN UPPER(vfu.FEATURE_NAME) LIKE '%VIDEO%' OR UPPER(vfu.FEATURE_NAME) LIKE '%CAMERA%' OR UPPER(vfu.FEATURE_NAME) LIKE '%SCREEN%' THEN 'Video'
            WHEN UPPER(vfu.FEATURE_NAME) LIKE '%CHAT%' OR UPPER(vfu.FEATURE_NAME) LIKE '%SHARE%' OR UPPER(vfu.FEATURE_NAME) LIKE '%WHITEBOARD%' THEN 'Collaboration'
            WHEN UPPER(vfu.FEATURE_NAME) LIKE '%SECURITY%' OR UPPER(vfu.FEATURE_NAME) LIKE '%PASSWORD%' OR UPPER(vfu.FEATURE_NAME) LIKE '%LOCK%' THEN 'Security'
            ELSE 'General'
        END AS FEATURE_CATEGORY,
        
        vfu.USAGE_DATE,
        
        -- Metadata Columns
        vfu.LOAD_TIMESTAMP,
        vfu.UPDATE_TIMESTAMP,
        vfu.SOURCE_SYSTEM,
        
        -- Data Quality Score
        CASE 
            WHEN vfu.data_quality_flag = 'VALID' THEN 1.00
            WHEN vfu.data_quality_flag LIKE 'WARNING%' THEN 0.80
            ELSE 0.60
        END AS DATA_QUALITY_SCORE,
        
        -- Standard Metadata
        DATE(vfu.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(vfu.UPDATE_TIMESTAMP) AS UPDATE_DATE
        
    FROM validated_feature_usage vfu
    WHERE vfu.rn = 1  -- Keep only the latest record for each USAGE_ID
      AND vfu.data_quality_flag NOT LIKE 'CRITICAL%'
)

SELECT
    USAGE_ID,
    MEETING_ID,
    FEATURE_NAME,
    USAGE_COUNT,
    USAGE_DURATION,
    FEATURE_CATEGORY,
    USAGE_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATA_QUALITY_SCORE,
    LOAD_DATE,
    UPDATE_DATE
FROM transformed_feature_usage
