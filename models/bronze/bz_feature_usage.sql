-- Bronze Layer Feature Usage Model
-- Description: Transforms raw feature usage data to bronze layer with data quality checks
-- Source: RAW.FEATURE_USAGE
-- Target: BRONZE.bz_feature_usage
-- Author: DBT Data Engineer
-- Created: {{ run_started_at }}

{{ config(
    materialized='table'
) }}

WITH raw_feature_usage AS (
    SELECT 
        MEETING_ID,
        FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw', 'FEATURE_USAGE') }}
),

-- Data quality and cleansing transformations
cleansed_feature_usage AS (
    SELECT 
        -- 1-1 mapping from raw to bronze as per mapping specification
        TRIM(MEETING_ID) as meeting_id,
        TRIM(UPPER(FEATURE_NAME)) as feature_name,
        CASE 
            WHEN USAGE_COUNT IS NULL THEN 0
            WHEN USAGE_COUNT < 0 THEN 0
            ELSE USAGE_COUNT 
        END as usage_count,
        USAGE_DATE as usage_date,
        LOAD_TIMESTAMP as load_timestamp,
        COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) as update_timestamp,
        TRIM(UPPER(SOURCE_SYSTEM)) as source_system,
        
        -- Audit fields for bronze layer
        CURRENT_TIMESTAMP() as bronze_created_at,
        'SUCCESS' as process_status
        
    FROM raw_feature_usage
    WHERE MEETING_ID IS NOT NULL
      AND FEATURE_NAME IS NOT NULL
      AND USAGE_DATE IS NOT NULL
      AND LOAD_TIMESTAMP IS NOT NULL
      AND SOURCE_SYSTEM IS NOT NULL
)

-- Final select for bronze layer
SELECT 
    meeting_id,
    feature_name,
    usage_count,
    usage_date,
    load_timestamp,
    update_timestamp,
    source_system
FROM cleansed_feature_usage
