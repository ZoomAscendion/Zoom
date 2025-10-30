{{ config(
    materialized='table',
    on_schema_change='sync_all_columns',
    pre_hook="DROP TABLE IF EXISTS {{ this }}"
) }}

-- Silver layer transformation for meetings with comprehensive data quality checks
WITH bronze_meetings AS (
    SELECT 
        bm.MEETING_ID,
        bm.HOST_ID,
        bm.MEETING_TOPIC,
        bm.START_TIME,
        bm.END_TIME,
        bm.DURATION_MINUTES,
        bm.LOAD_TIMESTAMP,
        bm.UPDATE_TIMESTAMP,
        bm.SOURCE_SYSTEM,
        -- Add row number for deduplication
        ROW_NUMBER() OVER (
            PARTITION BY bm.MEETING_ID 
            ORDER BY bm.UPDATE_TIMESTAMP DESC, bm.LOAD_TIMESTAMP DESC
        ) as rn
    FROM {{ source('bronze', 'bz_meetings') }} bm
    WHERE bm.MEETING_ID IS NOT NULL 
    AND TRIM(bm.MEETING_ID) != ''
    AND bm.START_TIME IS NOT NULL
    AND bm.END_TIME IS NOT NULL
    AND bm.END_TIME >= bm.START_TIME
),

-- Get participant count for each meeting
participant_counts AS (
    SELECT 
        MEETING_ID,
        COUNT(DISTINCT USER_ID) as participant_count
    FROM {{ source('bronze', 'bz_participants') }}
    WHERE MEETING_ID IS NOT NULL
    GROUP BY MEETING_ID
),

-- Data quality validation and cleansing
cleansed_meetings AS (
    SELECT 
        bm.MEETING_ID as meeting_id,
        bm.HOST_ID as host_id,
        TRIM(bm.MEETING_TOPIC) as meeting_topic,
        CASE 
            WHEN bm.MEETING_TOPIC LIKE '%Webinar%' THEN 'Webinar'
            WHEN bm.MEETING_TOPIC LIKE '%Personal%' THEN 'Personal'
            WHEN bm.START_TIME = bm.LOAD_TIMESTAMP THEN 'Instant'
            ELSE 'Scheduled'
        END as meeting_type,
        bm.START_TIME as start_time,
        bm.END_TIME as end_time,
        GREATEST(DATEDIFF('minute', bm.START_TIME, bm.END_TIME), 0) as duration_minutes,
        COALESCE(u.user_name, 'Unknown Host') as host_name,
        CASE 
            WHEN bm.END_TIME < CURRENT_TIMESTAMP() THEN 'Completed'
            WHEN bm.START_TIME <= CURRENT_TIMESTAMP() AND bm.END_TIME >= CURRENT_TIMESTAMP() THEN 'In Progress'
            WHEN bm.START_TIME > CURRENT_TIMESTAMP() THEN 'Scheduled'
            ELSE 'Cancelled'
        END as meeting_status,
        'No' as recording_status,  -- Default value, can be enhanced with actual data
        COALESCE(pc.participant_count, 0) as participant_count,
        bm.LOAD_TIMESTAMP as load_timestamp,
        bm.UPDATE_TIMESTAMP as update_timestamp,
        bm.SOURCE_SYSTEM as source_system,
        -- Calculate data quality score with proper decimal precision
        CAST((
            CASE WHEN bm.MEETING_ID IS NOT NULL AND TRIM(bm.MEETING_ID) != '' THEN 0.2 ELSE 0 END +
            CASE WHEN bm.HOST_ID IS NOT NULL AND TRIM(bm.HOST_ID) != '' THEN 0.2 ELSE 0 END +
            CASE WHEN bm.START_TIME IS NOT NULL THEN 0.2 ELSE 0 END +
            CASE WHEN bm.END_TIME IS NOT NULL AND bm.END_TIME >= bm.START_TIME THEN 0.2 ELSE 0 END +
            CASE WHEN DATEDIFF('minute', bm.START_TIME, bm.END_TIME) BETWEEN 0 AND 1440 THEN 0.2 ELSE 0 END
        ) AS NUMBER(3,2)) as data_quality_score,
        CURRENT_DATE() as load_date,
        CURRENT_DATE() as update_date
    FROM bronze_meetings bm
    LEFT JOIN {{ ref('si_users') }} u ON bm.HOST_ID = u.user_id
    LEFT JOIN participant_counts pc ON bm.MEETING_ID = pc.MEETING_ID
    WHERE bm.rn = 1
    AND bm.DURATION_MINUTES BETWEEN 0 AND 1440  -- Valid duration range
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
FROM cleansed_meetings
WHERE data_quality_score >= 0.8  -- Only accept high quality records
