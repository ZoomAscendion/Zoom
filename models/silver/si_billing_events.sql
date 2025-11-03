{{ config(
    materialized='table'
) }}

-- Silver Layer Billing Events Table
-- Transforms Bronze billing events data with validation and financial transaction standardization

WITH bronze_billing_events AS (
    SELECT *
    FROM {{ source('bronze', 'bz_billing_events') }}
    WHERE EVENT_ID IS NOT NULL
        AND USER_ID IS NOT NULL
),

-- Data Quality Checks and Transformations
billing_events_cleaned AS (
    SELECT 
        -- Primary identifiers
        EVENT_ID,
        USER_ID,
        
        -- Event type standardization
        CASE 
            WHEN UPPER(TRIM(COALESCE(EVENT_TYPE, ''))) IN ('SUBSCRIPTION', 'UPGRADE', 'DOWNGRADE', 'REFUND') 
                THEN INITCAP(EVENT_TYPE)
            ELSE 'Unknown Transaction'
        END AS EVENT_TYPE,
        
        -- Transaction amount validation
        CASE 
            WHEN AMOUNT < 0 AND UPPER(TRIM(COALESCE(EVENT_TYPE, ''))) != 'REFUND' THEN ABS(AMOUNT)
            ELSE COALESCE(AMOUNT, 0.00)
        END AS TRANSACTION_AMOUNT,
        
        -- Transaction date validation
        CASE 
            WHEN EVENT_DATE > CURRENT_DATE() + INTERVAL '1 DAY' THEN CURRENT_DATE()
            ELSE COALESCE(EVENT_DATE, CURRENT_DATE())
        END AS TRANSACTION_DATE,
        
        -- Payment method derivation
        CASE 
            WHEN COALESCE(AMOUNT, 0) > 100 THEN 'Credit Card'
            WHEN COALESCE(AMOUNT, 0) > 50 THEN 'Bank Transfer'
            ELSE 'PayPal'
        END AS PAYMENT_METHOD,
        
        -- Currency code standardization
        'USD' AS CURRENCY_CODE,
        
        -- Invoice number generation
        CONCAT('INV-', EVENT_ID, '-', TO_CHAR(COALESCE(EVENT_DATE, CURRENT_DATE()), 'YYYYMMDD')) AS INVOICE_NUMBER,
        
        -- Transaction status derivation
        CASE 
            WHEN COALESCE(AMOUNT, 0) > 0 THEN 'Completed'
            WHEN COALESCE(AMOUNT, 0) = 0 THEN 'Pending'
            ELSE 'Failed'
        END AS TRANSACTION_STATUS,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data quality score calculation
        CASE 
            WHEN EVENT_ID IS NOT NULL 
                AND USER_ID IS NOT NULL
                AND EVENT_TYPE IS NOT NULL
                AND AMOUNT IS NOT NULL
                AND EVENT_DATE IS NOT NULL
                THEN 1.00
            WHEN EVENT_ID IS NOT NULL AND USER_ID IS NOT NULL
                THEN 0.75
            WHEN EVENT_ID IS NOT NULL
                THEN 0.50
            ELSE 0.25
        END AS DATA_QUALITY_SCORE,
        
        -- Standard metadata
        LOAD_TIMESTAMP::DATE AS LOAD_DATE,
        UPDATE_TIMESTAMP::DATE AS UPDATE_DATE,
        
        -- Row number for deduplication
        ROW_NUMBER() OVER (PARTITION BY EVENT_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
        
    FROM bronze_billing_events
),

-- Final selection with data quality filters
billing_events_final AS (
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
    FROM billing_events_cleaned
    WHERE rn = 1  -- Deduplication
        AND TRANSACTION_AMOUNT >= 0  -- Ensure non-negative amounts
)

SELECT * FROM billing_events_final
