-- Bronze Layer Support Tickets Table
-- Description: Manages customer support requests and resolution tracking
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'support_tickets'],
    pre_hook="
        {% if target.name != 'audit' %}
            INSERT INTO {{ ref('bz_data_audit') }} 
            (source_table, load_timestamp, processed_by, processing_time, status)
            SELECT 
                'BZ_SUPPORT_TICKETS' as source_table,
                CURRENT_TIMESTAMP() as load_timestamp,
                'DBT_{{ invocation_id }}' as processed_by,
                0 as processing_time,
                'STARTED' as status
        {% endif %}
    ",
    post_hook="
        {% if target.name != 'audit' %}
            INSERT INTO {{ ref('bz_data_audit') }} 
            (source_table, load_timestamp, processed_by, processing_time, status)
            SELECT 
                'BZ_SUPPORT_TICKETS' as source_table,
                CURRENT_TIMESTAMP() as load_timestamp,
                'DBT_{{ invocation_id }}' as processed_by,
                DATEDIFF('second', 
                    (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_SUPPORT_TICKETS' AND status = 'STARTED'),
                    CURRENT_TIMESTAMP()
                ) as processing_time,
                'SUCCESS' as status
        {% endif %}
    "
) }}

-- Raw data selection with null filtering for primary keys
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
    FROM {{ source('raw', 'support_tickets') }}
    WHERE ticket_id IS NOT NULL  -- Filter out records with null primary keys
),

-- Deduplication logic based on primary key and latest timestamp
deduped_support_tickets AS (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY ticket_id 
                   ORDER BY update_timestamp DESC, load_timestamp DESC
               ) as rn
        FROM raw_support_tickets
    )
    WHERE rn = 1
)

-- Final selection with Bronze timestamp overwrite
SELECT 
    ticket_id,
    user_id,
    ticket_type,
    resolution_status,
    open_date,
    CURRENT_TIMESTAMP() AS load_timestamp,  -- Overwrite with current DBT run time
    CURRENT_TIMESTAMP() AS update_timestamp, -- Overwrite with current DBT run time
    source_system
FROM deduped_support_tickets
