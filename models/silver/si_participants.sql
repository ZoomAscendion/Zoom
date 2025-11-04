{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, EXECUTED_BY, EXECUTION_ENVIRONMENT, DATA_LINEAGE_INFO, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT CONCAT('SILVER_PARTICIPANTS_', DATE_PART('epoch', CURRENT_TIMESTAMP())::STRING), 'SI_PARTICIPANTS_ETL', CURRENT_TIMESTAMP(), 'In Progress', 'BZ_PARTICIPANTS', 'SI_PARTICIPANTS', 'DBT_SILVER_PIPELINE', 'PRODUCTION', 'Bronze to Silver Participants transformation', CURRENT_DATE(), CURRENT_DATE(), 'SILVER_LAYER' WHERE '{{ this.name }}' != 'si_pipeline_audit'",
    post_hook="UPDATE {{ ref('si_pipeline_audit') }} SET END_TIME = CURRENT_TIMESTAMP(), STATUS = 'Success', EXECUTION_DURATION_SECONDS = DATEDIFF('second', START_TIME, CURRENT_TIMESTAMP()), RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), RECORDS_INSERTED = (SELECT COUNT(*) FROM {{ this }}) WHERE PIPELINE_NAME = 'SI_PARTICIPANTS_ETL' AND STATUS = 'In Progress' AND '{{ this.name }}' != 'si_pipeline_audit'"
) }}

-- Silver Layer Participants Table
-- Cleaned participant attendance data with calculated metrics
-- Source: Bronze.BZ_PARTICIPANTS
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

WITH bronze_participants AS (
    SELECT *
    FROM {{ source('bronze', 'bz_participants') }}
),

-- Data Quality Checks and Cleansing
cleansed_participants AS (
    SELECT
        -- Primary identifiers
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        
        -- Validated timestamps
        CASE 
            WHEN JOIN_TIME IS NULL THEN CURRENT_TIMESTAMP()
            ELSE JOIN_TIME
        END AS JOIN_TIME,
        
        CASE 
            WHEN LEAVE_TIME IS NULL OR LEAVE_TIME < JOIN_TIME 
                THEN DATEADD('minute', 30, JOIN_TIME)  -- Default 30 minute session
            ELSE LEAVE_TIME
        END AS LEAVE_TIME,
        
        -- Calculated attendance duration
        CASE 
            WHEN LEAVE_TIME IS NULL OR LEAVE_TIME < JOIN_TIME 
                THEN 30  -- Default duration
            ELSE DATEDIFF('minute', JOIN_TIME, LEAVE_TIME)
        END AS ATTENDANCE_DURATION,
        
        -- Participant role derivation (simplified)
        CASE 
            WHEN USER_ID IS NOT NULL THEN 'Participant'
            ELSE 'Observer'
        END AS PARTICIPANT_ROLE,
        
        -- Connection quality derivation based on attendance duration
        CASE 
            WHEN DATEDIFF('minute', JOIN_TIME, COALESCE(LEAVE_TIME, DATEADD('minute', 30, JOIN_TIME))) >= 60 THEN 'Excellent'
            WHEN DATEDIFF('minute', JOIN_TIME, COALESCE(LEAVE_TIME, DATEADD('minute', 30, JOIN_TIME))) >= 30 THEN 'Good'
            WHEN DATEDIFF('minute', JOIN_TIME, COALESCE(LEAVE_TIME, DATEADD('minute', 30, JOIN_TIME))) >= 10 THEN 'Fair'
            ELSE 'Poor'
        END AS CONNECTION_QUALITY,
        
        -- Metadata fields
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data quality score calculation
        CASE 
            WHEN PARTICIPANT_ID IS NOT NULL 
                AND MEETING_ID IS NOT NULL
                AND USER_ID IS NOT NULL
                AND JOIN_TIME IS NOT NULL
                AND LEAVE_TIME IS NOT NULL
                AND LEAVE_TIME >= JOIN_TIME
                THEN 1.00
            WHEN PARTICIPANT_ID IS NOT NULL AND MEETING_ID IS NOT NULL AND USER_ID IS NOT NULL
                THEN 0.75
            WHEN PARTICIPANT_ID IS NOT NULL AND MEETING_ID IS NOT NULL
                THEN 0.50
            ELSE 0.25
        END AS DATA_QUALITY_SCORE,
        
        -- Standard metadata
        COALESCE(LOAD_TIMESTAMP::DATE, CURRENT_DATE()) AS LOAD_DATE,
        COALESCE(UPDATE_TIMESTAMP::DATE, CURRENT_DATE()) AS UPDATE_DATE
        
    FROM bronze_participants
    WHERE PARTICIPANT_ID IS NOT NULL  -- Block records without primary key
      AND MEETING_ID IS NOT NULL      -- Block participants without meeting reference
),

-- Deduplication - keep latest record per participant
deduped_participants AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY PARTICIPANT_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM cleansed_participants
)

-- Final selection with data quality validation
SELECT
    PARTICIPANT_ID,
    MEETING_ID,
    USER_ID,
    JOIN_TIME,
    LEAVE_TIME,
    ATTENDANCE_DURATION,
    PARTICIPANT_ROLE,
    CONNECTION_QUALITY,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATA_QUALITY_SCORE,
    LOAD_DATE,
    UPDATE_DATE
FROM deduped_participants
WHERE rn = 1
  AND DATA_QUALITY_SCORE >= 0.50  -- Minimum quality threshold
