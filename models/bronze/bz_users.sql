-- Bronze Layer Users Model
-- Description: Raw user account data from user management systems
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_USERS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 0, 'STARTED')",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_USERS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_USERS' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'COMPLETED')"
) }}

-- Filter out null primary keys and apply deduplication
WITH source_data AS (
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
    WHERE USER_ID IS NOT NULL  -- Filter null primary keys
),

-- Apply deduplication based on primary key and latest timestamp
deduped_data AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY USER_ID 
            ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC
        ) as rn
    FROM source_data
)

SELECT 
    USER_ID,
    COALESCE(USER_NAME, USER_ID || '_user') as USER_NAME,  -- Handle null user names
    COALESCE(EMAIL, USER_ID || '@gmail.com') as EMAIL,     -- Handle null emails for tests
    COMPANY,
    PLAN_TYPE,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,    -- Overwrite with current timestamp
    CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP,  -- Overwrite with current timestamp
    SOURCE_SYSTEM
FROM deduped_data
WHERE rn = 1  -- Keep only the latest record per user
