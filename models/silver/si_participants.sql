{{ config(
    materialized='incremental',
    unique_key='participant_id',
    on_schema_change='sync_all_columns'
) }}

-- Silver layer transformation for Participants data with data quality validations
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
    
    {% if is_incremental() %}
    WHERE UPDATE_TIMESTAMP > (SELECT MAX(UPDATE_TIMESTAMP) FROM {{ this }})
    {% endif %}
),

-- Get meeting host information for role determination
meeting_hosts AS (
    SELECT 
        meeting_id,
        host_id
    FROM {{ ref('si_meetings') }}
),

-- Data quality validations and cleansing
cleansed_participants AS (
    SELECT 
        TRIM(bp.PARTICIPANT_ID) AS participant_id,
        TRIM(bp.MEETING_ID) AS meeting_id,
        TRIM(bp.USER_ID) AS user_id,
        bp.JOIN_TIME AS join_time,
        bp.LEAVE_TIME AS leave_time,
        CASE 
            WHEN bp.LEAVE_TIME IS NOT NULL AND bp.JOIN_TIME IS NOT NULL 
                AND bp.LEAVE_TIME >= bp.JOIN_TIME
            THEN DATEDIFF('minute', bp.JOIN_TIME, bp.LEAVE_TIME)
            ELSE 0
        END AS attendance_duration,
        CASE 
            WHEN bp.USER_ID = mh.host_id THEN 'Host'
            ELSE 'Participant'
        END AS participant_role,
        'Good' AS connection_quality,  -- Default value, can be enhanced with actual data
        bp.LOAD_TIMESTAMP AS load_timestamp,
        bp.UPDATE_TIMESTAMP AS update_timestamp,
        bp.SOURCE_SYSTEM AS source_system,
        -- Data quality score calculation
        CASE 
            WHEN bp.PARTICIPANT_ID IS NOT NULL 
                AND bp.MEETING_ID IS NOT NULL 
                AND bp.USER_ID IS NOT NULL 
                AND bp.JOIN_TIME IS NOT NULL
                AND (bp.LEAVE_TIME IS NULL OR bp.LEAVE_TIME >= bp.JOIN_TIME)
            THEN 1.00
            WHEN bp.PARTICIPANT_ID IS NOT NULL AND bp.MEETING_ID IS NOT NULL AND bp.USER_ID IS NOT NULL
            THEN 0.75
            WHEN bp.PARTICIPANT_ID IS NOT NULL AND bp.MEETING_ID IS NOT NULL
            THEN 0.50
            WHEN bp.PARTICIPANT_ID IS NOT NULL
            THEN 0.25
            ELSE 0.00
        END AS data_quality_score,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date
    FROM bronze_participants bp
    LEFT JOIN meeting_hosts mh ON bp.MEETING_ID = mh.meeting_id
    WHERE bp.PARTICIPANT_ID IS NOT NULL
        AND TRIM(bp.PARTICIPANT_ID) != ''
        AND bp.MEETING_ID IS NOT NULL
        AND bp.USER_ID IS NOT NULL
),

-- Deduplication using ROW_NUMBER to keep latest record
deduped_participants AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY participant_id 
            ORDER BY update_timestamp DESC, load_timestamp DESC
        ) AS row_num
    FROM cleansed_participants
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
FROM deduped_participants
WHERE row_num = 1
    AND data_quality_score >= 0.50  -- Minimum quality threshold
