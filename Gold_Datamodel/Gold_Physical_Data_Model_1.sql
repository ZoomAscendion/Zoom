_____________________________________________
-- Author: AAVA
-- Created on: 
-- Description: Gold Physical Data Model DDL scripts for Zoom Platform Analytics System following Medallion architecture with dimensional modeling for analytics and reporting
-- Version: 1
-- Updated on: 
_____________________________________________

-- =============================================
-- GOLD LAYER PHYSICAL DATA MODEL
-- Zoom Platform Analytics System
-- =============================================

-- Create Gold Schema if not exists
CREATE SCHEMA IF NOT EXISTS GOLD
    COMMENT = 'Gold layer schema for curated dimensional data following Medallion architecture';

USE SCHEMA GOLD;

-- =============================================
-- SECTION 1: FACT TABLES
-- =============================================

-- =============================================
-- 1. Go_Fact_Meeting_Activity
-- Description: Central fact table capturing meeting activities and usage metrics for platform usage analysis
-- =============================================

CREATE TABLE IF NOT EXISTS GOLD.Go_Fact_Meeting_Activity (
    -- ID Field (Added in Physical Model)
    FACT_MEETING_ACTIVITY_ID    VARCHAR(100)        COMMENT 'Unique identifier for each meeting activity fact record',
    
    -- Foreign Key References (ID fields)
    DATE_KEY                    DATE                COMMENT 'Foreign key reference to Go_Dim_Date',
    USER_KEY                    VARCHAR(255)        COMMENT 'Foreign key reference to Go_Dim_User',
    MEETING_TYPE_KEY            VARCHAR(50)         COMMENT 'Foreign key reference to Go_Dim_Meeting_Type',
    
    -- Fact Measures
    MEETING_DATE                DATE                COMMENT 'Date when the meeting occurred',
    MEETING_DURATION_MINUTES    NUMBER              COMMENT 'Total duration of the meeting in minutes',
    PARTICIPANT_COUNT           NUMBER              COMMENT 'Number of participants who joined the meeting',
    MEETING_TYPE                VARCHAR(50)         COMMENT 'Type of meeting (Scheduled, Instant, Webinar, Personal)',
    RECORDING_ENABLED_FLAG      BOOLEAN             COMMENT 'Whether recording was enabled for the meeting',
    FEATURE_USAGE_COUNT         NUMBER              COMMENT 'Total number of features used during the meeting',
    TOTAL_ATTENDANCE_MINUTES    NUMBER              COMMENT 'Sum of all participant attendance durations',
    HOST_PLAN_TYPE              VARCHAR(50)         COMMENT 'Plan type of the meeting host',
    MEETING_STATUS              VARCHAR(20)         COMMENT 'Final status of the meeting',
    
    -- Standard Metadata Columns
    LOAD_DATE                   DATE                COMMENT 'Date when record was loaded into Gold layer',
    UPDATE_DATE                 DATE                COMMENT 'Date when record was last updated',
    SOURCE_SYSTEM               VARCHAR(100)        COMMENT 'Source system identifier'
)
COMMENT = 'Central fact table capturing meeting activities and usage metrics for platform usage analysis';

-- =============================================
-- 2. Go_Fact_Support_Metrics
-- Description: Fact table for support ticket metrics and resolution tracking
-- =============================================

CREATE TABLE IF NOT EXISTS GOLD.Go_Fact_Support_Metrics (
    -- ID Field (Added in Physical Model)
    FACT_SUPPORT_METRICS_ID     VARCHAR(100)        COMMENT 'Unique identifier for each support metrics fact record',
    
    -- Foreign Key References (ID fields)
    DATE_KEY                    DATE                COMMENT 'Foreign key reference to Go_Dim_Date',
    USER_KEY                    VARCHAR(255)        COMMENT 'Foreign key reference to Go_Dim_User',
    SUPPORT_CATEGORY_KEY        VARCHAR(50)         COMMENT 'Foreign key reference to Go_Dim_Support_Category',
    
    -- Fact Measures
    TICKET_DATE                 DATE                COMMENT 'Date when support ticket was created',
    RESOLUTION_TIME_HOURS       NUMBER(10,2)        COMMENT 'Time taken to resolve ticket in business hours',
    TICKET_TYPE                 VARCHAR(50)         COMMENT 'Category of support ticket',
    PRIORITY_LEVEL              VARCHAR(20)         COMMENT 'Priority level of the ticket',
    RESOLUTION_STATUS           VARCHAR(20)         COMMENT 'Final resolution status',
    FIRST_CONTACT_RESOLUTION_FLAG BOOLEAN           COMMENT 'Whether ticket was resolved on first contact',
    ESCALATION_FLAG             BOOLEAN             COMMENT 'Whether ticket required escalation',
    CUSTOMER_PLAN_TYPE          VARCHAR(50)         COMMENT 'Plan type of the customer who created ticket',
    SATISFACTION_SCORE          NUMBER              COMMENT 'Customer satisfaction rating (1-5)',
    
    -- Standard Metadata Columns
    LOAD_DATE                   DATE                COMMENT 'Date when record was loaded into Gold layer',
    UPDATE_DATE                 DATE                COMMENT 'Date when record was last updated',
    SOURCE_SYSTEM               VARCHAR(100)        COMMENT 'Source system identifier'
)
COMMENT = 'Fact table for support ticket metrics and resolution tracking';

-- =============================================
-- 3. Go_Fact_Revenue_Events
-- Description: Fact table capturing billing events and revenue metrics
-- =============================================

CREATE TABLE IF NOT EXISTS GOLD.Go_Fact_Revenue_Events (
    -- ID Field (Added in Physical Model)
    FACT_REVENUE_EVENTS_ID      VARCHAR(100)        COMMENT 'Unique identifier for each revenue events fact record',
    
    -- Foreign Key References (ID fields)
    DATE_KEY                    DATE                COMMENT 'Foreign key reference to Go_Dim_Date',
    USER_KEY                    VARCHAR(255)        COMMENT 'Foreign key reference to Go_Dim_User',
    LICENSE_KEY                 VARCHAR(50)         COMMENT 'Foreign key reference to Go_Dim_License',
    
    -- Fact Measures
    TRANSACTION_DATE            DATE                COMMENT 'Date of the billing transaction',
    TRANSACTION_AMOUNT_USD      NUMBER(12,2)        COMMENT 'Transaction amount converted to USD',
    ORIGINAL_AMOUNT             NUMBER(12,2)        COMMENT 'Original transaction amount',
    CURRENCY_CODE               VARCHAR(3)          COMMENT 'Original currency code',
    EVENT_TYPE                  VARCHAR(50)         COMMENT 'Type of billing event',
    PAYMENT_METHOD              VARCHAR(50)         COMMENT 'Payment method used',
    LICENSE_TYPE                VARCHAR(50)         COMMENT 'Type of license associated with transaction',
    CUSTOMER_PLAN_TYPE          VARCHAR(50)         COMMENT 'Customer\'s subscription plan type',
    TRANSACTION_STATUS          VARCHAR(20)         COMMENT 'Status of the transaction',
    MRR_IMPACT                  NUMBER(12,2)        COMMENT 'Impact on Monthly Recurring Revenue',
    
    -- Standard Metadata Columns
    LOAD_DATE                   DATE                COMMENT 'Date when record was loaded into Gold layer',
    UPDATE_DATE                 DATE                COMMENT 'Date when record was last updated',
    SOURCE_SYSTEM               VARCHAR(100)        COMMENT 'Source system identifier'
)
COMMENT = 'Fact table capturing billing events and revenue metrics';

-- =============================================
-- 4. Go_Fact_Feature_Usage
-- Description: Fact table for detailed feature usage analytics
-- =============================================

CREATE TABLE IF NOT EXISTS GOLD.Go_Fact_Feature_Usage (
    -- ID Field (Added in Physical Model)
    FACT_FEATURE_USAGE_ID       VARCHAR(100)        COMMENT 'Unique identifier for each feature usage fact record',
    
    -- Foreign Key References (ID fields)
    DATE_KEY                    DATE                COMMENT 'Foreign key reference to Go_Dim_Date',
    USER_KEY                    VARCHAR(255)        COMMENT 'Foreign key reference to Go_Dim_User',
    FEATURE_KEY                 VARCHAR(100)        COMMENT 'Foreign key reference to Go_Dim_Feature',
    
    -- Fact Measures
    USAGE_DATE                  DATE                COMMENT 'Date when feature was used',
    FEATURE_NAME                VARCHAR(100)        COMMENT 'Name of the feature used',
    FEATURE_CATEGORY            VARCHAR(50)         COMMENT 'Category of the feature',
    USAGE_COUNT                 NUMBER              COMMENT 'Number of times feature was used',
    USAGE_DURATION_MINUTES      NUMBER              COMMENT 'Total duration feature was active',
    MEETING_TYPE                VARCHAR(50)         COMMENT 'Type of meeting where feature was used',
    USER_PLAN_TYPE              VARCHAR(50)         COMMENT 'Plan type of the user',
    PARTICIPANT_COUNT           NUMBER              COMMENT 'Number of participants in the meeting',
    
    -- Standard Metadata Columns
    LOAD_DATE                   DATE                COMMENT 'Date when record was loaded into Gold layer',
    UPDATE_DATE                 DATE                COMMENT 'Date when record was last updated',
    SOURCE_SYSTEM               VARCHAR(100)        COMMENT 'Source system identifier'
)
COMMENT = 'Fact table for detailed feature usage analytics';

-- =============================================
-- SECTION 2: DIMENSION TABLES
-- =============================================

-- =============================================
-- 5. Go_Dim_Date
-- Description: Standard date dimension for time-based analysis
-- =============================================

CREATE TABLE IF NOT EXISTS GOLD.Go_Dim_Date (
    -- ID Field (Added in Physical Model)
    DIM_DATE_ID                 VARCHAR(100)        COMMENT 'Unique identifier for each date dimension record',
    
    -- Business Columns
    DATE_KEY                    DATE                COMMENT 'Primary date key',
    YEAR                        NUMBER              COMMENT 'Year component',
    QUARTER                     NUMBER              COMMENT 'Quarter number (1-4)',
    MONTH                       NUMBER              COMMENT 'Month number (1-12)',
    MONTH_NAME                  VARCHAR(20)         COMMENT 'Full month name',
    WEEK_OF_YEAR                NUMBER              COMMENT 'Week number in year',
    DAY_OF_MONTH                NUMBER              COMMENT 'Day of the month',
    DAY_OF_WEEK                 NUMBER              COMMENT 'Day of week (1-7)',
    DAY_NAME                    VARCHAR(20)         COMMENT 'Full day name',
    IS_WEEKEND                  BOOLEAN             COMMENT 'Whether date falls on weekend',
    IS_HOLIDAY                  BOOLEAN             COMMENT 'Whether date is a business holiday',
    FISCAL_YEAR                 NUMBER              COMMENT 'Fiscal year',
    FISCAL_QUARTER              NUMBER              COMMENT 'Fiscal quarter',
    
    -- Standard Metadata Columns
    LOAD_DATE                   DATE                COMMENT 'Date when record was loaded',
    UPDATE_DATE                 DATE                COMMENT 'Date when record was last updated',
    SOURCE_SYSTEM               VARCHAR(100)        COMMENT 'Source system identifier'
)
COMMENT = 'Standard date dimension for time-based analysis';

-- =============================================
-- 6. Go_Dim_User
-- Description: User dimension with slowly changing attributes (SCD Type 2)
-- =============================================

CREATE TABLE IF NOT EXISTS GOLD.Go_Dim_User (
    -- ID Field (Added in Physical Model)
    DIM_USER_ID                 VARCHAR(100)        COMMENT 'Unique identifier for each user dimension record',
    
    -- Business Columns
    USER_BUSINESS_KEY           VARCHAR(255)        COMMENT 'Business key for the user',
    USER_NAME                   VARCHAR(255)        COMMENT 'Full name of the user',
    EMAIL_DOMAIN                VARCHAR(100)        COMMENT 'Domain part of email address',
    COMPANY_NAME                VARCHAR(255)        COMMENT 'Company or organization name',
    PLAN_TYPE                   VARCHAR(50)         COMMENT 'Current subscription plan type',
    ACCOUNT_STATUS              VARCHAR(20)         COMMENT 'Current account status',
    REGISTRATION_DATE           DATE                COMMENT 'Date when user registered',
    USER_SEGMENT                VARCHAR(50)         COMMENT 'User segment classification',
    
    -- SCD Type 2 Columns
    EFFECTIVE_START_DATE        DATE                COMMENT 'When this version became effective',
    EFFECTIVE_END_DATE          DATE                COMMENT 'When this version expired',
    IS_CURRENT                  BOOLEAN             COMMENT 'Whether this is the current version',
    
    -- Standard Metadata Columns
    LOAD_DATE                   DATE                COMMENT 'Date when record was loaded',
    UPDATE_DATE                 DATE                COMMENT 'Date when record was last updated',
    SOURCE_SYSTEM               VARCHAR(100)        COMMENT 'Source system identifier'
)
COMMENT = 'User dimension with slowly changing attributes (SCD Type 2)';

-- =============================================
-- 7. Go_Dim_Meeting_Type
-- Description: Meeting type classification dimension
-- =============================================

CREATE TABLE IF NOT EXISTS GOLD.Go_Dim_Meeting_Type (
    -- ID Field (Added in Physical Model)
    DIM_MEETING_TYPE_ID         VARCHAR(100)        COMMENT 'Unique identifier for each meeting type dimension record',
    
    -- Business Columns
    MEETING_TYPE_KEY            VARCHAR(50)         COMMENT 'Meeting type identifier',
    MEETING_TYPE_NAME           VARCHAR(100)        COMMENT 'Full name of meeting type',
    MEETING_CATEGORY            VARCHAR(50)         COMMENT 'High-level category',
    IS_SCHEDULED                BOOLEAN             COMMENT 'Whether meeting type requires scheduling',
    SUPPORTS_RECORDING          BOOLEAN             COMMENT 'Whether recording is supported',
    MAX_PARTICIPANTS            NUMBER              COMMENT 'Maximum number of participants allowed',
    REQUIRES_LICENSE            BOOLEAN             COMMENT 'Whether special license is required',
    
    -- Standard Metadata Columns
    LOAD_DATE                   DATE                COMMENT 'Date when record was loaded',
    UPDATE_DATE                 DATE                COMMENT 'Date when record was last updated',
    SOURCE_SYSTEM               VARCHAR(100)        COMMENT 'Source system identifier'
)
COMMENT = 'Meeting type classification dimension';

-- =============================================
-- 8. Go_Dim_Feature
-- Description: Platform feature dimension for usage analysis
-- =============================================

CREATE TABLE IF NOT EXISTS GOLD.Go_Dim_Feature (
    -- ID Field (Added in Physical Model)
    DIM_FEATURE_ID              VARCHAR(100)        COMMENT 'Unique identifier for each feature dimension record',
    
    -- Business Columns
    FEATURE_KEY                 VARCHAR(100)        COMMENT 'Feature identifier',
    FEATURE_NAME                VARCHAR(200)        COMMENT 'Full name of the feature',
    FEATURE_CATEGORY            VARCHAR(50)         COMMENT 'Feature category classification',
    FEATURE_SUBCATEGORY         VARCHAR(50)         COMMENT 'Feature subcategory',
    IS_PREMIUM_FEATURE          BOOLEAN             COMMENT 'Whether feature requires premium plan',
    RELEASE_DATE                DATE                COMMENT 'When feature was first released',
    DEPRECATION_DATE            DATE                COMMENT 'When feature was deprecated',
    IS_ACTIVE                   BOOLEAN             COMMENT 'Whether feature is currently active',
    
    -- Standard Metadata Columns
    LOAD_DATE                   DATE                COMMENT 'Date when record was loaded',
    UPDATE_DATE                 DATE                COMMENT 'Date when record was last updated',
    SOURCE_SYSTEM               VARCHAR(100)        COMMENT 'Source system identifier'
)
COMMENT = 'Platform feature dimension for usage analysis';

-- =============================================
-- 9. Go_Dim_Support_Category
-- Description: Support ticket categorization dimension
-- =============================================

CREATE TABLE IF NOT EXISTS GOLD.Go_Dim_Support_Category (
    -- ID Field (Added in Physical Model)
    DIM_SUPPORT_CATEGORY_ID     VARCHAR(100)        COMMENT 'Unique identifier for each support category dimension record',
    
    -- Business Columns
    CATEGORY_KEY                VARCHAR(50)         COMMENT 'Support category identifier',
    TICKET_TYPE                 VARCHAR(100)        COMMENT 'Type of support ticket',
    CATEGORY_GROUP              VARCHAR(50)         COMMENT 'High-level category grouping',
    PRIORITY_LEVEL              VARCHAR(20)         COMMENT 'Default priority level',
    SLA_HOURS                   NUMBER              COMMENT 'Service level agreement in hours',
    ESCALATION_THRESHOLD_HOURS  NUMBER              COMMENT 'Hours before automatic escalation',
    REQUIRES_TECHNICAL_EXPERTISE BOOLEAN            COMMENT 'Whether technical skills are required',
    
    -- Standard Metadata Columns
    LOAD_DATE                   DATE                COMMENT 'Date when record was loaded',
    UPDATE_DATE                 DATE                COMMENT 'Date when record was last updated',
    SOURCE_SYSTEM               VARCHAR(100)        COMMENT 'Source system identifier'
)
COMMENT = 'Support ticket categorization dimension';

-- =============================================
-- 10. Go_Dim_License
-- Description: License type and pricing dimension (SCD Type 2)
-- =============================================

CREATE TABLE IF NOT EXISTS GOLD.Go_Dim_License (
    -- ID Field (Added in Physical Model)
    DIM_LICENSE_ID              VARCHAR(100)        COMMENT 'Unique identifier for each license dimension record',
    
    -- Business Columns
    LICENSE_TYPE_KEY            VARCHAR(50)         COMMENT 'License type identifier',
    LICENSE_NAME                VARCHAR(100)        COMMENT 'Full name of license type',
    LICENSE_TIER                VARCHAR(50)         COMMENT 'License tier classification',
    MONTHLY_COST                NUMBER(10,2)        COMMENT 'Monthly cost of license',
    ANNUAL_COST                 NUMBER(10,2)        COMMENT 'Annual cost of license',
    MAX_PARTICIPANTS            NUMBER              COMMENT 'Maximum participants allowed',
    STORAGE_GB                  NUMBER              COMMENT 'Storage allocation in GB',
    FEATURES_INCLUDED           VARCHAR(4000)       COMMENT 'List of included features',
    
    -- SCD Type 2 Columns
    EFFECTIVE_START_DATE        DATE                COMMENT 'When this pricing became effective',
    EFFECTIVE_END_DATE          DATE                COMMENT 'When this pricing expired',
    IS_CURRENT                  BOOLEAN             COMMENT 'Whether this is current pricing',
    
    -- Standard Metadata Columns
    LOAD_DATE                   DATE                COMMENT 'Date when record was loaded',
    UPDATE_DATE                 DATE                COMMENT 'Date when record was last updated',
    SOURCE_SYSTEM               VARCHAR(100)        COMMENT 'Source system identifier'
)
COMMENT = 'License type and pricing dimension (SCD Type 2)';

-- =============================================
-- SECTION 3: AGGREGATED TABLES
-- =============================================

-- =============================================
-- 11. Go_Agg_Daily_Usage_Summary
-- Description: Daily aggregated usage metrics for performance optimization
-- =============================================

CREATE TABLE IF NOT EXISTS GOLD.Go_Agg_Daily_Usage_Summary (
    -- ID Field (Added in Physical Model)
    AGG_DAILY_USAGE_ID          VARCHAR(100)        COMMENT 'Unique identifier for each daily usage summary record',
    
    -- Business Columns
    SUMMARY_DATE                DATE                COMMENT 'Date of the aggregated metrics',
    TOTAL_MEETINGS              NUMBER              COMMENT 'Total number of meetings held',
    TOTAL_PARTICIPANTS          NUMBER              COMMENT 'Total number of unique participants',
    TOTAL_MEETING_MINUTES       NUMBER              COMMENT 'Sum of all meeting durations',
    AVERAGE_MEETING_DURATION    NUMBER(10,2)        COMMENT 'Average meeting duration in minutes',
    TOTAL_ACTIVE_USERS          NUMBER              COMMENT 'Number of users who hosted or attended meetings',
    NEW_USER_REGISTRATIONS      NUMBER              COMMENT 'Number of new user sign-ups',
    WEBINAR_COUNT               NUMBER              COMMENT 'Total number of webinars held',
    RECORDING_USAGE_COUNT       NUMBER              COMMENT 'Number of meetings with recording enabled',
    FEATURE_USAGE_EVENTS        NUMBER              COMMENT 'Total feature usage events',
    
    -- Standard Metadata Columns
    LOAD_DATE                   DATE                COMMENT 'Date when record was loaded',
    UPDATE_DATE                 DATE                COMMENT 'Date when record was last updated',
    SOURCE_SYSTEM               VARCHAR(100)        COMMENT 'Source system identifier'
)
COMMENT = 'Daily aggregated usage metrics for performance optimization';

-- =============================================
-- 12. Go_Agg_Monthly_Revenue_Summary
-- Description: Monthly revenue and billing aggregations
-- =============================================

CREATE TABLE IF NOT EXISTS GOLD.Go_Agg_Monthly_Revenue_Summary (
    -- ID Field (Added in Physical Model)
    AGG_MONTHLY_REVENUE_ID      VARCHAR(100)        COMMENT 'Unique identifier for each monthly revenue summary record',
    
    -- Business Columns
    REVENUE_MONTH               DATE                COMMENT 'Month of the revenue summary (first day of month)',
    TOTAL_REVENUE_USD           NUMBER(15,2)        COMMENT 'Total revenue in USD',
    MRR_USD                     NUMBER(15,2)        COMMENT 'Monthly Recurring Revenue in USD',
    NEW_CUSTOMER_REVENUE        NUMBER(15,2)        COMMENT 'Revenue from new customers',
    EXPANSION_REVENUE           NUMBER(15,2)        COMMENT 'Revenue from upgrades',
    CHURN_REVENUE               NUMBER(15,2)        COMMENT 'Revenue lost from churned customers',
    TOTAL_TRANSACTIONS          NUMBER              COMMENT 'Total number of billing transactions',
    ACTIVE_LICENSES             NUMBER              COMMENT 'Number of active licenses',
    LICENSE_UTILIZATION_RATE    NUMBER(5,2)         COMMENT 'Percentage of licenses being utilized',
    AVERAGE_REVENUE_PER_USER    NUMBER(10,2)        COMMENT 'Average revenue per active user',
    CUSTOMER_CHURN_RATE         NUMBER(5,2)         COMMENT 'Percentage of customers who churned',
    
    -- Standard Metadata Columns
    LOAD_DATE                   DATE                COMMENT 'Date when record was loaded',
    UPDATE_DATE                 DATE                COMMENT 'Date when record was last updated',
    SOURCE_SYSTEM               VARCHAR(100)        COMMENT 'Source system identifier'
)
COMMENT = 'Monthly revenue and billing aggregations';

-- =============================================
-- 13. Go_Agg_Weekly_Support_Summary
-- Description: Weekly support metrics aggregation
-- =============================================

CREATE TABLE IF NOT EXISTS GOLD.Go_Agg_Weekly_Support_Summary (
    -- ID Field (Added in Physical Model)
    AGG_WEEKLY_SUPPORT_ID       VARCHAR(100)        COMMENT 'Unique identifier for each weekly support summary record',
    
    -- Business Columns
    WEEK_START_DATE             DATE                COMMENT 'Start date of the week',
    TOTAL_TICKETS_CREATED       NUMBER              COMMENT 'Total tickets created during the week',
    TOTAL_TICKETS_RESOLVED      NUMBER              COMMENT 'Total tickets resolved during the week',
    AVERAGE_RESOLUTION_TIME_HOURS NUMBER(10,2)      COMMENT 'Average resolution time in hours',
    FIRST_CONTACT_RESOLUTION_RATE NUMBER(5,2)       COMMENT 'Percentage resolved on first contact',
    ESCALATION_RATE             NUMBER(5,2)         COMMENT 'Percentage of tickets escalated',
    TICKETS_BY_PRIORITY_CRITICAL NUMBER             COMMENT 'Number of critical priority tickets',
    TICKETS_BY_PRIORITY_HIGH    NUMBER              COMMENT 'Number of high priority tickets',
    TICKETS_BY_PRIORITY_MEDIUM  NUMBER              COMMENT 'Number of medium priority tickets',
    TICKETS_BY_PRIORITY_LOW     NUMBER              COMMENT 'Number of low priority tickets',
    CUSTOMER_SATISFACTION_AVG   NUMBER(3,2)         COMMENT 'Average customer satisfaction score',
    
    -- Standard Metadata Columns
    LOAD_DATE                   DATE                COMMENT 'Date when record was loaded',
    UPDATE_DATE                 DATE                COMMENT 'Date when record was last updated',
    SOURCE_SYSTEM               VARCHAR(100)        COMMENT 'Source system identifier'
)
COMMENT = 'Weekly support metrics aggregation';

-- =============================================
-- SECTION 4: ERROR DATA TABLE
-- =============================================

-- =============================================
-- 14. Go_Data_Quality_Errors
-- Description: Data validation errors and quality issues in Gold layer processing
-- =============================================

CREATE TABLE IF NOT EXISTS GOLD.Go_Data_Quality_Errors (
    -- ID Field (Added in Physical Model)
    ERROR_ID                    VARCHAR(100)        COMMENT 'Unique identifier for each error record',
    
    -- Error Details
    SOURCE_TABLE_NAME           VARCHAR(100)        COMMENT 'Name of source table where error occurred',
    TARGET_TABLE_NAME           VARCHAR(100)        COMMENT 'Name of target table affected',
    SOURCE_RECORD_IDENTIFIER    VARCHAR(200)        COMMENT 'Identifier of problematic source record',
    ERROR_TYPE                  VARCHAR(50)         COMMENT 'Type of error (Validation, Transformation, Load)',
    ERROR_CATEGORY              VARCHAR(50)         COMMENT 'Category (Missing Data, Invalid Format, Business Rule)',
    ERROR_COLUMN_NAME           VARCHAR(100)        COMMENT 'Column where error was detected',
    ERROR_DESCRIPTION           VARCHAR(4000)       COMMENT 'Detailed description of the error',
    ERROR_SEVERITY              VARCHAR(20)         COMMENT 'Severity level (Critical, High, Medium, Low)',
    DETECTED_TIMESTAMP          TIMESTAMP_NTZ(9)    COMMENT 'When error was detected',
    RESOLUTION_STATUS           VARCHAR(50)         COMMENT 'Status of error resolution',
    RESOLUTION_ACTION           VARCHAR(4000)       COMMENT 'Action taken to resolve error',
    RESOLVED_TIMESTAMP          TIMESTAMP_NTZ(9)    COMMENT 'When error was resolved',
    RESOLVED_BY                 VARCHAR(100)        COMMENT 'Who resolved the error',
    BUSINESS_IMPACT             VARCHAR(100)        COMMENT 'Impact on business reporting',
    
    -- Standard Metadata Columns
    LOAD_DATE                   DATE                COMMENT 'Date when error record was created',
    SOURCE_SYSTEM               VARCHAR(100)        COMMENT 'Source system identifier'
)
COMMENT = 'Data validation errors and quality issues in Gold layer processing';

-- =============================================
-- SECTION 5: AUDIT TABLE
-- =============================================

-- =============================================
-- 15. Go_Process_Audit
-- Description: Comprehensive audit trail for Gold layer pipeline execution and data processing
-- =============================================

CREATE TABLE IF NOT EXISTS GOLD.Go_Process_Audit (
    -- ID Field (Added in Physical Model)
    EXECUTION_ID                VARCHAR(100)        COMMENT 'Unique identifier for each pipeline execution',
    
    -- Pipeline Execution Details
    AUDIT_KEY                   VARCHAR(100)        COMMENT 'Unique identifier for audit record',
    PIPELINE_NAME               VARCHAR(200)        COMMENT 'Name of the data pipeline executed',
    EXECUTION_START_TIMESTAMP   TIMESTAMP_NTZ(9)    COMMENT 'When pipeline execution started',
    EXECUTION_END_TIMESTAMP     TIMESTAMP_NTZ(9)    COMMENT 'When pipeline execution completed',
    EXECUTION_DURATION_SECONDS  NUMBER              COMMENT 'Total execution time in seconds',
    EXECUTION_STATUS            VARCHAR(50)         COMMENT 'Status of execution (Success, Failed, Partial)',
    SOURCE_TABLES_PROCESSED     VARCHAR(4000)       COMMENT 'List of source tables processed',
    TARGET_TABLES_UPDATED       VARCHAR(4000)       COMMENT 'List of target tables updated',
    RECORDS_PROCESSED           NUMBER              COMMENT 'Total number of records processed',
    RECORDS_INSERTED            NUMBER              COMMENT 'Number of new records inserted',
    RECORDS_UPDATED             NUMBER              COMMENT 'Number of existing records updated',
    RECORDS_REJECTED            NUMBER              COMMENT 'Number of records rejected due to quality issues',
    DATA_QUALITY_SCORE          NUMBER(5,2)         COMMENT 'Overall data quality score for the batch',
    ERROR_MESSAGE               VARCHAR(4000)       COMMENT 'Error message if execution failed',
    EXECUTED_BY                 VARCHAR(100)        COMMENT 'User or system that executed the pipeline',
    EXECUTION_ENVIRONMENT       VARCHAR(50)         COMMENT 'Environment (Dev, Test, Prod)',
    
    -- Standard Metadata Columns
    LOAD_DATE                   DATE                COMMENT 'Date when audit record was created',
    SOURCE_SYSTEM               VARCHAR(100)        COMMENT 'Source system identifier'
)
COMMENT = 'Comprehensive audit trail for Gold layer pipeline execution and data processing';

-- =============================================
-- SECTION 6: UPDATE DDL SCRIPTS
-- =============================================

-- =============================================
-- Schema Evolution Scripts
-- Description: Scripts to handle schema changes and updates
-- =============================================

-- Add new column to existing table (example)
-- ALTER TABLE GOLD.Go_Fact_Meeting_Activity ADD COLUMN NEW_METRIC NUMBER COMMENT 'Description of new metric';

-- Modify column data type (example)
-- ALTER TABLE GOLD.Go_Dim_User ALTER COLUMN USER_SEGMENT SET DATA TYPE VARCHAR(100);

-- Add clustering key for performance optimization (example)
-- ALTER TABLE GOLD.Go_Fact_Meeting_Activity CLUSTER BY (MEETING_DATE, USER_KEY);
-- ALTER TABLE GOLD.Go_Fact_Revenue_Events CLUSTER BY (TRANSACTION_DATE, USER_KEY);
-- ALTER TABLE GOLD.Go_Fact_Support_Metrics CLUSTER BY (TICKET_DATE, USER_KEY);
-- ALTER TABLE GOLD.Go_Fact_Feature_Usage CLUSTER BY (USAGE_DATE, FEATURE_KEY);

-- Create views for commonly used queries (example)
-- CREATE OR REPLACE VIEW GOLD.VW_ACTIVE_USERS AS
-- SELECT USER_BUSINESS_KEY, USER_NAME, EMAIL_DOMAIN, PLAN_TYPE
-- FROM GOLD.Go_Dim_User
-- WHERE IS_CURRENT = TRUE AND ACCOUNT_STATUS = 'Active';

-- CREATE OR REPLACE VIEW GOLD.VW_MONTHLY_METRICS AS
-- SELECT 
--     DATE_TRUNC('MONTH', MEETING_DATE) as MONTH,
--     COUNT(*) as TOTAL_MEETINGS,
--     SUM(MEETING_DURATION_MINUTES) as TOTAL_MINUTES,
--     AVG(MEETING_DURATION_MINUTES) as AVG_DURATION
-- FROM GOLD.Go_Fact_Meeting_Activity
-- GROUP BY DATE_TRUNC('MONTH', MEETING_DATE);

-- =============================================
-- GOLD LAYER SUMMARY
-- =============================================

/*
GOLD LAYER TABLES CREATED:

1. FACT TABLES (4 tables):
   • Go_Fact_Meeting_Activity       - Meeting activities and usage metrics (16 columns)
   • Go_Fact_Support_Metrics        - Support ticket metrics and resolution tracking (15 columns)
   • Go_Fact_Revenue_Events         - Billing events and revenue metrics (16 columns)
   • Go_Fact_Feature_Usage          - Detailed feature usage analytics (14 columns)

2. DIMENSION TABLES (6 tables):
   • Go_Dim_Date                    - Standard date dimension (16 columns)
   • Go_Dim_User                    - User dimension with SCD Type 2 (15 columns)
   • Go_Dim_Meeting_Type            - Meeting type classification (10 columns)
   • Go_Dim_Feature                 - Platform feature dimension (11 columns)
   • Go_Dim_Support_Category        - Support ticket categorization (10 columns)
   • Go_Dim_License                 - License type and pricing with SCD Type 2 (14 columns)

3. AGGREGATED TABLES (3 tables):
   • Go_Agg_Daily_Usage_Summary     - Daily usage metrics aggregation (13 columns)
   • Go_Agg_Monthly_Revenue_Summary - Monthly revenue and billing aggregations (14 columns)
   • Go_Agg_Weekly_Support_Summary  - Weekly support metrics aggregation (14 columns)

4. AUDIT AND ERROR TABLES (2 tables):
   • Go_Data_Quality_Errors         - Data validation errors and quality issues (17 columns)
   • Go_Process_Audit               - Pipeline execution audit trail (19 columns)

KEY FEATURES:
• All tables follow 'Go_' naming convention for Gold layer identification
• ID fields added to all tables as required by physical model specifications
• All columns from Silver layer retained and enhanced with dimensional modeling
• Snowflake-compatible data types used throughout (VARCHAR, NUMBER, DATE, TIMESTAMP_NTZ, BOOLEAN)
• No primary keys, foreign keys, or constraints (following Snowflake best practices)
• Foreign key references implemented as regular columns for dimensional modeling
• SCD Type 2 implementation for Go_Dim_User and Go_Dim_License tables
• Comprehensive metadata columns for data lineage and quality tracking
• Star schema design with fact tables at center and dimension tables providing context
• Pre-aggregated tables for improved query performance
• Error tracking table for data validation issues
• Comprehensive audit table for pipeline execution monitoring
• CREATE TABLE IF NOT EXISTS syntax for safe deployment
• Detailed column comments for documentation
• Schema evolution scripts for future updates
• Clustering recommendations for performance optimization

DATA FLOW:
RAW Schema → BRONZE Schema → SILVER Schema → GOLD Schema

DIMENSIONAL MODEL DESIGN:
• Star Schema Architecture with central fact tables
• Conformed dimensions (Go_Dim_Date, Go_Dim_User) shared across fact tables
• Slowly Changing Dimensions (Type 1 and Type 2) for historical tracking
• Pre-aggregated tables for performance optimization
• Comprehensive audit and error tracking capabilities

This Gold Physical Data Model serves as the curated analytical layer in the Medallion architecture,
storing dimensional data optimized for business intelligence, reporting, and analytics while
maintaining data quality, performance, and governance standards.

API Cost: 0.003247 USD
*/

-- End of Gold Physical Data Model DDL Script