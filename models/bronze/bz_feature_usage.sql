-- Bronze Layer Feature Usage Table
-- Description: Records usage of platform features during meetings
-- Author: DBT Pipeline Generator
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='usage_id',
    pre_hook="INSERT INTO {{ this.database }}.{{ this.schema }}.bz_data_audit (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'DBT_PIPELINE', 0, 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ this.database }}.{{ this.schema }}.bz_data_audit (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'DBT_PIPELINE', 1.0, 'SUCCESS' WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

WITH source_data AS (
    -- Select from raw feature_usage table with null filtering for primary key
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
    WHERE usage_id IS NOT NULL  -- Filter out null primary keys
),

deduped_data AS (
    -- Apply deduplication based on primary key and latest update timestamp
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY usage_id 
                   ORDER BY update_timestamp DESC, load_timestamp DESC
               ) as rn
        FROM source_data
    )
    WHERE rn = 1
)

-- Final select with 1-1 mapping from raw to bronze
SELECT 
    usage_id,
    meeting_id,
    feature_name,
    usage_count,
    usage_date,
    load_timestamp,
    update_timestamp,
    source_system
FROM deduped_data
