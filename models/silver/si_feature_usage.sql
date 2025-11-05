{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

-- Silver Feature Usage transformation with data quality checks
WITH bronze_feature_usage AS (
    SELECT *
    FROM {{ ref('bz_feature_usage') }}
    WHERE USAGE_ID IS NOT NULL
      AND TRIM(USAGE_ID) != ''
      AND MEETING_ID IS NOT NULL
      AND FEATURE_NAME IS NOT NULL
      AND USAGE_COUNT >= 0
      AND USAGE_DATE >= '2020-01-01'
      AND USAGE_DATE <= DATEADD('day', 1, CURRENT_DATE)
),

valid_meetings AS (
    SELECT DISTINCT MEETING_ID
    FROM {{ ref('si_meetings') }}
),

filtered_feature_usage AS (
    SELECT bfu.*
    FROM bronze_feature_usage bfu
    INNER JOIN valid_meetings vm ON bfu.MEETING_ID = vm.MEETING_ID
    WHERE UPPER(TRIM(bfu.FEATURE_NAME)) IN ('SCREEN_SHARE', 'CHAT', 'RECORDING', 'BREAKOUT_ROOMS', 'WHITEBOARD')
),

deduped_feature_usage AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY USAGE_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM filtered_feature_usage
),

final_feature_usage AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        UPPER(TRIM(FEATURE_NAME)) AS FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        SOURCE_SYSTEM,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP
    FROM deduped_feature_usage
    WHERE rn = 1
)

SELECT * FROM final_feature_usage
