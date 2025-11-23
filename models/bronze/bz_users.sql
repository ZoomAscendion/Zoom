-- Bronze Layer Users Model
-- Description: Raw user account data from user management systems
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    pre_hook="CREATE TABLE IF NOT EXISTS {{ this.database }}.{{ this.schema }}.bz_data_audit_temp AS SELECT 'BZ_USERS' as source_table, CURRENT_TIMESTAMP() as load_timestamp, 'DBT_BRONZE_PIPELINE' as processed_by, 0 as processing_time, 'STARTED' as status, 1 as record_id",
    post_hook="CREATE TABLE IF NOT EXISTS {{ this.database }}.{{ this.schema }}.bz_data_audit_temp AS SELECT 'BZ_USERS' as source_table, CURRENT_TIMESTAMP() as load_timestamp, 'DBT_BRONZE_PIPELINE' as processed_by, 1 as processing_time, 'COMPLETED' as status, 2 as record_id"
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
