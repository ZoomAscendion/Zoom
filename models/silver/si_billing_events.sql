{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, EXECUTED_BY, EXECUTION_ENVIRONMENT, DATA_LINEAGE_INFO, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT CONCAT('EXEC_', TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), '_BIL'), 'Silver_Billing_Events_ETL', CURRENT_TIMESTAMP(), 'Started', 'BRONZE.BZ_BILLING_EVENTS', 'SILVER.SI_BILLING_EVENTS', 'DBT_SILVER_PIPELINE', 'PRODUCTION', 'Processing billing events data from Bronze to Silver', CURRENT_DATE(), CURRENT_DATE(), 'ZOOM_PLATFORM' WHERE '{{ this.name }}' != 'si_pipeline_audit'",
    post_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (EXECUTION_ID, PIPELINE_NAME, END_TIME, STATUS, RECORDS_PROCESSED, RECORDS_INSERTED, EXECUTED_BY, EXECUTION_ENVIRONMENT, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT CONCAT('EXEC_', TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), '_BIL_END'), 'Silver_Billing_Events_ETL', CURRENT_TIMESTAMP(), 'Completed', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 'DBT_SILVER_PIPELINE', 'PRODUCTION', CURRENT_DATE(), CURRENT_DATE(), 'ZOOM_PLATFORM' WHERE '{{ this.name }}' != 'si_pipeline_audit'"
) }}

-- Silver Billing Events Table Transformation
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

validated_billing_events AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        
        CASE 
            WHEN EVENT_TYPE IN ('Subscription', 'Upgrade', 'Downgrade', 'Refund') THEN EVENT_TYPE
            ELSE 'Other'
        END AS EVENT_TYPE,
        
        CASE 
            WHEN AMOUNT < 0 AND EVENT_TYPE != 'Refund' THEN ABS(AMOUNT)
            WHEN AMOUNT IS NULL THEN 0.00
            ELSE AMOUNT
        END AS TRANSACTION_AMOUNT,
        
        CASE 
            WHEN EVENT_DATE > CURRENT_DATE() THEN CURRENT_DATE()
            ELSE EVENT_DATE
        END AS TRANSACTION_DATE,
        
        CASE 
            WHEN AMOUNT >= 1000 THEN 'Bank Transfer'
            WHEN AMOUNT >= 100 THEN 'Credit Card'
            ELSE 'PayPal'
        END AS PAYMENT_METHOD,
        
        'USD' AS CURRENCY_CODE,
        
        CONCAT('INV-', EVENT_ID) AS INVOICE_NUMBER,
        
        CASE 
            WHEN AMOUNT > 0 THEN 'Completed'
            WHEN AMOUNT < 0 THEN 'Refunded'
            ELSE 'Pending'
        END AS TRANSACTION_STATUS,
        
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        (
            CASE WHEN EVENT_ID IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN USER_ID IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN EVENT_TYPE IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN AMOUNT IS NOT NULL THEN 0.25 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
        
    FROM bronze_billing_events
),

deduped_billing_events AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY EVENT_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM validated_billing_events
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
FROM deduped_billing_events
WHERE rn = 1
  AND TRANSACTION_AMOUNT >= 0
  AND DATA_QUALITY_SCORE >= 0.75
