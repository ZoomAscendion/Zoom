{{
  config(
    materialized='table',
    cluster_by=['MEETING_TYPE_ID', 'TIME_OF_DAY_CATEGORY'],
    tags=['dimension', 'gold'],
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (AUDIT_LOG_ID, PROCESS_NAME, PROCESS_TYPE, EXECUTION_START_TIMESTAMP, EXECUTION_STATUS, SOURCE_TABLE_NAME, TARGET_TABLE_NAME, PROCESS_TRIGGER, EXECUTED_BY, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key(['go_dim_meeting_type', run_started_at]) }}', 'go_dim_meeting_type', 'DIMENSION_LOAD', CURRENT_TIMESTAMP(), 'RUNNING', 'SI_MEETINGS', 'GO_DIM_MEETING_TYPE', 'DBT_RUN', 'DBT_SYSTEM', CURRENT_DATE(), CURRENT_DATE(), 'DBT_GOLD_LAYER'",
    post_hook="INSERT INTO {{ ref('go_audit_log') }} (AUDIT_LOG_ID, PROCESS_NAME, PROCESS_TYPE, EXECUTION_START_TIMESTAMP, EXECUTION_END_TIMESTAMP, EXECUTION_STATUS, SOURCE_TABLE_NAME, TARGET_TABLE_NAME, RECORDS_PROCESSED, PROCESS_TRIGGER, EXECUTED_BY, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key(['go_dim_meeting_type_complete', run_started_at]) }}', 'go_dim_meeting_type', 'DIMENSION_LOAD', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 'SUCCESS', 'SI_MEETINGS', 'GO_DIM_MEETING_TYPE', (SELECT COUNT(*) FROM {{ this }}), 'DBT_RUN', 'DBT_SYSTEM', CURRENT_DATE(), CURRENT_DATE(), 'DBT_GOLD_LAYER'"
  )
}}

-- Meeting Type Dimension Table
-- Creates meeting type dimension based on meeting characteristics from Silver layer

WITH source_meetings AS (
    SELECT 
        DURATION_MINUTES,
        START_TIME,
        DATA_QUALITY_SCORE,
        SOURCE_SYSTEM
    FROM {{ source('silver', 'si_meetings') }}
    WHERE VALIDATION_STATUS = 'PASSED'
),

meeting_type_categories AS (
    SELECT DISTINCT
        -- Meeting Category based on Duration
        CASE 
            WHEN DURATION_MINUTES <= 15 THEN 'Quick Sync'
            WHEN DURATION_MINUTES <= 60 THEN 'Standard Meeting'
            WHEN DURATION_MINUTES <= 120 THEN 'Extended Meeting'
            ELSE 'Long Session'
        END AS MEETING_CATEGORY,
        
        -- Duration Category
        CASE 
            WHEN DURATION_MINUTES <= 15 THEN 'Brief'
            WHEN DURATION_MINUTES <= 60 THEN 'Standard'
            WHEN DURATION_MINUTES <= 120 THEN 'Extended'
            ELSE 'Long'
        END AS DURATION_CATEGORY,
        
        -- Time of Day Category
        CASE 
            WHEN HOUR(START_TIME) BETWEEN 6 AND 11 THEN 'Morning'
            WHEN HOUR(START_TIME) BETWEEN 12 AND 17 THEN 'Afternoon'
            WHEN HOUR(START_TIME) BETWEEN 18 AND 21 THEN 'Evening'
            ELSE 'Night'
        END AS TIME_OF_DAY_CATEGORY,
        
        -- Day of Week
        DAYNAME(START_TIME) AS DAY_OF_WEEK,
        
        -- Weekend Flag
        CASE WHEN DAYOFWEEK(START_TIME) IN (1, 7) THEN TRUE ELSE FALSE END AS IS_WEEKEND_MEETING,
        
        -- Meeting Quality Score
        CASE 
            WHEN DATA_QUALITY_SCORE >= 90 THEN 9.0
            WHEN DATA_QUALITY_SCORE >= 80 THEN 8.0
            WHEN DATA_QUALITY_SCORE >= 70 THEN 7.0
            ELSE 6.0
        END AS MEETING_QUALITY_THRESHOLD,
        
        SOURCE_SYSTEM
    FROM source_meetings
),

meeting_type_dimension AS (
    SELECT 
        -- Primary Key
        ROW_NUMBER() OVER (ORDER BY MEETING_CATEGORY, DURATION_CATEGORY, TIME_OF_DAY_CATEGORY) AS MEETING_TYPE_ID,
        
        -- Meeting Type Information
        'Standard Meeting' AS MEETING_TYPE,
        MEETING_CATEGORY,
        DURATION_CATEGORY,
        'Unknown' AS PARTICIPANT_SIZE_CATEGORY, -- To be enhanced with participant count logic
        TIME_OF_DAY_CATEGORY,
        DAY_OF_WEEK,
        IS_WEEKEND_MEETING,
        FALSE AS IS_RECURRING_TYPE, -- To be enhanced with recurring meeting logic
        MEETING_QUALITY_THRESHOLD,
        
        -- Meeting Characteristics
        'Standard meeting features' AS TYPICAL_FEATURES_USED,
        'Business Meeting' AS BUSINESS_PURPOSE,
        
        -- Metadata
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        SOURCE_SYSTEM
    FROM meeting_type_categories
)

SELECT * FROM meeting_type_dimension
