{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, EXECUTED_BY, EXECUTION_ENVIRONMENT, DATA_LINEAGE_INFO, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT CONCAT('EXEC_', TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), '_TKT'), 'Silver_Support_Tickets_ETL', CURRENT_TIMESTAMP(), 'Started', 'BRONZE.BZ_SUPPORT_TICKETS', 'SILVER.SI_SUPPORT_TICKETS', 'DBT_SILVER_PIPELINE', 'PRODUCTION', 'Processing support tickets data from Bronze to Silver', CURRENT_DATE(), CURRENT_DATE(), 'ZOOM_PLATFORM' WHERE '{{ this.name }}' != 'si_pipeline_audit'",
    post_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (EXECUTION_ID, PIPELINE_NAME, END_TIME, STATUS, RECORDS_PROCESSED, RECORDS_INSERTED, EXECUTED_BY, EXECUTION_ENVIRONMENT, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT CONCAT('EXEC_', TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), '_TKT_END'), 'Silver_Support_Tickets_ETL', CURRENT_TIMESTAMP(), 'Completed', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 'DBT_SILVER_PIPELINE', 'PRODUCTION', CURRENT_DATE(), CURRENT_DATE(), 'ZOOM_PLATFORM' WHERE '{{ this.name }}' != 'si_pipeline_audit'"
) }}

-- Silver Support Tickets Table Transformation
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
),

validated_support_tickets AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        
        CASE 
            WHEN TICKET_TYPE IN ('Technical', 'Billing', 'Feature Request', 'Bug Report') THEN TICKET_TYPE
            ELSE 'General Inquiry'
        END AS TICKET_TYPE,
        
        CASE 
            WHEN TICKET_TYPE = 'Bug Report' THEN 'Critical'
            WHEN TICKET_TYPE = 'Technical' THEN 'High'
            WHEN TICKET_TYPE = 'Billing' THEN 'Medium'
            ELSE 'Low'
        END AS PRIORITY_LEVEL,
        
        CASE 
            WHEN OPEN_DATE > CURRENT_DATE() THEN CURRENT_DATE()
            ELSE OPEN_DATE
        END AS OPEN_DATE,
        
        CASE 
            WHEN RESOLUTION_STATUS = 'Resolved' OR RESOLUTION_STATUS = 'Closed' THEN DATEADD('day', 3, OPEN_DATE)
            ELSE NULL
        END AS CLOSE_DATE,
        
        CASE 
            WHEN RESOLUTION_STATUS IN ('Open', 'In Progress', 'Resolved', 'Closed') THEN RESOLUTION_STATUS
            ELSE 'Open'
        END AS RESOLUTION_STATUS,
        
        CASE 
            WHEN TICKET_TYPE = 'Technical' THEN 'Technical issue reported by user'
            WHEN TICKET_TYPE = 'Billing' THEN 'Billing inquiry or dispute'
            WHEN TICKET_TYPE = 'Feature Request' THEN 'User requested new feature'
            WHEN TICKET_TYPE = 'Bug Report' THEN 'Bug or system error reported'
            ELSE 'General customer inquiry'
        END AS ISSUE_DESCRIPTION,
        
        CASE 
            WHEN RESOLUTION_STATUS = 'Resolved' THEN 'Issue resolved successfully'
            WHEN RESOLUTION_STATUS = 'Closed' THEN 'Ticket closed'
            ELSE 'Resolution in progress'
        END AS RESOLUTION_NOTES,
        
        CASE 
            WHEN RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN 
                DATEDIFF('hour', OPEN_DATE, DATEADD('day', 3, OPEN_DATE))
            ELSE NULL
        END AS RESOLUTION_TIME_HOURS,
        
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        (
            CASE WHEN TICKET_ID IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN USER_ID IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN TICKET_TYPE IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN OPEN_DATE IS NOT NULL THEN 0.25 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
        
    FROM bronze_support_tickets
),

deduped_support_tickets AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY TICKET_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM validated_support_tickets
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
    LOAD_DATE,
    UPDATE_DATE
FROM deduped_support_tickets
WHERE rn = 1
  AND OPEN_DATE IS NOT NULL
  AND DATA_QUALITY_SCORE >= 0.75
