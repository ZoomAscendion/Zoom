-- Bronze Layer Feature Usage Model
-- Transforms raw feature usage data from RAW.FEATURE_USAGE to Bronze layer
-- Author: DBT Data Engineer
-- Created: {{ run_started_at }}

{{ config(
    materialized='table'
) }}

-- CTE for raw data extraction
WITH raw_feature_usage AS (
    SELECT 
        -- Business columns from source
        USAGE_ID,
        MEETING_ID,
        FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
        
    FROM {{ source('raw', 'feature_usage') }}
),

-- CTE for data validation and cleansing
validated_feature_usage AS (
    SELECT 
        -- Apply data quality checks and preserve original structure
        COALESCE(USAGE_ID, 'UNKNOWN') as USAGE_ID,
        COALESCE(MEETING_ID, 'UNKNOWN') as MEETING_ID,
        COALESCE(FEATURE_NAME, 'UNKNOWN') as FEATURE_NAME,
        COALESCE(USAGE_COUNT, 0) as USAGE_COUNT,
        USAGE_DATE,
        
        -- Metadata preservation
        COALESCE(LOAD_TIMESTAMP, CURRENT_TIMESTAMP()) as LOAD_TIMESTAMP,
        COALESCE(UPDATE_TIMESTAMP, CURRENT_TIMESTAMP()) as UPDATE_TIMESTAMP,
        COALESCE(SOURCE_SYSTEM, 'ZOOM_PLATFORM') as SOURCE_SYSTEM
        
    FROM raw_feature_usage
)

-- Final selection for Bronze layer
SELECT 
    USAGE_ID,
    MEETING_ID,
    FEATURE_NAME,
    USAGE_COUNT,
    USAGE_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM validated_feature_usage
