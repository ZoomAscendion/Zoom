/*
  Bronze Layer Users Model
  Purpose: Clean and validate user data from raw layer
  Source: RAW.USERS
  Target: BRONZE.BZ_USERS
  Author: Data Engineering Team
  Created: {{ run_started_at }}
*/

{{ config(
    materialized='table'
) }}

WITH raw_users AS (
    SELECT 
        -- Source data extraction with data quality checks
        user_name,
        email,
        company,
        plan_type,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw_zoom', 'users') }}
    WHERE user_name IS NOT NULL
      AND email IS NOT NULL
      AND plan_type IS NOT NULL
),

data_quality_checks AS (
    SELECT 
        *,
        -- Add data quality flags
        CASE 
            WHEN email NOT LIKE '%@%' THEN 'INVALID_EMAIL'
            WHEN LENGTH(TRIM(user_name)) = 0 THEN 'EMPTY_USERNAME'
            ELSE 'VALID'
        END AS data_quality_flag
    FROM raw_users
),

final_bronze AS (
    SELECT 
        -- 1-1 mapping from raw to bronze as per mapping specification
        user_name::STRING AS user_name,
        email::STRING AS email,
        company::STRING AS company,
        plan_type::STRING AS plan_type,
        load_timestamp::TIMESTAMP_NTZ AS load_timestamp,
        update_timestamp::TIMESTAMP_NTZ AS update_timestamp,
        source_system::STRING AS source_system
    FROM data_quality_checks
    WHERE data_quality_flag = 'VALID'
)

SELECT * FROM final_bronze
