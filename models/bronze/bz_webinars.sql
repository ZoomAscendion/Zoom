-- Bronze Layer Webinars Model
-- Transforms raw webinar data from RAW.WEBINARS to BRONZE.BZ_WEBINARS
-- Author: Data Engineering Team
-- Created: 2024-12-19

{{ config(
    materialized='table'
) }}

-- CTE for data validation and cleansing
WITH source_data AS (
    SELECT 
        -- Business columns from source (1:1 mapping)
        WEBINAR_ID,
        HOST_ID,
        WEBINAR_TOPIC,
        START_TIME,
        END_TIME,
        REGISTRANTS,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data quality flags
        CASE 
            WHEN WEBINAR_ID IS NULL THEN 'MISSING_WEBINAR_ID'
            WHEN HOST_ID IS NULL THEN 'MISSING_HOST_ID'
            WHEN WEBINAR_TOPIC IS NULL THEN 'MISSING_WEBINAR_TOPIC'
            ELSE 'VALID'
        END AS data_quality_flag
        
    FROM {{ source('raw', 'webinars') }}
),

-- CTE for final data selection
final_data AS (
    SELECT 
        WEBINAR_ID,
        HOST_ID,
        WEBINAR_TOPIC,
        START_TIME,
        END_TIME,
        REGISTRANTS,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM source_data
    WHERE data_quality_flag = 'VALID'
)

SELECT * FROM final_data
