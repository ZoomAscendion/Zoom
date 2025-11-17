{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_audit_log') }} (MODEL_NAME, TABLE_NAME, PROCESS_STATUS, LOAD_TIMESTAMP) SELECT '{{ this.name }}', 'SI_FEATURE_USAGE', 'STARTED', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'si_audit_log'",
    post_hook="INSERT INTO {{ ref('si_audit_log') }} (MODEL_NAME, TABLE_NAME, PROCESS_STATUS, LOAD_TIMESTAMP) SELECT '{{ this.name }}', 'SI_FEATURE_USAGE', 'COMPLETED', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'si_audit_log'"
) }}

-- Silver Layer Feature Usage Table
-- Transforms and cleanses feature usage data from Bronze layer
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

cleansed_feature_usage AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        TRIM(UPPER(FEATURE_NAME)) AS FEATURE_NAME,
        COALESCE(USAGE_COUNT, 0) AS USAGE_COUNT,
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Additional Silver layer metadata
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE
    FROM bronze_feature_usage
),

validated_feature_usage AS (
    SELECT *,
        CASE 
            WHEN FEATURE_NAME IS NOT NULL AND USAGE_COUNT >= 0 AND USAGE_DATE IS NOT NULL
            THEN 100
            WHEN FEATURE_NAME IS NOT NULL AND USAGE_COUNT >= 0
            THEN 75
            WHEN FEATURE_NAME IS NOT NULL OR USAGE_COUNT >= 0
            THEN 50
            ELSE 25
        END AS DATA_QUALITY_SCORE,
        CASE 
            WHEN FEATURE_NAME IS NOT NULL AND USAGE_COUNT >= 0 AND USAGE_DATE IS NOT NULL
            THEN 'PASSED'
            WHEN FEATURE_NAME IS NULL OR USAGE_COUNT < 0
            THEN 'FAILED'
            ELSE 'WARNING'
        END AS VALIDATION_STATUS
    FROM cleansed_feature_usage
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
    USAGE_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    LOAD_DATE,
    UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_feature_usage
WHERE rn = 1
  AND VALIDATION_STATUS != 'FAILED'
