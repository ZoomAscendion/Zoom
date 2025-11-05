{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (AUDIT_ID, PIPELINE_NAME, PIPELINE_RUN_ID, SOURCE_TABLE, TARGET_TABLE, EXECUTION_START_TIME, PROCESSED_BY, PROCESSING_MODE, EXECUTION_STATUS, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_SUPPORT_TICKETS', UUID_STRING(), 'BZ_SUPPORT_TICKETS', 'SI_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 'INCREMENTAL', 'STARTED', CURRENT_DATE(), CURRENT_DATE(), 'SILVER_ETL_PROCESS' WHERE '{{ this.name }}' != 'si_pipeline_audit'",
    post_hook="UPDATE {{ ref('si_pipeline_audit') }} SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(), EXECUTION_DURATION_SECONDS = DATEDIFF('second', EXECUTION_START_TIME, CURRENT_TIMESTAMP()), EXECUTION_STATUS = 'SUCCESS', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), RECORDS_INSERTED = (SELECT COUNT(*) FROM {{ this }}) WHERE TARGET_TABLE = 'SI_SUPPORT_TICKETS' AND EXECUTION_STATUS = 'STARTED' AND DATE(EXECUTION_START_TIME) = CURRENT_DATE() AND '{{ this.name }}' != 'si_pipeline_audit'"
) }}

-- Support tickets transformation with data quality checks
WITH bronze_support_tickets AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        TICKET_TYPE,
        RESOLUTION_STATUS,
        OPEN_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('bronze', 'bz_support_tickets') }}
    WHERE TICKET_ID IS NOT NULL 
      AND TRIM(TICKET_ID) != ''
),

validated_support_tickets AS (
    SELECT 
        bst.TICKET_ID,
        bst.USER_ID,
        -- Validate ticket type
        CASE 
            WHEN UPPER(TRIM(bst.TICKET_TYPE)) IN ('TECHNICAL', 'BILLING', 'FEATURE_REQUEST', 'ACCOUNT', 'GENERAL')
            THEN UPPER(TRIM(bst.TICKET_TYPE))
            ELSE 'GENERAL'
        END AS TICKET_TYPE,
        -- Validate resolution status
        CASE 
            WHEN UPPER(TRIM(bst.RESOLUTION_STATUS)) IN ('OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED')
            THEN UPPER(TRIM(bst.RESOLUTION_STATUS))
            ELSE 'OPEN'
        END AS RESOLUTION_STATUS,
        bst.OPEN_DATE,
        -- Calculate resolution time for closed tickets
        CASE 
            WHEN UPPER(TRIM(bst.RESOLUTION_STATUS)) IN ('RESOLVED', 'CLOSED')
            THEN DATEDIFF('hour', bst.OPEN_DATE, CURRENT_DATE())
            ELSE NULL
        END AS RESOLUTION_TIME_HOURS,
        DATE(bst.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(bst.UPDATE_TIMESTAMP) AS UPDATE_DATE,
        bst.SOURCE_SYSTEM,
        bst.LOAD_TIMESTAMP,
        bst.UPDATE_TIMESTAMP,
        ROW_NUMBER() OVER (PARTITION BY bst.TICKET_ID ORDER BY bst.UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_support_tickets bst
    INNER JOIN {{ ref('si_users') }} u ON bst.USER_ID = u.USER_ID
    WHERE bst.OPEN_DATE >= '2020-01-01'
      AND bst.OPEN_DATE <= CURRENT_DATE()
),

deduped_support_tickets AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        TICKET_TYPE,
        RESOLUTION_STATUS,
        OPEN_DATE,
        RESOLUTION_TIME_HOURS,
        LOAD_DATE,
        UPDATE_DATE,
        SOURCE_SYSTEM,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP
    FROM validated_support_tickets
    WHERE rn = 1
)

SELECT 
    TICKET_ID,
    USER_ID,
    TICKET_TYPE,
    RESOLUTION_STATUS,
    OPEN_DATE,
    RESOLUTION_TIME_HOURS,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP
FROM deduped_support_tickets
