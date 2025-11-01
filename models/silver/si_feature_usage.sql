{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, EXECUTED_BY, EXECUTION_ENVIRONMENT, DATA_LINEAGE_INFO, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key(["'SI_FEATURE_USAGE'", 'CURRENT_TIMESTAMP()']) }}', 'SI_FEATURE_USAGE_TRANSFORM', CURRENT_TIMESTAMP(), 'STARTED', 'BRONZE.BZ_FEATURE_USAGE', 'SILVER.SI_FEATURE_USAGE', 'DBT_PIPELINE', 'PROD', 'Feature usage data transformation with validation', CURRENT_DATE(), CURRENT_DATE(), 'SILVER_LAYER_PIPELINE' WHERE '{{ this.name }}' != 'audit_log'",
    post_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, END_TIME, STATUS, RECORDS_PROCESSED, RECORDS_INSERTED, EXECUTED_BY, EXECUTION_ENVIRONMENT, DATA_LINEAGE_INFO, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key(["'SI_FEATURE_USAGE'", 'CURRENT_TIMESTAMP()']) }}', 'SI_FEATURE_USAGE_TRANSFORM', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 'COMPLETED', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 'DBT_PIPELINE', 'PROD', 'Feature usage data transformation completed', CURRENT_DATE(), CURRENT_DATE(), 'SILVER_LAYER_PIPELINE' WHERE '{{ this.name }}' != 'audit_log'"
) }}

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
    FROM {{ source('bronze', 'bz_feature_usage') }}
    WHERE USAGE_ID IS NOT NULL
      AND MEETING_ID IS NOT NULL
      AND FEATURE_NAME IS NOT NULL
      AND USAGE_COUNT >= 0
),

-- Data cleansing and enrichment
cleansed_feature_usage AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        TRIM(UPPER(FEATURE_NAME)) AS FEATURE_NAME,
        USAGE_COUNT,
        CASE USAGE_COUNT
            WHEN 0 THEN 0
            ELSE GREATEST(1, USAGE_COUNT * 2)  -- Estimate duration based on usage count
        END AS USAGE_DURATION,
        CASE 
            WHEN UPPER(FEATURE_NAME) LIKE '%AUDIO%' OR UPPER(FEATURE_NAME) LIKE '%MICROPHONE%' OR UPPER(FEATURE_NAME) LIKE '%SPEAKER%' THEN 'Audio'
            WHEN UPPER(FEATURE_NAME) LIKE '%VIDEO%' OR UPPER(FEATURE_NAME) LIKE '%CAMERA%' OR UPPER(FEATURE_NAME) LIKE '%SCREEN%' THEN 'Video'
            WHEN UPPER(FEATURE_NAME) LIKE '%CHAT%' OR UPPER(FEATURE_NAME) LIKE '%SHARE%' OR UPPER(FEATURE_NAME) LIKE '%WHITEBOARD%' THEN 'Collaboration'
            WHEN UPPER(FEATURE_NAME) LIKE '%SECURITY%' OR UPPER(FEATURE_NAME) LIKE '%PASSWORD%' OR UPPER(FEATURE_NAME) LIKE '%LOCK%' THEN 'Security'
            ELSE 'Collaboration'
        END AS FEATURE_CATEGORY,
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM bronze_feature_usage
),

-- Data quality scoring
quality_scored_feature_usage AS (
    SELECT 
        *,
        CASE 
            WHEN USAGE_ID IS NOT NULL 
                 AND MEETING_ID IS NOT NULL 
                 AND FEATURE_NAME IS NOT NULL 
                 AND USAGE_COUNT >= 0
                 AND USAGE_DATE IS NOT NULL
                 AND FEATURE_CATEGORY IN ('Audio', 'Video', 'Collaboration', 'Security')
            THEN 1.00
            WHEN USAGE_ID IS NOT NULL AND MEETING_ID IS NOT NULL AND FEATURE_NAME IS NOT NULL
            THEN 0.75
            WHEN USAGE_ID IS NOT NULL AND MEETING_ID IS NOT NULL
            THEN 0.50
            ELSE 0.25
        END AS DATA_QUALITY_SCORE
    FROM cleansed_feature_usage
),

-- Remove duplicates
deduped_feature_usage AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY USAGE_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM quality_scored_feature_usage
)

SELECT 
    USAGE_ID,
    MEETING_ID,
    FEATURE_NAME,
    USAGE_COUNT,
    USAGE_DURATION,
    FEATURE_CATEGORY,
    USAGE_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATA_QUALITY_SCORE,
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
FROM deduped_feature_usage
WHERE rn = 1
  AND DATA_QUALITY_SCORE >= 0.50
