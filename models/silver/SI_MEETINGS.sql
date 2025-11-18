{{ config(
    materialized='table'
) }}

/*
 * SI_MEETINGS - Silver Layer Meetings Table
 * Includes critical P1 DQ check for numeric field text unit cleaning
 */

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

cleansed_meetings AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        TRIM(MEETING_TOPIC) AS MEETING_TOPIC,
        START_TIME,
        END_TIME,
        
        /* Critical P1 DQ Check: Numeric Field Text Unit Cleaning */
        CASE 
            WHEN TRY_TO_NUMBER(REGEXP_REPLACE(DURATION_MINUTES::STRING, '[^0-9.]', '')) IS NOT NULL THEN
                TRY_TO_NUMBER(REGEXP_REPLACE(DURATION_MINUTES::STRING, '[^0-9.]', ''))
            WHEN TRY_TO_NUMBER(DURATION_MINUTES::STRING) IS NOT NULL THEN
                TRY_TO_NUMBER(DURATION_MINUTES::STRING)
            ELSE 0
        END AS DURATION_MINUTES,
        
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        COALESCE(DATE(UPDATE_TIMESTAMP), DATE(LOAD_TIMESTAMP)) AS UPDATE_DATE
    FROM bronze_meetings
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
    LOAD_DATE,
    UPDATE_DATE,
    
    /* Data Quality Score Calculation */
    CASE 
        WHEN MEETING_ID IS NOT NULL 
            AND HOST_ID IS NOT NULL 
            AND START_TIME IS NOT NULL 
            AND END_TIME IS NOT NULL 
            AND DURATION_MINUTES IS NOT NULL 
            AND DURATION_MINUTES >= 0 
            AND DURATION_MINUTES <= 1440
        THEN 100
        WHEN MEETING_ID IS NOT NULL AND HOST_ID IS NOT NULL AND START_TIME IS NOT NULL 
        THEN 75
        WHEN MEETING_ID IS NOT NULL 
        THEN 50
        ELSE 25
    END AS DATA_QUALITY_SCORE,
    
    /* Validation Status */
    CASE 
        WHEN MEETING_ID IS NOT NULL 
            AND HOST_ID IS NOT NULL 
            AND START_TIME IS NOT NULL 
            AND END_TIME IS NOT NULL 
            AND DURATION_MINUTES IS NOT NULL 
            AND DURATION_MINUTES >= 0 
            AND DURATION_MINUTES <= 1440
        THEN 'PASSED'
        WHEN MEETING_ID IS NOT NULL AND HOST_ID IS NOT NULL 
        THEN 'WARNING'
        ELSE 'FAILED'
    END AS VALIDATION_STATUS
FROM cleansed_meetings
