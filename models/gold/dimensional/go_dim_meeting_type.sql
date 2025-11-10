{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (PROCESS_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_START_TIME, PROCESS_STATUS, PROCESS_NOTES, LOAD_DATE, UPDATE_DATE) VALUES ('GO_DIM_MEETING_TYPE_TRANSFORMATION', 'SYSTEM_GENERATED', 'GO_DIM_MEETING_TYPE', CURRENT_TIMESTAMP(), 'STARTED', 'Meeting type dimension transformation started', CURRENT_DATE(), CURRENT_DATE())",
    post_hook="INSERT INTO {{ ref('go_audit_log') }} (PROCESS_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_END_TIME, PROCESS_STATUS, PROCESS_NOTES, LOAD_DATE, UPDATE_DATE) VALUES ('GO_DIM_MEETING_TYPE_TRANSFORMATION', 'SYSTEM_GENERATED', 'GO_DIM_MEETING_TYPE', CURRENT_TIMESTAMP(), 'COMPLETED', 'Meeting type dimension transformation completed successfully', CURRENT_DATE(), CURRENT_DATE())"
) }}

-- Meeting Type Dimension Table
-- Defines standard meeting types and their characteristics

WITH meeting_types AS (
    SELECT 'Instant Meeting' AS meeting_type, 'Instant' AS meeting_category, 'Short' AS duration_category
    UNION ALL
    SELECT 'Scheduled Meeting' AS meeting_type, 'Scheduled' AS meeting_category, 'Medium' AS duration_category
    UNION ALL
    SELECT 'Recurring Meeting' AS meeting_type, 'Recurring' AS meeting_category, 'Medium' AS duration_category
    UNION ALL
    SELECT 'Webinar' AS meeting_type, 'Webinar' AS meeting_category, 'Long' AS duration_category
    UNION ALL
    SELECT 'Personal Meeting Room' AS meeting_type, 'Personal' AS meeting_category, 'Variable' AS duration_category
),

meeting_type_attributes AS (
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
)

SELECT * FROM meeting_type_attributes
ORDER BY MEETING_TYPE_ID
