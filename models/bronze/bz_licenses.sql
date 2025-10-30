-- Bronze Layer Licenses Model
-- Transforms raw license data from RAW.LICENSES to Bronze layer
-- Author: DBT Data Engineer
-- Created: {{ run_started_at }}

{{ config(
    materialized='table'
) }}

-- CTE for raw data extraction
WITH raw_licenses AS (
    SELECT 
        -- Business columns from source
        LICENSE_ID,
        LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        END_DATE,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
        
    FROM {{ source('raw', 'licenses') }}
),

-- CTE for data validation and cleansing
validated_licenses AS (
    SELECT 
        -- Apply data quality checks and preserve original structure
        COALESCE(LICENSE_ID, 'UNKNOWN') as LICENSE_ID,
        COALESCE(LICENSE_TYPE, 'UNKNOWN') as LICENSE_TYPE,
        COALESCE(ASSIGNED_TO_USER_ID, 'UNKNOWN') as ASSIGNED_TO_USER_ID,
        START_DATE,
        END_DATE,
        
        -- Metadata preservation
        COALESCE(LOAD_TIMESTAMP, CURRENT_TIMESTAMP()) as LOAD_TIMESTAMP,
        COALESCE(UPDATE_TIMESTAMP, CURRENT_TIMESTAMP()) as UPDATE_TIMESTAMP,
        COALESCE(SOURCE_SYSTEM, 'ZOOM_PLATFORM') as SOURCE_SYSTEM
        
    FROM raw_licenses
)

-- Final selection for Bronze layer
SELECT 
    LICENSE_ID,
    LICENSE_TYPE,
    ASSIGNED_TO_USER_ID,
    START_DATE,
    END_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM validated_licenses
