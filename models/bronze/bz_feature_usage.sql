-- Bronze Layer Feature Usage Table
-- Description: Records usage of platform features during meetings
-- Source: RAW.FEATURE_USAGE
-- Author: DBT Data Engineer
-- Created: {{ run_started_at }}

{{ config(
    materialized='table'
) }}

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
    WHERE USAGE_ID IS NOT NULL    -- Filter out NULL primary keys
      AND MEETING_ID IS NOT NULL  -- Filter out NULL foreign keys
      AND FEATURE_NAME IS NOT NULL -- Filter out NULL required fields
),

-- Apply deduplication based on primary key and latest timestamp
deduped_data AS (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY USAGE_ID 
                   ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC
               ) AS row_num
        FROM source_data
    )
    WHERE row_num = 1
),

-- Final transformation with Bronze timestamp overwrite
final_data AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        CURRENT_TIMESTAMP() AS load_timestamp,  -- Overwrite with current DBT run time
        CURRENT_TIMESTAMP() AS update_timestamp, -- Overwrite with current DBT run time
        SOURCE_SYSTEM
    FROM deduped_data
)

SELECT * FROM final_data
