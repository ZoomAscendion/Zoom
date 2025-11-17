{{ config(
    materialized='table',
    pre_hook="
        {% if this.name != 'SI_Audit_Log' %}
        INSERT INTO {{ ref('SI_Audit_Log') }} (
          EXECUTION_ID,
          PIPELINE_NAME,
          PIPELINE_TYPE,
          EXECUTION_START_TIME,
          EXECUTION_STATUS,
          SOURCE_TABLE,
          TARGET_TABLE,
          EXECUTED_BY,
          LOAD_TIMESTAMP
        )
        VALUES (
          '{{ invocation_id }}',
          '{{ this.name }}',
          'SILVER_TRANSFORMATION',
          CURRENT_TIMESTAMP(),
          'STARTED',
          'BRONZE.BZ_FEATURE_USAGE',
          '{{ this }}',
          'DBT_PIPELINE',
          CURRENT_TIMESTAMP()
        )
        {% endif %}
    ",
    post_hook="
        {% if this.name != 'SI_Audit_Log' %}
        UPDATE {{ ref('SI_Audit_Log') }}
        SET 
          EXECUTION_END_TIME = CURRENT_TIMESTAMP(),
          EXECUTION_DURATION_SECONDS = DATEDIFF('second', EXECUTION_START_TIME, CURRENT_TIMESTAMP()),
          EXECUTION_STATUS = 'COMPLETED',
          RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}),
          RECORDS_SUCCESS = (SELECT COUNT(*) FROM {{ this }}),
          UPDATE_TIMESTAMP = CURRENT_TIMESTAMP()
        WHERE EXECUTION_ID = '{{ invocation_id }}'
        AND TARGET_TABLE = '{{ this }}'
        AND EXECUTION_STATUS = 'STARTED'
        {% endif %}
    "
) }}

-- Silver Layer Feature Usage Table
-- Purpose: Clean and standardized platform feature usage information
-- Source: Bronze.BZ_FEATURE_USAGE

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
    FROM {{ source('bronze', 'BZ_FEATURE_USAGE') }}
),

-- Data Quality and Cleansing
cleansed_data AS (
    SELECT 
        -- Primary identifiers
        COALESCE(TRIM(USAGE_ID), 'UNKNOWN_USAGE_' || ROW_NUMBER() OVER (ORDER BY LOAD_TIMESTAMP)) AS USAGE_ID,
        
        -- Meeting reference validation
        CASE 
            WHEN TRIM(MEETING_ID) IS NULL OR TRIM(MEETING_ID) = '' THEN 'UNKNOWN_MEETING'
            ELSE TRIM(MEETING_ID)
        END AS MEETING_ID,
        
        -- Feature name standardization
        CASE 
            WHEN TRIM(FEATURE_NAME) IS NULL OR TRIM(FEATURE_NAME) = '' THEN 'UNKNOWN_FEATURE'
            ELSE UPPER(TRIM(FEATURE_NAME))
        END AS FEATURE_NAME,
        
        -- Usage count validation
        CASE 
            WHEN USAGE_COUNT IS NULL OR USAGE_COUNT < 0 THEN 0
            ELSE USAGE_COUNT
        END AS USAGE_COUNT,
        
        -- Usage date validation
        CASE 
            WHEN USAGE_DATE IS NULL THEN CURRENT_DATE()
            WHEN USAGE_DATE > CURRENT_DATE() THEN CURRENT_DATE()
            ELSE USAGE_DATE
        END AS USAGE_DATE,
        
        -- Metadata columns
        COALESCE(LOAD_TIMESTAMP, CURRENT_TIMESTAMP()) AS LOAD_TIMESTAMP,
        COALESCE(UPDATE_TIMESTAMP, CURRENT_TIMESTAMP()) AS UPDATE_TIMESTAMP,
        COALESCE(TRIM(SOURCE_SYSTEM), 'UNKNOWN') AS SOURCE_SYSTEM,
        
        -- Silver layer specific columns
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        
        -- Data quality scoring
        CASE 
            WHEN USAGE_ID IS NOT NULL 
                 AND MEETING_ID IS NOT NULL 
                 AND FEATURE_NAME IS NOT NULL
                 AND USAGE_COUNT IS NOT NULL 
                 AND USAGE_COUNT >= 0
                 AND USAGE_DATE IS NOT NULL THEN 100
            WHEN USAGE_ID IS NOT NULL AND MEETING_ID IS NOT NULL AND FEATURE_NAME IS NOT NULL THEN 80
            WHEN USAGE_ID IS NOT NULL AND MEETING_ID IS NOT NULL THEN 60
            ELSE 40
        END AS DATA_QUALITY_SCORE,
        
        -- Validation status
        CASE 
            WHEN USAGE_ID IS NULL THEN 'FAILED'
            WHEN MEETING_ID IS NULL OR FEATURE_NAME IS NULL THEN 'FAILED'
            WHEN USAGE_COUNT IS NULL OR USAGE_COUNT < 0 THEN 'WARNING'
            WHEN USAGE_DATE IS NULL OR USAGE_DATE > CURRENT_DATE() THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS,
        
        -- Row number for deduplication
        ROW_NUMBER() OVER (PARTITION BY USAGE_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM source_data
    WHERE USAGE_ID IS NOT NULL
),

-- Final deduplication and validation
final_data AS (
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
    FROM cleansed_data
    WHERE rn = 1
      AND VALIDATION_STATUS IN ('PASSED', 'WARNING')  -- Only pass clean data to Silver
      AND USAGE_COUNT >= 0  -- Ensure non-negative usage counts
)

SELECT * FROM final_data
