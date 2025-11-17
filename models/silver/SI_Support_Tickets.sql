{{ config(
    materialized='table',
    pre_hook="INSERT INTO SILVER.SI_AUDIT_LOG (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_SUPPORT_TICKETS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'RUNNING', 'BZ_SUPPORT_TICKETS', 'SI_SUPPORT_TICKETS', 'DBT_PIPELINE', CURRENT_TIMESTAMP()",
    post_hook="UPDATE SILVER.SI_AUDIT_LOG SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(), EXECUTION_STATUS = 'SUCCESS', RECORDS_SUCCESS = (SELECT COUNT(*) FROM SILVER.SI_SUPPORT_TICKETS), UPDATE_TIMESTAMP = CURRENT_TIMESTAMP() WHERE PIPELINE_NAME = 'BRONZE_TO_SILVER_SUPPORT_TICKETS' AND EXECUTION_STATUS = 'RUNNING'"
) }}

-- Silver Layer Support Tickets Table
-- Transforms and cleanses support ticket data from Bronze layer
-- Applies data quality checks and business rules

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
    FROM BRONZE.BZ_SUPPORT_TICKETS
),

cleansed_support_tickets AS (
    SELECT 
        bst.TICKET_ID,
        bst.USER_ID,
        UPPER(TRIM(bst.TICKET_TYPE)) AS TICKET_TYPE,
        CASE 
            WHEN UPPER(TRIM(bst.RESOLUTION_STATUS)) IN ('OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED') 
            THEN UPPER(TRIM(bst.RESOLUTION_STATUS))
            ELSE 'OPEN'
        END AS RESOLUTION_STATUS,
        bst.OPEN_DATE,
        bst.LOAD_TIMESTAMP,
        bst.UPDATE_TIMESTAMP,
        bst.SOURCE_SYSTEM,
        
        -- Additional Silver layer metadata
        DATE(bst.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(bst.UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM bronze_support_tickets bst
    INNER JOIN SILVER.SI_USERS su ON bst.USER_ID = su.USER_ID
    WHERE bst.TICKET_ID IS NOT NULL
        AND bst.USER_ID IS NOT NULL
        AND bst.TICKET_TYPE IS NOT NULL
        AND bst.RESOLUTION_STATUS IS NOT NULL
        AND bst.OPEN_DATE IS NOT NULL
        AND bst.OPEN_DATE <= CURRENT_DATE()
),

data_quality_scored AS (
    SELECT 
        *,
        -- Calculate data quality score
        CASE 
            WHEN TICKET_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND TICKET_TYPE IS NOT NULL 
                AND RESOLUTION_STATUS IN ('OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED')
                AND OPEN_DATE IS NOT NULL 
                AND OPEN_DATE <= CURRENT_DATE()
                AND LENGTH(TICKET_TYPE) <= 100
            THEN 100
            WHEN TICKET_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND TICKET_TYPE IS NOT NULL 
                AND RESOLUTION_STATUS IS NOT NULL
            THEN 75
            WHEN TICKET_ID IS NOT NULL 
                AND USER_ID IS NOT NULL
            THEN 50
            ELSE 25
        END AS DATA_QUALITY_SCORE,
        
        -- Set validation status
        CASE 
            WHEN TICKET_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND TICKET_TYPE IS NOT NULL 
                AND RESOLUTION_STATUS IN ('OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED')
                AND OPEN_DATE IS NOT NULL 
                AND OPEN_DATE <= CURRENT_DATE()
                AND LENGTH(TICKET_TYPE) <= 100
            THEN 'PASSED'
            WHEN TICKET_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND TICKET_TYPE IS NOT NULL
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM cleansed_support_tickets
),

-- Remove duplicates keeping the latest record
deduped_support_tickets AS (
    SELECT *
    FROM (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY TICKET_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) as rn
        FROM data_quality_scored
    ) ranked
    WHERE rn = 1
)

SELECT 
    TICKET_ID,
    USER_ID,
    TICKET_TYPE,
    RESOLUTION_STATUS,
    OPEN_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    LOAD_DATE,
    UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_support_tickets
WHERE VALIDATION_STATUS IN ('PASSED', 'WARNING')
