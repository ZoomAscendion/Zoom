{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

-- Silver Meetings transformation with data quality checks
WITH bronze_meetings AS (
    SELECT *
    FROM {{ source('bronze', 'bz_meetings') }}
    WHERE MEETING_ID IS NOT NULL
      AND TRIM(MEETING_ID) != ''
      AND HOST_ID IS NOT NULL
      AND START_TIME IS NOT NULL
      AND END_TIME IS NOT NULL
      AND START_TIME < END_TIME
      AND DURATION_MINUTES >= 0
      AND DURATION_MINUTES <= 1440
),

valid_hosts AS (
    SELECT DISTINCT USER_ID
    FROM {{ ref('si_users') }}
),

filtered_meetings AS (
    SELECT bm.*
    FROM bronze_meetings bm
    INNER JOIN valid_hosts vh ON bm.HOST_ID = vh.USER_ID
),

deduped_meetings AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY MEETING_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM filtered_meetings
),

final_meetings AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        TRIM(MEETING_TOPIC) AS MEETING_TOPIC,
        START_TIME,
        END_TIME,
        COALESCE(DURATION_MINUTES, DATEDIFF('minute', START_TIME, END_TIME)) AS DURATION_MINUTES,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        SOURCE_SYSTEM,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP
    FROM deduped_meetings
    WHERE rn = 1
)

SELECT * FROM final_meetings
