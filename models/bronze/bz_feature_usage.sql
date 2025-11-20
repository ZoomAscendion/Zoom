-- Bronze Layer Feature Usage Model
-- Description: Transforms raw feature usage data to bronze layer with data quality checks
-- Author: Data Engineering Team

{{ config(
    materialized='table',
    tags=['bronze', 'feature_usage']
) }}

-- CTE to filter out null primary keys and prepare raw data
WITH raw_feature_usage_filtered AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw', 'feature_usage') }}
    WHERE USAGE_ID IS NOT NULL  -- Filter out records with null primary key
),

-- CTE for deduplication based on primary key and latest timestamp
deduped_feature_usage AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY USAGE_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) as rn
    FROM raw_feature_usage_filtered
)

-- Final selection with 1-1 mapping from raw to bronze
SELECT 
    USAGE_ID,
    MEETING_ID,
    FEATURE_NAME,
    USAGE_COUNT,
    USAGE_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM deduped_feature_usage
WHERE rn = 1  -- Keep only the most recent record for each usage
