{{ config(
    materialized='table'
) }}

-- Silver Layer Billing Events Table Transformation
-- Applies data quality checks, standardization, and business rules

WITH bronze_billing_events AS (
    SELECT *
    FROM {{ source('bronze', 'bz_billing_events') }}
    WHERE LOAD_TIMESTAMP IS NOT NULL
),

validated_billing_events AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        EVENT_TYPE,
        AMOUNT,
        EVENT_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Data quality validation
        CASE 
            WHEN EVENT_ID IS NULL OR TRIM(EVENT_ID) = '' THEN 'INVALID_EVENT_ID'
            WHEN USER_ID IS NULL OR TRIM(USER_ID) = '' THEN 'INVALID_USER_ID'
            WHEN EVENT_TYPE IS NULL OR TRIM(EVENT_TYPE) = '' THEN 'INVALID_EVENT_TYPE'
            WHEN AMOUNT IS NULL OR AMOUNT <= 0 THEN 'INVALID_AMOUNT'
            WHEN AMOUNT > 50000 THEN 'EXCESSIVE_AMOUNT'
            WHEN EVENT_DATE IS NULL THEN 'INVALID_EVENT_DATE'
            ELSE 'VALID'
        END AS data_quality_flag
    FROM bronze_billing_events
),

cleansed_billing_events AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        UPPER(TRIM(EVENT_TYPE)) AS EVENT_TYPE,
        ROUND(AMOUNT, 2) AS AMOUNT,
        EVENT_DATE,
        'USD' AS CURRENCY_CODE,  -- Default currency code
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        SOURCE_SYSTEM,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP
    FROM validated_billing_events
    WHERE data_quality_flag = 'VALID'
),

deduped_billing_events AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY EVENT_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) AS row_num
    FROM cleansed_billing_events
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
FROM deduped_billing_events
WHERE row_num = 1
