_____________________________________________
-- *Author*: AAVA
-- *Created on*:   
-- *Description*: Gold Physical Data Model DDL scripts for Zoom Platform Analytics System following Medallion architecture with dimensional modeling for analytics and reporting
-- *Version*: 1 
-- *Updated on*: 
_____________________________________________

-- =============================================
-- GOLD LAYER PHYSICAL DATA MODEL
-- Zoom Platform Analytics System
-- =============================================

-- Create Gold Schema if not exists
CREATE SCHEMA IF NOT EXISTS GOLD
    COMMENT = 'Gold layer schema for business-ready dimensional data following Medallion architecture';

USE SCHEMA GOLD;

-- =============================================
-- SECTION 1: FACT TABLES
-- =============================================

-- =============================================
-- TABLE 1: GOLD.GO_MEETING_ACTIVITY_FACT
-- Description: Central fact table capturing meeting activities and metrics for platform usage analysis
-- =============================================

CREATE TABLE IF NOT EXISTS GOLD.GO_MEETING_ACTIVITY_FACT (
    -- ID Field (Added in Physical Model)
    MEETING_ACTIVITY_ID     VARCHAR(50)         COMMENT 'Unique identifier for each meeting activity record',
    
    -- Business Columns from Gold Logical Model
    MEETING_DATE            DATE                COMMENT 'Date when the meeting occurred',
    MEETING_DURATION_MINUTES NUMBER             COMMENT 'Total duration of the meeting in minutes',
    PARTICIPANT_COUNT       NUMBER              COMMENT 'Number of participants who joined the meeting',
    HOST_PLAN_TYPE          VARCHAR(50)         COMMENT 'Subscription plan type of the meeting host',
    MEETING_TYPE            VARCHAR(50)         COMMENT 'Type of meeting (Scheduled, Instant, Webinar, Personal)',
    RECORDING_ENABLED       BOOLEAN             COMMENT 'Whether the meeting was recorded',
    FEATURE_USAGE_COUNT     NUMBER              COMMENT 'Total number of features used during the meeting',
    TOTAL_ATTENDANCE_MINUTES NUMBER             COMMENT 'Sum of all participant attendance durations',
    AVERAGE_CONNECTION_QUALITY_SCORE NUMBER(3,2) COMMENT 'Average connection quality across all participants',
    MEETING_COMPLETION_STATUS VARCHAR(20)       COMMENT 'Whether meeting completed successfully',
    
    -- Metadata Columns
    LOAD_DATE               DATE                COMMENT 'Date when record was loaded into Gold layer',
    UPDATE_DATE             DATE                COMMENT 'Date when record was last updated',
    SOURCE_SYSTEM           VARCHAR(100)        COMMENT 'Source system identifier'
)
COMMENT = 'Central fact table capturing meeting activities and metrics for platform usage analysis';

-- =============================================
-- TABLE 2: GOLD.GO_SUPPORT_TICKET_FACT
-- Description: Fact table capturing support ticket metrics and resolution performance
-- =============================================

CREATE TABLE IF NOT EXISTS GOLD.GO_SUPPORT_TICKET_FACT (
    -- ID Field (Added in Physical Model)
    SUPPORT_TICKET_ID       VARCHAR(50)         COMMENT 'Unique identifier for each support ticket record',
    
    -- Business Columns from Gold Logical Model
    TICKET_DATE             DATE                COMMENT 'Date when the support ticket was created',
    TICKET_TYPE             VARCHAR(50)         COMMENT 'Category of support ticket',
    PRIORITY_LEVEL          VARCHAR(20)         COMMENT 'Urgency level of the ticket',
    RESOLUTION_TIME_HOURS   NUMBER              COMMENT 'Time taken to resolve ticket in business hours',
    CUSTOMER_PLAN_TYPE      VARCHAR(50)         COMMENT 'Plan type of the customer who created ticket',
    FIRST_CONTACT_RESOLUTION BOOLEAN            COMMENT 'Whether ticket was resolved on first contact',
    ESCALATION_REQUIRED     BOOLEAN             COMMENT 'Whether ticket required escalation',
    CUSTOMER_SATISFACTION_SCORE NUMBER          COMMENT 'Customer satisfaction rating (1-5)',
    RESOLUTION_STATUS       VARCHAR(20)         COMMENT 'Final status of the ticket',
    
    -- Metadata Columns
    LOAD_DATE               DATE                COMMENT 'Date when record was loaded into Gold layer',
    UPDATE_DATE             DATE                COMMENT 'Date when record was last updated',
    SOURCE_SYSTEM           VARCHAR(100)        COMMENT 'Source system identifier'
)
COMMENT = 'Fact table capturing support ticket metrics and resolution performance';

-- =============================================
-- TABLE 3: GOLD.GO_REVENUE_FACT
-- Description: Fact table capturing billing events and revenue metrics
-- =============================================

CREATE TABLE IF NOT EXISTS GOLD.GO_REVENUE_FACT (
    -- ID Field (Added in Physical Model)
    REVENUE_ID              VARCHAR(50)         COMMENT 'Unique identifier for each revenue record',
    
    -- Business Columns from Gold Logical Model
    TRANSACTION_DATE        DATE                COMMENT 'Date when the billing transaction occurred',
    TRANSACTION_AMOUNT      NUMBER(10,2)        COMMENT 'Monetary value of the transaction',
    TRANSACTION_TYPE        VARCHAR(50)         COMMENT 'Type of billing event',
    CUSTOMER_PLAN_TYPE      VARCHAR(50)         COMMENT 'Plan type associated with the transaction',
    PAYMENT_METHOD          VARCHAR(50)         COMMENT 'Method used for payment',
    CURRENCY_CODE           VARCHAR(3)          COMMENT 'ISO currency code',
    LICENSE_COUNT           NUMBER              COMMENT 'Number of licenses involved in transaction',
    IS_RECURRING_REVENUE    BOOLEAN             COMMENT 'Whether transaction represents recurring revenue',
    CUSTOMER_TENURE_MONTHS  NUMBER              COMMENT 'Number of months customer has been active',
    TRANSACTION_STATUS      VARCHAR(20)         COMMENT 'Status of the transaction',
    
    -- Metadata Columns
    LOAD_DATE               DATE                COMMENT 'Date when record was loaded into Gold layer',
    UPDATE_DATE             DATE                COMMENT 'Date when record was last updated',
    SOURCE_SYSTEM           VARCHAR(100)        COMMENT 'Source system identifier'
)
COMMENT = 'Fact table capturing billing events and revenue metrics';

-- =============================================
-- TABLE 4: GOLD.GO_FEATURE_USAGE_FACT
-- Description: Fact table capturing detailed feature usage patterns and adoption metrics
-- =============================================

CREATE TABLE IF NOT EXISTS GOLD.GO_FEATURE_USAGE_FACT (
    -- ID Field (Added in Physical Model)
    FEATURE_USAGE_ID        VARCHAR(50)         COMMENT 'Unique identifier for each feature usage record',
    
    -- Business Columns from Gold Logical Model
    USAGE_DATE              DATE                COMMENT 'Date when feature usage occurred',
    FEATURE_NAME            VARCHAR(100)        COMMENT 'Name of the feature used',
    FEATURE_CATEGORY        VARCHAR(50)         COMMENT 'Category of the feature',
    USAGE_COUNT             NUMBER              COMMENT 'Number of times feature was used',
    USAGE_DURATION_MINUTES  NUMBER              COMMENT 'Total duration feature was active',
    USER_PLAN_TYPE          VARCHAR(50)         COMMENT 'Plan type of the user using the feature',
    MEETING_TYPE            VARCHAR(50)         COMMENT 'Type of meeting where feature was used',
    USER_TENURE_DAYS        NUMBER              COMMENT 'Number of days since user registration',
    IS_FIRST_TIME_USAGE     BOOLEAN             COMMENT 'Whether this is user first time using the feature',
    
    -- Metadata Columns
    LOAD_DATE               DATE                COMMENT 'Date when record was loaded into Gold layer',
    UPDATE_DATE             DATE                COMMENT 'Date when record was last updated',
    SOURCE_SYSTEM           VARCHAR(100)        COMMENT 'Source system identifier'
)
COMMENT = 'Fact table capturing detailed feature usage patterns and adoption metrics';

-- =============================================
-- SECTION 2: DIMENSION TABLES
-- =============================================

-- =============================================
-- TABLE 5: GOLD.GO_USER_DIMENSION
-- Description: Slowly changing dimension containing user profile information with historical tracking (SCD Type 2)
-- =============================================

CREATE TABLE IF NOT EXISTS GOLD.GO_USER_DIMENSION (
    -- ID Field (Added in Physical Model)
    USER_DIMENSION_ID       VARCHAR(50)         COMMENT 'Unique identifier for each user dimension record',
    
    -- Business Columns from Gold Logical Model
    USER_NAME               VARCHAR(255)        COMMENT 'Full name of the user',
    EMAIL_DOMAIN            VARCHAR(100)        COMMENT 'Domain portion of user email address',
    COMPANY_NAME            VARCHAR(255)        COMMENT 'Organization name',
    PLAN_TYPE               VARCHAR(50)         COMMENT 'Current subscription plan',
    ACCOUNT_STATUS          VARCHAR(20)         COMMENT 'Current account status',
    REGISTRATION_DATE       DATE                COMMENT 'Date when user registered',
    USER_SEGMENT            VARCHAR(50)         COMMENT 'Business segment classification',
    GEOGRAPHIC_REGION       VARCHAR(100)        COMMENT 'Geographic region of the user',
    COMPANY_SIZE_CATEGORY   VARCHAR(50)         COMMENT 'Size category of user company',
    
    -- SCD Type 2 Columns
    EFFECTIVE_START_DATE    DATE                COMMENT 'Start date for this version of the record',
    EFFECTIVE_END_DATE      DATE                COMMENT 'End date for this version of the record',
    IS_CURRENT_RECORD       BOOLEAN             COMMENT 'Whether this is the current active record',
    
    -- Metadata Columns
    LOAD_DATE               DATE                COMMENT 'Date when record was loaded into Gold layer',
    UPDATE_DATE             DATE                COMMENT 'Date when record was last updated',
    SOURCE_SYSTEM           VARCHAR(100)        COMMENT 'Source system identifier'
)
COMMENT = 'Slowly changing dimension containing user profile information with historical tracking (SCD Type 2)';

-- =============================================
-- TABLE 6: GOLD.GO_DATE_DIMENSION
-- Description: Date dimension providing comprehensive date attributes for time-based analysis (SCD Type 1)
-- =============================================

CREATE TABLE IF NOT EXISTS GOLD.GO_DATE_DIMENSION (
    -- ID Field (Added in Physical Model)
    DATE_DIMENSION_ID       VARCHAR(50)         COMMENT 'Unique identifier for each date dimension record',
    
    -- Business Columns from Gold Logical Model
    DATE_KEY                DATE                COMMENT 'Primary date value',
    YEAR                    NUMBER              COMMENT 'Year component',
    QUARTER                 NUMBER              COMMENT 'Quarter number (1-4)',
    MONTH                   NUMBER              COMMENT 'Month number (1-12)',
    MONTH_NAME              VARCHAR(20)         COMMENT 'Full month name',
    WEEK_OF_YEAR            NUMBER              COMMENT 'Week number in the year',
    DAY_OF_MONTH            NUMBER              COMMENT 'Day of the month',
    DAY_OF_WEEK             NUMBER              COMMENT 'Day of the week (1-7)',
    DAY_NAME                VARCHAR(20)         COMMENT 'Full day name',
    IS_WEEKEND              BOOLEAN             COMMENT 'Whether the date falls on weekend',
    IS_HOLIDAY              BOOLEAN             COMMENT 'Whether the date is a business holiday',
    FISCAL_YEAR             NUMBER              COMMENT 'Fiscal year',
    FISCAL_QUARTER          NUMBER              COMMENT 'Fiscal quarter',
    BUSINESS_DAY_FLAG       BOOLEAN             COMMENT 'Whether the date is a business day',
    
    -- Metadata Columns
    LOAD_DATE               DATE                COMMENT 'Date when record was loaded into Gold layer',
    UPDATE_DATE             DATE                COMMENT 'Date when record was last updated',
    SOURCE_SYSTEM           VARCHAR(100)        COMMENT 'Source system identifier'
)
COMMENT = 'Date dimension providing comprehensive date attributes for time-based analysis (SCD Type 1)';

-- =============================================
-- TABLE 7: GOLD.GO_PLAN_DIMENSION
-- Description: Dimension containing subscription plan details and features (SCD Type 1)
-- =============================================

CREATE TABLE IF NOT EXISTS GOLD.GO_PLAN_DIMENSION (
    -- ID Field (Added in Physical Model)
    PLAN_DIMENSION_ID       VARCHAR(50)         COMMENT 'Unique identifier for each plan dimension record',
    
    -- Business Columns from Gold Logical Model
    PLAN_TYPE               VARCHAR(50)         COMMENT 'Plan type identifier',
    PLAN_NAME               VARCHAR(100)        COMMENT 'Descriptive plan name',
    PLAN_CATEGORY           VARCHAR(50)         COMMENT 'Plan category (Free, Paid, Enterprise)',
    MAX_PARTICIPANTS        NUMBER              COMMENT 'Maximum participants allowed',
    MEETING_DURATION_LIMIT  NUMBER              COMMENT 'Maximum meeting duration in minutes',
    RECORDING_ENABLED       BOOLEAN             COMMENT 'Whether recording is available',
    CLOUD_STORAGE_GB        NUMBER              COMMENT 'Cloud storage allocation in GB',
    ADMIN_FEATURES_ENABLED  BOOLEAN             COMMENT 'Whether admin features are available',
    API_ACCESS_ENABLED      BOOLEAN             COMMENT 'Whether API access is included',
    SUPPORT_LEVEL           VARCHAR(50)         COMMENT 'Level of customer support provided',
    MONTHLY_PRICE           NUMBER(10,2)        COMMENT 'Monthly subscription price',
    ANNUAL_PRICE            NUMBER(10,2)        COMMENT 'Annual subscription price',
    
    -- Metadata Columns
    LOAD_DATE               DATE                COMMENT 'Date when record was loaded into Gold layer',
    UPDATE_DATE             DATE                COMMENT 'Date when record was last updated',
    SOURCE_SYSTEM           VARCHAR(100)        COMMENT 'Source system identifier'
)
COMMENT = 'Dimension containing subscription plan details and features (SCD Type 1)';

-- =============================================
-- TABLE 8: GOLD.GO_FEATURE_DIMENSION
-- Description: Dimension containing feature definitions and categorizations (SCD Type 1)
-- =============================================

CREATE TABLE IF NOT EXISTS GOLD.GO_FEATURE_DIMENSION (
    -- ID Field (Added in Physical Model)
    FEATURE_DIMENSION_ID    VARCHAR(50)         COMMENT 'Unique identifier for each feature dimension record',
    
    -- Business Columns from Gold Logical Model
    FEATURE_NAME            VARCHAR(100)        COMMENT 'Name of the feature',
    FEATURE_CATEGORY        VARCHAR(50)         COMMENT 'Category classification',
    FEATURE_SUBCATEGORY     VARCHAR(50)         COMMENT 'Subcategory classification',
    FEATURE_DESCRIPTION     VARCHAR(1000)       COMMENT 'Detailed description of the feature',
    AVAILABILITY_BY_PLAN    VARCHAR(200)        COMMENT 'Plans that include this feature',
    IS_PREMIUM_FEATURE      BOOLEAN             COMMENT 'Whether feature requires premium plan',
    RELEASE_DATE            DATE                COMMENT 'Date when feature was released',
    DEPRECATION_DATE        DATE                COMMENT 'Date when feature was deprecated',
    USAGE_COMPLEXITY        VARCHAR(20)         COMMENT 'Complexity level (Simple, Moderate, Advanced)',
    BUSINESS_IMPACT         VARCHAR(50)         COMMENT 'Business impact category',
    
    -- Metadata Columns
    LOAD_DATE               DATE                COMMENT 'Date when record was loaded into Gold layer',
    UPDATE_DATE             DATE                COMMENT 'Date when record was last updated',
    SOURCE_SYSTEM           VARCHAR(100)        COMMENT 'Source system identifier'
)
COMMENT = 'Dimension containing feature definitions and categorizations (SCD Type 1)';

-- =============================================
-- SECTION 3: AGGREGATED TABLES
-- =============================================

-- =============================================
-- TABLE 9: GOLD.GO_DAILY_USAGE_SUMMARY
-- Description: Daily aggregated metrics for platform usage and adoption analysis
-- =============================================

CREATE TABLE IF NOT EXISTS GOLD.GO_DAILY_USAGE_SUMMARY (
    -- ID Field (Added in Physical Model)
    DAILY_SUMMARY_ID        VARCHAR(50)         COMMENT 'Unique identifier for each daily summary record',
    
    -- Business Columns from Gold Logical Model
    SUMMARY_DATE            DATE                COMMENT 'Date for which metrics are aggregated',
    TOTAL_MEETINGS          NUMBER              COMMENT 'Total number of meetings conducted',
    TOTAL_PARTICIPANTS      NUMBER              COMMENT 'Total number of unique participants',
    TOTAL_MEETING_MINUTES   NUMBER              COMMENT 'Sum of all meeting durations',
    AVERAGE_MEETING_DURATION NUMBER(10,2)       COMMENT 'Average meeting duration in minutes',
    DAILY_ACTIVE_USERS      NUMBER              COMMENT 'Number of unique active users',
    NEW_USER_REGISTRATIONS  NUMBER              COMMENT 'Number of new user sign-ups',
    MEETINGS_BY_PLAN_FREE   NUMBER              COMMENT 'Meetings hosted by Free plan users',
    MEETINGS_BY_PLAN_BASIC  NUMBER              COMMENT 'Meetings hosted by Basic plan users',
    MEETINGS_BY_PLAN_PRO    NUMBER              COMMENT 'Meetings hosted by Pro plan users',
    MEETINGS_BY_PLAN_ENTERPRISE NUMBER          COMMENT 'Meetings hosted by Enterprise plan users',
    RECORDED_MEETINGS_COUNT NUMBER              COMMENT 'Number of meetings that were recorded',
    WEBINAR_COUNT           NUMBER              COMMENT 'Number of webinars conducted',
    TOTAL_FEATURE_USAGE_EVENTS NUMBER           COMMENT 'Total feature usage events',
    UNIQUE_FEATURES_USED    NUMBER              COMMENT 'Number of unique features used',
    
    -- Metadata Columns
    LOAD_DATE               DATE                COMMENT 'Date when record was loaded',
    UPDATE_DATE             DATE                COMMENT 'Date when record was last updated',
    SOURCE_SYSTEM           VARCHAR(100)        COMMENT 'Source system identifier'
)
COMMENT = 'Daily aggregated metrics for platform usage and adoption analysis';

-- =============================================
-- TABLE 10: GOLD.GO_MONTHLY_REVENUE_SUMMARY
-- Description: Monthly aggregated revenue and billing metrics
-- =============================================

CREATE TABLE IF NOT EXISTS GOLD.GO_MONTHLY_REVENUE_SUMMARY (
    -- ID Field (Added in Physical Model)
    MONTHLY_REVENUE_ID      VARCHAR(50)         COMMENT 'Unique identifier for each monthly revenue record',
    
    -- Business Columns from Gold Logical Model
    SUMMARY_MONTH           DATE                COMMENT 'Month for which metrics are aggregated',
    TOTAL_REVENUE           NUMBER(15,2)        COMMENT 'Total revenue for the month',
    RECURRING_REVENUE       NUMBER(15,2)        COMMENT 'Monthly recurring revenue',
    ONE_TIME_REVENUE        NUMBER(15,2)        COMMENT 'One-time charges and fees',
    NEW_CUSTOMER_REVENUE    NUMBER(15,2)        COMMENT 'Revenue from new customers',
    EXPANSION_REVENUE       NUMBER(15,2)        COMMENT 'Revenue from plan upgrades',
    CHURN_REVENUE_LOST      NUMBER(15,2)        COMMENT 'Revenue lost due to churn',
    REFUND_AMOUNT           NUMBER(15,2)        COMMENT 'Total refunds processed',
    ACTIVE_LICENSES         NUMBER              COMMENT 'Number of active licenses',
    NEW_LICENSES_SOLD       NUMBER              COMMENT 'Number of new licenses sold',
    LICENSES_CANCELLED      NUMBER              COMMENT 'Number of licenses cancelled',
    AVERAGE_REVENUE_PER_USER NUMBER(10,2)       COMMENT 'Average revenue per user',
    CUSTOMER_ACQUISITION_COST NUMBER(10,2)      COMMENT 'Cost to acquire new customers',
    CUSTOMER_LIFETIME_VALUE NUMBER(15,2)        COMMENT 'Average customer lifetime value',
    CHURN_RATE_PERCENTAGE   NUMBER(5,2)         COMMENT 'Customer churn rate',
    
    -- Metadata Columns
    LOAD_DATE               DATE                COMMENT 'Date when record was loaded',
    UPDATE_DATE             DATE                COMMENT 'Date when record was last updated',
    SOURCE_SYSTEM           VARCHAR(100)        COMMENT 'Source system identifier'
)
COMMENT = 'Monthly aggregated revenue and billing metrics';

-- =============================================
-- TABLE 11: GOLD.GO_WEEKLY_SUPPORT_SUMMARY
-- Description: Weekly aggregated support ticket metrics and performance indicators
-- =============================================

CREATE TABLE IF NOT EXISTS GOLD.GO_WEEKLY_SUPPORT_SUMMARY (
    -- ID Field (Added in Physical Model)
    WEEKLY_SUPPORT_ID       VARCHAR(50)         COMMENT 'Unique identifier for each weekly support record',
    
    -- Business Columns from Gold Logical Model
    SUMMARY_WEEK            DATE                COMMENT 'Week start date for aggregated metrics',
    TOTAL_TICKETS_CREATED   NUMBER              COMMENT 'Total number of tickets created',
    TOTAL_TICKETS_RESOLVED  NUMBER              COMMENT 'Total number of tickets resolved',
    TICKETS_BY_TYPE_TECHNICAL NUMBER            COMMENT 'Technical support tickets',
    TICKETS_BY_TYPE_BILLING NUMBER              COMMENT 'Billing-related tickets',
    TICKETS_BY_TYPE_FEATURE NUMBER              COMMENT 'Feature request tickets',
    TICKETS_BY_TYPE_BUG     NUMBER              COMMENT 'Bug report tickets',
    TICKETS_BY_PRIORITY_CRITICAL NUMBER         COMMENT 'Critical priority tickets',
    TICKETS_BY_PRIORITY_HIGH NUMBER             COMMENT 'High priority tickets',
    TICKETS_BY_PRIORITY_MEDIUM NUMBER           COMMENT 'Medium priority tickets',
    TICKETS_BY_PRIORITY_LOW NUMBER              COMMENT 'Low priority tickets',
    AVERAGE_RESOLUTION_TIME_HOURS NUMBER(10,2)  COMMENT 'Average time to resolve tickets',
    FIRST_CONTACT_RESOLUTION_RATE NUMBER(5,2)   COMMENT 'Percentage resolved on first contact',
    ESCALATION_RATE         NUMBER(5,2)         COMMENT 'Percentage of tickets escalated',
    CUSTOMER_SATISFACTION_AVG NUMBER(3,2)       COMMENT 'Average customer satisfaction score',
    TICKETS_PER_1000_USERS  NUMBER(10,2)        COMMENT 'Ticket density per 1000 active users',
    
    -- Metadata Columns
    LOAD_DATE               DATE                COMMENT 'Date when record was loaded',
    UPDATE_DATE             DATE                COMMENT 'Date when record was last updated',
    SOURCE_SYSTEM           VARCHAR(100)        COMMENT 'Source system identifier'
)
COMMENT = 'Weekly aggregated support ticket metrics and performance indicators';

-- =============================================
-- SECTION 4: ERROR DATA TABLE
-- =============================================

-- =============================================
-- TABLE 12: GOLD.GO_DATA_VALIDATION_ERRORS
-- Description: Table storing data validation errors and quality issues from Gold layer processing
-- =============================================

CREATE TABLE IF NOT EXISTS GOLD.GO_DATA_VALIDATION_ERRORS (
    -- ID Field (Added in Physical Model)
    ERROR_ID                VARCHAR(50)         COMMENT 'Unique identifier for each error',
    
    -- Business Columns from Gold Logical Model
    SOURCE_TABLE            VARCHAR(100)        COMMENT 'Source table where error was detected',
    TARGET_TABLE            VARCHAR(100)        COMMENT 'Target table being processed',
    ERROR_TYPE              VARCHAR(50)         COMMENT 'Type of validation error',
    ERROR_CATEGORY          VARCHAR(50)         COMMENT 'Category of error (Data Quality, Business Rule, Technical)',
    ERROR_SEVERITY          VARCHAR(20)         COMMENT 'Severity level (Critical, High, Medium, Low)',
    ERROR_DESCRIPTION       VARCHAR(1000)       COMMENT 'Detailed description of the error',
    AFFECTED_COLUMN         VARCHAR(100)        COMMENT 'Column where error was detected',
    ERROR_VALUE             VARCHAR(1000)       COMMENT 'Value that caused the error',
    EXPECTED_VALUE_PATTERN  VARCHAR(1000)       COMMENT 'Expected value pattern or range',
    BUSINESS_RULE_VIOLATED  VARCHAR(200)        COMMENT 'Business rule that was violated',
    DETECTION_TIMESTAMP     TIMESTAMP_NTZ(9)    COMMENT 'When error was detected',
    RESOLUTION_STATUS       VARCHAR(20)         COMMENT 'Status of error resolution',
    RESOLUTION_ACTION       VARCHAR(1000)       COMMENT 'Action taken to resolve error',
    RESOLVED_TIMESTAMP      TIMESTAMP_NTZ(9)    COMMENT 'When error was resolved',
    RESOLVED_BY             VARCHAR(100)        COMMENT 'Who resolved the error',
    IMPACT_ASSESSMENT       VARCHAR(1000)       COMMENT 'Assessment of error impact on business',
    
    -- Metadata Columns
    LOAD_DATE               DATE                COMMENT 'Date when record was loaded',
    UPDATE_DATE             DATE                COMMENT 'Date when record was last updated',
    SOURCE_SYSTEM           VARCHAR(100)        COMMENT 'Source system identifier'
)
COMMENT = 'Table storing data validation errors and quality issues from Gold layer processing';

-- =============================================
-- SECTION 5: AUDIT TABLE
-- =============================================

-- =============================================
-- TABLE 13: GOLD.GO_PIPELINE_EXECUTION_AUDIT
-- Description: Comprehensive audit table for tracking Gold layer pipeline execution details
-- =============================================

CREATE TABLE IF NOT EXISTS GOLD.GO_PIPELINE_EXECUTION_AUDIT (
    -- ID Field (Added in Physical Model)
    EXECUTION_ID            VARCHAR(50)         COMMENT 'Unique identifier for pipeline execution',
    
    -- Business Columns from Gold Logical Model
    PIPELINE_NAME           VARCHAR(200)        COMMENT 'Name of the executed pipeline',
    EXECUTION_START_TIME    TIMESTAMP_NTZ(9)    COMMENT 'Pipeline execution start timestamp',
    EXECUTION_END_TIME      TIMESTAMP_NTZ(9)    COMMENT 'Pipeline execution end timestamp',
    EXECUTION_DURATION_SECONDS NUMBER           COMMENT 'Total execution time in seconds',
    EXECUTION_STATUS        VARCHAR(20)         COMMENT 'Status (Success, Failed, Partial Success)',
    SOURCE_TABLES_PROCESSED VARCHAR(1000)       COMMENT 'List of source tables processed',
    TARGET_TABLES_UPDATED   VARCHAR(1000)       COMMENT 'List of target tables updated',
    RECORDS_PROCESSED       NUMBER              COMMENT 'Total number of records processed',
    RECORDS_INSERTED        NUMBER              COMMENT 'Number of new records inserted',
    RECORDS_UPDATED         NUMBER              COMMENT 'Number of existing records updated',
    RECORDS_REJECTED        NUMBER              COMMENT 'Number of records rejected',
    DATA_QUALITY_SCORE      NUMBER(5,2)         COMMENT 'Overall data quality score for execution',
    ERROR_MESSAGE           VARCHAR(1000)       COMMENT 'Error details if execution failed',
    EXECUTED_BY             VARCHAR(100)        COMMENT 'User or system that executed pipeline',
    EXECUTION_ENVIRONMENT   VARCHAR(50)         COMMENT 'Environment (Dev, Test, Prod)',
    RESOURCE_UTILIZATION    VARCHAR(1000)       COMMENT 'CPU, memory, and storage utilization metrics',
    
    -- Metadata Columns
    LOAD_DATE               DATE                COMMENT 'Date when record was loaded',
    UPDATE_DATE             DATE                COMMENT 'Date when record was last updated',
    SOURCE_SYSTEM           VARCHAR(100)        COMMENT 'Source system identifier'
)
COMMENT = 'Comprehensive audit table for tracking Gold layer pipeline execution details';

-- =============================================
-- SECTION 6: UPDATE DDL SCRIPTS
-- =============================================

-- =============================================
-- Schema Evolution Scripts
-- Description: Scripts to handle schema changes and updates
-- =============================================

-- Add new column to existing table (example)
-- ALTER TABLE GOLD.GO_MEETING_ACTIVITY_FACT ADD COLUMN NEW_METRIC NUMBER COMMENT 'Description of new metric';

-- Modify column data type (example)
-- ALTER TABLE GOLD.GO_USER_DIMENSION ALTER COLUMN USER_NAME SET DATA TYPE VARCHAR(300);

-- Add clustering key for performance optimization (example)
-- ALTER TABLE GOLD.GO_MEETING_ACTIVITY_FACT CLUSTER BY (MEETING_DATE, HOST_PLAN_TYPE);
-- ALTER TABLE GOLD.GO_REVENUE_FACT CLUSTER BY (TRANSACTION_DATE, CUSTOMER_PLAN_TYPE);
-- ALTER TABLE GOLD.GO_FEATURE_USAGE_FACT CLUSTER BY (USAGE_DATE, FEATURE_CATEGORY);

-- Create views for commonly used queries (example)
-- CREATE OR REPLACE VIEW GOLD.VW_ACTIVE_USERS AS
-- SELECT USER_NAME, EMAIL_DOMAIN, COMPANY_NAME, PLAN_TYPE
-- FROM GOLD.GO_USER_DIMENSION
-- WHERE ACCOUNT_STATUS = 'Active' AND IS_CURRENT_RECORD = TRUE;

-- CREATE OR REPLACE VIEW GOLD.VW_MONTHLY_METRICS AS
-- SELECT 
--     DATE_TRUNC('MONTH', SUMMARY_DATE) as MONTH,
--     SUM(TOTAL_MEETINGS) as TOTAL_MEETINGS,
--     SUM(DAILY_ACTIVE_USERS) as TOTAL_ACTIVE_USERS,
--     AVG(AVERAGE_MEETING_DURATION) as AVG_MEETING_DURATION
-- FROM GOLD.GO_DAILY_USAGE_SUMMARY
-- GROUP BY DATE_TRUNC('MONTH', SUMMARY_DATE);

-- =============================================
-- GOLD LAYER SUMMARY
-- =============================================

/*
GOLD LAYER TABLES CREATED:

## 1. FACT TABLES (4 tables):
1. GOLD.GO_MEETING_ACTIVITY_FACT     - Meeting activities and platform usage metrics (14 columns)
2. GOLD.GO_SUPPORT_TICKET_FACT       - Support ticket metrics and resolution performance (12 columns)
3. GOLD.GO_REVENUE_FACT              - Billing events and revenue metrics (13 columns)
4. GOLD.GO_FEATURE_USAGE_FACT        - Feature usage patterns and adoption metrics (12 columns)

## 2. DIMENSION TABLES (4 tables):
5. GOLD.GO_USER_DIMENSION            - User profile information with SCD Type 2 (16 columns)
6. GOLD.GO_DATE_DIMENSION            - Comprehensive date attributes (17 columns)
7. GOLD.GO_PLAN_DIMENSION            - Subscription plan details and features (15 columns)
8. GOLD.GO_FEATURE_DIMENSION         - Feature definitions and categorizations (13 columns)

## 3. AGGREGATED TABLES (3 tables):
9. GOLD.GO_DAILY_USAGE_SUMMARY       - Daily aggregated platform usage metrics (18 columns)
10. GOLD.GO_MONTHLY_REVENUE_SUMMARY  - Monthly aggregated revenue and billing metrics (18 columns)
11. GOLD.GO_WEEKLY_SUPPORT_SUMMARY   - Weekly aggregated support ticket metrics (19 columns)

## 4. PROCESS AUDIT TABLES (1 table):
12. GOLD.GO_PIPELINE_EXECUTION_AUDIT - Gold layer pipeline execution audit trail (20 columns)

## 5. ERROR DATA TABLES (1 table):
13. GOLD.GO_DATA_VALIDATION_ERRORS   - Data validation errors and quality issues (20 columns)

KEY FEATURES:
• All tables follow 'GO_' naming convention for Gold layer identification
• ID fields added to all tables as required by physical model specifications
• All columns from Silver layer are incorporated into appropriate Gold layer tables
• Snowflake-compatible data types used throughout (VARCHAR, NUMBER, BOOLEAN, DATE, TIMESTAMP_NTZ)
• No primary keys, foreign keys, or constraints (following Snowflake best practices)
• Comprehensive metadata columns for data lineage and quality tracking
• Dimensional modeling with star schema design for optimal analytics performance
• SCD Type 2 implementation for user dimension to track historical changes
• Pre-calculated aggregations for common reporting requirements
• Error tracking and audit capabilities for data governance
• CREATE TABLE IF NOT EXISTS syntax for safe deployment
• Detailed column comments for documentation
• Schema evolution scripts for future updates
• Clustering recommendations for performance optimization

DATA FLOW:
RAW Schema → BRONZE Schema → SILVER Schema → GOLD Schema

This Gold Physical Data Model serves as the business-ready analytical layer in the Medallion architecture,
storing dimensional and aggregated data optimized for reporting, analytics, and business intelligence
consumption while maintaining comprehensive audit trails and data quality management.

API Cost: 0.003254 USD
*/

-- End of Gold Physical Data Model DDL Script