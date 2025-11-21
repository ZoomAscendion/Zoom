-- Bronze Layer Feature Usage Table
-- Description: Records usage of platform features during meetings
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='usage_id',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 0, 'STARTED')",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'DBT_PROCESS', DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_FEATURE_USAGE' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS')"
) }}

-- CTE to select and filter raw data
WITH raw_feature_usage AS (
    SELECT 
        usage_id,
        meeting_id,
        feature_name,
        usage_count,
        usage_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw', 'feature_usage') }}
    WHERE usage_id IS NOT NULL    -- Filter out NULL primary keys
      AND meeting_id IS NOT NULL  -- Filter out NULL foreign keys
),

-- CTE for deduplication based on usage_id and latest update_timestamp
deduped_feature_usage AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY usage_id 
            ORDER BY COALESCE(update_timestamp, load_timestamp) DESC
        ) as rn
    FROM raw_feature_usage
),

-- CTE for data quality and transformation
cleaned_feature_usage AS (
    SELECT 
        usage_id,
        meeting_id,
        COALESCE(feature_name, 'unknown') as feature_name,
        COALESCE(usage_count, 0) as usage_count,
        usage_date,
        CURRENT_TIMESTAMP() AS load_timestamp,  -- Overwrite with current timestamp
        CURRENT_TIMESTAMP() AS update_timestamp, -- Overwrite with current timestamp
        source_system
    FROM deduped_feature_usage
    WHERE rn = 1
)

-- Final SELECT with audit columns
SELECT 
    usage_id,
    meeting_id,
    feature_name,
    usage_count,
    usage_date,
    load_timestamp,
    update_timestamp,
    source_system
FROM cleaned_feature_usage
