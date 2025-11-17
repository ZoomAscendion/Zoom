{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_audit_log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_MEETINGS', 'PROCESS_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'si_audit_log'",
    post_hook="INSERT INTO {{ ref('si_audit_log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_MEETINGS', 'PROCESS_END', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'si_audit_log'"
) }}

-- Silver Layer Meetings Table
-- Purpose: Clean and standardized meeting information with critical format fixes
-- Source: Bronze BZ_MEETINGS table
-- Critical P1 Fix: Numeric field text unit cleaning for DURATION_MINUTES

WITH source_data AS (
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
    FROM {{ source('bronze', 'bz_meetings') }}
    WHERE MEETING_ID IS NOT NULL
),

timestamp_cleaned AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        TRIM(MEETING_TOPIC) AS MEETING_TOPIC,
        -- Handle EST timezone format conversion
        CASE 
            WHEN START_TIME::STRING LIKE '%EST%' THEN 
                TRY_TO_TIMESTAMP(REPLACE(START_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS')
            ELSE START_TIME
        END AS CLEAN_START_TIME,
        CASE 
            WHEN END_TIME::STRING LIKE '%EST%' THEN 
                TRY_TO_TIMESTAMP(REPLACE(END_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS')
            ELSE END_TIME
        END AS CLEAN_END_TIME,
        -- Critical P1 Fix: Clean text units from DURATION_MINUTES ("108 mins" error)
        TRY_TO_NUMBER(REGEXP_REPLACE(DURATION_MINUTES::STRING, '[^0-9.]', '')) AS CLEAN_DURATION_MINUTES,
        DURATION_MINUTES AS ORIGINAL_DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM source_data
),

validated_data AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        MEETING_TOPIC,
        CLEAN_START_TIME AS START_TIME,
        CLEAN_END_TIME AS END_TIME,
        CLEAN_DURATION_MINUTES AS DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        
        -- Data Quality Score with format conversion compliance
        CASE 
            WHEN MEETING_ID IS NOT NULL 
                AND HOST_ID IS NOT NULL 
                AND CLEAN_START_TIME IS NOT NULL 
                AND CLEAN_END_TIME IS NOT NULL 
                AND CLEAN_DURATION_MINUTES IS NOT NULL
                AND CLEAN_END_TIME > CLEAN_START_TIME
                AND CLEAN_DURATION_MINUTES BETWEEN 0 AND 1440
            THEN 100
            WHEN MEETING_ID IS NOT NULL AND HOST_ID IS NOT NULL AND CLEAN_START_TIME IS NOT NULL
            THEN 75
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        
        -- Validation Status
        CASE 
            WHEN MEETING_ID IS NOT NULL 
                AND HOST_ID IS NOT NULL 
                AND CLEAN_START_TIME IS NOT NULL 
                AND CLEAN_END_TIME IS NOT NULL 
                AND CLEAN_DURATION_MINUTES IS NOT NULL
                AND CLEAN_END_TIME > CLEAN_START_TIME
                AND CLEAN_DURATION_MINUTES BETWEEN 0 AND 1440
            THEN 'PASSED'
            WHEN MEETING_ID IS NOT NULL AND HOST_ID IS NOT NULL AND CLEAN_START_TIME IS NOT NULL
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS,
        
        -- Track format conversion issues
        CASE 
            WHEN ORIGINAL_DURATION_MINUTES::STRING REGEXP '[^0-9.]' AND CLEAN_DURATION_MINUTES IS NULL
            THEN 'FORMAT_CONVERSION_FAILURE'
            ELSE 'CONVERSION_SUCCESS'
        END AS CONVERSION_STATUS,
        
        ORIGINAL_DURATION_MINUTES
    FROM timestamp_cleaned
),

deduped_data AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY MEETING_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM validated_data
)

SELECT 
    MEETING_ID,
    HOST_ID,
    MEETING_TOPIC,
    START_TIME,
    END_TIME,
    DURATION_MINUTES,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    LOAD_DATE,
    UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_data
WHERE rn = 1
    AND VALIDATION_STATUS IN ('PASSED', 'WARNING')
