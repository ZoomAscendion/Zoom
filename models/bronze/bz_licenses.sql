-- Bronze Layer Licenses Model
-- Description: Transforms raw licenses data to bronze layer with data quality checks
-- Source: RAW.LICENSES
-- Target: BRONZE.bz_licenses
-- Author: DBT Data Engineer

{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('bz_audit_log') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'bz_licenses', CURRENT_TIMESTAMP(), 'DBT', 0, 'STARTED' WHERE '{{ this.name }}' != 'bz_audit_log'",
    post_hook="INSERT INTO {{ ref('bz_audit_log') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'bz_licenses', CURRENT_TIMESTAMP(), 'DBT', 1, 'COMPLETED' WHERE '{{ this.name }}' != 'bz_audit_log'"
) }}

WITH raw_licenses AS (
    SELECT 
        LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw', 'LICENSES') }}
),

-- Data quality and cleansing transformations
cleansed_licenses AS (
    SELECT 
        -- 1-1 mapping from raw to bronze as per mapping specification
        TRIM(UPPER(LICENSE_TYPE))::STRING as license_type,
        TRIM(ASSIGNED_TO_USER_ID)::STRING as assigned_to_user_id,
        START_DATE::DATE as start_date,
        END_DATE::DATE as end_date,
        LOAD_TIMESTAMP::TIMESTAMP_NTZ as load_timestamp,
        COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP)::TIMESTAMP_NTZ as update_timestamp,
        TRIM(UPPER(SOURCE_SYSTEM))::STRING as source_system
        
    FROM raw_licenses
    WHERE LICENSE_TYPE IS NOT NULL
      AND START_DATE IS NOT NULL
      AND END_DATE IS NOT NULL
      AND LOAD_TIMESTAMP IS NOT NULL
      AND SOURCE_SYSTEM IS NOT NULL
      AND START_DATE <= END_DATE  -- Business rule validation
)

-- Final select for bronze layer
SELECT 
    license_type,
    assigned_to_user_id,
    start_date,
    end_date,
    load_timestamp,
    update_timestamp,
    source_system
FROM cleansed_licenses
