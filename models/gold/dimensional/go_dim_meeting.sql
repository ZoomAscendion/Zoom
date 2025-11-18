{{ config(
    materialized='table'
) }}

-- Meeting Dimension Table
-- Creates meeting dimension with enhanced categorization and derived attributes

WITH source_meetings AS (
    SELECT 
        COALESCE(MEETING_ID, 'UNKNOWN_MEETING') AS MEETING_ID,
        START_TIME,
        COALESCE(DURATION_MINUTES, 0) AS DURATION_MINUTES,
        COALESCE(DATA_QUALITY_SCORE, 100) AS DATA_QUALITY_SCORE,
        COALESCE(SOURCE_SYSTEM, 'UNKNOWN') AS SOURCE_SYSTEM
    FROM {{ source('silver', 'si_meetings') }}
    WHERE COALESCE(VALIDATION_STATUS, 'PASSED') = 'PASSED'
),

meeting_transformations AS (
    SELECT 
        MD5(MEETING_ID) AS MEETING_KEY,
        ROW_NUMBER() OVER (ORDER BY MEETING_ID) AS MEETING_ID,
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
            WHEN START_TIME IS NOT NULL AND HOUR(START_TIME) BETWEEN 6 AND 11 THEN 'Morning'
            WHEN START_TIME IS NOT NULL AND HOUR(START_TIME) BETWEEN 12 AND 17 THEN 'Afternoon'
            WHEN START_TIME IS NOT NULL AND HOUR(START_TIME) BETWEEN 18 AND 21 THEN 'Evening'
            WHEN START_TIME IS NOT NULL THEN 'Night'
            ELSE 'Unknown'
        END AS TIME_OF_DAY_CATEGORY,
        CASE 
            WHEN START_TIME IS NOT NULL THEN DAYNAME(START_TIME)
            ELSE 'Unknown'
        END AS DAY_OF_WEEK,
        CASE 
            WHEN START_TIME IS NOT NULL AND DAYOFWEEK(START_TIME) IN (1, 7) THEN TRUE 
            ELSE FALSE 
        END AS IS_WEEKEND,
        FALSE AS IS_RECURRING, -- To be enhanced with recurring meeting logic
        CASE 
            WHEN DATA_QUALITY_SCORE >= 90 THEN 9.0
            WHEN DATA_QUALITY_SCORE >= 80 THEN 8.0
            WHEN DATA_QUALITY_SCORE >= 70 THEN 7.0
            ELSE 6.0
        END AS MEETING_QUALITY_SCORE,
        'Screen Share, Chat, Recording' AS TYPICAL_FEATURES_USED,
        'Business Meeting' AS BUSINESS_PURPOSE,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        SOURCE_SYSTEM
    FROM source_meetings
),

deduped_meetings AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY MEETING_KEY 
            ORDER BY LOAD_DATE DESC
        ) AS rn
    FROM meeting_transformations
)

SELECT 
    MEETING_KEY,
    MEETING_ID,
    MEETING_TYPE,
    MEETING_CATEGORY,
    DURATION_CATEGORY,
    PARTICIPANT_SIZE_CATEGORY,
    TIME_OF_DAY_CATEGORY,
    DAY_OF_WEEK,
    IS_WEEKEND,
    IS_RECURRING,
    MEETING_QUALITY_SCORE,
    TYPICAL_FEATURES_USED,
    BUSINESS_PURPOSE,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM
FROM deduped_meetings
WHERE rn = 1
