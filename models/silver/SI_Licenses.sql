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
          'BRONZE.BZ_LICENSES',
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

-- Silver Layer Licenses Table
-- Purpose: Clean and standardized license assignments with DD/MM/YYYY date fixes
-- Source: Bronze.BZ_LICENSES
-- Critical P1 Fixes: DD/MM/YYYY date format conversion

WITH source_data AS (
    SELECT 
        LICENSE_ID,
        LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('bronze', 'BZ_LICENSES') }}
),

-- Critical P1 Fix: DD/MM/YYYY date format conversion
date_cleaned AS (
    SELECT 
        LICENSE_ID,
        LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        -- Handle DD/MM/YYYY format in START_DATE
        CASE 
            WHEN START_DATE::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}$' THEN 
                TRY_TO_DATE(START_DATE::STRING, 'DD/MM/YYYY')
            ELSE START_DATE
        END AS CLEAN_START_DATE,
        -- Handle DD/MM/YYYY format in END_DATE
        CASE 
            WHEN END_DATE::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}$' THEN 
                TRY_TO_DATE(END_DATE::STRING, 'DD/MM/YYYY')
            ELSE END_DATE
        END AS CLEAN_END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Flag records with DD/MM/YYYY format for audit
        CASE 
            WHEN START_DATE::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}$' 
                 OR END_DATE::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}$' 
            THEN TRUE
            ELSE FALSE
        END AS HAD_DDMMYYYY_FORMAT
    FROM source_data
),

-- Data Quality and Cleansing
cleansed_data AS (
    SELECT 
        -- Primary identifiers
        COALESCE(TRIM(LICENSE_ID), 'UNKNOWN_LICENSE_' || ROW_NUMBER() OVER (ORDER BY LOAD_TIMESTAMP)) AS LICENSE_ID,
        
        -- License type standardization
        CASE 
            WHEN UPPER(TRIM(LICENSE_TYPE)) IN ('FREE', 'BASIC', 'PRO', 'BUSINESS', 'ENTERPRISE') THEN UPPER(TRIM(LICENSE_TYPE))
            WHEN TRIM(LICENSE_TYPE) IS NULL OR TRIM(LICENSE_TYPE) = '' THEN 'UNKNOWN'
            ELSE UPPER(TRIM(LICENSE_TYPE))
        END AS LICENSE_TYPE,
        
        -- User assignment validation
        CASE 
            WHEN TRIM(ASSIGNED_TO_USER_ID) IS NULL OR TRIM(ASSIGNED_TO_USER_ID) = '' THEN 'UNASSIGNED'
            ELSE TRIM(ASSIGNED_TO_USER_ID)
        END AS ASSIGNED_TO_USER_ID,
        
        -- Cleaned dates with validation
        COALESCE(CLEAN_START_DATE, CURRENT_DATE()) AS START_DATE,
        COALESCE(CLEAN_END_DATE, DATEADD('year', 1, COALESCE(CLEAN_START_DATE, CURRENT_DATE()))) AS END_DATE,
        
        -- Metadata columns
        COALESCE(LOAD_TIMESTAMP, CURRENT_TIMESTAMP()) AS LOAD_TIMESTAMP,
        COALESCE(UPDATE_TIMESTAMP, CURRENT_TIMESTAMP()) AS UPDATE_TIMESTAMP,
        COALESCE(TRIM(SOURCE_SYSTEM), 'UNKNOWN') AS SOURCE_SYSTEM,
        
        -- Silver layer specific columns
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        
        -- Data quality scoring
        CASE 
            WHEN LICENSE_ID IS NOT NULL 
                 AND LICENSE_TYPE IS NOT NULL 
                 AND ASSIGNED_TO_USER_ID IS NOT NULL
                 AND CLEAN_START_DATE IS NOT NULL 
                 AND CLEAN_END_DATE IS NOT NULL
                 AND CLEAN_END_DATE > CLEAN_START_DATE THEN 100
            WHEN LICENSE_ID IS NOT NULL AND LICENSE_TYPE IS NOT NULL AND ASSIGNED_TO_USER_ID IS NOT NULL THEN 80
            WHEN LICENSE_ID IS NOT NULL AND LICENSE_TYPE IS NOT NULL THEN 60
            ELSE 40
        END AS DATA_QUALITY_SCORE,
        
        -- Validation status
        CASE 
            WHEN LICENSE_ID IS NULL THEN 'FAILED'
            WHEN LICENSE_TYPE IS NULL OR ASSIGNED_TO_USER_ID IS NULL THEN 'FAILED'
            WHEN CLEAN_END_DATE <= CLEAN_START_DATE THEN 'WARNING'
            WHEN HAD_DDMMYYYY_FORMAT THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS,
        
        -- Audit flags
        HAD_DDMMYYYY_FORMAT,
        
        -- Row number for deduplication
        ROW_NUMBER() OVER (PARTITION BY LICENSE_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM date_cleaned
    WHERE LICENSE_ID IS NOT NULL
),

-- Final deduplication and validation
final_data AS (
    SELECT 
        LICENSE_ID,
        LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        END_DATE,
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
      AND END_DATE > START_DATE  -- Ensure logical date sequence
)

SELECT * FROM final_data
