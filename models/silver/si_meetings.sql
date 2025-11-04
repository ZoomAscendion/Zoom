{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ target.schema }}.SI_PIPELINE_AUDIT (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, SOURCE_TABLES_PROCESSED, EXECUTED_BY, EXECUTION_ENVIRONMENT) VALUES (GENERATE_UUID(), 'SI_MEETINGS_TRANSFORM', CURRENT_TIMESTAMP(), 'RUNNING', 'BZ_MEETINGS,BZ_USERS,BZ_PARTICIPANTS', 'DBT_SYSTEM', 'PRODUCTION')",
    post_hook="UPDATE {{ target.schema }}.SI_PIPELINE_AUDIT SET END_TIME = CURRENT_TIMESTAMP(), STATUS = 'SUCCESS', EXECUTION_DURATION_SECONDS = DATEDIFF('second', START_TIME, CURRENT_TIMESTAMP()), RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}) WHERE PIPELINE_NAME = 'SI_MEETINGS_TRANSFORM' AND STATUS = 'RUNNING'"
) }}

-- Silver Layer Meetings Transformation
-- Source: Bronze.BZ_MEETINGS, BZ_USERS, BZ_PARTICIPANTS
-- Target: Silver.SI_MEETINGS
-- Description: Clean, validate and enrich meeting data with host information and participant counts

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
    FROM {{ ref('bz_meetings') }}
    WHERE MEETING_ID IS NOT NULL
      AND HOST_ID IS NOT NULL
      AND START_TIME IS NOT NULL
),

host_info AS (
    SELECT 
        USER_ID,
        USER_NAME
    FROM {{ ref('si_users') }}
),

participant_counts AS (
    SELECT 
        MEETING_ID,
        COUNT(DISTINCT USER_ID) AS PARTICIPANT_COUNT
    FROM {{ ref('bz_participants') }}
    WHERE MEETING_ID IS NOT NULL
      AND USER_ID IS NOT NULL
    GROUP BY MEETING_ID
),

-- Data Quality Validation and Cleansing
validated_meetings AS (
    SELECT 
        m.MEETING_ID,
        m.HOST_ID,
        
        -- Clean meeting topic
        CASE 
            WHEN m.MEETING_TOPIC IS NULL OR TRIM(m.MEETING_TOPIC) = '' THEN 'Untitled Meeting'
            ELSE TRIM(m.MEETING_TOPIC)
        END AS MEETING_TOPIC,
        
        -- Derive meeting type from duration
        CASE 
            WHEN m.DURATION_MINUTES <= 30 THEN 'Instant'
            WHEN m.DURATION_MINUTES <= 60 THEN 'Scheduled'
            WHEN m.DURATION_MINUTES > 60 THEN 'Webinar'
            ELSE 'Personal'
        END AS MEETING_TYPE,
        
        -- Validate timestamps
        CASE 
            WHEN m.START_TIME > CURRENT_TIMESTAMP() THEN CURRENT_TIMESTAMP()
            ELSE m.START_TIME
        END AS START_TIME,
        
        CASE 
            WHEN m.END_TIME IS NULL THEN DATEADD('minute', COALESCE(m.DURATION_MINUTES, 60), m.START_TIME)
            WHEN m.END_TIME < m.START_TIME THEN DATEADD('minute', COALESCE(m.DURATION_MINUTES, 60), m.START_TIME)
            ELSE m.END_TIME
        END AS END_TIME,
        
        -- Recalculate duration if needed
        CASE 
            WHEN m.DURATION_MINUTES IS NULL OR m.DURATION_MINUTES <= 0 THEN 
                DATEDIFF('minute', m.START_TIME, 
                    CASE 
                        WHEN m.END_TIME IS NULL OR m.END_TIME < m.START_TIME 
                        THEN DATEADD('minute', 60, m.START_TIME)
                        ELSE m.END_TIME
                    END
                )
            ELSE m.DURATION_MINUTES
        END AS DURATION_MINUTES,
        
        -- Get host name
        COALESCE(h.USER_NAME, 'Unknown Host') AS HOST_NAME,
        
        -- Derive meeting status
        CASE 
            WHEN m.END_TIME IS NULL OR m.END_TIME > CURRENT_TIMESTAMP() THEN 'In Progress'
            WHEN m.END_TIME <= CURRENT_TIMESTAMP() THEN 'Completed'
            ELSE 'Scheduled'
        END AS MEETING_STATUS,
        
        -- Default recording status
        'No' AS RECORDING_STATUS,
        
        -- Get participant count
        COALESCE(pc.PARTICIPANT_COUNT, 0) AS PARTICIPANT_COUNT,
        
        m.LOAD_TIMESTAMP,
        m.UPDATE_TIMESTAMP,
        m.SOURCE_SYSTEM,
        
        -- Calculate data quality score
        (
            CASE WHEN m.MEETING_ID IS NOT NULL THEN 0.20 ELSE 0 END +
            CASE WHEN m.HOST_ID IS NOT NULL THEN 0.20 ELSE 0 END +
            CASE WHEN m.START_TIME IS NOT NULL THEN 0.20 ELSE 0 END +
            CASE WHEN m.DURATION_MINUTES > 0 THEN 0.20 ELSE 0 END +
            CASE WHEN m.MEETING_TOPIC IS NOT NULL AND TRIM(m.MEETING_TOPIC) != '' THEN 0.20 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        DATE(m.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(m.UPDATE_TIMESTAMP) AS UPDATE_DATE,
        
        ROW_NUMBER() OVER (PARTITION BY m.MEETING_ID ORDER BY m.UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_meetings m
    LEFT JOIN host_info h ON m.HOST_ID = h.USER_ID
    LEFT JOIN participant_counts pc ON m.MEETING_ID = pc.MEETING_ID
)

-- Final selection with deduplication
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
    UPDATE_DATE
FROM validated_meetings
WHERE rn = 1
  AND DATA_QUALITY_SCORE >= 0.60  -- Only include records with acceptable quality
