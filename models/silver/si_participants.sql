{{ config(
    materialized='incremental',
    unique_key='participant_id',
    on_schema_change='sync_all_columns'
) }}

-- Silver layer transformation for Participants
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
    FROM {{ source('bronze', 'bz_participants') }}
    WHERE PARTICIPANT_ID IS NOT NULL
        AND MEETING_ID IS NOT NULL
        AND USER_ID IS NOT NULL
        AND JOIN_TIME IS NOT NULL
),

-- Data Quality Checks and Cleansing
cleansed_participants AS (
    SELECT 
        TRIM(PARTICIPANT_ID) as PARTICIPANT_ID,
        TRIM(MEETING_ID) as MEETING_ID,
        TRIM(USER_ID) as USER_ID,
        JOIN_TIME,
        LEAVE_TIME,
        CASE 
            WHEN LEAVE_TIME IS NOT NULL AND LEAVE_TIME >= JOIN_TIME 
            THEN DATEDIFF('minute', JOIN_TIME, LEAVE_TIME)
            ELSE 0
        END as ATTENDANCE_DURATION,
        'Participant' as PARTICIPANT_ROLE,
        'Good' as CONNECTION_QUALITY,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM bronze_participants
    WHERE (LEAVE_TIME IS NULL OR LEAVE_TIME >= JOIN_TIME)
        AND JOIN_TIME <= CURRENT_TIMESTAMP()
),

-- Remove duplicates
deduped_participants AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY PARTICIPANT_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) as rn
    FROM cleansed_participants
),

-- Calculate data quality score
final_participants AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        JOIN_TIME,
        LEAVE_TIME,
        ATTENDANCE_DURATION,
        PARTICIPANT_ROLE,
        CONNECTION_QUALITY,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Calculate data quality score
        ROUND(
            (CASE WHEN JOIN_TIME IS NOT NULL THEN 0.3 ELSE 0 END +
             CASE WHEN LEAVE_TIME IS NOT NULL THEN 0.2 ELSE 0 END +
             CASE WHEN ATTENDANCE_DURATION >= 0 THEN 0.3 ELSE 0 END +
             CASE WHEN PARTICIPANT_ROLE IS NOT NULL THEN 0.1 ELSE 0 END +
             CASE WHEN CONNECTION_QUALITY IS NOT NULL THEN 0.1 ELSE 0 END), 2
        ) as DATA_QUALITY_SCORE,
        DATE(LOAD_TIMESTAMP) as LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) as UPDATE_DATE
    FROM deduped_participants
    WHERE rn = 1
)

SELECT * FROM final_participants

{% if is_incremental() %}
    WHERE UPDATE_TIMESTAMP > (SELECT COALESCE(MAX(UPDATE_TIMESTAMP), '1900-01-01') FROM {{ this }})
{% endif %}
