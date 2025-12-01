-- Bronze Layer Feature Usage Model
-- Description: Platform feature usage during meetings
-- Source: RAW.FEATURE_USAGE
-- Target: BRONZE.BZ_FEATURE_USAGE

{{ config(
    materialized='incremental',
    unique_key='usage_id',
    on_schema_change='append_new_columns',
    tags=['bronze', 'feature_usage'],
    pre_hook="
        {% if target.name != 'audit' %}
            INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, status)
            SELECT 'BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 'STARTED'
        {% endif %}
    ",
    post_hook="
        {% if target.name != 'audit' %}
            INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status)
            SELECT 'BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 
                   DATEDIFF('seconds', 
                           (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_FEATURE_USAGE' AND status = 'STARTED'),
                           CURRENT_TIMESTAMP()), 
                   'SUCCESS'
        {% endif %}
    "
) }}

WITH source_data AS (
    SELECT 
        usage_id,
        meeting_id,
        feature_name,
        usage_count,
        usage_date,
        load_timestamp,
        update_timestamp,
        source_system,
        -- Add row number for deduplication
        ROW_NUMBER() OVER (
            PARTITION BY usage_id 
            ORDER BY COALESCE(update_timestamp, load_timestamp) DESC
        ) AS row_num
    FROM {{ source('raw', 'feature_usage') }}
    WHERE usage_id IS NOT NULL  -- Filter out records with null primary keys
    
    {% if is_incremental() %}
        AND COALESCE(update_timestamp, load_timestamp) > (
            SELECT COALESCE(MAX(update_timestamp), '1900-01-01') 
            FROM {{ this }}
        )
    {% endif %}
),

validated_data AS (
    SELECT 
        usage_id,
        meeting_id,
        feature_name,
        -- Validate usage count is non-negative
        CASE 
            WHEN usage_count < 0 THEN 0
            ELSE COALESCE(usage_count, 0)
        END AS usage_count,
        usage_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM source_data
    WHERE row_num = 1  -- Keep only the most recent record per usage_id
        AND feature_name IS NOT NULL  -- Required field validation
        AND (usage_date IS NULL OR usage_date <= CURRENT_DATE())  -- No future dates
)

SELECT 
    usage_id,
    meeting_id,
    feature_name,
    usage_count,
    usage_date,
    -- Override timestamps as per Bronze layer requirements
    CURRENT_TIMESTAMP() AS load_timestamp,
    CURRENT_TIMESTAMP() AS update_timestamp,
    COALESCE(source_system, 'UNKNOWN') AS source_system
FROM validated_data
