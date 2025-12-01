{{ config(
    materialized='incremental',
    unique_key='meeting_id',
    on_schema_change='fail',
    tags=['bronze', 'meetings'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_MEETINGS', CURRENT_TIMESTAMP(), '{{ this.name }}', 0.0, 'STARTED')",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_MEETINGS', CURRENT_TIMESTAMP(), '{{ this.name }}', DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_MEETINGS' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS')"
) }}

/*
    Bronze Layer Meetings Model
    Purpose: Raw meeting data from source systems with metadata enrichment
    Author: AAVA
    Created: {{ run_started_at }}
    
    Potential PII Fields: MEETING_TOPIC
*/

WITH source_data AS (
    SELECT
        meeting_id,
        host_id,
        meeting_topic,
        start_time,
        end_time,
        duration_minutes,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw', 'meetings') }}
    
    {% if is_incremental() %}
        WHERE update_timestamp > (SELECT COALESCE(MAX(update_timestamp), '1900-01-01') FROM {{ this }})
    {% endif %}
),

deduped_data AS (
    SELECT
        meeting_id,
        host_id,
        meeting_topic,
        start_time,
        end_time,
        duration_minutes,
        COALESCE(load_timestamp, CURRENT_TIMESTAMP()) AS load_timestamp,
        COALESCE(update_timestamp, CURRENT_TIMESTAMP()) AS update_timestamp,
        COALESCE(source_system, 'UNKNOWN') AS source_system,
        ROW_NUMBER() OVER (
            PARTITION BY meeting_id 
            ORDER BY update_timestamp DESC, load_timestamp DESC
        ) AS row_num
    FROM source_data
    WHERE meeting_id IS NOT NULL  -- Primary key validation
),

data_quality_checks AS (
    SELECT
        meeting_id,
        host_id,
        meeting_topic,
        start_time,
        end_time,
        duration_minutes,
        load_timestamp,
        update_timestamp,
        source_system,
        -- Data quality validations
        CASE 
            WHEN start_time IS NOT NULL AND end_time IS NOT NULL AND start_time > end_time 
            THEN 'INVALID_TIME_RANGE'
            WHEN duration_minutes IS NOT NULL AND duration_minutes < 0 
            THEN 'INVALID_DURATION'
            ELSE 'VALID'
        END AS data_quality_flag
    FROM deduped_data
    WHERE row_num = 1
),

final AS (
    SELECT
        meeting_id,
        host_id,
        meeting_topic,
        start_time,
        end_time,
        duration_minutes,
        load_timestamp,
        update_timestamp,
        source_system
    FROM data_quality_checks
    WHERE data_quality_flag = 'VALID'  -- Only include valid records
)

SELECT
    meeting_id,
    host_id,
    meeting_topic,
    start_time,
    end_time,
    duration_minutes,
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
        {{ log("BZ_MEETINGS: Processing " ~ results.columns[0].values()[0] ~ " rows", info=True) }}
    {% endif %}
{% endif %}