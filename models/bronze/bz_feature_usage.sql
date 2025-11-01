-- Bronze Layer Feature Usage Model
-- Author: DBT Pipeline Generator
-- Description: Transform raw feature usage data to bronze layer with audit information
-- Source: RAW.FEATURE_USAGE
-- Target: BRONZE.BZ_FEATURE_USAGE

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
            'BZ_FEATURE_USAGE', 
            CURRENT_TIMESTAMP(), 
            'STARTED', 
            'DBT_PIPELINE'
        WHERE NOT EXISTS (SELECT 1 FROM {{ ref('bz_audit_log') }} WHERE SOURCE_TABLE = 'BZ_FEATURE_USAGE' AND STATUS = 'STARTED')
    ",
    post_hook="
        INSERT INTO {{ ref('bz_audit_log') }} (
            SOURCE_TABLE, 
            PROCESS_END_TIME, 
            STATUS, 
            CREATED_BY
        ) 
        SELECT 
            'BZ_FEATURE_USAGE', 
            CURRENT_TIMESTAMP(), 
            'COMPLETED', 
            'DBT_PIPELINE'
        WHERE NOT EXISTS (SELECT 1 FROM {{ ref('bz_audit_log') }} WHERE SOURCE_TABLE = 'BZ_FEATURE_USAGE' AND STATUS = 'COMPLETED')
    "
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
        
        -- Metadata columns from source
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
        
    FROM {{ source('raw_schema', 'feature_usage') }}
    WHERE USAGE_ID IS NOT NULL  -- Basic data quality check
),

-- CTE for data quality validation
validated_data AS (
    SELECT 
        *,
        -- Add row validation flags
        CASE 
            WHEN USAGE_ID IS NULL THEN 'INVALID_USAGE_ID'
            WHEN MEETING_ID IS NULL THEN 'INVALID_MEETING_ID'
            WHEN FEATURE_NAME IS NULL THEN 'INVALID_FEATURE_NAME'
            ELSE 'VALID'
        END AS data_quality_status
    FROM source_data
)

-- Final SELECT with error handling
SELECT 
    -- Business columns (direct 1:1 mapping)
    USAGE_ID,
    MEETING_ID,
    FEATURE_NAME,
    USAGE_COUNT,
    USAGE_DATE,
    
    -- Metadata columns (direct 1:1 mapping)
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
    
FROM validated_data
WHERE data_quality_status = 'VALID'
