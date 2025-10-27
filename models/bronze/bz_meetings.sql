-- Bronze Meetings Model
-- Transforms raw meetings data to bronze layer with data quality checks
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    pre_hook="""
        {% if this.name != 'bz_audit_log' %}
            INSERT INTO {{ ref('bz_audit_log') }} (source_table, load_timestamp, processed_by, processing_time, status)
            SELECT 
                '{{ this.name }}' as source_table,
                CURRENT_TIMESTAMP() as load_timestamp,
                CURRENT_USER() as processed_by,
                0 as processing_time,
                'STARTED' as status
        {% endif %}
    """,
    post_hook="""
        {% if this.name != 'bz_audit_log' %}
            INSERT INTO {{ ref('bz_audit_log') }} (source_table, load_timestamp, processed_by, processing_time, status)
            SELECT 
                '{{ this.name }}' as source_table,
                CURRENT_TIMESTAMP() as load_timestamp,
                CURRENT_USER() as processed_by,
                DATEDIFF('seconds', 
                    (SELECT MAX(load_timestamp) FROM {{ ref('bz_audit_log') }} WHERE source_table = '{{ this.name }}' AND status = 'STARTED'),
                    CURRENT_TIMESTAMP()
                ) as processing_time,
                'COMPLETED' as status
        {% endif %}
    """
) }}

-- Data quality and transformation layer
WITH source_data AS (
    SELECT 
        HOST_ID,
        MEETING_TOPIC,
        START_TIME,
        END_TIME,
        DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw_zoom', 'MEETINGS') }}
    WHERE HOST_ID IS NOT NULL
      AND MEETING_TOPIC IS NOT NULL
      AND START_TIME IS NOT NULL
      AND END_TIME IS NOT NULL
      AND DURATION_MINUTES IS NOT NULL
),

-- Data cleansing and standardization
cleansed_data AS (
    SELECT 
        TRIM(UPPER(HOST_ID)) as host_id,
        TRIM(MEETING_TOPIC) as meeting_topic,
        START_TIME as start_time,
        END_TIME as end_time,
        DURATION_MINUTES as duration_minutes,
        LOAD_TIMESTAMP as load_timestamp,
        COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) as update_timestamp,
        TRIM(UPPER(COALESCE(SOURCE_SYSTEM, 'UNKNOWN'))) as source_system
    FROM source_data
    WHERE START_TIME <= END_TIME
      AND DURATION_MINUTES >= 0
)

-- Final selection with audit information
SELECT 
    host_id,
    meeting_topic,
    start_time,
    end_time,
    duration_minutes,
    load_timestamp,
    update_timestamp,
    source_system
FROM cleansed_data
