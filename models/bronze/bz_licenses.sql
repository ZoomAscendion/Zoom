-- Bronze Layer Licenses Table
-- Description: Manages license assignments and entitlements
-- Author: DBT Data Engineer
-- Created: {{ run_started_at }}
-- Source: RAW.LICENSES -> BRONZE.BZ_LICENSES

{{ config(
    materialized='table',
    pre_hook="{% if this.name != 'bz_data_audit' %}INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) VALUES ('BZ_LICENSES', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 0.0, 'STARTED'){% endif %}",
    post_hook="{% if this.name != 'bz_data_audit' %}INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) VALUES ('BZ_LICENSES', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 1.0, 'SUCCESS'){% endif %}"
) }}

-- Raw data extraction with 1:1 mapping
WITH source_data AS (
    SELECT 
        -- Unique identifier for each license
        LICENSE_ID,
        
        -- Type of license
        LICENSE_TYPE,
        
        -- User ID to whom license is assigned
        ASSIGNED_TO_USER_ID,
        
        -- License validity start date
        START_DATE,
        
        -- License validity end date
        END_DATE,
        
        -- Timestamp when record was loaded into system
        LOAD_TIMESTAMP,
        
        -- Timestamp when record was last updated
        UPDATE_TIMESTAMP,
        
        -- Source system from which data originated
        SOURCE_SYSTEM
        
    FROM {{ source('raw', 'licenses') }}
),

-- Data validation and cleansing
validated_data AS (
    SELECT 
        LICENSE_ID,
        LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM source_data
    -- Basic data quality checks
    WHERE LICENSE_ID IS NOT NULL
      AND LICENSE_TYPE IS NOT NULL
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
FROM validated_data
