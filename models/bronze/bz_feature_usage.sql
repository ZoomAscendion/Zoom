-- Bronze Layer Feature Usage Model
-- Description: Raw usage of platform features during meetings from source systems
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'feature_usage']
) }}

-- Raw data selection with primary key filtering
WITH raw_feature_usage AS (
    SELECT *
    FROM {{ source('raw_schema', 'feature_usage') }}
    WHERE usage_id IS NOT NULL  -- Filter out records with null primary key
),

-- Deduplication logic based on primary key and load timestamp
deduped_feature_usage AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY usage_id 
               ORDER BY load_timestamp DESC, update_timestamp DESC NULLS LAST
           ) AS row_num
    FROM raw_feature_usage
),

-- Final transformation with 1-1 mapping
final_feature_usage AS (
    SELECT 
        usage_id,
        meeting_id,
        feature_name,
        usage_count,
        usage_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM deduped_feature_usage
    WHERE row_num = 1
)

SELECT * FROM final_feature_usage
