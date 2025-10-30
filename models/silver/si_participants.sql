{{
  config(
    materialized='incremental',
    unique_key='participant_id',
    on_schema_change='sync_all_columns',
    pre_hook="INSERT INTO {{ ref('audit_log') }} (audit_id, source_table, process_start_time, status, processed_by, load_date, source_system) SELECT '{{ invocation_id }}', 'SI_PARTICIPANTS', CURRENT_TIMESTAMP(), 'STARTED', 'DBT', CURRENT_DATE(), 'DBT_PIPELINE' WHERE '{{ this.name }}' != 'audit_log'",
    post_hook="UPDATE {{ ref('audit_log') }} SET process_end_time = CURRENT_TIMESTAMP(), status = 'SUCCESS' WHERE audit_id = '{{ invocation_id }}' AND source_table = 'SI_PARTICIPANTS' AND '{{ this.name }}' != 'audit_log'"
  )
}}

WITH bronze_participants AS (
    SELECT *
    FROM {{ ref('bz_participants') }}
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
        {{ calculate_data_quality_score('si_participants', ['PARTICIPANT_ID', 'MEETING_ID', 'USER_ID', 'JOIN_TIME']) }} AS data_quality_score,
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
