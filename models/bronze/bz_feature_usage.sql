-- Bronze Layer Feature Usage Table
-- Description: Records usage of platform features during meetings
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'feature_usage'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS) SELECT 'BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'DBT_BZ_FEATURE_USAGE', 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'DBT_BZ_FEATURE_USAGE', 1.0, 'COMPLETED' WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

WITH source_data AS (
    -- Select from RAW layer with null filtering for primary keys
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
      AND USAGE_COUNT IS NOT NULL
      AND USAGE_DATE IS NOT NULL
      AND LOAD_TIMESTAMP IS NOT NULL
      AND SOURCE_SYSTEM IS NOT NULL
),

deduped_data AS (
    -- Apply deduplication based on USAGE_ID and LOAD_TIMESTAMP
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY USAGE_ID 
               ORDER BY LOAD_TIMESTAMP DESC, 
                        COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC
           ) as rn
    FROM source_data
)

-- Final selection with audit columns
SELECT 
    USAGE_ID,
    MEETING_ID,
    FEATURE_NAME,
    USAGE_COUNT,
    USAGE_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM deduped_data
WHERE rn = 1
