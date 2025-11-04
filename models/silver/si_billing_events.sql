{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, EXECUTED_BY, EXECUTION_ENVIRONMENT, DATA_LINEAGE_INFO, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT CONCAT('SILVER_BILLING_EVENTS_', DATE_PART('epoch', CURRENT_TIMESTAMP())::STRING), 'SI_BILLING_EVENTS_ETL', CURRENT_TIMESTAMP(), 'In Progress', 'BZ_BILLING_EVENTS', 'SI_BILLING_EVENTS', 'DBT_SILVER_PIPELINE', 'PRODUCTION', 'Bronze to Silver Billing Events transformation', CURRENT_DATE(), CURRENT_DATE(), 'SILVER_LAYER' WHERE '{{ this.name }}' != 'si_pipeline_audit'",
    post_hook="UPDATE {{ ref('si_pipeline_audit') }} SET END_TIME = CURRENT_TIMESTAMP(), STATUS = 'Success', EXECUTION_DURATION_SECONDS = DATEDIFF('second', START_TIME, CURRENT_TIMESTAMP()), RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), RECORDS_INSERTED = (SELECT COUNT(*) FROM {{ this }}) WHERE PIPELINE_NAME = 'SI_BILLING_EVENTS_ETL' AND STATUS = 'In Progress' AND '{{ this.name }}' != 'si_pipeline_audit'"
) }}

-- Silver Layer Billing Events Table
-- Validated billing and financial transaction data
-- Source: Bronze.BZ_BILLING_EVENTS
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

WITH bronze_billing_events AS (
    SELECT *
    FROM {{ source('bronze', 'bz_billing_events') }}
),

-- Data Quality Checks and Cleansing
cleansed_billing_events AS (
    SELECT
        -- Primary identifiers
        EVENT_ID,
        USER_ID,
        
        -- Event type standardization
        CASE 
            WHEN EVENT_TYPE IN ('Subscription', 'Upgrade', 'Downgrade', 'Refund') THEN EVENT_TYPE
            ELSE 'Subscription'
        END AS EVENT_TYPE,
        
        -- Transaction amount validation
        CASE 
            WHEN AMOUNT IS NULL OR AMOUNT < 0 THEN 0.00
            WHEN AMOUNT > 10000 THEN 10000.00  -- Cap at reasonable maximum
            ELSE AMOUNT
        END AS TRANSACTION_AMOUNT,
        
        -- Transaction date validation
        COALESCE(EVENT_DATE, CURRENT_DATE()) AS TRANSACTION_DATE,
        
        -- Payment method derivation
        CASE 
            WHEN AMOUNT >= 100 THEN 'Credit Card'
            WHEN AMOUNT >= 50 THEN 'Bank Transfer'
            ELSE 'PayPal'
        END AS PAYMENT_METHOD,
        
        -- Currency code standardization
        'USD' AS CURRENCY_CODE,
        
        -- Invoice number generation
        CONCAT('INV-', EVENT_ID, '-', TO_CHAR(COALESCE(EVENT_DATE, CURRENT_DATE()), 'YYYYMMDD')) AS INVOICE_NUMBER,
        
        -- Transaction status derivation
        CASE 
            WHEN AMOUNT IS NULL OR AMOUNT <= 0 THEN 'Failed'
            WHEN EVENT_TYPE = 'Refund' THEN 'Refunded'
            ELSE 'Completed'
        END AS TRANSACTION_STATUS,
        
        -- Metadata fields
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data quality score calculation
        CASE 
            WHEN EVENT_ID IS NOT NULL 
                AND USER_ID IS NOT NULL
                AND EVENT_TYPE IS NOT NULL
                AND AMOUNT IS NOT NULL AND AMOUNT > 0
                AND EVENT_DATE IS NOT NULL
                THEN 1.00
            WHEN EVENT_ID IS NOT NULL AND USER_ID IS NOT NULL AND EVENT_TYPE IS NOT NULL
                THEN 0.75
            WHEN EVENT_ID IS NOT NULL AND USER_ID IS NOT NULL
                THEN 0.50
            ELSE 0.25
        END AS DATA_QUALITY_SCORE,
        
        -- Standard metadata
        COALESCE(LOAD_TIMESTAMP::DATE, CURRENT_DATE()) AS LOAD_DATE,
        COALESCE(UPDATE_TIMESTAMP::DATE, CURRENT_DATE()) AS UPDATE_DATE
        
    FROM bronze_billing_events
    WHERE EVENT_ID IS NOT NULL  -- Block records without primary key
      AND USER_ID IS NOT NULL   -- Block events without user reference
),

-- Deduplication - keep latest record per event
deduped_billing_events AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY EVENT_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM cleansed_billing_events
)

-- Final selection with data quality validation
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
  AND DATA_QUALITY_SCORE >= 0.50  -- Minimum quality threshold
