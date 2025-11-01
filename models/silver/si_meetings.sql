{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, EXECUTED_BY, EXECUTION_ENVIRONMENT, DATA_LINEAGE_INFO, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key(["'SI_MEETINGS'", 'CURRENT_TIMESTAMP()']) }}', 'SI_MEETINGS_TRANSFORM', CURRENT_TIMESTAMP(), 'STARTED', 'BRONZE.BZ_MEETINGS,BRONZE.BZ_USERS,BRONZE.BZ_PARTICIPANTS', 'SILVER.SI_MEETINGS', 'DBT_PIPELINE', 'PROD', 'Meeting data transformation with validation', CURRENT_DATE(), CURRENT_DATE(), 'SILVER_LAYER_PIPELINE' WHERE '{{ this.name }}' != 'audit_log'",
    post_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, END_TIME, STATUS, RECORDS_PROCESSED, RECORDS_INSERTED, EXECUTED_BY, EXECUTION_ENVIRONMENT, DATA_LINEAGE_INFO, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key(["'SI_MEETINGS'", 'CURRENT_TIMESTAMP()']) }}', 'SI_MEETINGS_TRANSFORM', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 'COMPLETED', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 'DBT_PIPELINE', 'PROD', 'Meeting data transformation completed', CURRENT_DATE(), CURRENT_DATE(), 'SILVER_LAYER_PIPELINE' WHERE '{{ this.name }}' != 'audit_log'"
) }}

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
      AND bm.END_TIME IS NOT NULL
      AND bm.END_TIME >= bm.START_TIME
),

-- Get host information
host_info AS (
    SELECT 
        bu.USER_ID,
        bu.USER_NAME
    FROM {{ source('bronze', 'bz_users') }} bu
    WHERE bu.USER_ID IS NOT NULL
),

-- Get participant counts
participant_counts AS (
    SELECT 
        bp.MEETING_ID,
        COUNT(DISTINCT bp.USER_ID) AS PARTICIPANT_COUNT
    FROM {{ source('bronze', 'bz_participants') }} bp
    WHERE bp.MEETING_ID IS NOT NULL
      AND bp.USER_ID IS NOT NULL
    GROUP BY bp.MEETING_ID
),

-- Data cleansing and enrichment
cleansed_meetings AS (
    SELECT 
        bm.MEETING_ID,
        bm.HOST_ID,
        TRIM(bm.MEETING_TOPIC) AS MEETING_TOPIC,
        CASE 
            WHEN DATEDIFF('minute', bm.START_TIME, bm.END_TIME) > 480 THEN 'Webinar'
            WHEN bm.MEETING_TOPIC ILIKE '%instant%' THEN 'Instant'
            WHEN bm.MEETING_TOPIC ILIKE '%personal%' THEN 'Personal'
            ELSE 'Scheduled'
        END AS MEETING_TYPE,
        bm.START_TIME,
        bm.END_TIME,
        GREATEST(bm.DURATION_MINUTES, DATEDIFF('minute', bm.START_TIME, bm.END_TIME)) AS DURATION_MINUTES,
        COALESCE(hi.USER_NAME, 'Unknown Host') AS HOST_NAME,
        CASE 
            WHEN bm.END_TIME < CURRENT_TIMESTAMP() THEN 'Completed'
            WHEN bm.START_TIME <= CURRENT_TIMESTAMP() AND bm.END_TIME >= CURRENT_TIMESTAMP() THEN 'In Progress'
            WHEN bm.START_TIME > CURRENT_TIMESTAMP() THEN 'Scheduled'
            ELSE 'Cancelled'
        END AS MEETING_STATUS,
        'No' AS RECORDING_STATUS, -- Default value as not available in bronze
        COALESCE(pc.PARTICIPANT_COUNT, 0) AS PARTICIPANT_COUNT,
        bm.LOAD_TIMESTAMP,
        bm.UPDATE_TIMESTAMP,
        bm.SOURCE_SYSTEM
    FROM bronze_meetings bm
    LEFT JOIN host_info hi ON bm.HOST_ID = hi.USER_ID
    LEFT JOIN participant_counts pc ON bm.MEETING_ID = pc.MEETING_ID
),

-- Data quality scoring
quality_scored_meetings AS (
    SELECT 
        *,
        CASE 
            WHEN MEETING_ID IS NOT NULL 
                 AND HOST_ID IS NOT NULL 
                 AND START_TIME IS NOT NULL 
                 AND END_TIME IS NOT NULL 
                 AND DURATION_MINUTES > 0 
                 AND DURATION_MINUTES <= 1440
                 AND END_TIME >= START_TIME
            THEN 1.00
            WHEN MEETING_ID IS NOT NULL AND HOST_ID IS NOT NULL AND START_TIME IS NOT NULL
            THEN 0.75
            WHEN MEETING_ID IS NOT NULL AND HOST_ID IS NOT NULL
            THEN 0.50
            ELSE 0.25
        END AS DATA_QUALITY_SCORE
    FROM cleansed_meetings
),

-- Remove duplicates
deduped_meetings AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY MEETING_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM quality_scored_meetings
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
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
FROM deduped_meetings
WHERE rn = 1
  AND DATA_QUALITY_SCORE >= 0.50
