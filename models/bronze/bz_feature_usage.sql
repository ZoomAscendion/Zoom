-- Bronze Layer Feature Usage Model
-- Description: Raw feature usage data tracking user interactions
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='usage_id'
) }}

-- Filter out NULL primary keys and apply deduplication
WITH source_data AS (
    SELECT *
    FROM {{ source('raw', 'feature_usage') }}
    WHERE usage_id IS NOT NULL  -- Filter NULL primary keys
),

-- Apply deduplication based on primary key and load timestamp
deduped_data AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY usage_id 
               ORDER BY load_timestamp DESC
           ) as rn
    FROM source_data
),

-- Final transformation
final AS (
    SELECT 
        usage_id,
        meeting_id,
        feature_name,
        usage_count,
        usage_date,
        -- Overwrite timestamps with current DBT run time
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        source_system
    FROM deduped_data
    WHERE rn = 1  -- Keep only the most recent record per usage_id
)

SELECT * FROM final
