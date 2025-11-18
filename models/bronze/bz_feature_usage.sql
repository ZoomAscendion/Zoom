-- Bronze Pipeline Step 5: Transform raw feature usage data to bronze layer
-- Description: 1-1 mapping from RAW.FEATURE_USAGE to BRONZE.BZ_FEATURE_USAGE with deduplication
-- Author: Data Engineering Team
-- Created: 2024-01-01

{{ config(
    materialized='table',
    tags=['bronze', 'feature_usage'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, status) SELECT 'BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_FEATURE_USAGE' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS' WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

-- Bronze Pipeline Step 5.1: Select and filter raw data excluding null primary keys
WITH raw_feature_usage_filtered AS (
    SELECT 
        usage_id,
        meeting_id,
        feature_name,
        usage_count,
        usage_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw_schema', 'feature_usage') }}
    WHERE usage_id IS NOT NULL  -- Filter out null primary keys
),

-- Bronze Pipeline Step 5.2: Apply deduplication logic based on primary key and latest timestamp
deduped_feature_usage AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY usage_id 
            ORDER BY update_timestamp DESC, load_timestamp DESC
        ) as rn
    FROM raw_feature_usage_filtered
),

-- Bronze Pipeline Step 5.3: Select final deduplicated records
final_feature_usage AS (
    SELECT 
        usage_id,
        meeting_id,
        feature_name,
        usage_count,
        usage_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM deduped_feature_usage
    WHERE rn = 1
)

SELECT * FROM final_feature_usage
