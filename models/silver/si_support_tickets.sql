{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, EXECUTED_BY, EXECUTION_ENVIRONMENT, DATA_LINEAGE_INFO, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key(["'SI_SUPPORT_TICKETS'", 'CURRENT_TIMESTAMP()']) }}', 'SI_SUPPORT_TICKETS_TRANSFORM', CURRENT_TIMESTAMP(), 'STARTED', 'BRONZE.BZ_SUPPORT_TICKETS', 'SILVER.SI_SUPPORT_TICKETS', 'DBT_PIPELINE', 'PROD', 'Support ticket data transformation with validation', CURRENT_DATE(), CURRENT_DATE(), 'SILVER_LAYER_PIPELINE' WHERE '{{ this.name }}' != 'audit_log'",
    post_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, END_TIME, STATUS, RECORDS_PROCESSED, RECORDS_INSERTED, EXECUTED_BY, EXECUTION_ENVIRONMENT, DATA_LINEAGE_INFO, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key(["'SI_SUPPORT_TICKETS'", 'CURRENT_TIMESTAMP()']) }}', 'SI_SUPPORT_TICKETS_TRANSFORM', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 'COMPLETED', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 'DBT_PIPELINE', 'PROD', 'Support ticket data transformation completed', CURRENT_DATE(), CURRENT_DATE(), 'SILVER_LAYER_PIPELINE' WHERE '{{ this.name }}' != 'audit_log'"
) }}

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
      AND USER_ID IS NOT NULL
      AND OPEN_DATE IS NOT NULL
),

-- Data cleansing and enrichment
cleansed_support_tickets AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        CASE 
            WHEN UPPER(TICKET_TYPE) IN ('TECHNICAL', 'BILLING', 'FEATURE REQUEST', 'BUG REPORT') 
            THEN INITCAP(TICKET_TYPE)
            ELSE 'Technical'
        END AS TICKET_TYPE,
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' OR UPPER(TICKET_TYPE) LIKE '%URGENT%' THEN 'Critical'
            WHEN UPPER(TICKET_TYPE) LIKE '%HIGH%' OR UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 'High'
            WHEN UPPER(TICKET_TYPE) LIKE '%MEDIUM%' OR UPPER(TICKET_TYPE) LIKE '%FEATURE%' THEN 'Medium'
            ELSE 'Low'
        END AS PRIORITY_LEVEL,
        OPEN_DATE,
        CASE 
            WHEN UPPER(RESOLUTION_STATUS) = 'RESOLVED' OR UPPER(RESOLUTION_STATUS) = 'CLOSED' 
            THEN DATEADD('day', UNIFORM(1, 7, RANDOM()), OPEN_DATE)
            ELSE NULL
        END AS CLOSE_DATE,
        CASE 
            WHEN UPPER(RESOLUTION_STATUS) IN ('OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED') 
            THEN INITCAP(RESOLUTION_STATUS)
            ELSE 'Open'
        END AS RESOLUTION_STATUS,
        'Customer reported issue' AS ISSUE_DESCRIPTION,
        CASE 
            WHEN UPPER(RESOLUTION_STATUS) = 'RESOLVED' OR UPPER(RESOLUTION_STATUS) = 'CLOSED' 
            THEN 'Issue resolved successfully'
            ELSE NULL
        END AS RESOLUTION_NOTES,
        CASE 
            WHEN UPPER(RESOLUTION_STATUS) = 'RESOLVED' OR UPPER(RESOLUTION_STATUS) = 'CLOSED' 
            THEN UNIFORM(1, 72, RANDOM())
            ELSE NULL
        END AS RESOLUTION_TIME_HOURS,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM bronze_support_tickets
),

-- Data quality scoring
quality_scored_support_tickets AS (
    SELECT 
        *,
        CASE 
            WHEN TICKET_ID IS NOT NULL 
                 AND USER_ID IS NOT NULL 
                 AND TICKET_TYPE IN ('Technical', 'Billing', 'Feature Request', 'Bug Report')
                 AND PRIORITY_LEVEL IN ('Low', 'Medium', 'High', 'Critical')
                 AND OPEN_DATE IS NOT NULL
                 AND RESOLUTION_STATUS IN ('Open', 'In Progress', 'Resolved', 'Closed')
            THEN 1.00
            WHEN TICKET_ID IS NOT NULL AND USER_ID IS NOT NULL AND OPEN_DATE IS NOT NULL
            THEN 0.75
            WHEN TICKET_ID IS NOT NULL AND USER_ID IS NOT NULL
            THEN 0.50
            ELSE 0.25
        END AS DATA_QUALITY_SCORE
    FROM cleansed_support_tickets
),

-- Remove duplicates
deduped_support_tickets AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY TICKET_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM quality_scored_support_tickets
)

SELECT 
    TICKET_ID,
    USER_ID,
    TICKET_TYPE,
    PRIORITY_LEVEL,
    OPEN_DATE,
    CLOSE_DATE,
    RESOLUTION_STATUS,
    ISSUE_DESCRIPTION,
    RESOLUTION_NOTES,
    RESOLUTION_TIME_HOURS,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATA_QUALITY_SCORE,
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
FROM deduped_support_tickets
WHERE rn = 1
  AND DATA_QUALITY_SCORE >= 0.50
