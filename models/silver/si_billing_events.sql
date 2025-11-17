{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_audit_log') }} (MODEL_NAME, TABLE_NAME, PROCESS_STATUS, LOAD_TIMESTAMP) SELECT 'si_billing_events', 'SI_BILLING_EVENTS', 'STARTED', CURRENT_TIMESTAMP()",
    post_hook="INSERT INTO {{ ref('si_audit_log') }} (MODEL_NAME, TABLE_NAME, PROCESS_STATUS, LOAD_TIMESTAMP) SELECT 'si_billing_events', 'SI_BILLING_EVENTS', 'COMPLETED', CURRENT_TIMESTAMP()"
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
    FROM {{ source('bronze', 'bz_billing_events') }}
    WHERE EVENT_ID IS NOT NULL
),

cleansed_billing_events AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        TRIM(UPPER(EVENT_TYPE)) AS EVENT_TYPE,
        -- Clean amount field removing quotes
        TRY_TO_NUMBER(REPLACE(AMOUNT::STRING, '"', '')) AS AMOUNT,
        EVENT_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Additional Silver layer metadata
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE
    FROM bronze_billing_events
),

validated_billing_events AS (
    SELECT *,
        CASE 
            WHEN EVENT_TYPE IS NOT NULL AND AMOUNT > 0 
                 AND EVENT_DATE IS NOT NULL AND EVENT_DATE <= CURRENT_DATE()
            THEN 100
            WHEN EVENT_TYPE IS NOT NULL AND AMOUNT > 0
            THEN 75
            WHEN EVENT_TYPE IS NOT NULL OR AMOUNT > 0
            THEN 50
            ELSE 25
        END AS DATA_QUALITY_SCORE,
        CASE 
            WHEN EVENT_TYPE IS NOT NULL AND AMOUNT > 0 
                 AND EVENT_DATE IS NOT NULL AND EVENT_DATE <= CURRENT_DATE()
            THEN 'PASSED'
            WHEN AMOUNT <= 0 OR EVENT_DATE > CURRENT_DATE()
            THEN 'FAILED'
            ELSE 'WARNING'
        END AS VALIDATION_STATUS
    FROM cleansed_billing_events
),

deduped_billing_events AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY EVENT_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM validated_billing_events
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
WHERE rn = 1
  AND VALIDATION_STATUS != 'FAILED'
