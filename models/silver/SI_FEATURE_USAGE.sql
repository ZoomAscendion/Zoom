{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (TABLE_NAME, STATUS, EXECUTION_START_TIME, EXECUTED_BY, LOAD_TIMESTAMP) SELECT 'SI_FEATURE_USAGE', 'STARTED', CURRENT_TIMESTAMP(), 'DBT_PIPELINE', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (TABLE_NAME, STATUS, EXECUTION_END_TIME, RECORDS_PROCESSED, RECORDS_SUCCESS, EXECUTED_BY, UPDATE_TIMESTAMP) SELECT 'SI_FEATURE_USAGE', 'COMPLETED', CURRENT_TIMESTAMP(), (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }} WHERE VALIDATION_STATUS = 'PASSED'), 'DBT_PIPELINE', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'"
) }}

-- Silver Layer Feature Usage Table
-- Purpose: Clean and standardized platform feature usage during meetings
-- Transformation: Bronze BZ_FEATURE_USAGE -> Silver SI_FEATURE_USAGE

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

data_quality_checks AS (
    SELECT 
        f.*,
        -- Feature name validation
        CASE 
            WHEN f.FEATURE_NAME IS NOT NULL AND LENGTH(TRIM(f.FEATURE_NAME)) > 0 AND LENGTH(f.FEATURE_NAME) <= 100 THEN 1
            ELSE 0
        END AS feature_name_valid,
        
        -- Usage count validation
        CASE 
            WHEN f.USAGE_COUNT >= 0 THEN 1
            ELSE 0
        END AS usage_count_valid,
        
        -- Meeting reference validation
        CASE 
            WHEN m.MEETING_ID IS NOT NULL THEN 1
            ELSE 0
        END AS meeting_ref_valid,
        
        -- Usage date consistency
        CASE 
            WHEN m.MEETING_ID IS NOT NULL AND DATE(f.USAGE_DATE) = DATE(m.START_TIME) THEN 1
            ELSE 0
        END AS date_consistent,
        
        -- Calculate data quality score
        CASE 
            WHEN f.USAGE_ID IS NOT NULL AND f.MEETING_ID IS NOT NULL AND f.FEATURE_NAME IS NOT NULL 
                 AND f.USAGE_COUNT IS NOT NULL AND f.USAGE_DATE IS NOT NULL THEN
                CASE 
                    WHEN f.USAGE_COUNT >= 0 AND LENGTH(TRIM(f.FEATURE_NAME)) > 0 AND m.MEETING_ID IS NOT NULL 
                         AND DATE(f.USAGE_DATE) = DATE(m.START_TIME) THEN 100
                    WHEN f.USAGE_COUNT >= 0 AND LENGTH(TRIM(f.FEATURE_NAME)) > 0 AND m.MEETING_ID IS NOT NULL THEN 80
                    WHEN f.USAGE_COUNT >= 0 AND LENGTH(TRIM(f.FEATURE_NAME)) > 0 THEN 60
                    ELSE 40
                END
            ELSE 0
        END AS data_quality_score
    FROM bronze_feature_usage f
    LEFT JOIN {{ ref('SI_MEETINGS') }} m ON f.MEETING_ID = m.MEETING_ID
),

deduplication AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY USAGE_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM data_quality_checks
),

cleaned_feature_usage AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        TRIM(UPPER(FEATURE_NAME)) AS FEATURE_NAME,
        CASE 
            WHEN USAGE_COUNT >= 0 THEN USAGE_COUNT
            ELSE 0
        END AS USAGE_COUNT,
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Additional Silver layer metadata
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        data_quality_score AS DATA_QUALITY_SCORE,
        CASE 
            WHEN data_quality_score >= 80 THEN 'PASSED'
            WHEN data_quality_score >= 50 THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM deduplication
    WHERE rn = 1
      AND USAGE_ID IS NOT NULL
      AND MEETING_ID IS NOT NULL
      AND FEATURE_NAME IS NOT NULL
      AND USAGE_COUNT >= 0
)

SELECT * FROM cleaned_feature_usage
