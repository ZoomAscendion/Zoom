{{ config(
    materialized='incremental',
    unique_key='participant_id',
    on_schema_change='fail',
    tags=['bronze', 'participants'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), '{{ this.name }}', 0.0, 'STARTED')",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), '{{ this.name }}', DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_PARTICIPANTS' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS')"
) }}

/*
    Bronze Layer Participants Model
    Purpose: Raw meeting participant data from source systems with metadata enrichment
    Author: AAVA
    Created: {{ run_started_at }}
*/

WITH source_data AS (
    SELECT
        participant_id,
        meeting_id,
        user_id,
        join_time,
        leave_time,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw', 'participants') }}
    
    {% if is_incremental() %}
        WHERE update_timestamp > (SELECT COALESCE(MAX(update_timestamp), '1900-01-01') FROM {{ this }})
    {% endif %}
),

deduped_data AS (
    SELECT
        participant_id,
        meeting_id,
        user_id,
        join_time,
        leave_time,
        COALESCE(load_timestamp, CURRENT_TIMESTAMP()) AS load_timestamp,
        COALESCE(update_timestamp, CURRENT_TIMESTAMP()) AS update_timestamp,
        COALESCE(source_system, 'UNKNOWN') AS source_system,
        ROW_NUMBER() OVER (
            PARTITION BY participant_id 
            ORDER BY update_timestamp DESC, load_timestamp DESC
        ) AS row_num
    FROM source_data
    WHERE participant_id IS NOT NULL  -- Primary key validation
),

data_quality_checks AS (
    SELECT
        participant_id,
        meeting_id,
        user_id,
        join_time,
        leave_time,
        load_timestamp,
        update_timestamp,
        source_system,
        -- Data quality validations
        CASE 
            WHEN join_time IS NOT NULL AND leave_time IS NOT NULL AND join_time > leave_time 
            THEN 'INVALID_TIME_RANGE'
            WHEN meeting_id IS NULL OR user_id IS NULL 
            THEN 'MISSING_REQUIRED_FIELDS'
            ELSE 'VALID'
        END AS data_quality_flag
    FROM deduped_data
    WHERE row_num = 1
),

final AS (
    SELECT
        participant_id,
        meeting_id,
        user_id,
        join_time,
        leave_time,
        load_timestamp,
        update_timestamp,
        source_system
    FROM data_quality_checks
    WHERE data_quality_flag = 'VALID'  -- Only include valid records
)

SELECT
    participant_id,
    meeting_id,
    user_id,
    join_time,
    leave_time,
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
        {{ log("BZ_PARTICIPANTS: Processing " ~ results.columns[0].values()[0] ~ " rows", info=True) }}
    {% endif %}
{% endif %}