-- Bronze Pipeline Step 6: Transform raw support tickets data to bronze layer
-- Description: 1-1 mapping from RAW.SUPPORT_TICKETS to BRONZE.BZ_SUPPORT_TICKETS with deduplication
-- Author: Data Engineering Team
-- Created: 2024-01-01

{{ config(
    materialized='table',
    tags=['bronze', 'support_tickets']
) }}

-- Bronze Pipeline Step 6.1: Select and filter raw data excluding null primary keys
WITH raw_support_tickets_filtered AS (
    SELECT 
        ticket_id,
        user_id,
        ticket_type,
        resolution_status,
        open_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw_layer', 'support_tickets') }}
    WHERE ticket_id IS NOT NULL  -- Filter out null primary keys
),

-- Bronze Pipeline Step 6.2: Apply deduplication logic based on primary key and latest timestamp
deduped_support_tickets AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ticket_id 
            ORDER BY COALESCE(update_timestamp, load_timestamp) DESC, load_timestamp DESC
        ) as rn
    FROM raw_support_tickets_filtered
),

-- Bronze Pipeline Step 6.3: Select final deduplicated records
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
    WHERE rn = 1
)

SELECT * FROM final_support_tickets
