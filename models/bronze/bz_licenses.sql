-- Bronze Layer Licenses Table
-- Description: Raw license assignments and entitlements from source systems
-- Source: RAW.LICENSES
-- Target: BRONZE.BZ_LICENSES
-- Transformation: 1-1 mapping with deduplication

{{ config(
    materialized='table',
    tags=['bronze', 'licenses'],
    pre_hook="
        {% if not (this.name == 'bz_data_audit') %}
        INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS)
        VALUES ('BZ_LICENSES', CURRENT_TIMESTAMP(), CURRENT_USER(), 'STARTED')
        {% endif %}
    ",
    post_hook="
        {% if not (this.name == 'bz_data_audit') %}
        INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS)
        VALUES ('BZ_LICENSES', CURRENT_TIMESTAMP(), CURRENT_USER(), 'COMPLETED')
        {% endif %}
    "
) }}

-- CTE for data extraction and deduplication
WITH source_data AS (
    SELECT 
        LICENSE_ID,
        LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Add row number for deduplication based on latest update timestamp
        ROW_NUMBER() OVER (
            PARTITION BY LICENSE_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) AS rn
    FROM {{ source('raw_schema', 'licenses') }}
),

-- Final deduplication
deduped_data AS (
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
    WHERE rn = 1
)

-- Final select with data quality checks
SELECT 
    LICENSE_ID,
    LICENSE_TYPE,
    ASSIGNED_TO_USER_ID,
    START_DATE,
    END_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM deduped_data
WHERE LICENSE_ID IS NOT NULL  -- Basic data quality check
