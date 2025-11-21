-- Bronze Layer Feature Usage Table
-- Description: Records usage of platform features during meetings
-- Source: RAW.FEATURE_USAGE
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='usage_id',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 0, 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_FEATURE_USAGE' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS' WHERE '{{ this.name }}' != 'bz_data_audit'"
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
    FROM {{ source('raw_layer', 'feature_usage') }}
    WHERE usage_id IS NOT NULL    -- Filter out records with null primary keys
      AND meeting_id IS NOT NULL  -- Filter out records with null meeting_id
),

-- CTE for data cleaning and validation
cleaned_feature_usage AS (
    SELECT 
        usage_id,
        meeting_id,
        feature_name,
        usage_count,
        usage_date,
        load_timestamp,
        update_timestamp,
        source_system,
        ROW_NUMBER() OVER (PARTITION BY usage_id ORDER BY load_timestamp DESC) AS row_num
    FROM raw_feature_usage
),

-- CTE for deduplication
deduped_feature_usage AS (
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
    WHERE row_num = 1  -- Keep only the latest record for each usage_id
)

-- Final SELECT with Bronze timestamp overwrite
SELECT 
    usage_id::VARCHAR(16777216) AS usage_id,
    meeting_id::VARCHAR(16777216) AS meeting_id,
    feature_name::VARCHAR(16777216) AS feature_name,
    usage_count::NUMBER(38,0) AS usage_count,
    usage_date::DATE AS usage_date,
    CURRENT_TIMESTAMP() AS load_timestamp,
    CURRENT_TIMESTAMP() AS update_timestamp,
    source_system::VARCHAR(16777216) AS source_system
FROM deduped_feature_usage
