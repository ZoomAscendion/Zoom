{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_AUDIT_LOG') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTION_TRIGGER, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_FEATURE_USAGE', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'RUNNING', 'BZ_FEATURE_USAGE', 'SI_FEATURE_USAGE', 'DBT_SCHEDULED', 'DBT_CLOUD', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_AUDIT_LOG'",
    post_hook="INSERT INTO {{ ref('SI_AUDIT_LOG') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_END_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, RECORDS_PROCESSED, RECORDS_SUCCESS, EXECUTION_TRIGGER, EXECUTED_BY, UPDATE_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_FEATURE_USAGE', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'SUCCESS', 'BZ_FEATURE_USAGE', 'SI_FEATURE_USAGE', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 'DBT_SCHEDULED', 'DBT_CLOUD', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_AUDIT_LOG'"
) }}

-- SI_FEATURE_USAGE: Cleaned and standardized platform feature usage during meetings

WITH source_data AS (
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
    WHERE USAGE_ID IS NOT NULL  -- Exclude records with null USAGE_ID
),

data_quality_validation AS (
    SELECT 
        *,
        -- Data Quality Score Calculation
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
        
        -- Validation Status
        CASE 
            WHEN USAGE_ID IS NOT NULL 
                AND MEETING_ID IS NOT NULL 
                AND FEATURE_NAME IS NOT NULL 
                AND USAGE_COUNT IS NOT NULL 
                AND USAGE_COUNT >= 0
            THEN 'PASSED'
            WHEN USAGE_ID IS NOT NULL AND MEETING_ID IS NOT NULL 
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM source_data
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY USAGE_ID ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC) as rn
    FROM data_quality_validation
),

final_transformation AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        UPPER(TRIM(FEATURE_NAME)) AS FEATURE_NAME,
        COALESCE(USAGE_COUNT, 0) AS USAGE_COUNT,
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        DATA_QUALITY_SCORE,
        VALIDATION_STATUS
    FROM deduplication
    WHERE rn = 1  -- Keep only the latest record per USAGE_ID
        AND VALIDATION_STATUS != 'FAILED'  -- Exclude failed records from Silver layer
)

SELECT * FROM final_transformation
