{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, EXECUTED_BY, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, LOAD_DATE) SELECT 'EXEC_' || REPLACE(CAST(CURRENT_TIMESTAMP() AS STRING), ' ', '_'), 'SI_FEATURE_USAGE_TRANSFORMATION', CURRENT_TIMESTAMP(), 'STARTED', 'DBT_PIPELINE', 'BZ_FEATURE_USAGE', 'SI_FEATURE_USAGE', CURRENT_DATE() WHERE EXISTS (SELECT 1 FROM {{ ref('audit_log') }} LIMIT 1)",
    post_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, END_TIME, STATUS, EXECUTED_BY, RECORDS_PROCESSED, LOAD_DATE) SELECT 'EXEC_' || REPLACE(CAST(CURRENT_TIMESTAMP() AS STRING), ' ', '_'), 'SI_FEATURE_USAGE_TRANSFORMATION', CURRENT_TIMESTAMP(), 'COMPLETED', 'DBT_PIPELINE', (SELECT COUNT(*) FROM {{ this }}), CURRENT_DATE() WHERE EXISTS (SELECT 1 FROM {{ ref('audit_log') }} LIMIT 1)"
) }}

-- Silver Layer Feature Usage Table Transformation
-- Source: Bronze.BZ_FEATURE_USAGE

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

-- Data Quality Validation and Cleansing
validated_feature_usage AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        
        -- Standardize feature name
        CASE 
            WHEN FEATURE_NAME IS NULL OR TRIM(FEATURE_NAME) = '' 
            THEN 'Unknown Feature'
            ELSE TRIM(FEATURE_NAME)
        END AS FEATURE_NAME,
        
        -- Validate usage count
        CASE 
            WHEN USAGE_COUNT < 0 THEN NULL
            ELSE COALESCE(USAGE_COUNT, 0)
        END AS USAGE_COUNT,
        
        -- Derive usage duration from usage count
        CASE 
            WHEN USAGE_COUNT IS NOT NULL AND USAGE_COUNT > 0 
            THEN USAGE_COUNT * 2  -- Assume 2 minutes per usage
            ELSE 0
        END AS USAGE_DURATION,
        
        -- Categorize features
        CASE 
            WHEN UPPER(FEATURE_NAME) LIKE '%AUDIO%' OR UPPER(FEATURE_NAME) LIKE '%MICROPHONE%' OR UPPER(FEATURE_NAME) LIKE '%SOUND%' THEN 'Audio'
            WHEN UPPER(FEATURE_NAME) LIKE '%VIDEO%' OR UPPER(FEATURE_NAME) LIKE '%CAMERA%' OR UPPER(FEATURE_NAME) LIKE '%SCREEN%' THEN 'Video'
            WHEN UPPER(FEATURE_NAME) LIKE '%CHAT%' OR UPPER(FEATURE_NAME) LIKE '%SHARE%' OR UPPER(FEATURE_NAME) LIKE '%WHITEBOARD%' THEN 'Collaboration'
            WHEN UPPER(FEATURE_NAME) LIKE '%SECURITY%' OR UPPER(FEATURE_NAME) LIKE '%PASSWORD%' OR UPPER(FEATURE_NAME) LIKE '%LOCK%' THEN 'Security'
            ELSE 'Other'
        END AS FEATURE_CATEGORY,
        
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Calculate data quality score
        CASE 
            WHEN USAGE_ID IS NOT NULL 
                AND MEETING_ID IS NOT NULL
                AND FEATURE_NAME IS NOT NULL AND TRIM(FEATURE_NAME) != ''
                AND USAGE_COUNT >= 0
                AND USAGE_DATE IS NOT NULL
            THEN 1.00
            WHEN USAGE_ID IS NOT NULL AND MEETING_ID IS NOT NULL
            THEN 0.75
            ELSE 0.50
        END AS DATA_QUALITY_SCORE,
        
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        
        -- Add row number for deduplication
        ROW_NUMBER() OVER (PARTITION BY USAGE_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_feature_usage
    WHERE USAGE_ID IS NOT NULL
        AND MEETING_ID IS NOT NULL
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
    LOAD_DATE,
    UPDATE_DATE
FROM validated_feature_usage
WHERE rn = 1
