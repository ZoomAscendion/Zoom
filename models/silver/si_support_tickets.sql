{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, EXECUTED_BY, EXECUTION_ENVIRONMENT, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key(["'SI_SUPPORT_TICKETS'", 'CURRENT_TIMESTAMP()']) }}', 'SI_SUPPORT_TICKETS_TRANSFORMATION', CURRENT_TIMESTAMP(), 'STARTED', 'DBT_SYSTEM', 'PROD', 'BZ_SUPPORT_TICKETS', 'SI_SUPPORT_TICKETS', CURRENT_DATE(), CURRENT_DATE(), 'Silver Layer Pipeline' WHERE '{{ this.name }}' != 'audit_log'",
    post_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, END_TIME, STATUS, EXECUTED_BY, EXECUTION_ENVIRONMENT, RECORDS_PROCESSED, RECORDS_INSERTED, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key(["'SI_SUPPORT_TICKETS'", 'CURRENT_TIMESTAMP()']) }}', 'SI_SUPPORT_TICKETS_TRANSFORMATION', CURRENT_TIMESTAMP(), 'SUCCESS', 'DBT_SYSTEM', 'PROD', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), CURRENT_DATE(), CURRENT_DATE(), 'Silver Layer Pipeline' WHERE '{{ this.name }}' != 'audit_log'"
) }}

-- Silver Layer Support Tickets Table
-- Transforms support ticket data with resolution metrics and priority assignments

WITH bronze_support_tickets AS (
    SELECT 
        bst.TICKET_ID,
        bst.USER_ID,
        bst.TICKET_TYPE,
        bst.RESOLUTION_STATUS,
        bst.OPEN_DATE,
        bst.LOAD_TIMESTAMP,
        bst.UPDATE_TIMESTAMP,
        bst.SOURCE_SYSTEM
    FROM {{ source('bronze', 'bz_support_tickets') }} bst
    WHERE bst.TICKET_ID IS NOT NULL
      AND bst.USER_ID IS NOT NULL
      AND bst.OPEN_DATE IS NOT NULL
),

-- Data Quality and Cleansing Layer
cleansed_support_tickets AS (
    SELECT 
        -- Primary Keys
        TRIM(bst.TICKET_ID) AS TICKET_ID,
        TRIM(bst.USER_ID) AS USER_ID,
        
        -- Standardized Ticket Type
        CASE 
            WHEN UPPER(bst.TICKET_TYPE) LIKE '%TECHNICAL%' OR UPPER(bst.TICKET_TYPE) LIKE '%TECH%' THEN 'Technical'
            WHEN UPPER(bst.TICKET_TYPE) LIKE '%BILLING%' OR UPPER(bst.TICKET_TYPE) LIKE '%PAYMENT%' THEN 'Billing'
            WHEN UPPER(bst.TICKET_TYPE) LIKE '%FEATURE%' OR UPPER(bst.TICKET_TYPE) LIKE '%REQUEST%' THEN 'Feature Request'
            WHEN UPPER(bst.TICKET_TYPE) LIKE '%BUG%' OR UPPER(bst.TICKET_TYPE) LIKE '%ERROR%' THEN 'Bug Report'
            ELSE 'Technical'  -- Default category
        END AS TICKET_TYPE,
        
        -- Derive Priority Level based on ticket type and keywords
        CASE 
            WHEN UPPER(bst.TICKET_TYPE) LIKE '%CRITICAL%' OR UPPER(bst.TICKET_TYPE) LIKE '%URGENT%' THEN 'Critical'
            WHEN UPPER(bst.TICKET_TYPE) LIKE '%HIGH%' OR UPPER(bst.TICKET_TYPE) LIKE '%BILLING%' THEN 'High'
            WHEN UPPER(bst.TICKET_TYPE) LIKE '%MEDIUM%' OR UPPER(bst.TICKET_TYPE) LIKE '%TECHNICAL%' THEN 'Medium'
            ELSE 'Low'
        END AS PRIORITY_LEVEL,
        
        bst.OPEN_DATE,
        
        -- Derive Close Date based on resolution status
        CASE 
            WHEN UPPER(bst.RESOLUTION_STATUS) IN ('RESOLVED', 'CLOSED') 
            THEN DATEADD('day', 
                CASE 
                    WHEN UPPER(bst.TICKET_TYPE) LIKE '%CRITICAL%' THEN 1
                    WHEN UPPER(bst.TICKET_TYPE) LIKE '%HIGH%' THEN 3
                    WHEN UPPER(bst.TICKET_TYPE) LIKE '%MEDIUM%' THEN 7
                    ELSE 14
                END, bst.OPEN_DATE)
            ELSE NULL
        END AS CLOSE_DATE,
        
        -- Standardized Resolution Status
        CASE 
            WHEN UPPER(bst.RESOLUTION_STATUS) LIKE '%OPEN%' THEN 'Open'
            WHEN UPPER(bst.RESOLUTION_STATUS) LIKE '%PROGRESS%' OR UPPER(bst.RESOLUTION_STATUS) LIKE '%WORKING%' THEN 'In Progress'
            WHEN UPPER(bst.RESOLUTION_STATUS) LIKE '%RESOLVED%' THEN 'Resolved'
            WHEN UPPER(bst.RESOLUTION_STATUS) LIKE '%CLOSED%' THEN 'Closed'
            ELSE 'Open'  -- Default status
        END AS RESOLUTION_STATUS,
        
        -- Placeholder for Issue Description (not in bronze)
        'Issue description not available in bronze layer' AS ISSUE_DESCRIPTION,
        
        -- Placeholder for Resolution Notes (not in bronze)
        CASE 
            WHEN UPPER(bst.RESOLUTION_STATUS) IN ('RESOLVED', 'CLOSED') 
            THEN 'Ticket resolved successfully'
            ELSE NULL
        END AS RESOLUTION_NOTES,
        
        -- Calculate Resolution Time in Hours
        CASE 
            WHEN UPPER(bst.RESOLUTION_STATUS) IN ('RESOLVED', 'CLOSED') 
            THEN DATEDIFF('hour', bst.OPEN_DATE, 
                DATEADD('day', 
                    CASE 
                        WHEN UPPER(bst.TICKET_TYPE) LIKE '%CRITICAL%' THEN 1
                        WHEN UPPER(bst.TICKET_TYPE) LIKE '%HIGH%' THEN 3
                        WHEN UPPER(bst.TICKET_TYPE) LIKE '%MEDIUM%' THEN 7
                        ELSE 14
                    END, bst.OPEN_DATE))
            ELSE NULL
        END AS RESOLUTION_TIME_HOURS,
        
        -- Metadata Columns
        bst.LOAD_TIMESTAMP,
        bst.UPDATE_TIMESTAMP,
        bst.SOURCE_SYSTEM,
        
        -- Data Quality Score Calculation
        (
            CASE WHEN bst.TICKET_ID IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN bst.USER_ID IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN bst.TICKET_TYPE IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN bst.OPEN_DATE IS NOT NULL THEN 0.25 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        -- Standard Metadata
        DATE(bst.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(bst.UPDATE_TIMESTAMP) AS UPDATE_DATE
        
    FROM bronze_support_tickets bst
),

-- Deduplication Layer
deduped_support_tickets AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY TICKET_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM cleansed_support_tickets
)

-- Final Select with Data Quality Filters
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
  AND DATA_QUALITY_SCORE >= 0.75  -- Minimum quality threshold
  AND TICKET_ID IS NOT NULL
  AND USER_ID IS NOT NULL
