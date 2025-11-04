{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, EXECUTED_BY, EXECUTION_ENVIRONMENT, DATA_LINEAGE_INFO, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT CONCAT('EXEC_', TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), '_FTR'), 'Silver_Feature_Usage_ETL', CURRENT_TIMESTAMP(), 'Started', 'BRONZE.BZ_FEATURE_USAGE', 'SILVER.SI_FEATURE_USAGE', 'DBT_SILVER_PIPELINE', 'PRODUCTION', 'Processing feature usage data from Bronze to Silver', CURRENT_DATE(), CURRENT_DATE(), 'ZOOM_PLATFORM' WHERE '{{ this.name }}' != 'si_pipeline_audit'",
    post_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (EXECUTION_ID, PIPELINE_NAME, END_TIME, STATUS, RECORDS_PROCESSED, RECORDS_INSERTED, EXECUTED_BY, EXECUTION_ENVIRONMENT, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT CONCAT('EXEC_', TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), '_FTR_END'), 'Silver_Feature_Usage_ETL', CURRENT_TIMESTAMP(), 'Completed', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 'DBT_SILVER_PIPELINE', 'PRODUCTION', CURRENT_DATE(), CURRENT_DATE(), 'ZOOM_PLATFORM' WHERE '{{ this.name }}' != 'si_pipeline_audit'"
) }}

-- Silver Feature Usage Table Transformation
WITH bronze_feature_usage AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('bronze', 'bz_feature_usage') }}
    WHERE USAGE_ID IS NOT NULL
      AND MEETING_ID IS NOT NULL
),

validated_feature_usage AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        
        CASE 
            WHEN FEATURE_NAME IS NULL OR TRIM(FEATURE_NAME) = '' THEN 'Unknown Feature'
            ELSE TRIM(FEATURE_NAME)
        END AS FEATURE_NAME,
        
        CASE 
            WHEN USAGE_COUNT < 0 THEN 0
            WHEN USAGE_COUNT IS NULL THEN 0
            ELSE USAGE_COUNT
        END AS USAGE_COUNT,
        
        CASE 
            WHEN USAGE_COUNT IS NULL OR USAGE_COUNT <= 0 THEN 0
            ELSE USAGE_COUNT * 2
        END AS USAGE_DURATION,
        
        CASE 
            WHEN LOWER(FEATURE_NAME) LIKE '%audio%' OR LOWER(FEATURE_NAME) LIKE '%microphone%' THEN 'Audio'
            WHEN LOWER(FEATURE_NAME) LIKE '%video%' OR LOWER(FEATURE_NAME) LIKE '%camera%' THEN 'Video'
            WHEN LOWER(FEATURE_NAME) LIKE '%chat%' OR LOWER(FEATURE_NAME) LIKE '%share%' OR LOWER(FEATURE_NAME) LIKE '%whiteboard%' THEN 'Collaboration'
            WHEN LOWER(FEATURE_NAME) LIKE '%security%' OR LOWER(FEATURE_NAME) LIKE '%password%' THEN 'Security'
            ELSE 'Other'
        END AS FEATURE_CATEGORY,
        
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        (
            CASE WHEN USAGE_ID IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN MEETING_ID IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN FEATURE_NAME IS NOT NULL AND TRIM(FEATURE_NAME) != '' THEN 0.25 ELSE 0 END +
            CASE WHEN USAGE_COUNT >= 0 THEN 0.25 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
        
    FROM bronze_feature_usage
),

deduped_feature_usage AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY USAGE_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM validated_feature_usage
)

SELECT 
    USAGE_ID,
    MEETING_ID,
    FEATURE_NAME,
    USAGE_COUNT,
    USAGE_DURATION,
    FEATURE_CATEGORY,
    USAGE_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATA_QUALITY_SCORE,
    LOAD_DATE,
    UPDATE_DATE
FROM deduped_feature_usage
WHERE rn = 1
  AND USAGE_COUNT >= 0
  AND DATA_QUALITY_SCORE >= 0.75
