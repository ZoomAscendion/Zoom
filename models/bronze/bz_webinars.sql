-- Bronze Layer Webinars Model
-- Author: DBT Pipeline Generator
-- Description: Transform raw webinars data to bronze layer with audit information
-- Source: RAW.WEBINARS
-- Target: BRONZE.BZ_WEBINARS

{{ config(
    materialized='table',
    pre_hook="
        INSERT INTO {{ ref('bz_audit_log') }} (
            SOURCE_TABLE, 
            PROCESS_START_TIME, 
            STATUS, 
            CREATED_BY
        ) 
        SELECT 
            'BZ_WEBINARS', 
            CURRENT_TIMESTAMP(), 
            'STARTED', 
            'DBT_PIPELINE'
        WHERE NOT EXISTS (SELECT 1 FROM {{ ref('bz_audit_log') }} WHERE SOURCE_TABLE = 'BZ_WEBINARS' AND STATUS = 'STARTED')
    ",
    post_hook="
        INSERT INTO {{ ref('bz_audit_log') }} (
            SOURCE_TABLE, 
            PROCESS_END_TIME, 
            STATUS, 
            CREATED_BY
        ) 
        SELECT 
            'BZ_WEBINARS', 
            CURRENT_TIMESTAMP(), 
            'COMPLETED', 
            'DBT_PIPELINE'
        WHERE NOT EXISTS (SELECT 1 FROM {{ ref('bz_audit_log') }} WHERE SOURCE_TABLE = 'BZ_WEBINARS' AND STATUS = 'COMPLETED')
    "
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
        
        -- Metadata columns from source
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
        
    FROM {{ source('raw_schema', 'webinars') }}
    WHERE WEBINAR_ID IS NOT NULL  -- Basic data quality check
),

-- CTE for data quality validation
validated_data AS (
    SELECT 
        *,
        -- Add row validation flags
        CASE 
            WHEN WEBINAR_ID IS NULL THEN 'INVALID_WEBINAR_ID'
            WHEN HOST_ID IS NULL THEN 'INVALID_HOST_ID'
            WHEN WEBINAR_TOPIC IS NULL THEN 'INVALID_WEBINAR_TOPIC'
            ELSE 'VALID'
        END AS data_quality_status
    FROM source_data
)

-- Final SELECT with error handling
SELECT 
    -- Business columns (direct 1:1 mapping)
    WEBINAR_ID,
    HOST_ID,
    WEBINAR_TOPIC,
    START_TIME,
    END_TIME,
    REGISTRANTS,
    
    -- Metadata columns (direct 1:1 mapping)
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
    
FROM validated_data
WHERE data_quality_status = 'VALID'
