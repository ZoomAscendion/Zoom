-- Bronze Layer Feature Usage Model
-- Description: Raw feature usage data tracking user interactions
-- Author: Data Engineer
-- Created: 2024-12-19

{{ config(
    materialized='table',
    tags=['bronze', 'feature_usage'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'DBT_USER', 0, 'STARTED')",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'DBT_USER', 1, 'SUCCESS')"
) }}

-- Filter out NULL primary keys and apply deduplication
WITH source_data AS (
    SELECT *
    FROM {{ source('raw', 'feature_usage') }}
    WHERE usage_id IS NOT NULL
),

-- Apply deduplication based on primary key and load timestamp
deduped_data AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY usage_id 
               ORDER BY load_timestamp DESC
           ) AS row_num
    FROM source_data
),

-- Final transformation with bronze timestamp overwrite
final AS (
    SELECT 
        usage_id,
        meeting_id,
        COALESCE(feature_name, 'unknown_feature') AS feature_name,
        COALESCE(usage_count, 0) AS usage_count,
        usage_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        COALESCE(source_system, 'unknown') AS source_system
    FROM deduped_data
    WHERE row_num = 1
)

SELECT * FROM final
