{{ config(
    materialized='table',
    on_schema_change='sync_all_columns',
    pre_hook="
        INSERT INTO {{ ref('SI_AUDIT_LOG') }} (EXECUTION_ID, PIPELINE_NAME, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP)
        VALUES (UUID_STRING(), 'SI_PARTICIPANTS', CURRENT_TIMESTAMP(), 'STARTED', 'BRONZE.BZ_PARTICIPANTS', '{{ this.schema }}.SI_PARTICIPANTS', 'DBT_PIPELINE', CURRENT_TIMESTAMP())
    ",
    post_hook="
        UPDATE {{ ref('SI_AUDIT_LOG') }} 
        SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(), 
            EXECUTION_STATUS = 'SUCCESS',
            RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}),
            UPDATE_TIMESTAMP = CURRENT_TIMESTAMP()
        WHERE TARGET_TABLE = '{{ this.schema }}.SI_PARTICIPANTS' 
        AND EXECUTION_STATUS = 'STARTED'
        AND EXECUTION_START_TIME >= CURRENT_TIMESTAMP() - INTERVAL '1 HOUR'
    "
) }}

-- Silver Layer Participants Table
-- Purpose: Clean and standardized meeting participants with MM/DD/YYYY format handling
-- Transformation: Bronze to Silver with timestamp format validation

WITH bronze_participants AS (
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

timestamp_standardization AS (
    SELECT 
        *,
        -- Enhanced MM/DD/YYYY format handling with multi-format parsing
        COALESCE(
            TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'YYYY-MM-DD HH24:MI:SS'),
            TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'MM/DD/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'DD/MM/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(REPLACE(JOIN_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS')
        ) AS STANDARDIZED_JOIN_TIME,
        
        COALESCE(
            TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'YYYY-MM-DD HH24:MI:SS'),
            TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'MM/DD/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'DD/MM/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(REPLACE(LEAVE_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS')
        ) AS STANDARDIZED_LEAVE_TIME
    FROM bronze_participants
),

data_quality_checks AS (
    SELECT 
        *,
        -- Data Quality Score Calculation
        CASE 
            WHEN PARTICIPANT_ID IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN MEETING_ID IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN USER_ID IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN STANDARDIZED_JOIN_TIME IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN STANDARDIZED_LEAVE_TIME IS NOT NULL THEN 20 ELSE 0 END
        AS DATA_QUALITY_SCORE,
        
        -- Validation Status
        CASE 
            WHEN PARTICIPANT_ID IS NULL OR MEETING_ID IS NULL OR USER_ID IS NULL THEN 'FAILED'
            WHEN STANDARDIZED_JOIN_TIME IS NULL OR STANDARDIZED_LEAVE_TIME IS NULL THEN 'FAILED'
            WHEN STANDARDIZED_LEAVE_TIME <= STANDARDIZED_JOIN_TIME THEN 'FAILED'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM timestamp_standardization
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY PARTICIPANT_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) as rn
    FROM data_quality_checks
),

final_transformation AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        STANDARDIZED_JOIN_TIME AS JOIN_TIME,
        STANDARDIZED_LEAVE_TIME AS LEAVE_TIME,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Additional Silver layer metadata columns
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        DATA_QUALITY_SCORE,
        VALIDATION_STATUS
    FROM deduplication
    WHERE rn = 1
    AND VALIDATION_STATUS IN ('PASSED', 'WARNING') -- Exclude FAILED records
    AND STANDARDIZED_JOIN_TIME IS NOT NULL
    AND STANDARDIZED_LEAVE_TIME IS NOT NULL
)

SELECT * FROM final_transformation
