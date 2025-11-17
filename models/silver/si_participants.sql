{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

/* Silver Participants Table - Cleaned and standardized meeting participants with timestamp format handling */

WITH bronze_participants AS (
    SELECT *
    FROM {{ source('bronze', 'bz_participants') }}
),

timestamp_format_cleaning AS (
    SELECT 
        bp.*,
        /* Enhanced timestamp handling for multiple formats */
        COALESCE(
            TRY_TO_TIMESTAMP(bp.JOIN_TIME, 'YYYY-MM-DD HH24:MI:SS'),
            TRY_TO_TIMESTAMP(bp.JOIN_TIME, 'DD/MM/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(bp.JOIN_TIME, 'DD-MM-YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(bp.JOIN_TIME, 'MM/DD/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(bp.JOIN_TIME)
        ) AS CLEAN_JOIN_TIME,
        
        COALESCE(
            TRY_TO_TIMESTAMP(bp.LEAVE_TIME, 'YYYY-MM-DD HH24:MI:SS'),
            TRY_TO_TIMESTAMP(bp.LEAVE_TIME, 'DD/MM/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(bp.LEAVE_TIME, 'DD-MM-YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(bp.LEAVE_TIME, 'MM/DD/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(bp.LEAVE_TIME)
        ) AS CLEAN_LEAVE_TIME
    FROM bronze_participants bp
),

data_quality_checks AS (
    SELECT 
        tfc.*,
        /* Data Quality Score Calculation */
        (
            CASE WHEN tfc.PARTICIPANT_ID IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN tfc.MEETING_ID IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN tfc.USER_ID IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN tfc.CLEAN_JOIN_TIME IS NOT NULL THEN 15 ELSE 0 END +
            CASE WHEN tfc.CLEAN_LEAVE_TIME IS NOT NULL THEN 15 ELSE 0 END +
            CASE WHEN tfc.CLEAN_LEAVE_TIME > tfc.CLEAN_JOIN_TIME THEN 10 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        /* Validation Status */
        CASE 
            WHEN tfc.PARTICIPANT_ID IS NULL OR tfc.MEETING_ID IS NULL OR tfc.USER_ID IS NULL THEN 'FAILED'
            WHEN tfc.CLEAN_JOIN_TIME IS NULL OR tfc.CLEAN_LEAVE_TIME IS NULL THEN 'FAILED'
            WHEN tfc.CLEAN_LEAVE_TIME <= tfc.CLEAN_JOIN_TIME THEN 'FAILED'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM timestamp_format_cleaning tfc
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY PARTICIPANT_ID 
            ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC
        ) AS row_num
    FROM data_quality_checks
    WHERE PARTICIPANT_ID IS NOT NULL
),

final_participants AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        CLEAN_JOIN_TIME AS JOIN_TIME,
        CLEAN_LEAVE_TIME AS LEAVE_TIME,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        DATA_QUALITY_SCORE,
        VALIDATION_STATUS
    FROM deduplication
    WHERE row_num = 1
      AND VALIDATION_STATUS != 'FAILED'
)

SELECT * FROM final_participants
