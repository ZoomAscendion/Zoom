-- Bronze Layer Support Tickets Model
-- Description: Raw customer support requests and resolution tracking from source systems
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'support_tickets']
) }}

-- Raw data selection with primary key filtering
WITH raw_support_tickets AS (
    SELECT *
    FROM {{ source('raw_schema', 'support_tickets') }}
    WHERE ticket_id IS NOT NULL  -- Filter out records with null primary key
),

-- Deduplication logic based on primary key and load timestamp
deduped_support_tickets AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ticket_id 
               ORDER BY load_timestamp DESC, update_timestamp DESC NULLS LAST
           ) AS row_num
    FROM raw_support_tickets
),

-- Final transformation with 1-1 mapping
final_support_tickets AS (
    SELECT 
        ticket_id,
        user_id,
        ticket_type,
        resolution_status,
        open_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM deduped_support_tickets
    WHERE row_num = 1
)

SELECT * FROM final_support_tickets
