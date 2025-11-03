{{ config(
    materialized='table'
) }}

-- Pre-hook: Log process start
{% if this.name != 'audit_log' %}
{{ log("Starting transformation for si_meetings", info=True) }}
{% endif %}

WITH source_data AS (
    SELECT 
        m.MEETING_ID,
        m.HOST_ID,
        m.MEETING_TOPIC,
        m.START_TIME,
        m.END_TIME,
        m.DURATION_MINUTES,
        m.LOAD_TIMESTAMP,
        m.UPDATE_TIMESTAMP,
        m.SOURCE_SYSTEM,
        u.USER_NAME AS HOST_NAME
    FROM {{ ref('bz_meetings') }} m
    LEFT JOIN {{ ref('bz_users') }} u ON m.HOST_ID = u.USER_ID
    WHERE m.MEETING_ID IS NOT NULL
),

participant_counts AS (
    SELECT 
        MEETING_ID,
        COUNT(DISTINCT USER_ID) AS PARTICIPANT_COUNT
    FROM {{ ref('bz_participants') }}
    WHERE MEETING_ID IS NOT NULL
    GROUP BY MEETING_ID
),

data_quality_checks AS (
    SELECT 
        s.*,
        pc.PARTICIPANT_COUNT,
        
        -- Time validation
        CASE 
            WHEN s.START_TIME IS NOT NULL AND s.END_TIME IS NOT NULL 
                 AND s.END_TIME >= s.START_TIME THEN 1
            ELSE 0
        END AS time_valid,
        
        -- Duration validation
        CASE 
            WHEN s.DURATION_MINUTES >= 1 AND s.DURATION_MINUTES <= 1440 THEN 1
            ELSE 0
        END AS duration_valid,
        
        -- Host validation
        CASE 
            WHEN s.HOST_ID IS NOT NULL AND s.HOST_NAME IS NOT NULL THEN 1
            ELSE 0
        END AS host_valid
    FROM source_data s
    LEFT JOIN participant_counts pc ON s.MEETING_ID = pc.MEETING_ID
),

cleaned_data AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        
        -- Clean meeting topic
        CASE 
            WHEN MEETING_TOPIC IS NOT NULL AND TRIM(MEETING_TOPIC) != '' 
            THEN TRIM(MEETING_TOPIC)
            ELSE 'UNTITLED_MEETING'
        END AS MEETING_TOPIC,
        
        -- Derive meeting type from duration
        CASE 
            WHEN DURATION_MINUTES <= 30 THEN 'Instant'
            WHEN DURATION_MINUTES <= 60 THEN 'Scheduled'
            WHEN DURATION_MINUTES <= 240 THEN 'Webinar'
            ELSE 'Personal'
        END AS MEETING_TYPE,
        
        -- Validate and clean timestamps
        CASE 
            WHEN time_valid = 1 THEN START_TIME
            ELSE NULL
        END AS START_TIME,
        
        CASE 
            WHEN time_valid = 1 THEN END_TIME
            WHEN START_TIME IS NOT NULL AND DURATION_MINUTES > 0 
            THEN DATEADD('minute', DURATION_MINUTES, START_TIME)
            ELSE NULL
        END AS END_TIME,
        
        -- Validate and recalculate duration
        CASE 
            WHEN duration_valid = 1 THEN DURATION_MINUTES
            WHEN time_valid = 1 AND START_TIME IS NOT NULL AND END_TIME IS NOT NULL
            THEN DATEDIFF('minute', START_TIME, END_TIME)
            ELSE NULL
        END AS DURATION_MINUTES,
        
        -- Host name
        COALESCE(HOST_NAME, 'UNKNOWN_HOST') AS HOST_NAME,
        
        -- Meeting status based on timestamps
        CASE 
            WHEN END_TIME IS NOT NULL AND END_TIME < CURRENT_TIMESTAMP() THEN 'Completed'
            WHEN START_TIME IS NOT NULL AND START_TIME <= CURRENT_TIMESTAMP() 
                 AND (END_TIME IS NULL OR END_TIME > CURRENT_TIMESTAMP()) THEN 'In Progress'
            WHEN START_TIME IS NOT NULL AND START_TIME > CURRENT_TIMESTAMP() THEN 'Scheduled'
            ELSE 'Cancelled'
        END AS MEETING_STATUS,
        
        -- Recording status (derived)
        CASE 
            WHEN MEETING_TOPIC LIKE '%RECORD%' OR MEETING_TOPIC LIKE '%REC%' THEN 'Yes'
            ELSE 'No'
        END AS RECORDING_STATUS,
        
        -- Participant count
        COALESCE(PARTICIPANT_COUNT, 0) AS PARTICIPANT_COUNT,
        
        -- Calculate data quality score
        ROUND((time_valid + duration_valid + host_valid) / 3.0, 2) AS DATA_QUALITY_SCORE,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at
        
    FROM data_quality_checks
    WHERE MEETING_ID IS NOT NULL  -- Remove records with null primary key
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY MEETING_ID 
            ORDER BY UPDATE_TIMESTAMP DESC
        ) AS row_num
    FROM cleaned_data
    QUALIFY row_num = 1
)

-- Final SELECT
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
    DATA_QUALITY_SCORE,
    LOAD_DATE,
    UPDATE_DATE,
    created_at,
    updated_at
FROM deduplication

-- Post-hook: Log process completion
{% if this.name != 'audit_log' %}
{{ log("Completed transformation for si_meetings", info=True) }}
{% endif %}
