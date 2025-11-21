-- Bronze Layer Feature Usage Table
-- Description: Transforms raw feature usage data into bronze layer with data quality checks and deduplication
-- Source: RAW.FEATURE_USAGE
-- Target: BRONZE.BZ_FEATURE_USAGE
-- Author: DBT Bronze Pipeline
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    post_hook="INSERT INTO {{ this.schema }}.bz_data_audit (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('bz_feature_usage', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 0, 'COMPLETED')"
) }}

WITH raw_feature_usage_filtered AS (
    -- Filter out records with NULL primary keys
    SELECT *
    FROM {{ source('raw_zoom', 'feature_usage') }}
    WHERE usage_id IS NOT NULL
),

raw_feature_usage_deduplicated AS (
    -- Apply deduplication logic based on primary key and latest update timestamp
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY usage_id 
               ORDER BY COALESCE(update_timestamp, load_timestamp, CURRENT_TIMESTAMP()) DESC
           ) AS row_num
    FROM raw_feature_usage_filtered
),

raw_feature_usage_clean AS (
    -- Select only the most recent record for each usage record
    SELECT 
        usage_id,
        meeting_id,
        feature_name,
        usage_count,
        usage_date,
        source_system
    FROM raw_feature_usage_deduplicated
    WHERE row_num = 1
),

final_feature_usage AS (
    -- Apply Bronze layer transformations and add audit columns
    SELECT 
        -- Primary business columns (1-1 mapping from RAW)
        usage_id,
        meeting_id,
        feature_name,
        usage_count,
        usage_date,
        
        -- Bronze layer audit columns (overwrite with current timestamp)
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        
        -- Source system tracking
        COALESCE(source_system, 'UNKNOWN') AS source_system
    FROM raw_feature_usage_clean
)

SELECT *
FROM final_feature_usage
