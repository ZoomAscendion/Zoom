-- Bronze Layer Webinars Model
-- Transforms raw webinar data from RAW.WEBINARS to BRONZE.BZ_WEBINARS
-- Author: Data Engineering Team
-- Created: 2024-12-19

{{ config(materialized='table') }}

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
    SOURCE_SYSTEM
    
FROM {{ source('raw', 'webinars') }}
WHERE WEBINAR_ID IS NOT NULL
