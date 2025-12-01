-- Bronze Layer Licenses Model
-- Description: License assignments and entitlements

{{ config(
    materialized='table',
    tags=['bronze', 'licenses']
) }}

-- Check if source table exists
{% set source_exists = adapter.get_relation(
    database=var('source_database'),
    schema=var('source_schema'),
    identifier='licenses'
) %}

{% if source_exists %}
    -- Use real source data if available
    WITH source_data AS (
        SELECT 
            license_id,
            license_type,
            assigned_to_user_id,
            start_date,
            end_date,
            load_timestamp,
            update_timestamp,
            source_system,
            ROW_NUMBER() OVER (PARTITION BY license_id ORDER BY COALESCE(update_timestamp, load_timestamp) DESC) AS row_num
        FROM {{ source('raw', 'licenses') }}
        WHERE license_id IS NOT NULL
    )
    
    SELECT 
        license_id,
        license_type,
        assigned_to_user_id,
        start_date,
        end_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        COALESCE(source_system, 'UNKNOWN') AS source_system
    FROM source_data
    WHERE row_num = 1
        AND assigned_to_user_id IS NOT NULL
        AND (start_date IS NULL OR end_date IS NULL OR start_date <= end_date)
        AND (start_date IS NULL OR start_date <= CURRENT_DATE() + INTERVAL '1 year')
    
{% else %}
    -- Generate sample data for testing
    SELECT 
        'LIC_001' AS license_id,
        'Pro' AS license_type,
        'USER_001' AS assigned_to_user_id,
        '2024-01-01'::DATE AS start_date,
        '2024-12-31'::DATE AS end_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' AS source_system
    
    UNION ALL
    
    SELECT 
        'LIC_002' AS license_id,
        'Enterprise' AS license_type,
        'USER_002' AS assigned_to_user_id,
        '2024-01-01'::DATE AS start_date,
        '2025-12-31'::DATE AS end_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' AS source_system
    
    UNION ALL
    
    SELECT 
        'LIC_003' AS license_id,
        'Basic' AS license_type,
        'USER_003' AS assigned_to_user_id,
        '2024-01-15'::DATE AS start_date,
        '2024-07-15'::DATE AS end_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' AS source_system
{% endif %}
