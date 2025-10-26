/*
  Bronze Layer Licenses Model
  Purpose: Clean and validate license data from raw layer
  Source: RAW.LICENSES
  Target: BRONZE.BZ_LICENSES
  Author: Data Engineering Team
  Created: {{ run_started_at }}
*/

{{ config(
    materialized='table'
) }}

WITH raw_licenses AS (
    SELECT 
        -- Source data extraction with data quality checks
        license_type,
        assigned_to_user_id,
        start_date,
        end_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw_zoom', 'licenses') }}
    WHERE license_type IS NOT NULL
      AND start_date IS NOT NULL
      AND end_date IS NOT NULL
),

data_quality_checks AS (
    SELECT 
        *,
        -- Add data quality flags
        CASE 
            WHEN start_date > end_date THEN 'INVALID_DATE_RANGE'
            WHEN end_date < CURRENT_DATE() THEN 'EXPIRED_LICENSE'
            ELSE 'VALID'
        END AS data_quality_flag
    FROM raw_licenses
),

final_bronze AS (
    SELECT 
        -- 1-1 mapping from raw to bronze as per mapping specification
        license_type::STRING AS license_type,
        assigned_to_user_id::STRING AS assigned_to_user_id,
        start_date::DATE AS start_date,
        end_date::DATE AS end_date,
        load_timestamp::TIMESTAMP_NTZ AS load_timestamp,
        update_timestamp::TIMESTAMP_NTZ AS update_timestamp,
        source_system::STRING AS source_system
    FROM data_quality_checks
    WHERE data_quality_flag IN ('VALID', 'EXPIRED_LICENSE') -- Include expired licenses for historical analysis
)

SELECT * FROM final_bronze
