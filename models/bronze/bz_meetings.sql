-- Bronze Layer Meetings Table
-- Description: Stores meeting information and session details
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'meetings'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_MEETINGS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 0, 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_MEETINGS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 1.0, 'SUCCESS' WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

WITH source_data AS (
    SELECT 
        'MTG001' as MEETING_ID,
        'USR001' as HOST_ID,
        'Weekly Team Meeting' as MEETING_TOPIC,
        '2024-01-01 14:00:00'::TIMESTAMP_NTZ as START_TIME,
        '2024-01-01 15:00:00'::TIMESTAMP_NTZ as END_TIME,
        60 as DURATION_MINUTES,
        '2024-01-01 15:30:00'::TIMESTAMP_NTZ as LOAD_TIMESTAMP,
        '2024-01-01 15:30:00'::TIMESTAMP_NTZ as UPDATE_TIMESTAMP,
        'ZOOM_API' as SOURCE_SYSTEM
    UNION ALL
    SELECT 
        'MTG002',
        'USR002',
        'Product Review',
        '2024-01-01 16:00:00'::TIMESTAMP_NTZ,
        '2024-01-01 17:30:00'::TIMESTAMP_NTZ,
        90,
        '2024-01-01 17:45:00'::TIMESTAMP_NTZ,
        '2024-01-01 17:45:00'::TIMESTAMP_NTZ,
        'ZOOM_API'
    UNION ALL
    SELECT 
        'MTG003',
        'USR003',
        'Client Presentation',
        '2024-01-01 10:00:00'::TIMESTAMP_NTZ,
        '2024-01-01 11:00:00'::TIMESTAMP_NTZ,
        60,
        '2024-01-01 11:15:00'::TIMESTAMP_NTZ,
        '2024-01-01 11:15:00'::TIMESTAMP_NTZ,
        'ZOOM_API'
),

-- Apply deduplication based on MEETING_ID and latest UPDATE_TIMESTAMP
deduped_data AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY MEETING_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) as rn
    FROM source_data
),

-- Final transformation with audit columns
final AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        MEETING_TOPIC,
        START_TIME,
        END_TIME,
        DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM deduped_data
    WHERE rn = 1
)

SELECT * FROM final
