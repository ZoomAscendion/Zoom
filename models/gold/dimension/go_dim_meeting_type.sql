{{ config(
    materialized='table',
    unique_key='MEETING_TYPE_ID'
) }}

-- Meeting type dimension with categorization

WITH source_meetings AS (
    SELECT DISTINCT
        DURATION_MINUTES,
        START_TIME,
        SOURCE_SYSTEM
    FROM {{ source('silver', 'si_meetings') }}
    WHERE VALIDATION_STATUS = 'PASSED'
      AND DURATION_MINUTES IS NOT NULL
      AND START_TIME IS NOT NULL
),

meeting_categories AS (
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
            WHEN HOUR(START_TIME) BETWEEN 6 AND 11 THEN 'Morning'
            WHEN HOUR(START_TIME) BETWEEN 12 AND 17 THEN 'Afternoon'
            WHEN HOUR(START_TIME) BETWEEN 18 AND 21 THEN 'Evening'
            ELSE 'Night'
        END AS TIME_OF_DAY_CATEGORY,
        DAYNAME(START_TIME) AS DAY_OF_WEEK,
        CASE WHEN DAYOFWEEK(START_TIME) IN (1, 7) THEN TRUE ELSE FALSE END AS IS_WEEKEND_MEETING,
        SOURCE_SYSTEM
    FROM source_meetings
),

meeting_type_dimension AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY MEETING_CATEGORY, DURATION_CATEGORY, TIME_OF_DAY_CATEGORY) AS MEETING_TYPE_ID,
        MEETING_CATEGORY AS MEETING_TYPE,
        MEETING_CATEGORY,
        DURATION_CATEGORY,
        'Unknown' AS PARTICIPANT_SIZE_CATEGORY, -- To be enhanced with participant data
        TIME_OF_DAY_CATEGORY,
        DAY_OF_WEEK,
        IS_WEEKEND_MEETING,
        FALSE AS IS_RECURRING_TYPE, -- To be enhanced with recurring meeting logic
        CASE 
            WHEN DURATION_CATEGORY = 'Brief' THEN 7.0
            WHEN DURATION_CATEGORY = 'Standard' THEN 8.0
            WHEN DURATION_CATEGORY = 'Extended' THEN 7.5
            ELSE 6.0
        END AS MEETING_QUALITY_THRESHOLD,
        CASE 
            WHEN MEETING_CATEGORY = 'Quick Sync' THEN 'Screen Share, Chat'
            WHEN MEETING_CATEGORY = 'Standard Meeting' THEN 'Screen Share, Chat, Recording'
            WHEN MEETING_CATEGORY = 'Extended Meeting' THEN 'Screen Share, Chat, Recording, Breakout Rooms'
            ELSE 'All Features'
        END AS TYPICAL_FEATURES_USED,
        CASE 
            WHEN TIME_OF_DAY_CATEGORY = 'Morning' THEN 'Daily Standup'
            WHEN TIME_OF_DAY_CATEGORY = 'Afternoon' THEN 'Business Meeting'
            WHEN TIME_OF_DAY_CATEGORY = 'Evening' THEN 'Training Session'
            ELSE 'Ad-hoc Meeting'
        END AS BUSINESS_PURPOSE,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        SOURCE_SYSTEM
    FROM meeting_categories
)

SELECT * FROM meeting_type_dimension
