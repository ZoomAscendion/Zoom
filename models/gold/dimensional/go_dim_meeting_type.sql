{{ config(
    materialized='table'
) }}

-- Meeting type dimension with enhanced categorization
-- Derives meeting characteristics from meeting data

WITH source_meetings AS (
    SELECT DISTINCT
        DURATION_MINUTES,
        START_TIME,
        DATA_QUALITY_SCORE,
        SOURCE_SYSTEM
    FROM {{ source('silver', 'si_meetings') }}
    WHERE VALIDATION_STATUS = 'PASSED'
      AND DURATION_MINUTES IS NOT NULL
      AND START_TIME IS NOT NULL
),

meeting_categories AS (
    SELECT DISTINCT
        CASE 
            WHEN DURATION_MINUTES <= 15 THEN 'Brief'
            WHEN DURATION_MINUTES <= 60 THEN 'Standard'
            WHEN DURATION_MINUTES <= 120 THEN 'Extended'
            ELSE 'Long'
        END AS DURATION_CATEGORY,
        CASE 
            WHEN HOUR(START_TIME) BETWEEN 6 AND 11 THEN 'Morning'
            WHEN HOUR(START_TIME) BETWEEN 12 AND 17 THEN 'Afternoon'
            WHEN HOUR(START_TIME) BETWEEN 18 AND 21 THEN 'Evening'
            ELSE 'Night'
        END AS TIME_OF_DAY_CATEGORY,
        DAYNAME(START_TIME) AS DAY_OF_WEEK,
        CASE WHEN DAYOFWEEK(START_TIME) IN (1, 7) THEN TRUE ELSE FALSE END AS IS_WEEKEND_MEETING,
        AVG(DURATION_MINUTES) AS avg_duration,
        AVG(DATA_QUALITY_SCORE) AS avg_quality_score,
        MIN(SOURCE_SYSTEM) AS SOURCE_SYSTEM
    FROM source_meetings
    GROUP BY 
        CASE 
            WHEN DURATION_MINUTES <= 15 THEN 'Brief'
            WHEN DURATION_MINUTES <= 60 THEN 'Standard'
            WHEN DURATION_MINUTES <= 120 THEN 'Extended'
            ELSE 'Long'
        END,
        CASE 
            WHEN HOUR(START_TIME) BETWEEN 6 AND 11 THEN 'Morning'
            WHEN HOUR(START_TIME) BETWEEN 12 AND 17 THEN 'Afternoon'
            WHEN HOUR(START_TIME) BETWEEN 18 AND 21 THEN 'Evening'
            ELSE 'Night'
        END,
        DAYNAME(START_TIME),
        CASE WHEN DAYOFWEEK(START_TIME) IN (1, 7) THEN TRUE ELSE FALSE END
),

meeting_type_dimension AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY DURATION_CATEGORY, TIME_OF_DAY_CATEGORY) AS MEETING_TYPE_ID,
        'Standard Meeting' AS MEETING_TYPE,
        CASE 
            WHEN DURATION_CATEGORY = 'Brief' THEN 'Quick Sync'
            WHEN DURATION_CATEGORY = 'Standard' THEN 'Standard Meeting'
            WHEN DURATION_CATEGORY = 'Extended' THEN 'Extended Meeting'
            ELSE 'Long Session'
        END AS MEETING_CATEGORY,
        DURATION_CATEGORY,
        'Unknown' AS PARTICIPANT_SIZE_CATEGORY,
        TIME_OF_DAY_CATEGORY,
        DAY_OF_WEEK,
        IS_WEEKEND_MEETING,
        FALSE AS IS_RECURRING_TYPE,
        CASE 
            WHEN avg_quality_score >= 90 THEN 9.0
            WHEN avg_quality_score >= 80 THEN 8.0
            WHEN avg_quality_score >= 70 THEN 7.0
            ELSE 6.0
        END AS MEETING_QUALITY_THRESHOLD,
        'Standard meeting features' AS TYPICAL_FEATURES_USED,
        'Business Meeting' AS BUSINESS_PURPOSE,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        SOURCE_SYSTEM
    FROM meeting_categories
)

SELECT * FROM meeting_type_dimension
