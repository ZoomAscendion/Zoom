{{ config(
    materialized='table',
    on_schema_change='sync_all_columns',
    pre_hook="
        INSERT INTO {{ ref('si_pipeline_audit') }} (
            execution_id, pipeline_name, start_time, status, 
            source_tables_processed, executed_by, execution_environment,
            load_date, update_date, source_system
        )
        VALUES (
            '{{ invocation_id }}_si_feature_usage', 
            'si_feature_usage', 
            CURRENT_TIMESTAMP(), 
            'STARTED',
            'BZ_FEATURE_USAGE',
            '{{ var(\"audit_user\") }}',
            'PRODUCTION',
            CURRENT_DATE(),
            CURRENT_DATE(),
            'DBT_SILVER_PIPELINE'
        )
    ",
    post_hook="
        UPDATE {{ ref('si_pipeline_audit') }}
        SET 
            end_time = CURRENT_TIMESTAMP(),
            status = 'SUCCESS',
            execution_duration_seconds = DATEDIFF('second', start_time, CURRENT_TIMESTAMP()),
            target_tables_updated = 'SI_FEATURE_USAGE',
            records_processed = (SELECT COUNT(*) FROM {{ this }}),
            records_inserted = (SELECT COUNT(*) FROM {{ this }}),
            records_updated = 0,
            records_rejected = 0,
            update_date = CURRENT_DATE()
        WHERE execution_id = '{{ invocation_id }}_si_feature_usage'
    "
) }}

-- Silver layer transformation for Feature Usage
WITH bronze_feature_usage AS (
    SELECT *
    FROM {{ source('bronze', 'bz_feature_usage') }}
),

-- Data Quality Checks and Cleansing
cleansed_feature_usage AS (
    SELECT 
        usage_id,
        meeting_id,
        TRIM(UPPER(feature_name)) AS feature_name_clean,
        usage_count,
        usage_date,
        load_timestamp,
        update_timestamp,
        source_system,
        
        -- Data Quality Validations
        CASE 
            WHEN usage_id IS NULL THEN 0
            WHEN meeting_id IS NULL THEN 0
            WHEN feature_name IS NULL OR TRIM(feature_name) = '' THEN 0
            WHEN usage_count IS NULL OR usage_count < 0 THEN 0
            WHEN usage_date IS NULL THEN 0
            ELSE 1
        END AS usage_valid,
        
        -- Corrected usage_count
        CASE 
            WHEN usage_count IS NULL OR usage_count < 0 THEN 0
            ELSE usage_count
        END AS usage_count_corrected
        
    FROM bronze_feature_usage
),

-- Remove duplicates
deduped_usage AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY usage_id 
            ORDER BY update_timestamp DESC, load_timestamp DESC
        ) AS rn
    FROM cleansed_feature_usage
    WHERE usage_valid = 1
),

-- Final transformation with derived fields
final_usage AS (
    SELECT 
        usage_id,
        meeting_id,
        feature_name_clean AS feature_name,
        usage_count_corrected AS usage_count,
        
        -- Derive usage duration from count (simplified logic)
        CASE 
            WHEN usage_count_corrected > 0 
            THEN usage_count_corrected * 2
            ELSE 0
        END AS usage_duration,
        
        -- Categorize features
        CASE 
            WHEN feature_name_clean LIKE '%AUDIO%' OR feature_name_clean LIKE '%MICROPHONE%' OR feature_name_clean LIKE '%SOUND%' THEN 'Audio'
            WHEN feature_name_clean LIKE '%VIDEO%' OR feature_name_clean LIKE '%CAMERA%' OR feature_name_clean LIKE '%SCREEN%' THEN 'Video'
            WHEN feature_name_clean LIKE '%CHAT%' OR feature_name_clean LIKE '%SHARE%' OR feature_name_clean LIKE '%WHITEBOARD%' THEN 'Collaboration'
            WHEN feature_name_clean LIKE '%SECURITY%' OR feature_name_clean LIKE '%PASSWORD%' OR feature_name_clean LIKE '%LOCK%' THEN 'Security'
            ELSE 'Other'
        END AS feature_category,
        
        usage_date,
        
        -- Metadata columns
        load_timestamp,
        update_timestamp,
        source_system,
        
        -- Data quality score
        CASE 
            WHEN feature_name_clean IS NOT NULL 
                AND usage_count_corrected >= 0 
                AND usage_date IS NOT NULL
            THEN 1.00
            ELSE 0.75
        END AS data_quality_score,
        
        DATE(load_timestamp) AS load_date,
        DATE(update_timestamp) AS update_date
        
    FROM deduped_usage
    WHERE rn = 1
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
FROM final_usage
