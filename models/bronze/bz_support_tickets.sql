{{
  config(
    materialized='table',
    tags=['bronze', 'support_tickets'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'DBT_JOB', 0, 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="UPDATE {{ ref('bz_data_audit') }} SET processing_time = DATEDIFF('second', load_timestamp, CURRENT_TIMESTAMP()), status = 'SUCCESS' WHERE source_table = 'BZ_SUPPORT_TICKETS' AND status = 'STARTED' AND '{{ this.name }}' != 'bz_data_audit'"
  )
}}

-- Bronze layer transformation for SUPPORT_TICKETS table
-- Applies data cleaning, validation, and deduplication
-- Maps raw support ticket data to bronze layer with audit information

WITH source_data AS (
    SELECT *
    FROM {{ source('raw', 'support_tickets') }}
    WHERE ticket_id IS NOT NULL        -- Filter out records with null primary key
      AND user_id IS NOT NULL         -- Filter out records with null user_id
      AND ticket_type IS NOT NULL     -- Filter out records with null ticket_type
      AND resolution_status IS NOT NULL -- Filter out records with null resolution_status
      AND open_date IS NOT NULL       -- Filter out records with null open_date
),

-- Apply deduplication based on primary key, keeping the most recent record
deduped_data AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY ticket_id ORDER BY load_timestamp DESC) as rn
    FROM source_data
),

-- Final transformation with data quality enhancements
final_data AS (
    SELECT
        ticket_id,
        user_id,
        ticket_type,
        resolution_status,
        open_date,
        CURRENT_TIMESTAMP() AS load_timestamp,  -- Overwrite with current timestamp
        CURRENT_TIMESTAMP() AS update_timestamp, -- Overwrite with current timestamp
        source_system
    FROM deduped_data
    WHERE rn = 1  -- Keep only the most recent record per ticket_id
)

SELECT * FROM final_data
