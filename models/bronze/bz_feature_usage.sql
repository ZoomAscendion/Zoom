-- Bronze Layer Feature Usage Model
-- Transforms raw feature usage data from RAW.FEATURE_USAGE to BRONZE.BZ_FEATURE_USAGE
-- Author: Data Engineering Team
-- Created: 2024-12-19

{{ config(
    materialized='table',
    post_hook="{{ audit_insert('BZ_FEATURE_USAGE', "(SELECT COUNT(*) FROM " ~ this ~ ")") }}"
) }}

-- CTE for data validation and cleansing
WITH source_data AS (
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
        SOURCE_SYSTEM,
        
        -- Data quality validation
        CASE 
            WHEN USAGE_ID IS NULL THEN 'INVALID'
            WHEN MEETING_ID IS NULL THEN 'INVALID'
            WHEN FEATURE_NAME IS NULL THEN 'INVALID'
            ELSE 'VALID'
        END AS data_quality_status
        
    FROM {{ source('raw', 'feature_usage') }}
),

-- CTE for final data selection with error handling
final_data AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM source_data
    WHERE data_quality_status = 'VALID'
)

SELECT * FROM final_data
