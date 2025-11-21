-- Bronze Layer Feature Usage Table
-- Description: Raw feature usage data tracking user interactions
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ target.schema }}.bz_data_audit (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'DBT_USER', 0, 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ target.schema }}.bz_data_audit (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'DBT_USER', 10, 'SUCCESS' WHERE '{{ this.name }}' != 'bz_data_audit'"
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
      AND meeting_id IS NOT NULL  -- Filter out NULL meeting_id
      AND feature_name IS NOT NULL -- Filter out NULL feature_name
      AND usage_count IS NOT NULL  -- Filter out NULL usage_count
      AND usage_date IS NOT NULL   -- Filter out NULL usage_date
),

-- CTE for deduplication based on primary key
deduped_feature_usage AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY usage_id ORDER BY load_timestamp DESC) as rn
    FROM raw_feature_usage
)

-- Final selection with Bronze timestamp overwrite
SELECT 
    usage_id,
    meeting_id,
    feature_name,
    usage_count,
    usage_date,
    CURRENT_TIMESTAMP() AS load_timestamp,    -- Overwrite with current DBT run time
    CURRENT_TIMESTAMP() AS update_timestamp,  -- Overwrite with current DBT run time
    source_system
FROM deduped_feature_usage
WHERE rn = 1  -- Keep only the most recent record per usage_id
