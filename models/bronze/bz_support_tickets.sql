/*
  Bronze Support Tickets Model
  Purpose: Transform raw support tickets data to bronze layer
  Source: RAW.SUPPORT_TICKETS
  Author: DBT Data Engineer
  Created: {{ run_started_at }}
*/

{{ config(
    materialized='table'
) }}

WITH source_data AS (
    SELECT *
    FROM {{ source('raw_zoom', 'support_tickets') }}
),

-- Data validation and cleansing
cleansed_data AS (
    SELECT
        -- Business fields with data validation
        COALESCE(TRIM(user_id), 'UNKNOWN') AS user_id,
        COALESCE(TRIM(ticket_type), 'UNKNOWN') AS ticket_type,
        COALESCE(TRIM(resolution_status), 'OPEN') AS resolution_status,
        COALESCE(open_date, CURRENT_DATE()) AS open_date,
        
        -- Audit fields
        COALESCE(load_timestamp, CURRENT_TIMESTAMP()) AS load_timestamp,
        COALESCE(update_timestamp, CURRENT_TIMESTAMP()) AS update_timestamp,
        COALESCE(TRIM(source_system), 'UNKNOWN') AS source_system,
        
        -- Process metadata
        CURRENT_TIMESTAMP() AS bronze_created_at,
        'SUCCESS' AS process_status
        
    FROM source_data
    WHERE user_id IS NOT NULL  -- Basic data quality check
)

SELECT
    user_id::STRING AS user_id,
    ticket_type::STRING AS ticket_type,
    resolution_status::STRING AS resolution_status,
    open_date::DATE AS open_date,
    load_timestamp::TIMESTAMP_NTZ AS load_timestamp,
    update_timestamp::TIMESTAMP_NTZ AS update_timestamp,
    source_system::STRING AS source_system
FROM cleansed_data
