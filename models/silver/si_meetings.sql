{{
  config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, EXECUTED_BY, EXECUTION_ENVIRONMENT, LOAD_DATE, SOURCE_SYSTEM) SELECT 'EXEC_MEETINGS_' || TO_VARCHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), 'SILVER_MEETINGS_TRANSFORM', CURRENT_TIMESTAMP(), 'STARTED', 'BRONZE.BZ_MEETINGS', 'SILVER.SI_MEETINGS', CURRENT_USER(), 'PROD', CURRENT_DATE(), 'BRONZE_LAYER' WHERE '{{ this.name }}' != 'si_pipeline_audit'",
    post_hook="UPDATE {{ ref('si_pipeline_audit') }} SET END_TIME = CURRENT_TIMESTAMP(), STATUS = 'SUCCESS', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), RECORDS_INSERTED = (SELECT COUNT(*) FROM {{ this }}) WHERE PIPELINE_NAME = 'SILVER_MEETINGS_TRANSFORM' AND END_TIME IS NULL AND '{{ this.name }}' != 'si_pipeline_audit'"
  )
}}

-- Silver Layer Meetings Model
-- Description: Transform and cleanse bronze meetings data to silver layer with data quality validations
-- Source: BRONZE.BZ_MEETINGS
-- Target: SILVER.SI_MEETINGS
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

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
),

-- Get host information for enrichment
host_info AS (
    SELECT 
        USER_ID,
        USER_NAME
    FROM {{ ref('si_users') }}
    WHERE USER_ID IS NOT NULL
),

-- Get participant count for each meeting
participant_counts AS (
    SELECT 
        MEETING_ID,
        COUNT(DISTINCT USER_ID) AS PARTICIPANT_COUNT
    FROM {{ source('bronze', 'bz_participants') }}
    WHERE MEETING_ID IS NOT NULL
      AND USER_ID IS NOT NULL
    GROUP BY MEETING_ID
),

-- Data Quality Validation Layer
data_quality_checks AS (
    SELECT 
        *,
        -- Time validation
        CASE 
            WHEN START_TIME IS NULL THEN 0.0
            WHEN END_TIME IS NULL THEN 0.3
            WHEN END_TIME < START_TIME THEN 0.0
            ELSE 1.0
        END AS time_quality_score,
        
        -- Duration validation
        CASE 
            WHEN DURATION_MINUTES IS NULL THEN 0.0
            WHEN DURATION_MINUTES < 0 THEN 0.0
            WHEN DURATION_MINUTES > 1440 THEN 0.2  -- More than 24 hours is suspicious
            ELSE 1.0
        END AS duration_quality_score,
        
        -- Topic validation
        CASE 
            WHEN MEETING_TOPIC IS NULL OR TRIM(MEETING_TOPIC) = '' THEN 0.3
            WHEN LENGTH(TRIM(MEETING_TOPIC)) < 3 THEN 0.5
            ELSE 1.0
        END AS topic_quality_score
    FROM bronze_meetings
),

-- Apply data transformations and cleansing
transformed_meetings AS (
    SELECT 
        -- Primary key
        MEETING_ID,
        HOST_ID,
        
        -- Cleansed business columns
        CASE 
            WHEN MEETING_TOPIC IS NULL OR TRIM(MEETING_TOPIC) = '' THEN 'Untitled Meeting'
            ELSE TRIM(MEETING_TOPIC)
        END AS MEETING_TOPIC,
        
        -- Derive meeting type based on duration and other factors
        CASE 
            WHEN DURATION_MINUTES <= 40 THEN 'Instant'
            WHEN DURATION_MINUTES > 40 AND DURATION_MINUTES <= 120 THEN 'Scheduled'
            WHEN DURATION_MINUTES > 120 THEN 'Webinar'
            ELSE 'Personal'
        END AS MEETING_TYPE,
        
        -- Time columns with validation
        CASE 
            WHEN START_TIME IS NULL THEN LOAD_TIMESTAMP
            ELSE START_TIME
        END AS START_TIME,
        
        CASE 
            WHEN END_TIME IS NULL OR END_TIME < START_TIME THEN 
                DATEADD('minute', COALESCE(DURATION_MINUTES, 60), 
                       CASE WHEN START_TIME IS NULL THEN LOAD_TIMESTAMP ELSE START_TIME END)
            ELSE END_TIME
        END AS END_TIME,
        
        -- Recalculate duration if needed
        CASE 
            WHEN DURATION_MINUTES IS NULL OR DURATION_MINUTES < 0 THEN 
                DATEDIFF('minute', 
                        CASE WHEN START_TIME IS NULL THEN LOAD_TIMESTAMP ELSE START_TIME END,
                        CASE WHEN END_TIME IS NULL OR END_TIME < START_TIME THEN 
                            DATEADD('minute', 60, CASE WHEN START_TIME IS NULL THEN LOAD_TIMESTAMP ELSE START_TIME END)
                        ELSE END_TIME END)
            ELSE DURATION_MINUTES
        END AS DURATION_MINUTES,
        
        -- Host name from enrichment
        COALESCE(h.USER_NAME, 'Unknown Host') AS HOST_NAME,
        
        -- Meeting status based on timestamps
        CASE 
            WHEN END_TIME IS NOT NULL AND END_TIME < CURRENT_TIMESTAMP() THEN 'Completed'
            WHEN START_TIME IS NOT NULL AND START_TIME <= CURRENT_TIMESTAMP() AND 
                 (END_TIME IS NULL OR END_TIME > CURRENT_TIMESTAMP()) THEN 'In Progress'
            WHEN START_TIME IS NOT NULL AND START_TIME > CURRENT_TIMESTAMP() THEN 'Scheduled'
            ELSE 'Unknown'
        END AS MEETING_STATUS,
        
        -- Recording status (derived)
        CASE 
            WHEN DURATION_MINUTES > 30 THEN 'Yes'
            ELSE 'No'
        END AS RECORDING_STATUS,
        
        -- Participant count
        COALESCE(pc.PARTICIPANT_COUNT, 0) AS PARTICIPANT_COUNT,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data quality score calculation
        ROUND((time_quality_score + duration_quality_score + topic_quality_score) / 3.0, 2) AS DATA_QUALITY_SCORE,
        
        -- Standard audit columns
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
        
    FROM data_quality_checks m
    LEFT JOIN host_info h ON m.HOST_ID = h.USER_ID
    LEFT JOIN participant_counts pc ON m.MEETING_ID = pc.MEETING_ID
    WHERE MEETING_ID IS NOT NULL
),

-- Deduplication layer - keep latest record per meeting
deduped_meetings AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY MEETING_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) AS rn
    FROM transformed_meetings
),

-- Final output with audit columns
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
        DATA_QUALITY_SCORE,
        LOAD_DATE,
        UPDATE_DATE,
        
        -- Process audit columns
        CURRENT_TIMESTAMP() AS CREATED_AT,
        CURRENT_TIMESTAMP() AS UPDATED_AT,
        'SUCCESS' AS PROCESS_STATUS
        
    FROM deduped_meetings
    WHERE rn = 1
      AND DATA_QUALITY_SCORE >= 0.5  -- Only high quality records proceed to Silver
)

SELECT * FROM final_meetings
