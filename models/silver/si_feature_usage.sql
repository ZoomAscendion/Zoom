{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, EXECUTED_BY, EXECUTION_ENVIRONMENT, DATA_LINEAGE_INFO, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT CONCAT('SILVER_FEATURE_USAGE_', DATE_PART('epoch', CURRENT_TIMESTAMP())::STRING), 'SI_FEATURE_USAGE_ETL', CURRENT_TIMESTAMP(), 'In Progress', 'BZ_FEATURE_USAGE', 'SI_FEATURE_USAGE', 'DBT_SILVER_PIPELINE', 'PRODUCTION', 'Bronze to Silver Feature Usage transformation', CURRENT_DATE(), CURRENT_DATE(), 'SILVER_LAYER' WHERE '{{ this.name }}' != 'si_pipeline_audit'",
    post_hook="UPDATE {{ ref('si_pipeline_audit') }} SET END_TIME = CURRENT_TIMESTAMP(), STATUS = 'Success', EXECUTION_DURATION_SECONDS = DATEDIFF('second', START_TIME, CURRENT_TIMESTAMP()), RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), RECORDS_INSERTED = (SELECT COUNT(*) FROM {{ this }}) WHERE PIPELINE_NAME = 'SI_FEATURE_USAGE_ETL' AND STATUS = 'In Progress' AND '{{ this.name }}' != 'si_pipeline_audit'"
) }}

-- Silver Layer Feature Usage Table
-- Standardized feature usage data with categorization
-- Source: Bronze.BZ_FEATURE_USAGE
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

WITH bronze_feature_usage AS (
    SELECT *
    FROM {{ source('bronze', 'bz_feature_usage') }}
),

-- Data Quality Checks and Cleansing
cleansed_feature_usage AS (
    SELECT
        -- Primary identifiers
        USAGE_ID,
        MEETING_ID,
        
        -- Standardized feature name
        CASE 
            WHEN FEATURE_NAME IS NULL OR TRIM(FEATURE_NAME) = '' THEN 'Unknown Feature'
            ELSE TRIM(INITCAP(FEATURE_NAME))
        END AS FEATURE_NAME,
        
        -- Validated usage count
        CASE 
            WHEN USAGE_COUNT IS NULL OR USAGE_COUNT < 0 THEN 0
            ELSE USAGE_COUNT
        END AS USAGE_COUNT,
        
        -- Derived usage duration (simplified calculation)
        CASE 
            WHEN USAGE_COUNT IS NULL OR USAGE_COUNT <= 0 THEN 0
            WHEN USAGE_COUNT = 1 THEN 5  -- 5 minutes for single use
            ELSE USAGE_COUNT * 3  -- 3 minutes per usage
        END AS USAGE_DURATION,
        
        -- Feature categorization based on feature name
        CASE 
            WHEN UPPER(FEATURE_NAME) LIKE '%AUDIO%' OR UPPER(FEATURE_NAME) LIKE '%MICROPHONE%' OR UPPER(FEATURE_NAME) LIKE '%SOUND%' THEN 'Audio'
            WHEN UPPER(FEATURE_NAME) LIKE '%VIDEO%' OR UPPER(FEATURE_NAME) LIKE '%CAMERA%' OR UPPER(FEATURE_NAME) LIKE '%SCREEN%' THEN 'Video'
            WHEN UPPER(FEATURE_NAME) LIKE '%CHAT%' OR UPPER(FEATURE_NAME) LIKE '%SHARE%' OR UPPER(FEATURE_NAME) LIKE '%WHITEBOARD%' THEN 'Collaboration'
            WHEN UPPER(FEATURE_NAME) LIKE '%SECURITY%' OR UPPER(FEATURE_NAME) LIKE '%PASSWORD%' OR UPPER(FEATURE_NAME) LIKE '%LOCK%' THEN 'Security'
            ELSE 'General'
        END AS FEATURE_CATEGORY,
        
        -- Usage date validation
        COALESCE(USAGE_DATE, CURRENT_DATE()) AS USAGE_DATE,
        
        -- Metadata fields
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data quality score calculation
        CASE 
            WHEN USAGE_ID IS NOT NULL 
                AND MEETING_ID IS NOT NULL
                AND FEATURE_NAME IS NOT NULL AND TRIM(FEATURE_NAME) != ''
                AND USAGE_COUNT IS NOT NULL AND USAGE_COUNT >= 0
                AND USAGE_DATE IS NOT NULL
                THEN 1.00
            WHEN USAGE_ID IS NOT NULL AND MEETING_ID IS NOT NULL AND FEATURE_NAME IS NOT NULL
                THEN 0.75
            WHEN USAGE_ID IS NOT NULL AND MEETING_ID IS NOT NULL
                THEN 0.50
            ELSE 0.25
        END AS DATA_QUALITY_SCORE,
        
        -- Standard metadata
        COALESCE(LOAD_TIMESTAMP::DATE, CURRENT_DATE()) AS LOAD_DATE,
        COALESCE(UPDATE_TIMESTAMP::DATE, CURRENT_DATE()) AS UPDATE_DATE
        
    FROM bronze_feature_usage
    WHERE USAGE_ID IS NOT NULL  -- Block records without primary key
      AND MEETING_ID IS NOT NULL  -- Block usage without meeting reference
),

-- Deduplication - keep latest record per usage
deduped_feature_usage AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY USAGE_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM cleansed_feature_usage
)

-- Final selection with data quality validation
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
FROM deduped_feature_usage
WHERE rn = 1
  AND DATA_QUALITY_SCORE >= 0.50  -- Minimum quality threshold
