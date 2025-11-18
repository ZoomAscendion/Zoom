{{ config(
    materialized='table'
) }}

-- Meeting type dimension transformation from Silver to Gold layer
WITH meeting_data AS (
    SELECT 
        MEETING_ID,
        DURATION_MINUTES,
        START_TIME,
        SOURCE_SYSTEM
    FROM {{ source('silver', 'si_meetings') }}
    WHERE MEETING_ID IS NOT NULL
),

meeting_type_transformed AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY MEETING_ID) AS MEETING_TYPE_ID,
        'Standard Meeting' AS MEETING_TYPE,
        CASE 
            WHEN COALESCE(DURATION_MINUTES, 0) <= 15 THEN 'Quick Sync'
            WHEN COALESCE(DURATION_MINUTES, 0) <= 60 THEN 'Standard Meeting'
            WHEN COALESCE(DURATION_MINUTES, 0) <= 120 THEN 'Extended Meeting'
            ELSE 'Long Session'
        END AS MEETING_CATEGORY,
        CASE 
            WHEN COALESCE(DURATION_MINUTES, 0) <= 15 THEN 'Brief'
            WHEN COALESCE(DURATION_MINUTES, 0) <= 60 THEN 'Standard'
            WHEN COALESCE(DURATION_MINUTES, 0) <= 120 THEN 'Extended'
            ELSE 'Long'
        END AS DURATION_CATEGORY,
        'Unknown' AS PARTICIPANT_SIZE_CATEGORY,
        CASE 
            WHEN HOUR(COALESCE(START_TIME, CURRENT_TIMESTAMP())) BETWEEN 6 AND 11 THEN 'Morning'
            WHEN HOUR(COALESCE(START_TIME, CURRENT_TIMESTAMP())) BETWEEN 12 AND 17 THEN 'Afternoon'
            WHEN HOUR(COALESCE(START_TIME, CURRENT_TIMESTAMP())) BETWEEN 18 AND 21 THEN 'Evening'
            ELSE 'Night'
        END AS TIME_OF_DAY_CATEGORY,
        DAYNAME(COALESCE(START_TIME, CURRENT_TIMESTAMP())) AS DAY_OF_WEEK,
        CASE WHEN DAYOFWEEK(COALESCE(START_TIME, CURRENT_TIMESTAMP())) IN (1, 7) THEN TRUE ELSE FALSE END AS IS_WEEKEND_MEETING,
        FALSE AS IS_RECURRING_TYPE,
        8.0 AS MEETING_QUALITY_THRESHOLD,
        'Standard meeting features' AS TYPICAL_FEATURES_USED,
        'Business Meeting' AS BUSINESS_PURPOSE,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        COALESCE(SOURCE_SYSTEM, 'UNKNOWN') AS SOURCE_SYSTEM
    FROM meeting_data
)

SELECT * FROM meeting_type_transformed
