{{ config(
    materialized='table',
    pre_hook="
        {% if this.name != 'SI_AUDIT_LOG' %}
        INSERT INTO {{ ref('SI_AUDIT_LOG') }} (MODEL_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_START_TIME, STATUS, LOAD_TIMESTAMP)
        VALUES ('{{ this.name }}', 'BZ_BILLING_EVENTS', 'SI_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'STARTED', CURRENT_TIMESTAMP())
        {% endif %}
    ",
    post_hook="
        {% if this.name != 'SI_AUDIT_LOG' %}
        INSERT INTO {{ ref('SI_AUDIT_LOG') }} (MODEL_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_END_TIME, STATUS, RECORDS_SUCCESS, LOAD_TIMESTAMP)
        VALUES ('{{ this.name }}', 'BZ_BILLING_EVENTS', 'SI_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'COMPLETED', (SELECT COUNT(*) FROM {{ this }}), CURRENT_TIMESTAMP())
        {% endif %}
    "
) }}

-- Silver layer transformation for Billing Events table
-- Applies data quality checks and amount validation

WITH source_data AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        EVENT_TYPE,
        AMOUNT,
        EVENT_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('bronze', 'BZ_BILLING_EVENTS') }}
    WHERE EVENT_ID IS NOT NULL
),

data_quality_checks AS (
    SELECT 
        *,
        -- Clean amount field
        TRY_TO_NUMBER(REPLACE(REPLACE(AMOUNT::STRING, '"', ''), ',', '')) AS CLEANED_AMOUNT,
        
        -- Data quality score calculation
        CASE 
            WHEN EVENT_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND EVENT_TYPE IS NOT NULL 
                AND TRY_TO_NUMBER(REPLACE(REPLACE(AMOUNT::STRING, '"', ''), ',', '')) > 0
                AND EVENT_DATE IS NOT NULL 
                AND EVENT_DATE <= CURRENT_DATE()
            THEN 100
            WHEN EVENT_ID IS NOT NULL AND USER_ID IS NOT NULL
            THEN 75
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        
        -- Validation status
        CASE 
            WHEN EVENT_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND EVENT_TYPE IS NOT NULL 
                AND TRY_TO_NUMBER(REPLACE(REPLACE(AMOUNT::STRING, '"', ''), ',', '')) > 0
                AND EVENT_DATE IS NOT NULL 
                AND EVENT_DATE <= CURRENT_DATE()
            THEN 'PASSED'
            WHEN EVENT_ID IS NOT NULL AND USER_ID IS NOT NULL
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM source_data
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY EVENT_ID ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC) AS rn
    FROM data_quality_checks
),

final_transformation AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        UPPER(TRIM(EVENT_TYPE)) AS EVENT_TYPE,
        ROUND(CLEANED_AMOUNT, 2) AS AMOUNT,
        EVENT_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        DATA_QUALITY_SCORE,
        VALIDATION_STATUS
    FROM deduplication
    WHERE rn = 1  -- Keep only the latest record per event
        AND VALIDATION_STATUS != 'FAILED'  -- Exclude failed records
        AND CLEANED_AMOUNT IS NOT NULL
)

SELECT * FROM final_transformation
