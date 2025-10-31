{{ config(
    materialized='table'
) }}

-- Meeting Type Dimension Table
WITH meeting_types AS (
    SELECT 'SCHEDULED' AS MEETING_TYPE_KEY, 'Scheduled Meeting' AS MEETING_TYPE_NAME
    UNION ALL
    SELECT 'INSTANT' AS MEETING_TYPE_KEY, 'Instant Meeting' AS MEETING_TYPE_NAME
    UNION ALL
    SELECT 'WEBINAR' AS MEETING_TYPE_KEY, 'Webinar' AS MEETING_TYPE_NAME
    UNION ALL
    SELECT 'PERSONAL' AS MEETING_TYPE_KEY, 'Personal Room' AS MEETING_TYPE_NAME
),

meeting_type_attributes AS (
    SELECT 
        'DIM_MEETING_TYPE_' || MEETING_TYPE_KEY AS DIM_MEETING_TYPE_ID,
        MEETING_TYPE_KEY,
        MEETING_TYPE_NAME,
        CASE 
            WHEN MEETING_TYPE_KEY = 'WEBINAR' THEN 'Broadcast' 
            ELSE 'Regular' 
        END AS MEETING_CATEGORY,
        CASE 
            WHEN MEETING_TYPE_KEY IN ('SCHEDULED', 'WEBINAR') THEN TRUE 
            ELSE FALSE 
        END AS IS_SCHEDULED,
        TRUE AS SUPPORTS_RECORDING,
        CASE 
            WHEN MEETING_TYPE_KEY = 'WEBINAR' THEN 10000 
            ELSE 500 
        END AS MAX_PARTICIPANTS,
        CASE 
            WHEN MEETING_TYPE_KEY = 'WEBINAR' THEN TRUE 
            ELSE FALSE 
        END AS REQUIRES_LICENSE,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        'BUSINESS_RULES' AS SOURCE_SYSTEM
    FROM meeting_types
)

SELECT * FROM meeting_type_attributes
