{{ config(
    materialized='table',
    cluster_by=['MEETING_TYPE', 'TIME_OF_DAY_CATEGORY'],
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (PROCESS_ID, PROCESS_NAME, PROCESS_TYPE, PROCESS_START_TIMESTAMP, PROCESS_STATUS, SOURCE_TABLE, TARGET_TABLE, PROCESS_TRIGGER, EXECUTED_BY, LOAD_DATE, SOURCE_SYSTEM) VALUES ('{{ dbt_utils.generate_surrogate_key(["'go_dim_meeting_type'", "CURRENT_TIMESTAMP()"]) }}', 'GO_DIM_MEETING_TYPE_LOAD', 'DIMENSION_LOAD', CURRENT_TIMESTAMP(), 'RUNNING', 'SI_MEETINGS', 'GO_DIM_MEETING_TYPE', 'DBT_MODEL_RUN', 'DBT_USER', CURRENT_DATE(), 'DBT_GOLD_LAYER')",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET PROCESS_END_TIMESTAMP = CURRENT_TIMESTAMP(), PROCESS_STATUS = 'SUCCESS', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), RECORDS_SUCCESS = (SELECT COUNT(*) FROM {{ this }}), DATA_QUALITY_SCORE = 95.0 WHERE PROCESS_ID = '{{ dbt_utils.generate_surrogate_key(["'go_dim_meeting_type'", "CURRENT_TIMESTAMP()"]) }}'"
) }}

-- Meeting type dimension with enhanced categorization
-- Derives meeting characteristics from meeting data

WITH source_meetings AS (
    SELECT DISTINCT
        DURATION_MINUTES,
        START_TIME,
        DATA_QUALITY_SCORE,
        SOURCE_SYSTEM
    FROM {{ source('silver', 'si_meetings') }}
    WHERE VALIDATION_STATUS = 'PASSED'
      AND DURATION_MINUTES IS NOT NULL
      AND START_TIME IS NOT NULL
),

meeting_type_dimension AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY DURATION_CATEGORY, TIME_OF_DAY_CATEGORY) AS MEETING_TYPE_ID,
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
            WHEN HOUR(START_TIME) BETWEEN 6 AND 11 THEN 'Morning'
            WHEN HOUR(START_TIME) BETWEEN 12 AND 17 THEN 'Afternoon'
            WHEN HOUR(START_TIME) BETWEEN 18 AND 21 THEN 'Evening'
            ELSE 'Night'
        END AS TIME_OF_DAY_CATEGORY,
        DAYNAME(START_TIME) AS DAY_OF_WEEK,
        CASE WHEN DAYOFWEEK(START_TIME) IN (1, 7) THEN TRUE ELSE FALSE END AS IS_WEEKEND_MEETING,
        FALSE AS IS_RECURRING_TYPE,
        CASE 
            WHEN DATA_QUALITY_SCORE >= 90 THEN 9.0
            WHEN DATA_QUALITY_SCORE >= 80 THEN 8.0
            WHEN DATA_QUALITY_SCORE >= 70 THEN 7.0
            ELSE 6.0
        END AS MEETING_QUALITY_THRESHOLD,
        'Standard meeting features' AS TYPICAL_FEATURES_USED,
        'Business Meeting' AS BUSINESS_PURPOSE,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        SOURCE_SYSTEM
    FROM source_meetings
)

SELECT DISTINCT * FROM meeting_type_dimension
