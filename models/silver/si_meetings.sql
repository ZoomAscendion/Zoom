{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (AUDIT_ID, PIPELINE_NAME, PIPELINE_RUN_ID, SOURCE_TABLE, TARGET_TABLE, EXECUTION_START_TIME, PROCESSED_BY, PROCESSING_MODE, EXECUTION_STATUS, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_MEETINGS', UUID_STRING(), 'BZ_MEETINGS', 'SI_MEETINGS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 'INCREMENTAL', 'STARTED', CURRENT_DATE(), CURRENT_DATE(), 'SILVER_ETL_PROCESS' WHERE '{{ this.name }}' != 'si_pipeline_audit'",
    post_hook="UPDATE {{ ref('si_pipeline_audit') }} SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(), EXECUTION_DURATION_SECONDS = DATEDIFF('second', EXECUTION_START_TIME, CURRENT_TIMESTAMP()), EXECUTION_STATUS = 'SUCCESS', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), RECORDS_INSERTED = (SELECT COUNT(*) FROM {{ this }}) WHERE TARGET_TABLE = 'SI_MEETINGS' AND EXECUTION_STATUS = 'STARTED' AND DATE(EXECUTION_START_TIME) = CURRENT_DATE() AND '{{ this.name }}' != 'si_pipeline_audit'"
) }}

-- Meetings transformation with data quality checks
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
    FROM {{ source('bronze', 'bz_meetings') }}
    WHERE MEETING_ID IS NOT NULL 
      AND TRIM(MEETING_ID) != ''
      AND START_TIME IS NOT NULL
      AND END_TIME IS NOT NULL
),

validated_meetings AS (
    SELECT 
        bm.MEETING_ID,
        bm.HOST_ID,
        COALESCE(TRIM(bm.MEETING_TOPIC), 'No Topic') AS MEETING_TOPIC,
        bm.START_TIME,
        bm.END_TIME,
        -- Validate duration and calculate if needed
        CASE 
            WHEN bm.DURATION_MINUTES IS NULL OR bm.DURATION_MINUTES < 0 OR bm.DURATION_MINUTES > 1440
            THEN GREATEST(0, DATEDIFF('minute', bm.START_TIME, bm.END_TIME))
            ELSE bm.DURATION_MINUTES
        END AS DURATION_MINUTES,
        DATE(bm.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(bm.UPDATE_TIMESTAMP) AS UPDATE_DATE,
        bm.SOURCE_SYSTEM,
        bm.LOAD_TIMESTAMP,
        bm.UPDATE_TIMESTAMP,
        ROW_NUMBER() OVER (PARTITION BY bm.MEETING_ID ORDER BY bm.UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_meetings bm
    INNER JOIN {{ ref('si_users') }} u ON bm.HOST_ID = u.USER_ID
    WHERE bm.START_TIME < bm.END_TIME  -- Ensure chronological consistency
      AND bm.DURATION_MINUTES >= 1    -- Exclude test meetings
),

deduped_meetings AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        MEETING_TOPIC,
        START_TIME,
        END_TIME,
        DURATION_MINUTES,
        LOAD_DATE,
        UPDATE_DATE,
        SOURCE_SYSTEM,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP
    FROM validated_meetings
    WHERE rn = 1
)

SELECT 
    MEETING_ID,
    HOST_ID,
    MEETING_TOPIC,
    START_TIME,
    END_TIME,
    DURATION_MINUTES,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP
FROM deduped_meetings
