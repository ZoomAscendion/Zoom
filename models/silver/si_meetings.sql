{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, EXECUTED_BY, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, LOAD_DATE) SELECT 'EXEC_' || REPLACE(CAST(CURRENT_TIMESTAMP() AS STRING), ' ', '_'), 'SI_MEETINGS_TRANSFORMATION', CURRENT_TIMESTAMP(), 'STARTED', 'DBT_PIPELINE', 'BZ_MEETINGS,BZ_USERS,BZ_PARTICIPANTS', 'SI_MEETINGS', CURRENT_DATE() WHERE EXISTS (SELECT 1 FROM {{ ref('audit_log') }} LIMIT 1)",
    post_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, END_TIME, STATUS, EXECUTED_BY, RECORDS_PROCESSED, LOAD_DATE) SELECT 'EXEC_' || REPLACE(CAST(CURRENT_TIMESTAMP() AS STRING), ' ', '_'), 'SI_MEETINGS_TRANSFORMATION', CURRENT_TIMESTAMP(), 'COMPLETED', 'DBT_PIPELINE', (SELECT COUNT(*) FROM {{ this }}), CURRENT_DATE() WHERE EXISTS (SELECT 1 FROM {{ ref('audit_log') }} LIMIT 1)"
) }}

-- Silver Layer Meetings Table Transformation
-- Source: Bronze.BZ_MEETINGS with enrichment from BZ_USERS and BZ_PARTICIPANTS

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
    FROM {{ source('bronze', 'BZ_MEETINGS') }}
),

host_info AS (
    SELECT 
        USER_ID,
        USER_NAME
    FROM {{ source('bronze', 'BZ_USERS') }}
),

participant_counts AS (
    SELECT 
        MEETING_ID,
        COUNT(DISTINCT USER_ID) AS PARTICIPANT_COUNT
    FROM {{ source('bronze', 'BZ_PARTICIPANTS') }}
    GROUP BY MEETING_ID
),

-- Data Quality Validation and Cleansing
validated_meetings AS (
    SELECT 
        bm.MEETING_ID,
        bm.HOST_ID,
        
        -- Meeting topic standardization
        CASE 
            WHEN bm.MEETING_TOPIC IS NULL OR TRIM(bm.MEETING_TOPIC) = '' 
            THEN 'Unknown Topic - needs enrichment'
            ELSE TRIM(bm.MEETING_TOPIC)
        END AS MEETING_TOPIC,
        
        -- Derive meeting type from duration and other attributes
        CASE 
            WHEN bm.DURATION_MINUTES <= 30 THEN 'Instant'
            WHEN bm.DURATION_MINUTES <= 60 THEN 'Scheduled'
            WHEN bm.DURATION_MINUTES > 60 THEN 'Webinar'
            ELSE 'Personal'
        END AS MEETING_TYPE,
        
        -- Validate and correct timestamps
        CASE 
            WHEN bm.START_TIME > DATEADD('day', 1, CURRENT_TIMESTAMP()) 
            THEN CURRENT_TIMESTAMP()
            ELSE bm.START_TIME
        END AS START_TIME,
        
        CASE 
            WHEN bm.END_TIME IS NULL 
            THEN DATEADD('hour', 1, bm.START_TIME)
            WHEN bm.END_TIME < bm.START_TIME 
            THEN DATEADD('minute', COALESCE(bm.DURATION_MINUTES, 60), bm.START_TIME)
            ELSE bm.END_TIME
        END AS END_TIME,
        
        -- Validate and recalculate duration
        CASE 
            WHEN bm.DURATION_MINUTES < 0 THEN ABS(bm.DURATION_MINUTES)
            WHEN bm.DURATION_MINUTES IS NULL AND bm.START_TIME IS NOT NULL AND bm.END_TIME IS NOT NULL
            THEN DATEDIFF('minute', bm.START_TIME, bm.END_TIME)
            WHEN bm.DURATION_MINUTES > 1440 THEN 1440  -- Cap at 24 hours
            ELSE COALESCE(bm.DURATION_MINUTES, 60)
        END AS DURATION_MINUTES,
        
        -- Host name from users table
        COALESCE(hi.USER_NAME, 'Unknown Host') AS HOST_NAME,
        
        -- Derive meeting status
        CASE 
            WHEN bm.END_TIME IS NULL AND bm.START_TIME <= CURRENT_TIMESTAMP() 
            THEN 'In Progress'
            WHEN bm.END_TIME IS NOT NULL AND bm.END_TIME <= CURRENT_TIMESTAMP() 
            THEN 'Completed'
            WHEN bm.START_TIME > CURRENT_TIMESTAMP() 
            THEN 'Scheduled'
            ELSE 'Cancelled'
        END AS MEETING_STATUS,
        
        -- Derive recording status (simplified logic)
        CASE 
            WHEN bm.DURATION_MINUTES > 30 THEN 'Yes'
            ELSE 'No'
        END AS RECORDING_STATUS,
        
        -- Participant count
        COALESCE(pc.PARTICIPANT_COUNT, 0) AS PARTICIPANT_COUNT,
        
        bm.LOAD_TIMESTAMP,
        bm.UPDATE_TIMESTAMP,
        bm.SOURCE_SYSTEM,
        
        -- Calculate data quality score
        CASE 
            WHEN bm.MEETING_ID IS NOT NULL 
                AND bm.HOST_ID IS NOT NULL
                AND bm.START_TIME IS NOT NULL
                AND bm.END_TIME IS NOT NULL
                AND bm.END_TIME >= bm.START_TIME
                AND bm.DURATION_MINUTES > 0
            THEN 1.00
            WHEN bm.MEETING_ID IS NOT NULL AND bm.HOST_ID IS NOT NULL
            THEN 0.75
            WHEN bm.MEETING_ID IS NOT NULL
            THEN 0.50
            ELSE 0.25
        END AS DATA_QUALITY_SCORE,
        
        DATE(bm.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(bm.UPDATE_TIMESTAMP) AS UPDATE_DATE,
        
        -- Add row number for deduplication
        ROW_NUMBER() OVER (PARTITION BY bm.MEETING_ID ORDER BY bm.UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_meetings bm
    LEFT JOIN host_info hi ON bm.HOST_ID = hi.USER_ID
    LEFT JOIN participant_counts pc ON bm.MEETING_ID = pc.MEETING_ID
    WHERE bm.MEETING_ID IS NOT NULL  -- Block records without MEETING_ID
        AND bm.HOST_ID IS NOT NULL   -- Block records without HOST_ID
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
WHERE rn = 1  -- Keep only the latest record per MEETING_ID
