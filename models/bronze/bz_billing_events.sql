-- Bronze Pipeline Step 7: Transform raw billing events data to bronze layer
-- Description: 1-1 mapping from RAW.BILLING_EVENTS to BRONZE.BZ_BILLING_EVENTS with deduplication
-- Author: Data Engineering Team
-- Created: 2024-01-01

{{ config(
    materialized='table',
    tags=['bronze', 'billing_events']
) }}

-- Bronze Pipeline Step 7.1: Select and filter raw data excluding null primary keys
WITH raw_billing_events_filtered AS (
    SELECT 
        event_id,
        user_id,
        event_type,
        amount,
        event_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw_schema', 'billing_events') }}
    WHERE event_id IS NOT NULL  -- Filter out null primary keys
),

-- Bronze Pipeline Step 7.2: Apply deduplication logic based on primary key and latest timestamp
deduped_billing_events AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY event_id 
            ORDER BY COALESCE(update_timestamp, load_timestamp) DESC, load_timestamp DESC
        ) as rn
    FROM raw_billing_events_filtered
),

-- Bronze Pipeline Step 7.3: Select final deduplicated records
final_billing_events AS (
    SELECT 
        event_id,
        user_id,
        event_type,
        amount,
        event_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM deduped_billing_events
    WHERE rn = 1
)

SELECT * FROM final_billing_events
