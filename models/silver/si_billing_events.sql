{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, EXECUTED_BY, EXECUTION_ENVIRONMENT, DATA_LINEAGE_INFO, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key(["'SI_BILLING_EVENTS'", 'CURRENT_TIMESTAMP()']) }}', 'SI_BILLING_EVENTS_TRANSFORM', CURRENT_TIMESTAMP(), 'STARTED', 'BRONZE.BZ_BILLING_EVENTS', 'SILVER.SI_BILLING_EVENTS', 'DBT_PIPELINE', 'PROD', 'Billing events data transformation with validation', CURRENT_DATE(), CURRENT_DATE(), 'SILVER_LAYER_PIPELINE' WHERE '{{ this.name }}' != 'audit_log'",
    post_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, END_TIME, STATUS, RECORDS_PROCESSED, RECORDS_INSERTED, EXECUTED_BY, EXECUTION_ENVIRONMENT, DATA_LINEAGE_INFO, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key(["'SI_BILLING_EVENTS'", 'CURRENT_TIMESTAMP()']) }}', 'SI_BILLING_EVENTS_TRANSFORM', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 'COMPLETED', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 'DBT_PIPELINE', 'PROD', 'Billing events data transformation completed', CURRENT_DATE(), CURRENT_DATE(), 'SILVER_LAYER_PIPELINE' WHERE '{{ this.name }}' != 'audit_log'"
) }}

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
      AND AMOUNT > 0
      AND EVENT_DATE IS NOT NULL
),

-- Data cleansing and enrichment
cleansed_billing_events AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        CASE 
            WHEN UPPER(EVENT_TYPE) IN ('SUBSCRIPTION', 'UPGRADE', 'DOWNGRADE', 'REFUND') 
            THEN INITCAP(EVENT_TYPE)
            ELSE 'Subscription'
        END AS EVENT_TYPE,
        AMOUNT AS TRANSACTION_AMOUNT,
        EVENT_DATE AS TRANSACTION_DATE,
        'Credit Card' AS PAYMENT_METHOD,  -- Default payment method
        'USD' AS CURRENCY_CODE,  -- Default currency
        CONCAT('INV-', EVENT_ID, '-', DATE_PART('year', EVENT_DATE)) AS INVOICE_NUMBER,
        'Completed' AS TRANSACTION_STATUS,  -- Default status
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM bronze_billing_events
    WHERE EVENT_DATE <= CURRENT_DATE()
),

-- Data quality scoring
quality_scored_billing_events AS (
    SELECT 
        *,
        CASE 
            WHEN EVENT_ID IS NOT NULL 
                 AND USER_ID IS NOT NULL 
                 AND EVENT_TYPE IN ('Subscription', 'Upgrade', 'Downgrade', 'Refund')
                 AND TRANSACTION_AMOUNT > 0
                 AND TRANSACTION_DATE IS NOT NULL
                 AND CURRENCY_CODE = 'USD'
                 AND TRANSACTION_STATUS = 'Completed'
            THEN 1.00
            WHEN EVENT_ID IS NOT NULL AND USER_ID IS NOT NULL AND TRANSACTION_AMOUNT > 0
            THEN 0.75
            WHEN EVENT_ID IS NOT NULL AND USER_ID IS NOT NULL
            THEN 0.50
            ELSE 0.25
        END AS DATA_QUALITY_SCORE
    FROM cleansed_billing_events
),

-- Remove duplicates
deduped_billing_events AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY EVENT_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM quality_scored_billing_events
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
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
FROM deduped_billing_events
WHERE rn = 1
  AND DATA_QUALITY_SCORE >= 0.50
