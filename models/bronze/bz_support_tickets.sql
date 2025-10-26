/*
  Bronze Layer Support Tickets Model
  Purpose: Clean and validate support ticket data from raw layer
  Source: RAW.SUPPORT_TICKETS
  Target: BRONZE.BZ_SUPPORT_TICKETS
  Author: Data Engineering Team
  Created: {{ run_started_at }}
*/

{{ config(
    materialized='table'
) }}

WITH raw_support_tickets AS (
    SELECT 
        -- Source data extraction with data quality checks
        user_id,
        ticket_type,
        resolution_status,
        open_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw_zoom', 'support_tickets') }}
    WHERE user_id IS NOT NULL
      AND ticket_type IS NOT NULL
      AND resolution_status IS NOT NULL
      AND open_date IS NOT NULL
),

data_quality_checks AS (
    SELECT 
        *,
        -- Add data quality flags
        CASE 
            WHEN open_date > CURRENT_DATE() THEN 'FUTURE_DATE'
            ELSE 'VALID'
        END AS data_quality_flag
    FROM raw_support_tickets
),

final_bronze AS (
    SELECT 
        -- 1-1 mapping from raw to bronze as per mapping specification
        user_id::STRING AS user_id,
        ticket_type::STRING AS ticket_type,
        resolution_status::STRING AS resolution_status,
        open_date::DATE AS open_date,
        load_timestamp::TIMESTAMP_NTZ AS load_timestamp,
        update_timestamp::TIMESTAMP_NTZ AS update_timestamp,
        source_system::STRING AS source_system
    FROM data_quality_checks
    WHERE data_quality_flag = 'VALID'
)

SELECT * FROM final_bronze
