/*
  Bronze Licenses Model
  Purpose: Transform raw licenses data to bronze layer
  Source: RAW.LICENSES
  Author: DBT Data Engineer
  Created: {{ run_started_at }}
*/

{{ config(
    materialized='table'
) }}

WITH source_data AS (
    SELECT *
    FROM {{ source('raw_zoom', 'licenses') }}
),

-- Data validation and cleansing
cleansed_data AS (
    SELECT
        -- Business fields with data validation
        COALESCE(TRIM(license_type), 'UNKNOWN') AS license_type,
        TRIM(assigned_to_user_id) AS assigned_to_user_id,
        COALESCE(start_date, CURRENT_DATE()) AS start_date,
        COALESCE(end_date, CURRENT_DATE()) AS end_date,
        
        -- Audit fields
        COALESCE(load_timestamp, CURRENT_TIMESTAMP()) AS load_timestamp,
        COALESCE(update_timestamp, CURRENT_TIMESTAMP()) AS update_timestamp,
        COALESCE(TRIM(source_system), 'UNKNOWN') AS source_system,
        
        -- Process metadata
        CURRENT_TIMESTAMP() AS bronze_created_at,
        'SUCCESS' AS process_status
        
    FROM source_data
    WHERE license_type IS NOT NULL  -- Basic data quality check
)

SELECT
    license_type::STRING AS license_type,
    assigned_to_user_id::STRING AS assigned_to_user_id,
    start_date::DATE AS start_date,
    end_date::DATE AS end_date,
    load_timestamp::TIMESTAMP_NTZ AS load_timestamp,
    update_timestamp::TIMESTAMP_NTZ AS update_timestamp,
    source_system::STRING AS source_system
FROM cleansed_data
