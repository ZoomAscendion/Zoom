{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_audit_log') }} (TABLE_NAME, STATUS, AUDIT_TIMESTAMP, LOAD_TIMESTAMP) SELECT 'SI_MEETINGS', 'PROCESSING_STARTED', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'si_audit_log'",
    post_hook="INSERT INTO {{ ref('si_audit_log') }} (TABLE_NAME, STATUS, AUDIT_TIMESTAMP, LOAD_TIMESTAMP) SELECT 'SI_MEETINGS', 'PROCESSING_COMPLETED', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'si_audit_log'"
) }}

-- SI_MEETINGS: Cleaned and standardized meeting information and session details
-- Transformation from Bronze BZ_MEETINGS to Silver SI_MEETINGS
-- Includes critical duration text cleaning and timestamp format handling

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
    WHERE MEETING_ID IS NOT NULL
),

-- Critical Data Quality: Clean duration text units (e.g., "108 mins")
cleansed_meetings AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        TRIM(MEETING_TOPIC) AS MEETING_TOPIC,
        -- Handle EST timezone format conversion
        CASE 
            WHEN START_TIME::STRING LIKE '%EST%' THEN 
                TRY_TO_TIMESTAMP(REPLACE(START_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS')
            WHEN TYPEOF(START_TIME) = 'VARCHAR' THEN 
                TRY_TO_TIMESTAMP(START_TIME, 'DD/MM/YYYY HH24:MI')
            ELSE START_TIME
        END AS START_TIME,
        CASE 
            WHEN END_TIME::STRING LIKE '%EST%' THEN 
                TRY_TO_TIMESTAMP(REPLACE(END_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS')
            WHEN TYPEOF(END_TIME) = 'VARCHAR' THEN 
                TRY_TO_TIMESTAMP(END_TIME, 'DD/MM/YYYY HH24:MI')
            ELSE END_TIME
        END AS END_TIME,
        -- Critical: Clean text units from DURATION_MINUTES (e.g., "108 mins" -> 108)
        CASE 
            WHEN DURATION_MINUTES::STRING REGEXP '[a-zA-Z]' THEN 
                TRY_TO_NUMBER(REGEXP_REPLACE(DURATION_MINUTES::STRING, '[^0-9.]', ''))
            ELSE DURATION_MINUTES
        END AS DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM bronze_meetings
),

-- Data Quality Validation and Scoring
validated_meetings AS (
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
        -- Calculate duration consistency
        ABS(COALESCE(DURATION_MINUTES, 0) - COALESCE(DATEDIFF('minute', START_TIME, END_TIME), 0)) AS duration_diff,
        -- Data Quality Scoring
        CASE 
            WHEN START_TIME IS NOT NULL AND END_TIME IS NOT NULL 
                 AND END_TIME > START_TIME 
                 AND DURATION_MINUTES IS NOT NULL 
                 AND DURATION_MINUTES > 0 
                 AND DURATION_MINUTES <= 1440
                 AND ABS(COALESCE(DURATION_MINUTES, 0) - COALESCE(DATEDIFF('minute', START_TIME, END_TIME), 0)) <= 1
            THEN 100
            WHEN START_TIME IS NOT NULL AND END_TIME IS NOT NULL AND END_TIME > START_TIME
            THEN 80
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        CASE 
            WHEN START_TIME IS NOT NULL AND END_TIME IS NOT NULL 
                 AND END_TIME > START_TIME 
                 AND DURATION_MINUTES IS NOT NULL 
                 AND DURATION_MINUTES > 0 
                 AND DURATION_MINUTES <= 1440
            THEN 'PASSED'
            WHEN START_TIME IS NULL OR END_TIME IS NULL OR END_TIME <= START_TIME
            THEN 'FAILED'
            ELSE 'WARNING'
        END AS VALIDATION_STATUS
    FROM cleansed_meetings
),

-- Remove Duplicates (Keep latest record based on UPDATE_TIMESTAMP)
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
    DURATION_MINUTES,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    -- Additional Silver layer metadata columns
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_meetings
WHERE rn = 1
  AND START_TIME IS NOT NULL
  AND END_TIME IS NOT NULL
  AND END_TIME > START_TIME
  AND DURATION_MINUTES IS NOT NULL
  AND DURATION_MINUTES > 0
