-- Bronze Layer Participants Model
-- Description: Meeting participants and their session details

{{ config(
    materialized='table',
    tags=['bronze', 'participants']
) }}

-- Check if source table exists
{% set source_exists = adapter.get_relation(
    database=var('source_database'),
    schema=var('source_schema'),
    identifier='participants'
) %}

{% if source_exists %}
    -- Use real source data if available
    WITH source_data AS (
        SELECT 
            participant_id,
            meeting_id,
            user_id,
            join_time,
            leave_time,
            load_timestamp,
            update_timestamp,
            source_system,
            ROW_NUMBER() OVER (PARTITION BY participant_id ORDER BY COALESCE(update_timestamp, load_timestamp) DESC) AS row_num
        FROM {{ source('raw', 'participants') }}
        WHERE participant_id IS NOT NULL
            AND meeting_id IS NOT NULL
            AND user_id IS NOT NULL
    )
    
    SELECT 
        participant_id,
        meeting_id,
        user_id,
        join_time,
        leave_time,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        COALESCE(source_system, 'UNKNOWN') AS source_system
    FROM source_data
    WHERE row_num = 1
        AND (join_time IS NULL OR leave_time IS NULL OR join_time <= leave_time)
    
{% else %}
    -- Generate sample data for testing
    SELECT 
        'PART_001' AS participant_id,
        'MEET_001' AS meeting_id,
        'USER_001' AS user_id,
        '2024-01-15 09:00:00'::TIMESTAMP AS join_time,
        '2024-01-15 09:30:00'::TIMESTAMP AS leave_time,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' AS source_system
    
    UNION ALL
    
    SELECT 
        'PART_002' AS participant_id,
        'MEET_001' AS meeting_id,
        'USER_002' AS user_id,
        '2024-01-15 09:02:00'::TIMESTAMP AS join_time,
        '2024-01-15 09:30:00'::TIMESTAMP AS leave_time,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' AS source_system
    
    UNION ALL
    
    SELECT 
        'PART_003' AS participant_id,
        'MEET_002' AS meeting_id,
        'USER_003' AS user_id,
        '2024-01-15 14:00:00'::TIMESTAMP AS join_time,
        '2024-01-15 15:00:00'::TIMESTAMP AS leave_time,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' AS source_system
{% endif %}
