-- =====================================================
-- Bronze Layer Participants Model
-- =====================================================
-- Description: Raw participant data from source system with 1:1 mapping
-- Source: RAW.PARTICIPANTS
-- Target: BRONZE.BZ_PARTICIPANTS
-- =====================================================

{{ config(
    materialized='table',
    pre_hook="""
        {% if target.name != 'bz_audit_log' %}
            INSERT INTO {{ ref('bz_audit_log') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS)
            VALUES ('BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 0, 'STARTED')
        {% endif %}
    """,
    post_hook="""
        {% if target.name != 'bz_audit_log' %}
            INSERT INTO {{ ref('bz_audit_log') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS)
            VALUES ('BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 30, 'COMPLETED')
        {% endif %}
    """
) }}

-- Raw data extraction with basic error handling
WITH source_data AS (
    SELECT 
        -- Primary participant information (1:1 mapping from source)
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        JOIN_TIME,
        LEAVE_TIME,
        
        -- Metadata columns (1:1 mapping from source)
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
        
    FROM {{ source('raw', 'participants') }}
),

-- Data validation and cleansing
validated_data AS (
    SELECT 
        -- Convert all VARCHAR fields to STRING for consistency
        CAST(PARTICIPANT_ID AS STRING) AS PARTICIPANT_ID,
        CAST(MEETING_ID AS STRING) AS MEETING_ID,
        CAST(USER_ID AS STRING) AS USER_ID,
        
        -- Preserve original timestamps
        JOIN_TIME,
        LEAVE_TIME,
        
        -- Metadata preservation
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        CAST(SOURCE_SYSTEM AS STRING) AS SOURCE_SYSTEM
        
    FROM source_data
    -- Include all records for bronze layer (no filtering)
)

-- Final selection for bronze layer
SELECT 
    PARTICIPANT_ID,
    MEETING_ID,
    USER_ID,
    JOIN_TIME,
    LEAVE_TIME,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM validated_data
