-- Bronze Layer Meetings Table
-- Description: Stores meeting information and session details
-- Author: DBT Pipeline Generator
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='meeting_id',
    pre_hook="
        {% if this.name != 'bz_data_audit' %}
        INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status)
        SELECT 'BZ_MEETINGS', CURRENT_TIMESTAMP(), 'DBT_PIPELINE', 0, 'STARTED'
        {% endif %}
    ",
    post_hook="
        {% if this.name != 'bz_data_audit' %}
        INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status)
        SELECT 'BZ_MEETINGS', CURRENT_TIMESTAMP(), 'DBT_PIPELINE', DATEDIFF('second', 
            (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_MEETINGS' AND status = 'STARTED'), 
            CURRENT_TIMESTAMP()), 'SUCCESS'
        {% endif %}
    "
) }}

WITH source_data AS (
    -- Select from raw meetings table with null filtering for primary key
    SELECT 
        meeting_id,
        host_id,
        meeting_topic,
        start_time,
        TRY_CAST(end_time AS TIMESTAMP_NTZ(9)) AS end_time,
        TRY_CAST(duration_minutes AS NUMBER(38,0)) AS duration_minutes,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw_layer', 'meetings') }}
    WHERE meeting_id IS NOT NULL  -- Filter out null primary keys
),

deduped_data AS (
    -- Apply deduplication based on primary key and latest update timestamp
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY meeting_id 
                   ORDER BY update_timestamp DESC, load_timestamp DESC
               ) as rn
        FROM source_data
    )
    WHERE rn = 1
)

-- Final select with 1-1 mapping from raw to bronze
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
FROM deduped_data
