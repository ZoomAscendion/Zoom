-- Bronze Layer Support Tickets Table
-- Description: Manages customer support requests and resolution tracking
-- Source: RAW.SUPPORT_TICKETS
-- Author: DBT Data Engineer

{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (record_id, source_table, load_timestamp, processed_by, processing_time, status) SELECT COALESCE(MAX(record_id), 0) + 1, 'bz_support_tickets', CURRENT_TIMESTAMP(), 'DBT_{{ invocation_id }}', 0, 'STARTED' FROM {{ ref('bz_data_audit') }}",
    post_hook="UPDATE {{ ref('bz_data_audit') }} SET processing_time = 1.0, status = 'SUCCESS' WHERE source_table = 'bz_support_tickets' AND status = 'STARTED'"
) }}

WITH source_data AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        TICKET_TYPE,
        RESOLUTION_STATUS,
        OPEN_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw', 'support_tickets') }}
    WHERE TICKET_ID IS NOT NULL  -- Filter out NULL primary keys
      AND USER_ID IS NOT NULL    -- Filter out NULL foreign keys
),

-- Apply deduplication based on primary key and latest timestamp
deduped_data AS (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY TICKET_ID 
                   ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC
               ) AS row_num
        FROM source_data
    )
    WHERE row_num = 1
),

-- Final transformation with Bronze timestamp overwrite
final_data AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        TICKET_TYPE,
        RESOLUTION_STATUS,
        OPEN_DATE,
        CURRENT_TIMESTAMP() AS load_timestamp,  -- Overwrite with current DBT run time
        CURRENT_TIMESTAMP() AS update_timestamp, -- Overwrite with current DBT run time
        SOURCE_SYSTEM
    FROM deduped_data
)

SELECT * FROM final_data
