{{ config(
    materialized='table',
    pre_hook="INSERT INTO SILVER.SI_AUDIT_LOG (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_FEATURE_USAGE', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'RUNNING', 'BZ_FEATURE_USAGE', 'SI_FEATURE_USAGE', 'DBT_PIPELINE', CURRENT_TIMESTAMP()",
    post_hook="UPDATE SILVER.SI_AUDIT_LOG SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(), EXECUTION_STATUS = 'SUCCESS', RECORDS_SUCCESS = (SELECT COUNT(*) FROM SILVER.SI_FEATURE_USAGE), UPDATE_TIMESTAMP = CURRENT_TIMESTAMP() WHERE PIPELINE_NAME = 'BRONZE_TO_SILVER_FEATURE_USAGE' AND EXECUTION_STATUS = 'RUNNING'"
) }}

-- Silver Layer Feature Usage Table
-- Transforms and cleanses feature usage data from Bronze layer
-- Applies data quality checks and business rules

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
    FROM BRONZE.BZ_FEATURE_USAGE
),

cleansed_feature_usage AS (
    SELECT 
        bfu.USAGE_ID,
        bfu.MEETING_ID,
        UPPER(TRIM(bfu.FEATURE_NAME)) AS FEATURE_NAME,
        bfu.USAGE_COUNT,
        bfu.USAGE_DATE,
        bfu.LOAD_TIMESTAMP,
        bfu.UPDATE_TIMESTAMP,
        bfu.SOURCE_SYSTEM,
        
        -- Additional Silver layer metadata
        DATE(bfu.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(bfu.UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM bronze_feature_usage bfu
    INNER JOIN SILVER.SI_MEETINGS sm ON bfu.MEETING_ID = sm.MEETING_ID
    WHERE bfu.USAGE_ID IS NOT NULL
        AND bfu.MEETING_ID IS NOT NULL
        AND bfu.FEATURE_NAME IS NOT NULL
        AND bfu.USAGE_COUNT IS NOT NULL
        AND bfu.USAGE_COUNT >= 0
        AND bfu.USAGE_DATE IS NOT NULL
        AND DATE(bfu.USAGE_DATE) = DATE(sm.START_TIME)
),

data_quality_scored AS (
    SELECT 
        *,
        -- Calculate data quality score
        CASE 
            WHEN USAGE_ID IS NOT NULL 
                AND MEETING_ID IS NOT NULL 
                AND FEATURE_NAME IS NOT NULL 
                AND USAGE_COUNT IS NOT NULL 
                AND USAGE_COUNT >= 0
                AND USAGE_DATE IS NOT NULL
                AND LENGTH(FEATURE_NAME) <= 100
            THEN 100
            WHEN USAGE_ID IS NOT NULL 
                AND MEETING_ID IS NOT NULL 
                AND FEATURE_NAME IS NOT NULL 
                AND USAGE_COUNT >= 0
            THEN 75
            WHEN USAGE_ID IS NOT NULL 
                AND MEETING_ID IS NOT NULL
            THEN 50
            ELSE 25
        END AS DATA_QUALITY_SCORE,
        
        -- Set validation status
        CASE 
            WHEN USAGE_ID IS NOT NULL 
                AND MEETING_ID IS NOT NULL 
                AND FEATURE_NAME IS NOT NULL 
                AND USAGE_COUNT IS NOT NULL 
                AND USAGE_COUNT >= 0
                AND USAGE_DATE IS NOT NULL
                AND LENGTH(FEATURE_NAME) <= 100
            THEN 'PASSED'
            WHEN USAGE_ID IS NOT NULL 
                AND MEETING_ID IS NOT NULL 
                AND FEATURE_NAME IS NOT NULL
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM cleansed_feature_usage
),

-- Remove duplicates keeping the latest record
deduped_feature_usage AS (
    SELECT *
    FROM (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY USAGE_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) as rn
        FROM data_quality_scored
    ) ranked
    WHERE rn = 1
)

SELECT 
    USAGE_ID,
    MEETING_ID,
    FEATURE_NAME,
    USAGE_COUNT,
    USAGE_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    LOAD_DATE,
    UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_feature_usage
WHERE VALIDATION_STATUS IN ('PASSED', 'WARNING')
