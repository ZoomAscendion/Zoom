-- Bronze Layer Support Tickets Model
-- Description: Transforms raw support ticket data into bronze layer with audit capabilities
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'support_tickets']
) }}

-- CTE to select and filter raw data
WITH raw_support_tickets AS (
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
    WHERE TICKET_ID IS NOT NULL  -- Filter out records with null primary key
),

-- CTE for deduplication based on primary key and latest update timestamp
deduped_support_tickets AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY TICKET_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) AS row_num
    FROM raw_support_tickets
)

-- Final selection with 1-1 mapping from raw to bronze
SELECT
    TICKET_ID,
    USER_ID,
    TICKET_TYPE,
    RESOLUTION_STATUS,
    OPEN_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM deduped_support_tickets
WHERE row_num = 1  -- Keep only the most recent record for each ticket
