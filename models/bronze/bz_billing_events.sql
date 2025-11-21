-- Bronze Layer Billing Events Table
-- Description: Transforms raw billing event data into bronze layer with data quality checks and deduplication
-- Source: RAW.BILLING_EVENTS
-- Target: BRONZE.BZ_BILLING_EVENTS
-- Author: DBT Bronze Pipeline
-- Created: {{ run_started_at }}

{{ config(
    materialized='table'
) }}

WITH raw_billing_events_filtered AS (
    -- Filter out records with NULL primary keys
    SELECT *
    FROM {{ source('raw_zoom', 'billing_events') }}
    WHERE event_id IS NOT NULL
),

raw_billing_events_deduplicated AS (
    -- Apply deduplication logic based on primary key and latest update timestamp
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY event_id 
               ORDER BY update_timestamp DESC, load_timestamp DESC
           ) AS row_num
    FROM raw_billing_events_filtered
),

raw_billing_events_clean AS (
    -- Select only the most recent record for each billing event
    SELECT 
        event_id,
        user_id,
        event_type,
        amount,
        event_date,
        source_system
    FROM raw_billing_events_deduplicated
    WHERE row_num = 1
),

final_billing_events AS (
    -- Apply Bronze layer transformations and add audit columns
    SELECT 
        -- Primary business columns (1-1 mapping from RAW)
        event_id,
        user_id,
        event_type,
        amount,
        event_date,
        
        -- Bronze layer audit columns (overwrite with current timestamp)
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        
        -- Source system tracking
        COALESCE(source_system, 'UNKNOWN') AS source_system
    FROM raw_billing_events_clean
)

SELECT *
FROM final_billing_events
