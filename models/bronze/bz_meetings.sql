-- Bronze Layer Meetings Table
-- Description: Stores meeting information and session details
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'meetings'],
    pre_hook="
        {% if this.name != 'bz_data_audit' %}
            INSERT INTO {{ ref('bz_data_audit') }} (record_id, source_table, load_timestamp, processed_by, processing_time, status)
            SELECT 
                (SELECT COALESCE(MAX(record_id), 0) + 1 FROM {{ ref('bz_data_audit') }}),
                'BZ_MEETINGS',
                CURRENT_TIMESTAMP(),
                'DBT_BRONZE_PIPELINE',
                0,
                'STARTED'
        {% endif %}
    ",
    post_hook="
        {% if this.name != 'bz_data_audit' %}
            INSERT INTO {{ ref('bz_data_audit') }} (record_id, source_table, load_timestamp, processed_by, processing_time, status)
            SELECT 
                (SELECT COALESCE(MAX(record_id), 0) + 1 FROM {{ ref('bz_data_audit') }}),
                'BZ_MEETINGS',
                CURRENT_TIMESTAMP(),
                'DBT_BRONZE_PIPELINE',
                DATEDIFF('seconds', 
                    (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_MEETINGS' AND status = 'STARTED'),
                    CURRENT_TIMESTAMP()
                ),
                'SUCCESS'
        {% endif %}
    "
) }}

-- Raw data selection with null filtering for primary key
WITH raw_meetings AS (
    SELECT *
    FROM {{ source('raw', 'meetings') }}
    WHERE meeting_id IS NOT NULL  -- Filter out records with null primary key
),

-- Deduplication logic based on primary key and latest timestamp
deduped_meetings AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY meeting_id 
            ORDER BY update_timestamp DESC, load_timestamp DESC
        ) AS row_num
    FROM raw_meetings
),

-- Final transformation with data type conversions and bronze timestamp overwrite
final_meetings AS (
    SELECT 
        meeting_id,
        host_id,
        meeting_topic,
        start_time,
        TRY_CAST(end_time AS TIMESTAMP_NTZ(9)) AS end_time,  -- Convert VARCHAR to TIMESTAMP
        TRY_CAST(duration_minutes AS NUMBER(38,0)) AS duration_minutes,  -- Convert VARCHAR to NUMBER
        CURRENT_TIMESTAMP() AS load_timestamp,  -- Overwrite with current DBT run timestamp
        CURRENT_TIMESTAMP() AS update_timestamp,  -- Overwrite with current DBT run timestamp
        source_system
    FROM deduped_meetings
    WHERE row_num = 1
)

SELECT * FROM final_meetings
