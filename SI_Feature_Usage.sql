{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_FEATURE_USAGE', 'PIPELINE_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_FEATURE_USAGE', 'PIPELINE_END', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_Audit_Log'"
) }}

-- Silver Layer Feature Usage Table
-- Transform and cleanse feature usage data from Bronze layer
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
),

cleansed_feature_usage AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        UPPER(TRIM(FEATURE_NAME)) AS FEATURE_NAME,
        
        /* Numeric field cleaning for USAGE_COUNT */
        CASE 
            WHEN TRY_TO_NUMBER(REGEXP_REPLACE(USAGE_COUNT::STRING, '[^0-9.]', '')) IS NOT NULL THEN
                TRY_TO_NUMBER(REGEXP_REPLACE(USAGE_COUNT::STRING, '[^0-9.]', ''))
            ELSE TRY_TO_NUMBER(USAGE_COUNT::STRING)
        END AS USAGE_COUNT,
        
        /* Date format handling */
        COALESCE(
            TRY_TO_DATE(USAGE_DATE::STRING, 'YYYY-MM-DD'),
            TRY_TO_DATE(USAGE_DATE::STRING, 'DD/MM/YYYY'),
            TRY_TO_DATE(USAGE_DATE::STRING, 'DD-MM-YYYY'),
            TRY_TO_DATE(USAGE_DATE::STRING, 'MM/DD/YYYY'),
            TRY_TO_DATE(USAGE_DATE::STRING)
        ) AS USAGE_DATE,
        
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM bronze_feature_usage
    WHERE USAGE_ID IS NOT NULL
),

validated_feature_usage AS (
    SELECT 
        *,
        /* Data Quality Score Calculation */
        CASE 
            WHEN USAGE_ID IS NOT NULL 
                AND MEETING_ID IS NOT NULL 
                AND FEATURE_NAME IS NOT NULL 
                AND USAGE_COUNT IS NOT NULL 
                AND USAGE_COUNT >= 0
                AND USAGE_DATE IS NOT NULL
            THEN 100
            WHEN USAGE_ID IS NOT NULL AND MEETING_ID IS NOT NULL AND FEATURE_NAME IS NOT NULL 
            THEN 75
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        
        /* Validation Status */
        CASE 
            WHEN USAGE_ID IS NOT NULL 
                AND MEETING_ID IS NOT NULL 
                AND FEATURE_NAME IS NOT NULL 
                AND USAGE_COUNT IS NOT NULL 
                AND USAGE_COUNT >= 0
                AND USAGE_DATE IS NOT NULL
            THEN 'PASSED'
            WHEN USAGE_ID IS NOT NULL AND MEETING_ID IS NOT NULL AND FEATURE_NAME IS NOT NULL 
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM cleansed_feature_usage
),

deduped_feature_usage AS (
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
        VALIDATION_STATUS,
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
    AND VALIDATION_STATUS IN ('PASSED', 'WARNING')
