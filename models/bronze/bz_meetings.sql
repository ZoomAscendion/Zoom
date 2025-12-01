-- Bronze Layer Meetings Model
-- Description: Meeting information and session details

{{ config(
    materialized='table',
    tags=['bronze', 'meetings']
) }}

-- Check if source table exists
{% set source_exists = adapter.get_relation(
    database=var('source_database'),
    schema=var('source_schema'),
    identifier='meetings'
) %}

{% if source_exists %}
    -- Use real source data if available
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
            source_system,
            ROW_NUMBER() OVER (PARTITION BY meeting_id ORDER BY COALESCE(update_timestamp, load_timestamp) DESC) AS row_num
        FROM {{ source('raw', 'meetings') }}
        WHERE meeting_id IS NOT NULL
    )
    
    SELECT 
        meeting_id,
        host_id,
        meeting_topic,
        start_time,
        end_time,
        CASE 
            WHEN start_time IS NOT NULL AND end_time IS NOT NULL AND start_time < end_time THEN
                COALESCE(duration_minutes, DATEDIFF('minutes', start_time, end_time))
            ELSE duration_minutes
        END AS duration_minutes,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        COALESCE(source_system, 'UNKNOWN') AS source_system
    FROM source_data
    WHERE row_num = 1
        AND (start_time IS NULL OR end_time IS NULL OR start_time <= end_time)
    
{% else %}
    -- Generate sample data for testing
    SELECT 
        'MEET_001' AS meeting_id,
        'USER_001' AS host_id,
        'Weekly Team Standup' AS meeting_topic,
        '2024-01-15 09:00:00'::TIMESTAMP AS start_time,
        '2024-01-15 09:30:00'::TIMESTAMP AS end_time,
        30 AS duration_minutes,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' AS source_system
    
    UNION ALL
    
    SELECT 
        'MEET_002' AS meeting_id,
        'USER_002' AS host_id,
        'Product Review' AS meeting_topic,
        '2024-01-15 14:00:00'::TIMESTAMP AS start_time,
        '2024-01-15 15:00:00'::TIMESTAMP AS end_time,
        60 AS duration_minutes,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' AS source_system
    
    UNION ALL
    
    SELECT 
        'MEET_003' AS meeting_id,
        'USER_003' AS host_id,
        'Client Presentation' AS meeting_topic,
        '2024-01-16 10:00:00'::TIMESTAMP AS start_time,
        '2024-01-16 11:30:00'::TIMESTAMP AS end_time,
        90 AS duration_minutes,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' AS source_system
{% endif %}
