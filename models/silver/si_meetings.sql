{{ config(
    materialized='table'
) }}

-- Silver layer transformation for Meetings
-- Source: BRONZE.BZ_MEETINGS -> Target: SILVER.SI_MEETINGS
-- Includes data quality validations and enrichment

WITH source_data AS (
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
    FROM {{ ref('bz_meetings') }}
    WHERE MEETING_ID IS NOT NULL
),

host_info AS (
    SELECT 
        USER_ID,
        USER_NAME
    FROM {{ ref('bz_users') }}
    WHERE USER_ID IS NOT NULL
),

participant_counts AS (
    SELECT 
        MEETING_ID,
        COUNT(DISTINCT USER_ID) AS participant_count
    FROM {{ ref('bz_participants') }}
    WHERE MEETING_ID IS NOT NULL
    GROUP BY MEETING_ID
),

data_quality_checks AS (
    SELECT 
        s.*,
        h.USER_NAME AS host_name,
        COALESCE(p.participant_count, 0) AS participant_count,
        
        -- Time validation
        CASE 
            WHEN START_TIME IS NULL THEN 0
            WHEN END_TIME IS NULL THEN 0
            WHEN END_TIME < START_TIME THEN 0
            ELSE 1
        END AS time_valid,
        
        -- Duration validation
        CASE 
            WHEN DURATION_MINUTES IS NULL THEN 0
            WHEN DURATION_MINUTES < 0 THEN 0
            WHEN DURATION_MINUTES > 1440 THEN 0  -- Max 24 hours
            ELSE 1
        END AS duration_valid,
        
        -- Host validation
        CASE 
            WHEN HOST_ID IS NULL THEN 0
            WHEN h.USER_NAME IS NULL THEN 0
            ELSE 1
        END AS host_valid
        
    FROM source_data s
    LEFT JOIN host_info h ON s.HOST_ID = h.USER_ID
    LEFT JOIN participant_counts p ON s.MEETING_ID = p.MEETING_ID
),

cleaned_data AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        
        -- Cleaned meeting topic
        CASE 
            WHEN MEETING_TOPIC IS NOT NULL AND TRIM(MEETING_TOPIC) != '' 
            THEN TRIM(MEETING_TOPIC)
            ELSE 'Untitled Meeting'
        END AS MEETING_TOPIC,
        
        -- Derived meeting type
        CASE 
            WHEN DURATION_MINUTES <= 5 THEN 'Instant'
            WHEN DURATION_MINUTES BETWEEN 6 AND 60 THEN 'Scheduled'
            WHEN DURATION_MINUTES > 60 THEN 'Webinar'
            ELSE 'Personal'
        END AS MEETING_TYPE,
        
        -- Validated timestamps
        CASE 
            WHEN time_valid = 1 THEN START_TIME
            ELSE NULL
        END AS START_TIME,
        
        CASE 
            WHEN time_valid = 1 THEN END_TIME
            ELSE NULL
        END AS END_TIME,
        
        -- Validated duration
        CASE 
            WHEN duration_valid = 1 THEN DURATION_MINUTES
            WHEN time_valid = 1 AND START_TIME IS NOT NULL AND END_TIME IS NOT NULL 
            THEN DATEDIFF('minute', START_TIME, END_TIME)
            ELSE NULL
        END AS DURATION_MINUTES,
        
        -- Host name
        COALESCE(host_name, 'Unknown Host') AS HOST_NAME,
        
        -- Meeting status
        CASE 
            WHEN END_TIME IS NOT NULL AND END_TIME < CURRENT_TIMESTAMP() THEN 'Completed'
            WHEN START_TIME IS NOT NULL AND START_TIME <= CURRENT_TIMESTAMP() AND 
                 (END_TIME IS NULL OR END_TIME > CURRENT_TIMESTAMP()) THEN 'In Progress'
            WHEN START_TIME IS NOT NULL AND START_TIME > CURRENT_TIMESTAMP() THEN 'Scheduled'
            ELSE 'Cancelled'
        END AS MEETING_STATUS,
        
        -- Recording status (derived)
        CASE 
            WHEN DURATION_MINUTES > 30 THEN 'Yes'
            ELSE 'No'
        END AS RECORDING_STATUS,
        
        participant_count AS PARTICIPANT_COUNT,
        
        -- Metadata
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data quality score
        ROUND((time_valid + duration_valid + host_valid) / 3.0, 2) AS DATA_QUALITY_SCORE,
        
        -- Standard metadata
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
        
    FROM data_quality_checks
    WHERE MEETING_ID IS NOT NULL
),

-- Deduplication
deduplicated_data AS (
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
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM deduplicated_data
WHERE DATA_QUALITY_SCORE >= 0.5  -- Only include records with acceptable quality
