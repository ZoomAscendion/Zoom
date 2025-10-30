-- Bronze Layer Licenses Model
-- Transforms raw license data from RAW.LICENSES to Bronze layer
-- Author: DBT Data Engineer
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    pre_hook="
        {% if this.name != 'bz_audit_log' %}
        INSERT INTO {{ ref('bz_audit_log') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS)
        VALUES ('BZ_LICENSES', CURRENT_TIMESTAMP(), 'DBT_PIPELINE', 'STARTED')
        {% endif %}
    ",
    post_hook="
        {% if this.name != 'bz_audit_log' %}
        INSERT INTO {{ ref('bz_audit_log') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS, RECORD_COUNT)
        VALUES ('BZ_LICENSES', CURRENT_TIMESTAMP(), 'DBT_PIPELINE', 
                EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP() - (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_audit_log') }} WHERE SOURCE_TABLE = 'BZ_LICENSES' AND STATUS = 'STARTED'))),
                'COMPLETED', (SELECT COUNT(*) FROM {{ this }}))
        {% endif %}
    "
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
