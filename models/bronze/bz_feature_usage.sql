-- Bronze Layer Feature Usage Table
-- Description: Records usage of platform features during meetings
-- Author: Data Engineering Team
-- Created: 2024-12-19

{{ config(
    materialized='table',
    tags=['bronze', 'feature_usage'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (RECORD_ID, SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) VALUES ({{ range(1, 1000000) | random }}, 'BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 0.0, 'STARTED')",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (RECORD_ID, SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) VALUES ({{ range(1, 1000000) | random }}, 'BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 0.0, 'COMPLETED')"
) }}

WITH source_data AS (
    -- Select from RAW layer with null filtering for primary key
    SELECT *
    FROM {{ source('raw', 'feature_usage') }}
    WHERE USAGE_ID IS NOT NULL
),

deduped_data AS (
    -- Apply deduplication based on primary key and latest timestamp
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY USAGE_ID 
               ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC
           ) AS row_num
    FROM source_data
)

-- Final selection with 1-1 mapping from RAW to Bronze
SELECT
    USAGE_ID,
    MEETING_ID,
    FEATURE_NAME,
    USAGE_COUNT,
    USAGE_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM deduped_data
WHERE row_num = 1
