-- Bronze Layer Feature Usage Model
-- Transforms raw feature usage data from RAW.FEATURE_USAGE to BRONZE.BZ_FEATURE_USAGE
-- Author: Data Engineering Team
-- Created: 2024-12-19

{{ config(materialized='table') }}

SELECT 
    -- Business columns from source (1:1 mapping)
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
WHERE USAGE_ID IS NOT NULL
