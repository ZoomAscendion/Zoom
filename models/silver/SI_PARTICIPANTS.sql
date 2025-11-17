{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_AUDIT_LOG') }} (MODEL_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_START_TIME, STATUS, LOAD_TIMESTAMP) VALUES ('SI_PARTICIPANTS', 'BZ_PARTICIPANTS', 'SI_PARTICIPANTS', CURRENT_TIMESTAMP(), 'STARTED', CURRENT_TIMESTAMP())",
    post_hook="INSERT INTO {{ ref('SI_AUDIT_LOG') }} (MODEL_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_END_TIME, STATUS, RECORDS_SUCCESS, LOAD_TIMESTAMP) VALUES ('SI_PARTICIPANTS', 'BZ_PARTICIPANTS', 'SI_PARTICIPANTS', CURRENT_TIMESTAMP(), 'COMPLETED', (SELECT COUNT(*) FROM {{ this }}), CURRENT_TIMESTAMP())"
) }}

-- Silver layer transformation for Participants table
-- Handles MM/DD/YYYY HH:MM format conversion and data quality validation

WITH source_data AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        JOIN_TIME,
        LEAVE_TIME,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('bronze', 'BZ_PARTICIPANTS') }}
    WHERE PARTICIPANT_ID IS NOT NULL
),

timestamp_conversion AS (
    SELECT 
        *,
        -- Handle MM/DD/YYYY HH:MM format conversion for JOIN_TIME
        CASE 
            WHEN REGEXP_LIKE(JOIN_TIME::STRING, '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$') THEN 
                TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'MM/DD/YYYY HH24:MI')
            ELSE JOIN_TIME
        END AS CONVERTED_JOIN_TIME,
        
        -- Handle MM/DD/YYYY HH:MM format conversion for LEAVE_TIME
        CASE 
            WHEN REGEXP_LIKE(LEAVE_TIME::STRING, '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$') THEN 
                TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'MM/DD/YYYY HH24:MI')
            ELSE LEAVE_TIME
        END AS CONVERTED_LEAVE_TIME
    FROM source_data
),

data_quality_checks AS (
    SELECT 
        *,
        -- Data quality score calculation
        CASE 
            WHEN PARTICIPANT_ID IS NOT NULL 
                AND MEETING_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND CONVERTED_JOIN_TIME IS NOT NULL 
                AND CONVERTED_LEAVE_TIME IS NOT NULL 
                AND CONVERTED_LEAVE_TIME > CONVERTED_JOIN_TIME
            THEN 100
            WHEN PARTICIPANT_ID IS NOT NULL AND MEETING_ID IS NOT NULL AND USER_ID IS NOT NULL
            THEN 75
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        
        -- Validation status
        CASE 
            WHEN PARTICIPANT_ID IS NOT NULL 
                AND MEETING_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND CONVERTED_JOIN_TIME IS NOT NULL 
                AND CONVERTED_LEAVE_TIME IS NOT NULL 
                AND CONVERTED_LEAVE_TIME > CONVERTED_JOIN_TIME
            THEN 'PASSED'
            WHEN PARTICIPANT_ID IS NOT NULL AND MEETING_ID IS NOT NULL
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM timestamp_conversion
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY PARTICIPANT_ID ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC) AS rn
    FROM data_quality_checks
),

final_transformation AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        CONVERTED_JOIN_TIME AS JOIN_TIME,
        CONVERTED_LEAVE_TIME AS LEAVE_TIME,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        DATA_QUALITY_SCORE,
        VALIDATION_STATUS
    FROM deduplication
    WHERE rn = 1  -- Keep only the latest record per participant
        AND VALIDATION_STATUS != 'FAILED'  -- Exclude failed records
)

SELECT * FROM final_transformation
