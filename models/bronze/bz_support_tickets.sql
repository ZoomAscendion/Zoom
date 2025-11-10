-- Bronze Layer Support Tickets Table
-- Description: Manages customer support requests and resolution tracking
-- Author: DBT Data Engineer
-- Created: {{ run_started_at }}
-- Source: RAW.SUPPORT_TICKETS -> BRONZE.BZ_SUPPORT_TICKETS

{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) VALUES ('BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 0.0, 'STARTED')",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) VALUES ('BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', DATEDIFF('second', (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_data_audit') }} WHERE SOURCE_TABLE = 'BZ_SUPPORT_TICKETS' AND STATUS = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS')"
) }}

-- Raw data extraction with 1:1 mapping
WITH source_data AS (
    SELECT 
        -- Unique identifier for each support ticket
        TICKET_ID,
        
        -- Reference to user who created the ticket
        USER_ID,
        
        -- Type of support ticket
        TICKET_TYPE,
        
        -- Current status of ticket resolution
        RESOLUTION_STATUS,
        
        -- Date when ticket was opened
        OPEN_DATE,
        
        -- Timestamp when record was loaded into system
        LOAD_TIMESTAMP,
        
        -- Timestamp when record was last updated
        UPDATE_TIMESTAMP,
        
        -- Source system from which data originated
        SOURCE_SYSTEM
        
    FROM {{ source('raw', 'support_tickets') }}
),

-- Data validation and cleansing
validated_data AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        TICKET_TYPE,
        RESOLUTION_STATUS,
        OPEN_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM source_data
    -- Basic data quality checks
    WHERE TICKET_ID IS NOT NULL
      AND USER_ID IS NOT NULL
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
FROM validated_data
