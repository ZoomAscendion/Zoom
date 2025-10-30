{{
    config(
        materialized='incremental',
        unique_key='participant_id',
        on_schema_change='sync_all_columns'
    )
}}

-- Silver Layer Participants Transformation
-- Source: Bronze.BZ_PARTICIPANTS
-- Target: Silver.SI_PARTICIPANTS

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
    
    {% if is_incremental() %}
        AND UPDATE_TIMESTAMP > (SELECT MAX(update_timestamp) FROM {{ this }})
    {% endif %}
),

-- Data Quality and Transformation Layer
data_quality_checks AS (
    SELECT 
        *,
        -- Data Quality Score Calculation
        CASE 
            WHEN PARTICIPANT_ID IS NULL THEN 0.0
            WHEN MEETING_ID IS NULL OR USER_ID IS NULL THEN 0.2
            WHEN JOIN_TIME IS NULL THEN 0.4
            WHEN LEAVE_TIME IS NOT NULL AND LEAVE_TIME < JOIN_TIME THEN 0.3
            ELSE 1.0
        END AS data_quality_score,
        
        -- Row Number for Deduplication
        ROW_NUMBER() OVER (PARTITION BY PARTICIPANT_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_participants
),

-- Final Transformation
transformed_participants AS (
    SELECT 
        TRIM(PARTICIPANT_ID) AS participant_id,
        TRIM(MEETING_ID) AS meeting_id,
        TRIM(USER_ID) AS user_id,
        JOIN_TIME AS join_time,
        LEAVE_TIME AS leave_time,
        CASE 
            WHEN LEAVE_TIME IS NOT NULL AND JOIN_TIME IS NOT NULL 
            THEN GREATEST(0, DATEDIFF('minute', JOIN_TIME, LEAVE_TIME))
            ELSE 0
        END AS attendance_duration,
        'Participant' AS participant_role,
        'Good' AS connection_quality,  -- Default value, can be enhanced with actual data
        LOAD_TIMESTAMP AS load_timestamp,
        UPDATE_TIMESTAMP AS update_timestamp,
        SOURCE_SYSTEM AS source_system,
        data_quality_score,
        DATE(LOAD_TIMESTAMP) AS load_date,
        DATE(UPDATE_TIMESTAMP) AS update_date
    FROM data_quality_checks
    WHERE rn = 1  -- Remove duplicates
        AND data_quality_score > 0.0  -- Remove records with critical quality issues
        AND MEETING_ID IS NOT NULL
        AND USER_ID IS NOT NULL
)

SELECT 
    participant_id,
    meeting_id,
    user_id,
    join_time,
    leave_time,
    attendance_duration,
    participant_role,
    connection_quality,
    load_timestamp,
    update_timestamp,
    source_system,
    data_quality_score,
    load_date,
    update_date
FROM transformed_participants
