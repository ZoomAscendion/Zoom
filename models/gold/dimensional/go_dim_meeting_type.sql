{{ config(materialized='table') }}

-- Meeting Type Dimension Table
WITH meeting_types AS (
    SELECT 'Instant Meeting' AS meeting_type, 'Instant' AS meeting_category, 'Short' AS duration_category
    UNION ALL
    SELECT 'Scheduled Meeting', 'Scheduled', 'Medium'
    UNION ALL
    SELECT 'Recurring Meeting', 'Recurring', 'Medium'
    UNION ALL
    SELECT 'Webinar', 'Webinar', 'Long'
    UNION ALL
    SELECT 'Personal Meeting Room', 'Personal', 'Variable'
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY meeting_type) AS MEETING_TYPE_ID,
    meeting_type AS MEETING_TYPE,
    meeting_category AS MEETING_CATEGORY,
    duration_category AS DURATION_CATEGORY,
    CASE 
        WHEN duration_category = 'Short' THEN 'Small'
        WHEN duration_category = 'Medium' THEN 'Medium'
        WHEN duration_category = 'Long' THEN 'Large'
        ELSE 'Variable'
    END AS PARTICIPANT_SIZE_CATEGORY,
    CASE 
        WHEN meeting_category = 'Instant' THEN 'Anytime'
        WHEN meeting_category = 'Webinar' THEN 'Business Hours'
        ELSE 'Flexible'
    END AS TIME_OF_DAY_CATEGORY,
    CASE 
        WHEN meeting_category = 'Recurring' THEN TRUE
        ELSE FALSE
    END AS IS_RECURRING_TYPE,
    CASE 
        WHEN meeting_category = 'Webinar' THEN TRUE
        ELSE FALSE
    END AS REQUIRES_REGISTRATION,
    TRUE AS SUPPORTS_RECORDING,
    CASE 
        WHEN meeting_category = 'Webinar' THEN 10000
        WHEN meeting_category = 'Scheduled' THEN 1000
        ELSE 500
    END AS MAX_PARTICIPANTS_ALLOWED,
    CASE 
        WHEN meeting_category = 'Webinar' THEN 'High'
        ELSE 'Standard'
    END AS SECURITY_LEVEL,
    CASE 
        WHEN meeting_category = 'Webinar' THEN 'Broadcast'
        ELSE 'Interactive'
    END AS MEETING_FORMAT,
    CURRENT_DATE() AS LOAD_DATE,
    CURRENT_DATE() AS UPDATE_DATE,
    'SYSTEM_GENERATED' AS SOURCE_SYSTEM
FROM meeting_types
