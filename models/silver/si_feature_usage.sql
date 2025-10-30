{{ config(
    materialized='incremental',
    unique_key='usage_id',
    on_schema_change='sync_all_columns'
) }}

-- Silver layer transformation for feature usage with data quality checks
WITH bronze_feature_usage AS (
    SELECT 
        usage_id,
        meeting_id,
        feature_name,
        usage_count,
        usage_date,
        load_timestamp,
        update_timestamp,
        source_system,
        ROW_NUMBER() OVER (PARTITION BY usage_id ORDER BY update_timestamp DESC, load_timestamp DESC) as rn
    FROM {{ source('bronze', 'bz_feature_usage') }}
    WHERE usage_id IS NOT NULL 
    AND TRIM(usage_id) != ''
    AND meeting_id IS NOT NULL
    AND feature_name IS NOT NULL
    AND usage_count >= 0
    {% if is_incremental() %}
        AND (update_timestamp > (SELECT COALESCE(MAX(update_timestamp), '1900-01-01') FROM {{ this }})
             OR load_timestamp > (SELECT COALESCE(MAX(load_timestamp), '1900-01-01') FROM {{ this }}))
    {% endif %}
),

deduped_feature_usage AS (
    SELECT 
        usage_id,
        meeting_id,
        feature_name,
        usage_count,
        usage_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM bronze_feature_usage
    WHERE rn = 1
),

validated_feature_usage AS (
    SELECT 
        f.usage_id,
        f.meeting_id,
        TRIM(f.feature_name) AS feature_name,
        f.usage_count,
        COALESCE(f.usage_count * 5, 0) AS usage_duration,
        CASE 
            WHEN LOWER(f.feature_name) LIKE '%audio%' OR LOWER(f.feature_name) LIKE '%microphone%' THEN 'Audio'
            WHEN LOWER(f.feature_name) LIKE '%video%' OR LOWER(f.feature_name) LIKE '%camera%' THEN 'Video'
            WHEN LOWER(f.feature_name) LIKE '%chat%' OR LOWER(f.feature_name) LIKE '%screen%' OR LOWER(f.feature_name) LIKE '%share%' THEN 'Collaboration'
            WHEN LOWER(f.feature_name) LIKE '%security%' OR LOWER(f.feature_name) LIKE '%password%' THEN 'Security'
            ELSE 'Other'
        END AS feature_category,
        f.usage_date,
        f.load_timestamp,
        f.update_timestamp,
        f.source_system
    FROM deduped_feature_usage f
    INNER JOIN {{ ref('si_meetings') }} m ON f.meeting_id = m.meeting_id
),

final_feature_usage AS (
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
        -- Calculate data quality score
        CAST(ROUND(
            (CASE WHEN usage_id IS NOT NULL THEN 0.25 ELSE 0 END +
             CASE WHEN meeting_id IS NOT NULL THEN 0.25 ELSE 0 END +
             CASE WHEN feature_name IS NOT NULL THEN 0.25 ELSE 0 END +
             CASE WHEN usage_count >= 0 THEN 0.25 ELSE 0 END), 2
        ) AS NUMBER(3,2)) AS data_quality_score,
        DATE(load_timestamp) AS load_date,
        DATE(update_timestamp) AS update_date
    FROM validated_feature_usage
)

SELECT * FROM final_feature_usage
