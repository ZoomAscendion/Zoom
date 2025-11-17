{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (TABLE_NAME, STATUS, EXECUTION_START_TIME, EXECUTED_BY, LOAD_TIMESTAMP) SELECT 'SI_BILLING_EVENTS', 'STARTED', CURRENT_TIMESTAMP(), 'DBT_PIPELINE', CURRENT_TIMESTAMP()",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (TABLE_NAME, STATUS, EXECUTION_END_TIME, RECORDS_PROCESSED, RECORDS_SUCCESS, EXECUTED_BY, UPDATE_TIMESTAMP) SELECT 'SI_BILLING_EVENTS', 'COMPLETED', CURRENT_TIMESTAMP(), (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }} WHERE VALIDATION_STATUS = 'PASSED'), 'DBT_PIPELINE', CURRENT_TIMESTAMP()"
) }}

-- Silver Layer Billing Events Table
-- Purpose: Clean and standardized financial transactions and billing activities
-- Transformation: Bronze BZ_BILLING_EVENTS -> Silver SI_BILLING_EVENTS

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
    WHERE EVENT_ID IS NOT NULL
),

data_quality_checks AS (
    SELECT 
        b.*,
        -- Amount validation
        CASE 
            WHEN b.AMOUNT > 0 THEN 1
            ELSE 0
        END AS amount_valid,
        
        -- Event date validation
        CASE 
            WHEN b.EVENT_DATE <= CURRENT_DATE() THEN 1
            ELSE 0
        END AS date_valid,
        
        -- User reference validation
        CASE 
            WHEN u.USER_ID IS NOT NULL THEN 1
            ELSE 0
        END AS user_ref_valid,
        
        -- Event type validation
        CASE 
            WHEN b.EVENT_TYPE IS NOT NULL AND LENGTH(TRIM(b.EVENT_TYPE)) > 0 THEN 1
            ELSE 0
        END AS event_type_valid,
        
        -- Calculate data quality score
        CASE 
            WHEN b.EVENT_ID IS NOT NULL AND b.USER_ID IS NOT NULL AND b.EVENT_TYPE IS NOT NULL 
                 AND b.AMOUNT IS NOT NULL AND b.EVENT_DATE IS NOT NULL THEN
                CASE 
                    WHEN b.AMOUNT > 0 AND b.EVENT_DATE <= CURRENT_DATE() AND u.USER_ID IS NOT NULL 
                         AND LENGTH(TRIM(b.EVENT_TYPE)) > 0 THEN 100
                    WHEN b.AMOUNT > 0 AND b.EVENT_DATE <= CURRENT_DATE() AND LENGTH(TRIM(b.EVENT_TYPE)) > 0 THEN 80
                    WHEN b.AMOUNT > 0 AND b.EVENT_DATE <= CURRENT_DATE() THEN 60
                    ELSE 40
                END
            ELSE 0
        END AS data_quality_score
    FROM bronze_billing_events b
    LEFT JOIN {{ ref('SI_USERS') }} u ON b.USER_ID = u.USER_ID
),

deduplication AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY EVENT_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM data_quality_checks
),

cleaned_billing_events AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        TRIM(UPPER(EVENT_TYPE)) AS EVENT_TYPE,
        ROUND(AMOUNT, 2) AS AMOUNT,
        EVENT_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Additional Silver layer metadata
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        data_quality_score AS DATA_QUALITY_SCORE,
        CASE 
            WHEN data_quality_score >= 80 THEN 'PASSED'
            WHEN data_quality_score >= 50 THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM deduplication
    WHERE rn = 1
      AND EVENT_ID IS NOT NULL
      AND USER_ID IS NOT NULL
      AND AMOUNT > 0
      AND EVENT_DATE <= CURRENT_DATE()
)

SELECT * FROM cleaned_billing_events
