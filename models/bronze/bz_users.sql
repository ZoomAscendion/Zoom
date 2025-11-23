-- Bronze Layer Users Table
-- Description: Raw user account data from user management systems
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='user_id',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_USERS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 0, 'STARTED'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_USERS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_USERS' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS'"
) }}

WITH source_data AS (
    SELECT 
        USER_ID,
        USER_NAME,
        EMAIL,
        COMPANY,
        PLAN_TYPE,
        LOAD_TIMESTAMP as raw_load_timestamp,
        UPDATE_TIMESTAMP as raw_update_timestamp,
        SOURCE_SYSTEM
    FROM {{ source('raw_schema', 'users') }}
    WHERE USER_ID IS NOT NULL  -- Filter out NULL primary keys
),

-- Apply deduplication based on primary key and latest timestamp
deduped_data AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY USER_ID 
            ORDER BY COALESCE(raw_update_timestamp, raw_load_timestamp) DESC
        ) as row_num
    FROM source_data
),

-- Handle null values and apply business rules
cleaned_data AS (
    SELECT 
        USER_ID,
        COALESCE(USER_NAME, 'Unknown User') as USER_NAME,
        COALESCE(EMAIL, USER_NAME || '@gmail.com') as EMAIL,  -- Default email for null values
        COMPANY,
        COALESCE(PLAN_TYPE, 'Basic') as PLAN_TYPE,
        CURRENT_TIMESTAMP() AS load_timestamp,  -- Bronze timestamp overwrite
        CURRENT_TIMESTAMP() AS update_timestamp,  -- Bronze timestamp overwrite
        SOURCE_SYSTEM
    FROM deduped_data
    WHERE row_num = 1
)

SELECT * FROM cleaned_data
