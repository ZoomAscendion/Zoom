/*
  Bronze Feature Usage Model
  Purpose: Transform raw feature usage data to bronze layer
  Source: RAW.FEATURE_USAGE
  Author: DBT Data Engineer
  Created: {{ run_started_at }}
*/

{{ config(
    materialized='table'
) }}

WITH source_data AS (
    SELECT *
    FROM {{ source('raw_zoom', 'feature_usage') }}
),

-- Data validation and cleansing
cleansed_data AS (
    SELECT
        -- Business fields with data validation
        COALESCE(TRIM(meeting_id), 'UNKNOWN') AS meeting_id,
        COALESCE(TRIM(feature_name), 'UNKNOWN') AS feature_name,
        COALESCE(usage_count, 0) AS usage_count,
        COALESCE(usage_date, CURRENT_DATE()) AS usage_date,
        
        -- Audit fields
        COALESCE(load_timestamp, CURRENT_TIMESTAMP()) AS load_timestamp,
        COALESCE(update_timestamp, CURRENT_TIMESTAMP()) AS update_timestamp,
        COALESCE(TRIM(source_system), 'UNKNOWN') AS source_system,
        
        -- Process metadata
        CURRENT_TIMESTAMP() AS bronze_created_at,
        'SUCCESS' AS process_status
        
    FROM source_data
    WHERE meeting_id IS NOT NULL  -- Basic data quality check
)

SELECT
    meeting_id::STRING AS meeting_id,
    feature_name::STRING AS feature_name,
    usage_count::NUMBER(38,0) AS usage_count,
    usage_date::DATE AS usage_date,
    load_timestamp::TIMESTAMP_NTZ AS load_timestamp,
    update_timestamp::TIMESTAMP_NTZ AS update_timestamp,
    source_system::STRING AS source_system
FROM cleansed_data
