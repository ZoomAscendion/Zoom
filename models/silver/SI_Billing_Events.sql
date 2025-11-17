{{ config(
    materialized='table',
    pre_hook="INSERT INTO SILVER.SI_AUDIT_LOG (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_BILLING_EVENTS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'RUNNING', 'BZ_BILLING_EVENTS', 'SI_BILLING_EVENTS', 'DBT_PIPELINE', CURRENT_TIMESTAMP()",
    post_hook="UPDATE SILVER.SI_AUDIT_LOG SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(), EXECUTION_STATUS = 'SUCCESS', RECORDS_SUCCESS = (SELECT COUNT(*) FROM SILVER.SI_BILLING_EVENTS), UPDATE_TIMESTAMP = CURRENT_TIMESTAMP() WHERE PIPELINE_NAME = 'BRONZE_TO_SILVER_BILLING_EVENTS' AND EXECUTION_STATUS = 'RUNNING'"
) }}

-- Silver Layer Billing Events Table
-- Transforms and cleanses billing event data from Bronze layer
-- Applies data quality checks and business rules

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
    FROM BRONZE.BZ_BILLING_EVENTS
),

cleansed_billing_events AS (
    SELECT 
        bbe.EVENT_ID,
        bbe.USER_ID,
        UPPER(TRIM(bbe.EVENT_TYPE)) AS EVENT_TYPE,
        ROUND(bbe.AMOUNT, 2) AS AMOUNT,
        bbe.EVENT_DATE,
        bbe.LOAD_TIMESTAMP,
        bbe.UPDATE_TIMESTAMP,
        bbe.SOURCE_SYSTEM,
        
        -- Additional Silver layer metadata
        DATE(bbe.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(bbe.UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM bronze_billing_events bbe
    INNER JOIN SILVER.SI_USERS su ON bbe.USER_ID = su.USER_ID
    WHERE bbe.EVENT_ID IS NOT NULL
        AND bbe.USER_ID IS NOT NULL
        AND bbe.EVENT_TYPE IS NOT NULL
        AND bbe.AMOUNT IS NOT NULL
        AND bbe.AMOUNT > 0
        AND bbe.EVENT_DATE IS NOT NULL
        AND bbe.EVENT_DATE <= CURRENT_DATE()
),

data_quality_scored AS (
    SELECT 
        *,
        -- Calculate data quality score
        CASE 
            WHEN EVENT_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND EVENT_TYPE IS NOT NULL 
                AND AMOUNT IS NOT NULL 
                AND AMOUNT > 0
                AND EVENT_DATE IS NOT NULL 
                AND EVENT_DATE <= CURRENT_DATE()
                AND LENGTH(EVENT_TYPE) <= 100
            THEN 100
            WHEN EVENT_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND EVENT_TYPE IS NOT NULL 
                AND AMOUNT > 0
            THEN 75
            WHEN EVENT_ID IS NOT NULL 
                AND USER_ID IS NOT NULL
            THEN 50
            ELSE 25
        END AS DATA_QUALITY_SCORE,
        
        -- Set validation status
        CASE 
            WHEN EVENT_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND EVENT_TYPE IS NOT NULL 
                AND AMOUNT IS NOT NULL 
                AND AMOUNT > 0
                AND EVENT_DATE IS NOT NULL 
                AND EVENT_DATE <= CURRENT_DATE()
                AND LENGTH(EVENT_TYPE) <= 100
            THEN 'PASSED'
            WHEN EVENT_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND EVENT_TYPE IS NOT NULL
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM cleansed_billing_events
),

-- Remove duplicates keeping the latest record
deduped_billing_events AS (
    SELECT *
    FROM (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY EVENT_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) as rn
        FROM data_quality_scored
    ) ranked
    WHERE rn = 1
)

SELECT 
    EVENT_ID,
    USER_ID,
    EVENT_TYPE,
    AMOUNT,
    EVENT_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    LOAD_DATE,
    UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_billing_events
WHERE VALIDATION_STATUS IN ('PASSED', 'WARNING')
