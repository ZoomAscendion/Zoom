-- Bronze Layer Support Tickets Model
-- Description: Raw support ticket data from customer service systems
-- Author: Data Engineer
-- Created: 2024-12-19

{{ config(
    materialized='table',
    tags=['bronze', 'support_tickets'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'DBT_USER', 0, 'STARTED')",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'DBT_USER', 1, 'SUCCESS')"
) }}

-- Filter out NULL primary keys and apply deduplication
WITH source_data AS (
    SELECT *
    FROM {{ source('raw', 'support_tickets') }}
    WHERE ticket_id IS NOT NULL
),

-- Apply deduplication based on primary key and load timestamp
deduped_data AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ticket_id 
               ORDER BY load_timestamp DESC
           ) AS row_num
    FROM source_data
),

-- Final transformation with bronze timestamp overwrite
final AS (
    SELECT 
        ticket_id,
        user_id,
        COALESCE(ticket_type, 'general') AS ticket_type,
        COALESCE(resolution_status, 'open') AS resolution_status,
        open_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        COALESCE(source_system, 'unknown') AS source_system
    FROM deduped_data
    WHERE row_num = 1
)

SELECT * FROM final
