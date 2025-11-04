{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, EXECUTED_BY, EXECUTION_ENVIRONMENT, DATA_LINEAGE_INFO, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT CONCAT('SILVER_MEETINGS_', DATE_PART('epoch', CURRENT_TIMESTAMP())::STRING), 'SI_MEETINGS_ETL', CURRENT_TIMESTAMP(), 'In Progress', 'BZ_MEETINGS,BZ_USERS,BZ_PARTICIPANTS', 'SI_MEETINGS', 'DBT_SILVER_PIPELINE', 'PRODUCTION', 'Bronze to Silver Meetings transformation', CURRENT_DATE(), CURRENT_DATE(), 'SILVER_LAYER' WHERE '{{ this.name }}' != 'si_pipeline_audit'",
    post_hook="UPDATE {{ ref('si_pipeline_audit') }} SET END_TIME = CURRENT_TIMESTAMP(), STATUS = 'Success', EXECUTION_DURATION_SECONDS = DATEDIFF('second', START_TIME, CURRENT_TIMESTAMP()), RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), RECORDS_INSERTED = (SELECT COUNT(*) FROM {{ this }}) WHERE PIPELINE_NAME = 'SI_MEETINGS_ETL' AND STATUS = 'In Progress' AND '{{ this.name }}' != 'si_pipeline_audit'"
) }}

-- Silver Layer Meetings Table
-- Cleaned and enriched meeting data with calculated metrics
-- Source: Bronze.BZ_MEETINGS, Bronze.BZ_USERS, Bronze.BZ_PARTICIPANTS
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

WITH bronze_meetings AS (
    SELECT *
    FROM {{ source('bronze', 'bz_meetings') }}
),

bronze_users AS (
    SELECT USER_ID, USER_NAME
    FROM {{ source('bronze', 'bz_users') }}
),

participant_counts AS (
    SELECT 
        MEETING_ID,
        COUNT(DISTINCT USER_ID) AS PARTICIPANT_COUNT
    FROM {{ source('bronze', 'bz_participants') }}
    WHERE MEETING_ID IS NOT NULL
    GROUP BY MEETING_ID
),

-- Data Quality Checks and Cleansing
cleansed_meetings AS (
    SELECT
        -- Primary identifier
        bm.MEETING_ID,
        bm.HOST_ID,
        
        -- Meeting details with standardization
        CASE 
            WHEN bm.MEETING_TOPIC IS NULL OR TRIM(bm.MEETING_TOPIC) = '' THEN 'Untitled Meeting'
            ELSE TRIM(bm.MEETING_TOPIC)
        END AS MEETING_TOPIC,
        
        -- Meeting type derivation
        CASE 
            WHEN bm.DURATION_MINUTES >= 60 THEN 'Scheduled'
            WHEN bm.DURATION_MINUTES BETWEEN 15 AND 59 THEN 'Instant'
            WHEN bm.DURATION_MINUTES < 15 THEN 'Personal'
            ELSE 'Unknown'
        END AS MEETING_TYPE,
        
        -- Validated timestamps
        CASE 
            WHEN bm.START_TIME IS NULL THEN CURRENT_TIMESTAMP()
            ELSE bm.START_TIME
        END AS START_TIME,
        
        CASE 
            WHEN bm.END_TIME IS NULL OR bm.END_TIME < bm.START_TIME 
                THEN DATEADD('minute', COALESCE(bm.DURATION_MINUTES, 30), bm.START_TIME)
            ELSE bm.END_TIME
        END AS END_TIME,
        
        -- Duration validation and calculation
        CASE 
            WHEN bm.DURATION_MINUTES IS NULL OR bm.DURATION_MINUTES < 0 
                THEN DATEDIFF('minute', bm.START_TIME, 
                    CASE WHEN bm.END_TIME < bm.START_TIME THEN DATEADD('minute', 30, bm.START_TIME) ELSE bm.END_TIME END)
            WHEN bm.DURATION_MINUTES > 1440 THEN 1440  -- Cap at 24 hours
            ELSE bm.DURATION_MINUTES
        END AS DURATION_MINUTES,
        
        -- Host name from users table
        COALESCE(bu.USER_NAME, 'Unknown Host') AS HOST_NAME,
        
        -- Meeting status derivation
        CASE 
            WHEN bm.END_TIME IS NULL OR bm.END_TIME > CURRENT_TIMESTAMP() THEN 'Scheduled'
            WHEN bm.START_TIME <= CURRENT_TIMESTAMP() AND bm.END_TIME > CURRENT_TIMESTAMP() THEN 'In Progress'
            WHEN bm.END_TIME <= CURRENT_TIMESTAMP() THEN 'Completed'
            ELSE 'Unknown'
        END AS MEETING_STATUS,
        
        -- Recording status derivation (simplified)
        CASE 
            WHEN bm.DURATION_MINUTES >= 30 THEN 'Yes'
            ELSE 'No'
        END AS RECORDING_STATUS,
        
        -- Participant count
        COALESCE(pc.PARTICIPANT_COUNT, 0) AS PARTICIPANT_COUNT,
        
        -- Metadata fields
        bm.LOAD_TIMESTAMP,
        bm.UPDATE_TIMESTAMP,
        bm.SOURCE_SYSTEM,
        
        -- Data quality score calculation
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
        
        -- Standard metadata
        COALESCE(bm.LOAD_TIMESTAMP::DATE, CURRENT_DATE()) AS LOAD_DATE,
        COALESCE(bm.UPDATE_TIMESTAMP::DATE, CURRENT_DATE()) AS UPDATE_DATE
        
    FROM bronze_meetings bm
    LEFT JOIN bronze_users bu ON bm.HOST_ID = bu.USER_ID
    LEFT JOIN participant_counts pc ON bm.MEETING_ID = pc.MEETING_ID
    WHERE bm.MEETING_ID IS NOT NULL  -- Block records without primary key
      AND bm.HOST_ID IS NOT NULL     -- Block meetings without host
),

-- Deduplication - keep latest record per meeting
deduped_meetings AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY MEETING_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM cleansed_meetings
)

-- Final selection with data quality validation
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
  AND DATA_QUALITY_SCORE >= 0.50  -- Minimum quality threshold
