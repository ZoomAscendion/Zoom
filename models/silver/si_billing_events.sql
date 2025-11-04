{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, EXECUTED_BY, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, LOAD_DATE) SELECT 'EXEC_' || REPLACE(CAST(CURRENT_TIMESTAMP() AS STRING), ' ', '_'), 'SI_BILLING_EVENTS_TRANSFORMATION', CURRENT_TIMESTAMP(), 'STARTED', 'DBT_PIPELINE', 'BZ_BILLING_EVENTS', 'SI_BILLING_EVENTS', CURRENT_DATE() WHERE EXISTS (SELECT 1 FROM {{ ref('audit_log') }} LIMIT 1)",
    post_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, END_TIME, STATUS, EXECUTED_BY, RECORDS_PROCESSED, LOAD_DATE) SELECT 'EXEC_' || REPLACE(CAST(CURRENT_TIMESTAMP() AS STRING), ' ', '_'), 'SI_BILLING_EVENTS_TRANSFORMATION', CURRENT_TIMESTAMP(), 'COMPLETED', 'DBT_PIPELINE', (SELECT COUNT(*) FROM {{ this }}), CURRENT_DATE() WHERE EXISTS (SELECT 1 FROM {{ ref('audit_log') }} LIMIT 1)"
) }}

-- Silver Layer Billing Events Table Transformation
-- Source: Bronze.BZ_BILLING_EVENTS

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

-- Data Quality Validation and Cleansing
validated_billing_events AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        
        -- Standardize event type and handle negative amounts
        CASE 
            WHEN AMOUNT < 0 AND EVENT_TYPE != 'Refund' THEN 'Refund'
            WHEN EVENT_TYPE IN ('Subscription', 'Upgrade', 'Downgrade', 'Refund') THEN EVENT_TYPE
            ELSE 'Other'
        END AS EVENT_TYPE,
        
        -- Validate transaction amount
        ABS(COALESCE(AMOUNT, 0)) AS TRANSACTION_AMOUNT,
        
        -- Validate transaction date
        CASE 
            WHEN EVENT_DATE > DATEADD('day', 1, CURRENT_DATE()) 
            THEN CURRENT_DATE()
            ELSE EVENT_DATE
        END AS TRANSACTION_DATE,
        
        -- Derive payment method from event type and amount patterns
        CASE 
            WHEN AMOUNT >= 1000 THEN 'Bank Transfer'
            WHEN AMOUNT >= 100 THEN 'Credit Card'
            ELSE 'PayPal'
        END AS PAYMENT_METHOD,
        
        -- Default currency code
        'USD' AS CURRENCY_CODE,
        
        -- Generate invoice number from event ID
        'INV-' || EVENT_ID AS INVOICE_NUMBER,
        
        -- Derive transaction status
        CASE 
            WHEN EVENT_TYPE = 'Refund' THEN 'Refunded'
            WHEN AMOUNT > 0 THEN 'Completed'
            ELSE 'Failed'
        END AS TRANSACTION_STATUS,
        
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Calculate data quality score
        CASE 
            WHEN EVENT_ID IS NOT NULL 
                AND USER_ID IS NOT NULL
                AND EVENT_TYPE IS NOT NULL
                AND AMOUNT IS NOT NULL
                AND EVENT_DATE IS NOT NULL
            THEN 1.00
            WHEN EVENT_ID IS NOT NULL AND USER_ID IS NOT NULL
            THEN 0.75
            ELSE 0.50
        END AS DATA_QUALITY_SCORE,
        
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        
        -- Add row number for deduplication
        ROW_NUMBER() OVER (PARTITION BY EVENT_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_billing_events
    WHERE EVENT_ID IS NOT NULL
        AND USER_ID IS NOT NULL
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
FROM validated_billing_events
WHERE rn = 1
