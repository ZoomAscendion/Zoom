-- Bronze Layer Users Model
-- Description: Transforms raw user data to bronze layer with data quality checks
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'users']
) }}

-- CTE to filter out null primary keys and prepare raw data
WITH raw_users_filtered AS (
    SELECT 
        USER_ID,
        USER_NAME,
        EMAIL,
        COMPANY,
        PLAN_TYPE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw', 'users') }}
    WHERE USER_ID IS NOT NULL  -- Filter out records with null primary key
),

-- CTE for deduplication based on primary key and latest timestamp
deduped_users AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY USER_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) as rn
    FROM raw_users_filtered
)

-- Final selection with 1-1 mapping from raw to bronze
SELECT 
    USER_ID,
    USER_NAME,
    EMAIL,
    COMPANY,
    PLAN_TYPE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM deduped_users
WHERE rn = 1  -- Keep only the most recent record for each user
