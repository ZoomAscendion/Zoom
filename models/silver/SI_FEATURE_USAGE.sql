{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (TABLE_NAME, PROCESS_STATUS, PROCESS_START_TIME, EXECUTED_BY, AUDIT_TIMESTAMP) SELECT 'SI_FEATURE_USAGE', 'STARTED', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (TABLE_NAME, PROCESS_STATUS, PROCESS_END_TIME, RECORDS_PROCESSED, RECORDS_SUCCESS, EXECUTED_BY, AUDIT_TIMESTAMP) SELECT 'SI_FEATURE_USAGE', 'COMPLETED', CURRENT_TIMESTAMP(), (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }} WHERE VALIDATION_STATUS = 'PASSED'), 'DBT_SILVER_PIPELINE', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'"
) }}

-- Silver layer transformation for Feature Usage table
-- Applies data quality checks and standardization

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
    WHERE USAGE_ID IS NOT NULL
),

-- Data quality validation and cleansing
cleansed_feature_usage AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        TRIM(UPPER(FEATURE_NAME)) AS FEATURE_NAME,
        CASE 
            WHEN USAGE_COUNT < 0 THEN 0
            ELSE USAGE_COUNT
        END AS USAGE_COUNT,
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Data quality scoring
        CASE 
            WHEN USAGE_ID IS NOT NULL 
                AND MEETING_ID IS NOT NULL 
                AND FEATURE_NAME IS NOT NULL 
                AND USAGE_COUNT >= 0
                AND USAGE_DATE IS NOT NULL
            THEN 100
            WHEN USAGE_ID IS NOT NULL AND MEETING_ID IS NOT NULL
            THEN 75
            WHEN USAGE_ID IS NOT NULL
            THEN 50
            ELSE 25
        END AS DATA_QUALITY_SCORE,
        -- Validation status
        CASE 
            WHEN USAGE_ID IS NOT NULL 
                AND MEETING_ID IS NOT NULL 
                AND FEATURE_NAME IS NOT NULL
            THEN 'PASSED'
            WHEN USAGE_ID IS NULL OR MEETING_ID IS NULL
            THEN 'FAILED'
            ELSE 'WARNING'
        END AS VALIDATION_STATUS,
        ROW_NUMBER() OVER (PARTITION BY USAGE_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_feature_usage
),

-- Remove duplicates and failed records
deduped_feature_usage AS (
    SELECT *
    FROM cleansed_feature_usage
    WHERE rn = 1
      AND VALIDATION_STATUS != 'FAILED'
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
    CURRENT_DATE() AS LOAD_DATE,
    CURRENT_DATE() AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_feature_usage
