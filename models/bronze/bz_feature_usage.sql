-- Bronze Layer Feature Usage Model
-- Description: Transforms raw feature usage data into bronze layer with audit capabilities
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='usage_id',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS) SELECT 'BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'DBT_{{ invocation_id }}', 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS) SELECT 'BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'DBT_{{ invocation_id }}', 'COMPLETED' WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

WITH raw_feature_usage AS (
    -- Select from raw feature usage table with null filtering for primary keys
    SELECT 
        USAGE_ID,
        MEETING_ID,
        FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw', 'feature_usage') }}
    WHERE USAGE_ID IS NOT NULL
      AND MEETING_ID IS NOT NULL
      AND FEATURE_NAME IS NOT NULL
),

deduped_feature_usage AS (
    -- Apply deduplication based on usage_id, keeping the latest record
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY USAGE_ID ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC) as rn
        FROM raw_feature_usage
    )
    WHERE rn = 1
),

final_feature_usage AS (
    -- Final transformation
    SELECT 
        USAGE_ID,
        MEETING_ID,
        FEATURE_NAME,
        COALESCE(USAGE_COUNT, 0) AS USAGE_COUNT,
        USAGE_DATE,
        CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
        CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP,
        COALESCE(SOURCE_SYSTEM, 'unknown') AS SOURCE_SYSTEM
    FROM deduped_feature_usage
)

SELECT * FROM final_feature_usage
