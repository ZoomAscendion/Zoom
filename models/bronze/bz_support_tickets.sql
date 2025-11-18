-- Bronze Layer Support Tickets Table
-- Description: Manages customer support requests and resolution tracking
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'support_tickets'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'DBT_SYSTEM', 0, 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'DBT_SYSTEM', DATEDIFF('second', (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_data_audit') }} WHERE SOURCE_TABLE = 'BZ_SUPPORT_TICKETS' AND STATUS = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS' WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

WITH source_data AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        TICKET_TYPE,
        RESOLUTION_STATUS,
        OPEN_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw', 'support_tickets') }}
    WHERE TICKET_ID IS NOT NULL  -- Filter out NULL primary keys
      AND USER_ID IS NOT NULL    -- Filter out NULL foreign keys
),

-- Apply deduplication based on primary key and latest timestamp
deduped_data AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY TICKET_ID 
            ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC
        ) AS row_num
    FROM source_data
)

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
    
    -- Timestamp when record was loaded into Bronze layer
    LOAD_TIMESTAMP,
    
    -- Timestamp when record was last updated
    UPDATE_TIMESTAMP,
    
    -- Source system from which data originated
    SOURCE_SYSTEM
    
FROM deduped_data
WHERE row_num = 1
