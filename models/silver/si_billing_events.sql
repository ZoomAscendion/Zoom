{{ config(
    materialized='table'
) }}

-- Pre-hook: Log process start
{% if this.name != 'audit_log' %}
{{ log("Starting transformation for si_billing_events", info=True) }}
{% endif %}

WITH source_data AS (
    SELECT 
        b.EVENT_ID,
        b.USER_ID,
        b.EVENT_TYPE,
        b.AMOUNT,
        b.EVENT_DATE,
        b.LOAD_TIMESTAMP,
        b.UPDATE_TIMESTAMP,
        b.SOURCE_SYSTEM
    FROM {{ ref('bz_billing_events') }} b
    WHERE b.EVENT_ID IS NOT NULL
),

data_quality_checks AS (
    SELECT 
        s.*,
        
        -- Event type validation
        CASE 
            WHEN s.EVENT_TYPE IN ('Subscription', 'Upgrade', 'Downgrade', 'Refund') THEN 1
            ELSE 0
        END AS event_type_valid,
        
        -- Amount validation
        CASE 
            WHEN s.AMOUNT IS NOT NULL AND s.AMOUNT >= 0 THEN 1
            ELSE 0
        END AS amount_valid,
        
        -- Date validation
        CASE 
            WHEN s.EVENT_DATE IS NOT NULL AND s.EVENT_DATE <= CURRENT_DATE() THEN 1
            ELSE 0
        END AS date_valid
    FROM source_data s
),

cleaned_data AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        
        -- Standardize event type
        CASE 
            WHEN event_type_valid = 1 THEN EVENT_TYPE
            ELSE 'Other'
        END AS EVENT_TYPE,
        
        -- Validate transaction amount
        CASE 
            WHEN amount_valid = 1 THEN AMOUNT
            ELSE 0.00
        END AS TRANSACTION_AMOUNT,
        
        -- Validate transaction date
        CASE 
            WHEN date_valid = 1 THEN EVENT_DATE
            ELSE CURRENT_DATE()
        END AS TRANSACTION_DATE,
        
        -- Derive payment method from amount patterns
        CASE 
            WHEN AMOUNT >= 100 THEN 'Bank Transfer'
            WHEN AMOUNT >= 50 THEN 'Credit Card'
            WHEN AMOUNT > 0 THEN 'PayPal'
            ELSE 'Unknown'
        END AS PAYMENT_METHOD,
        
        -- Set currency code
        'USD' AS CURRENCY_CODE,
        
        -- Generate invoice number
        CONCAT('INV-', EVENT_ID, '-', TO_CHAR(EVENT_DATE, 'YYYYMMDD')) AS INVOICE_NUMBER,
        
        -- Derive transaction status
        CASE 
            WHEN EVENT_TYPE = 'Refund' THEN 'Refunded'
            WHEN AMOUNT > 0 THEN 'Completed'
            ELSE 'Pending'
        END AS TRANSACTION_STATUS,
        
        -- Calculate data quality score
        ROUND((event_type_valid + amount_valid + date_valid) / 3.0, 2) AS DATA_QUALITY_SCORE,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at
        
    FROM data_quality_checks
    WHERE EVENT_ID IS NOT NULL  -- Remove records with null primary key
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY EVENT_ID 
            ORDER BY UPDATE_TIMESTAMP DESC
        ) AS row_num
    FROM cleaned_data
    QUALIFY row_num = 1
)

-- Final SELECT
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
    UPDATE_DATE,
    created_at,
    updated_at
FROM deduplication

-- Post-hook: Log process completion
{% if this.name != 'audit_log' %}
{{ log("Completed transformation for si_billing_events", info=True) }}
{% endif %}
