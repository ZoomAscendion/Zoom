{{ config(
    materialized='table',
    pre_hook="
        INSERT INTO {{ ref('si_audit_log') }} (
            EXECUTION_ID, PIPELINE_NAME, EXECUTION_START_TIME, EXECUTION_STATUS, 
            SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP
        )
        VALUES (
            '{{ invocation_id }}', 
            'si_billing_events', 
            CURRENT_TIMESTAMP(), 
            'RUNNING', 
            'BRONZE.BZ_BILLING_EVENTS', 
            'SILVER.SI_BILLING_EVENTS', 
            'DBT_SILVER_PIPELINE', 
            CURRENT_TIMESTAMP()
        )",
    post_hook="
        UPDATE {{ ref('si_audit_log') }} 
        SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(),
            EXECUTION_STATUS = 'SUCCESS',
            RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}),
            RECORDS_SUCCESS = (SELECT COUNT(*) FROM {{ this }})
        WHERE EXECUTION_ID = '{{ invocation_id }}' 
        AND TARGET_TABLE = 'SILVER.SI_BILLING_EVENTS'"
) }}

-- Silver layer billing events table with amount validation
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

cleansed_billing_events AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        TRIM(UPPER(EVENT_TYPE)) AS EVENT_TYPE,
        CASE 
            WHEN AMOUNT < 0 THEN 0
            ELSE ROUND(AMOUNT, 2)
        END AS AMOUNT,  -- Ensure non-negative amounts and round to 2 decimals
        EVENT_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        ROW_NUMBER() OVER (PARTITION BY EVENT_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_billing_events
    WHERE AMOUNT IS NOT NULL
      AND EVENT_DATE <= CURRENT_DATE()  -- Remove future dates
      AND EVENT_TYPE IS NOT NULL
      AND LENGTH(TRIM(EVENT_TYPE)) > 0
),

validated_billing_events AS (
    SELECT 
        be.EVENT_ID,
        be.USER_ID,
        be.EVENT_TYPE,
        be.AMOUNT,
        be.EVENT_DATE,
        be.LOAD_TIMESTAMP,
        be.UPDATE_TIMESTAMP,
        be.SOURCE_SYSTEM,
        -- Additional Silver layer metadata
        DATE(be.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(be.UPDATE_TIMESTAMP) AS UPDATE_DATE,
        -- Data quality scoring
        CASE 
            WHEN be.AMOUNT >= 0 AND be.EVENT_DATE <= CURRENT_DATE() 
                 AND u.USER_ID IS NOT NULL THEN 100
            WHEN be.AMOUNT >= 0 AND be.EVENT_DATE <= CURRENT_DATE() THEN 80
            WHEN be.AMOUNT >= 0 THEN 60
            ELSE 40
        END AS DATA_QUALITY_SCORE,
        CASE 
            WHEN be.AMOUNT >= 0 AND be.EVENT_DATE <= CURRENT_DATE() 
                 AND u.USER_ID IS NOT NULL THEN 'PASSED'
            WHEN u.USER_ID IS NULL THEN 'FAILED'
            WHEN be.EVENT_DATE > CURRENT_DATE() THEN 'FAILED'
            WHEN be.AMOUNT < 0 THEN 'FAILED'
            ELSE 'WARNING'
        END AS VALIDATION_STATUS
    FROM cleansed_billing_events be
    LEFT JOIN {{ ref('si_users') }} u ON be.USER_ID = u.USER_ID
    WHERE be.rn = 1
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
FROM validated_billing_events
