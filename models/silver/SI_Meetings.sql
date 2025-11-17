{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_MEETINGS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'RUNNING', 'BZ_MEETINGS', 'SI_MEETINGS', 'DBT_PIPELINE', CURRENT_TIMESTAMP() WHERE EXISTS (SELECT 1 FROM {{ ref('SI_Audit_Log') }})",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_END_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, UPDATE_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_MEETINGS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'SUCCESS', 'BZ_MEETINGS', 'SI_MEETINGS', 'DBT_PIPELINE', CURRENT_TIMESTAMP() WHERE EXISTS (SELECT 1 FROM {{ ref('SI_Audit_Log') }})"
) }}

-- Silver Layer Meetings Table Transformation
-- Transforms Bronze BZ_MEETINGS to Silver SI_MEETINGS with EST timezone handling

WITH bronze_meetings AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        MEETING_TOPIC,
        START_TIME,
        END_TIME,
        DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('bronze', 'BZ_MEETINGS') }}
),

validated_meetings AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        TRIM(MEETING_TOPIC) as MEETING_TOPIC,
        
        -- Handle EST timezone conversion
        CASE 
            WHEN START_TIME::STRING LIKE '%EST%' THEN 
                CONVERT_TIMEZONE('America/New_York', 'UTC', 
                    TRY_TO_TIMESTAMP(REPLACE(START_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS'))
            ELSE START_TIME
        END as START_TIME,
        
        CASE 
            WHEN END_TIME::STRING LIKE '%EST%' THEN 
                CONVERT_TIMEZONE('America/New_York', 'UTC', 
                    TRY_TO_TIMESTAMP(REPLACE(END_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS'))
            ELSE END_TIME
        END as END_TIME,
        
        DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM bronze_meetings
),

quality_checked_meetings AS (
    SELECT 
        vm.*,
        
        -- Recalculate duration after timezone conversion
        DATEDIFF('minute', vm.START_TIME, vm.END_TIME) as CALCULATED_DURATION,
        
        -- Data Quality Score Calculation
        CASE 
            WHEN vm.MEETING_ID IS NULL THEN 0
            WHEN vm.HOST_ID IS NULL THEN 20
            WHEN vm.START_TIME IS NULL OR vm.END_TIME IS NULL THEN 30
            WHEN vm.END_TIME <= vm.START_TIME THEN 40
            WHEN vm.DURATION_MINUTES < 0 OR vm.DURATION_MINUTES > 1440 THEN 50
            WHEN ABS(vm.DURATION_MINUTES - DATEDIFF('minute', vm.START_TIME, vm.END_TIME)) > 1 THEN 70
            ELSE 100
        END as DATA_QUALITY_SCORE,
        
        -- Validation Status
        CASE 
            WHEN vm.MEETING_ID IS NULL OR vm.HOST_ID IS NULL OR vm.START_TIME IS NULL OR vm.END_TIME IS NULL THEN 'FAILED'
            WHEN vm.END_TIME <= vm.START_TIME OR vm.DURATION_MINUTES < 0 OR vm.DURATION_MINUTES > 1440 THEN 'FAILED'
            WHEN ABS(vm.DURATION_MINUTES - DATEDIFF('minute', vm.START_TIME, vm.END_TIME)) > 1 THEN 'WARNING'
            ELSE 'PASSED'
        END as VALIDATION_STATUS
    FROM validated_meetings vm
),

deduped_meetings AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        MEETING_TOPIC,
        START_TIME,
        END_TIME,
        DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATA_QUALITY_SCORE,
        VALIDATION_STATUS,
        ROW_NUMBER() OVER (PARTITION BY MEETING_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) as rn
    FROM quality_checked_meetings
    WHERE MEETING_ID IS NOT NULL
      AND HOST_ID IS NOT NULL
      AND START_TIME IS NOT NULL
      AND END_TIME IS NOT NULL
      AND END_TIME > START_TIME
)

SELECT 
    MEETING_ID,
    HOST_ID,
    MEETING_TOPIC,
    START_TIME,
    END_TIME,
    DURATION_MINUTES,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATE(LOAD_TIMESTAMP) as LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) as UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_meetings
WHERE rn = 1
