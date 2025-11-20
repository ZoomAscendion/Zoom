-- Bronze Layer Feature Usage Table
-- Description: Records usage of platform features during meetings
-- Author: DBT Data Engineer
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='usage_id',
    pre_hook="
        INSERT INTO {{ ref('bz_data_audit') }} 
        (record_id, source_table, load_timestamp, processed_by, processing_time, status)
        SELECT 
            COALESCE((SELECT MAX(record_id) FROM {{ ref('bz_data_audit') }}), 0) + 1,
            'BZ_FEATURE_USAGE', 
            CURRENT_TIMESTAMP(), 
            'DBT_BRONZE_PIPELINE', 
            0, 
            'STARTED'
    ",
    post_hook="
        INSERT INTO {{ ref('bz_data_audit') }} 
        (record_id, source_table, load_timestamp, processed_by, processing_time, status)
        SELECT 
            COALESCE((SELECT MAX(record_id) FROM {{ ref('bz_data_audit') }}), 0) + 1,
            'BZ_FEATURE_USAGE', 
            CURRENT_TIMESTAMP(), 
            'DBT_BRONZE_PIPELINE', 
            DATEDIFF('second', 
                (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_FEATURE_USAGE' AND status = 'STARTED'), 
                CURRENT_TIMESTAMP()), 
            'SUCCESS'
    "
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
    FROM {{ source('raw', 'feature_usage') }}
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
    ) ranked
    WHERE rn = 1
)

-- Final select with 1-1 mapping from raw to bronze
SELECT 
    usage_id::VARCHAR(16777216) as usage_id,
    meeting_id::VARCHAR(16777216) as meeting_id,
    feature_name::VARCHAR(16777216) as feature_name,
    usage_count::NUMBER(38,0) as usage_count,
    usage_date::DATE as usage_date,
    load_timestamp::TIMESTAMP_NTZ(9) as load_timestamp,
    update_timestamp::TIMESTAMP_NTZ(9) as update_timestamp,
    source_system::VARCHAR(16777216) as source_system
FROM deduped_data
