{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (execution_id, pipeline_name, start_time, status, source_tables_processed, target_tables_updated, executed_by, execution_environment, load_date, update_date, source_system) SELECT 'EXEC_SI_FEATURE_USAGE_' || TO_VARCHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), 'SI_FEATURE_USAGE_TRANSFORMATION', CURRENT_TIMESTAMP(), 'STARTED', 'BZ_FEATURE_USAGE', 'SI_FEATURE_USAGE', 'DBT_PIPELINE', 'PRODUCTION', CURRENT_DATE(), CURRENT_DATE(), 'DBT_PIPELINE' WHERE NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = CURRENT_SCHEMA() AND TABLE_NAME = 'SI_PIPELINE_AUDIT')",
    post_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (execution_id, pipeline_name, end_time, status, records_processed, records_inserted, executed_by, execution_environment, load_date, update_date, source_system) SELECT 'EXEC_SI_FEATURE_USAGE_' || TO_VARCHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), 'SI_FEATURE_USAGE_TRANSFORMATION', CURRENT_TIMESTAMP(), 'COMPLETED', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 'DBT_PIPELINE', 'PRODUCTION', CURRENT_DATE(), CURRENT_DATE(), 'DBT_PIPELINE' WHERE NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = CURRENT_SCHEMA() AND TABLE_NAME = 'SI_PIPELINE_AUDIT')"
) }}

-- Silver Feature Usage Model
-- Transforms bronze feature usage data with categorization and validation

WITH bronze_feature_usage AS (
    SELECT * FROM {{ source('bronze', 'bz_feature_usage') }}
),

silver_meetings AS (
    SELECT * FROM {{ ref('si_meetings') }}
),

-- Data Quality Validation
data_quality_checks AS (
    SELECT 
        *,
        -- Usage count validation
        CASE 
            WHEN usage_count < 0 THEN 'NEGATIVE_USAGE_COUNT'
            WHEN usage_count > 10000 THEN 'EXCESSIVE_USAGE_COUNT'
            ELSE 'VALID'
        END AS usage_count_quality_flag,
        
        -- Feature name validation
        CASE 
            WHEN feature_name IS NULL OR TRIM(feature_name) = '' THEN 'MISSING_FEATURE_NAME'
            ELSE 'VALID'
        END AS feature_name_quality_flag
    FROM bronze_feature_usage
    WHERE usage_id IS NOT NULL
      AND meeting_id IS NOT NULL
),

-- Data Cleansing and Categorization
cleansed_feature_usage AS (
    SELECT 
        f.usage_id,
        f.meeting_id,
        
        -- Standardized feature name
        TRIM(UPPER(f.feature_name)) AS feature_name,
        
        -- Corrected usage count
        CASE 
            WHEN f.usage_count_quality_flag = 'NEGATIVE_USAGE_COUNT' THEN 0
            WHEN f.usage_count_quality_flag = 'EXCESSIVE_USAGE_COUNT' THEN 1000
            ELSE f.usage_count
        END AS usage_count,
        
        -- Derived usage duration
        CASE 
            WHEN f.usage_count > 0 AND m.duration_minutes IS NOT NULL
            THEN LEAST(f.usage_count * 2, m.duration_minutes)  -- Estimate 2 minutes per usage
            ELSE 0
        END AS usage_duration,
        
        -- Feature categorization
        CASE 
            WHEN UPPER(f.feature_name) LIKE '%AUDIO%' OR UPPER(f.feature_name) LIKE '%MICROPHONE%' OR UPPER(f.feature_name) LIKE '%SOUND%' THEN 'Audio'
            WHEN UPPER(f.feature_name) LIKE '%VIDEO%' OR UPPER(f.feature_name) LIKE '%CAMERA%' OR UPPER(f.feature_name) LIKE '%SCREEN%' THEN 'Video'
            WHEN UPPER(f.feature_name) LIKE '%CHAT%' OR UPPER(f.feature_name) LIKE '%SHARE%' OR UPPER(f.feature_name) LIKE '%WHITEBOARD%' THEN 'Collaboration'
            WHEN UPPER(f.feature_name) LIKE '%SECURITY%' OR UPPER(f.feature_name) LIKE '%PASSWORD%' OR UPPER(f.feature_name) LIKE '%LOCK%' THEN 'Security'
            ELSE 'Other'
        END AS feature_category,
        
        f.usage_date,
        
        -- Silver layer metadata
        f.load_timestamp,
        f.update_timestamp,
        f.source_system,
        
        -- Data quality score
        ROUND(
            (CASE WHEN f.usage_count_quality_flag = 'VALID' THEN 0.4 ELSE 0.0 END +
             CASE WHEN f.feature_name_quality_flag = 'VALID' THEN 0.3 ELSE 0.0 END +
             CASE WHEN m.meeting_id IS NOT NULL THEN 0.2 ELSE 0.0 END +
             CASE WHEN f.usage_date IS NOT NULL THEN 0.1 ELSE 0.0 END), 2
        ) AS data_quality_score,
        
        -- Standard metadata
        DATE(f.load_timestamp) AS load_date,
        DATE(f.update_timestamp) AS update_date
        
    FROM data_quality_checks f
    LEFT JOIN silver_meetings m ON f.meeting_id = m.meeting_id
    WHERE f.feature_name_quality_flag != 'MISSING_FEATURE_NAME'
      AND m.meeting_id IS NOT NULL  -- Block orphaned feature usage records
),

-- Deduplication
deduped_feature_usage AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY usage_id ORDER BY update_timestamp DESC) AS rn
    FROM cleansed_feature_usage
)

SELECT 
    usage_id,
    meeting_id,
    feature_name,
    usage_count,
    usage_duration,
    feature_category,
    usage_date,
    load_timestamp,
    update_timestamp,
    source_system,
    data_quality_score,
    load_date,
    update_date
FROM deduped_feature_usage
WHERE rn = 1
