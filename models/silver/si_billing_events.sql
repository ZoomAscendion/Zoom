{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (AUDIT_ID, PIPELINE_NAME, PIPELINE_RUN_ID, SOURCE_TABLE, TARGET_TABLE, EXECUTION_START_TIME, PROCESSED_BY, PROCESSING_MODE, EXECUTION_STATUS, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_BILLING_EVENTS', UUID_STRING(), 'BZ_BILLING_EVENTS', 'SI_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 'INCREMENTAL', 'STARTED', CURRENT_DATE(), CURRENT_DATE(), 'SILVER_ETL_PROCESS' WHERE '{{ this.name }}' != 'si_pipeline_audit'",
    post_hook="UPDATE {{ ref('si_pipeline_audit') }} SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(), EXECUTION_DURATION_SECONDS = DATEDIFF('second', EXECUTION_START_TIME, CURRENT_TIMESTAMP()), EXECUTION_STATUS = 'SUCCESS', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), RECORDS_INSERTED = (SELECT COUNT(*) FROM {{ this }}) WHERE TARGET_TABLE = 'SI_BILLING_EVENTS' AND EXECUTION_STATUS = 'STARTED' AND DATE(EXECUTION_START_TIME) = CURRENT_DATE() AND '{{ this.name }}' != 'si_pipeline_audit'"
) }}

-- Billing events transformation with data quality checks
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
      AND TRIM(EVENT_ID) != ''
      AND AMOUNT > 0
),

validated_billing_events AS (
    SELECT 
        bbe.EVENT_ID,
        bbe.USER_ID,
        -- Validate event type
        CASE 
            WHEN UPPER(TRIM(bbe.EVENT_TYPE)) IN ('SUBSCRIPTION', 'UPGRADE', 'DOWNGRADE', 'REFUND', 'CHARGEBACK', 'PAYMENT')
            THEN UPPER(TRIM(bbe.EVENT_TYPE))
            ELSE 'PAYMENT'
        END AS EVENT_TYPE,
        bbe.AMOUNT,
        bbe.EVENT_DATE,
        'USD' AS CURRENCY_CODE,  -- Default currency
        DATE(bbe.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(bbe.UPDATE_TIMESTAMP) AS UPDATE_DATE,
        bbe.SOURCE_SYSTEM,
        bbe.LOAD_TIMESTAMP,
        bbe.UPDATE_TIMESTAMP,
        ROW_NUMBER() OVER (PARTITION BY bbe.EVENT_ID ORDER BY bbe.UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_billing_events bbe
    INNER JOIN {{ ref('si_users') }} u ON bbe.USER_ID = u.USER_ID
    WHERE bbe.EVENT_DATE >= '2020-01-01'
      AND bbe.EVENT_DATE <= DATEADD('day', 30, CURRENT_DATE())
),

deduped_billing_events AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        EVENT_TYPE,
        AMOUNT,
        EVENT_DATE,
        CURRENCY_CODE,
        LOAD_DATE,
        UPDATE_DATE,
        SOURCE_SYSTEM,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP
    FROM validated_billing_events
    WHERE rn = 1
)

SELECT 
    EVENT_ID,
    USER_ID,
    EVENT_TYPE,
    AMOUNT,
    EVENT_DATE,
    CURRENCY_CODE,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP
FROM deduped_billing_events
