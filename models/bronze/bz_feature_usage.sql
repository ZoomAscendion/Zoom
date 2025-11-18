-- Bronze Layer Feature Usage Model
-- Description: Transforms raw feature usage data from RAW.FEATURE_USAGE to Bronze layer with deduplication and audit logging
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'feature_usage'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), '{{ var(\"audit_user\") }}', 0.0, 'STARTED'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), '{{ var(\"audit_user\") }}', DATEDIFF('second', (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_data_audit') }} WHERE SOURCE_TABLE = 'BZ_FEATURE_USAGE' AND STATUS = 'STARTED'), CURRENT_TIMESTAMP()), 'COMPLETED'"
) }}

WITH source_data AS (
    -- Select from raw feature usage table with null filtering for primary key
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
    WHERE USAGE_ID IS NOT NULL -- Filter out records with null primary key
),

deduplication AS (
    -- Apply deduplication logic based on USAGE_ID and latest LOAD_TIMESTAMP
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY USAGE_ID 
               ORDER BY LOAD_TIMESTAMP DESC, UPDATE_TIMESTAMP DESC NULLS LAST
           ) AS row_num
    FROM source_data
),

final AS (
    -- Select only the most recent record for each USAGE_ID
    SELECT 
        USAGE_ID,
        MEETING_ID,
        FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM deduplication
    WHERE row_num = 1
)

SELECT * FROM final
