{{ config(
    materialized='table',
    tags=['dimension', 'gold'],
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (AUDIT_LOG_ID, PROCESS_NAME, EXECUTION_START_TIMESTAMP, EXECUTION_STATUS, SOURCE_TABLE_NAME, TARGET_TABLE_NAME, LOAD_DATE, SOURCE_SYSTEM) VALUES (UUID_STRING(), 'GO_DIM_MEETING_LOAD', CURRENT_TIMESTAMP(), 'RUNNING', 'SILVER.SI_MEETINGS', 'GOLD.GO_DIM_MEETING', CURRENT_DATE(), 'DBT_GOLD_LAYER')",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET EXECUTION_END_TIMESTAMP = CURRENT_TIMESTAMP(), EXECUTION_STATUS = 'SUCCESS', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}) WHERE PROCESS_NAME = 'GO_DIM_MEETING_LOAD' AND DATE(EXECUTION_START_TIMESTAMP) = CURRENT_DATE()"
) }}

-- Meeting Dimension Transformation
-- Creates meeting dimension with enhanced categorization

WITH source_meetings AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        MEETING_TOPIC,
        START_TIME,
        END_TIME,
        DURATION_MINUTES,
        DATA_QUALITY_SCORE,
        SOURCE_SYSTEM,
        ROW_NUMBER() OVER (
            PARTITION BY MEETING_ID 
            ORDER BY UPDATE_TIMESTAMP DESC
        ) as rn
    FROM {{ source('silver', 'si_meetings') }}
    WHERE VALIDATION_STATUS = 'PASSED'
),

transformed_meetings AS (
    SELECT 
        MD5(MEETING_ID) as MEETING_KEY,
        'Standard Meeting' as MEETING_TYPE,
        CASE 
            WHEN DURATION_MINUTES <= 15 THEN 'Quick Sync'
            WHEN DURATION_MINUTES <= 60 THEN 'Standard Meeting'
            WHEN DURATION_MINUTES <= 120 THEN 'Extended Meeting'
            ELSE 'Long Session'
        END as MEETING_CATEGORY,
        CASE 
            WHEN DURATION_MINUTES <= 15 THEN 'Brief'
            WHEN DURATION_MINUTES <= 60 THEN 'Standard'
            WHEN DURATION_MINUTES <= 120 THEN 'Extended'
            ELSE 'Long'
        END as DURATION_CATEGORY,
        'Unknown' as PARTICIPANT_SIZE_CATEGORY,
        CASE 
            WHEN HOUR(START_TIME) BETWEEN 6 AND 11 THEN 'Morning'
            WHEN HOUR(START_TIME) BETWEEN 12 AND 17 THEN 'Afternoon'
            WHEN HOUR(START_TIME) BETWEEN 18 AND 21 THEN 'Evening'
            ELSE 'Night'
        END as TIME_OF_DAY_CATEGORY,
        DAYNAME(START_TIME) as DAY_OF_WEEK,
        CASE WHEN DAYOFWEEK(START_TIME) IN (1, 7) THEN TRUE ELSE FALSE END as IS_WEEKEND,
        FALSE as IS_RECURRING,
        CASE 
            WHEN DATA_QUALITY_SCORE >= 90 THEN 9.0
            WHEN DATA_QUALITY_SCORE >= 80 THEN 8.0
            WHEN DATA_QUALITY_SCORE >= 70 THEN 7.0
            ELSE 6.0
        END as MEETING_QUALITY_SCORE,
        'Standard Features' as TYPICAL_FEATURES_USED,
        'Business Meeting' as BUSINESS_PURPOSE,
        CURRENT_DATE() as LOAD_DATE,
        CURRENT_DATE() as UPDATE_DATE,
        SOURCE_SYSTEM
    FROM source_meetings
    WHERE rn = 1
)

SELECT * FROM transformed_meetings
