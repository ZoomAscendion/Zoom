-- Bronze Layer Billing Events Table
-- Description: Tracks financial transactions and billing activities
-- Source: RAW.BILLING_EVENTS
-- Target: BRONZE.BZ_BILLING_EVENTS
-- Transformation: 1-1 mapping with deduplication

{{ config(
    materialized='table',
    unique_key='event_id',
    pre_hook="
        {% if this.name != 'bz_data_audit' %}
            INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS)
            VALUES ('BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), '{{ var(\"audit_user\") }}', 'STARTED')
        {% endif %}
    ",
    post_hook="
        {% if this.name != 'bz_data_audit' %}
            INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS)
            VALUES ('BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), '{{ var(\"audit_user\") }}', 
                    DATEDIFF('seconds', 
                        (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_data_audit') }} WHERE SOURCE_TABLE = 'BZ_BILLING_EVENTS' AND STATUS = 'STARTED'), 
                        CURRENT_TIMESTAMP()), 
                    'COMPLETED')
        {% endif %}
    "
) }}

-- Raw data extraction with deduplication
WITH source_data AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        EVENT_TYPE,
        AMOUNT,
        EVENT_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Add row number for deduplication based on latest update timestamp
        ROW_NUMBER() OVER (
            PARTITION BY EVENT_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) as rn
    FROM {{ source('raw', 'billing_events') }}
),

-- Apply data quality checks and transformations
cleaned_data AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        EVENT_TYPE,
        AMOUNT,
        EVENT_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM source_data
    WHERE rn = 1  -- Keep only the latest record per event
        AND EVENT_ID IS NOT NULL   -- Ensure primary key is not null
        AND EVENT_TYPE IS NOT NULL -- Ensure event type is specified
)

-- Final selection for Bronze layer
SELECT 
    EVENT_ID,
    USER_ID,
    EVENT_TYPE,
    AMOUNT,
    EVENT_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM cleaned_data
