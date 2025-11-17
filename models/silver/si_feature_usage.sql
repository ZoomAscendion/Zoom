{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_audit_log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_FEATURE_USAGE', 'PROCESS_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'si_audit_log'",
    post_hook="INSERT INTO {{ ref('si_audit_log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_FEATURE_USAGE', 'PROCESS_END', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'si_audit_log'"
) }}

-- Silver Layer Feature Usage Table
-- Purpose: Clean and standardized platform feature usage data
-- Source: Bronze BZ_FEATURE_USAGE table

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
    FROM {{ source('bronze', 'bz_feature_usage') }}
    WHERE USAGE_ID IS NOT NULL
),

cleaned_data AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        UPPER(TRIM(FEATURE_NAME)) AS FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM source_data
),

validated_data AS (
    SELECT 
        *,
        -- Data Quality Score
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
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        
        -- Validation Status
        CASE 
            WHEN USAGE_ID IS NOT NULL 
                AND MEETING_ID IS NOT NULL 
                AND FEATURE_NAME IS NOT NULL 
                AND USAGE_COUNT IS NOT NULL 
                AND USAGE_COUNT >= 0
                AND USAGE_DATE IS NOT NULL
            THEN 'PASSED'
            WHEN USAGE_ID IS NOT NULL AND MEETING_ID IS NOT NULL AND FEATURE_NAME IS NOT NULL
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM cleaned_data
),

deduped_data AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY USAGE_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM validated_data
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
FROM deduped_data
WHERE rn = 1
    AND VALIDATION_STATUS IN ('PASSED', 'WARNING')
