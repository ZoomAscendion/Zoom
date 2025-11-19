{{ config(
    materialized='table'
) }}

-- Meeting Type Dimension Table
-- Dimension table containing meeting types and characteristics

WITH meeting_data AS (
    SELECT DISTINCT
        DURATION_MINUTES,
        START_TIME,
        SOURCE_SYSTEM
    FROM {{ source('silver', 'si_meetings') }}
    WHERE VALIDATION_STATUS = 'PASSED'
      AND DURATION_MINUTES IS NOT NULL
      AND START_TIME IS NOT NULL
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY DURATION_MINUTES) AS MEETING_TYPE_ID,
    'Standard Meeting' AS MEETING_TYPE,
    CASE 
        WHEN DURATION_MINUTES <= 15 THEN 'Quick Sync'
        WHEN DURATION_MINUTES <= 60 THEN 'Standard Meeting'
        WHEN DURATION_MINUTES <= 120 THEN 'Extended Meeting'
        ELSE 'Long Session'
    END AS MEETING_CATEGORY,
    CASE 
        WHEN DURATION_MINUTES <= 15 THEN 'Brief'
        WHEN DURATION_MINUTES <= 60 THEN 'Standard'
        WHEN DURATION_MINUTES <= 120 THEN 'Extended'
        ELSE 'Long'
    END AS DURATION_CATEGORY,
    'Unknown' AS PARTICIPANT_SIZE_CATEGORY,
    CASE 
        WHEN HOUR(START_TIME) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN HOUR(START_TIME) BETWEEN 12 AND 17 THEN 'Afternoon'
        WHEN HOUR(START_TIME) BETWEEN 18 AND 21 THEN 'Evening'
        ELSE 'Night'
    END AS TIME_OF_DAY_CATEGORY,
    DAYNAME(START_TIME) AS DAY_OF_WEEK,
    CASE WHEN DAYOFWEEK(START_TIME) IN (1, 7) THEN TRUE ELSE FALSE END AS IS_WEEKEND_MEETING,
    FALSE AS IS_RECURRING_TYPE,
    CASE 
        WHEN DURATION_MINUTES >= 60 THEN 8.0
        WHEN DURATION_MINUTES >= 30 THEN 7.0
        ELSE 6.0
    END AS MEETING_QUALITY_THRESHOLD,
    'Standard meeting features' AS TYPICAL_FEATURES_USED,
    'Business Meeting' AS BUSINESS_PURPOSE,
    CURRENT_DATE() AS LOAD_DATE,
    CURRENT_DATE() AS UPDATE_DATE,
    SOURCE_SYSTEM
FROM meeting_data
LIMIT 100 -- Limit to prevent too many combinations
