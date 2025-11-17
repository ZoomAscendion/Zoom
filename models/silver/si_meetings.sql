{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

/* Silver Meetings Table - Cleaned and standardized meeting information with critical numeric field cleaning */

WITH bronze_meetings AS (
    SELECT *
    FROM {{ source('bronze', 'bz_meetings') }}
),

numeric_field_cleaning AS (
    SELECT 
        bm.*,
        /* Critical P1 Fix: Clean text units from DURATION_MINUTES field */
        CASE 
            WHEN TRY_TO_NUMBER(REGEXP_REPLACE(bm.DURATION_MINUTES::STRING, '[^0-9.]', '')) IS NOT NULL THEN
                TRY_TO_NUMBER(REGEXP_REPLACE(bm.DURATION_MINUTES::STRING, '[^0-9.]', ''))
            ELSE TRY_TO_NUMBER(bm.DURATION_MINUTES::STRING)
        END AS CLEAN_DURATION_MINUTES,
        
        /* Enhanced timestamp handling for EST timezone */
        COALESCE(
            TRY_TO_TIMESTAMP(bm.START_TIME, 'YYYY-MM-DD HH24:MI:SS'),
            TRY_TO_TIMESTAMP(REGEXP_REPLACE(bm.START_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', ''), 'YYYY-MM-DD HH24:MI:SS'),
            TRY_TO_TIMESTAMP(bm.START_TIME, 'DD/MM/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(bm.START_TIME, 'MM/DD/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(bm.START_TIME)
        ) AS CLEAN_START_TIME,
        
        COALESCE(
            TRY_TO_TIMESTAMP(bm.END_TIME, 'YYYY-MM-DD HH24:MI:SS'),
            TRY_TO_TIMESTAMP(REGEXP_REPLACE(bm.END_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', ''), 'YYYY-MM-DD HH24:MI:SS'),
            TRY_TO_TIMESTAMP(bm.END_TIME, 'DD/MM/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(bm.END_TIME, 'MM/DD/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(bm.END_TIME)
        ) AS CLEAN_END_TIME
    FROM bronze_meetings bm
),

data_quality_checks AS (
    SELECT 
        nfc.*,
        /* Data Quality Score Calculation */
        (
            CASE WHEN nfc.MEETING_ID IS NOT NULL THEN 15 ELSE 0 END +
            CASE WHEN nfc.HOST_ID IS NOT NULL THEN 15 ELSE 0 END +
            CASE WHEN nfc.CLEAN_START_TIME IS NOT NULL THEN 15 ELSE 0 END +
            CASE WHEN nfc.CLEAN_END_TIME IS NOT NULL THEN 15 ELSE 0 END +
            CASE WHEN nfc.CLEAN_DURATION_MINUTES IS NOT NULL AND nfc.CLEAN_DURATION_MINUTES >= 0 AND nfc.CLEAN_DURATION_MINUTES <= 1440 THEN 15 ELSE 0 END +
            CASE WHEN nfc.CLEAN_END_TIME > nfc.CLEAN_START_TIME THEN 10 ELSE 0 END +
            CASE WHEN nfc.LOAD_TIMESTAMP IS NOT NULL THEN 10 ELSE 0 END +
            CASE WHEN nfc.SOURCE_SYSTEM IS NOT NULL THEN 5 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        /* Validation Status */
        CASE 
            WHEN nfc.MEETING_ID IS NULL OR nfc.HOST_ID IS NULL THEN 'FAILED'
            WHEN nfc.CLEAN_START_TIME IS NULL OR nfc.CLEAN_END_TIME IS NULL THEN 'FAILED'
            WHEN nfc.CLEAN_DURATION_MINUTES IS NULL THEN 'FAILED'
            WHEN nfc.CLEAN_END_TIME <= nfc.CLEAN_START_TIME THEN 'FAILED'
            WHEN nfc.CLEAN_DURATION_MINUTES < 0 OR nfc.CLEAN_DURATION_MINUTES > 1440 THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM numeric_field_cleaning nfc
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY MEETING_ID 
            ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC
        ) AS row_num
    FROM data_quality_checks
    WHERE MEETING_ID IS NOT NULL
),

final_meetings AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        TRIM(MEETING_TOPIC) AS MEETING_TOPIC,
        CLEAN_START_TIME AS START_TIME,
        CLEAN_END_TIME AS END_TIME,
        CLEAN_DURATION_MINUTES AS DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        DATA_QUALITY_SCORE,
        VALIDATION_STATUS
    FROM deduplication
    WHERE row_num = 1
      AND VALIDATION_STATUS != 'FAILED'
)

SELECT * FROM final_meetings
