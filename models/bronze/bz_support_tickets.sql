-- Bronze Layer Support Tickets Table
-- Description: Manages customer support requests and resolution tracking
-- Author: DBT Data Engineer
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='ticket_id',
    pre_hook="
        {% if this.name != 'bz_data_audit' %}
        INSERT INTO {{ ref('bz_data_audit') }} 
        (source_table, load_timestamp, processed_by, processing_time, status)
        VALUES ('BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 0, 'STARTED')
        {% endif %}
    ",
    post_hook="
        {% if this.name != 'bz_data_audit' %}
        INSERT INTO {{ ref('bz_data_audit') }} 
        (source_table, load_timestamp, processed_by, processing_time, status)
        VALUES ('BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 
                DATEDIFF('second', 
                    (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_SUPPORT_TICKETS' AND status = 'STARTED'), 
                    CURRENT_TIMESTAMP()), 
                'SUCCESS')
        {% endif %}
    "
) }}

WITH source_data AS (
    -- Select from raw support_tickets table with null filtering for primary key
    SELECT 
        ticket_id,
        user_id,
        ticket_type,
        resolution_status,
        open_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw', 'support_tickets') }}
    WHERE ticket_id IS NOT NULL  -- Filter out null primary keys
),

deduped_data AS (
    -- Apply deduplication based on primary key and latest update timestamp
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY ticket_id 
                   ORDER BY update_timestamp DESC, load_timestamp DESC
               ) as rn
        FROM source_data
    ) ranked
    WHERE rn = 1
)

-- Final select with 1-1 mapping from raw to bronze
SELECT 
    ticket_id::VARCHAR(16777216) as ticket_id,
    user_id::VARCHAR(16777216) as user_id,
    ticket_type::VARCHAR(16777216) as ticket_type,
    resolution_status::VARCHAR(16777216) as resolution_status,
    open_date::DATE as open_date,
    load_timestamp::TIMESTAMP_NTZ(9) as load_timestamp,
    update_timestamp::TIMESTAMP_NTZ(9) as update_timestamp,
    source_system::VARCHAR(16777216) as source_system
FROM deduped_data
