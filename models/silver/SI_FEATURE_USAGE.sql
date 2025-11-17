{{ config(
    materialized='table',
    on_schema_change='sync_all_columns',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP) VALUES ('{{ invocation_id }}', 'SI_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'RUNNING', 'BRONZE.BZ_FEATURE_USAGE', 'SILVER.SI_FEATURE_USAGE', 'DBT_PIPELINE', CURRENT_TIMESTAMP())",
    post_hook="UPDATE {{ ref('SI_Audit_Log') }} SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(), EXECUTION_STATUS = 'SUCCESS', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), RECORDS_SUCCESS = (SELECT COUNT(*) FROM {{ this }}) WHERE EXECUTION_ID = '{{ invocation_id }}' AND TARGET_TABLE = 'SILVER.SI_FEATURE_USAGE'"
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
    FROM {{ source('bronze', 'BZ_FEATURE_USAGE') }}
),

cleansed_feature_usage AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        
        -- Feature name standardization
        CASE 
            WHEN FEATURE_NAME IS NULL OR TRIM(FEATURE_NAME) = '' THEN 'UNKNOWN_FEATURE'
            ELSE UPPER(TRIM(FEATURE_NAME))
        END AS FEATURE_NAME,
        
        -- Usage count validation
        CASE 
            WHEN USAGE_COUNT IS NULL OR USAGE_COUNT < 0 THEN 0
            ELSE USAGE_COUNT
        END AS USAGE_COUNT,
        
        -- Usage date validation
        CASE 
            WHEN USAGE_DATE IS NULL THEN DATE(LOAD_TIMESTAMP)
            WHEN USAGE_DATE > CURRENT_DATE() THEN CURRENT_DATE()
            ELSE USAGE_DATE
        END AS USAGE_DATE,
        
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Silver layer specific fields
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM bronze_feature_usage
    WHERE USAGE_ID IS NOT NULL
),

data_quality_scored AS (
    SELECT 
        *,
        -- Calculate data quality score (0-100)
        CASE 
            WHEN USAGE_ID IS NOT NULL 
                AND MEETING_ID IS NOT NULL
                AND FEATURE_NAME != 'UNKNOWN_FEATURE'
                AND USAGE_COUNT >= 0
                AND USAGE_DATE IS NOT NULL
            THEN 100
            WHEN USAGE_ID IS NOT NULL 
                AND MEETING_ID IS NOT NULL
                AND USAGE_COUNT >= 0
            THEN 80
            WHEN USAGE_ID IS NOT NULL 
                AND MEETING_ID IS NOT NULL
            THEN 60
            ELSE 40
        END AS DATA_QUALITY_SCORE,
        
        -- Validation status
        CASE 
            WHEN USAGE_ID IS NOT NULL 
                AND MEETING_ID IS NOT NULL
                AND FEATURE_NAME != 'UNKNOWN_FEATURE'
                AND USAGE_COUNT >= 0
            THEN 'PASSED'
            WHEN USAGE_ID IS NOT NULL 
                AND MEETING_ID IS NOT NULL
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM cleansed_feature_usage
),

-- Remove duplicates keeping the latest record
deduped_feature_usage AS (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY USAGE_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) as rn
        FROM data_quality_scored
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
    LOAD_DATE,
    UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_feature_usage
WHERE VALIDATION_STATUS != 'FAILED'
