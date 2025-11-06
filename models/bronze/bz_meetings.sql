-- =====================================================
-- Bronze Layer Meetings Model
-- =====================================================
-- Description: Raw meeting data from source system with 1:1 mapping
-- Source: RAW.MEETINGS
-- Target: BRONZE.BZ_MEETINGS
-- =====================================================

{{ config(
    materialized='table'
) }}

-- Raw data extraction with basic error handling
WITH source_data AS (
    SELECT 
        -- Primary meeting information (1:1 mapping from source)
        MEETING_ID,
        HOST_ID,
        MEETING_TOPIC,
        START_TIME,
        END_TIME,
        DURATION_MINUTES,
        
        -- Metadata columns (1:1 mapping from source)
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data quality indicators
        CASE 
            WHEN MEETING_ID IS NULL THEN 'MISSING_MEETING_ID'
            WHEN HOST_ID IS NULL THEN 'MISSING_HOST_ID'
            WHEN START_TIME IS NULL THEN 'MISSING_START_TIME'
            ELSE 'VALID'
        END AS data_quality_flag
        
    FROM {{ source('raw', 'meetings') }}
),

-- Data validation and cleansing
validated_data AS (
    SELECT 
        -- Convert all VARCHAR fields to STRING for consistency
        CAST(MEETING_ID AS STRING) AS MEETING_ID,
        CAST(HOST_ID AS STRING) AS HOST_ID,
        CAST(MEETING_TOPIC AS STRING) AS MEETING_TOPIC,
        
        -- Preserve original timestamps and numeric values
        START_TIME,
        END_TIME,
        DURATION_MINUTES,
        
        -- Metadata preservation
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        CAST(SOURCE_SYSTEM AS STRING) AS SOURCE_SYSTEM
        
    FROM source_data
    -- Include all records for bronze layer (no filtering)
)

-- Final selection for bronze layer
SELECT 
    MEETING_ID,
    HOST_ID,
    MEETING_TOPIC,
    START_TIME,
    END_TIME,
    DURATION_MINUTES,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM validated_data
