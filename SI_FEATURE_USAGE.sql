{{ config(
    materialized='table',
    tags=['silver', 'feature_usage'],
    pre_hook="INSERT INTO {{ ref('SI_AUDIT_LOG') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), '{{ this.name }}', 'PRE_HOOK_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_AUDIT_LOG'",
    post_hook="INSERT INTO {{ ref('SI_AUDIT_LOG') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), '{{ this.name }}', 'POST_HOOK_COMPLETE', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_AUDIT_LOG'"
) }}

WITH bronze_feature_usage AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY USAGE_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM {{ source('bronze', 'BZ_FEATURE_USAGE') }}
    WHERE USAGE_ID IS NOT NULL
),

cleaned_feature_usage AS (
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
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM bronze_feature_usage
    WHERE rn = 1
),

validated_feature_usage AS (
    SELECT *,
        CASE 
            WHEN USAGE_ID IS NOT NULL 
                 AND MEETING_ID IS NOT NULL 
                 AND FEATURE_NAME IS NOT NULL 
                 AND USAGE_COUNT IS NOT NULL
                 AND USAGE_COUNT >= 0
                 AND USAGE_DATE IS NOT NULL
            THEN 95
            WHEN USAGE_ID IS NOT NULL AND MEETING_ID IS NOT NULL
            THEN 75
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        CASE 
            WHEN USAGE_ID IS NOT NULL 
                 AND MEETING_ID IS NOT NULL 
                 AND FEATURE_NAME IS NOT NULL 
                 AND USAGE_COUNT >= 0
            THEN 'PASSED'
            WHEN USAGE_ID IS NOT NULL AND MEETING_ID IS NOT NULL
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM cleaned_feature_usage
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
FROM validated_feature_usage
