{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (PROCESS_ID, PROCESS_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_START_TIME, PROCESS_STATUS, CREATED_AT, UPDATED_AT) VALUES (GENERATE_UUID(), 'go_dim_meeting_type_generation', 'SYSTEM', 'GO_DIM_MEETING_TYPE', CURRENT_TIMESTAMP(), 'STARTED', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP())",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET PROCESS_END_TIME = CURRENT_TIMESTAMP(), PROCESS_STATUS = 'COMPLETED', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), RECORDS_SUCCESS = (SELECT COUNT(*) FROM {{ this }}), UPDATED_AT = CURRENT_TIMESTAMP() WHERE PROCESS_NAME = 'go_dim_meeting_type_generation' AND PROCESS_STATUS = 'STARTED'"
) }}

-- Meeting Type Dimension Table
WITH meeting_types AS (
    SELECT 'Instant Meeting' AS meeting_type, 'Instant' AS meeting_category, 'Short' AS duration_category
    UNION ALL
    SELECT 'Scheduled Meeting' AS meeting_type, 'Scheduled' AS meeting_category, 'Medium' AS duration_category
    UNION ALL
    SELECT 'Webinar' AS meeting_type, 'Webinar' AS meeting_category, 'Long' AS duration_category
    UNION ALL
    SELECT 'Recurring Meeting' AS meeting_type, 'Scheduled' AS meeting_category, 'Variable' AS duration_category
    UNION ALL
    SELECT 'Personal Meeting Room' AS meeting_type, 'Personal' AS meeting_category, 'Variable' AS duration_category
),

meeting_type_enriched AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY meeting_type) AS MEETING_TYPE_ID,
        meeting_type AS MEETING_TYPE,
        meeting_category AS MEETING_CATEGORY,
        duration_category AS DURATION_CATEGORY,
        CASE 
            WHEN duration_category = 'Short' THEN 'Small Group'
            WHEN duration_category = 'Medium' THEN 'Medium Group'
            WHEN duration_category = 'Long' THEN 'Large Group'
            ELSE 'Variable'
        END AS PARTICIPANT_SIZE_CATEGORY,
        CASE 
            WHEN meeting_category = 'Instant' THEN 'Anytime'
            WHEN meeting_category = 'Webinar' THEN 'Business Hours'
            ELSE 'Scheduled'
        END AS TIME_OF_DAY_CATEGORY,
        CASE 
            WHEN meeting_type LIKE '%Recurring%' THEN TRUE
            ELSE FALSE
        END AS IS_RECURRING_TYPE,
        CASE 
            WHEN meeting_type = 'Webinar' THEN TRUE
            ELSE FALSE
        END AS REQUIRES_REGISTRATION,
        TRUE AS SUPPORTS_RECORDING,
        CASE 
            WHEN meeting_type = 'Webinar' THEN 10000
            WHEN meeting_type LIKE '%Personal%' THEN 100
            ELSE 500
        END AS MAX_PARTICIPANTS_ALLOWED,
        'Standard' AS SECURITY_LEVEL,
        CASE 
            WHEN meeting_type = 'Webinar' THEN 'Broadcast'
            ELSE 'Interactive'
        END AS MEETING_FORMAT,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        'SYSTEM' AS SOURCE_SYSTEM
    FROM meeting_types
)

SELECT * FROM meeting_type_enriched
