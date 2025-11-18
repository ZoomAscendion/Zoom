-- Bronze Layer Feature Usage Table
-- Description: Records usage of platform features during meetings
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'feature_usage'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 0, 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 1.0, 'SUCCESS' WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

WITH source_data AS (
    SELECT 
        'USAGE001' as USAGE_ID,
        'MTG001' as MEETING_ID,
        'Screen Share' as FEATURE_NAME,
        3 as USAGE_COUNT,
        '2024-01-01'::DATE as USAGE_DATE,
        '2024-01-01 15:30:00'::TIMESTAMP_NTZ as LOAD_TIMESTAMP,
        '2024-01-01 15:30:00'::TIMESTAMP_NTZ as UPDATE_TIMESTAMP,
        'ZOOM_API' as SOURCE_SYSTEM
    UNION ALL
    SELECT 
        'USAGE002',
        'MTG001',
        'Chat',
        15,
        '2024-01-01'::DATE,
        '2024-01-01 15:30:00'::TIMESTAMP_NTZ,
        '2024-01-01 15:30:00'::TIMESTAMP_NTZ,
        'ZOOM_API'
    UNION ALL
    SELECT 
        'USAGE003',
        'MTG002',
        'Recording',
        1,
        '2024-01-01'::DATE,
        '2024-01-01 17:45:00'::TIMESTAMP_NTZ,
        '2024-01-01 17:45:00'::TIMESTAMP_NTZ,
        'ZOOM_API'
),

-- Apply deduplication based on USAGE_ID and latest UPDATE_TIMESTAMP
deduped_data AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY USAGE_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) as rn
    FROM source_data
),

-- Final transformation with audit columns
final AS (
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
)

SELECT * FROM final
