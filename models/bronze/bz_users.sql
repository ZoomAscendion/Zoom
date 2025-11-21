-- Bronze Layer Users Table
-- Description: Stores user profile and subscription information from source systems
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'users'],
    pre_hook="
        {% if this.name != 'bz_data_audit' %}
        INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status)
        VALUES ('BZ_USERS', CURRENT_TIMESTAMP(), 'DBT_{{ invocation_id }}', 0, 'STARTED')
        {% endif %}
    ",
    post_hook="
        {% if this.name != 'bz_data_audit' %}
        INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status)
        VALUES ('BZ_USERS', CURRENT_TIMESTAMP(), 'DBT_{{ invocation_id }}', DATEDIFF('second', 
            (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_USERS' AND status = 'STARTED'), 
            CURRENT_TIMESTAMP()), 'COMPLETED')
        {% endif %}
    "
) }}

-- Filter out NULL primary keys and apply deduplication
WITH source_data AS (
    SELECT *
    FROM {{ source('raw', 'users') }}
    WHERE user_id IS NOT NULL  -- Filter NULL primary keys
),

-- Apply deduplication based on primary key and load timestamp
deduped_data AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY user_id 
            ORDER BY load_timestamp DESC
        ) AS row_num
    FROM source_data
),

-- Final transformation with data quality handling
final AS (
    SELECT
        -- Primary identifier
        user_id,
        
        -- User information with null handling
        COALESCE(user_name, 'Unknown User') AS user_name,
        CASE 
            WHEN email IS NULL OR email = '' THEN user_name || '@gmail.com'
            ELSE email 
        END AS email,
        company,
        COALESCE(plan_type, 'Basic') AS plan_type,
        
        -- Metadata columns - overwrite with current timestamp
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        COALESCE(source_system, 'unknown') AS source_system
        
    FROM deduped_data
    WHERE row_num = 1  -- Keep only the most recent record
)

SELECT * FROM final
