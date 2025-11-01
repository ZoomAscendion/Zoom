{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, EXECUTED_BY, EXECUTION_ENVIRONMENT, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key(["'SI_BILLING_EVENTS'", 'CURRENT_TIMESTAMP()']) }}', 'SI_BILLING_EVENTS_TRANSFORMATION', CURRENT_TIMESTAMP(), 'STARTED', 'DBT_SYSTEM', 'PROD', 'BZ_BILLING_EVENTS', 'SI_BILLING_EVENTS', CURRENT_DATE(), CURRENT_DATE(), 'Silver Layer Pipeline' WHERE '{{ this.name }}' != 'audit_log'",
    post_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, END_TIME, STATUS, EXECUTED_BY, EXECUTION_ENVIRONMENT, RECORDS_PROCESSED, RECORDS_INSERTED, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key(["'SI_BILLING_EVENTS'", 'CURRENT_TIMESTAMP()']) }}', 'SI_BILLING_EVENTS_TRANSFORMATION', CURRENT_TIMESTAMP(), 'SUCCESS', 'DBT_SYSTEM', 'PROD', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), CURRENT_DATE(), CURRENT_DATE(), 'Silver Layer Pipeline' WHERE '{{ this.name }}' != 'audit_log'"
) }}

-- Silver Layer Billing Events Table
-- Transforms billing event data with financial validations and transaction categorization

WITH bronze_billing_events AS (
    SELECT 
        bbe.EVENT_ID,
        bbe.USER_ID,
        bbe.EVENT_TYPE,
        bbe.AMOUNT,
        bbe.EVENT_DATE,
        bbe.LOAD_TIMESTAMP,
        bbe.UPDATE_TIMESTAMP,
        bbe.SOURCE_SYSTEM
    FROM {{ source('bronze', 'bz_billing_events') }} bbe
    WHERE bbe.EVENT_ID IS NOT NULL
      AND bbe.USER_ID IS NOT NULL
      AND bbe.AMOUNT > 0
      AND bbe.EVENT_DATE IS NOT NULL
),

-- Data Quality and Cleansing Layer
cleansed_billing_events AS (
    SELECT 
        -- Primary Keys
        TRIM(bbe.EVENT_ID) AS EVENT_ID,
        TRIM(bbe.USER_ID) AS USER_ID,
        
        -- Standardized Event Type
        CASE 
            WHEN UPPER(bbe.EVENT_TYPE) LIKE '%SUBSCRIPTION%' OR UPPER(bbe.EVENT_TYPE) LIKE '%SUBSCRIBE%' THEN 'Subscription'
            WHEN UPPER(bbe.EVENT_TYPE) LIKE '%UPGRADE%' THEN 'Upgrade'
            WHEN UPPER(bbe.EVENT_TYPE) LIKE '%DOWNGRADE%' THEN 'Downgrade'
            WHEN UPPER(bbe.EVENT_TYPE) LIKE '%REFUND%' THEN 'Refund'
            ELSE 'Subscription'  -- Default category
        END AS EVENT_TYPE,
        
        -- Validated Transaction Amount
        ROUND(bbe.AMOUNT, 2) AS TRANSACTION_AMOUNT,
        
        bbe.EVENT_DATE AS TRANSACTION_DATE,
        
        -- Derive Payment Method (placeholder logic)
        CASE 
            WHEN bbe.AMOUNT < 50 THEN 'Credit Card'
            WHEN bbe.AMOUNT BETWEEN 50 AND 500 THEN 'Bank Transfer'
            ELSE 'PayPal'
        END AS PAYMENT_METHOD,
        
        -- Default Currency Code
        'USD' AS CURRENCY_CODE,
        
        -- Generate Invoice Number
        CONCAT('INV-', YEAR(bbe.EVENT_DATE), '-', LPAD(ROW_NUMBER() OVER (ORDER BY bbe.EVENT_DATE, bbe.EVENT_ID), 6, '0')) AS INVOICE_NUMBER,
        
        -- Transaction Status
        CASE 
            WHEN UPPER(bbe.EVENT_TYPE) LIKE '%REFUND%' THEN 'Refunded'
            WHEN bbe.AMOUNT > 0 THEN 'Completed'
            ELSE 'Failed'
        END AS TRANSACTION_STATUS,
        
        -- Metadata Columns
        bbe.LOAD_TIMESTAMP,
        bbe.UPDATE_TIMESTAMP,
        bbe.SOURCE_SYSTEM,
        
        -- Data Quality Score Calculation
        (
            CASE WHEN bbe.EVENT_ID IS NOT NULL THEN 0.2 ELSE 0 END +
            CASE WHEN bbe.USER_ID IS NOT NULL THEN 0.2 ELSE 0 END +
            CASE WHEN bbe.EVENT_TYPE IS NOT NULL THEN 0.2 ELSE 0 END +
            CASE WHEN bbe.AMOUNT > 0 THEN 0.2 ELSE 0 END +
            CASE WHEN bbe.EVENT_DATE IS NOT NULL THEN 0.2 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        -- Standard Metadata
        DATE(bbe.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(bbe.UPDATE_TIMESTAMP) AS UPDATE_DATE
        
    FROM bronze_billing_events bbe
),

-- Deduplication Layer
deduped_billing_events AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY EVENT_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM cleansed_billing_events
)

-- Final Select with Data Quality Filters
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
FROM deduped_billing_events
WHERE rn = 1
  AND DATA_QUALITY_SCORE >= 0.80  -- Minimum quality threshold
  AND EVENT_ID IS NOT NULL
  AND USER_ID IS NOT NULL
