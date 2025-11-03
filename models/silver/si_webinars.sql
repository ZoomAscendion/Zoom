{{ config(
    materialized='table'
) }}

-- Silver Layer Webinars Table
-- Transforms Bronze webinars data with validation and engagement metrics

WITH bronze_webinars AS (
    SELECT *
    FROM {{ source('bronze', 'bz_webinars') }}
    WHERE WEBINAR_ID IS NOT NULL
        AND HOST_ID IS NOT NULL
),

-- Data Quality Checks and Transformations
webinars_cleaned AS (
    SELECT 
        -- Primary identifiers
        WEBINAR_ID,
        HOST_ID,
        
        -- Webinar topic standardization
        CASE 
            WHEN WEBINAR_TOPIC IS NULL OR TRIM(WEBINAR_TOPIC) = '' 
                THEN 'Unknown Topic - needs enrichment'
            ELSE TRIM(WEBINAR_TOPIC)
        END AS WEBINAR_TOPIC,
        
        -- Timestamp validation and correction
        CASE 
            WHEN START_TIME > CURRENT_TIMESTAMP() + INTERVAL '1 YEAR' 
                THEN CURRENT_TIMESTAMP()
            ELSE START_TIME
        END AS START_TIME,
        
        CASE 
            WHEN END_TIME IS NULL THEN 
                DATEADD('hour', 1, START_TIME)  -- Default 1 hour if null
            WHEN END_TIME < START_TIME 
                THEN DATEADD('hour', 1, START_TIME)
            WHEN END_TIME > CURRENT_TIMESTAMP() + INTERVAL '1 YEAR'
                THEN CURRENT_TIMESTAMP()
            ELSE END_TIME
        END AS END_TIME,
        
        -- Duration calculation
        CASE 
            WHEN END_TIME IS NULL THEN 60  -- Default 1 hour
            WHEN END_TIME < START_TIME THEN 60
            ELSE DATEDIFF('minute', START_TIME, END_TIME)
        END AS DURATION_MINUTES,
        
        -- Registrants validation
        CASE 
            WHEN REGISTRANTS < 0 THEN 0
            ELSE COALESCE(REGISTRANTS, 0)
        END AS REGISTRANTS,
        
        -- Attendees estimation (80% of registrants)
        CASE 
            WHEN REGISTRANTS < 0 THEN 0
            WHEN REGISTRANTS = 0 THEN 0
            ELSE ROUND(COALESCE(REGISTRANTS, 0) * 0.8)
        END AS ATTENDEES,
        
        -- Attendance rate calculation
        CASE 
            WHEN COALESCE(REGISTRANTS, 0) = 0 THEN 0.0
            WHEN REGISTRANTS < 0 THEN 0.0
            ELSE ROUND((ROUND(COALESCE(REGISTRANTS, 0) * 0.8) / COALESCE(REGISTRANTS, 1)) * 100, 2)
        END AS ATTENDANCE_RATE,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data quality score calculation
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
            WHEN WEBINAR_ID IS NOT NULL
                THEN 0.50
            ELSE 0.25
        END AS DATA_QUALITY_SCORE,
        
        -- Standard metadata
        LOAD_TIMESTAMP::DATE AS LOAD_DATE,
        UPDATE_TIMESTAMP::DATE AS UPDATE_DATE,
        
        -- Row number for deduplication
        ROW_NUMBER() OVER (PARTITION BY WEBINAR_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
        
    FROM bronze_webinars
),

-- Final selection with data quality filters
webinars_final AS (
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
    FROM webinars_cleaned
    WHERE rn = 1  -- Deduplication
        AND END_TIME >= START_TIME  -- Ensure temporal logic
        AND REGISTRANTS >= 0  -- Ensure non-negative registrants
)

SELECT * FROM webinars_final
