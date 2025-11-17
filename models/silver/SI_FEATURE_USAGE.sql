{{ config(
    materialized='table',
    on_schema_change='sync_all_columns',
    pre_hook="
        INSERT INTO {{ ref('SI_AUDIT_LOG') }} (EXECUTION_ID, PIPELINE_NAME, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP)
        VALUES (UUID_STRING(), 'SI_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'STARTED', 'BRONZE.BZ_FEATURE_USAGE', '{{ this.schema }}.SI_FEATURE_USAGE', 'DBT_PIPELINE', CURRENT_TIMESTAMP())
    ",
    post_hook="
        UPDATE {{ ref('SI_AUDIT_LOG') }} 
        SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(), 
            EXECUTION_STATUS = 'SUCCESS',
            RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}),
            UPDATE_TIMESTAMP = CURRENT_TIMESTAMP()
        WHERE TARGET_TABLE = '{{ this.schema }}.SI_FEATURE_USAGE' 
        AND EXECUTION_STATUS = 'STARTED'
        AND EXECUTION_START_TIME >= CURRENT_TIMESTAMP() - INTERVAL '1 HOUR'
    "
) }}

-- Silver Layer Feature Usage Table
-- Purpose: Clean and standardized platform feature usage during meetings
-- Transformation: Bronze to Silver with data quality validations

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
    WHERE USAGE_ID IS NOT NULL
),

data_quality_checks AS (
    SELECT 
        *,
        -- Data Quality Score Calculation
        CASE 
            WHEN USAGE_ID IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN MEETING_ID IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN FEATURE_NAME IS NOT NULL AND LENGTH(TRIM(FEATURE_NAME)) > 0 THEN 20 ELSE 0 END +
            CASE WHEN USAGE_COUNT IS NOT NULL AND USAGE_COUNT >= 0 THEN 20 ELSE 0 END +
            CASE WHEN USAGE_DATE IS NOT NULL THEN 20 ELSE 0 END
        AS DATA_QUALITY_SCORE,
        
        -- Validation Status
        CASE 
            WHEN USAGE_ID IS NULL OR MEETING_ID IS NULL OR FEATURE_NAME IS NULL THEN 'FAILED'
            WHEN USAGE_COUNT IS NULL OR USAGE_COUNT < 0 THEN 'FAILED'
            WHEN USAGE_DATE IS NULL OR USAGE_DATE > CURRENT_DATE() THEN 'FAILED'
            WHEN LENGTH(TRIM(FEATURE_NAME)) = 0 THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM bronze_feature_usage
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY USAGE_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) as rn
    FROM data_quality_checks
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
        -- Additional Silver layer metadata columns
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        DATA_QUALITY_SCORE,
        VALIDATION_STATUS
    FROM deduplication
    WHERE rn = 1
    AND VALIDATION_STATUS IN ('PASSED', 'WARNING') -- Exclude FAILED records
)

SELECT * FROM final_transformation
