-- Bronze Layer Feature Usage Model
-- Description: Platform feature usage during meetings

{{ config(
    materialized='table',
    tags=['bronze', 'feature_usage']
) }}

-- Check if source table exists
{% set source_exists = adapter.get_relation(
    database=var('source_database'),
    schema=var('source_schema'),
    identifier='feature_usage'
) %}

{% if source_exists %}
    -- Use real source data if available
    WITH source_data AS (
        SELECT 
            usage_id,
            meeting_id,
            feature_name,
            usage_count,
            usage_date,
            load_timestamp,
            update_timestamp,
            source_system,
            ROW_NUMBER() OVER (PARTITION BY usage_id ORDER BY COALESCE(update_timestamp, load_timestamp) DESC) AS row_num
        FROM {{ source('raw', 'feature_usage') }}
        WHERE usage_id IS NOT NULL
    )
    
    SELECT 
        usage_id,
        meeting_id,
        feature_name,
        CASE 
            WHEN usage_count < 0 THEN 0
            ELSE COALESCE(usage_count, 0)
        END AS usage_count,
        usage_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        COALESCE(source_system, 'UNKNOWN') AS source_system
    FROM source_data
    WHERE row_num = 1
        AND feature_name IS NOT NULL
        AND (usage_date IS NULL OR usage_date <= CURRENT_DATE())
    
{% else %}
    -- Generate sample data for testing
    SELECT 
        'USAGE_001' AS usage_id,
        'MEET_001' AS meeting_id,
        'Screen Share' AS feature_name,
        5 AS usage_count,
        '2024-01-15'::DATE AS usage_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' AS source_system
    
    UNION ALL
    
    SELECT 
        'USAGE_002' AS usage_id,
        'MEET_001' AS meeting_id,
        'Chat' AS feature_name,
        12 AS usage_count,
        '2024-01-15'::DATE AS usage_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' AS source_system
    
    UNION ALL
    
    SELECT 
        'USAGE_003' AS usage_id,
        'MEET_002' AS meeting_id,
        'Recording' AS feature_name,
        1 AS usage_count,
        '2024-01-15'::DATE AS usage_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' AS source_system
    
    UNION ALL
    
    SELECT 
        'USAGE_004' AS usage_id,
        'MEET_003' AS meeting_id,
        'Whiteboard' AS feature_name,
        3 AS usage_count,
        '2024-01-16'::DATE AS usage_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' AS source_system
{% endif %}
