{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, EXECUTED_BY, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT CONCAT('EXEC_SI_MEETINGS_', DATE_PART('epoch', CURRENT_TIMESTAMP())::STRING), 'SILVER_SI_MEETINGS', CURRENT_TIMESTAMP(), 'In Progress', 'DBT_SILVER_PIPELINE', CURRENT_DATE(), CURRENT_DATE(), 'BRONZE_BZ_MEETINGS' WHERE NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'SI_PIPELINE_AUDIT')",
    post_hook="UPDATE {{ ref('si_pipeline_audit') }} SET END_TIME = CURRENT_TIMESTAMP(), STATUS = 'Success', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}) WHERE PIPELINE_NAME = 'SILVER_SI_MEETINGS' AND STATUS = 'In Progress'"
) }}

-- Silver Layer Meetings Table
-- Transforms Bronze meetings data with enrichment and data quality validations

WITH bronze_meetings AS (
    SELECT *
    FROM {{ ref('bz_meetings') }}
    WHERE MEETING_ID IS NOT NULL
        AND HOST_ID IS NOT NULL
),

-- Get participant counts per meeting
participant_counts AS (
    SELECT 
        MEETING_ID,
        COUNT(DISTINCT USER_ID) AS PARTICIPANT_COUNT
    FROM {{ ref('bz_participants') }}
    WHERE MEETING_ID IS NOT NULL AND USER_ID IS NOT NULL
    GROUP BY MEETING_ID
),

-- Get host names from users table
host_info AS (
    SELECT 
        USER_ID,
        USER_NAME
    FROM {{ ref('bz_users') }}
    WHERE USER_ID IS NOT NULL
),

-- Data Quality Checks and Transformations
meetings_cleaned AS (
    SELECT 
        bm.MEETING_ID,
        bm.HOST_ID,
        
        -- Meeting topic standardization
        CASE 
            WHEN bm.MEETING_TOPIC IS NULL OR TRIM(bm.MEETING_TOPIC) = '' 
                THEN 'Unknown Topic - needs enrichment'
            ELSE TRIM(bm.MEETING_TOPIC)
        END AS MEETING_TOPIC,
        
        -- Meeting type derivation based on duration
        CASE 
            WHEN bm.DURATION_MINUTES <= 30 THEN 'Instant'
            WHEN bm.DURATION_MINUTES <= 60 THEN 'Scheduled'
            WHEN bm.DURATION_MINUTES > 60 THEN 'Webinar'
            ELSE 'Personal'
        END AS MEETING_TYPE,
        
        -- Timestamp validation and correction
        CASE 
            WHEN bm.START_TIME > CURRENT_TIMESTAMP() + INTERVAL '1 DAY' 
                THEN CURRENT_TIMESTAMP()
            ELSE bm.START_TIME
        END AS START_TIME,
        
        CASE 
            WHEN bm.END_TIME < bm.START_TIME 
                THEN DATEADD('minute', GREATEST(bm.DURATION_MINUTES, 1), bm.START_TIME)
            WHEN bm.END_TIME > CURRENT_TIMESTAMP() + INTERVAL '1 DAY'
                THEN CURRENT_TIMESTAMP()
            ELSE bm.END_TIME
        END AS END_TIME,
        
        -- Duration validation and recalculation
        CASE 
            WHEN bm.DURATION_MINUTES < 0 THEN ABS(bm.DURATION_MINUTES)
            WHEN bm.DURATION_MINUTES = 0 THEN 1
            WHEN bm.DURATION_MINUTES > 1440 THEN 1440  -- Cap at 24 hours
            ELSE bm.DURATION_MINUTES
        END AS DURATION_MINUTES,
        
        -- Host name from join
        COALESCE(hi.USER_NAME, 'Unknown Host') AS HOST_NAME,
        
        -- Meeting status derivation
        CASE 
            WHEN bm.END_TIME IS NULL OR bm.END_TIME > CURRENT_TIMESTAMP() THEN 'Scheduled'
            WHEN bm.START_TIME <= CURRENT_TIMESTAMP() AND bm.END_TIME > CURRENT_TIMESTAMP() THEN 'In Progress'
            WHEN bm.END_TIME <= CURRENT_TIMESTAMP() THEN 'Completed'
            ELSE 'Cancelled'
        END AS MEETING_STATUS,
        
        -- Recording status (derived from topic keywords)
        CASE 
            WHEN LOWER(bm.MEETING_TOPIC) LIKE '%record%' OR LOWER(bm.MEETING_TOPIC) LIKE '%recording%' 
                THEN 'Yes'
            ELSE 'No'
        END AS RECORDING_STATUS,
        
        -- Participant count from join
        COALESCE(pc.PARTICIPANT_COUNT, 0) AS PARTICIPANT_COUNT,
        
        -- Metadata columns
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
        bm.LOAD_TIMESTAMP::DATE AS LOAD_DATE,
        bm.UPDATE_TIMESTAMP::DATE AS UPDATE_DATE,
        
        -- Row number for deduplication
        ROW_NUMBER() OVER (PARTITION BY bm.MEETING_ID ORDER BY bm.UPDATE_TIMESTAMP DESC) AS rn
        
    FROM bronze_meetings bm
    LEFT JOIN participant_counts pc ON bm.MEETING_ID = pc.MEETING_ID
    LEFT JOIN host_info hi ON bm.HOST_ID = hi.USER_ID
),

-- Final selection with data quality filters
meetings_final AS (
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
    FROM meetings_cleaned
    WHERE rn = 1  -- Deduplication
        AND END_TIME >= START_TIME  -- Ensure temporal logic
        AND DURATION_MINUTES > 0  -- Ensure positive duration
)

SELECT * FROM meetings_final
