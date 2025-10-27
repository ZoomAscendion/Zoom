/*
  Bronze Users Model
  Purpose: Transform raw users data to bronze layer
  Source: RAW.USERS
  Author: DBT Data Engineer
  Created: {{ run_started_at }}
*/

{{ config(
    materialized='table'
) }}

WITH source_data AS (
    SELECT *
    FROM {{ source('raw_zoom', 'users') }}
),

-- Data validation and cleansing
cleansed_data AS (
    SELECT
        -- Business fields with data validation
        COALESCE(TRIM(user_name), 'UNKNOWN') AS user_name,
        COALESCE(TRIM(LOWER(email)), 'unknown@unknown.com') AS email,
        TRIM(company) AS company,
        COALESCE(TRIM(plan_type), 'UNKNOWN') AS plan_type,
        
        -- Audit fields
        COALESCE(load_timestamp, CURRENT_TIMESTAMP()) AS load_timestamp,
        COALESCE(update_timestamp, CURRENT_TIMESTAMP()) AS update_timestamp,
        COALESCE(TRIM(source_system), 'UNKNOWN') AS source_system,
        
        -- Process metadata
        CURRENT_TIMESTAMP() AS bronze_created_at,
        'SUCCESS' AS process_status
        
    FROM source_data
    WHERE user_name IS NOT NULL AND email IS NOT NULL  -- Basic data quality check
)

SELECT
    user_name::STRING AS user_name,
    email::STRING AS email,
    company::STRING AS company,
    plan_type::STRING AS plan_type,
    load_timestamp::TIMESTAMP_NTZ AS load_timestamp,
    update_timestamp::TIMESTAMP_NTZ AS update_timestamp,
    source_system::STRING AS source_system
FROM cleansed_data
