-- Bronze Layer Users Model
-- Description: Raw user account data from user management systems
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='user_id',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS) SELECT 'BZ_USERS', CURRENT_TIMESTAMP(), 'DBT_USER', 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS) SELECT 'BZ_USERS', CURRENT_TIMESTAMP(), 'DBT_USER', 'COMPLETED' WHERE '{{ this.name }}' != 'bz_data_audit'"
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
           ) as rn
    FROM source_data
),

-- Final transformation with data quality checks
final AS (
    SELECT 
        user_id,
        user_name,
        -- Handle NULL email by creating default email
        CASE 
            WHEN email IS NULL OR TRIM(email) = '' 
            THEN user_name || '@gmail.com'
            ELSE email 
        END as email,
        company,
        plan_type,
        -- Overwrite timestamps with current DBT run time
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        source_system
    FROM deduped_data
    WHERE rn = 1  -- Keep only the most recent record per user_id
)

SELECT * FROM final
