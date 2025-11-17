{{ config(
    materialized='table',
    on_schema_change='sync_all_columns',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP) VALUES ('{{ invocation_id }}', 'SI_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'RUNNING', 'BRONZE.BZ_BILLING_EVENTS', 'SILVER.SI_BILLING_EVENTS', 'DBT_PIPELINE', CURRENT_TIMESTAMP())",
    post_hook="UPDATE {{ ref('SI_Audit_Log') }} SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(), EXECUTION_STATUS = 'SUCCESS', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), RECORDS_SUCCESS = (SELECT COUNT(*) FROM {{ this }}) WHERE EXECUTION_ID = '{{ invocation_id }}' AND TARGET_TABLE = 'SILVER.SI_BILLING_EVENTS'"
) }}

-- Silver Layer Billing Events Table
-- Transforms and cleanses billing event data from Bronze layer

WITH bronze_billing_events AS (
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
),

cleansed_billing_events AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        
        -- Event type standardization
        CASE 
            WHEN EVENT_TYPE IS NULL OR TRIM(EVENT_TYPE) = '' THEN 'UNKNOWN_EVENT'
            ELSE UPPER(TRIM(EVENT_TYPE))
        END AS EVENT_TYPE,
        
        -- Amount validation and conversion
        CASE 
            WHEN AMOUNT IS NULL OR AMOUNT <= 0 THEN 0.00
            WHEN TRY_TO_NUMBER(REPLACE(AMOUNT::STRING, '"', '')) IS NOT NULL THEN 
                ROUND(TRY_TO_NUMBER(REPLACE(AMOUNT::STRING, '"', '')), 2)
            ELSE ROUND(AMOUNT, 2)
        END AS AMOUNT,
        
        -- Event date validation
        CASE 
            WHEN EVENT_DATE IS NULL THEN DATE(LOAD_TIMESTAMP)
            WHEN EVENT_DATE > CURRENT_DATE() THEN CURRENT_DATE()
            ELSE EVENT_DATE
        END AS EVENT_DATE,
        
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Silver layer specific fields
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM bronze_billing_events
    WHERE EVENT_ID IS NOT NULL
),

data_quality_scored AS (
    SELECT 
        *,
        -- Calculate data quality score (0-100)
        CASE 
            WHEN EVENT_ID IS NOT NULL 
                AND USER_ID IS NOT NULL
                AND EVENT_TYPE != 'UNKNOWN_EVENT'
                AND AMOUNT > 0
                AND EVENT_DATE IS NOT NULL
            THEN 100
            WHEN EVENT_ID IS NOT NULL 
                AND USER_ID IS NOT NULL
                AND AMOUNT >= 0
                AND EVENT_DATE IS NOT NULL
            THEN 85
            WHEN EVENT_ID IS NOT NULL 
                AND USER_ID IS NOT NULL
            THEN 70
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        
        -- Validation status
        CASE 
            WHEN EVENT_ID IS NOT NULL 
                AND USER_ID IS NOT NULL
                AND EVENT_TYPE != 'UNKNOWN_EVENT'
                AND AMOUNT >= 0
            THEN 'PASSED'
            WHEN EVENT_ID IS NOT NULL 
                AND USER_ID IS NOT NULL
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM cleansed_billing_events
),

-- Remove duplicates keeping the latest record
deduped_billing_events AS (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY EVENT_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) as rn
        FROM data_quality_scored
    )
    WHERE rn = 1
)

SELECT 
    EVENT_ID,
    USER_ID,
    EVENT_TYPE,
    AMOUNT,
    EVENT_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    LOAD_DATE,
    UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_billing_events
WHERE VALIDATION_STATUS != 'FAILED'
