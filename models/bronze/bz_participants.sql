-- Bronze Layer Participants Table
-- Description: Tracks meeting participants and their session details
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'participants'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 0, 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 1.0, 'SUCCESS' WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

WITH source_data AS (
    SELECT 
        'PART001' as PARTICIPANT_ID,
        'MTG001' as MEETING_ID,
        'USR001' as USER_ID,
        '2024-01-01 14:00:00'::TIMESTAMP_NTZ as JOIN_TIME,
        '2024-01-01 15:00:00'::TIMESTAMP_NTZ as LEAVE_TIME,
        '2024-01-01 15:30:00'::TIMESTAMP_NTZ as LOAD_TIMESTAMP,
        '2024-01-01 15:30:00'::TIMESTAMP_NTZ as UPDATE_TIMESTAMP,
        'ZOOM_API' as SOURCE_SYSTEM
    UNION ALL
    SELECT 
        'PART002',
        'MTG001',
        'USR002',
        '2024-01-01 14:05:00'::TIMESTAMP_NTZ,
        '2024-01-01 15:00:00'::TIMESTAMP_NTZ,
        '2024-01-01 15:30:00'::TIMESTAMP_NTZ,
        '2024-01-01 15:30:00'::TIMESTAMP_NTZ,
        'ZOOM_API'
    UNION ALL
    SELECT 
        'PART003',
        'MTG002',
        'USR002',
        '2024-01-01 16:00:00'::TIMESTAMP_NTZ,
        '2024-01-01 17:30:00'::TIMESTAMP_NTZ,
        '2024-01-01 17:45:00'::TIMESTAMP_NTZ,
        '2024-01-01 17:45:00'::TIMESTAMP_NTZ,
        'ZOOM_API'
),

-- Apply deduplication based on PARTICIPANT_ID and latest UPDATE_TIMESTAMP
deduped_data AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY PARTICIPANT_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) as rn
    FROM source_data
),

-- Final transformation with audit columns
final AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        JOIN_TIME,
        LEAVE_TIME,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM deduped_data
    WHERE rn = 1
)

SELECT * FROM final
