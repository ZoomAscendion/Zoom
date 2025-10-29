-- Bronze Layer Webinars Model
-- Transforms raw webinar data from RAW.WEBINARS to BRONZE.BZ_WEBINARS
-- Author: Data Engineering Team
-- Created: 2024-12-19

{{ config(
    materialized='table',
    post_hook="{{ audit_insert('BZ_WEBINARS', "(SELECT COUNT(*) FROM " ~ this ~ ")") }}"
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
        
        -- Data quality validation
        CASE 
            WHEN WEBINAR_ID IS NULL THEN 'INVALID'
            WHEN HOST_ID IS NULL THEN 'INVALID'
            WHEN WEBINAR_TOPIC IS NULL THEN 'INVALID'
            ELSE 'VALID'
        END AS data_quality_status
        
    FROM {{ source('raw', 'webinars') }}
),

-- CTE for final data selection with error handling
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
    WHERE data_quality_status = 'VALID'
)

SELECT * FROM final_data
