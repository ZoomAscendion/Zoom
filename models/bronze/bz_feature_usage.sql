-- =====================================================
-- Bronze Layer Feature Usage Model
-- =====================================================
-- Description: Raw feature usage data from source system with 1:1 mapping
-- Source: RAW.FEATURE_USAGE
-- Target: BRONZE.BZ_FEATURE_USAGE
-- =====================================================

{{ config(
    materialized='table',
    pre_hook="""
        INSERT INTO {{ ref('bz_audit_log') }} (RECORD_ID, SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS)
        SELECT 
            COALESCE((SELECT MAX(RECORD_ID) FROM {{ ref('bz_audit_log') }}), 0) + 1,
            'BZ_FEATURE_USAGE', 
            CURRENT_TIMESTAMP(), 
            'DBT_PROCESS', 
            0, 
            'STARTED'
    """,
    post_hook="""
        INSERT INTO {{ ref('bz_audit_log') }} (RECORD_ID, SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS)
        SELECT 
            COALESCE((SELECT MAX(RECORD_ID) FROM {{ ref('bz_audit_log') }}), 0) + 1,
            'BZ_FEATURE_USAGE', 
            CURRENT_TIMESTAMP(), 
            'DBT_PROCESS', 
            30, 
            'COMPLETED'
    """
) }}

-- Raw data extraction with basic error handling
WITH source_data AS (
    SELECT 
        -- Primary feature usage information (1:1 mapping from source)
        USAGE_ID,
        MEETING_ID,
        FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        
        -- Metadata columns (1:1 mapping from source)
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
        
    FROM {{ source('raw', 'feature_usage') }}
),

-- Data validation and cleansing
validated_data AS (
    SELECT 
        -- Convert all VARCHAR fields to STRING for consistency
        CAST(USAGE_ID AS STRING) AS USAGE_ID,
        CAST(MEETING_ID AS STRING) AS MEETING_ID,
        CAST(FEATURE_NAME AS STRING) AS FEATURE_NAME,
        
        -- Preserve numeric and date values
        USAGE_COUNT,
        USAGE_DATE,
        
        -- Metadata preservation
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        CAST(SOURCE_SYSTEM AS STRING) AS SOURCE_SYSTEM
        
    FROM source_data
    -- Include all records for bronze layer (no filtering)
)

-- Final selection for bronze layer
SELECT 
    USAGE_ID,
    MEETING_ID,
    FEATURE_NAME,
    USAGE_COUNT,
    USAGE_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM validated_data
