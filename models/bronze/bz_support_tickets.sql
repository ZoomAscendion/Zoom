-- Bronze Layer Support Tickets Table
-- Description: Manages customer support requests and resolution tracking
-- Author: Data Engineering Team
-- Created: 2024-12-19

{{ config(
    materialized='table',
    tags=['bronze', 'support_tickets']
) }}

WITH source_data AS (
    -- Select from RAW layer with null filtering for primary key
    SELECT *
    FROM {{ source('raw', 'support_tickets') }}
    WHERE TICKET_ID IS NOT NULL
),

deduped_data AS (
    -- Apply deduplication based on primary key and latest timestamp
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY TICKET_ID 
               ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC
           ) AS row_num
    FROM source_data
)

-- Final selection with 1-1 mapping from RAW to Bronze
SELECT
    TICKET_ID,
    USER_ID,
    TICKET_TYPE,
    RESOLUTION_STATUS,
    OPEN_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM deduped_data
WHERE row_num = 1
