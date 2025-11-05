{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

-- Bronze to Silver transformation for Billing Events
-- Implements data quality checks and standardization

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
      AND TRIM(EVENT_ID) != ''
),

data_quality_checks AS (
    SELECT 
        bbe.*,
        -- Validation checks
        CASE 
            WHEN bbe.AMOUNT IS NULL OR bbe.AMOUNT <= 0 THEN 'INVALID_AMOUNT'
            WHEN bbe.AMOUNT > 10000 THEN 'POTENTIAL_OUTLIER'
            WHEN bbe.EVENT_DATE IS NULL THEN 'MISSING_EVENT_DATE'
            WHEN bbe.EVENT_DATE > CURRENT_DATE() THEN 'FUTURE_EVENT_DATE'
            WHEN bbe.USER_ID IS NULL THEN 'MISSING_USER_ID'
            ELSE 'VALID'
        END AS validation_status
    FROM bronze_billing_events bbe
),

valid_records AS (
    SELECT 
        dqc.EVENT_ID,
        dqc.USER_ID,
        UPPER(TRIM(dqc.EVENT_TYPE)) AS EVENT_TYPE,
        dqc.AMOUNT,
        dqc.EVENT_DATE,
        'USD' AS CURRENCY_CODE,  -- Default currency as per business rules
        DATE(dqc.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(dqc.UPDATE_TIMESTAMP) AS UPDATE_DATE,
        dqc.SOURCE_SYSTEM,
        dqc.LOAD_TIMESTAMP,
        dqc.UPDATE_TIMESTAMP,
        ROW_NUMBER() OVER (PARTITION BY dqc.EVENT_ID ORDER BY dqc.UPDATE_TIMESTAMP DESC) AS rn
    FROM data_quality_checks dqc
    INNER JOIN {{ ref('si_users') }} u ON dqc.USER_ID = u.USER_ID
    WHERE dqc.validation_status IN ('VALID', 'POTENTIAL_OUTLIER')
      AND dqc.AMOUNT > 0
      AND dqc.EVENT_TYPE IS NOT NULL
      AND TRIM(dqc.EVENT_TYPE) != ''
)

SELECT 
    EVENT_ID,
    USER_ID,
    EVENT_TYPE,
    AMOUNT,
    EVENT_DATE,
    CURRENCY_CODE,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP
FROM valid_records
WHERE rn = 1
