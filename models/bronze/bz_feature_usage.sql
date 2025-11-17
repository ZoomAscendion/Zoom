-- Bronze Layer Feature Usage Table
-- Description: Raw usage of platform features during meetings from source systems
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    pre_hook="{% if this.name != 'bz_data_audit' %}INSERT INTO {{ target.database }}.{{ target.schema }}.BZ_DATA_AUDIT (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 0, 'STARTED'{% endif %}",
    post_hook="{% if this.name != 'bz_data_audit' %}INSERT INTO {{ target.database }}.{{ target.schema }}.BZ_DATA_AUDIT (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 1, 'SUCCESS'{% endif %}"
) }}

-- CTE for data deduplication
WITH deduplicated_feature_usage AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Use ROW_NUMBER to identify duplicates based on USAGE_ID and UPDATE_TIMESTAMP
        ROW_NUMBER() OVER (
            PARTITION BY USAGE_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) AS rn
    FROM {{ source('raw', 'feature_usage') }}
)

-- Final selection with data validation and cleansing
SELECT 
    USAGE_ID,
    MEETING_ID,
    FEATURE_NAME,
    USAGE_COUNT,
    USAGE_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM deduplicated_feature_usage
WHERE rn = 1  -- Keep only the most recent record for each USAGE_ID
  AND USAGE_ID IS NOT NULL  -- Ensure primary key is not null
