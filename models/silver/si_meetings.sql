{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('audit_log') }} (source_table, process_start_time, status) VALUES ('si_meetings', CURRENT_TIMESTAMP(), 'STARTED')",
    post_hook="UPDATE {{ ref('audit_log') }} SET process_end_time = CURRENT_TIMESTAMP(), status = 'COMPLETED', rows_processed = (SELECT COUNT(*) FROM {{ this }}) WHERE source_table = 'si_meetings' AND status = 'STARTED'"
) }}

-- Main transformation using CTEs
WITH source_data AS (
    SELECT 
        m.MEETING_ID,
        m.HOST_ID,
        m.MEETING_TOPIC,
        m.START_TIME,
        m.END_TIME,
        m.DURATION_MINUTES,
        m.LOAD_TIMESTAMP,
        m.UPDATE_TIMESTAMP,
        m.SOURCE_SYSTEM,
        u.USER_NAME AS HOST_NAME
    FROM DB_POC_ZOOM.BRONZE.BZ_MEETINGS m
    LEFT JOIN DB_POC_ZOOM.BRONZE.BZ_USERS u ON m.HOST_ID = u.USER_ID
    WHERE m.MEETING_ID IS NOT NULL
    AND m.HOST_ID IS NOT NULL
),

cleaned_data AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        TRIM(MEETING_TOPIC) AS MEETING_TOPIC,
        CASE 
            WHEN DURATION_MINUTES <= 60 THEN 'Instant'
            WHEN DURATION_MINUTES <= 240 THEN 'Scheduled'
            ELSE 'Webinar'
        END AS MEETING_TYPE,
        START_TIME,
        CASE 
            WHEN END_TIME < START_TIME THEN DATEADD('minute', DURATION_MINUTES, START_TIME)
            ELSE END_TIME
        END AS END_TIME,
        CASE 
            WHEN DURATION_MINUTES < 0 THEN ABS(DURATION_MINUTES)
            ELSE DURATION_MINUTES
        END AS DURATION_MINUTES,
        TRIM(HOST_NAME) AS HOST_NAME,
        CASE 
            WHEN END_TIME < CURRENT_TIMESTAMP() THEN 'Completed'
            WHEN START_TIME <= CURRENT_TIMESTAMP() AND END_TIME >= CURRENT_TIMESTAMP() THEN 'In Progress'
            ELSE 'Scheduled'
        END AS MEETING_STATUS,
        'No' AS RECORDING_STATUS,  -- Default value
        0 AS PARTICIPANT_COUNT,    -- Will be updated via post-processing
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Calculate data quality score
        CASE 
            WHEN MEETING_ID IS NOT NULL AND HOST_ID IS NOT NULL AND START_TIME IS NOT NULL AND END_TIME IS NOT NULL THEN 1.00
            WHEN MEETING_ID IS NOT NULL AND HOST_ID IS NOT NULL AND START_TIME IS NOT NULL THEN 0.80
            WHEN MEETING_ID IS NOT NULL AND HOST_ID IS NOT NULL THEN 0.60
            ELSE 0.00
        END AS DATA_QUALITY_SCORE,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM source_data
    WHERE START_TIME IS NOT NULL
    AND END_TIME IS NOT NULL
    AND END_TIME >= START_TIME
),

deduplicated AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY MEETING_ID 
            ORDER BY UPDATE_TIMESTAMP DESC
        ) AS row_num
    FROM cleaned_data
    QUALIFY row_num = 1
)

-- Final SELECT
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
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM deduplicated
