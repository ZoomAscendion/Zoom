-- Bronze Layer Support Tickets Model
-- Transforms raw support ticket data from RAW.SUPPORT_TICKETS to Bronze layer
-- Author: DBT Data Engineer
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    pre_hook="
        {% if this.name != 'bz_audit_log' %}
        INSERT INTO {{ ref('bz_audit_log') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS)
        VALUES ('BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'DBT', 'STARTED')
        {% endif %}
    ",
    post_hook="
        {% if this.name != 'bz_audit_log' %}
        INSERT INTO {{ ref('bz_audit_log') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS, RECORD_COUNT)
        VALUES ('BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'DBT', 
                EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP() - (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_audit_log') }} WHERE SOURCE_TABLE = 'BZ_SUPPORT_TICKETS' AND STATUS = 'STARTED'))),
                'COMPLETED', (SELECT COUNT(*) FROM {{ this }}))
        {% endif %}
    "
) }}

-- CTE for raw data extraction
WITH raw_support_tickets AS (
    SELECT 
        -- Business columns from source
        TICKET_ID,
        USER_ID,
        TICKET_TYPE,
        RESOLUTION_STATUS,
        OPEN_DATE,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
        
    FROM {{ source('raw', 'support_tickets') }}
),

-- CTE for data validation and cleansing
validated_support_tickets AS (
    SELECT 
        -- Apply data quality checks and preserve original structure
        COALESCE(TICKET_ID, 'UNKNOWN') as TICKET_ID,
        COALESCE(USER_ID, 'UNKNOWN') as USER_ID,
        COALESCE(TICKET_TYPE, 'UNKNOWN') as TICKET_TYPE,
        COALESCE(RESOLUTION_STATUS, 'UNKNOWN') as RESOLUTION_STATUS,
        OPEN_DATE,
        
        -- Metadata preservation
        COALESCE(LOAD_TIMESTAMP, CURRENT_TIMESTAMP()) as LOAD_TIMESTAMP,
        COALESCE(UPDATE_TIMESTAMP, CURRENT_TIMESTAMP()) as UPDATE_TIMESTAMP,
        COALESCE(SOURCE_SYSTEM, 'ZOOM_PLATFORM') as SOURCE_SYSTEM
        
    FROM raw_support_tickets
)

-- Final selection for Bronze layer
SELECT 
    TICKET_ID,
    USER_ID,
    TICKET_TYPE,
    RESOLUTION_STATUS,
    OPEN_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM validated_support_tickets
