-- Bronze Layer Licenses Table
-- Description: Manages license assignments and entitlements
-- Source: RAW.LICENSES
-- Target: BRONZE.BZ_LICENSES
-- Transformation: 1-1 mapping with deduplication

{{ config(
    materialized='table',
    unique_key='license_id',
    pre_hook="
        {% if this.name != 'bz_data_audit' %}
            INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS)
            VALUES ('BZ_LICENSES', CURRENT_TIMESTAMP(), '{{ var(\"audit_user\") }}', 'STARTED')
        {% endif %}
    ",
    post_hook="
        {% if this.name != 'bz_data_audit' %}
            INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS)
            VALUES ('BZ_LICENSES', CURRENT_TIMESTAMP(), '{{ var(\"audit_user\") }}', 
                    DATEDIFF('seconds', 
                        (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_data_audit') }} WHERE SOURCE_TABLE = 'BZ_LICENSES' AND STATUS = 'STARTED'), 
                        CURRENT_TIMESTAMP()), 
                    'COMPLETED')
        {% endif %}
    "
) }}

-- Raw data extraction with deduplication
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
        ) as rn
    FROM {{ source('raw', 'licenses') }}
),

-- Apply data quality checks and transformations
cleaned_data AS (
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
    WHERE rn = 1  -- Keep only the latest record per license
        AND LICENSE_ID IS NOT NULL   -- Ensure primary key is not null
        AND LICENSE_TYPE IS NOT NULL -- Ensure license type is specified
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
FROM cleaned_data
