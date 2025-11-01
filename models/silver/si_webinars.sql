{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, EXECUTED_BY, EXECUTION_ENVIRONMENT, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key(["'SI_WEBINARS'", 'CURRENT_TIMESTAMP()']) }}', 'SI_WEBINARS_TRANSFORMATION', CURRENT_TIMESTAMP(), 'STARTED', 'DBT_SYSTEM', 'PROD', 'BZ_WEBINARS', 'SI_WEBINARS', CURRENT_DATE(), CURRENT_DATE(), 'Silver Layer Pipeline' WHERE '{{ this.name }}' != 'audit_log'",
    post_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, END_TIME, STATUS, EXECUTED_BY, EXECUTION_ENVIRONMENT, RECORDS_PROCESSED, RECORDS_INSERTED, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key(["'SI_WEBINARS'", 'CURRENT_TIMESTAMP()']) }}', 'SI_WEBINARS_TRANSFORMATION', CURRENT_TIMESTAMP(), 'SUCCESS', 'DBT_SYSTEM', 'PROD', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), CURRENT_DATE(), CURRENT_DATE(), 'Silver Layer Pipeline' WHERE '{{ this.name }}' != 'audit_log'"
) }}

-- Silver Layer Webinars Table
-- Transforms webinar data with engagement metrics and attendance calculations

WITH bronze_webinars AS (
    SELECT 
        bw.WEBINAR_ID,
        bw.HOST_ID,
        bw.WEBINAR_TOPIC,
        bw.START_TIME,
        bw.END_TIME,
        bw.REGISTRANTS,
        bw.LOAD_TIMESTAMP,
        bw.UPDATE_TIMESTAMP,
        bw.SOURCE_SYSTEM
    FROM {{ source('bronze', 'bz_webinars') }} bw
    WHERE bw.WEBINAR_ID IS NOT NULL
      AND bw.HOST_ID IS NOT NULL
      AND bw.START_TIME IS NOT NULL
      AND bw.END_TIME IS NOT NULL
),

-- Data Quality and Cleansing Layer
cleansed_webinars AS (
    SELECT 
        -- Primary Keys
        TRIM(bw.WEBINAR_ID) AS WEBINAR_ID,
        TRIM(bw.HOST_ID) AS HOST_ID,
        
        -- Cleansed Business Columns
        CASE 
            WHEN bw.WEBINAR_TOPIC IS NOT NULL THEN TRIM(bw.WEBINAR_TOPIC)
            ELSE 'Untitled Webinar'
        END AS WEBINAR_TOPIC,
        
        -- Validated Timestamps
        bw.START_TIME,
        CASE 
            WHEN bw.END_TIME >= bw.START_TIME THEN bw.END_TIME
            ELSE bw.START_TIME  -- Default to start time if end time is invalid
        END AS END_TIME,
        
        -- Calculated Duration
        CASE 
            WHEN bw.END_TIME >= bw.START_TIME 
            THEN DATEDIFF('minute', bw.START_TIME, bw.END_TIME)
            ELSE 60  -- Default 1 hour duration
        END AS DURATION_MINUTES,
        
        -- Validated Registrants
        COALESCE(bw.REGISTRANTS, 0) AS REGISTRANTS,
        
        -- Calculate Attendees (estimated as 70% of registrants)
        ROUND(COALESCE(bw.REGISTRANTS, 0) * 0.70) AS ATTENDEES,
        
        -- Calculate Attendance Rate
        CASE 
            WHEN COALESCE(bw.REGISTRANTS, 0) > 0 
            THEN ROUND((ROUND(COALESCE(bw.REGISTRANTS, 0) * 0.70) / bw.REGISTRANTS) * 100, 2)
            ELSE 0.00
        END AS ATTENDANCE_RATE,
        
        -- Metadata Columns
        bw.LOAD_TIMESTAMP,
        bw.UPDATE_TIMESTAMP,
        bw.SOURCE_SYSTEM,
        
        -- Data Quality Score Calculation
        (
            CASE WHEN bw.WEBINAR_ID IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN bw.HOST_ID IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN bw.START_TIME IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN bw.END_TIME >= bw.START_TIME THEN 0.25 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        -- Standard Metadata
        DATE(bw.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(bw.UPDATE_TIMESTAMP) AS UPDATE_DATE
        
    FROM bronze_webinars bw
),

-- Deduplication Layer
deduped_webinars AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY WEBINAR_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM cleansed_webinars
)

-- Final Select with Data Quality Filters
SELECT 
    WEBINAR_ID,
    HOST_ID,
    WEBINAR_TOPIC,
    START_TIME,
    END_TIME,
    DURATION_MINUTES,
    REGISTRANTS,
    ATTENDEES,
    ATTENDANCE_RATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATA_QUALITY_SCORE,
    LOAD_DATE,
    UPDATE_DATE
FROM deduped_webinars
WHERE rn = 1
  AND DATA_QUALITY_SCORE >= 0.75  -- Minimum quality threshold
  AND WEBINAR_ID IS NOT NULL
  AND HOST_ID IS NOT NULL
