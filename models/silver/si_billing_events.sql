{{ config(
    materialized='table',
    on_schema_change='sync_all_columns',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, EXECUTED_BY, EXECUTION_ENVIRONMENT, SOURCE_SYSTEM, LOAD_DATE, UPDATE_DATE) SELECT 'BILL_' || REPLACE(REPLACE(REPLACE(CURRENT_TIMESTAMP()::STRING, ' ', '_'), ':', ''), '.', '_'), 'Silver_Billing_Events_ETL', CURRENT_TIMESTAMP(), 'STARTED', 'DBT_SILVER_JOB', 'PRODUCTION', 'ZOOM_PLATFORM', CURRENT_DATE(), CURRENT_DATE()",
    post_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, END_TIME, STATUS, EXECUTION_DURATION_SECONDS, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, RECORDS_PROCESSED, RECORDS_INSERTED, RECORDS_UPDATED, RECORDS_REJECTED, EXECUTED_BY, EXECUTION_ENVIRONMENT, DATA_LINEAGE_INFO, SOURCE_SYSTEM, LOAD_DATE, UPDATE_DATE) SELECT 'BILL_' || REPLACE(REPLACE(REPLACE(CURRENT_TIMESTAMP()::STRING, ' ', '_'), ':', ''), '.', '_'), 'Silver_Billing_Events_ETL', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 'COMPLETED', 0, 'BZ_BILLING_EVENTS', 'SI_BILLING_EVENTS', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 0, 0, 'DBT_SILVER_JOB', 'PRODUCTION', 'Bronze to Silver Billing Events transformation', 'ZOOM_PLATFORM', CURRENT_DATE(), CURRENT_DATE()"
) }}

-- Silver Billing Events Table
-- Transforms Bronze billing events data with validations and enrichments

WITH bronze_billing_events AS (
    SELECT *
    FROM {{ source('bronze', 'bz_billing_events') }}
),

-- Data Quality Validations
validated_billing_events AS (
    SELECT
        be.*,
        -- Data Quality Flags
        CASE 
            WHEN be.EVENT_ID IS NULL THEN 'CRITICAL_NO_EVENT_ID'
            WHEN be.USER_ID IS NULL THEN 'CRITICAL_NO_USER_ID'
            WHEN be.EVENT_TYPE IS NULL THEN 'CRITICAL_NO_EVENT_TYPE'
            WHEN be.AMOUNT < 0 AND UPPER(be.EVENT_TYPE) != 'REFUND' THEN 'CRITICAL_NEGATIVE_AMOUNT'
            WHEN be.EVENT_DATE > CURRENT_DATE() + INTERVAL '1 DAY' THEN 'WARNING_FUTURE_DATE'
            ELSE 'VALID'
        END AS data_quality_flag,
        
        -- Row Number for Deduplication
        ROW_NUMBER() OVER (PARTITION BY be.EVENT_ID ORDER BY be.UPDATE_TIMESTAMP DESC, be.LOAD_TIMESTAMP DESC) AS rn
    FROM bronze_billing_events be
    WHERE be.EVENT_ID IS NOT NULL  -- Block records without EVENT_ID
      AND be.USER_ID IS NOT NULL   -- Block records without USER_ID
      AND be.EVENT_TYPE IS NOT NULL -- Block records without EVENT_TYPE
      AND (be.AMOUNT >= 0 OR UPPER(be.EVENT_TYPE) = 'REFUND') -- Allow negative amounts only for refunds
),

-- Apply Transformations
transformed_billing_events AS (
    SELECT
        -- Primary Keys
        vbe.EVENT_ID,
        vbe.USER_ID,
        
        -- Standardized Business Columns
        CASE 
            WHEN UPPER(vbe.EVENT_TYPE) IN ('SUBSCRIPTION', 'SUB') THEN 'Subscription'
            WHEN UPPER(vbe.EVENT_TYPE) IN ('UPGRADE', 'UP') THEN 'Upgrade'
            WHEN UPPER(vbe.EVENT_TYPE) IN ('DOWNGRADE', 'DOWN') THEN 'Downgrade'
            WHEN UPPER(vbe.EVENT_TYPE) IN ('REFUND', 'REF') THEN 'Refund'
            ELSE 'Other'
        END AS EVENT_TYPE,
        
        ABS(COALESCE(vbe.AMOUNT, 0)) AS TRANSACTION_AMOUNT,
        vbe.EVENT_DATE AS TRANSACTION_DATE,
        
        -- Derived Columns
        CASE 
            WHEN vbe.AMOUNT <= 20 THEN 'Credit Card'
            WHEN vbe.AMOUNT <= 100 THEN 'Bank Transfer'
            ELSE 'PayPal'
        END AS PAYMENT_METHOD,
        
        'USD' AS CURRENCY_CODE,
        
        CONCAT('INV-', vbe.EVENT_ID, '-', TO_CHAR(vbe.EVENT_DATE, 'YYYYMMDD')) AS INVOICE_NUMBER,
        
        CASE 
            WHEN vbe.AMOUNT > 0 THEN 'Completed'
            WHEN vbe.AMOUNT = 0 THEN 'Pending'
            ELSE 'Refunded'
        END AS TRANSACTION_STATUS,
        
        -- Metadata Columns
        vbe.LOAD_TIMESTAMP,
        vbe.UPDATE_TIMESTAMP,
        vbe.SOURCE_SYSTEM,
        
        -- Data Quality Score
        CASE 
            WHEN vbe.data_quality_flag = 'VALID' THEN 1.00
            WHEN vbe.data_quality_flag LIKE 'WARNING%' THEN 0.80
            ELSE 0.60
        END AS DATA_QUALITY_SCORE,
        
        -- Standard Metadata
        DATE(vbe.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(vbe.UPDATE_TIMESTAMP) AS UPDATE_DATE
        
    FROM validated_billing_events vbe
    WHERE vbe.rn = 1  -- Keep only the latest record for each EVENT_ID
      AND vbe.data_quality_flag NOT LIKE 'CRITICAL%'
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
FROM transformed_billing_events
