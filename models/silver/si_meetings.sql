{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, EXECUTED_BY, EXECUTION_ENVIRONMENT, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key(["'SI_MEETINGS'", 'CURRENT_TIMESTAMP()']) }}', 'SI_MEETINGS_TRANSFORMATION', CURRENT_TIMESTAMP(), 'STARTED', 'DBT_SYSTEM', 'PROD', 'BZ_MEETINGS,BZ_USERS', 'SI_MEETINGS', CURRENT_DATE(), CURRENT_DATE(), 'Silver Layer Pipeline' WHERE '{{ this.name }}' != 'audit_log'",
    post_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, END_TIME, STATUS, EXECUTED_BY, EXECUTION_ENVIRONMENT, RECORDS_PROCESSED, RECORDS_INSERTED, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key(["'SI_MEETINGS'", 'CURRENT_TIMESTAMP()']) }}', 'SI_MEETINGS_TRANSFORMATION', CURRENT_TIMESTAMP(), 'SUCCESS', 'DBT_SYSTEM', 'PROD', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), CURRENT_DATE(), CURRENT_DATE(), 'Silver Layer Pipeline' WHERE '{{ this.name }}' != 'audit_log'"
) }}

-- Silver Layer Meetings Table
-- Transforms and enriches meeting data from Bronze layer with host information and calculated metrics

WITH bronze_meetings AS (
    SELECT 
        bm.MEETING_ID,
        bm.HOST_ID,
        bm.MEETING_TOPIC,
        bm.START_TIME,
        bm.END_TIME,
        bm.DURATION_MINUTES,
        bm.LOAD_TIMESTAMP,
        bm.UPDATE_TIMESTAMP,
        bm.SOURCE_SYSTEM
    FROM {{ source('bronze', 'bz_meetings') }} bm
    WHERE bm.MEETING_ID IS NOT NULL
      AND bm.HOST_ID IS NOT NULL
      AND bm.START_TIME IS NOT NULL
),

-- Join with Users for Host Information
meeting_with_host AS (
    SELECT 
        bm.*,
        bu.USER_NAME AS host_user_name
    FROM bronze_meetings bm
    LEFT JOIN {{ source('bronze', 'bz_users') }} bu ON bm.HOST_ID = bu.USER_ID
),

-- Get Participant Count from Bronze Participants
participant_counts AS (
    SELECT 
        MEETING_ID,
        COUNT(DISTINCT USER_ID) AS participant_count
    FROM {{ source('bronze', 'bz_participants') }}
    WHERE MEETING_ID IS NOT NULL AND USER_ID IS NOT NULL
    GROUP BY MEETING_ID
),

-- Data Quality and Cleansing Layer
cleansed_meetings AS (
    SELECT 
        -- Primary Keys
        TRIM(mwh.MEETING_ID) AS MEETING_ID,
        TRIM(mwh.HOST_ID) AS HOST_ID,
        
        -- Cleansed Business Columns
        CASE 
            WHEN mwh.MEETING_TOPIC IS NOT NULL THEN TRIM(mwh.MEETING_TOPIC)
            ELSE 'Untitled Meeting'
        END AS MEETING_TOPIC,
        
        -- Derive Meeting Type based on characteristics
        CASE 
            WHEN mwh.MEETING_TOPIC ILIKE '%webinar%' THEN 'Webinar'
            WHEN DATEDIFF('minute', mwh.START_TIME, mwh.END_TIME) > 480 THEN 'Scheduled'
            WHEN DATEDIFF('minute', mwh.START_TIME, mwh.END_TIME) <= 60 THEN 'Instant'
            ELSE 'Personal'
        END AS MEETING_TYPE,
        
        -- Validated Timestamps
        mwh.START_TIME,
        CASE 
            WHEN mwh.END_TIME >= mwh.START_TIME THEN mwh.END_TIME
            ELSE mwh.START_TIME  -- Default to start time if end time is invalid
        END AS END_TIME,
        
        -- Recalculated Duration
        CASE 
            WHEN mwh.END_TIME >= mwh.START_TIME 
            THEN DATEDIFF('minute', mwh.START_TIME, mwh.END_TIME)
            ELSE COALESCE(mwh.DURATION_MINUTES, 0)
        END AS DURATION_MINUTES,
        
        -- Host Information
        CASE 
            WHEN mwh.host_user_name IS NOT NULL THEN TRIM(INITCAP(mwh.host_user_name))
            ELSE 'Unknown Host'
        END AS HOST_NAME,
        
        -- Meeting Status based on timestamps
        CASE 
            WHEN mwh.START_TIME > CURRENT_TIMESTAMP() THEN 'Scheduled'
            WHEN mwh.START_TIME <= CURRENT_TIMESTAMP() AND mwh.END_TIME > CURRENT_TIMESTAMP() THEN 'In Progress'
            WHEN mwh.END_TIME <= CURRENT_TIMESTAMP() THEN 'Completed'
            ELSE 'Cancelled'
        END AS MEETING_STATUS,
        
        -- Recording Status (derived)
        CASE 
            WHEN DATEDIFF('minute', mwh.START_TIME, mwh.END_TIME) > 30 THEN 'Yes'
            ELSE 'No'
        END AS RECORDING_STATUS,
        
        -- Participant Count
        COALESCE(pc.participant_count, 0) AS PARTICIPANT_COUNT,
        
        -- Metadata Columns
        mwh.LOAD_TIMESTAMP,
        mwh.UPDATE_TIMESTAMP,
        mwh.SOURCE_SYSTEM,
        
        -- Data Quality Score Calculation
        (
            CASE WHEN mwh.MEETING_ID IS NOT NULL THEN 0.2 ELSE 0 END +
            CASE WHEN mwh.HOST_ID IS NOT NULL THEN 0.2 ELSE 0 END +
            CASE WHEN mwh.START_TIME IS NOT NULL THEN 0.2 ELSE 0 END +
            CASE WHEN mwh.END_TIME >= mwh.START_TIME THEN 0.2 ELSE 0 END +
            CASE WHEN mwh.DURATION_MINUTES > 0 THEN 0.2 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        -- Standard Metadata
        DATE(mwh.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(mwh.UPDATE_TIMESTAMP) AS UPDATE_DATE
        
    FROM meeting_with_host mwh
    LEFT JOIN participant_counts pc ON mwh.MEETING_ID = pc.MEETING_ID
),

-- Deduplication Layer
deduped_meetings AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY MEETING_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM cleansed_meetings
)

-- Final Select with Data Quality Filters
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
  AND DATA_QUALITY_SCORE >= 0.60  -- Minimum quality threshold
  AND MEETING_ID IS NOT NULL
  AND HOST_ID IS NOT NULL
