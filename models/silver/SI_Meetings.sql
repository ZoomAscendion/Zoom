{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY, SOURCE_SYSTEM) SELECT UUID_STRING(), 'SI_MEETINGS', 'PIPELINE_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE', 'SILVER_LAYER' WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY, SOURCE_SYSTEM) SELECT UUID_STRING(), 'SI_MEETINGS', 'PIPELINE_END', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE', 'SILVER_LAYER' WHERE '{{ this.name }}' != 'SI_Audit_Log'"
) }}

-- SI_MEETINGS: Silver layer transformation from Bronze BZ_MEETINGS
-- Description: Stores cleaned and standardized meeting information with enhanced format validation

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
    FROM BRONZE.BZ_MEETINGS
    WHERE MEETING_ID IS NOT NULL
),

cleaned_meetings AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        TRIM(MEETING_TOPIC) AS MEETING_TOPIC,
        
        /* Enhanced timestamp handling with EST timezone support */
        CASE 
            WHEN START_TIME::STRING LIKE '%EST%' THEN 
                TRY_TO_TIMESTAMP(REGEXP_REPLACE(START_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', ''), 'YYYY-MM-DD HH24:MI:SS')
            ELSE START_TIME
        END AS START_TIME,
        
        CASE 
            WHEN END_TIME::STRING LIKE '%EST%' THEN 
                TRY_TO_TIMESTAMP(REGEXP_REPLACE(END_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', ''), 'YYYY-MM-DD HH24:MI:SS')
            ELSE END_TIME
        END AS END_TIME,
        
        /* Critical P1 Fix: Clean text units from DURATION_MINUTES field */
        CASE 
            WHEN TRY_TO_NUMBER(REGEXP_REPLACE(DURATION_MINUTES::STRING, '[^0-9.]', '')) IS NOT NULL THEN
                TRY_TO_NUMBER(REGEXP_REPLACE(DURATION_MINUTES::STRING, '[^0-9.]', ''))
            ELSE TRY_TO_NUMBER(DURATION_MINUTES::STRING)
        END AS CLEAN_DURATION_MINUTES,
        
        DURATION_MINUTES AS ORIGINAL_DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        CASE WHEN UPDATE_TIMESTAMP IS NOT NULL THEN DATE(UPDATE_TIMESTAMP) ELSE NULL END AS UPDATE_DATE
    FROM bronze_meetings
),

validated_meetings AS (
    SELECT 
        *,
        /* Calculate data quality score */
        CASE 
            WHEN MEETING_ID IS NOT NULL 
                AND HOST_ID IS NOT NULL 
                AND START_TIME IS NOT NULL 
                AND END_TIME IS NOT NULL 
                AND CLEAN_DURATION_MINUTES IS NOT NULL
                AND END_TIME > START_TIME
                AND CLEAN_DURATION_MINUTES BETWEEN 0 AND 1440
            THEN 100
            WHEN MEETING_ID IS NOT NULL AND HOST_ID IS NOT NULL AND START_TIME IS NOT NULL 
            THEN 75
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        
        /* Set validation status */
        CASE 
            WHEN MEETING_ID IS NOT NULL 
                AND HOST_ID IS NOT NULL 
                AND START_TIME IS NOT NULL 
                AND END_TIME IS NOT NULL 
                AND CLEAN_DURATION_MINUTES IS NOT NULL
                AND END_TIME > START_TIME
                AND CLEAN_DURATION_MINUTES BETWEEN 0 AND 1440
            THEN 'PASSED'
            WHEN MEETING_ID IS NOT NULL AND HOST_ID IS NOT NULL 
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM cleaned_meetings
),

deduped_meetings AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY MEETING_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM validated_meetings
)

SELECT 
    MEETING_ID,
    HOST_ID,
    MEETING_TOPIC,
    START_TIME,
    END_TIME,
    CLEAN_DURATION_MINUTES AS DURATION_MINUTES,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    LOAD_DATE,
    UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_meetings
WHERE rn = 1
    AND VALIDATION_STATUS != 'FAILED'
