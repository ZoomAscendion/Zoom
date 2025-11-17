{{ config(
    materialized='table',
    pre_hook="
        {% if this.name != 'SI_AUDIT_LOG' %}
        INSERT INTO {{ ref('SI_AUDIT_LOG') }} (MODEL_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_START_TIME, STATUS, LOAD_TIMESTAMP)
        VALUES ('{{ this.name }}', 'BZ_MEETINGS', 'SI_MEETINGS', CURRENT_TIMESTAMP(), 'STARTED', CURRENT_TIMESTAMP())
        {% endif %}
    ",
    post_hook="
        {% if this.name != 'SI_AUDIT_LOG' %}
        INSERT INTO {{ ref('SI_AUDIT_LOG') }} (MODEL_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_END_TIME, STATUS, RECORDS_SUCCESS, LOAD_TIMESTAMP)
        VALUES ('{{ this.name }}', 'BZ_MEETINGS', 'SI_MEETINGS', CURRENT_TIMESTAMP(), 'COMPLETED', (SELECT COUNT(*) FROM {{ this }}), CURRENT_TIMESTAMP())
        {% endif %}
    "
) }}

-- Silver layer transformation for Meetings table
-- Handles EST timezone conversion and data quality validation

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
    WHERE MEETING_ID IS NOT NULL
),

timestamp_conversion AS (
    SELECT 
        *,
        -- Handle EST timezone conversion for START_TIME
        CASE 
            WHEN START_TIME::STRING LIKE '%EST%' THEN 
                CASE 
                    WHEN TYPEOF(START_TIME) = 'VARCHAR' THEN
                        TRY_TO_TIMESTAMP(REPLACE(START_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS')
                    ELSE START_TIME
                END
            ELSE START_TIME
        END AS CONVERTED_START_TIME,
        
        -- Handle EST timezone conversion for END_TIME
        CASE 
            WHEN END_TIME::STRING LIKE '%EST%' THEN 
                CASE 
                    WHEN TYPEOF(END_TIME) = 'VARCHAR' THEN
                        TRY_TO_TIMESTAMP(REPLACE(END_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS')
                    ELSE END_TIME
                END
            ELSE END_TIME
        END AS CONVERTED_END_TIME
    FROM source_data
),

data_quality_checks AS (
    SELECT 
        *,
        -- Validate duration consistency after timestamp conversion
        ABS(DURATION_MINUTES - DATEDIFF('minute', CONVERTED_START_TIME, CONVERTED_END_TIME)) AS DURATION_DIFF,
        
        -- Data quality score calculation
        CASE 
            WHEN MEETING_ID IS NOT NULL 
                AND HOST_ID IS NOT NULL 
                AND CONVERTED_START_TIME IS NOT NULL 
                AND CONVERTED_END_TIME IS NOT NULL 
                AND CONVERTED_END_TIME > CONVERTED_START_TIME
                AND DURATION_MINUTES BETWEEN 0 AND 1440
                AND ABS(DURATION_MINUTES - DATEDIFF('minute', CONVERTED_START_TIME, CONVERTED_END_TIME)) <= 1
            THEN 100
            WHEN MEETING_ID IS NOT NULL AND HOST_ID IS NOT NULL AND CONVERTED_START_TIME IS NOT NULL
            THEN 75
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        
        -- Validation status
        CASE 
            WHEN MEETING_ID IS NOT NULL 
                AND HOST_ID IS NOT NULL 
                AND CONVERTED_START_TIME IS NOT NULL 
                AND CONVERTED_END_TIME IS NOT NULL 
                AND CONVERTED_END_TIME > CONVERTED_START_TIME
                AND DURATION_MINUTES BETWEEN 0 AND 1440
            THEN 'PASSED'
            WHEN MEETING_ID IS NOT NULL AND HOST_ID IS NOT NULL
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM timestamp_conversion
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY MEETING_ID ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC) AS rn
    FROM data_quality_checks
),

final_transformation AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        TRIM(MEETING_TOPIC) AS MEETING_TOPIC,
        CONVERTED_START_TIME AS START_TIME,
        CONVERTED_END_TIME AS END_TIME,
        DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        DATA_QUALITY_SCORE,
        VALIDATION_STATUS
    FROM deduplication
    WHERE rn = 1  -- Keep only the latest record per meeting
        AND VALIDATION_STATUS != 'FAILED'  -- Exclude failed records
)

SELECT * FROM final_transformation
