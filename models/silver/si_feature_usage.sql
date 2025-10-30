{{ config(
    materialized='incremental',
    unique_key='usage_id',
    on_schema_change='sync_all_columns'
) }}

-- Silver layer transformation for Feature Usage data
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
    
    {% if is_incremental() %}
    WHERE UPDATE_TIMESTAMP > (SELECT MAX(UPDATE_TIMESTAMP) FROM {{ this }})
    {% endif %}
),

cleansed_feature_usage AS (
    SELECT 
        TRIM(USAGE_ID) AS usage_id,
        TRIM(MEETING_ID) AS meeting_id,
        TRIM(FEATURE_NAME) AS feature_name,
        COALESCE(USAGE_COUNT, 0) AS usage_count,
        COALESCE(USAGE_COUNT * 5, 0) AS usage_duration,  -- Estimated 5 minutes per usage
        CASE 
            WHEN UPPER(FEATURE_NAME) LIKE '%AUDIO%' OR UPPER(FEATURE_NAME) LIKE '%MIC%' THEN 'Audio'
            WHEN UPPER(FEATURE_NAME) LIKE '%VIDEO%' OR UPPER(FEATURE_NAME) LIKE '%CAMERA%' THEN 'Video'
            WHEN UPPER(FEATURE_NAME) LIKE '%CHAT%' OR UPPER(FEATURE_NAME) LIKE '%SHARE%' THEN 'Collaboration'
            WHEN UPPER(FEATURE_NAME) LIKE '%SECURITY%' OR UPPER(FEATURE_NAME) LIKE '%PASSWORD%' THEN 'Security'
            ELSE 'Other'
        END AS feature_category,
        USAGE_DATE AS usage_date,
        LOAD_TIMESTAMP AS load_timestamp,
        UPDATE_TIMESTAMP AS update_timestamp,
        SOURCE_SYSTEM AS source_system,
        CASE 
            WHEN USAGE_ID IS NOT NULL AND MEETING_ID IS NOT NULL AND FEATURE_NAME IS NOT NULL AND USAGE_COUNT >= 0
            THEN 1.00
            ELSE 0.50
        END AS data_quality_score,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date
    FROM bronze_feature_usage
    WHERE USAGE_ID IS NOT NULL
        AND USAGE_COUNT >= 0
),

deduped_feature_usage AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY usage_id 
            ORDER BY update_timestamp DESC
        ) AS row_num
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
WHERE row_num = 1
