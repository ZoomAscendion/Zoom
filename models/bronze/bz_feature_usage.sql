-- Bronze Layer Feature Usage Model
-- Description: Transforms raw feature usage data into bronze layer with audit capabilities
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'feature_usage']
) }}

-- CTE to select and filter raw data
WITH raw_feature_usage AS (
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

-- CTE for deduplication based on primary key and latest update timestamp
deduped_feature_usage AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY USAGE_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) AS row_num
    FROM raw_feature_usage
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
WHERE row_num = 1  -- Keep only the most recent record for each usage
