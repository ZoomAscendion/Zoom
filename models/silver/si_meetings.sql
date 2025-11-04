{{ config(
    materialized='table',
    on_schema_change='sync_all_columns',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, EXECUTED_BY, EXECUTION_ENVIRONMENT, SOURCE_SYSTEM, LOAD_DATE, UPDATE_DATE) SELECT 'MEET_' || REPLACE(REPLACE(REPLACE(CURRENT_TIMESTAMP()::STRING, ' ', '_'), ':', ''), '.', '_'), 'Silver_Meetings_ETL', CURRENT_TIMESTAMP(), 'STARTED', 'DBT_SILVER_JOB', 'PRODUCTION', 'ZOOM_PLATFORM', CURRENT_DATE(), CURRENT_DATE()",
    post_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, END_TIME, STATUS, EXECUTION_DURATION_SECONDS, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, RECORDS_PROCESSED, RECORDS_INSERTED, RECORDS_UPDATED, RECORDS_REJECTED, EXECUTED_BY, EXECUTION_ENVIRONMENT, DATA_LINEAGE_INFO, SOURCE_SYSTEM, LOAD_DATE, UPDATE_DATE) SELECT 'MEET_' || REPLACE(REPLACE(REPLACE(CURRENT_TIMESTAMP()::STRING, ' ', '_'), ':', ''), '.', '_'), 'Silver_Meetings_ETL', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 'COMPLETED', 0, 'BZ_MEETINGS,BZ_USERS,BZ_PARTICIPANTS', 'SI_MEETINGS', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 0, 0, 'DBT_SILVER_JOB', 'PRODUCTION', 'Bronze to Silver Meetings transformation', 'ZOOM_PLATFORM', CURRENT_DATE(), CURRENT_DATE()"
) }}

-- Silver Meetings Table
-- Transforms Bronze meetings data with enrichments and validations

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
    GROUP BY MEETING_ID
),

-- Data Quality Validations
validated_meetings AS (
    SELECT
        m.*,
        -- Data Quality Flags
        CASE 
            WHEN m.MEETING_ID IS NULL THEN 'CRITICAL_NO_MEETING_ID'
            WHEN m.HOST_ID IS NULL THEN 'CRITICAL_NO_HOST_ID'
            WHEN m.END_TIME < m.START_TIME THEN 'CRITICAL_INVALID_TIME_SEQUENCE'
            WHEN m.DURATION_MINUTES < 0 THEN 'CRITICAL_NEGATIVE_DURATION'
            WHEN m.START_TIME > CURRENT_TIMESTAMP() + INTERVAL '1 DAY' THEN 'WARNING_FUTURE_MEETING'
            ELSE 'VALID'
        END AS data_quality_flag,
        
        -- Row Number for Deduplication
        ROW_NUMBER() OVER (PARTITION BY m.MEETING_ID ORDER BY m.UPDATE_TIMESTAMP DESC, m.LOAD_TIMESTAMP DESC) AS rn
    FROM bronze_meetings m
    WHERE m.MEETING_ID IS NOT NULL  -- Block records without MEETING_ID
      AND m.HOST_ID IS NOT NULL     -- Block records without HOST_ID
      AND m.END_TIME >= m.START_TIME  -- Block invalid time sequences
      AND m.DURATION_MINUTES >= 0     -- Block negative durations
),

-- Apply Transformations
transformed_meetings AS (
    SELECT
        -- Primary Keys
        vm.MEETING_ID,
        vm.HOST_ID,
        
        -- Standardized Business Columns
        TRIM(vm.MEETING_TOPIC) AS MEETING_TOPIC,
        CASE 
            WHEN vm.DURATION_MINUTES <= 30 THEN 'Instant'
            WHEN vm.DURATION_MINUTES <= 120 THEN 'Scheduled'
            WHEN vm.DURATION_MINUTES > 120 THEN 'Webinar'
            ELSE 'Personal'
        END AS MEETING_TYPE,
        vm.START_TIME,
        vm.END_TIME,
        GREATEST(vm.DURATION_MINUTES, DATEDIFF('minute', vm.START_TIME, vm.END_TIME)) AS DURATION_MINUTES,
        
        -- Enriched Columns
        COALESCE(u.USER_NAME, 'Unknown Host') AS HOST_NAME,
        CASE 
            WHEN vm.END_TIME < CURRENT_TIMESTAMP() THEN 'Completed'
            WHEN vm.START_TIME > CURRENT_TIMESTAMP() THEN 'Scheduled'
            ELSE 'In Progress'
        END AS MEETING_STATUS,
        'No' AS RECORDING_STATUS,  -- Default value
        COALESCE(pc.PARTICIPANT_COUNT, 0) AS PARTICIPANT_COUNT,
        
        -- Metadata Columns
        vm.LOAD_TIMESTAMP,
        vm.UPDATE_TIMESTAMP,
        vm.SOURCE_SYSTEM,
        
        -- Data Quality Score
        CASE 
            WHEN vm.data_quality_flag = 'VALID' THEN 1.00
            WHEN vm.data_quality_flag LIKE 'WARNING%' THEN 0.80
            ELSE 0.60
        END AS DATA_QUALITY_SCORE,
        
        -- Standard Metadata
        DATE(vm.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(vm.UPDATE_TIMESTAMP) AS UPDATE_DATE
        
    FROM validated_meetings vm
    LEFT JOIN bronze_users u ON vm.HOST_ID = u.USER_ID
    LEFT JOIN participant_counts pc ON vm.MEETING_ID = pc.MEETING_ID
    WHERE vm.rn = 1  -- Keep only the latest record for each MEETING_ID
      AND vm.data_quality_flag NOT LIKE 'CRITICAL%'
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
FROM transformed_meetings
