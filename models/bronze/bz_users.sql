-- Bronze Layer Users Model
-- Description: Raw user profile and subscription information from source systems
-- Author: Data Engineering Team
-- Created: 2024-12-19

{{ config(
    materialized='table',
    tags=['bronze', 'users'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, status) SELECT 'BZ_USERS', CURRENT_TIMESTAMP(), 'dbt_user', 'STARTED'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_USERS', CURRENT_TIMESTAMP(), 'dbt_user', DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_USERS' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS'"
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
               ORDER BY load_timestamp DESC, update_timestamp DESC NULLS LAST
           ) AS row_num
    FROM source_data
)

-- Final selection with 1-to-1 mapping from raw to bronze
SELECT 
    user_id,
    user_name,
    email,
    company,
    plan_type,
    load_timestamp,
    update_timestamp,
    source_system
FROM deduped_data
WHERE row_num = 1
