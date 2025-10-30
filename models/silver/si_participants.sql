{{ config(
    materialized='table',
    on_schema_change='sync_all_columns',
    pre_hook="DROP TABLE IF EXISTS {{ this }}"
) }}

-- Silver layer transformation for participants with comprehensive data quality checks
WITH bronze_participants AS (
    SELECT 
        bp.PARTICIPANT_ID,
        bp.MEETING_ID,
        bp.USER_ID,
        bp.JOIN_TIME,
        bp.LEAVE_TIME,
        bp.LOAD_TIMESTAMP,
        bp.UPDATE_TIMESTAMP,
        bp.SOURCE_SYSTEM,
        -- Add row number for deduplication
        ROW_NUMBER() OVER (
            PARTITION BY bp.PARTICIPANT_ID 
            ORDER BY bp.UPDATE_TIMESTAMP DESC, bp.LOAD_TIMESTAMP DESC
        ) as rn
    FROM {{ source('bronze', 'bz_participants') }} bp
    WHERE bp.PARTICIPANT_ID IS NOT NULL 
    AND TRIM(bp.PARTICIPANT_ID) != ''
    AND bp.MEETING_ID IS NOT NULL
    AND bp.USER_ID IS NOT NULL
    AND bp.JOIN_TIME IS NOT NULL
),

-- Data quality validation and cleansing
cleansed_participants AS (
    SELECT 
        bp.PARTICIPANT_ID as participant_id,
        bp.MEETING_ID as meeting_id,
        bp.USER_ID as user_id,
        bp.JOIN_TIME as join_time,
        COALESCE(bp.LEAVE_TIME, bp.JOIN_TIME + INTERVAL '1 minute') as leave_time,
        GREATEST(
            DATEDIFF('minute', bp.JOIN_TIME, COALESCE(bp.LEAVE_TIME, bp.JOIN_TIME + INTERVAL '1 minute')), 
            0
        ) as attendance_duration,
        CASE 
            WHEN m.host_id IS NOT NULL AND bp.USER_ID = m.host_id THEN 'Host'
            WHEN DATEDIFF('minute', bp.JOIN_TIME, COALESCE(bp.LEAVE_TIME, bp.JOIN_TIME)) > 30 THEN 'Participant'
            ELSE 'Observer'
        END as participant_role,
        'Good' as connection_quality,  -- Default value, can be enhanced with actual data
        bp.LOAD_TIMESTAMP as load_timestamp,
        bp.UPDATE_TIMESTAMP as update_timestamp,
        bp.SOURCE_SYSTEM as source_system,
        -- Calculate data quality score with proper decimal precision
        CAST((
            CASE WHEN bp.PARTICIPANT_ID IS NOT NULL AND TRIM(bp.PARTICIPANT_ID) != '' THEN 0.25 ELSE 0 END +
            CASE WHEN bp.MEETING_ID IS NOT NULL AND TRIM(bp.MEETING_ID) != '' THEN 0.25 ELSE 0 END +
            CASE WHEN bp.USER_ID IS NOT NULL AND TRIM(bp.USER_ID) != '' THEN 0.25 ELSE 0 END +
            CASE WHEN bp.JOIN_TIME IS NOT NULL THEN 0.25 ELSE 0 END
        ) AS NUMBER(3,2)) as data_quality_score,
        CURRENT_DATE() as load_date,
        CURRENT_DATE() as update_date
    FROM bronze_participants bp
    LEFT JOIN {{ ref('si_meetings') }} m ON bp.MEETING_ID = m.meeting_id
    WHERE bp.rn = 1
    AND (bp.LEAVE_TIME IS NULL OR bp.LEAVE_TIME >= bp.JOIN_TIME)
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
FROM cleansed_participants
WHERE data_quality_score >= 0.75  -- Only accept high quality records
