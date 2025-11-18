-- Bronze Pipeline Step 2: Transform raw users data to bronze layer
-- Description: 1-1 mapping from RAW.USERS to BRONZE.BZ_USERS with deduplication
-- Author: Data Engineering Team
-- Created: 2024-01-01

{{ config(
    materialized='table',
    tags=['bronze', 'users']
) }}

-- Bronze Pipeline Step 2.1: Select and filter raw data excluding null primary keys
WITH raw_users_filtered AS (
    SELECT 
        user_id,
        user_name,
        email,
        company,
        plan_type,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw_layer', 'users') }}
    WHERE user_id IS NOT NULL  -- Filter out null primary keys
),

-- Bronze Pipeline Step 2.2: Apply deduplication logic based on primary key and latest timestamp
deduped_users AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY user_id 
            ORDER BY COALESCE(update_timestamp, load_timestamp) DESC, load_timestamp DESC
        ) as rn
    FROM raw_users_filtered
),

-- Bronze Pipeline Step 2.3: Select final deduplicated records
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
    WHERE rn = 1
)

SELECT * FROM final_users
