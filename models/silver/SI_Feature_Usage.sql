{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_FEATURE_USAGE', 'PIPELINE_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_FEATURE_USAGE', 'PIPELINE_END', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE'"
) }}

-- Silver layer transformation for Feature Usage table
WITH bronze_feature_usage AS (
    SELECT *
    FROM {{ source('bronze', 'BZ_FEATURE_USAGE') }}
),

data_quality_checks AS (
    SELECT 
        *,
        -- Data quality score calculation
        (
            CASE WHEN USAGE_ID IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN MEETING_ID IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN FEATURE_NAME IS NOT NULL AND LENGTH(TRIM(FEATURE_NAME)) > 0 THEN 20 ELSE 0 END +
            CASE WHEN USAGE_COUNT IS NOT NULL AND USAGE_COUNT >= 0 THEN 20 ELSE 0 END +
            CASE WHEN USAGE_DATE IS NOT NULL THEN 20 ELSE 0 END
        ) AS data_quality_score,
        
        -- Validation status
        CASE 
            WHEN USAGE_ID IS NULL OR MEETING_ID IS NULL OR FEATURE_NAME IS NULL THEN 'FAILED'
            WHEN USAGE_COUNT IS NULL OR USAGE_COUNT < 0 THEN 'FAILED'
            WHEN USAGE_DATE IS NULL THEN 'FAILED'
            ELSE 'PASSED'
        END AS validation_status
    FROM bronze_feature_usage
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY USAGE_ID 
            ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC, LOAD_TIMESTAMP DESC
        ) AS row_num
    FROM data_quality_checks
    WHERE USAGE_ID IS NOT NULL
),

final_transformation AS (
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
        COALESCE(DATE(UPDATE_TIMESTAMP), DATE(LOAD_TIMESTAMP)) AS UPDATE_DATE,
        data_quality_score AS DATA_QUALITY_SCORE,
        validation_status AS VALIDATION_STATUS
    FROM deduplication
    WHERE row_num = 1
    AND validation_status != 'FAILED'
)

SELECT * FROM final_transformation
