{{ config(
    materialized='table',
    tags=['silver', 'feature_usage']
) }}

WITH source_feature_usage AS (
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
      AND MEETING_ID IS NOT NULL
      AND FEATURE_NAME IS NOT NULL
      AND USAGE_COUNT >= 0
),

validated_meetings AS (
    SELECT MEETING_ID, DURATION_MINUTES
    FROM {{ ref('si_meetings') }}
),

validated_feature_usage AS (
    SELECT
        sfu.USAGE_ID,
        sfu.MEETING_ID,
        TRIM(sfu.FEATURE_NAME) AS FEATURE_NAME,
        sfu.USAGE_COUNT,
        0 AS USAGE_DURATION,
        CASE
            WHEN UPPER(sfu.FEATURE_NAME) LIKE '%AUDIO%' OR UPPER(sfu.FEATURE_NAME) LIKE '%MICROPHONE%' THEN 'Audio'
            WHEN UPPER(sfu.FEATURE_NAME) LIKE '%VIDEO%' OR UPPER(sfu.FEATURE_NAME) LIKE '%CAMERA%' THEN 'Video'
            WHEN UPPER(sfu.FEATURE_NAME) LIKE '%SCREEN%' OR UPPER(sfu.FEATURE_NAME) LIKE '%SHARE%' OR UPPER(sfu.FEATURE_NAME) LIKE '%CHAT%' THEN 'Collaboration'
            WHEN UPPER(sfu.FEATURE_NAME) LIKE '%SECURITY%' OR UPPER(sfu.FEATURE_NAME) LIKE '%ENCRYPTION%' THEN 'Security'
            ELSE 'Collaboration'
        END AS FEATURE_CATEGORY,
        sfu.USAGE_DATE,
        sfu.LOAD_TIMESTAMP,
        sfu.UPDATE_TIMESTAMP,
        sfu.SOURCE_SYSTEM
    FROM source_feature_usage sfu
    INNER JOIN validated_meetings vm ON sfu.MEETING_ID = vm.MEETING_ID
),

quality_scored_feature_usage AS (
    SELECT
        *,
        (
            CASE WHEN FEATURE_NAME IS NOT NULL AND TRIM(FEATURE_NAME) != '' THEN 0.25 ELSE 0 END +
            CASE WHEN USAGE_COUNT >= 0 THEN 0.25 ELSE 0 END +
            CASE WHEN FEATURE_CATEGORY IN ('Audio', 'Video', 'Collaboration', 'Security') THEN 0.25 ELSE 0 END +
            CASE WHEN USAGE_DATE IS NOT NULL AND USAGE_DATE <= CURRENT_DATE() THEN 0.25 ELSE 0 END
        ) AS DATA_QUALITY_SCORE
    FROM validated_feature_usage
),

deduped_feature_usage AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY USAGE_ID ORDER BY UPDATE_TIMESTAMP DESC) AS row_num
    FROM quality_scored_feature_usage
)

SELECT
    USAGE_ID,
    MEETING_ID,
    FEATURE_NAME,
    USAGE_COUNT,
    USAGE_DURATION,
    FEATURE_CATEGORY,
    USAGE_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATA_QUALITY_SCORE,
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
FROM deduped_feature_usage
WHERE row_num = 1
  AND DATA_QUALITY_SCORE >= 0.60
