{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP) VALUES (UUID_STRING(), 'BRONZE_TO_SILVER_FEATURE_USAGE', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'RUNNING', 'BZ_FEATURE_USAGE', 'SI_FEATURE_USAGE', 'DBT_PIPELINE', CURRENT_TIMESTAMP())",
    post_hook="UPDATE {{ ref('SI_Audit_Log') }} SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(), EXECUTION_STATUS = 'SUCCESS', EXECUTION_DURATION_SECONDS = DATEDIFF('second', EXECUTION_START_TIME, CURRENT_TIMESTAMP()), UPDATE_TIMESTAMP = CURRENT_TIMESTAMP() WHERE PIPELINE_NAME = 'BRONZE_TO_SILVER_FEATURE_USAGE' AND EXECUTION_STATUS = 'RUNNING'"
) }}

-- Silver layer transformation for Feature Usage table
-- Applies data quality checks, referential integrity, and usage validation

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
    FROM {{ source('bronze', 'BZ_FEATURE_USAGE') }}
),

-- Get meeting dates for validation
meeting_dates AS (
    SELECT 
        MEETING_ID,
        DATE(START_TIME) AS meeting_date
    FROM {{ ref('SI_MEETINGS') }}
),

-- Data quality validation and cleansing
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
        md.meeting_date,
        -- Data quality scoring
        CASE 
            WHEN bfu.USAGE_ID IS NULL THEN 0
            WHEN bfu.MEETING_ID IS NULL THEN 20
            WHEN bfu.FEATURE_NAME IS NULL OR LENGTH(TRIM(bfu.FEATURE_NAME)) = 0 THEN 30
            WHEN bfu.USAGE_COUNT IS NULL OR bfu.USAGE_COUNT < 0 THEN 40
            WHEN bfu.USAGE_DATE IS NULL THEN 50
            WHEN md.MEETING_ID IS NULL THEN 60
            WHEN bfu.USAGE_DATE != md.meeting_date THEN 70
            ELSE 100
        END AS DATA_QUALITY_SCORE,
        -- Validation status
        CASE 
            WHEN bfu.USAGE_ID IS NULL OR bfu.MEETING_ID IS NULL THEN 'FAILED'
            WHEN bfu.FEATURE_NAME IS NULL OR LENGTH(TRIM(bfu.FEATURE_NAME)) = 0 THEN 'FAILED'
            WHEN bfu.USAGE_COUNT IS NULL OR bfu.USAGE_COUNT < 0 THEN 'FAILED'
            WHEN bfu.USAGE_DATE IS NULL THEN 'FAILED'
            WHEN md.MEETING_ID IS NULL THEN 'FAILED'
            WHEN bfu.USAGE_DATE != md.meeting_date THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM bronze_feature_usage bfu
    LEFT JOIN meeting_dates md ON bfu.MEETING_ID = md.MEETING_ID
),

-- Remove duplicates keeping the latest record
deduped_feature_usage AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY USAGE_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM cleansed_feature_usage
    WHERE USAGE_ID IS NOT NULL
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
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_feature_usage
WHERE rn = 1
    AND VALIDATION_STATUS != 'FAILED'
