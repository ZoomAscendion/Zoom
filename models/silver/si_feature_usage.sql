{{ config(
    materialized='incremental',
    unique_key='usage_id',
    on_schema_change='sync_all_columns',
    pre_hook="
        INSERT INTO {{ this.database }}.{{ this.schema }}.si_pipeline_audit (
            execution_id, pipeline_name, start_time, status, executed_by, execution_environment, source_system,
            source_tables_processed, target_tables_updated, load_date, update_date
        ) 
        SELECT 
            LEFT('{{ invocation_id }}_feature', 500) as execution_id,
            'si_feature_usage_pipeline' as pipeline_name,
            CURRENT_TIMESTAMP() as start_time,
            'RUNNING' as status,
            CURRENT_USER() as executed_by,
            'PROD' as execution_environment,
            'DBT_SILVER_PIPELINE' as source_system,
            'BZ_FEATURE_USAGE' as source_tables_processed,
            'SI_FEATURE_USAGE' as target_tables_updated,
            CURRENT_DATE() as load_date,
            CURRENT_DATE() as update_date
    ",
    post_hook="
        UPDATE {{ this.database }}.{{ this.schema }}.si_pipeline_audit 
        SET 
            end_time = CURRENT_TIMESTAMP(),
            status = 'SUCCESS',
            records_processed = (SELECT COUNT(*) FROM {{ this }}),
            execution_duration_seconds = DATEDIFF('second', start_time, CURRENT_TIMESTAMP())
        WHERE execution_id = LEFT('{{ invocation_id }}_feature', 500)
    "
) }}

-- Silver layer transformation for feature usage with comprehensive data quality checks
WITH bronze_feature_usage AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Add row number for deduplication
        ROW_NUMBER() OVER (
            PARTITION BY USAGE_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) as rn
    FROM {{ source('bronze', 'bz_feature_usage') }}
    WHERE USAGE_ID IS NOT NULL 
    AND TRIM(USAGE_ID) != ''
    AND MEETING_ID IS NOT NULL
    AND FEATURE_NAME IS NOT NULL
    
    {% if is_incremental() %}
        AND UPDATE_TIMESTAMP > (SELECT MAX(update_timestamp) FROM {{ this }})
    {% endif %}
),

-- Data quality validation and cleansing
cleansed_feature_usage AS (
    SELECT 
        TRIM(USAGE_ID) as usage_id,
        TRIM(MEETING_ID) as meeting_id,
        TRIM(FEATURE_NAME) as feature_name,
        GREATEST(USAGE_COUNT, 0) as usage_count,
        GREATEST(USAGE_COUNT * 5, 0) as usage_duration,  -- Estimated duration
        CASE 
            WHEN UPPER(FEATURE_NAME) LIKE '%AUDIO%' OR UPPER(FEATURE_NAME) LIKE '%MIC%' THEN 'Audio'
            WHEN UPPER(FEATURE_NAME) LIKE '%VIDEO%' OR UPPER(FEATURE_NAME) LIKE '%CAMERA%' THEN 'Video'
            WHEN UPPER(FEATURE_NAME) LIKE '%SHARE%' OR UPPER(FEATURE_NAME) LIKE '%CHAT%' THEN 'Collaboration'
            WHEN UPPER(FEATURE_NAME) LIKE '%SECURITY%' OR UPPER(FEATURE_NAME) LIKE '%PASSWORD%' THEN 'Security'
            ELSE 'Collaboration'
        END as feature_category,
        USAGE_DATE as usage_date,
        LOAD_TIMESTAMP as load_timestamp,
        UPDATE_TIMESTAMP as update_timestamp,
        SOURCE_SYSTEM as source_system,
        -- Calculate data quality score with proper decimal precision
        CAST((
            CASE WHEN USAGE_ID IS NOT NULL AND TRIM(USAGE_ID) != '' THEN 0.25 ELSE 0 END +
            CASE WHEN MEETING_ID IS NOT NULL AND TRIM(MEETING_ID) != '' THEN 0.25 ELSE 0 END +
            CASE WHEN FEATURE_NAME IS NOT NULL AND TRIM(FEATURE_NAME) != '' THEN 0.25 ELSE 0 END +
            CASE WHEN USAGE_COUNT >= 0 THEN 0.25 ELSE 0 END
        ) AS NUMBER(3,2)) as data_quality_score,
        CURRENT_DATE() as load_date,
        CURRENT_DATE() as update_date
    FROM bronze_feature_usage
    WHERE rn = 1
    AND USAGE_COUNT >= 0
    AND USAGE_DATE <= CURRENT_DATE()
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
FROM cleansed_feature_usage
WHERE data_quality_score >= 0.75  -- Only accept high quality records
