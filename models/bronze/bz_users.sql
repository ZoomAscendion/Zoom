-- Bronze Layer Users Table
-- Description: Transforms raw user data into bronze layer with data quality checks and deduplication
-- Source: RAW.USERS
-- Target: BRONZE.BZ_USERS
-- Author: DBT Bronze Pipeline
-- Created: {{ run_started_at }}

{{ config(
    materialized='table'
) }}

WITH raw_users_filtered AS (
    -- Filter out records with NULL primary keys
    SELECT *
    FROM {{ source('raw_zoom', 'users') }}
    WHERE user_id IS NOT NULL
),

raw_users_deduplicated AS (
    -- Apply deduplication logic based on primary key and latest update timestamp
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY user_id 
               ORDER BY update_timestamp DESC, load_timestamp DESC
           ) AS row_num
    FROM raw_users_filtered
),

raw_users_clean AS (
    -- Select only the most recent record for each user
    SELECT 
        user_id,
        user_name,
        email,
        company,
        plan_type,
        source_system
    FROM raw_users_deduplicated
    WHERE row_num = 1
),

final_users AS (
    -- Apply Bronze layer transformations and add audit columns
    SELECT 
        -- Primary business columns (1-1 mapping from RAW)
        user_id,
        user_name,
        email,
        company,
        plan_type,
        
        -- Bronze layer audit columns (overwrite with current timestamp)
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        
        -- Source system tracking
        COALESCE(source_system, 'UNKNOWN') AS source_system
    FROM raw_users_clean
)

SELECT *
FROM final_users
