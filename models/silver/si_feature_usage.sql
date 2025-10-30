{{
  config(
    materialized='incremental',
    unique_key='usage_id',
    on_schema_change='sync_all_columns'
  )
}}

WITH bronze_feature_usage AS (
    SELECT *
    FROM {{ source('bronze', 'bz_feature_usage') }}
    WHERE USAGE_ID IS NOT NULL
        AND MEETING_ID IS NOT NULL
        AND FEATURE_NAME IS NOT NULL
        AND USAGE_COUNT >= 0
    {% if is_incremental() %}
        AND UPDATE_TIMESTAMP > (SELECT MAX(UPDATE_TIMESTAMP) FROM {{ this }})
    {% endif %}
),

cleaned_feature_usage AS (
    SELECT 
        USAGE_ID AS usage_id,
        MEETING_ID AS meeting_id,
        TRIM(FEATURE_NAME) AS feature_name,
        USAGE_COUNT AS usage_count,
        COALESCE(USAGE_COUNT * 2, 0) AS usage_duration,
        CASE 
            WHEN UPPER(FEATURE_NAME) LIKE '%AUDIO%' OR UPPER(FEATURE_NAME) LIKE '%MICROPHONE%' THEN 'AUDIO'
            WHEN UPPER(FEATURE_NAME) LIKE '%VIDEO%' OR UPPER(FEATURE_NAME) LIKE '%CAMERA%' THEN 'VIDEO'
            WHEN UPPER(FEATURE_NAME) LIKE '%CHAT%' OR UPPER(FEATURE_NAME) LIKE '%SCREEN%' OR UPPER(FEATURE_NAME) LIKE '%SHARE%' THEN 'COLLABORATION'
            WHEN UPPER(FEATURE_NAME) LIKE '%SECURITY%' OR UPPER(FEATURE_NAME) LIKE '%PASSWORD%' THEN 'SECURITY'
            ELSE 'OTHER'
        END AS feature_category,
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        0.88 AS data_quality_score,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date
    FROM bronze_feature_usage
),

deduped_feature_usage AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY usage_id ORDER BY update_timestamp DESC) AS rn
    FROM cleaned_feature_usage
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
