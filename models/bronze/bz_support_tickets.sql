-- Bronze Layer Support Tickets Table
-- Description: Transforms raw support ticket data into bronze layer with data quality checks and deduplication
-- Source: RAW.SUPPORT_TICKETS
-- Target: BRONZE.BZ_SUPPORT_TICKETS
-- Author: DBT Bronze Pipeline
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    post_hook="INSERT INTO {{ this.schema }}.bz_data_audit (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('bz_support_tickets', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 0, 'COMPLETED')"
) }}

WITH raw_support_tickets_filtered AS (
    -- Filter out records with NULL primary keys
    SELECT *
    FROM {{ source('raw_zoom', 'support_tickets') }}
    WHERE ticket_id IS NOT NULL
),

raw_support_tickets_deduplicated AS (
    -- Apply deduplication logic based on primary key and latest update timestamp
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ticket_id 
               ORDER BY COALESCE(update_timestamp, load_timestamp, CURRENT_TIMESTAMP()) DESC
           ) AS row_num
    FROM raw_support_tickets_filtered
),

raw_support_tickets_clean AS (
    -- Select only the most recent record for each ticket
    SELECT 
        ticket_id,
        user_id,
        ticket_type,
        resolution_status,
        open_date,
        source_system
    FROM raw_support_tickets_deduplicated
    WHERE row_num = 1
),

final_support_tickets AS (
    -- Apply Bronze layer transformations and add audit columns
    SELECT 
        -- Primary business columns (1-1 mapping from RAW)
        ticket_id,
        user_id,
        ticket_type,
        resolution_status,
        open_date,
        
        -- Bronze layer audit columns (overwrite with current timestamp)
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        
        -- Source system tracking
        COALESCE(source_system, 'UNKNOWN') AS source_system
    FROM raw_support_tickets_clean
)

SELECT *
FROM final_support_tickets
