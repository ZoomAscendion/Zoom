{{ config(
    materialized='table',
    on_schema_change='sync_all_columns',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, EXECUTED_BY, EXECUTION_ENVIRONMENT, SOURCE_SYSTEM, LOAD_DATE, UPDATE_DATE) SELECT 'WEB_' || REPLACE(REPLACE(REPLACE(CURRENT_TIMESTAMP()::STRING, ' ', '_'), ':', ''), '.', '_'), 'Silver_Webinars_ETL', CURRENT_TIMESTAMP(), 'STARTED', 'DBT_SILVER_JOB', 'PRODUCTION', 'ZOOM_PLATFORM', CURRENT_DATE(), CURRENT_DATE()",
    post_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, END_TIME, STATUS, EXECUTION_DURATION_SECONDS, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, RECORDS_PROCESSED, RECORDS_INSERTED, RECORDS_UPDATED, RECORDS_REJECTED, EXECUTED_BY, EXECUTION_ENVIRONMENT, DATA_LINEAGE_INFO, SOURCE_SYSTEM, LOAD_DATE, UPDATE_DATE) SELECT 'WEB_' || REPLACE(REPLACE(REPLACE(CURRENT_TIMESTAMP()::STRING, ' ', '_'), ':', ''), '.', '_'), 'Silver_Webinars_ETL', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 'COMPLETED', 0, 'BZ_WEBINARS', 'SI_WEBINARS', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 0, 0, 'DBT_SILVER_JOB', 'PRODUCTION', 'Bronze to Silver Webinars transformation', 'ZOOM_PLATFORM', CURRENT_DATE(), CURRENT_DATE()"
) }}

-- Silver Webinars Table
-- Transforms Bronze webinars data with validations and engagement metrics

WITH bronze_webinars AS (
    SELECT *
    FROM {{ source('bronze', 'bz_webinars') }}
),

-- Data Quality Validations
validated_webinars AS (
    SELECT
        w.*,
        -- Data Quality Flags
        CASE 
            WHEN w.WEBINAR_ID IS NULL THEN 'CRITICAL_NO_WEBINAR_ID'
            WHEN w.HOST_ID IS NULL THEN 'CRITICAL_NO_HOST_ID'
            WHEN w.END_TIME < w.START_TIME THEN 'CRITICAL_INVALID_TIME_SEQUENCE'
            WHEN w.REGISTRANTS < 0 THEN 'CRITICAL_NEGATIVE_REGISTRANTS'
            WHEN w.START_TIME > CURRENT_TIMESTAMP() + INTERVAL '1 YEAR' THEN 'WARNING_FUTURE_WEBINAR'
            WHEN w.WEBINAR_TOPIC IS NULL OR TRIM(w.WEBINAR_TOPIC) = '' THEN 'WARNING_MISSING_TOPIC'
            ELSE 'VALID'
        END AS data_quality_flag,
        
        -- Row Number for Deduplication
        ROW_NUMBER() OVER (PARTITION BY w.WEBINAR_ID ORDER BY w.UPDATE_TIMESTAMP DESC, w.LOAD_TIMESTAMP DESC) AS rn
    FROM bronze_webinars w
    WHERE w.WEBINAR_ID IS NOT NULL  -- Block records without WEBINAR_ID
      AND w.HOST_ID IS NOT NULL     -- Block records without HOST_ID
      AND w.END_TIME >= w.START_TIME -- Block invalid time sequences
      AND COALESCE(w.REGISTRANTS, 0) >= 0 -- Block negative registrants
),

-- Apply Transformations
transformed_webinars AS (
    SELECT
        -- Primary Keys
        vw.WEBINAR_ID,
        vw.HOST_ID,
        
        -- Standardized Business Columns
        COALESCE(NULLIF(TRIM(vw.WEBINAR_TOPIC), ''), 'Webinar Topic - Needs Update') AS WEBINAR_TOPIC,
        vw.START_TIME,
        COALESCE(vw.END_TIME, DATEADD('hour', 1, vw.START_TIME)) AS END_TIME,
        
        -- Calculated Duration
        DATEDIFF('minute', vw.START_TIME, COALESCE(vw.END_TIME, DATEADD('hour', 1, vw.START_TIME))) AS DURATION_MINUTES,
        
        GREATEST(COALESCE(vw.REGISTRANTS, 0), 0) AS REGISTRANTS,
        
        -- Derived Attendees (estimate 70% attendance rate)
        ROUND(GREATEST(COALESCE(vw.REGISTRANTS, 0), 0) * 0.7) AS ATTENDEES,
        
        -- Calculated Attendance Rate
        CASE 
            WHEN COALESCE(vw.REGISTRANTS, 0) > 0 THEN 
                ROUND((ROUND(GREATEST(COALESCE(vw.REGISTRANTS, 0), 0) * 0.7) / GREATEST(COALESCE(vw.REGISTRANTS, 0), 1)) * 100, 2)
            ELSE 0.00
        END AS ATTENDANCE_RATE,
        
        -- Metadata Columns
        vw.LOAD_TIMESTAMP,
        vw.UPDATE_TIMESTAMP,
        vw.SOURCE_SYSTEM,
        
        -- Data Quality Score
        CASE 
            WHEN vw.data_quality_flag = 'VALID' THEN 1.00
            WHEN vw.data_quality_flag LIKE 'WARNING%' THEN 0.80
            ELSE 0.60
        END AS DATA_QUALITY_SCORE,
        
        -- Standard Metadata
        DATE(vw.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(vw.UPDATE_TIMESTAMP) AS UPDATE_DATE
        
    FROM validated_webinars vw
    WHERE vw.rn = 1  -- Keep only the latest record for each WEBINAR_ID
      AND vw.data_quality_flag NOT LIKE 'CRITICAL%'
)

SELECT
    WEBINAR_ID,
    HOST_ID,
    WEBINAR_TOPIC,
    START_TIME,
    END_TIME,
    DURATION_MINUTES,
    REGISTRANTS,
    ATTENDEES,
    ATTENDANCE_RATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATA_QUALITY_SCORE,
    LOAD_DATE,
    UPDATE_DATE
FROM transformed_webinars
