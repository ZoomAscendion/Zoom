{{ config(
    materialized='table'
) }}

-- Meeting Type Dimension Table
-- Dimension table containing meeting types and characteristics

WITH meeting_categories AS (
    SELECT DISTINCT
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
        CASE 
            WHEN START_TIME IS NOT NULL THEN
                CASE 
                    WHEN HOUR(START_TIME) BETWEEN 6 AND 11 THEN 'Morning'
                    WHEN HOUR(START_TIME) BETWEEN 12 AND 17 THEN 'Afternoon'
                    WHEN HOUR(START_TIME) BETWEEN 18 AND 21 THEN 'Evening'
                    ELSE 'Night'
                END
            ELSE 'Unknown'
        END AS TIME_OF_DAY_CATEGORY,
        CASE 
            WHEN START_TIME IS NOT NULL THEN DAYNAME(START_TIME)
            ELSE 'Unknown'
        END AS DAY_OF_WEEK,
        CASE 
            WHEN START_TIME IS NOT NULL AND DAYOFWEEK(START_TIME) IN (1, 7) THEN TRUE
            ELSE FALSE
        END AS IS_WEEKEND_MEETING,
        SOURCE_SYSTEM
    FROM {{ source('silver', 'si_meetings') }}
    WHERE VALIDATION_STATUS = 'PASSED'
      AND DURATION_MINUTES IS NOT NULL
      AND DURATION_MINUTES > 0
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY MEETING_CATEGORY, DURATION_CATEGORY, TIME_OF_DAY_CATEGORY) AS MEETING_TYPE_ID,
    'Standard Meeting' AS MEETING_TYPE,
    MEETING_CATEGORY,
    DURATION_CATEGORY,
    'Unknown' AS PARTICIPANT_SIZE_CATEGORY,
    TIME_OF_DAY_CATEGORY,
    DAY_OF_WEEK,
    IS_WEEKEND_MEETING,
    FALSE AS IS_RECURRING_TYPE,
    7.0 AS MEETING_QUALITY_THRESHOLD,
    'Standard meeting features' AS TYPICAL_FEATURES_USED,
    'Business Meeting' AS BUSINESS_PURPOSE,
    CURRENT_DATE() AS LOAD_DATE,
    CURRENT_DATE() AS UPDATE_DATE,
    SOURCE_SYSTEM
FROM meeting_categories
LIMIT 50
