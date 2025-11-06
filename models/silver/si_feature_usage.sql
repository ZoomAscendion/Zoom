{{ config(
    materialized='table'
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
