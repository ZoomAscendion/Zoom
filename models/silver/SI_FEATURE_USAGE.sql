{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTION_TRIGGER, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_FEATURE_USAGE', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'RUNNING', 'BZ_FEATURE_USAGE', 'SI_FEATURE_USAGE', 'SCHEDULED', 'DBT_CLOUD', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_END_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, RECORDS_PROCESSED, RECORDS_SUCCESS, EXECUTION_TRIGGER, EXECUTED_BY, UPDATE_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_FEATURE_USAGE', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'SUCCESS', 'BZ_FEATURE_USAGE', 'SI_FEATURE_USAGE', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 'SCHEDULED', 'DBT_CLOUD', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'"
) }}

-- Silver layer transformation for Feature Usage table
-- Applies data quality checks, referential integrity, and usage validation

WITH bronze_feature_usage AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        FEATURE_NAME,
        USAGE_COUNT,
        -- Handle different date formats
        CASE 
            WHEN USAGE_DATE IS NOT NULL THEN
                TRY_TO_DATE(USAGE_DATE, 'DD/MM/YYYY')
            ELSE NULL
        END AS USAGE_DATE,
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

-- Join with meeting data for date validation
feature_usage_with_meetings AS (
    SELECT 
        bfu.*,
        md.mtg_date
    FROM bronze_feature_usage bfu
    LEFT JOIN meeting_dates md ON bfu.MEETING_ID = md.mtg_meeting_id
),

-- Data quality validation and scoring
validated_feature_usage AS (
    SELECT 
        *,
        -- Data quality score calculation (0-100)
        CASE 
            WHEN USAGE_ID IS NULL OR MEETING_ID IS NULL THEN 0
            WHEN FEATURE_NAME IS NULL OR LENGTH(TRIM(FEATURE_NAME)) = 0 THEN 20
            WHEN USAGE_COUNT IS NULL OR USAGE_COUNT < 0 THEN 30
            WHEN USAGE_DATE IS NULL THEN 40
            WHEN mtg_date IS NULL THEN 50  -- Meeting doesn't exist
            WHEN USAGE_DATE != mtg_date THEN 70
            ELSE 100
        END AS DATA_QUALITY_SCORE,
        
        -- Validation status
        CASE 
            WHEN USAGE_ID IS NULL OR MEETING_ID IS NULL THEN 'FAILED'
            WHEN FEATURE_NAME IS NULL OR LENGTH(TRIM(FEATURE_NAME)) = 0 THEN 'FAILED'
            WHEN USAGE_COUNT IS NULL OR USAGE_COUNT < 0 THEN 'FAILED'
            WHEN USAGE_DATE IS NULL THEN 'FAILED'
            WHEN mtg_date IS NULL THEN 'FAILED'  -- Meeting doesn't exist
            WHEN USAGE_DATE != mtg_date THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM feature_usage_with_meetings
),

-- Remove duplicates keeping latest record
deduped_feature_usage AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY USAGE_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM validated_feature_usage
    WHERE VALIDATION_STATUS != 'FAILED'
)

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
FROM deduped_feature_usage
WHERE rn = 1
