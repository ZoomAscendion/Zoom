{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (TABLE_NAME, STATUS, PROCESS_START_TIME, PROCESSED_BY, CREATED_AT) SELECT 'SI_FEATURE_USAGE', 'STARTED', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (TABLE_NAME, STATUS, PROCESS_END_TIME, PROCESSED_BY, RECORDS_PROCESSED, UPDATED_AT) SELECT 'SI_FEATURE_USAGE', 'COMPLETED', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE', (SELECT COUNT(*) FROM {{ this }}), CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'"
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
    WHERE USAGE_ID IS NOT NULL  -- Remove null usage IDs
),

data_quality_checks AS (
    SELECT 
        *,
        -- Row number for deduplication
        ROW_NUMBER() OVER (PARTITION BY USAGE_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_feature_usage
),

cleansed_feature_usage AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        TRIM(UPPER(FEATURE_NAME)) AS FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Additional Silver layer metadata
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        -- Data quality score calculation
        CASE 
            WHEN FEATURE_NAME IS NOT NULL 
                 AND USAGE_COUNT IS NOT NULL 
                 AND USAGE_COUNT >= 0 
                 AND USAGE_DATE IS NOT NULL THEN 100
            WHEN FEATURE_NAME IS NOT NULL 
                 AND USAGE_COUNT IS NOT NULL 
                 AND USAGE_DATE IS NOT NULL THEN 75
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        CASE 
            WHEN FEATURE_NAME IS NOT NULL 
                 AND USAGE_COUNT IS NOT NULL 
                 AND USAGE_COUNT >= 0 
                 AND USAGE_DATE IS NOT NULL THEN 'PASSED'
            WHEN FEATURE_NAME IS NOT NULL 
                 AND USAGE_COUNT IS NOT NULL 
                 AND USAGE_DATE IS NOT NULL THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS,
        CURRENT_TIMESTAMP() AS CREATED_AT,
        CURRENT_TIMESTAMP() AS UPDATED_AT
    FROM data_quality_checks
    WHERE rn = 1  -- Keep only the latest record for each usage
      AND FEATURE_NAME IS NOT NULL
      AND USAGE_COUNT IS NOT NULL
      AND USAGE_COUNT >= 0  -- Non-negative usage counts
      AND USAGE_DATE IS NOT NULL
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
    VALIDATION_STATUS,
    CREATED_AT,
    UPDATED_AT
FROM cleansed_feature_usage
