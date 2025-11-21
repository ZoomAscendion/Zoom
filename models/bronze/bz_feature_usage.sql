-- Bronze Layer Feature Usage Table
-- Description: Records usage of platform features during meetings
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'feature_usage'],
    pre_hook="
        {% if target.name != 'audit' %}
            INSERT INTO {{ ref('bz_data_audit') }} 
            (source_table, load_timestamp, processed_by, processing_time, status)
            SELECT 
                'BZ_FEATURE_USAGE' as source_table,
                CURRENT_TIMESTAMP() as load_timestamp,
                'DBT_{{ invocation_id }}' as processed_by,
                0 as processing_time,
                'STARTED' as status
        {% endif %}
    ",
    post_hook="
        {% if target.name != 'audit' %}
            INSERT INTO {{ ref('bz_data_audit') }} 
            (source_table, load_timestamp, processed_by, processing_time, status)
            SELECT 
                'BZ_FEATURE_USAGE' as source_table,
                CURRENT_TIMESTAMP() as load_timestamp,
                'DBT_{{ invocation_id }}' as processed_by,
                DATEDIFF('second', 
                    (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_FEATURE_USAGE' AND status = 'STARTED'),
                    CURRENT_TIMESTAMP()
                ) as processing_time,
                'SUCCESS' as status
        {% endif %}
    "
) }}

-- Raw data selection with null filtering for primary keys
WITH raw_feature_usage AS (
    SELECT 
        usage_id,
        meeting_id,
        feature_name,
        usage_count,
        usage_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw', 'feature_usage') }}
    WHERE usage_id IS NOT NULL  -- Filter out records with null primary keys
),

-- Deduplication logic based on primary key and latest timestamp
deduped_feature_usage AS (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY usage_id 
                   ORDER BY update_timestamp DESC, load_timestamp DESC
               ) as rn
        FROM raw_feature_usage
    )
    WHERE rn = 1
)

-- Final selection with Bronze timestamp overwrite
SELECT 
    usage_id,
    meeting_id,
    feature_name,
    usage_count,
    usage_date,
    CURRENT_TIMESTAMP() AS load_timestamp,  -- Overwrite with current DBT run time
    CURRENT_TIMESTAMP() AS update_timestamp, -- Overwrite with current DBT run time
    source_system
FROM deduped_feature_usage
