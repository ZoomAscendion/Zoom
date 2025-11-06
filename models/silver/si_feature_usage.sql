{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (AUDIT_ID, PIPELINE_NAME, SOURCE_TABLE, TARGET_TABLE, EXECUTION_START_TIME, EXECUTION_STATUS, PROCESSED_BY, PROCESSING_MODE, LOAD_DATE, SOURCE_SYSTEM) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_FEATURE_USAGE', 'BZ_FEATURE_USAGE', 'SI_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'RUNNING', 'DBT_PIPELINE', 'INCREMENTAL', CURRENT_DATE(), 'SILVER_LAYER_PROCESSING' WHERE '{{ this.name }}' != 'si_pipeline_audit'",
    post_hook="UPDATE {{ ref('si_pipeline_audit') }} SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(), EXECUTION_STATUS = 'SUCCESS', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), EXECUTION_DURATION_SECONDS = DATEDIFF('second', EXECUTION_START_TIME, CURRENT_TIMESTAMP()) WHERE TARGET_TABLE = 'SI_FEATURE_USAGE' AND EXECUTION_STATUS = 'RUNNING' AND '{{ this.name }}' != 'si_pipeline_audit'"
) }}

-- Silver Layer Feature Usage Table Transformation
-- Applies data quality checks, standardization, and business rules

WITH bronze_feature_usage AS (
    SELECT *
    FROM {{ source('bronze', 'bz_feature_usage') }}
    WHERE LOAD_TIMESTAMP IS NOT NULL
),

validated_feature_usage AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Data quality validation
        CASE 
            WHEN USAGE_ID IS NULL OR TRIM(USAGE_ID) = '' THEN 'INVALID_USAGE_ID'
            WHEN MEETING_ID IS NULL OR TRIM(MEETING_ID) = '' THEN 'INVALID_MEETING_ID'
            WHEN FEATURE_NAME IS NULL OR TRIM(FEATURE_NAME) = '' THEN 'INVALID_FEATURE_NAME'
            WHEN USAGE_COUNT IS NULL OR USAGE_COUNT < 0 THEN 'INVALID_USAGE_COUNT'
            WHEN USAGE_DATE IS NULL THEN 'INVALID_USAGE_DATE'
            ELSE 'VALID'
        END AS data_quality_flag
    FROM bronze_feature_usage
),

cleansed_feature_usage AS (
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
    FROM validated_feature_usage
    WHERE data_quality_flag = 'VALID'
),

deduped_feature_usage AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY USAGE_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) AS row_num
    FROM cleansed_feature_usage
)

SELECT 
    USAGE_ID,
    MEETING_ID,
    FEATURE_NAME,
    USAGE_COUNT,
    USAGE_DATE,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP
FROM deduped_feature_usage
WHERE row_num = 1
