{{
  config(
    materialized='incremental',
    unique_key='feature_usage_id',
    on_schema_change='sync_all_columns',
    incremental_strategy='merge'
  )
}}

-- Silver Feature Usage Table Transformation
-- Transforms bronze feature usage data with categorization and validation

WITH bronze_feature_usage AS (
    SELECT 
        meeting_id,
        feature_name,
        usage_count,
        usage_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('bronze', 'bz_feature_usage') }}
    WHERE meeting_id IS NOT NULL 
      AND feature_name IS NOT NULL
      AND usage_count >= 0
      AND usage_date IS NOT NULL
),

deduped_feature_usage AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY meeting_id, feature_name, usage_date 
            ORDER BY update_timestamp DESC, load_timestamp DESC
        ) AS row_num
    FROM bronze_feature_usage
),

transformed_feature_usage AS (
    SELECT 
        -- Primary Key Generation
        {{ dbt_utils.generate_surrogate_key(['meeting_id', 'feature_name', 'usage_date']) }} AS feature_usage_id,
        
        -- Direct Mappings
        meeting_id,
        TRIM(feature_name) AS feature_name,
        usage_count,
        usage_date,
        
        -- Derived Attributes
        COALESCE(usage_count * 5, 0) AS usage_duration_minutes,  -- Estimated duration
        
        CASE 
            WHEN UPPER(feature_name) LIKE '%AUDIO%' OR UPPER(feature_name) LIKE '%MIC%' THEN 'Audio'
            WHEN UPPER(feature_name) LIKE '%VIDEO%' OR UPPER(feature_name) LIKE '%CAM%' THEN 'Video'
            WHEN UPPER(feature_name) LIKE '%SCREEN%' OR UPPER(feature_name) LIKE '%SHARE%' THEN 'Screen Share'
            WHEN UPPER(feature_name) LIKE '%CHAT%' OR UPPER(feature_name) LIKE '%MESSAGE%' THEN 'Chat'
            WHEN UPPER(feature_name) LIKE '%RECORD%' THEN 'Recording'
            ELSE 'Other'
        END AS feature_category,
        
        CASE 
            WHEN usage_count <= 5 THEN 'Low'
            WHEN usage_count <= 20 THEN 'Medium'
            ELSE 'High'
        END AS usage_pattern,
        
        -- Audit Fields
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        source_system,
        load_timestamp,
        update_timestamp,
        
        -- Data Quality Score Calculation
        ROUND(
            (CASE WHEN meeting_id IS NOT NULL THEN 0.25 ELSE 0 END +
             CASE WHEN feature_name IS NOT NULL AND LENGTH(TRIM(feature_name)) > 0 THEN 0.25 ELSE 0 END +
             CASE WHEN usage_count >= 0 THEN 0.25 ELSE 0 END +
             CASE WHEN usage_date IS NOT NULL THEN 0.25 ELSE 0 END), 2
        ) AS data_quality_score
        
    FROM deduped_feature_usage
    WHERE row_num = 1
)

SELECT * FROM transformed_feature_usage

{% if is_incremental() %}
  WHERE update_timestamp > (SELECT COALESCE(MAX(update_timestamp), '1900-01-01') FROM {{ this }})
{% endif %}
