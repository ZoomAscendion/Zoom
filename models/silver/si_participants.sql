{{ config(
    materialized='table',
    on_schema_change='sync_all_columns',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, EXECUTED_BY, EXECUTION_ENVIRONMENT, SOURCE_SYSTEM, LOAD_DATE, UPDATE_DATE) SELECT 'PART_' || REPLACE(REPLACE(REPLACE(CURRENT_TIMESTAMP()::STRING, ' ', '_'), ':', ''), '.', '_'), 'Silver_Participants_ETL', CURRENT_TIMESTAMP(), 'STARTED', 'DBT_SILVER_JOB', 'PRODUCTION', 'ZOOM_PLATFORM', CURRENT_DATE(), CURRENT_DATE()",
    post_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, END_TIME, STATUS, EXECUTION_DURATION_SECONDS, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, RECORDS_PROCESSED, RECORDS_INSERTED, RECORDS_UPDATED, RECORDS_REJECTED, EXECUTED_BY, EXECUTION_ENVIRONMENT, DATA_LINEAGE_INFO, SOURCE_SYSTEM, LOAD_DATE, UPDATE_DATE) SELECT 'PART_' || REPLACE(REPLACE(REPLACE(CURRENT_TIMESTAMP()::STRING, ' ', '_'), ':', ''), '.', '_'), 'Silver_Participants_ETL', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 'COMPLETED', 0, 'BZ_PARTICIPANTS,BZ_MEETINGS', 'SI_PARTICIPANTS', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 0, 0, 'DBT_SILVER_JOB', 'PRODUCTION', 'Bronze to Silver Participants transformation', 'ZOOM_PLATFORM', CURRENT_DATE(), CURRENT_DATE()"
) }}

-- Silver Participants Table
-- Transforms Bronze participants data with attendance calculations and validations

WITH bronze_participants AS (
    SELECT *
    FROM {{ source('bronze', 'bz_participants') }}
),

bronze_meetings AS (
    SELECT MEETING_ID, HOST_ID, START_TIME, END_TIME
    FROM {{ source('bronze', 'bz_meetings') }}
),

-- Data Quality Validations
validated_participants AS (
    SELECT
        p.*,
        -- Data Quality Flags
        CASE 
            WHEN p.PARTICIPANT_ID IS NULL THEN 'CRITICAL_NO_PARTICIPANT_ID'
            WHEN p.MEETING_ID IS NULL THEN 'CRITICAL_NO_MEETING_ID'
            WHEN p.USER_ID IS NULL THEN 'CRITICAL_NO_USER_ID'
            WHEN p.LEAVE_TIME < p.JOIN_TIME THEN 'CRITICAL_INVALID_TIME_SEQUENCE'
            WHEN p.JOIN_TIME > CURRENT_TIMESTAMP() + INTERVAL '1 YEAR' THEN 'CRITICAL_FUTURE_TIMESTAMP'
            WHEN p.LEAVE_TIME IS NULL THEN 'WARNING_MISSING_LEAVE_TIME'
            ELSE 'VALID'
        END AS data_quality_flag,
        
        -- Row Number for Deduplication
        ROW_NUMBER() OVER (PARTITION BY p.PARTICIPANT_ID ORDER BY p.UPDATE_TIMESTAMP DESC, p.LOAD_TIMESTAMP DESC) AS rn
    FROM bronze_participants p
    WHERE p.PARTICIPANT_ID IS NOT NULL  -- Block records without PARTICIPANT_ID
      AND p.MEETING_ID IS NOT NULL      -- Block records without MEETING_ID
      AND p.USER_ID IS NOT NULL         -- Block records without USER_ID
      AND (p.LEAVE_TIME IS NULL OR p.LEAVE_TIME >= p.JOIN_TIME)  -- Block invalid time sequences
      AND p.JOIN_TIME <= CURRENT_TIMESTAMP() + INTERVAL '1 YEAR'  -- Block future timestamps
),

-- Apply Transformations
transformed_participants AS (
    SELECT
        -- Primary Keys
        vp.PARTICIPANT_ID,
        vp.MEETING_ID,
        vp.USER_ID,
        
        -- Time Columns with Corrections
        vp.JOIN_TIME,
        CASE 
            WHEN vp.LEAVE_TIME IS NULL THEN 
                DATEADD('minute', 
                    (SELECT AVG(DATEDIFF('minute', JOIN_TIME, LEAVE_TIME)) 
                     FROM bronze_participants 
                     WHERE LEAVE_TIME IS NOT NULL), 
                    vp.JOIN_TIME)
            ELSE vp.LEAVE_TIME
        END AS LEAVE_TIME,
        
        -- Calculated Columns
        CASE 
            WHEN vp.LEAVE_TIME IS NOT NULL THEN 
                DATEDIFF('minute', vp.JOIN_TIME, vp.LEAVE_TIME)
            ELSE 30  -- Default 30 minutes for missing leave time
        END AS ATTENDANCE_DURATION,
        
        -- Derived Columns
        CASE 
            WHEN vp.USER_ID = m.HOST_ID THEN 'Host'
            ELSE 'Participant'
        END AS PARTICIPANT_ROLE,
        
        CASE 
            WHEN DATEDIFF('minute', vp.JOIN_TIME, COALESCE(vp.LEAVE_TIME, vp.JOIN_TIME)) >= 60 THEN 'Excellent'
            WHEN DATEDIFF('minute', vp.JOIN_TIME, COALESCE(vp.LEAVE_TIME, vp.JOIN_TIME)) >= 30 THEN 'Good'
            WHEN DATEDIFF('minute', vp.JOIN_TIME, COALESCE(vp.LEAVE_TIME, vp.JOIN_TIME)) >= 10 THEN 'Fair'
            ELSE 'Poor'
        END AS CONNECTION_QUALITY,
        
        -- Metadata Columns
        vp.LOAD_TIMESTAMP,
        vp.UPDATE_TIMESTAMP,
        vp.SOURCE_SYSTEM,
        
        -- Data Quality Score
        CASE 
            WHEN vp.data_quality_flag = 'VALID' THEN 1.00
            WHEN vp.data_quality_flag LIKE 'WARNING%' THEN 0.80
            ELSE 0.60
        END AS DATA_QUALITY_SCORE,
        
        -- Standard Metadata
        DATE(vp.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(vp.UPDATE_TIMESTAMP) AS UPDATE_DATE
        
    FROM validated_participants vp
    LEFT JOIN bronze_meetings m ON vp.MEETING_ID = m.MEETING_ID
    WHERE vp.rn = 1  -- Keep only the latest record for each PARTICIPANT_ID
      AND vp.data_quality_flag NOT LIKE 'CRITICAL%'
)

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
FROM transformed_participants
