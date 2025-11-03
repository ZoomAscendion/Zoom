{{
    config(
        materialized='table',
        on_schema_change='sync_all_columns'
    )
}}

-- Silver Layer Billing Events Transformation
-- Transforms Bronze layer billing event data with financial validations

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
      AND USER_ID IS NOT NULL
),

-- Data Quality Validations and Cleansing
billing_events_cleaned AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        
        -- Standardize event type
        CASE 
            WHEN UPPER(TRIM(EVENT_TYPE)) IN ('SUBSCRIPTION', 'SUB', 'SUBSCRIBE') THEN 'Subscription'
            WHEN UPPER(TRIM(EVENT_TYPE)) IN ('UPGRADE', 'UP') THEN 'Upgrade'
            WHEN UPPER(TRIM(EVENT_TYPE)) IN ('DOWNGRADE', 'DOWN') THEN 'Downgrade'
            WHEN UPPER(TRIM(EVENT_TYPE)) IN ('REFUND', 'RETURN') THEN 'Refund'
            ELSE 'Other'
        END AS EVENT_TYPE,
        
        -- Validate and correct transaction amount
        CASE 
            WHEN AMOUNT < 0 AND UPPER(TRIM(EVENT_TYPE)) NOT IN ('REFUND', 'RETURN') THEN ABS(AMOUNT)
            WHEN AMOUNT IS NULL THEN 0.00
            ELSE AMOUNT
        END AS TRANSACTION_AMOUNT,
        
        -- Validate transaction date
        CASE 
            WHEN EVENT_DATE > CURRENT_DATE() THEN CURRENT_DATE()
            WHEN EVENT_DATE < '2020-01-01' THEN '2020-01-01'
            ELSE EVENT_DATE
        END AS TRANSACTION_DATE,
        
        -- Derive payment method from event type and amount
        CASE 
            WHEN AMOUNT >= 100 THEN 'Bank Transfer'
            WHEN AMOUNT >= 20 THEN 'Credit Card'
            ELSE 'PayPal'
        END AS PAYMENT_METHOD,
        
        -- Set currency code (defaulting to USD)
        'USD' AS CURRENCY_CODE,
        
        -- Generate invoice number
        'INV-' || EVENT_ID || '-' || TO_CHAR(EVENT_DATE, 'YYYYMMDD') AS INVOICE_NUMBER,
        
        -- Derive transaction status
        CASE 
            WHEN AMOUNT > 0 THEN 'Completed'
            WHEN AMOUNT < 0 THEN 'Refunded'
            ELSE 'Pending'
        END AS TRANSACTION_STATUS,
        
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Calculate data quality score
        (
            CASE WHEN EVENT_ID IS NOT NULL THEN 0.2 ELSE 0 END +
            CASE WHEN USER_ID IS NOT NULL THEN 0.2 ELSE 0 END +
            CASE WHEN EVENT_TYPE IS NOT NULL THEN 0.2 ELSE 0 END +
            CASE WHEN AMOUNT IS NOT NULL THEN 0.2 ELSE 0 END +
            CASE WHEN EVENT_DATE IS NOT NULL THEN 0.2 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM bronze_billing_events
),

-- Remove duplicates keeping the latest record
billing_events_deduped AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY EVENT_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM billing_events_cleaned
)

SELECT 
    EVENT_ID,
    USER_ID,
    EVENT_TYPE,
    TRANSACTION_AMOUNT,
    TRANSACTION_DATE,
    PAYMENT_METHOD,
    CURRENCY_CODE,
    INVOICE_NUMBER,
    TRANSACTION_STATUS,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATA_QUALITY_SCORE,
    LOAD_DATE,
    UPDATE_DATE
FROM billing_events_deduped
WHERE rn = 1
  AND DATA_QUALITY_SCORE >= 0.80  -- Only allow records with at least 80% data quality
