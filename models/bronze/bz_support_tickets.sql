-- Bronze Layer Support Tickets Table
-- Description: Raw support ticket data from customer service systems
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'DBT_USER', 0, 'STARTED')",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'DBT_USER', DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_SUPPORT_TICKETS' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS')"
) }}

-- CTE to select and filter raw data
WITH raw_support_tickets AS (
    SELECT 
        ticket_id,
        user_id,
        ticket_type,
        resolution_status,
        open_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw', 'support_tickets') }}
    WHERE ticket_id IS NOT NULL        -- Filter out NULL primary keys
      AND user_id IS NOT NULL          -- Filter out NULL user_id
      AND ticket_type IS NOT NULL      -- Filter out NULL ticket_type
      AND resolution_status IS NOT NULL -- Filter out NULL resolution_status
      AND open_date IS NOT NULL        -- Filter out NULL open_date
),

-- CTE for deduplication based on primary key
deduped_support_tickets AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY ticket_id ORDER BY load_timestamp DESC) as rn
    FROM raw_support_tickets
)

-- Final selection with Bronze timestamp overwrite
SELECT 
    ticket_id,
    user_id,
    ticket_type,
    resolution_status,
    open_date,
    CURRENT_TIMESTAMP() AS load_timestamp,    -- Overwrite with current DBT run time
    CURRENT_TIMESTAMP() AS update_timestamp,  -- Overwrite with current DBT run time
    source_system
FROM deduped_support_tickets
WHERE rn = 1  -- Keep only the most recent record per ticket_id
