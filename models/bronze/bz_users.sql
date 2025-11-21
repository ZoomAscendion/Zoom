-- Bronze Layer Users Table
-- Description: Raw user account data from user management systems
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_USERS', CURRENT_TIMESTAMP(), 'DBT_USER', 0, 'STARTED')",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_USERS', CURRENT_TIMESTAMP(), 'DBT_USER', DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_USERS' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS')"
) }}

-- CTE to select and filter raw data
WITH raw_users AS (
    SELECT 
        user_id,
        user_name,
        email,
        company,
        plan_type,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw', 'users') }}
    WHERE user_id IS NOT NULL  -- Filter out NULL primary keys
      AND email IS NOT NULL   -- Filter out NULL email (unique constraint)
),

-- CTE for deduplication based on primary key
deduped_users AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY load_timestamp DESC) as rn
    FROM raw_users
)

-- Final selection with Bronze timestamp overwrite
SELECT 
    user_id,
    COALESCE(user_name, user_id || '_user') AS user_name,  -- Default value if null
    COALESCE(email, user_id || '@gmail.com') AS email,     -- Default email format
    company,
    plan_type,
    CURRENT_TIMESTAMP() AS load_timestamp,    -- Overwrite with current DBT run time
    CURRENT_TIMESTAMP() AS update_timestamp,  -- Overwrite with current DBT run time
    source_system
FROM deduped_users
WHERE rn = 1  -- Keep only the most recent record per user_id
