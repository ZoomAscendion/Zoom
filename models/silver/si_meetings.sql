{{
  config(
    materialized='incremental',
    unique_key='meeting_id',
    on_schema_change='sync_all_columns'
  )
}}

WITH bronze_meetings AS (
    SELECT *
    FROM {{ source('bronze', 'bz_meetings') }}
    WHERE MEETING_ID IS NOT NULL
        AND START_TIME IS NOT NULL
        AND END_TIME IS NOT NULL
        AND END_TIME >= START_TIME
    {% if is_incremental() %}
        AND UPDATE_TIMESTAMP > (SELECT MAX(UPDATE_TIMESTAMP) FROM {{ this }})
    {% endif %}
),

participant_counts AS (
    SELECT 
        MEETING_ID,
        COUNT(DISTINCT USER_ID) AS participant_count
    FROM {{ source('bronze', 'bz_participants') }}
    GROUP BY MEETING_ID
),

cleaned_meetings AS (
    SELECT 
        bm.MEETING_ID AS meeting_id,
        bm.HOST_ID AS host_id,
        TRIM(COALESCE(bm.MEETING_TOPIC, 'No Topic')) AS meeting_topic,
        CASE 
            WHEN bm.DURATION_MINUTES <= 15 THEN 'INSTANT'
            WHEN bm.DURATION_MINUTES > 480 THEN 'WEBINAR'
            ELSE 'SCHEDULED'
        END AS meeting_type,
        bm.START_TIME AS start_time,
        bm.END_TIME AS end_time,
        COALESCE(bm.DURATION_MINUTES, DATEDIFF('minute', bm.START_TIME, bm.END_TIME)) AS duration_minutes,
        COALESCE(u.user_name, 'Unknown Host') AS host_name,
        CASE 
            WHEN bm.END_TIME < CURRENT_TIMESTAMP() THEN 'COMPLETED'
            WHEN bm.START_TIME <= CURRENT_TIMESTAMP() AND bm.END_TIME > CURRENT_TIMESTAMP() THEN 'IN_PROGRESS'
            WHEN bm.START_TIME > CURRENT_TIMESTAMP() THEN 'SCHEDULED'
            ELSE 'CANCELLED'
        END AS meeting_status,
        'NO' AS recording_status,
        COALESCE(pc.participant_count, 0) AS participant_count,
        bm.LOAD_TIMESTAMP,
        bm.UPDATE_TIMESTAMP,
        bm.SOURCE_SYSTEM,
        0.85 AS data_quality_score,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date
    FROM bronze_meetings bm
    LEFT JOIN {{ ref('si_users') }} u ON bm.HOST_ID = u.user_id
    LEFT JOIN participant_counts pc ON bm.MEETING_ID = pc.MEETING_ID
),

deduped_meetings AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY meeting_id ORDER BY update_timestamp DESC) AS rn
    FROM cleaned_meetings
)

SELECT 
    meeting_id,
    host_id,
    meeting_topic,
    meeting_type,
    start_time,
    end_time,
    duration_minutes,
    host_name,
    meeting_status,
    recording_status,
    participant_count,
    load_timestamp,
    update_timestamp,
    source_system,
    data_quality_score,
    load_date,
    update_date
FROM deduped_meetings
WHERE rn = 1
