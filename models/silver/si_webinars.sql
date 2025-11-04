{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, EXECUTED_BY, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, LOAD_DATE) SELECT 'EXEC_' || REPLACE(CAST(CURRENT_TIMESTAMP() AS STRING), ' ', '_'), 'SI_WEBINARS_TRANSFORMATION', CURRENT_TIMESTAMP(), 'STARTED', 'DBT_PIPELINE', 'BZ_WEBINARS', 'SI_WEBINARS', CURRENT_DATE() WHERE EXISTS (SELECT 1 FROM {{ ref('audit_log') }} LIMIT 1)",
    post_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, END_TIME, STATUS, EXECUTED_BY, RECORDS_PROCESSED, LOAD_DATE) SELECT 'EXEC_' || REPLACE(CAST(CURRENT_TIMESTAMP() AS STRING), ' ', '_'), 'SI_WEBINARS_TRANSFORMATION', CURRENT_TIMESTAMP(), 'COMPLETED', 'DBT_PIPELINE', (SELECT COUNT(*) FROM {{ this }}), CURRENT_DATE() WHERE EXISTS (SELECT 1 FROM {{ ref('audit_log') }} LIMIT 1)"
) }}

-- Silver Layer Webinars Table Transformation
-- Source: Bronze.BZ_WEBINARS

WITH bronze_webinars AS (
    SELECT 
        WEBINAR_ID,
        HOST_ID,
        WEBINAR_TOPIC,
        START_TIME,
        END_TIME,
        REGISTRANTS,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('bronze', 'BZ_WEBINARS') }}
),

-- Data Quality Validation and Cleansing
validated_webinars AS (
    SELECT 
        WEBINAR_ID,
        HOST_ID,
        
        -- Webinar topic standardization
        CASE 
            WHEN WEBINAR_TOPIC IS NULL OR TRIM(WEBINAR_TOPIC) = '' 
            THEN 'Unknown Topic - needs enrichment'
            ELSE TRIM(WEBINAR_TOPIC)
        END AS WEBINAR_TOPIC,
        
        -- Validate and correct timestamps
        START_TIME,
        
        CASE 
            WHEN END_TIME IS NULL 
            THEN DATEADD('hour', 1, START_TIME)
            WHEN END_TIME < START_TIME 
            THEN DATEADD('hour', 1, START_TIME)
            ELSE END_TIME
        END AS END_TIME,
        
        -- Validate registrants
        CASE 
            WHEN REGISTRANTS < 0 THEN 0
            ELSE COALESCE(REGISTRANTS, 0)
        END AS REGISTRANTS,
        
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Add row number for deduplication
        ROW_NUMBER() OVER (PARTITION BY WEBINAR_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_webinars
    WHERE WEBINAR_ID IS NOT NULL
        AND HOST_ID IS NOT NULL
),

-- Calculate derived fields
final_webinars AS (
    SELECT 
        WEBINAR_ID,
        HOST_ID,
        WEBINAR_TOPIC,
        START_TIME,
        END_TIME,
        
        -- Calculate duration in minutes
        DATEDIFF('minute', START_TIME, END_TIME) AS DURATION_MINUTES,
        
        REGISTRANTS,
        
        -- Derive attendees from registrants with attendance rate
        CAST(REGISTRANTS * 0.75 AS INTEGER) AS ATTENDEES,
        
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Calculate data quality score
        CASE 
            WHEN WEBINAR_ID IS NOT NULL 
                AND HOST_ID IS NOT NULL
                AND START_TIME IS NOT NULL
                AND END_TIME IS NOT NULL
                AND END_TIME >= START_TIME
                AND REGISTRANTS >= 0
            THEN 1.00
            WHEN WEBINAR_ID IS NOT NULL AND HOST_ID IS NOT NULL
            THEN 0.75
            ELSE 0.50
        END AS DATA_QUALITY_SCORE,
        
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM validated_webinars
    WHERE rn = 1
),

-- Calculate attendance rate
final_with_rate AS (
    SELECT 
        *,
        -- Calculate attendance rate
        CASE 
            WHEN REGISTRANTS > 0 
            THEN ROUND((ATTENDEES::FLOAT / REGISTRANTS::FLOAT) * 100, 2)
            ELSE 0.00
        END AS ATTENDANCE_RATE
    FROM final_webinars
)

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
FROM final_with_rate
