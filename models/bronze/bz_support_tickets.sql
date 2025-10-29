-- Bronze Layer Support Tickets Model
-- Transforms raw support ticket data from RAW.SUPPORT_TICKETS to BRONZE.BZ_SUPPORT_TICKETS
-- Author: Data Engineering Team
-- Created: 2024-12-19

{{ config(materialized='table') }}

SELECT 
    -- Business columns from source (1:1 mapping)
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
WHERE TICKET_ID IS NOT NULL
  AND USER_ID IS NOT NULL
  AND TICKET_TYPE IS NOT NULL
