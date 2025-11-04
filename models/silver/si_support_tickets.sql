{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, EXECUTED_BY, EXECUTION_ENVIRONMENT, DATA_LINEAGE_INFO, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT CONCAT('SILVER_SUPPORT_TICKETS_', DATE_PART('epoch', CURRENT_TIMESTAMP())::STRING), 'SI_SUPPORT_TICKETS_ETL', CURRENT_TIMESTAMP(), 'In Progress', 'BZ_SUPPORT_TICKETS', 'SI_SUPPORT_TICKETS', 'DBT_SILVER_PIPELINE', 'PRODUCTION', 'Bronze to Silver Support Tickets transformation', CURRENT_DATE(), CURRENT_DATE(), 'SILVER_LAYER' WHERE '{{ this.name }}' != 'si_pipeline_audit'",
    post_hook="UPDATE {{ ref('si_pipeline_audit') }} SET END_TIME = CURRENT_TIMESTAMP(), STATUS = 'Success', EXECUTION_DURATION_SECONDS = DATEDIFF('second', START_TIME, CURRENT_TIMESTAMP()), RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), RECORDS_INSERTED = (SELECT COUNT(*) FROM {{ this }}) WHERE PIPELINE_NAME = 'SI_SUPPORT_TICKETS_ETL' AND STATUS = 'In Progress' AND '{{ this.name }}' != 'si_pipeline_audit'"
) }}

-- Silver Layer Support Tickets Table
-- Standardized customer support ticket data with resolution metrics
-- Source: Bronze.BZ_SUPPORT_TICKETS
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

WITH bronze_support_tickets AS (
    SELECT *
    FROM {{ source('bronze', 'bz_support_tickets') }}
),

-- Data Quality Checks and Cleansing
cleansed_support_tickets AS (
    SELECT
        -- Primary identifiers
        TICKET_ID,
        USER_ID,
        
        -- Standardized ticket type
        CASE 
            WHEN UPPER(TICKET_TYPE) IN ('TECHNICAL', 'BUG REPORT') THEN 'Technical'
            WHEN UPPER(TICKET_TYPE) = 'BILLING' THEN 'Billing'
            WHEN UPPER(TICKET_TYPE) = 'FEATURE REQUEST' THEN 'Feature Request'
            ELSE 'Bug Report'
        END AS TICKET_TYPE,
        
        -- Priority level derivation
        CASE 
            WHEN UPPER(TICKET_TYPE) IN ('TECHNICAL', 'BUG REPORT') THEN 'High'
            WHEN UPPER(TICKET_TYPE) = 'BILLING' THEN 'Medium'
            WHEN UPPER(TICKET_TYPE) = 'FEATURE REQUEST' THEN 'Low'
            ELSE 'Medium'
        END AS PRIORITY_LEVEL,
        
        -- Date validation
        COALESCE(OPEN_DATE, CURRENT_DATE()) AS OPEN_DATE,
        
        -- Close date derivation
        CASE 
            WHEN UPPER(RESOLUTION_STATUS) IN ('RESOLVED', 'CLOSED') 
                THEN DATEADD('day', 
                    CASE 
                        WHEN UPPER(TICKET_TYPE) IN ('TECHNICAL', 'BUG REPORT') THEN 2
                        WHEN UPPER(TICKET_TYPE) = 'BILLING' THEN 5
                        ELSE 7
                    END, 
                    COALESCE(OPEN_DATE, CURRENT_DATE()))
            ELSE NULL
        END AS CLOSE_DATE,
        
        -- Resolution status standardization
        CASE 
            WHEN RESOLUTION_STATUS IN ('Open', 'In Progress', 'Resolved', 'Closed') THEN RESOLUTION_STATUS
            ELSE 'Open'
        END AS RESOLUTION_STATUS,
        
        -- Issue description derivation
        CASE 
            WHEN UPPER(TICKET_TYPE) = 'TECHNICAL' THEN 'Technical issue requiring support'
            WHEN UPPER(TICKET_TYPE) = 'BILLING' THEN 'Billing inquiry or payment issue'
            WHEN UPPER(TICKET_TYPE) = 'FEATURE REQUEST' THEN 'Request for new feature or enhancement'
            ELSE 'General support request'
        END AS ISSUE_DESCRIPTION,
        
        -- Resolution notes
        CASE 
            WHEN UPPER(RESOLUTION_STATUS) = 'RESOLVED' THEN 'Issue resolved successfully'
            WHEN UPPER(RESOLUTION_STATUS) = 'CLOSED' THEN 'Ticket closed by customer'
            WHEN UPPER(RESOLUTION_STATUS) = 'IN PROGRESS' THEN 'Currently being worked on'
            ELSE 'Awaiting customer response'
        END AS RESOLUTION_NOTES,
        
        -- Resolution time calculation
        CASE 
            WHEN UPPER(RESOLUTION_STATUS) IN ('RESOLVED', 'CLOSED') 
                THEN DATEDIFF('hour', 
                    COALESCE(OPEN_DATE, CURRENT_DATE()), 
                    DATEADD('day', 
                        CASE 
                            WHEN UPPER(TICKET_TYPE) IN ('TECHNICAL', 'BUG REPORT') THEN 2
                            WHEN UPPER(TICKET_TYPE) = 'BILLING' THEN 5
                            ELSE 7
                        END, 
                        COALESCE(OPEN_DATE, CURRENT_DATE())))
            ELSE NULL
        END AS RESOLUTION_TIME_HOURS,
        
        -- Metadata fields
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data quality score calculation
        CASE 
            WHEN TICKET_ID IS NOT NULL 
                AND USER_ID IS NOT NULL
                AND TICKET_TYPE IS NOT NULL
                AND RESOLUTION_STATUS IS NOT NULL
                AND OPEN_DATE IS NOT NULL
                THEN 1.00
            WHEN TICKET_ID IS NOT NULL AND USER_ID IS NOT NULL AND TICKET_TYPE IS NOT NULL
                THEN 0.75
            WHEN TICKET_ID IS NOT NULL AND USER_ID IS NOT NULL
                THEN 0.50
            ELSE 0.25
        END AS DATA_QUALITY_SCORE,
        
        -- Standard metadata
        COALESCE(LOAD_TIMESTAMP::DATE, CURRENT_DATE()) AS LOAD_DATE,
        COALESCE(UPDATE_TIMESTAMP::DATE, CURRENT_DATE()) AS UPDATE_DATE
        
    FROM bronze_support_tickets
    WHERE TICKET_ID IS NOT NULL  -- Block records without primary key
      AND USER_ID IS NOT NULL    -- Block tickets without user reference
),

-- Deduplication - keep latest record per ticket
deduped_support_tickets AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY TICKET_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM cleansed_support_tickets
)

-- Final selection with data quality validation
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
  AND DATA_QUALITY_SCORE >= 0.50  -- Minimum quality threshold
