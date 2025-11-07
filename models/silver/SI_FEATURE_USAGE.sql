{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTION_TRIGGER, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_FEATURE_USAGE', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'RUNNING', 'BZ_FEATURE_USAGE', 'SI_FEATURE_USAGE', 'DBT', 'SYSTEM', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_END_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, RECORDS_PROCESSED, RECORDS_SUCCESS, EXECUTION_TRIGGER, EXECUTED_BY, UPDATE_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_FEATURE_USAGE', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'SUCCESS', 'BZ_FEATURE_USAGE', 'SI_FEATURE_USAGE', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 'DBT', 'SYSTEM', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'"
) }}

-- Silver layer transformation for Feature Usage table
-- Applies data quality checks, usage count validation, and date consistency

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

-- Get meeting dates for validation
meeting_dates AS (
    SELECT 
        MEETING_ID AS mtg_meeting_id,
        DATE(START_TIME) AS mtg_date
    FROM {{ ref('SI_MEETINGS') }}
),

-- Validate feature usage data
validated_feature_usage AS (
    SELECT 
        bf.*,
        md.mtg_date,
        
        -- Calculate data quality score
        CASE 
            WHEN bf.USAGE_ID IS NOT NULL 
                AND bf.MEETING_ID IS NOT NULL 
                AND bf.FEATURE_NAME IS NOT NULL 
                AND bf.USAGE_COUNT IS NOT NULL 
                AND bf.USAGE_COUNT >= 0
                AND bf.USAGE_DATE IS NOT NULL 
                AND (md.mtg_date IS NULL OR bf.USAGE_DATE = md.mtg_date)
                AND LENGTH(TRIM(bf.FEATURE_NAME)) <= 100
            THEN 100
            WHEN bf.USAGE_ID IS NOT NULL 
                AND bf.MEETING_ID IS NOT NULL 
                AND bf.FEATURE_NAME IS NOT NULL 
                AND bf.USAGE_COUNT IS NOT NULL 
                AND bf.USAGE_COUNT >= 0
                AND bf.USAGE_DATE IS NOT NULL 
            THEN 75
            WHEN bf.USAGE_ID IS NOT NULL 
                AND bf.MEETING_ID IS NOT NULL 
                AND bf.FEATURE_NAME IS NOT NULL 
            THEN 50
            ELSE 25
        END AS data_quality_score,
        
        -- Set validation status
        CASE 
            WHEN bf.USAGE_ID IS NOT NULL 
                AND bf.MEETING_ID IS NOT NULL 
                AND bf.FEATURE_NAME IS NOT NULL 
                AND bf.USAGE_COUNT IS NOT NULL 
                AND bf.USAGE_COUNT >= 0
                AND bf.USAGE_DATE IS NOT NULL 
                AND (md.mtg_date IS NULL OR bf.USAGE_DATE = md.mtg_date)
                AND LENGTH(TRIM(bf.FEATURE_NAME)) <= 100
            THEN 'PASSED'
            WHEN bf.USAGE_ID IS NOT NULL 
                AND bf.MEETING_ID IS NOT NULL 
                AND bf.FEATURE_NAME IS NOT NULL 
                AND bf.USAGE_COUNT IS NOT NULL 
                AND bf.USAGE_COUNT >= 0
                AND bf.USAGE_DATE IS NOT NULL 
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS validation_status
    FROM bronze_feature_usage bf
    LEFT JOIN meeting_dates md ON bf.MEETING_ID = md.mtg_meeting_id
),

-- Remove duplicates keeping the latest record
deduped_feature_usage AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY USAGE_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM validated_feature_usage
    WHERE validation_status IN ('PASSED', 'WARNING')
)

SELECT 
    USAGE_ID,
    MEETING_ID,
    UPPER(TRIM(FEATURE_NAME)) AS FEATURE_NAME,
    CASE 
        WHEN USAGE_COUNT >= 0 THEN USAGE_COUNT
        ELSE 0
    END AS USAGE_COUNT,
    USAGE_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    -- Additional Silver layer metadata columns
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
    data_quality_score AS DATA_QUALITY_SCORE,
    validation_status AS VALIDATION_STATUS
FROM deduped_feature_usage
WHERE rn = 1
