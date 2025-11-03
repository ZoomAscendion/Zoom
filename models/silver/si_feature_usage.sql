{{ config(
    materialized='table'
) }}

-- Pre-hook: Log process start
{% if this.name != 'audit_log' %}
{{ log("Starting transformation for si_feature_usage", info=True) }}
{% endif %}

WITH source_data AS (
    SELECT 
        f.USAGE_ID,
        f.MEETING_ID,
        f.FEATURE_NAME,
        f.USAGE_COUNT,
        f.USAGE_DATE,
        f.LOAD_TIMESTAMP,
        f.UPDATE_TIMESTAMP,
        f.SOURCE_SYSTEM
    FROM {{ ref('bz_feature_usage') }} f
    WHERE f.USAGE_ID IS NOT NULL
),

data_quality_checks AS (
    SELECT 
        s.*,
        
        -- Usage count validation
        CASE 
            WHEN s.USAGE_COUNT >= 0 THEN 1
            ELSE 0
        END AS usage_count_valid,
        
        -- Feature name validation
        CASE 
            WHEN s.FEATURE_NAME IS NOT NULL AND TRIM(s.FEATURE_NAME) != '' THEN 1
            ELSE 0
        END AS feature_name_valid,
        
        -- Date validation
        CASE 
            WHEN s.USAGE_DATE IS NOT NULL AND s.USAGE_DATE <= CURRENT_DATE() THEN 1
            ELSE 0
        END AS date_valid
    FROM source_data s
),

cleaned_data AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        
        -- Standardize feature name
        CASE 
            WHEN feature_name_valid = 1 
            THEN TRIM(UPPER(FEATURE_NAME))
            ELSE 'UNKNOWN_FEATURE'
        END AS FEATURE_NAME,
        
        -- Validate usage count
        CASE 
            WHEN usage_count_valid = 1 THEN USAGE_COUNT
            ELSE 0
        END AS USAGE_COUNT,
        
        -- Derive usage duration from count (simplified logic)
        CASE 
            WHEN usage_count_valid = 1 AND USAGE_COUNT > 0
            THEN USAGE_COUNT * 2  -- Assume 2 minutes per usage
            ELSE 0
        END AS USAGE_DURATION,
        
        -- Categorize features
        CASE 
            WHEN UPPER(FEATURE_NAME) LIKE '%AUDIO%' OR UPPER(FEATURE_NAME) LIKE '%MIC%' 
                 OR UPPER(FEATURE_NAME) LIKE '%SOUND%' THEN 'Audio'
            WHEN UPPER(FEATURE_NAME) LIKE '%VIDEO%' OR UPPER(FEATURE_NAME) LIKE '%CAM%' 
                 OR UPPER(FEATURE_NAME) LIKE '%SCREEN%' THEN 'Video'
            WHEN UPPER(FEATURE_NAME) LIKE '%CHAT%' OR UPPER(FEATURE_NAME) LIKE '%SHARE%' 
                 OR UPPER(FEATURE_NAME) LIKE '%WHITEBOARD%' THEN 'Collaboration'
            WHEN UPPER(FEATURE_NAME) LIKE '%SECURITY%' OR UPPER(FEATURE_NAME) LIKE '%LOCK%' 
                 OR UPPER(FEATURE_NAME) LIKE '%PASSWORD%' THEN 'Security'
            ELSE 'General'
        END AS FEATURE_CATEGORY,
        
        -- Validate usage date
        CASE 
            WHEN date_valid = 1 THEN USAGE_DATE
            ELSE CURRENT_DATE()
        END AS USAGE_DATE,
        
        -- Calculate data quality score
        ROUND((usage_count_valid + feature_name_valid + date_valid) / 3.0, 2) AS DATA_QUALITY_SCORE,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at
        
    FROM data_quality_checks
    WHERE USAGE_ID IS NOT NULL  -- Remove records with null primary key
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY USAGE_ID 
            ORDER BY UPDATE_TIMESTAMP DESC
        ) AS row_num
    FROM cleaned_data
    QUALIFY row_num = 1
)

-- Final SELECT
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
    UPDATE_DATE,
    created_at,
    updated_at
FROM deduplication

-- Post-hook: Log process completion
{% if this.name != 'audit_log' %}
{{ log("Completed transformation for si_feature_usage", info=True) }}
{% endif %}
