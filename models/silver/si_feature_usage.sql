{{ config(
    materialized='table',
    pre_hook="
        INSERT INTO {{ ref('si_audit_log') }} (
            EXECUTION_ID, PIPELINE_NAME, EXECUTION_START_TIME, EXECUTION_STATUS, 
            SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP
        )
        VALUES (
            '{{ invocation_id }}', 
            'si_feature_usage', 
            CURRENT_TIMESTAMP(), 
            'RUNNING', 
            'BRONZE.BZ_FEATURE_USAGE', 
            'SILVER.SI_FEATURE_USAGE', 
            'DBT_SILVER_PIPELINE', 
            CURRENT_TIMESTAMP()
        )",
    post_hook="
        UPDATE {{ ref('si_audit_log') }} 
        SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(),
            EXECUTION_STATUS = 'SUCCESS',
            RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}),
            RECORDS_SUCCESS = (SELECT COUNT(*) FROM {{ this }})
        WHERE EXECUTION_ID = '{{ invocation_id }}' 
        AND TARGET_TABLE = 'SILVER.SI_FEATURE_USAGE'"
) }}

-- Silver layer feature usage table with data quality checks
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
),

cleansed_feature_usage AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        TRIM(UPPER(FEATURE_NAME)) AS FEATURE_NAME,  -- Standardize feature names
        CASE 
            WHEN USAGE_COUNT < 0 THEN 0
            ELSE USAGE_COUNT
        END AS USAGE_COUNT,  -- Ensure non-negative usage counts
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        ROW_NUMBER() OVER (PARTITION BY USAGE_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_feature_usage
    WHERE USAGE_COUNT >= 0  -- Remove negative usage counts
      AND FEATURE_NAME IS NOT NULL
      AND LENGTH(TRIM(FEATURE_NAME)) > 0
),

validated_feature_usage AS (
    SELECT 
        fu.USAGE_ID,
        fu.MEETING_ID,
        fu.FEATURE_NAME,
        fu.USAGE_COUNT,
        fu.USAGE_DATE,
        fu.LOAD_TIMESTAMP,
        fu.UPDATE_TIMESTAMP,
        fu.SOURCE_SYSTEM,
        -- Additional Silver layer metadata
        DATE(fu.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(fu.UPDATE_TIMESTAMP) AS UPDATE_DATE,
        -- Data quality scoring
        CASE 
            WHEN fu.USAGE_COUNT >= 0 AND fu.FEATURE_NAME IS NOT NULL 
                 AND m.MEETING_ID IS NOT NULL 
                 AND DATE(fu.USAGE_DATE) = DATE(m.START_TIME) THEN 100
            WHEN fu.USAGE_COUNT >= 0 AND fu.FEATURE_NAME IS NOT NULL 
                 AND m.MEETING_ID IS NOT NULL THEN 80
            WHEN fu.USAGE_COUNT >= 0 AND fu.FEATURE_NAME IS NOT NULL THEN 60
            ELSE 40
        END AS DATA_QUALITY_SCORE,
        CASE 
            WHEN fu.USAGE_COUNT >= 0 AND fu.FEATURE_NAME IS NOT NULL 
                 AND m.MEETING_ID IS NOT NULL THEN 'PASSED'
            WHEN m.MEETING_ID IS NULL THEN 'FAILED'
            WHEN fu.USAGE_COUNT < 0 THEN 'FAILED'
            ELSE 'WARNING'
        END AS VALIDATION_STATUS
    FROM cleansed_feature_usage fu
    LEFT JOIN {{ ref('si_meetings') }} m ON fu.MEETING_ID = m.MEETING_ID
    WHERE fu.rn = 1
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
FROM validated_feature_usage
