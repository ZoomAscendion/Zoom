-- Bronze Layer Users Model
-- Description: Raw user profile and subscription information from source systems
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'users']
) }}

-- Raw data selection with primary key filtering
WITH raw_users AS (
    SELECT *
    FROM {{ source('raw_schema', 'users') }}
    WHERE user_id IS NOT NULL  -- Filter out records with null primary key
),

-- Deduplication logic based on primary key and load timestamp
deduped_users AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY user_id 
               ORDER BY load_timestamp DESC, update_timestamp DESC NULLS LAST
           ) AS row_num
    FROM raw_users
),

-- Final transformation with 1-1 mapping
final_users AS (
    SELECT 
        user_id,
        user_name,
        email,
        company,
        plan_type,
        load_timestamp,
        update_timestamp,
        source_system
    FROM deduped_users
    WHERE row_num = 1
)

SELECT * FROM final_users
