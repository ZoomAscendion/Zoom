-- Bronze Layer Licenses Model
-- Author: DBT Pipeline Generator
-- Description: Transform raw licenses data to bronze layer with audit information
-- Source: RAW.LICENSES
-- Target: BRONZE.BZ_LICENSES

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
            'BZ_LICENSES', 
            CURRENT_TIMESTAMP(), 
            'STARTED', 
            'DBT_PIPELINE'
        WHERE NOT EXISTS (SELECT 1 FROM {{ ref('bz_audit_log') }} WHERE SOURCE_TABLE = 'BZ_LICENSES' AND STATUS = 'STARTED')
    ",
    post_hook="
        INSERT INTO {{ ref('bz_audit_log') }} (
            SOURCE_TABLE, 
            PROCESS_END_TIME, 
            STATUS, 
            CREATED_BY
        ) 
        SELECT 
            'BZ_LICENSES', 
            CURRENT_TIMESTAMP(), 
            'COMPLETED', 
            'DBT_PIPELINE'
        WHERE NOT EXISTS (SELECT 1 FROM {{ ref('bz_audit_log') }} WHERE SOURCE_TABLE = 'BZ_LICENSES' AND STATUS = 'COMPLETED')
    "
) }}

-- CTE for data validation and cleansing
WITH source_data AS (
    SELECT 
        -- Business columns from source (1:1 mapping)
        LICENSE_ID,
        LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        END_DATE,
        
        -- Metadata columns from source
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
        
    FROM {{ source('raw_schema', 'licenses') }}
    WHERE LICENSE_ID IS NOT NULL  -- Basic data quality check
),

-- CTE for data quality validation
validated_data AS (
    SELECT 
        *,
        -- Add row validation flags
        CASE 
            WHEN LICENSE_ID IS NULL THEN 'INVALID_LICENSE_ID'
            WHEN LICENSE_TYPE IS NULL THEN 'INVALID_LICENSE_TYPE'
            WHEN ASSIGNED_TO_USER_ID IS NULL THEN 'INVALID_USER_ID'
            ELSE 'VALID'
        END AS data_quality_status
    FROM source_data
)

-- Final SELECT with error handling
SELECT 
    -- Business columns (direct 1:1 mapping)
    LICENSE_ID,
    LICENSE_TYPE,
    ASSIGNED_TO_USER_ID,
    START_DATE,
    END_DATE,
    
    -- Metadata columns (direct 1:1 mapping)
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
    
FROM validated_data
WHERE data_quality_status = 'VALID'
