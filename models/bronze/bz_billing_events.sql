/*
  Bronze Billing Events Model
  Purpose: Transform raw billing events data to bronze layer
  Source: RAW.BILLING_EVENTS
  Author: DBT Data Engineer
  Created: {{ run_started_at }}
*/

{{ config(
    materialized='table'
) }}

WITH source_data AS (
    SELECT *
    FROM {{ source('raw_zoom', 'billing_events') }}
),

-- Data validation and cleansing
cleansed_data AS (
    SELECT
        -- Business fields with data validation
        COALESCE(TRIM(user_id), 'UNKNOWN') AS user_id,
        COALESCE(TRIM(event_type), 'UNKNOWN') AS event_type,
        COALESCE(amount, 0) AS amount,
        COALESCE(event_date, CURRENT_DATE()) AS event_date,
        
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
    event_type::STRING AS event_type,
    amount::NUMBER(10,2) AS amount,
    event_date::DATE AS event_date,
    load_timestamp::TIMESTAMP_NTZ AS load_timestamp,
    update_timestamp::TIMESTAMP_NTZ AS update_timestamp,
    source_system::STRING AS source_system
FROM cleansed_data
