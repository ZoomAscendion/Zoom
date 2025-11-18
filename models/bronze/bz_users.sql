{{
  config(
    materialized='table',
    tags=['bronze', 'users'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS) SELECT 'BZ_USERS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 'STARTED' WHERE EXISTS (SELECT 1 FROM {{ ref('bz_data_audit') }} LIMIT 1)",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_USERS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 1.0, 'SUCCESS' WHERE EXISTS (SELECT 1 FROM {{ ref('bz_data_audit') }} LIMIT 1)"
  )
}}

-- Bronze Layer Users Table
-- 1:1 mapping from RAW.USERS to BRONZE.BZ_USERS
-- Includes deduplication logic based on USER_ID and LOAD_TIMESTAMP

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
    FROM {{ source('raw_schema', 'users') }}
),

-- Apply deduplication logic - keep latest record per USER_ID
deduped_data AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY USER_ID 
            ORDER BY LOAD_TIMESTAMP DESC, UPDATE_TIMESTAMP DESC
        ) AS row_num
    FROM source_data
)

-- Final selection with audit columns
SELECT 
    USER_ID,
    USER_NAME,
    EMAIL,
    COMPANY,
    PLAN_TYPE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM deduped_data
WHERE row_num = 1
