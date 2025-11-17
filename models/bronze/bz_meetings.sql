-- Bronze Layer Meetings Table
-- Description: Stores meeting information and session details
-- Source: RAW.MEETINGS
-- Target: BRONZE.BZ_MEETINGS
-- Transformation: 1-1 mapping with deduplication

{{ config(
    materialized='table',
    unique_key='meeting_id',
    pre_hook="
        {% if this.name != 'bz_data_audit' %}
            INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS)
            VALUES ('BZ_MEETINGS', CURRENT_TIMESTAMP(), '{{ var(\"audit_user\") }}', 'STARTED')
        {% endif %}
    ",
    post_hook="
        {% if this.name != 'bz_data_audit' %}
            INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS)
            VALUES ('BZ_MEETINGS', CURRENT_TIMESTAMP(), '{{ var(\"audit_user\") }}', 
                    DATEDIFF('seconds', 
                        (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_data_audit') }} WHERE SOURCE_TABLE = 'BZ_MEETINGS' AND STATUS = 'STARTED'), 
                        CURRENT_TIMESTAMP()), 
                    'COMPLETED')
        {% endif %}
    "
) }}

-- Raw data extraction with deduplication
WITH source_data AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        MEETING_TOPIC,
        START_TIME,
        END_TIME,
        DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Add row number for deduplication based on latest update timestamp
        ROW_NUMBER() OVER (
            PARTITION BY MEETING_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) as rn
    FROM {{ source('raw', 'meetings') }}
),

-- Apply data quality checks and transformations
cleaned_data AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        MEETING_TOPIC,
        START_TIME,
        END_TIME,
        DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM source_data
    WHERE rn = 1  -- Keep only the latest record per meeting
        AND MEETING_ID IS NOT NULL  -- Ensure primary key is not null
        AND HOST_ID IS NOT NULL     -- Ensure host is specified
)

-- Final selection for Bronze layer
SELECT 
    MEETING_ID,
    HOST_ID,
    MEETING_TOPIC,
    START_TIME,
    END_TIME,
    DURATION_MINUTES,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM cleaned_data
