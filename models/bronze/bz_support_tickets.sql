-- Bronze Layer Support Tickets Table
-- Description: Manages customer support requests and resolution tracking
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='ticket_id',
    pre_hook="
        {% if this.name != 'bz_data_audit' %}
        INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status)
        VALUES ('BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 0.0, 'STARTED');
        {% endif %}
    ",
    post_hook="
        {% if this.name != 'bz_data_audit' %}
        INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status)
        VALUES ('BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 0.0, 'COMPLETED');
        {% endif %}
    "
) }}

-- Filter out NULL primary keys before any processing
WITH source_data AS (
    SELECT *
    FROM {{ source('raw_zoom', 'support_tickets') }}
    WHERE ticket_id IS NOT NULL
),

-- Apply deduplication based on primary key and latest update timestamp
deduped_data AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ticket_id 
               ORDER BY update_timestamp DESC, load_timestamp DESC
           ) as row_num
    FROM source_data
)

-- Final selection with 1-1 mapping from raw to bronze
SELECT 
    ticket_id,
    user_id,
    ticket_type,
    resolution_status,
    open_date,
    load_timestamp,
    update_timestamp,
    source_system
FROM deduped_data
WHERE row_num = 1
