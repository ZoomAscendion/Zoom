{{ config(
    materialized='table'
) }}

-- Gold Dimension: Meeting Type Dimension
-- Description: Meeting types and characteristics

WITH meeting_types AS (
    SELECT 
        'Instant Meeting' AS meeting_type,
        'Instant' AS meeting_category,
        'Short' AS duration_category
    UNION ALL
    SELECT 
        'Scheduled Meeting' AS meeting_type,
        'Scheduled' AS meeting_category,
        'Medium' AS duration_category
    UNION ALL
    SELECT 
        'Webinar' AS meeting_type,
        'Webinar' AS meeting_category,
        'Long' AS duration_category
    UNION ALL
    SELECT 
        'Recurring Meeting' AS meeting_type,
        'Recurring' AS meeting_category,
        'Variable' AS duration_category
),

meeting_type_enrichment AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY meeting_type) AS MEETING_TYPE_ID,
        meeting_type AS MEETING_TYPE,
        meeting_category AS MEETING_CATEGORY,
        duration_category AS DURATION_CATEGORY,
        CASE 
            WHEN meeting_type = 'Webinar' THEN 'Large'
            WHEN meeting_type = 'Instant Meeting' THEN 'Small'
            ELSE 'Medium'
        END AS PARTICIPANT_SIZE_CATEGORY,
        'Business Hours' AS TIME_OF_DAY_CATEGORY,
        CASE 
            WHEN meeting_type = 'Recurring Meeting' THEN TRUE
            ELSE FALSE
        END AS IS_RECURRING_TYPE,
        CASE 
            WHEN meeting_type = 'Webinar' THEN TRUE
            ELSE FALSE
        END AS REQUIRES_REGISTRATION,
        TRUE AS SUPPORTS_RECORDING,
        CASE 
            WHEN meeting_type = 'Webinar' THEN 10000
            WHEN meeting_type = 'Instant Meeting' THEN 100
            ELSE 500
        END AS MAX_PARTICIPANTS_ALLOWED,
        'Standard' AS SECURITY_LEVEL,
        CASE 
            WHEN meeting_type = 'Webinar' THEN 'Broadcast'
            ELSE 'Interactive'
        END AS MEETING_FORMAT,
        CURRENT_DATE AS LOAD_DATE,
        CURRENT_DATE AS UPDATE_DATE,
        'SYSTEM_GENERATED' AS SOURCE_SYSTEM
    FROM meeting_types
)

SELECT * FROM meeting_type_enrichment
