{{ config(
    materialized='incremental',
    unique_key='meeting_id',
    on_schema_change='sync_all_columns'
) }}

-- Silver layer transformation for Meetings
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
    WHERE MEETING_ID IS NOT NULL
        AND HOST_ID IS NOT NULL
        AND START_TIME IS NOT NULL
        AND END_TIME IS NOT NULL
        AND END_TIME >= START_TIME
),

-- Get participant count
participant_counts AS (
    SELECT 
        MEETING_ID,
        COUNT(DISTINCT USER_ID) as PARTICIPANT_COUNT
    FROM {{ source('bronze', 'bz_participants') }}
    GROUP BY MEETING_ID
),

-- Get host names from users
host_info AS (
    SELECT 
        u.USER_ID,
        u.USER_NAME as HOST_NAME
    FROM {{ ref('si_users') }} u
),

-- Data Quality Checks and Cleansing
cleansed_meetings AS (
    SELECT 
        TRIM(m.MEETING_ID) as MEETING_ID,
        TRIM(m.HOST_ID) as HOST_ID,
        TRIM(m.MEETING_TOPIC) as MEETING_TOPIC,
        CASE 
            WHEN m.MEETING_TOPIC LIKE '%webinar%' THEN 'Webinar'
            WHEN m.MEETING_TOPIC LIKE '%instant%' THEN 'Instant'
            WHEN m.MEETING_TOPIC LIKE '%personal%' THEN 'Personal'
            ELSE 'Scheduled'
        END as MEETING_TYPE,
        m.START_TIME,
        m.END_TIME,
        GREATEST(DATEDIFF('minute', m.START_TIME, m.END_TIME), 0) as DURATION_MINUTES,
        COALESCE(h.HOST_NAME, 'Unknown Host') as HOST_NAME,
        CASE 
            WHEN m.END_TIME < CURRENT_TIMESTAMP() THEN 'Completed'
            WHEN m.START_TIME <= CURRENT_TIMESTAMP() AND m.END_TIME > CURRENT_TIMESTAMP() THEN 'In Progress'
            WHEN m.START_TIME > CURRENT_TIMESTAMP() THEN 'Scheduled'
            ELSE 'Unknown'
        END as MEETING_STATUS,
        'No' as RECORDING_STATUS,
        COALESCE(pc.PARTICIPANT_COUNT, 0) as PARTICIPANT_COUNT,
        m.LOAD_TIMESTAMP,
        m.UPDATE_TIMESTAMP,
        m.SOURCE_SYSTEM
    FROM bronze_meetings m
    LEFT JOIN participant_counts pc ON m.MEETING_ID = pc.MEETING_ID
    LEFT JOIN host_info h ON m.HOST_ID = h.USER_ID
),

-- Remove duplicates
deduped_meetings AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY MEETING_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) as rn
    FROM cleansed_meetings
),

-- Calculate data quality score
final_meetings AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        MEETING_TOPIC,
        MEETING_TYPE,
        START_TIME,
        END_TIME,
        DURATION_MINUTES,
        HOST_NAME,
        MEETING_STATUS,
        RECORDING_STATUS,
        PARTICIPANT_COUNT,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Calculate data quality score
        ROUND(
            (CASE WHEN MEETING_TOPIC IS NOT NULL THEN 0.3 ELSE 0 END +
             CASE WHEN HOST_NAME != 'Unknown Host' THEN 0.2 ELSE 0 END +
             CASE WHEN DURATION_MINUTES >= 0 THEN 0.2 ELSE 0 END +
             CASE WHEN PARTICIPANT_COUNT >= 0 THEN 0.2 ELSE 0 END +
             CASE WHEN MEETING_STATUS != 'Unknown' THEN 0.1 ELSE 0 END), 2
        ) as DATA_QUALITY_SCORE,
        DATE(LOAD_TIMESTAMP) as LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) as UPDATE_DATE
    FROM deduped_meetings
    WHERE rn = 1
)

SELECT * FROM final_meetings

{% if is_incremental() %}
    WHERE UPDATE_TIMESTAMP > (SELECT COALESCE(MAX(UPDATE_TIMESTAMP), '1900-01-01') FROM {{ this }})
{% endif %}
