-- Bronze Layer Feature Usage Table
-- Description: Records usage of platform features during meetings
-- Source: RAW.FEATURE_USAGE
-- Target: BRONZE.BZ_FEATURE_USAGE
-- Transformation: 1-1 mapping with deduplication

{{ config(
    materialized='table',
    unique_key='usage_id',
    pre_hook="
        {% if this.name != 'bz_data_audit' %}
            INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS)
            VALUES ('BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), '{{ var(\"audit_user\") }}', 'STARTED')
        {% endif %}
    ",
    post_hook="
        {% if this.name != 'bz_data_audit' %}
            INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS)
            VALUES ('BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), '{{ var(\"audit_user\") }}', 
                    DATEDIFF('seconds', 
                        (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_data_audit') }} WHERE SOURCE_TABLE = 'BZ_FEATURE_USAGE' AND STATUS = 'STARTED'), 
                        CURRENT_TIMESTAMP()), 
                    'COMPLETED')
        {% endif %}
    "
) }}

-- Raw data extraction with deduplication
WITH source_data AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Add row number for deduplication based on latest update timestamp
        ROW_NUMBER() OVER (
            PARTITION BY USAGE_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) as rn
    FROM {{ source('raw', 'feature_usage') }}
),

-- Apply data quality checks and transformations
cleaned_data AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM source_data
    WHERE rn = 1  -- Keep only the latest record per usage
        AND USAGE_ID IS NOT NULL     -- Ensure primary key is not null
        AND FEATURE_NAME IS NOT NULL -- Ensure feature name is specified
)

-- Final selection for Bronze layer
SELECT 
    USAGE_ID,
    MEETING_ID,
    FEATURE_NAME,
    USAGE_COUNT,
    USAGE_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM cleaned_data
