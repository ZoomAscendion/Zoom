{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTION_TRIGGER, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_FEATURE_USAGE', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'STARTED', 'BZ_FEATURE_USAGE', 'SI_FEATURE_USAGE', 'DBT_RUN', 'DBT_CLOUD', CURRENT_TIMESTAMP() WHERE '{{ this }}' != '{{ ref('SI_Audit_Log') }}'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_END_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, RECORDS_PROCESSED, EXECUTION_TRIGGER, EXECUTED_BY, UPDATE_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_FEATURE_USAGE', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'COMPLETED', 'BZ_FEATURE_USAGE', 'SI_FEATURE_USAGE', (SELECT COUNT(*) FROM {{ this }}), 'DBT_RUN', 'DBT_CLOUD', CURRENT_TIMESTAMP() WHERE '{{ this }}' != '{{ ref('SI_Audit_Log') }}'"
) }}

-- Silver Feature Usage table transformation from Bronze layer
-- Standardizes feature names and validates usage metrics

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

-- Data cleansing and standardization
cleansed_feature_usage AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        UPPER(TRIM(FEATURE_NAME)) AS FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data quality scoring
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
            WHEN USAGE_ID IS NOT NULL 
            THEN 50
            ELSE 25
        END AS DATA_QUALITY_SCORE,
        
        -- Validation status
        CASE 
            WHEN USAGE_ID IS NULL OR MEETING_ID IS NULL THEN 'FAILED'
            WHEN FEATURE_NAME IS NULL OR LENGTH(TRIM(FEATURE_NAME)) = 0 THEN 'FAILED'
            WHEN USAGE_COUNT IS NULL OR USAGE_COUNT < 0 THEN 'FAILED'
            WHEN USAGE_DATE IS NULL THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM bronze_feature_usage
    WHERE USAGE_ID IS NOT NULL
),

-- Remove duplicates keeping the latest record
deduped_feature_usage AS (
    SELECT *
    FROM (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY USAGE_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
        FROM cleansed_feature_usage
    )
    WHERE rn = 1
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
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_feature_usage
WHERE VALIDATION_STATUS != 'FAILED'  -- Exclude failed records
