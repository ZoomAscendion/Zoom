-- Bronze Layer Users Model
-- Description: User profile and subscription information from source systems

{{ config(
    materialized='table',
    tags=['bronze', 'users', 'pii']
) }}

-- Check if source table exists
{% set source_exists = adapter.get_relation(
    database=var('source_database'),
    schema=var('source_schema'),
    identifier='users'
) %}

{% if source_exists %}
    -- Use real source data if available
    WITH source_data AS (
        SELECT 
            user_id,
            user_name,
            email,
            company,
            plan_type,
            load_timestamp,
            update_timestamp,
            source_system,
            ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY COALESCE(update_timestamp, load_timestamp) DESC) AS row_num
        FROM {{ source('raw', 'users') }}
        WHERE user_id IS NOT NULL
    )
    
    SELECT 
        user_id,
        user_name,
        CASE 
            WHEN email IS NULL OR email = '' THEN 
                COALESCE(user_name, 'user' || user_id) || '@gmail.com'
            ELSE email
        END AS email,
        company,
        CASE 
            WHEN plan_type IN ('Basic', 'Pro', 'Business', 'Enterprise') THEN plan_type
            ELSE 'Basic'
        END AS plan_type,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        COALESCE(source_system, 'UNKNOWN') AS source_system
    FROM source_data
    WHERE row_num = 1
    
{% else %}
    -- Generate sample data for testing
    SELECT 
        'USER_001' AS user_id,
        'John Doe' AS user_name,
        'john.doe@gmail.com' AS email,
        'Acme Corp' AS company,
        'Pro' AS plan_type,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' AS source_system
    
    UNION ALL
    
    SELECT 
        'USER_002' AS user_id,
        'Jane Smith' AS user_name,
        'jane.smith@gmail.com' AS email,
        'Tech Solutions' AS company,
        'Enterprise' AS plan_type,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' AS source_system
    
    UNION ALL
    
    SELECT 
        'USER_003' AS user_id,
        'Bob Johnson' AS user_name,
        'bob.johnson@gmail.com' AS email,
        'StartupXYZ' AS company,
        'Basic' AS plan_type,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' AS source_system
{% endif %}
