{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

/* Transform Bronze Feature Usage to Silver Feature Usage with standardization */

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
),

data_quality_checks AS (
    SELECT 
        *,
        /* Data Quality Score Calculation */
        (
            CASE WHEN USAGE_ID IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN MEETING_ID IS NOT NULL THEN 25 ELSE 0 END +
            CASE WHEN FEATURE_NAME IS NOT NULL AND LENGTH(TRIM(FEATURE_NAME)) > 0 THEN 25 ELSE 0 END +
            CASE WHEN USAGE_COUNT IS NOT NULL AND USAGE_COUNT >= 0 THEN 20 ELSE 0 END +
            CASE WHEN USAGE_DATE IS NOT NULL THEN 10 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        /* Validation Status */
        CASE 
            WHEN (
                CASE WHEN USAGE_ID IS NOT NULL THEN 20 ELSE 0 END +
                CASE WHEN MEETING_ID IS NOT NULL THEN 25 ELSE 0 END +
                CASE WHEN FEATURE_NAME IS NOT NULL AND LENGTH(TRIM(FEATURE_NAME)) > 0 THEN 25 ELSE 0 END +
                CASE WHEN USAGE_COUNT IS NOT NULL AND USAGE_COUNT >= 0 THEN 20 ELSE 0 END +
                CASE WHEN USAGE_DATE IS NOT NULL THEN 10 ELSE 0 END
            ) >= 90 THEN 'PASSED'
            WHEN (
                CASE WHEN USAGE_ID IS NOT NULL THEN 20 ELSE 0 END +
                CASE WHEN MEETING_ID IS NOT NULL THEN 25 ELSE 0 END +
                CASE WHEN FEATURE_NAME IS NOT NULL AND LENGTH(TRIM(FEATURE_NAME)) > 0 THEN 25 ELSE 0 END +
                CASE WHEN USAGE_COUNT IS NOT NULL AND USAGE_COUNT >= 0 THEN 20 ELSE 0 END +
                CASE WHEN USAGE_DATE IS NOT NULL THEN 10 ELSE 0 END
            ) >= 70 THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM bronze_feature_usage
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY USAGE_ID 
            ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC
        ) as rn
    FROM data_quality_checks
)

SELECT 
    USAGE_ID,
    MEETING_ID,
    UPPER(TRIM(FEATURE_NAME)) AS FEATURE_NAME,
    COALESCE(USAGE_COUNT, 0) AS USAGE_COUNT,
    USAGE_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduplication
WHERE rn = 1
  AND VALIDATION_STATUS IN ('PASSED', 'WARNING')
