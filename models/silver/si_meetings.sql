{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, EXECUTED_BY, EXECUTION_ENVIRONMENT, DATA_LINEAGE_INFO, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT CONCAT('EXEC_', TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), '_MTG'), 'Silver_Meetings_ETL', CURRENT_TIMESTAMP(), 'Started', 'BRONZE.BZ_MEETINGS,BRONZE.BZ_USERS,BRONZE.BZ_PARTICIPANTS', 'SILVER.SI_MEETINGS', 'DBT_SILVER_PIPELINE', 'PRODUCTION', 'Processing meetings data from Bronze to Silver', CURRENT_DATE(), CURRENT_DATE(), 'ZOOM_PLATFORM' WHERE '{{ this.name }}' != 'si_pipeline_audit'",
    post_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (EXECUTION_ID, PIPELINE_NAME, END_TIME, STATUS, RECORDS_PROCESSED, RECORDS_INSERTED, EXECUTED_BY, EXECUTION_ENVIRONMENT, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT CONCAT('EXEC_', TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), '_MTG_END'), 'Silver_Meetings_ETL', CURRENT_TIMESTAMP(), 'Completed', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 'DBT_SILVER_PIPELINE', 'PRODUCTION', CURRENT_DATE(), CURRENT_DATE(), 'ZOOM_PLATFORM' WHERE '{{ this.name }}' != 'si_pipeline_audit'"
) }}

-- Silver Meetings Table Transformation
-- Transforms Bronze meetings data with enrichment and data quality validations

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
),

-- Get host names from users
host_info AS (
    SELECT 
        USER_ID,
        USER_NAME
    FROM {{ ref('si_users') }}
),

-- Get participant counts
participant_counts AS (
    SELECT 
        MEETING_ID,
        COUNT(DISTINCT USER_ID) AS PARTICIPANT_COUNT
    FROM {{ source('bronze', 'bz_participants') }}
    WHERE MEETING_ID IS NOT NULL
    GROUP BY MEETING_ID
),

-- Data Quality Validations and Transformations
validated_meetings AS (
    SELECT 
        m.MEETING_ID,
        m.HOST_ID,
        
        -- Standardize meeting topic
        CASE 
            WHEN m.MEETING_TOPIC IS NULL OR TRIM(m.MEETING_TOPIC) = '' THEN 'Untitled Meeting'
            ELSE TRIM(m.MEETING_TOPIC)
        END AS MEETING_TOPIC,
        
        -- Derive meeting type from duration
        CASE 
            WHEN m.DURATION_MINUTES <= 30 THEN 'Instant'
            WHEN m.DURATION_MINUTES <= 60 THEN 'Scheduled'
            WHEN m.DURATION_MINUTES > 120 THEN 'Webinar'
            ELSE 'Personal'
        END AS MEETING_TYPE,
        
        -- Validate and correct timestamps
        CASE 
            WHEN m.START_TIME > CURRENT_TIMESTAMP() THEN CURRENT_TIMESTAMP()
            ELSE m.START_TIME
        END AS START_TIME,
        
        CASE 
            WHEN m.END_TIME < m.START_TIME THEN DATEADD('minute', COALESCE(m.DURATION_MINUTES, 60), m.START_TIME)
            WHEN m.END_TIME > CURRENT_TIMESTAMP() THEN CURRENT_TIMESTAMP()
            ELSE m.END_TIME
        END AS END_TIME,
        
        -- Recalculate duration if needed
        CASE 
            WHEN m.DURATION_MINUTES < 0 THEN DATEDIFF('minute', m.START_TIME, m.END_TIME)
            WHEN m.DURATION_MINUTES IS NULL THEN DATEDIFF('minute', m.START_TIME, m.END_TIME)
            ELSE m.DURATION_MINUTES
        END AS DURATION_MINUTES,
        
        -- Get host name
        COALESCE(h.USER_NAME, 'Unknown Host') AS HOST_NAME,
        
        -- Derive meeting status
        CASE 
            WHEN m.END_TIME < CURRENT_TIMESTAMP() THEN 'Completed'
            WHEN m.START_TIME <= CURRENT_TIMESTAMP() AND m.END_TIME >= CURRENT_TIMESTAMP() THEN 'In Progress'
            WHEN m.START_TIME > CURRENT_TIMESTAMP() THEN 'Scheduled'
            ELSE 'Cancelled'
        END AS MEETING_STATUS,
        
        -- Derive recording status (simplified logic)
        CASE 
            WHEN m.DURATION_MINUTES > 60 THEN 'Yes'
            ELSE 'No'
        END AS RECORDING_STATUS,
        
        -- Get participant count
        COALESCE(pc.PARTICIPANT_COUNT, 0) AS PARTICIPANT_COUNT,
        
        m.LOAD_TIMESTAMP,
        m.UPDATE_TIMESTAMP,
        m.SOURCE_SYSTEM,
        
        -- Calculate data quality score
        (
            CASE WHEN m.MEETING_ID IS NOT NULL THEN 0.2 ELSE 0 END +
            CASE WHEN m.HOST_ID IS NOT NULL THEN 0.2 ELSE 0 END +
            CASE WHEN m.START_TIME IS NOT NULL THEN 0.2 ELSE 0 END +
            CASE WHEN m.END_TIME IS NOT NULL AND m.END_TIME >= m.START_TIME THEN 0.2 ELSE 0 END +
            CASE WHEN m.DURATION_MINUTES >= 0 THEN 0.2 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        DATE(m.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(m.UPDATE_TIMESTAMP) AS UPDATE_DATE
        
    FROM bronze_meetings m
    LEFT JOIN host_info h ON m.HOST_ID = h.USER_ID
    LEFT JOIN participant_counts pc ON m.MEETING_ID = pc.MEETING_ID
),

-- Remove duplicates
deduped_meetings AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY MEETING_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM validated_meetings
)

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
FROM deduped_meetings
WHERE rn = 1
  AND START_TIME IS NOT NULL
  AND END_TIME IS NOT NULL
  AND END_TIME >= START_TIME
  AND DURATION_MINUTES >= 0
  AND DATA_QUALITY_SCORE >= 0.6
