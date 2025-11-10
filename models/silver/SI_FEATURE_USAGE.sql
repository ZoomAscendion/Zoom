{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_FEATURE_USAGE', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'RUNNING', 'BZ_FEATURE_USAGE', 'SI_FEATURE_USAGE', 'DBT_PIPELINE', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="UPDATE {{ ref('SI_Audit_Log') }} SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(), EXECUTION_STATUS = 'SUCCESS', RECORDS_SUCCESS = (SELECT COUNT(*) FROM {{ this }}), UPDATE_TIMESTAMP = CURRENT_TIMESTAMP() WHERE PIPELINE_NAME = 'BRONZE_TO_SILVER_FEATURE_USAGE' AND EXECUTION_STATUS = 'RUNNING' AND '{{ this.name }}' != 'SI_Audit_Log'"
) }}

-- Silver layer transformation for Feature Usage table
-- Applies data quality checks, referential integrity, and usage validation

WITH bronze_feature_usage AS (
    SELECT 
        bfu.USAGE_ID,
        bfu.MEETING_ID,
        bfu.FEATURE_NAME,
        bfu.USAGE_COUNT,
        bfu.USAGE_DATE,
        bfu.LOAD_TIMESTAMP,
        bfu.UPDATE_TIMESTAMP,
        bfu.SOURCE_SYSTEM
    FROM {{ source('bronze', 'BZ_FEATURE_USAGE') }} bfu
),

-- Join with meetings for date validation
feature_usage_with_meetings AS (
    SELECT 
        bfu.USAGE_ID,
        bfu.MEETING_ID,
        bfu.FEATURE_NAME,
        bfu.USAGE_COUNT,
        bfu.USAGE_DATE,
        bfu.LOAD_TIMESTAMP,
        bfu.UPDATE_TIMESTAMP,
        bfu.SOURCE_SYSTEM,
        sm.START_TIME AS meeting_start_time
    FROM bronze_feature_usage bfu
    LEFT JOIN {{ ref('SI_MEETINGS') }} sm ON bfu.MEETING_ID = sm.MEETING_ID
),

-- Data quality validation and cleansing
cleansed_feature_usage AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        UPPER(TRIM(FEATURE_NAME)) AS FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        meeting_start_time,
        
        -- Data quality scoring
        CASE 
            WHEN USAGE_ID IS NULL THEN 0
            WHEN MEETING_ID IS NULL THEN 20
            WHEN FEATURE_NAME IS NULL OR LENGTH(TRIM(FEATURE_NAME)) = 0 THEN 30
            WHEN USAGE_COUNT IS NULL OR USAGE_COUNT < 0 THEN 40
            WHEN USAGE_DATE IS NULL THEN 50
            WHEN meeting_start_time IS NULL THEN 60
            WHEN DATE(USAGE_DATE) != DATE(meeting_start_time) THEN 70
            WHEN LENGTH(FEATURE_NAME) > 100 THEN 80
            ELSE 100
        END AS DATA_QUALITY_SCORE,
        
        -- Validation status
        CASE 
            WHEN USAGE_ID IS NULL OR MEETING_ID IS NULL OR FEATURE_NAME IS NULL THEN 'FAILED'
            WHEN USAGE_COUNT IS NULL OR USAGE_COUNT < 0 OR USAGE_DATE IS NULL THEN 'FAILED'
            WHEN meeting_start_time IS NULL THEN 'FAILED'
            WHEN DATE(USAGE_DATE) != DATE(meeting_start_time) THEN 'WARNING'
            WHEN LENGTH(FEATURE_NAME) > 100 THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM feature_usage_with_meetings
),

-- Remove duplicates using ROW_NUMBER
deduped_feature_usage AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY USAGE_ID ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC) AS rn
    FROM cleansed_feature_usage
    WHERE USAGE_ID IS NOT NULL
      AND MEETING_ID IS NOT NULL
      AND FEATURE_NAME IS NOT NULL
      AND LENGTH(TRIM(FEATURE_NAME)) > 0
      AND USAGE_COUNT IS NOT NULL
      AND USAGE_COUNT >= 0
      AND USAGE_DATE IS NOT NULL
      AND meeting_start_time IS NOT NULL
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
  AND VALIDATION_STATUS IN ('PASSED', 'WARNING')
