{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

/* Silver Feature Usage Table - Cleaned and standardized platform feature usage */

WITH bronze_feature_usage AS (
    SELECT *
    FROM {{ source('bronze', 'bz_feature_usage') }}
),

data_quality_checks AS (
    SELECT 
        bfu.*,
        /* Data Quality Score Calculation */
        (
            CASE WHEN bfu.USAGE_ID IS NOT NULL THEN 25 ELSE 0 END +
            CASE WHEN bfu.MEETING_ID IS NOT NULL THEN 25 ELSE 0 END +
            CASE WHEN bfu.FEATURE_NAME IS NOT NULL AND LENGTH(TRIM(bfu.FEATURE_NAME)) > 0 THEN 20 ELSE 0 END +
            CASE WHEN bfu.USAGE_COUNT IS NOT NULL AND bfu.USAGE_COUNT >= 0 THEN 15 ELSE 0 END +
            CASE WHEN bfu.USAGE_DATE IS NOT NULL THEN 15 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        /* Validation Status */
        CASE 
            WHEN bfu.USAGE_ID IS NULL OR bfu.MEETING_ID IS NULL THEN 'FAILED'
            WHEN bfu.FEATURE_NAME IS NULL OR LENGTH(TRIM(bfu.FEATURE_NAME)) = 0 THEN 'FAILED'
            WHEN bfu.USAGE_COUNT IS NULL OR bfu.USAGE_COUNT < 0 THEN 'FAILED'
            WHEN bfu.USAGE_DATE IS NULL THEN 'FAILED'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM bronze_feature_usage bfu
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY USAGE_ID 
            ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC
        ) AS row_num
    FROM data_quality_checks
    WHERE USAGE_ID IS NOT NULL
),

final_feature_usage AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        UPPER(TRIM(FEATURE_NAME)) AS FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        DATA_QUALITY_SCORE,
        VALIDATION_STATUS
    FROM deduplication
    WHERE row_num = 1
      AND VALIDATION_STATUS != 'FAILED'
)

SELECT * FROM final_feature_usage
