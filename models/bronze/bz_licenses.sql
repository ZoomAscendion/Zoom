-- =====================================================
-- Bronze Layer Licenses Model
-- =====================================================
-- Description: Raw license data from source system with 1:1 mapping
-- Source: RAW.LICENSES
-- Target: BRONZE.BZ_LICENSES
-- =====================================================

{{ config(
    materialized='table',
    pre_hook="""
        INSERT INTO {{ ref('bz_audit_log') }} (RECORD_ID, SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS)
        SELECT 
            COALESCE((SELECT MAX(RECORD_ID) FROM {{ ref('bz_audit_log') }}), 0) + 1,
            'BZ_LICENSES', 
            CURRENT_TIMESTAMP(), 
            'DBT_PROCESS', 
            0, 
            'STARTED'
    """,
    post_hook="""
        INSERT INTO {{ ref('bz_audit_log') }} (RECORD_ID, SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS)
        SELECT 
            COALESCE((SELECT MAX(RECORD_ID) FROM {{ ref('bz_audit_log') }}), 0) + 1,
            'BZ_LICENSES', 
            CURRENT_TIMESTAMP(), 
            'DBT_PROCESS', 
            30, 
            'COMPLETED'
    """
) }}

-- Raw data extraction with basic error handling
WITH source_data AS (
    SELECT 
        -- Primary license information (1:1 mapping from source)
        LICENSE_ID,
        LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        END_DATE,
        
        -- Metadata columns (1:1 mapping from source)
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
        
    FROM {{ source('raw', 'licenses') }}
),

-- Data validation and cleansing
validated_data AS (
    SELECT 
        -- Convert all VARCHAR fields to STRING for consistency
        CAST(LICENSE_ID AS STRING) AS LICENSE_ID,
        CAST(LICENSE_TYPE AS STRING) AS LICENSE_TYPE,
        CAST(ASSIGNED_TO_USER_ID AS STRING) AS ASSIGNED_TO_USER_ID,
        
        -- Preserve date values
        START_DATE,
        END_DATE,
        
        -- Metadata preservation
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        CAST(SOURCE_SYSTEM AS STRING) AS SOURCE_SYSTEM
        
    FROM source_data
    -- Include all records for bronze layer (no filtering)
)

-- Final selection for bronze layer
SELECT 
    LICENSE_ID,
    LICENSE_TYPE,
    ASSIGNED_TO_USER_ID,
    START_DATE,
    END_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM validated_data
