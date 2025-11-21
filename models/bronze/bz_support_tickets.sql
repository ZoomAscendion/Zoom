-- Bronze Layer Support Tickets Table
-- Description: Manages customer support requests and resolution tracking
-- Source: RAW.SUPPORT_TICKETS
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='ticket_id',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 0, 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_SUPPORT_TICKETS' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS' WHERE '{{ this.name }}' != 'bz_data_audit'"
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
    FROM {{ source('raw_layer', 'support_tickets') }}
    WHERE ticket_id IS NOT NULL  -- Filter out records with null primary keys
      AND user_id IS NOT NULL   -- Filter out records with null user_id
),

-- CTE for data cleaning and validation
cleaned_support_tickets AS (
    SELECT 
        ticket_id,
        user_id,
        ticket_type,
        resolution_status,
        open_date,
        load_timestamp,
        update_timestamp,
        source_system,
        ROW_NUMBER() OVER (PARTITION BY ticket_id ORDER BY load_timestamp DESC) AS row_num
    FROM raw_support_tickets
),

-- CTE for deduplication
deduped_support_tickets AS (
    SELECT 
        ticket_id,
        user_id,
        ticket_type,
        resolution_status,
        open_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM cleaned_support_tickets
    WHERE row_num = 1  -- Keep only the latest record for each ticket_id
)

-- Final SELECT with Bronze timestamp overwrite
SELECT 
    ticket_id::VARCHAR(16777216) AS ticket_id,
    user_id::VARCHAR(16777216) AS user_id,
    ticket_type::VARCHAR(16777216) AS ticket_type,
    resolution_status::VARCHAR(16777216) AS resolution_status,
    open_date::DATE AS open_date,
    CURRENT_TIMESTAMP() AS load_timestamp,
    CURRENT_TIMESTAMP() AS update_timestamp,
    source_system::VARCHAR(16777216) AS source_system
FROM deduped_support_tickets
