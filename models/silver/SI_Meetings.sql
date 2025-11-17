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
          'BRONZE.BZ_MEETINGS',
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

-- Silver Layer Meetings Table
-- Purpose: Clean and standardized meeting information with critical DQ fixes
-- Source: Bronze.BZ_MEETINGS
-- Critical P1 Fixes: Duration text cleaning and EST timezone handling

WITH source_data AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        MEETING_TOPIC,
        START_TIME,
        END_TIME,
        DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('bronze', 'BZ_MEETINGS') }}
),

-- Critical P1 Fix: Clean duration text units ("108 mins" error)
cleansed_duration AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        MEETING_TOPIC,
        START_TIME,
        END_TIME,
        -- Clean text units from DURATION_MINUTES field
        CASE 
            WHEN DURATION_MINUTES IS NULL THEN NULL
            WHEN TRY_TO_NUMBER(REGEXP_REPLACE(DURATION_MINUTES::STRING, '[^0-9.]', '')) IS NOT NULL 
            THEN TRY_TO_NUMBER(REGEXP_REPLACE(DURATION_MINUTES::STRING, '[^0-9.]', ''))
            ELSE NULL
        END AS CLEAN_DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Flag records with text units for audit
        CASE 
            WHEN DURATION_MINUTES::STRING REGEXP '[a-zA-Z]' THEN TRUE
            ELSE FALSE
        END AS HAD_TEXT_UNITS
    FROM source_data
),

-- Critical P1 Fix: EST timezone format handling
timestamp_cleaned AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        MEETING_TOPIC,
        -- Handle EST timezone format in START_TIME
        CASE 
            WHEN START_TIME::STRING LIKE '%EST%' THEN 
                TRY_TO_TIMESTAMP(REPLACE(START_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS')
            ELSE START_TIME
        END AS CLEAN_START_TIME,
        -- Handle EST timezone format in END_TIME
        CASE 
            WHEN END_TIME::STRING LIKE '%EST%' THEN 
                TRY_TO_TIMESTAMP(REPLACE(END_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS')
            ELSE END_TIME
        END AS CLEAN_END_TIME,
        CLEAN_DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        HAD_TEXT_UNITS
    FROM cleansed_duration
),

-- Data Quality and Cleansing
cleansed_data AS (
    SELECT 
        -- Primary identifiers
        COALESCE(TRIM(MEETING_ID), 'UNKNOWN_MEETING_' || ROW_NUMBER() OVER (ORDER BY LOAD_TIMESTAMP)) AS MEETING_ID,
        
        -- Host validation
        CASE 
            WHEN TRIM(HOST_ID) IS NULL OR TRIM(HOST_ID) = '' THEN 'UNKNOWN_HOST'
            ELSE TRIM(HOST_ID)
        END AS HOST_ID,
        
        -- Meeting topic cleansing
        CASE 
            WHEN TRIM(MEETING_TOPIC) IS NULL OR TRIM(MEETING_TOPIC) = '' THEN 'UNTITLED_MEETING'
            ELSE TRIM(MEETING_TOPIC)
        END AS MEETING_TOPIC,
        
        -- Cleaned timestamps
        COALESCE(CLEAN_START_TIME, CURRENT_TIMESTAMP()) AS START_TIME,
        COALESCE(CLEAN_END_TIME, DATEADD('minute', COALESCE(CLEAN_DURATION_MINUTES, 30), COALESCE(CLEAN_START_TIME, CURRENT_TIMESTAMP()))) AS END_TIME,
        
        -- Duration validation and calculation
        CASE 
            WHEN CLEAN_DURATION_MINUTES IS NOT NULL AND CLEAN_DURATION_MINUTES > 0 AND CLEAN_DURATION_MINUTES <= 1440 
            THEN CLEAN_DURATION_MINUTES
            WHEN CLEAN_START_TIME IS NOT NULL AND CLEAN_END_TIME IS NOT NULL 
            THEN GREATEST(DATEDIFF('minute', CLEAN_START_TIME, CLEAN_END_TIME), 0)
            ELSE 30  -- Default 30 minutes
        END AS DURATION_MINUTES,
        
        -- Metadata columns
        COALESCE(LOAD_TIMESTAMP, CURRENT_TIMESTAMP()) AS LOAD_TIMESTAMP,
        COALESCE(UPDATE_TIMESTAMP, CURRENT_TIMESTAMP()) AS UPDATE_TIMESTAMP,
        COALESCE(TRIM(SOURCE_SYSTEM), 'UNKNOWN') AS SOURCE_SYSTEM,
        
        -- Silver layer specific columns
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        
        -- Data quality scoring
        CASE 
            WHEN MEETING_ID IS NOT NULL 
                 AND HOST_ID IS NOT NULL 
                 AND CLEAN_START_TIME IS NOT NULL 
                 AND CLEAN_END_TIME IS NOT NULL
                 AND CLEAN_DURATION_MINUTES IS NOT NULL 
                 AND CLEAN_DURATION_MINUTES > 0
                 AND CLEAN_END_TIME > CLEAN_START_TIME THEN 100
            WHEN MEETING_ID IS NOT NULL AND HOST_ID IS NOT NULL AND CLEAN_START_TIME IS NOT NULL THEN 80
            WHEN MEETING_ID IS NOT NULL AND HOST_ID IS NOT NULL THEN 60
            ELSE 40
        END AS DATA_QUALITY_SCORE,
        
        -- Validation status
        CASE 
            WHEN MEETING_ID IS NULL THEN 'FAILED'
            WHEN CLEAN_END_TIME <= CLEAN_START_TIME THEN 'FAILED'
            WHEN CLEAN_DURATION_MINUTES IS NULL OR CLEAN_DURATION_MINUTES <= 0 THEN 'WARNING'
            WHEN HAD_TEXT_UNITS THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS,
        
        -- Audit flags
        HAD_TEXT_UNITS,
        
        -- Row number for deduplication
        ROW_NUMBER() OVER (PARTITION BY MEETING_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM timestamp_cleaned
    WHERE MEETING_ID IS NOT NULL
),

-- Final deduplication and validation
final_data AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        MEETING_TOPIC,
        START_TIME,
        END_TIME,
        DURATION_MINUTES,
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
      AND END_TIME > START_TIME  -- Ensure logical time sequence
      AND DURATION_MINUTES > 0   -- Ensure positive duration
)

SELECT * FROM final_data
