-- Bronze Layer Support Tickets Model
-- Description: Transforms raw support tickets data to bronze layer with data quality checks
-- Source: RAW.SUPPORT_TICKETS
-- Target: BRONZE.bz_support_tickets
-- Author: DBT Data Engineer
-- Created: {{ run_started_at }}

{{ config(
    materialized='table'
) }}

WITH raw_support_tickets AS (
    SELECT 
        USER_ID,
        TICKET_TYPE,
        RESOLUTION_STATUS,
        OPEN_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw', 'SUPPORT_TICKETS') }}
),

-- Data quality and cleansing transformations
cleansed_support_tickets AS (
    SELECT 
        -- 1-1 mapping from raw to bronze as per mapping specification
        TRIM(USER_ID) as user_id,
        TRIM(UPPER(TICKET_TYPE)) as ticket_type,
        TRIM(UPPER(RESOLUTION_STATUS)) as resolution_status,
        OPEN_DATE as open_date,
        LOAD_TIMESTAMP as load_timestamp,
        COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) as update_timestamp,
        TRIM(UPPER(SOURCE_SYSTEM)) as source_system,
        
        -- Audit fields for bronze layer
        CURRENT_TIMESTAMP() as bronze_created_at,
        'SUCCESS' as process_status
        
    FROM raw_support_tickets
    WHERE USER_ID IS NOT NULL
      AND TICKET_TYPE IS NOT NULL
      AND RESOLUTION_STATUS IS NOT NULL
      AND OPEN_DATE IS NOT NULL
      AND LOAD_TIMESTAMP IS NOT NULL
      AND SOURCE_SYSTEM IS NOT NULL
)

-- Final select for bronze layer
SELECT 
    user_id,
    ticket_type,
    resolution_status,
    open_date,
    load_timestamp,
    update_timestamp,
    source_system
FROM cleansed_support_tickets
