{{ config(
    materialized='table',
    pre_hook="
        {% if this.name != 'SI_Audit_Log' %}
        INSERT INTO {{ ref('SI_Audit_Log') }} (
          EXECUTION_ID,
          PIPELINE_NAME,
          PIPELINE_TYPE,
          EXECUTION_START_TIME,
          EXECUTION_STATUS,
          SOURCE_TABLE,
          TARGET_TABLE,
          EXECUTED_BY,
          LOAD_TIMESTAMP
        )
        VALUES (
          '{{ invocation_id }}',
          '{{ this.name }}',
          'SILVER_TRANSFORMATION',
          CURRENT_TIMESTAMP(),
          'STARTED',
          'BRONZE.BZ_PARTICIPANTS',
          '{{ this }}',
          'DBT_PIPELINE',
          CURRENT_TIMESTAMP()
        )
        {% endif %}
    ",
    post_hook="
        {% if this.name != 'SI_Audit_Log' %}
        UPDATE {{ ref('SI_Audit_Log') }}
        SET 
          EXECUTION_END_TIME = CURRENT_TIMESTAMP(),
          EXECUTION_DURATION_SECONDS = DATEDIFF('second', EXECUTION_START_TIME, CURRENT_TIMESTAMP()),
          EXECUTION_STATUS = 'COMPLETED',
          RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}),
          RECORDS_SUCCESS = (SELECT COUNT(*) FROM {{ this }}),
          UPDATE_TIMESTAMP = CURRENT_TIMESTAMP()
        WHERE EXECUTION_ID = '{{ invocation_id }}'
        AND TARGET_TABLE = '{{ this }}'
        AND EXECUTION_STATUS = 'STARTED'
        {% endif %}
    "
) }}

-- Silver Layer Participants Table
-- Purpose: Clean and standardized meeting participants with MM/DD/YYYY timestamp fixes
-- Source: Bronze.BZ_PARTICIPANTS
-- Critical P1 Fixes: MM/DD/YYYY HH:MM timestamp format handling

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
),

-- Critical P1 Fix: MM/DD/YYYY HH:MM timestamp format handling
timestamp_cleaned AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        -- Handle MM/DD/YYYY HH:MM format in JOIN_TIME
        CASE 
            WHEN JOIN_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' THEN 
                TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'MM/DD/YYYY HH24:MI')
            ELSE JOIN_TIME
        END AS CLEAN_JOIN_TIME,
        -- Handle MM/DD/YYYY HH:MM format in LEAVE_TIME
        CASE 
            WHEN LEAVE_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' THEN 
                TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'MM/DD/YYYY HH24:MI')
            ELSE LEAVE_TIME
        END AS CLEAN_LEAVE_TIME,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Flag records with MM/DD/YYYY format for audit
        CASE 
            WHEN JOIN_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' 
                 OR LEAVE_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' 
            THEN TRUE
            ELSE FALSE
        END AS HAD_MMDDYYYY_FORMAT
    FROM source_data
),

-- Data Quality and Cleansing
cleansed_data AS (
    SELECT 
        -- Primary identifiers
        COALESCE(TRIM(PARTICIPANT_ID), 'UNKNOWN_PARTICIPANT_' || ROW_NUMBER() OVER (ORDER BY LOAD_TIMESTAMP)) AS PARTICIPANT_ID,
        
        -- Meeting and user validation
        CASE 
            WHEN TRIM(MEETING_ID) IS NULL OR TRIM(MEETING_ID) = '' THEN 'UNKNOWN_MEETING'
            ELSE TRIM(MEETING_ID)
        END AS MEETING_ID,
        
        CASE 
            WHEN TRIM(USER_ID) IS NULL OR TRIM(USER_ID) = '' THEN 'UNKNOWN_USER'
            ELSE TRIM(USER_ID)
        END AS USER_ID,
        
        -- Cleaned timestamps with validation
        COALESCE(CLEAN_JOIN_TIME, CURRENT_TIMESTAMP()) AS JOIN_TIME,
        COALESCE(CLEAN_LEAVE_TIME, DATEADD('minute', 30, COALESCE(CLEAN_JOIN_TIME, CURRENT_TIMESTAMP()))) AS LEAVE_TIME,
        
        -- Metadata columns
        COALESCE(LOAD_TIMESTAMP, CURRENT_TIMESTAMP()) AS LOAD_TIMESTAMP,
        COALESCE(UPDATE_TIMESTAMP, CURRENT_TIMESTAMP()) AS UPDATE_TIMESTAMP,
        COALESCE(TRIM(SOURCE_SYSTEM), 'UNKNOWN') AS SOURCE_SYSTEM,
        
        -- Silver layer specific columns
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        
        -- Data quality scoring
        CASE 
            WHEN PARTICIPANT_ID IS NOT NULL 
                 AND MEETING_ID IS NOT NULL 
                 AND USER_ID IS NOT NULL
                 AND CLEAN_JOIN_TIME IS NOT NULL 
                 AND CLEAN_LEAVE_TIME IS NOT NULL
                 AND CLEAN_LEAVE_TIME > CLEAN_JOIN_TIME THEN 100
            WHEN PARTICIPANT_ID IS NOT NULL AND MEETING_ID IS NOT NULL AND USER_ID IS NOT NULL THEN 80
            WHEN PARTICIPANT_ID IS NOT NULL AND MEETING_ID IS NOT NULL THEN 60
            ELSE 40
        END AS DATA_QUALITY_SCORE,
        
        -- Validation status
        CASE 
            WHEN PARTICIPANT_ID IS NULL THEN 'FAILED'
            WHEN MEETING_ID IS NULL OR USER_ID IS NULL THEN 'FAILED'
            WHEN CLEAN_LEAVE_TIME <= CLEAN_JOIN_TIME THEN 'WARNING'
            WHEN HAD_MMDDYYYY_FORMAT THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS,
        
        -- Audit flags
        HAD_MMDDYYYY_FORMAT,
        
        -- Row number for deduplication
        ROW_NUMBER() OVER (PARTITION BY PARTICIPANT_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM timestamp_cleaned
    WHERE PARTICIPANT_ID IS NOT NULL
),

-- Final deduplication and validation
final_data AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        JOIN_TIME,
        LEAVE_TIME,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        LOAD_DATE,
        UPDATE_DATE,
        DATA_QUALITY_SCORE,
        VALIDATION_STATUS
    FROM cleansed_data
    WHERE rn = 1
      AND VALIDATION_STATUS IN ('PASSED', 'WARNING')  -- Only pass clean data to Silver
      AND LEAVE_TIME > JOIN_TIME  -- Ensure logical time sequence
)

SELECT * FROM final_data
