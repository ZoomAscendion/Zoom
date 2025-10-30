-- Bronze Layer Webinars Model
-- Transforms raw webinar data from RAW.WEBINARS to Bronze layer
-- Author: DBT Data Engineer
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    pre_hook="
        {% if this.name != 'bz_audit_log' %}
        INSERT INTO {{ ref('bz_audit_log') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS)
        VALUES ('BZ_WEBINARS', CURRENT_TIMESTAMP(), 'DBT', 'STARTED')
        {% endif %}
    ",
    post_hook="
        {% if this.name != 'bz_audit_log' %}
        INSERT INTO {{ ref('bz_audit_log') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS, RECORD_COUNT)
        VALUES ('BZ_WEBINARS', CURRENT_TIMESTAMP(), 'DBT', 
                EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP() - (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_audit_log') }} WHERE SOURCE_TABLE = 'BZ_WEBINARS' AND STATUS = 'STARTED'))),
                'COMPLETED', (SELECT COUNT(*) FROM {{ this }}))
        {% endif %}
    "
) }}

-- CTE for raw data extraction
WITH raw_webinars AS (
    SELECT 
        -- Business columns from source
        WEBINAR_ID,
        HOST_ID,
        WEBINAR_TOPIC,
        START_TIME,
        END_TIME,
        REGISTRANTS,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
        
    FROM {{ source('raw', 'webinars') }}
),

-- CTE for data validation and cleansing
validated_webinars AS (
    SELECT 
        -- Apply data quality checks and preserve original structure
        COALESCE(WEBINAR_ID, 'UNKNOWN') as WEBINAR_ID,
        COALESCE(HOST_ID, 'UNKNOWN') as HOST_ID,
        COALESCE(WEBINAR_TOPIC, 'UNKNOWN') as WEBINAR_TOPIC,
        START_TIME,
        END_TIME,
        COALESCE(REGISTRANTS, 0) as REGISTRANTS,
        
        -- Metadata preservation
        COALESCE(LOAD_TIMESTAMP, CURRENT_TIMESTAMP()) as LOAD_TIMESTAMP,
        COALESCE(UPDATE_TIMESTAMP, CURRENT_TIMESTAMP()) as UPDATE_TIMESTAMP,
        COALESCE(SOURCE_SYSTEM, 'ZOOM_PLATFORM') as SOURCE_SYSTEM
        
    FROM raw_webinars
)

-- Final selection for Bronze layer
SELECT 
    WEBINAR_ID,
    HOST_ID,
    WEBINAR_TOPIC,
    START_TIME,
    END_TIME,
    REGISTRANTS,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM validated_webinars
