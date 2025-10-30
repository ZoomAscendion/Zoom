{{ config(
    materialized='incremental',
    unique_key='participant_id',
    on_schema_change='sync_all_columns'
) }}

-- Silver layer transformation for participants with data quality checks and deduplication
WITH bronze_participants AS (
    SELECT 
        participant_id,
        meeting_id,
        user_id,
        join_time,
        leave_time,
        load_timestamp,
        update_timestamp,
        source_system,
        ROW_NUMBER() OVER (PARTITION BY participant_id ORDER BY update_timestamp DESC, load_timestamp DESC) as rn
    FROM {{ source('bronze', 'bz_participants') }}
    WHERE participant_id IS NOT NULL 
    AND TRIM(participant_id) != ''
    AND meeting_id IS NOT NULL
    AND user_id IS NOT NULL
    AND join_time IS NOT NULL
    AND (leave_time IS NULL OR leave_time >= join_time)
    {% if is_incremental() %}
        AND (update_timestamp > (SELECT COALESCE(MAX(update_timestamp), '1900-01-01') FROM {{ this }})
             OR load_timestamp > (SELECT COALESCE(MAX(load_timestamp), '1900-01-01') FROM {{ this }}))
    {% endif %}
),

deduped_participants AS (
    SELECT 
        participant_id,
        meeting_id,
        user_id,
        join_time,
        leave_time,
        load_timestamp,
        update_timestamp,
        source_system
    FROM bronze_participants
    WHERE rn = 1
),

validated_participants AS (
    SELECT 
        p.participant_id,
        p.meeting_id,
        p.user_id,
        p.join_time,
        COALESCE(p.leave_time, CURRENT_TIMESTAMP()) AS leave_time,
        CASE 
            WHEN p.leave_time IS NOT NULL 
            THEN DATEDIFF('minute', p.join_time, p.leave_time)
            ELSE DATEDIFF('minute', p.join_time, CURRENT_TIMESTAMP())
        END AS attendance_duration,
        CASE 
            WHEN p.user_id = m.host_id THEN 'Host'
            ELSE 'Participant'
        END AS participant_role,
        'Good' AS connection_quality,
        p.load_timestamp,
        p.update_timestamp,
        p.source_system
    FROM deduped_participants p
    LEFT JOIN {{ ref('si_meetings') }} m ON p.meeting_id = m.meeting_id
    LEFT JOIN {{ ref('si_users') }} u ON p.user_id = u.user_id
    WHERE m.meeting_id IS NOT NULL
    AND u.user_id IS NOT NULL
),

final_participants AS (
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
        -- Calculate data quality score
        CAST(ROUND(
            (CASE WHEN participant_id IS NOT NULL THEN 0.25 ELSE 0 END +
             CASE WHEN meeting_id IS NOT NULL THEN 0.25 ELSE 0 END +
             CASE WHEN user_id IS NOT NULL THEN 0.25 ELSE 0 END +
             CASE WHEN attendance_duration >= 0 THEN 0.25 ELSE 0 END), 2
        ) AS NUMBER(3,2)) AS data_quality_score,
        DATE(load_timestamp) AS load_date,
        DATE(update_timestamp) AS update_date
    FROM validated_participants
)

SELECT * FROM final_participants
