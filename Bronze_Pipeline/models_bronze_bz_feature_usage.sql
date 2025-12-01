{{ config(
    materialized='incremental',
    unique_key='usage_id',
    on_schema_change='fail',
    tags=['bronze', 'feature_usage'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), '{{ this.name }}', 0.0, 'STARTED')",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), '{{ this.name }}', DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_FEATURE_USAGE' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS')"
) }}

/*
    Bronze Layer Feature Usage Model
    Purpose: Raw feature usage data from source systems with metadata enrichment
    Author: AAVA
    Created: {{ run_started_at }}
*/

WITH source_data AS (
    SELECT
        usage_id,
        meeting_id,
        feature_name,
        usage_count,
        usage_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw', 'feature_usage') }}
    
    {% if is_incremental() %}
        WHERE update_timestamp > (SELECT COALESCE(MAX(update_timestamp), '1900-01-01') FROM {{ this }})
    {% endif %}
),

deduped_data AS (
    SELECT
        usage_id,
        meeting_id,
        feature_name,
        usage_count,
        usage_date,
        COALESCE(load_timestamp, CURRENT_TIMESTAMP()) AS load_timestamp,
        COALESCE(update_timestamp, CURRENT_TIMESTAMP()) AS update_timestamp,
        COALESCE(source_system, 'UNKNOWN') AS source_system,
        ROW_NUMBER() OVER (
            PARTITION BY usage_id 
            ORDER BY update_timestamp DESC, load_timestamp DESC
        ) AS row_num
    FROM source_data
    WHERE usage_id IS NOT NULL  -- Primary key validation
),

data_quality_checks AS (
    SELECT
        usage_id,
        meeting_id,
        feature_name,
        usage_count,
        usage_date,
        load_timestamp,
        update_timestamp,
        source_system,
        -- Data quality validations
        CASE 
            WHEN usage_count IS NOT NULL AND usage_count < 0 
            THEN 'INVALID_USAGE_COUNT'
            WHEN meeting_id IS NULL OR feature_name IS NULL 
            THEN 'MISSING_REQUIRED_FIELDS'
            WHEN usage_date IS NOT NULL AND usage_date > CURRENT_DATE() 
            THEN 'FUTURE_DATE'
            ELSE 'VALID'
        END AS data_quality_flag
    FROM deduped_data
    WHERE row_num = 1
),

final AS (
    SELECT
        usage_id,
        meeting_id,
        feature_name,
        usage_count,
        usage_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM data_quality_checks
    WHERE data_quality_flag = 'VALID'  -- Only include valid records
)

SELECT
    usage_id,
    meeting_id,
    feature_name,
    usage_count,
    usage_date,
    load_timestamp,
    update_timestamp,
    source_system
FROM final

-- Data quality logging
{% if execute %}
    {% set row_count_query %}
        SELECT COUNT(*) as row_count FROM ({{ sql }})
    {% endset %}
    
    {% set results = run_query(row_count_query) %}
    {% if results %}
        {{ log("BZ_FEATURE_USAGE: Processing " ~ results.columns[0].values()[0] ~ " rows", info=True) }}
    {% endif %}
{% endif %}