-- Bronze Layer Users Table
-- Description: Stores user profile and subscription information from source systems
-- Author: Data Engineering Team
-- Created: 2024-12-19

{{ config(
    materialized='table',
    tags=['bronze', 'users']
) }}

WITH source_data AS (
    -- Select from RAW layer with null filtering for primary key
    SELECT *
    FROM {{ source('raw', 'users') }}
    WHERE USER_ID IS NOT NULL
),

deduped_data AS (
    -- Apply deduplication based on primary key and latest timestamp
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY USER_ID 
               ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC
           ) AS row_num
    FROM source_data
)

-- Final selection with 1-1 mapping from RAW to Bronze
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
