{{
  config(
    materialized='incremental',
    unique_key='participant_id',
    on_schema_change='sync_all_columns'
  )
}}

WITH bronze_participants AS (
    SELECT *
    FROM {{ source('bronze', 'bz_participants') }}
    WHERE PARTICIPANT_ID IS NOT NULL
        AND MEETING_ID IS NOT NULL
        AND USER_ID IS NOT NULL
        AND JOIN_TIME IS NOT NULL
    {% if is_incremental() %}
        AND UPDATE_TIMESTAMP > (SELECT MAX(UPDATE_TIMESTAMP) FROM {{ this }})
    {% endif %}
),

cleaned_participants AS (
    SELECT 
        bp.PARTICIPANT_ID AS participant_id,
        bp.MEETING_ID AS meeting_id,
        bp.USER_ID AS user_id,
        bp.JOIN_TIME AS join_time,
        bp.LEAVE_TIME AS leave_time,
        CASE 
            WHEN bp.LEAVE_TIME IS NOT NULL 
            THEN DATEDIFF('minute', bp.JOIN_TIME, bp.LEAVE_TIME)
            ELSE 0
        END AS attendance_duration,
        CASE 
            WHEN bp.USER_ID = m.host_id THEN 'HOST'
            ELSE 'PARTICIPANT'
        END AS participant_role,
        'GOOD' AS connection_quality,
        bp.LOAD_TIMESTAMP,
        bp.UPDATE_TIMESTAMP,
        bp.SOURCE_SYSTEM,
        CAST(0.90 AS NUMBER(3,2)) AS data_quality_score,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date
    FROM bronze_participants bp
    LEFT JOIN {{ ref('si_meetings') }} m ON bp.MEETING_ID = m.meeting_id
),

deduped_participants AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY participant_id ORDER BY update_timestamp DESC) AS rn
    FROM cleaned_participants
    WHERE (leave_time IS NULL OR leave_time >= join_time)
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
WHERE rn = 1
