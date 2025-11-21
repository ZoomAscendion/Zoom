-- Bronze Layer Support Tickets Table
-- Description: Manages customer support requests and resolution tracking
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'support_tickets'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 0, 'STARTED')",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_SUPPORT_TICKETS' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS')"
) }}

WITH source_data AS (
    -- Select from raw source table with null filtering for primary key
    SELECT *
    FROM {{ source('raw', 'support_tickets') }}
    WHERE ticket_id IS NOT NULL
),

deduped_data AS (
    -- Apply deduplication based on primary key and latest timestamp
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY ticket_id 
                   ORDER BY update_timestamp DESC, load_timestamp DESC
               ) AS row_num
        FROM source_data
    )
    WHERE row_num = 1
)

-- Final select with bronze timestamp overwrite
SELECT
    ticket_id,
    user_id,
    ticket_type,
    resolution_status,
    open_date,
    CURRENT_TIMESTAMP() AS load_timestamp,
    CURRENT_TIMESTAMP() AS update_timestamp,
    source_system
FROM deduped_data
