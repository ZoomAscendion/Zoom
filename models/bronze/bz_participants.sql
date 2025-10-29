-- Bronze Layer Participants Model
-- Transforms raw participant data from RAW.PARTICIPANTS to BRONZE.BZ_PARTICIPANTS
-- Author: Data Engineering Team
-- Created: 2024-12-19

{{ config(
    materialized='table',
    pre_hook="""
        {% if not is_incremental() %}
            INSERT INTO {{ ref('bz_audit_log') }} (SOURCE_TABLE, PROCESS_START_TIME, STATUS, PROCESSED_BY)
            SELECT 'BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), 'STARTED', 'DBT_SYSTEM'
            WHERE EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'BZ_AUDIT_LOG')
        {% endif %}
    """,
    post_hook="""
        INSERT INTO {{ ref('bz_audit_log') }} (SOURCE_TABLE, PROCESS_START_TIME, PROCESS_END_TIME, STATUS, RECORD_COUNT, PROCESSED_BY)
        SELECT 
            'BZ_PARTICIPANTS',
            CURRENT_TIMESTAMP() - INTERVAL '1 MINUTE',
            CURRENT_TIMESTAMP(),
            'SUCCESS',
            (SELECT COUNT(*) FROM {{ this }}),
            'DBT_SYSTEM'
        WHERE EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'BZ_AUDIT_LOG')
    """
) }}

-- CTE for data validation and cleansing
WITH source_data AS (
    SELECT 
        -- Business columns from source (1:1 mapping)
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        JOIN_TIME,
        LEAVE_TIME,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data quality flags
        CASE 
            WHEN PARTICIPANT_ID IS NULL THEN 'MISSING_PARTICIPANT_ID'
            WHEN MEETING_ID IS NULL THEN 'MISSING_MEETING_ID'
            WHEN USER_ID IS NULL THEN 'MISSING_USER_ID'
            ELSE 'VALID'
        END AS data_quality_flag
        
    FROM {{ source('raw', 'participants') }}
),

-- CTE for final data selection
final_data AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        JOIN_TIME,
        LEAVE_TIME,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM source_data
    WHERE data_quality_flag = 'VALID'
)

SELECT * FROM final_data
