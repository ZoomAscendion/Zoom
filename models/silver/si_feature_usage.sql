{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

-- Bronze to Silver transformation for Feature Usage
-- Implements data quality checks and standardization

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
      AND TRIM(USAGE_ID) != ''
),

data_quality_checks AS (
    SELECT 
        bfu.*,
        -- Validation checks
        CASE 
            WHEN bfu.USAGE_COUNT IS NULL OR bfu.USAGE_COUNT < 0 THEN 'INVALID_USAGE_COUNT'
            WHEN bfu.USAGE_DATE IS NULL THEN 'MISSING_USAGE_DATE'
            WHEN bfu.USAGE_DATE > CURRENT_DATE() THEN 'FUTURE_USAGE_DATE'
            WHEN bfu.USAGE_DATE < '2020-01-01' THEN 'INVALID_USAGE_DATE'
            ELSE 'VALID'
        END AS validation_status
    FROM bronze_feature_usage bfu
),

valid_records AS (
    SELECT 
        dqc.USAGE_ID,
        dqc.MEETING_ID,
        UPPER(TRIM(dqc.FEATURE_NAME)) AS FEATURE_NAME,
        dqc.USAGE_COUNT,
        dqc.USAGE_DATE,
        DATE(dqc.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(dqc.UPDATE_TIMESTAMP) AS UPDATE_DATE,
        dqc.SOURCE_SYSTEM,
        dqc.LOAD_TIMESTAMP,
        dqc.UPDATE_TIMESTAMP,
        ROW_NUMBER() OVER (PARTITION BY dqc.USAGE_ID ORDER BY dqc.UPDATE_TIMESTAMP DESC) AS rn
    FROM data_quality_checks dqc
    INNER JOIN {{ ref('si_meetings') }} m ON dqc.MEETING_ID = m.MEETING_ID
    WHERE dqc.validation_status = 'VALID'
      AND dqc.FEATURE_NAME IS NOT NULL
      AND TRIM(dqc.FEATURE_NAME) != ''
      AND dqc.USAGE_COUNT >= 0
)

SELECT 
    USAGE_ID,
    MEETING_ID,
    FEATURE_NAME,
    USAGE_COUNT,
    USAGE_DATE,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP
FROM valid_records
WHERE rn = 1
