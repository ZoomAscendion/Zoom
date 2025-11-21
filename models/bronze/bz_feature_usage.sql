-- Bronze Layer Feature Usage Table
-- Description: Records usage of platform features during meetings
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'feature_usage'],
    pre_hook="
        {% if this.name != 'bz_data_audit' %}
            INSERT INTO {{ ref('bz_data_audit') }} (record_id, source_table, load_timestamp, processed_by, processing_time, status)
            SELECT 
                (SELECT COALESCE(MAX(record_id), 0) + 1 FROM {{ ref('bz_data_audit') }}),
                'BZ_FEATURE_USAGE',
                CURRENT_TIMESTAMP(),
                'DBT_BRONZE_PIPELINE',
                0,
                'STARTED'
        {% endif %}
    ",
    post_hook="
        {% if this.name != 'bz_data_audit' %}
            INSERT INTO {{ ref('bz_data_audit') }} (record_id, source_table, load_timestamp, processed_by, processing_time, status)
            SELECT 
                (SELECT COALESCE(MAX(record_id), 0) + 1 FROM {{ ref('bz_data_audit') }}),
                'BZ_FEATURE_USAGE',
                CURRENT_TIMESTAMP(),
                'DBT_BRONZE_PIPELINE',
                DATEDIFF('seconds', 
                    (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_FEATURE_USAGE' AND status = 'STARTED'),
                    CURRENT_TIMESTAMP()
                ),
                'SUCCESS'
        {% endif %}
    "
) }}

-- Raw data selection with null filtering for primary key
WITH raw_feature_usage AS (
    SELECT *
    FROM {{ source('raw', 'feature_usage') }}
    WHERE usage_id IS NOT NULL  -- Filter out records with null primary key
),

-- Deduplication logic based on primary key and latest timestamp
deduped_feature_usage AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY usage_id 
            ORDER BY update_timestamp DESC, load_timestamp DESC
        ) AS row_num
    FROM raw_feature_usage
),

-- Final transformation with bronze timestamp overwrite
final_feature_usage AS (
    SELECT 
        usage_id,
        meeting_id,
        feature_name,
        usage_count,
        usage_date,
        CURRENT_TIMESTAMP() AS load_timestamp,  -- Overwrite with current DBT run timestamp
        CURRENT_TIMESTAMP() AS update_timestamp,  -- Overwrite with current DBT run timestamp
        source_system
    FROM deduped_feature_usage
    WHERE row_num = 1
)

SELECT * FROM final_feature_usage
