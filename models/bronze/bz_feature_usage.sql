{{
  config(
    materialized='table',
    tags=['bronze', 'feature_usage'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'DBT_JOB', 0, 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="UPDATE {{ ref('bz_data_audit') }} SET processing_time = DATEDIFF('second', load_timestamp, CURRENT_TIMESTAMP()), status = 'SUCCESS' WHERE source_table = 'BZ_FEATURE_USAGE' AND status = 'STARTED' AND '{{ this.name }}' != 'bz_data_audit'"
  )
}}

-- Bronze layer transformation for FEATURE_USAGE table
-- Applies data cleaning, validation, and deduplication
-- Maps raw feature usage data to bronze layer with audit information

WITH source_data AS (
    SELECT *
    FROM {{ source('raw', 'feature_usage') }}
    WHERE usage_id IS NOT NULL     -- Filter out records with null primary key
      AND meeting_id IS NOT NULL  -- Filter out records with null meeting_id
      AND feature_name IS NOT NULL -- Filter out records with null feature_name
      AND usage_count IS NOT NULL  -- Filter out records with null usage_count
      AND usage_date IS NOT NULL   -- Filter out records with null usage_date
),

-- Apply deduplication based on primary key, keeping the most recent record
deduped_data AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY usage_id ORDER BY load_timestamp DESC) as rn
    FROM source_data
),

-- Final transformation with data quality enhancements
final_data AS (
    SELECT
        usage_id,
        meeting_id,
        feature_name,
        usage_count,
        usage_date,
        CURRENT_TIMESTAMP() AS load_timestamp,  -- Overwrite with current timestamp
        CURRENT_TIMESTAMP() AS update_timestamp, -- Overwrite with current timestamp
        source_system
    FROM deduped_data
    WHERE rn = 1  -- Keep only the most recent record per usage_id
)

SELECT * FROM final_data
