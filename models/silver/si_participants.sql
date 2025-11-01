{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, EXECUTED_BY, EXECUTION_ENVIRONMENT, DATA_LINEAGE_INFO, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key(["'SI_PARTICIPANTS'", 'CURRENT_TIMESTAMP()']) }}', 'SI_PARTICIPANTS_TRANSFORM', CURRENT_TIMESTAMP(), 'STARTED', 'BRONZE.BZ_PARTICIPANTS', 'SILVER.SI_PARTICIPANTS', 'DBT_PIPELINE', 'PROD', 'Participant data transformation with validation', CURRENT_DATE(), CURRENT_DATE(), 'SILVER_LAYER_PIPELINE' WHERE '{{ this.name }}' != 'audit_log'",
    post_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, END_TIME, STATUS, RECORDS_PROCESSED, RECORDS_INSERTED, EXECUTED_BY, EXECUTION_ENVIRONMENT, DATA_LINEAGE_INFO, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key(["'SI_PARTICIPANTS'", 'CURRENT_TIMESTAMP()']) }}', 'SI_PARTICIPANTS_TRANSFORM', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 'COMPLETED', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 'DBT_PIPELINE', 'PROD', 'Participant data transformation completed', CURRENT_DATE(), CURRENT_DATE(), 'SILVER_LAYER_PIPELINE' WHERE '{{ this.name }}' != 'audit_log'"
) }}

WITH bronze_participants AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        JOIN_TIME,
        LEAVE_TIME,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('bronze', 'bz_participants') }}
    WHERE PARTICIPANT_ID IS NOT NULL
      AND MEETING_ID IS NOT NULL
      AND USER_ID IS NOT NULL
      AND JOIN_TIME IS NOT NULL
),

-- Data cleansing and enrichment
cleansed_participants AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        JOIN_TIME,
        COALESCE(LEAVE_TIME, DATEADD('minute', 60, JOIN_TIME)) AS LEAVE_TIME,
        CASE 
            WHEN LEAVE_TIME IS NOT NULL 
            THEN GREATEST(0, DATEDIFF('minute', JOIN_TIME, LEAVE_TIME))
            ELSE 60  -- Default 60 minutes if leave time is null
        END AS ATTENDANCE_DURATION,
        'Participant' AS PARTICIPANT_ROLE,  -- Default role
        'Good' AS CONNECTION_QUALITY,  -- Default quality
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM bronze_participants
    WHERE LEAVE_TIME IS NULL OR LEAVE_TIME >= JOIN_TIME
),

-- Data quality scoring
quality_scored_participants AS (
    SELECT 
        *,
        CASE 
            WHEN PARTICIPANT_ID IS NOT NULL 
                 AND MEETING_ID IS NOT NULL 
                 AND USER_ID IS NOT NULL 
                 AND JOIN_TIME IS NOT NULL 
                 AND LEAVE_TIME >= JOIN_TIME
                 AND ATTENDANCE_DURATION >= 0
            THEN 1.00
            WHEN PARTICIPANT_ID IS NOT NULL AND MEETING_ID IS NOT NULL AND USER_ID IS NOT NULL
            THEN 0.75
            WHEN PARTICIPANT_ID IS NOT NULL AND MEETING_ID IS NOT NULL
            THEN 0.50
            ELSE 0.25
        END AS DATA_QUALITY_SCORE
    FROM cleansed_participants
),

-- Remove duplicates
deduped_participants AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY PARTICIPANT_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM quality_scored_participants
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
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
FROM deduped_participants
WHERE rn = 1
  AND DATA_QUALITY_SCORE >= 0.50
