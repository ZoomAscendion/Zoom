{{ config(
    materialized='table'
) }}

WITH bronze_feature_usage AS (
    SELECT *
    FROM {{ source('bronze', 'bz_feature_usage') }}
),

data_quality_checks AS (
    SELECT 
        *,
        -- Usage count validation
        CASE 
            WHEN usage_count >= 0 THEN 1
            ELSE 0
        END AS usage_quality,
        
        -- Feature name validation
        CASE 
            WHEN feature_name IS NOT NULL AND TRIM(feature_name) != '' THEN 1
            ELSE 0
        END AS feature_quality,
        
        -- Date validation
        CASE 
            WHEN usage_date IS NOT NULL AND usage_date <= CURRENT_DATE() THEN 1
            ELSE 0
        END AS date_quality,
        
        -- Completeness check
        CASE 
            WHEN usage_id IS NOT NULL AND meeting_id IS NOT NULL THEN 1
            ELSE 0
        END AS completeness_quality
    FROM bronze_feature_usage
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER(
            PARTITION BY usage_id 
            ORDER BY load_timestamp DESC, update_timestamp DESC
        ) AS rn
    FROM data_quality_checks
),

final_transformation AS (
    SELECT 
        usage_id,
        meeting_id,
        TRIM(feature_name) AS feature_name,
        CASE 
            WHEN usage_count < 0 THEN 0
            ELSE usage_count
        END AS usage_count,
        CASE 
            WHEN usage_count < 0 THEN 0
            ELSE usage_count * 2
        END AS usage_duration,
        CASE 
            WHEN LOWER(feature_name) LIKE '%audio%' OR LOWER(feature_name) LIKE '%mic%' THEN 'Audio'
            WHEN LOWER(feature_name) LIKE '%video%' OR LOWER(feature_name) LIKE '%camera%' THEN 'Video'
            WHEN LOWER(feature_name) LIKE '%share%' OR LOWER(feature_name) LIKE '%chat%' THEN 'Collaboration'
            WHEN LOWER(feature_name) LIKE '%security%' OR LOWER(feature_name) LIKE '%password%' THEN 'Security'
            ELSE 'Other'
        END AS feature_category,
        usage_date,
        load_timestamp,
        update_timestamp,
        source_system,
        -- Calculate data quality score
        ROUND(
            (usage_quality + feature_quality + date_quality + completeness_quality) / 4.0, 2
        ) AS data_quality_score,
        DATE(load_timestamp) AS load_date,
        DATE(update_timestamp) AS update_date
    FROM deduplication
    WHERE rn = 1
      AND usage_id IS NOT NULL
      AND meeting_id IS NOT NULL
      AND feature_name IS NOT NULL
      AND usage_count >= 0
)

SELECT * FROM final_transformation
