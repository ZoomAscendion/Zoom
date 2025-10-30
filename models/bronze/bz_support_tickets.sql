-- Bronze Layer Support Tickets Model
-- Transforms raw support ticket data from RAW.SUPPORT_TICKETS to Bronze layer
-- Author: DBT Data Engineer
-- Created: {{ run_started_at }}

{{ config(
    materialized='table'
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
