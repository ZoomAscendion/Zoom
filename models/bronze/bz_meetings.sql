-- Bronze Layer Meetings Table
-- Description: Stores meeting information and session details
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='meeting_id',
    pre_hook="
        {% if this.name != 'bz_data_audit' %}
        INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status)
        VALUES ('BZ_MEETINGS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 0.0, 'STARTED');
        {% endif %}
    ",
    post_hook="
        {% if this.name != 'bz_data_audit' %}
        INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status)
        VALUES ('BZ_MEETINGS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 0.0, 'COMPLETED');
        {% endif %}
    "
) }}

-- Filter out NULL primary keys before any processing
WITH source_data AS (
    SELECT *
    FROM {{ source('raw_zoom', 'meetings') }}
    WHERE meeting_id IS NOT NULL
),

-- Apply deduplication based on primary key and latest update timestamp
deduped_data AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY meeting_id 
               ORDER BY update_timestamp DESC, load_timestamp DESC
           ) as row_num
    FROM source_data
)

-- Final selection with 1-1 mapping and data type conversions
SELECT 
    meeting_id,
    host_id,
    meeting_topic,
    start_time,
    TRY_CAST(end_time AS TIMESTAMP_NTZ) as end_time,
    TRY_CAST(duration_minutes AS NUMBER(38,0)) as duration_minutes,
    load_timestamp,
    update_timestamp,
    source_system
FROM deduped_data
WHERE row_num = 1
