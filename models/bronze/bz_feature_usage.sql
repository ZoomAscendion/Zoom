/*
  Bronze Layer Feature Usage Model
  Purpose: Clean and validate feature usage data from raw layer
  Source: RAW.FEATURE_USAGE
  Target: BRONZE.BZ_FEATURE_USAGE
  Author: Data Engineering Team
  Created: {{ run_started_at }}
*/

{{ config(
    materialized='table'
) }}

WITH raw_feature_usage AS (
    SELECT 
        -- Source data extraction with data quality checks
        meeting_id,
        feature_name,
        usage_count,
        usage_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw_zoom', 'feature_usage') }}
    WHERE meeting_id IS NOT NULL
      AND feature_name IS NOT NULL
      AND usage_count IS NOT NULL
      AND usage_date IS NOT NULL
),

data_quality_checks AS (
    SELECT 
        *,
        -- Add data quality flags
        CASE 
            WHEN usage_count < 0 THEN 'NEGATIVE_COUNT'
            WHEN usage_date > CURRENT_DATE() THEN 'FUTURE_DATE'
            ELSE 'VALID'
        END AS data_quality_flag
    FROM raw_feature_usage
),

final_bronze AS (
    SELECT 
        -- 1-1 mapping from raw to bronze as per mapping specification
        meeting_id::STRING AS meeting_id,
        feature_name::STRING AS feature_name,
        usage_count::NUMBER(38,0) AS usage_count,
        usage_date::DATE AS usage_date,
        load_timestamp::TIMESTAMP_NTZ AS load_timestamp,
        update_timestamp::TIMESTAMP_NTZ AS update_timestamp,
        source_system::STRING AS source_system
    FROM data_quality_checks
    WHERE data_quality_flag = 'VALID'
)

SELECT * FROM final_bronze
