{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_audit_log') }} (TABLE_NAME, STATUS, AUDIT_TIMESTAMP, LOAD_TIMESTAMP) SELECT 'SI_BILLING_EVENTS', 'PROCESSING_STARTED', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'si_audit_log'",
    post_hook="INSERT INTO {{ ref('si_audit_log') }} (TABLE_NAME, STATUS, AUDIT_TIMESTAMP, LOAD_TIMESTAMP) SELECT 'SI_BILLING_EVENTS', 'PROCESSING_COMPLETED', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'si_audit_log'"
) }}

-- SI_BILLING_EVENTS: Cleaned and standardized financial transactions and billing activities
-- Transformation from Bronze BZ_BILLING_EVENTS to Silver SI_BILLING_EVENTS

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

-- Data Cleansing and Standardization
cleansed_billing_events AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        UPPER(TRIM(EVENT_TYPE)) AS EVENT_TYPE,
        ROUND(AMOUNT, 2) AS AMOUNT,
        EVENT_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM bronze_billing_events
    WHERE AMOUNT > 0
      AND EVENT_DATE <= CURRENT_DATE()
),

-- Data Quality Validation
validated_billing_events AS (
    SELECT 
        b.EVENT_ID,
        b.USER_ID,
        b.EVENT_TYPE,
        b.AMOUNT,
        b.EVENT_DATE,
        b.LOAD_TIMESTAMP,
        b.UPDATE_TIMESTAMP,
        b.SOURCE_SYSTEM,
        -- Data Quality Scoring
        CASE 
            WHEN b.AMOUNT > 0 AND b.EVENT_DATE <= CURRENT_DATE()
                 AND b.EVENT_TYPE IS NOT NULL AND LENGTH(TRIM(b.EVENT_TYPE)) > 0
                 AND u.USER_ID IS NOT NULL
            THEN 100
            WHEN b.AMOUNT > 0 AND b.EVENT_DATE <= CURRENT_DATE()
                 AND b.EVENT_TYPE IS NOT NULL
            THEN 80
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        CASE 
            WHEN b.AMOUNT > 0 AND b.EVENT_DATE <= CURRENT_DATE()
                 AND b.EVENT_TYPE IS NOT NULL AND LENGTH(TRIM(b.EVENT_TYPE)) > 0
                 AND u.USER_ID IS NOT NULL
            THEN 'PASSED'
            WHEN b.AMOUNT <= 0 OR b.EVENT_DATE > CURRENT_DATE()
            THEN 'FAILED'
            ELSE 'WARNING'
        END AS VALIDATION_STATUS
    FROM cleansed_billing_events b
    LEFT JOIN {{ ref('si_users') }} u ON b.USER_ID = u.USER_ID
),

-- Remove Duplicates
deduped_billing_events AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY EVENT_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
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
    -- Additional Silver layer metadata columns
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_billing_events
WHERE rn = 1
  AND AMOUNT > 0
  AND EVENT_DATE <= CURRENT_DATE()
  AND EVENT_TYPE IS NOT NULL
