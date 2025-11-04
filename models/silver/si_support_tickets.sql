{{ config(
    materialized='table',
    on_schema_change='sync_all_columns',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, EXECUTED_BY, EXECUTION_ENVIRONMENT, SOURCE_SYSTEM, LOAD_DATE, UPDATE_DATE) SELECT 'SUPP_' || REPLACE(REPLACE(REPLACE(CURRENT_TIMESTAMP()::STRING, ' ', '_'), ':', ''), '.', '_'), 'Silver_Support_Tickets_ETL', CURRENT_TIMESTAMP(), 'STARTED', 'DBT_SILVER_JOB', 'PRODUCTION', 'ZOOM_PLATFORM', CURRENT_DATE(), CURRENT_DATE()",
    post_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, END_TIME, STATUS, EXECUTION_DURATION_SECONDS, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, RECORDS_PROCESSED, RECORDS_INSERTED, RECORDS_UPDATED, RECORDS_REJECTED, EXECUTED_BY, EXECUTION_ENVIRONMENT, DATA_LINEAGE_INFO, SOURCE_SYSTEM, LOAD_DATE, UPDATE_DATE) SELECT 'SUPP_' || REPLACE(REPLACE(REPLACE(CURRENT_TIMESTAMP()::STRING, ' ', '_'), ':', ''), '.', '_'), 'Silver_Support_Tickets_ETL', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 'COMPLETED', 0, 'BZ_SUPPORT_TICKETS', 'SI_SUPPORT_TICKETS', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 0, 0, 'DBT_SILVER_JOB', 'PRODUCTION', 'Bronze to Silver Support Tickets transformation', 'ZOOM_PLATFORM', CURRENT_DATE(), CURRENT_DATE()"
) }}

-- Silver Support Tickets Table
-- Transforms Bronze support tickets data with standardizations and metrics

WITH bronze_support_tickets AS (
    SELECT *
    FROM {{ source('bronze', 'bz_support_tickets') }}
),

-- Data Quality Validations
validated_support_tickets AS (
    SELECT
        st.*,
        -- Data Quality Flags
        CASE 
            WHEN st.TICKET_ID IS NULL THEN 'CRITICAL_NO_TICKET_ID'
            WHEN st.USER_ID IS NULL THEN 'CRITICAL_NO_USER_ID'
            WHEN st.TICKET_TYPE IS NULL THEN 'CRITICAL_NO_TICKET_TYPE'
            WHEN st.OPEN_DATE > CURRENT_DATE() + INTERVAL '1 DAY' THEN 'CRITICAL_FUTURE_OPEN_DATE'
            WHEN st.RESOLUTION_STATUS NOT IN ('Open', 'In Progress', 'Resolved', 'Closed') THEN 'WARNING_INVALID_STATUS'
            ELSE 'VALID'
        END AS data_quality_flag,
        
        -- Row Number for Deduplication
        ROW_NUMBER() OVER (PARTITION BY st.TICKET_ID ORDER BY st.UPDATE_TIMESTAMP DESC, st.LOAD_TIMESTAMP DESC) AS rn
    FROM bronze_support_tickets st
    WHERE st.TICKET_ID IS NOT NULL  -- Block records without TICKET_ID
      AND st.USER_ID IS NOT NULL    -- Block records without USER_ID
      AND st.TICKET_TYPE IS NOT NULL -- Block records without TICKET_TYPE
      AND st.OPEN_DATE <= CURRENT_DATE() + INTERVAL '1 DAY' -- Block future dates
),

-- Apply Transformations
transformed_support_tickets AS (
    SELECT
        -- Primary Keys
        vst.TICKET_ID,
        vst.USER_ID,
        
        -- Standardized Business Columns
        CASE 
            WHEN UPPER(vst.TICKET_TYPE) IN ('TECHNICAL', 'TECH') THEN 'Technical'
            WHEN UPPER(vst.TICKET_TYPE) IN ('BILLING', 'BILL') THEN 'Billing'
            WHEN UPPER(vst.TICKET_TYPE) IN ('FEATURE REQUEST', 'FEATURE', 'REQUEST') THEN 'Feature Request'
            WHEN UPPER(vst.TICKET_TYPE) IN ('BUG REPORT', 'BUG') THEN 'Bug Report'
            ELSE 'General'
        END AS TICKET_TYPE,
        
        -- Derived Priority Level
        CASE 
            WHEN UPPER(vst.TICKET_TYPE) IN ('BUG REPORT', 'BUG') THEN 'High'
            WHEN UPPER(vst.TICKET_TYPE) = 'TECHNICAL' THEN 'Medium'
            WHEN UPPER(vst.TICKET_TYPE) = 'BILLING' THEN 'High'
            WHEN UPPER(vst.TICKET_TYPE) = 'FEATURE REQUEST' THEN 'Low'
            ELSE 'Medium'
        END AS PRIORITY_LEVEL,
        
        vst.OPEN_DATE,
        
        -- Derived Close Date
        CASE 
            WHEN UPPER(vst.RESOLUTION_STATUS) IN ('RESOLVED', 'CLOSED') THEN 
                DATEADD('day', 
                    CASE 
                        WHEN UPPER(vst.TICKET_TYPE) IN ('BUG REPORT', 'BUG') THEN 1
                        WHEN UPPER(vst.TICKET_TYPE) = 'TECHNICAL' THEN 3
                        WHEN UPPER(vst.TICKET_TYPE) = 'BILLING' THEN 2
                        ELSE 7
                    END, 
                    vst.OPEN_DATE)
            ELSE NULL
        END AS CLOSE_DATE,
        
        CASE 
            WHEN UPPER(vst.RESOLUTION_STATUS) IN ('OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED') THEN vst.RESOLUTION_STATUS
            ELSE 'Open'
        END AS RESOLUTION_STATUS,
        
        -- Derived Issue Description
        CASE 
            WHEN UPPER(vst.TICKET_TYPE) = 'TECHNICAL' THEN 'Technical issue requiring support'
            WHEN UPPER(vst.TICKET_TYPE) = 'BILLING' THEN 'Billing or payment related inquiry'
            WHEN UPPER(vst.TICKET_TYPE) = 'FEATURE REQUEST' THEN 'Request for new feature or enhancement'
            WHEN UPPER(vst.TICKET_TYPE) IN ('BUG REPORT', 'BUG') THEN 'Bug report requiring investigation'
            ELSE 'General support request'
        END AS ISSUE_DESCRIPTION,
        
        -- Derived Resolution Notes
        CASE 
            WHEN UPPER(vst.RESOLUTION_STATUS) IN ('RESOLVED', 'CLOSED') THEN 'Issue resolved successfully'
            WHEN UPPER(vst.RESOLUTION_STATUS) = 'IN PROGRESS' THEN 'Issue being investigated'
            ELSE 'Awaiting initial review'
        END AS RESOLUTION_NOTES,
        
        -- Calculate Resolution Time
        CASE 
            WHEN UPPER(vst.RESOLUTION_STATUS) IN ('RESOLVED', 'CLOSED') THEN 
                DATEDIFF('hour', vst.OPEN_DATE, 
                    DATEADD('day', 
                        CASE 
                            WHEN UPPER(vst.TICKET_TYPE) IN ('BUG REPORT', 'BUG') THEN 1
                            WHEN UPPER(vst.TICKET_TYPE) = 'TECHNICAL' THEN 3
                            WHEN UPPER(vst.TICKET_TYPE) = 'BILLING' THEN 2
                            ELSE 7
                        END, 
                        vst.OPEN_DATE))
            ELSE NULL
        END AS RESOLUTION_TIME_HOURS,
        
        -- Metadata Columns
        vst.LOAD_TIMESTAMP,
        vst.UPDATE_TIMESTAMP,
        vst.SOURCE_SYSTEM,
        
        -- Data Quality Score
        CASE 
            WHEN vst.data_quality_flag = 'VALID' THEN 1.00
            WHEN vst.data_quality_flag LIKE 'WARNING%' THEN 0.80
            ELSE 0.60
        END AS DATA_QUALITY_SCORE,
        
        -- Standard Metadata
        DATE(vst.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(vst.UPDATE_TIMESTAMP) AS UPDATE_DATE
        
    FROM validated_support_tickets vst
    WHERE vst.rn = 1  -- Keep only the latest record for each TICKET_ID
      AND vst.data_quality_flag NOT LIKE 'CRITICAL%'
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
FROM transformed_support_tickets
