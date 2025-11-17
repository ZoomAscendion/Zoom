{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_audit_log') }} (TABLE_NAME, STATUS, AUDIT_TIMESTAMP, LOAD_TIMESTAMP) SELECT 'SI_FEATURE_USAGE', 'PROCESSING_STARTED', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'si_audit_log'",
    post_hook="INSERT INTO {{ ref('si_audit_log') }} (TABLE_NAME, STATUS, AUDIT_TIMESTAMP, LOAD_TIMESTAMP) SELECT 'SI_FEATURE_USAGE', 'PROCESSING_COMPLETED', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'si_audit_log'"
) }}

-- SI_FEATURE_USAGE: Cleaned and standardized platform feature usage during meetings
-- Transformation from Bronze BZ_FEATURE_USAGE to Silver SI_FEATURE_USAGE

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

-- Data Cleansing and Standardization
cleansed_feature_usage AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        UPPER(TRIM(FEATURE_NAME)) AS FEATURE_NAME,
        COALESCE(USAGE_COUNT, 0) AS USAGE_COUNT,
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM bronze_feature_usage
    WHERE USAGE_COUNT >= 0
),

-- Data Quality Validation
validated_feature_usage AS (
    SELECT 
        f.USAGE_ID,
        f.MEETING_ID,
        f.FEATURE_NAME,
        f.USAGE_COUNT,
        f.USAGE_DATE,
        f.LOAD_TIMESTAMP,
        f.UPDATE_TIMESTAMP,
        f.SOURCE_SYSTEM,
        -- Data Quality Scoring
        CASE 
            WHEN f.FEATURE_NAME IS NOT NULL AND LENGTH(f.FEATURE_NAME) <= 100
                 AND f.USAGE_COUNT >= 0
                 AND m.MEETING_ID IS NOT NULL
            THEN 100
            WHEN f.FEATURE_NAME IS NOT NULL AND f.USAGE_COUNT >= 0
            THEN 80
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        CASE 
            WHEN f.FEATURE_NAME IS NOT NULL AND LENGTH(f.FEATURE_NAME) <= 100
                 AND f.USAGE_COUNT >= 0
                 AND m.MEETING_ID IS NOT NULL
            THEN 'PASSED'
            WHEN f.FEATURE_NAME IS NULL OR f.USAGE_COUNT < 0
            THEN 'FAILED'
            ELSE 'WARNING'
        END AS VALIDATION_STATUS
    FROM cleansed_feature_usage f
    LEFT JOIN {{ ref('si_meetings') }} m ON f.MEETING_ID = m.MEETING_ID
),

-- Remove Duplicates
deduped_feature_usage AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY USAGE_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
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
    -- Additional Silver layer metadata columns
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_feature_usage
WHERE rn = 1
  AND FEATURE_NAME IS NOT NULL
  AND USAGE_COUNT >= 0
