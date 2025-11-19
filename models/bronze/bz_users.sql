-- Bronze Layer Users Table
-- Description: Stores user profile and subscription information from source systems
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'users']
) }}

-- CTE to filter out NULL primary keys and prepare raw data
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
    WHERE USER_ID IS NOT NULL
),

-- CTE for deduplication based on primary key and latest timestamp
deduped_users AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY USER_ID 
            ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC
        ) AS row_num
    FROM raw_users_filtered
)

-- Final selection with 1-to-1 mapping from raw to bronze
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
WHERE row_num = 1
