-- Bronze Layer Feature Usage Model
-- Description: Raw feature usage data tracking user interactions
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 0, 'STARTED')",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_FEATURE_USAGE' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'COMPLETED')"
) }}

-- Filter out null primary keys and apply deduplication
WITH source_data AS (
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
    WHERE USAGE_ID IS NOT NULL    -- Filter null primary keys
      AND MEETING_ID IS NOT NULL  -- Filter null meeting IDs
),

-- Apply deduplication based on primary key and latest timestamp
deduped_data AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY USAGE_ID 
            ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC
        ) as rn
    FROM source_data
)

SELECT 
    USAGE_ID,
    MEETING_ID,
    FEATURE_NAME,
    USAGE_COUNT,
    USAGE_DATE,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,    -- Overwrite with current timestamp
    CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP,  -- Overwrite with current timestamp
    SOURCE_SYSTEM
FROM deduped_data
WHERE rn = 1  -- Keep only the latest record per usage
