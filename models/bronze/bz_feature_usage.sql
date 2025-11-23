-- Bronze Layer Feature Usage Table
-- Description: Raw feature usage data tracking user interactions
-- Source: RAW.FEATURE_USAGE
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='usage_id',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'dbt_user', 0, 'STARTED'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'dbt_user', DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_FEATURE_USAGE' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS'"
) }}

-- Source data with null filtering for primary key
WITH source_data AS (
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
    WHERE usage_id IS NOT NULL    -- Filter out null primary keys
      AND meeting_id IS NOT NULL  -- Filter out null meeting_id
      AND feature_name IS NOT NULL -- Filter out null feature_name
      AND usage_count IS NOT NULL  -- Filter out null usage_count
      AND usage_date IS NOT NULL   -- Filter out null usage_date
),

-- Data cleaning and validation
cleaned_data AS (
    SELECT 
        usage_id,
        meeting_id,
        feature_name,
        usage_count,
        usage_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM source_data
    WHERE usage_count >= 0  -- Ensure usage count is non-negative
),

-- Deduplication based on usage_id (keeping latest record)
deduped_data AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY usage_id ORDER BY COALESCE(update_timestamp, load_timestamp) DESC) AS rn
    FROM cleaned_data
)

-- Final selection with Bronze timestamp overwrite
SELECT 
    usage_id,
    meeting_id,
    feature_name,
    usage_count,
    usage_date,
    CURRENT_TIMESTAMP() AS load_timestamp,  -- Overwrite with current DBT run time
    CURRENT_TIMESTAMP() AS update_timestamp,  -- Overwrite with current DBT run time
    source_system
FROM deduped_data
WHERE rn = 1
