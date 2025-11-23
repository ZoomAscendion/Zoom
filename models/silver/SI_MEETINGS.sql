{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_MEETINGS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'STARTED', 'BZ_MEETINGS', 'SI_MEETINGS', 'DBT_PIPELINE', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_END_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, UPDATE_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_MEETINGS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'COMPLETED', 'BZ_MEETINGS', 'SI_MEETINGS', 'DBT_PIPELINE', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'"
) }}

-- Transform Bronze Meetings to Silver Meetings with enhanced timestamp format validation
WITH bronze_meetings AS (
    SELECT *
    FROM {{ source('bronze', 'BZ_MEETINGS') }}
    WHERE MEETING_ID IS NOT NULL
),

deduped_meetings AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY MEETING_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) as rn
    FROM bronze_meetings
),

transformed_meetings AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        TRIM(MEETING_TOPIC) AS MEETING_TOPIC,
        
        /* Enhanced START_TIME with EST timezone handling */
        CASE 
            WHEN START_TIME::STRING LIKE '%EST%' THEN 
                COALESCE(
                    TRY_TO_TIMESTAMP(REGEXP_REPLACE(START_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', ''), 'YYYY-MM-DD HH24:MI:SS'),
                    TRY_TO_TIMESTAMP(REGEXP_REPLACE(START_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', ''), 'DD/MM/YYYY HH24:MI'),
                    TRY_TO_TIMESTAMP(REGEXP_REPLACE(START_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', ''), 'MM/DD/YYYY HH24:MI'),
                    TRY_TO_TIMESTAMP(START_TIME::STRING)
                )
            ELSE 
                COALESCE(
                    TRY_TO_TIMESTAMP(START_TIME::STRING, 'YYYY-MM-DD HH24:MI:SS'),
                    TRY_TO_TIMESTAMP(START_TIME::STRING, 'DD/MM/YYYY HH24:MI'),
                    TRY_TO_TIMESTAMP(START_TIME::STRING, 'MM/DD/YYYY HH24:MI'),
                    TRY_TO_TIMESTAMP(START_TIME::STRING)
                )
        END AS START_TIME,
        
        /* Enhanced END_TIME with EST timezone handling */
        CASE 
            WHEN END_TIME::STRING LIKE '%EST%' THEN 
                COALESCE(
                    TRY_TO_TIMESTAMP(REGEXP_REPLACE(END_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', ''), 'YYYY-MM-DD HH24:MI:SS'),
                    TRY_TO_TIMESTAMP(REGEXP_REPLACE(END_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', ''), 'DD/MM/YYYY HH24:MI'),
                    TRY_TO_TIMESTAMP(REGEXP_REPLACE(END_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', ''), 'MM/DD/YYYY HH24:MI'),
                    TRY_TO_TIMESTAMP(END_TIME::STRING)
                )
            ELSE 
                COALESCE(
                    TRY_TO_TIMESTAMP(END_TIME::STRING, 'YYYY-MM-DD HH24:MI:SS'),
                    TRY_TO_TIMESTAMP(END_TIME::STRING, 'DD/MM/YYYY HH24:MI'),
                    TRY_TO_TIMESTAMP(END_TIME::STRING, 'MM/DD/YYYY HH24:MI'),
                    TRY_TO_TIMESTAMP(END_TIME::STRING)
                )
        END AS END_TIME,
        
        /* Clean duration with numeric validation */
        CASE 
            WHEN TRY_TO_NUMBER(REGEXP_REPLACE(DURATION_MINUTES::STRING, '[^0-9.]', '')) IS NOT NULL THEN
                TRY_TO_NUMBER(REGEXP_REPLACE(DURATION_MINUTES::STRING, '[^0-9.]', ''))
            ELSE TRY_TO_NUMBER(DURATION_MINUTES::STRING)
        END AS DURATION_MINUTES,
        
        CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
        CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        
        /* Data Quality Score Calculation */
        CASE 
            WHEN MEETING_ID IS NOT NULL 
                AND HOST_ID IS NOT NULL 
                AND START_TIME IS NOT NULL 
                AND END_TIME IS NOT NULL 
                AND DURATION_MINUTES IS NOT NULL
                AND DURATION_MINUTES >= 0
            THEN 100
            WHEN MEETING_ID IS NOT NULL AND HOST_ID IS NOT NULL 
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
                AND END_TIME > START_TIME
            THEN 'PASSED'
            WHEN MEETING_ID IS NOT NULL AND HOST_ID IS NOT NULL 
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
        
    FROM deduped_meetings
    WHERE rn = 1
)

SELECT *
FROM transformed_meetings
WHERE VALIDATION_STATUS IN ('PASSED', 'WARNING')
  AND START_TIME IS NOT NULL
  AND END_TIME IS NOT NULL
