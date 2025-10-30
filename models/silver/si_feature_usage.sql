{{
    config(
        materialized='incremental',
        unique_key='usage_id',
        on_schema_change='sync_all_columns'
    )
}}

-- Silver Layer Feature Usage Transformation
-- Source: Bronze.BZ_FEATURE_USAGE
-- Target: Silver.SI_FEATURE_USAGE

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
    FROM {{ source('bronze', 'bz_feature_usage') }}
    WHERE USAGE_ID IS NOT NULL
    
    {% if is_incremental() %}
        AND UPDATE_TIMESTAMP > (SELECT MAX(update_timestamp) FROM {{ this }})
    {% endif %}
),

-- Data Quality and Transformation Layer
data_quality_checks AS (
    SELECT 
        *,
        -- Data Quality Score Calculation
        CASE 
            WHEN USAGE_ID IS NULL THEN 0.0
            WHEN MEETING_ID IS NULL OR FEATURE_NAME IS NULL THEN 0.3
            WHEN USAGE_COUNT < 0 THEN 0.4
            WHEN USAGE_DATE IS NULL OR USAGE_DATE > CURRENT_DATE() THEN 0.5
            ELSE 1.0
        END AS data_quality_score,
        
        -- Row Number for Deduplication
        ROW_NUMBER() OVER (PARTITION BY USAGE_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_feature_usage
),

-- Final Transformation
transformed_feature_usage AS (
    SELECT 
        TRIM(USAGE_ID) AS usage_id,
        TRIM(MEETING_ID) AS meeting_id,
        TRIM(UPPER(FEATURE_NAME)) AS feature_name,
        GREATEST(0, COALESCE(USAGE_COUNT, 0)) AS usage_count,
        COALESCE(USAGE_COUNT * 5, 0) AS usage_duration,  -- Estimated 5 minutes per usage
        CASE 
            WHEN UPPER(FEATURE_NAME) LIKE '%AUDIO%' OR UPPER(FEATURE_NAME) LIKE '%MIC%' OR UPPER(FEATURE_NAME) LIKE '%SOUND%' THEN 'Audio'
            WHEN UPPER(FEATURE_NAME) LIKE '%VIDEO%' OR UPPER(FEATURE_NAME) LIKE '%CAMERA%' OR UPPER(FEATURE_NAME) LIKE '%SCREEN%' THEN 'Video'
            WHEN UPPER(FEATURE_NAME) LIKE '%CHAT%' OR UPPER(FEATURE_NAME) LIKE '%SHARE%' OR UPPER(FEATURE_NAME) LIKE '%WHITEBOARD%' THEN 'Collaboration'
            WHEN UPPER(FEATURE_NAME) LIKE '%SECURITY%' OR UPPER(FEATURE_NAME) LIKE '%PASSWORD%' OR UPPER(FEATURE_NAME) LIKE '%LOCK%' THEN 'Security'
            ELSE 'Other'
        END AS feature_category,
        USAGE_DATE AS usage_date,
        LOAD_TIMESTAMP AS load_timestamp,
        UPDATE_TIMESTAMP AS update_timestamp,
        SOURCE_SYSTEM AS source_system,
        data_quality_score,
        DATE(LOAD_TIMESTAMP) AS load_date,
        DATE(UPDATE_TIMESTAMP) AS update_date
    FROM data_quality_checks
    WHERE rn = 1  -- Remove duplicates
        AND data_quality_score > 0.0  -- Remove records with critical quality issues
        AND USAGE_COUNT >= 0
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
FROM transformed_feature_usage
