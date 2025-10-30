{{ config(
    materialized='incremental',
    unique_key='meeting_id',
    on_schema_change='sync_all_columns'
) }}

-- Silver layer transformation for Meetings data with data quality validations
WITH bronze_meetings AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        MEETING_TOPIC,
        START_TIME,
        END_TIME,
        DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('bronze', 'bz_meetings') }}
    
    {% if is_incremental() %}
    WHERE UPDATE_TIMESTAMP > (SELECT MAX(UPDATE_TIMESTAMP) FROM {{ this }})
    {% endif %}
),

-- Get participant count from participants table
participant_counts AS (
    SELECT 
        MEETING_ID,
        COUNT(DISTINCT USER_ID) AS participant_count
    FROM {{ source('bronze', 'bz_participants') }}
    GROUP BY MEETING_ID
),

-- Get host name from users table
host_info AS (
    SELECT 
        user_id,
        user_name
    FROM {{ ref('si_users') }}
),

-- Data quality validations and cleansing
cleansed_meetings AS (
    SELECT 
        TRIM(bm.MEETING_ID) AS meeting_id,
        TRIM(bm.HOST_ID) AS host_id,
        TRIM(bm.MEETING_TOPIC) AS meeting_topic,
        CASE 
            WHEN bm.MEETING_TOPIC LIKE '%Webinar%' THEN 'Webinar'
            WHEN bm.MEETING_TOPIC LIKE '%Personal%' THEN 'Personal'
            WHEN bm.START_TIME = bm.LOAD_TIMESTAMP THEN 'Instant'
            ELSE 'Scheduled'
        END AS meeting_type,
        bm.START_TIME AS start_time,
        bm.END_TIME AS end_time,
        CASE 
            WHEN bm.DURATION_MINUTES BETWEEN 0 AND 1440 THEN bm.DURATION_MINUTES
            WHEN bm.END_TIME > bm.START_TIME THEN DATEDIFF('minute', bm.START_TIME, bm.END_TIME)
            ELSE 0
        END AS duration_minutes,
        COALESCE(hi.user_name, 'Unknown Host') AS host_name,
        CASE 
            WHEN bm.END_TIME < CURRENT_TIMESTAMP() THEN 'Completed'
            WHEN bm.START_TIME <= CURRENT_TIMESTAMP() AND bm.END_TIME > CURRENT_TIMESTAMP() THEN 'In Progress'
            WHEN bm.START_TIME > CURRENT_TIMESTAMP() THEN 'Scheduled'
            ELSE 'Cancelled'
        END AS meeting_status,
        'No' AS recording_status,  -- Default value, can be enhanced with actual data
        COALESCE(pc.participant_count, 0) AS participant_count,
        bm.LOAD_TIMESTAMP AS load_timestamp,
        bm.UPDATE_TIMESTAMP AS update_timestamp,
        bm.SOURCE_SYSTEM AS source_system,
        -- Data quality score calculation
        CASE 
            WHEN bm.MEETING_ID IS NOT NULL 
                AND bm.HOST_ID IS NOT NULL 
                AND bm.START_TIME IS NOT NULL 
                AND bm.END_TIME IS NOT NULL 
                AND bm.END_TIME >= bm.START_TIME
                AND bm.DURATION_MINUTES >= 0
            THEN 1.00
            WHEN bm.MEETING_ID IS NOT NULL AND bm.HOST_ID IS NOT NULL AND bm.START_TIME IS NOT NULL
            THEN 0.75
            WHEN bm.MEETING_ID IS NOT NULL AND bm.HOST_ID IS NOT NULL
            THEN 0.50
            WHEN bm.MEETING_ID IS NOT NULL
            THEN 0.25
            ELSE 0.00
        END AS data_quality_score,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date
    FROM bronze_meetings bm
    LEFT JOIN participant_counts pc ON bm.MEETING_ID = pc.MEETING_ID
    LEFT JOIN host_info hi ON bm.HOST_ID = hi.user_id
    WHERE bm.MEETING_ID IS NOT NULL
        AND TRIM(bm.MEETING_ID) != ''
        AND bm.START_TIME IS NOT NULL
),

-- Deduplication using ROW_NUMBER to keep latest record
deduped_meetings AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY meeting_id 
            ORDER BY update_timestamp DESC, load_timestamp DESC
        ) AS row_num
    FROM cleansed_meetings
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
WHERE row_num = 1
    AND data_quality_score >= 0.50  -- Minimum quality threshold
