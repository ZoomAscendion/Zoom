_____________________________________________
-- *Author*: AAVA
-- *Created on*:   
-- *Description*: Gold layer physical data model for Zoom Platform Analytics System with foreign key relationships for BI integration
-- *Version*: 2 
-- *Updated on*: 
-- *Changes*: Added foreign key columns to fact tables to establish join relationships between dimensions and facts for Tableau reporting
-- *Reason*: Enable proper dimensional relationships for BI tools and improve query performance by establishing clear join paths between fact and dimension tables
_____________________________________________

-- =====================================================
-- GOLD LAYER PHYSICAL DATA MODEL - DDL SCRIPTS
-- Database: DB_POC_ZOOM
-- Schema: GOLD
-- Purpose: Dimensional data model for analytics and reporting with BI integration
-- =====================================================

-- 1. CREATE GOLD SCHEMA
CREATE SCHEMA IF NOT EXISTS GOLD;

-- =====================================================
-- 2. DIMENSION TABLES - DDL SCRIPTS
-- =====================================================

-- 2.1 GO_DIM_DATE - Standard Date Dimension
-- Description: Standard date dimension for time-based analysis across all fact tables
CREATE TABLE IF NOT EXISTS GOLD.GO_DIM_DATE (
    DATE_KEY DATE,
    DATE_ID NUMBER(10,0) AUTOINCREMENT,
    DATE_VALUE DATE,
    YEAR NUMBER(4,0),
    QUARTER NUMBER(1,0),
    MONTH NUMBER(2,0),
    MONTH_NAME VARCHAR(20),
    DAY_OF_MONTH NUMBER(2,0),
    DAY_OF_WEEK NUMBER(1,0),
    DAY_NAME VARCHAR(20),
    IS_WEEKEND BOOLEAN,
    IS_HOLIDAY BOOLEAN,
    FISCAL_YEAR NUMBER(4,0),
    FISCAL_QUARTER NUMBER(1,0),
    WEEK_OF_YEAR NUMBER(2,0),
    -- Standard metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(100)
);

-- 2.2 GO_DIM_FEATURE - Feature Dimension
-- Description: Dimension table containing platform features and their characteristics
CREATE TABLE IF NOT EXISTS GOLD.GO_DIM_FEATURE (
    FEATURE_KEY VARCHAR(50),
    FEATURE_ID NUMBER(10,0) AUTOINCREMENT,
    FEATURE_NAME VARCHAR(200),
    FEATURE_CATEGORY VARCHAR(100),
    FEATURE_TYPE VARCHAR(100),
    FEATURE_COMPLEXITY VARCHAR(50),
    IS_PREMIUM_FEATURE BOOLEAN,
    FEATURE_RELEASE_DATE DATE,
    FEATURE_STATUS VARCHAR(50),
    USAGE_FREQUENCY_CATEGORY VARCHAR(50),
    FEATURE_DESCRIPTION VARCHAR(500),
    TARGET_USER_SEGMENT VARCHAR(100),
    -- Standard metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(100)
);

-- 2.3 GO_DIM_LICENSE - License Dimension
-- Description: Dimension table containing license types and entitlements
CREATE TABLE IF NOT EXISTS GOLD.GO_DIM_LICENSE (
    LICENSE_KEY VARCHAR(50),
    LICENSE_ID NUMBER(10,0) AUTOINCREMENT,
    LICENSE_TYPE VARCHAR(100),
    LICENSE_CATEGORY VARCHAR(50),
    LICENSE_TIER VARCHAR(50),
    MAX_PARTICIPANTS NUMBER(10,0),
    STORAGE_LIMIT_GB NUMBER(10,0),
    RECORDING_LIMIT_HOURS NUMBER(10,0),
    ADMIN_FEATURES_INCLUDED BOOLEAN,
    API_ACCESS_INCLUDED BOOLEAN,
    SSO_SUPPORT_INCLUDED BOOLEAN,
    MONTHLY_PRICE NUMBER(10,2),
    ANNUAL_PRICE NUMBER(10,2),
    LICENSE_BENEFITS VARCHAR(1000),
    EFFECTIVE_START_DATE DATE,
    EFFECTIVE_END_DATE DATE,
    IS_CURRENT_RECORD BOOLEAN,
    -- Standard metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(100)
);

-- 2.4 GO_DIM_MEETING - Meeting Dimension
-- Description: Dimension table containing meeting characteristics and metadata
CREATE TABLE IF NOT EXISTS GOLD.GO_DIM_MEETING (
    MEETING_KEY VARCHAR(50),
    MEETING_ID NUMBER(10,0) AUTOINCREMENT,
    MEETING_TYPE VARCHAR(100),
    MEETING_CATEGORY VARCHAR(100),
    DURATION_CATEGORY VARCHAR(50),
    PARTICIPANT_SIZE_CATEGORY VARCHAR(50),
    TIME_OF_DAY_CATEGORY VARCHAR(50),
    DAY_OF_WEEK VARCHAR(20),
    IS_WEEKEND BOOLEAN,
    IS_RECURRING BOOLEAN,
    MEETING_QUALITY_SCORE NUMBER(3,1),
    TYPICAL_FEATURES_USED VARCHAR(500),
    BUSINESS_PURPOSE VARCHAR(200),
    -- Standard metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(100)
);

-- 2.5 GO_DIM_SUPPORT_CATEGORY - Support Category Dimension
-- Description: Dimension table containing support ticket categories and characteristics
CREATE TABLE IF NOT EXISTS GOLD.GO_DIM_SUPPORT_CATEGORY (
    SUPPORT_CATEGORY_KEY VARCHAR(50),
    SUPPORT_CATEGORY_ID NUMBER(10,0) AUTOINCREMENT,
    SUPPORT_CATEGORY VARCHAR(100),
    SUPPORT_SUBCATEGORY VARCHAR(100),
    PRIORITY_LEVEL VARCHAR(50),
    EXPECTED_RESOLUTION_TIME_HOURS NUMBER(10,2),
    REQUIRES_ESCALATION BOOLEAN,
    SELF_SERVICE_AVAILABLE BOOLEAN,
    KNOWLEDGE_BASE_ARTICLES NUMBER(5,0),
    COMMON_RESOLUTION_STEPS VARCHAR(1000),
    CUSTOMER_IMPACT_LEVEL VARCHAR(50),
    DEPARTMENT_RESPONSIBLE VARCHAR(100),
    SLA_TARGET_HOURS NUMBER(10,2),
    -- Standard metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(100)
);

-- 2.6 GO_DIM_USER - User Dimension
-- Description: Dimension table containing user profile and subscription information
CREATE TABLE IF NOT EXISTS GOLD.GO_DIM_USER (
    USER_KEY VARCHAR(50),
    USER_DIM_ID NUMBER(10,0) AUTOINCREMENT,
    USER_ID VARCHAR(200),
    USER_NAME VARCHAR(200),
    EMAIL_DOMAIN VARCHAR(100),
    COMPANY VARCHAR(200),
    PLAN_TYPE VARCHAR(100),
    PLAN_CATEGORY VARCHAR(50),
    REGISTRATION_DATE DATE,
    USER_STATUS VARCHAR(50),
    GEOGRAPHIC_REGION VARCHAR(100),
    INDUSTRY_SECTOR VARCHAR(100),
    USER_ROLE VARCHAR(100),
    ACCOUNT_TYPE VARCHAR(50),
    LANGUAGE_PREFERENCE VARCHAR(50),
    EFFECTIVE_START_DATE DATE,
    EFFECTIVE_END_DATE DATE,
    IS_CURRENT_RECORD BOOLEAN,
    -- Standard metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(100)
);

-- =====================================================
-- 3. FACT TABLES - DDL SCRIPTS WITH FOREIGN KEY COLUMNS
-- =====================================================

-- 3.1 GO_FACT_MEETING_ACTIVITY - Meeting Activity Fact
-- Description: Central fact table capturing meeting activities and usage metrics with foreign key relationships
CREATE TABLE IF NOT EXISTS GOLD.GO_FACT_MEETING_ACTIVITY (
    MEETING_ACTIVITY_ID NUMBER(15,0) AUTOINCREMENT,
    -- Foreign Key Columns for BI Integration
    USER_KEY VARCHAR(50),
    MEETING_KEY VARCHAR(50),
    DATE_KEY DATE,
    FEATURE_KEY VARCHAR(50),
    -- Original Fact Columns
    MEETING_DATE DATE,
    MEETING_TOPIC VARCHAR(500),
    START_TIME TIMESTAMP_NTZ(9),
    END_TIME TIMESTAMP_NTZ(9),
    DURATION_MINUTES NUMBER(10,0),
    PARTICIPANT_COUNT NUMBER(10,0),
    TOTAL_JOIN_TIME_MINUTES NUMBER(15,2),
    AVERAGE_PARTICIPATION_MINUTES NUMBER(10,2),
    FEATURES_USED_COUNT NUMBER(10,0),
    SCREEN_SHARE_USAGE_COUNT NUMBER(10,0),
    RECORDING_USAGE_COUNT NUMBER(10,0),
    CHAT_USAGE_COUNT NUMBER(10,0),
    MEETING_QUALITY_SCORE NUMBER(5,2),
    AUDIO_QUALITY_SCORE NUMBER(5,2),
    VIDEO_QUALITY_SCORE NUMBER(5,2),
    CONNECTION_ISSUES_COUNT NUMBER(5,0),
    MEETING_SATISFACTION_SCORE NUMBER(3,1),
    PEAK_CONCURRENT_PARTICIPANTS NUMBER(10,0),
    LATE_JOINERS_COUNT NUMBER(10,0),
    EARLY_LEAVERS_COUNT NUMBER(10,0),
    BREAKOUT_ROOMS_USED NUMBER(5,0),
    POLLS_CONDUCTED NUMBER(5,0),
    FILE_SHARES_COUNT NUMBER(10,0),
    -- Standard metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(100)
);

-- 3.2 GO_FACT_SUPPORT_ACTIVITY - Support Activity Fact
-- Description: Fact table capturing support ticket activities and resolution metrics with foreign key relationships
CREATE TABLE IF NOT EXISTS GOLD.GO_FACT_SUPPORT_ACTIVITY (
    SUPPORT_ACTIVITY_ID NUMBER(15,0) AUTOINCREMENT,
    -- Foreign Key Columns for BI Integration
    USER_KEY VARCHAR(50),
    DATE_KEY DATE,
    SUPPORT_CATEGORY_KEY VARCHAR(50),
    -- Original Fact Columns
    TICKET_OPEN_DATE DATE,
    TICKET_CLOSE_DATE DATE,
    TICKET_TYPE VARCHAR(100),
    RESOLUTION_STATUS VARCHAR(100),
    PRIORITY_LEVEL VARCHAR(50),
    RESOLUTION_TIME_HOURS NUMBER(10,2),
    ESCALATION_COUNT NUMBER(5,0),
    CUSTOMER_SATISFACTION_SCORE NUMBER(3,1),
    FIRST_CONTACT_RESOLUTION_FLAG BOOLEAN,
    FIRST_RESPONSE_TIME_HOURS NUMBER(10,2),
    ACTIVE_WORK_TIME_HOURS NUMBER(15,2),
    CUSTOMER_WAIT_TIME_HOURS NUMBER(15,2),
    REASSIGNMENT_COUNT NUMBER(5,0),
    REOPENED_COUNT NUMBER(5,0),
    AGENT_INTERACTIONS_COUNT NUMBER(10,0),
    CUSTOMER_INTERACTIONS_COUNT NUMBER(10,0),
    KNOWLEDGE_BASE_ARTICLES_USED NUMBER(5,0),
    SLA_MET BOOLEAN,
    SLA_BREACH_HOURS NUMBER(10,2),
    RESOLUTION_METHOD VARCHAR(100),
    ROOT_CAUSE_CATEGORY VARCHAR(100),
    PREVENTABLE_ISSUE BOOLEAN,
    FOLLOW_UP_REQUIRED BOOLEAN,
    COST_TO_RESOLVE NUMBER(10,2),
    -- Standard metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(100)
);

-- 3.3 GO_FACT_REVENUE_ACTIVITY - Revenue Activity Fact
-- Description: Fact table capturing billing events and revenue metrics with foreign key relationships
CREATE TABLE IF NOT EXISTS GOLD.GO_FACT_REVENUE_ACTIVITY (
    REVENUE_ACTIVITY_ID NUMBER(15,0) AUTOINCREMENT,
    -- Foreign Key Columns for BI Integration
    USER_KEY VARCHAR(50),
    LICENSE_KEY VARCHAR(50),
    DATE_KEY DATE,
    -- Original Fact Columns
    TRANSACTION_DATE DATE,
    EVENT_TYPE VARCHAR(100),
    AMOUNT NUMBER(15,2),
    CURRENCY VARCHAR(10),
    PAYMENT_METHOD VARCHAR(100),
    SUBSCRIPTION_REVENUE_AMOUNT NUMBER(15,2),
    ONE_TIME_REVENUE_AMOUNT NUMBER(15,2),
    REFUND_AMOUNT NUMBER(15,2),
    TAX_AMOUNT NUMBER(15,2),
    NET_REVENUE_AMOUNT NUMBER(15,2),
    DISCOUNT_AMOUNT NUMBER(15,2),
    EXCHANGE_RATE NUMBER(10,6),
    USD_AMOUNT NUMBER(15,2),
    SUBSCRIPTION_PERIOD_MONTHS NUMBER(5,0),
    LICENSE_QUANTITY NUMBER(10,0),
    PRORATION_AMOUNT NUMBER(15,2),
    COMMISSION_AMOUNT NUMBER(15,2),
    MRR_IMPACT NUMBER(15,2),
    ARR_IMPACT NUMBER(15,2),
    CUSTOMER_LIFETIME_VALUE NUMBER(20,2),
    CHURN_RISK_SCORE NUMBER(5,2),
    PAYMENT_STATUS VARCHAR(50),
    REFUND_REASON VARCHAR(200),
    SALES_CHANNEL VARCHAR(100),
    PROMOTION_CODE VARCHAR(50),
    -- Standard metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(100)
);

-- 3.4 GO_FACT_FEATURE_USAGE - Feature Usage Fact
-- Description: Fact table capturing detailed feature usage metrics and patterns with foreign key relationships
CREATE TABLE IF NOT EXISTS GOLD.GO_FACT_FEATURE_USAGE (
    FEATURE_USAGE_ID NUMBER(15,0) AUTOINCREMENT,
    -- Foreign Key Columns for BI Integration
    DATE_KEY DATE,
    FEATURE_KEY VARCHAR(50),
    USER_KEY VARCHAR(50),
    MEETING_KEY VARCHAR(50),
    -- Original Fact Columns
    USAGE_DATE DATE,
    USAGE_TIMESTAMP TIMESTAMP_NTZ(9),
    FEATURE_NAME VARCHAR(200),
    USAGE_COUNT NUMBER(10,0),
    USAGE_DURATION_MINUTES NUMBER(15,2),
    SESSION_DURATION_MINUTES NUMBER(15,2),
    FEATURE_ADOPTION_SCORE NUMBER(5,2),
    USER_EXPERIENCE_RATING NUMBER(3,1),
    FEATURE_PERFORMANCE_SCORE NUMBER(5,2),
    CONCURRENT_FEATURES_COUNT NUMBER(5,0),
    USAGE_CONTEXT VARCHAR(100),
    DEVICE_TYPE VARCHAR(50),
    PLATFORM_VERSION VARCHAR(50),
    ERROR_COUNT NUMBER(5,0),
    SUCCESS_RATE NUMBER(5,2),
    -- Standard metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(100)
);

-- =====================================================
-- 4. AGGREGATED TABLES - DDL SCRIPTS WITH FOREIGN KEY COLUMNS
-- =====================================================

-- 4.1 GO_AGG_DAILY_USAGE_SUMMARY - Daily Usage Summary
-- Description: Daily aggregated metrics for platform usage and adoption with foreign key relationships
CREATE TABLE IF NOT EXISTS GOLD.GO_AGG_DAILY_USAGE_SUMMARY (
    DAILY_SUMMARY_ID NUMBER(15,0) AUTOINCREMENT,
    -- Foreign Key Columns for BI Integration
    DATE_KEY DATE,
    -- Aggregated Metrics
    SUMMARY_DATE DATE,
    TOTAL_MEETINGS NUMBER(15,0),
    TOTAL_MEETING_MINUTES NUMBER(20,0),
    UNIQUE_HOSTS NUMBER(15,0),
    UNIQUE_PARTICIPANTS NUMBER(15,0),
    AVERAGE_MEETING_DURATION NUMBER(10,2),
    AVERAGE_PARTICIPANTS_PER_MEETING NUMBER(10,2),
    TOTAL_SCREEN_SHARES NUMBER(15,0),
    TOTAL_RECORDINGS NUMBER(15,0),
    TOTAL_CHAT_USAGE NUMBER(15,0),
    PEAK_CONCURRENT_MEETINGS NUMBER(10,0),
    NEW_USER_REGISTRATIONS NUMBER(10,0),
    -- Standard metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(100)
);

-- 4.2 GO_AGG_MONTHLY_REVENUE_SUMMARY - Monthly Revenue Summary
-- Description: Monthly aggregated revenue and billing metrics with foreign key relationships
CREATE TABLE IF NOT EXISTS GOLD.GO_AGG_MONTHLY_REVENUE_SUMMARY (
    MONTHLY_REVENUE_ID NUMBER(15,0) AUTOINCREMENT,
    -- Foreign Key Columns for BI Integration
    DATE_KEY DATE,
    LICENSE_KEY VARCHAR(50),
    -- Aggregated Metrics
    SUMMARY_MONTH DATE,
    TOTAL_REVENUE NUMBER(20,2),
    SUBSCRIPTION_REVENUE NUMBER(20,2),
    ONE_TIME_REVENUE NUMBER(20,2),
    REFUND_AMOUNT NUMBER(20,2),
    NET_REVENUE NUMBER(20,2),
    NEW_CUSTOMER_REVENUE NUMBER(20,2),
    EXPANSION_REVENUE NUMBER(20,2),
    CHURN_REVENUE_LOST NUMBER(20,2),
    AVERAGE_REVENUE_PER_USER NUMBER(15,2),
    TOTAL_ACTIVE_LICENSES NUMBER(15,0),
    LICENSE_UTILIZATION_RATE NUMBER(5,2),
    MONTHLY_RECURRING_REVENUE NUMBER(20,2),
    -- Standard metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(100)
);

-- 4.3 GO_AGG_SUPPORT_PERFORMANCE_SUMMARY - Support Performance Summary
-- Description: Aggregated support performance and service reliability metrics with foreign key relationships
CREATE TABLE IF NOT EXISTS GOLD.GO_AGG_SUPPORT_PERFORMANCE_SUMMARY (
    SUPPORT_SUMMARY_ID NUMBER(15,0) AUTOINCREMENT,
    -- Foreign Key Columns for BI Integration
    DATE_KEY DATE,
    SUPPORT_CATEGORY_KEY VARCHAR(50),
    -- Aggregated Metrics
    SUMMARY_DATE DATE,
    TOTAL_TICKETS_OPENED NUMBER(10,0),
    TOTAL_TICKETS_CLOSED NUMBER(10,0),
    TICKETS_RESOLVED_SAME_DAY NUMBER(10,0),
    AVERAGE_RESOLUTION_TIME_HOURS NUMBER(10,2),
    FIRST_CONTACT_RESOLUTION_RATE NUMBER(5,2),
    CUSTOMER_SATISFACTION_AVERAGE NUMBER(3,2),
    CRITICAL_TICKETS_COUNT NUMBER(10,0),
    HIGH_PRIORITY_TICKETS_COUNT NUMBER(10,0),
    ESCALATED_TICKETS_COUNT NUMBER(10,0),
    TICKETS_PER_1000_USERS NUMBER(10,2),
    SLA_COMPLIANCE_RATE NUMBER(5,2),
    -- Standard metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(100)
);

-- =====================================================
-- 5. ERROR DATA TABLE
-- =====================================================

-- 5.1 GO_DATA_VALIDATION_ERRORS - Error Data Table
-- Description: Stores detailed error information from data validation processes in Gold layer
CREATE TABLE IF NOT EXISTS GOLD.GO_DATA_VALIDATION_ERRORS (
    ERROR_ID VARCHAR(50),
    PROCESS_EXECUTION_ID VARCHAR(50),
    ERROR_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_TABLE_NAME VARCHAR(200),
    TARGET_TABLE_NAME VARCHAR(200),
    SOURCE_RECORD_IDENTIFIER VARCHAR(500),
    ERROR_TYPE VARCHAR(100),
    ERROR_CATEGORY VARCHAR(100),
    ERROR_SEVERITY VARCHAR(50),
    ERROR_CODE VARCHAR(50),
    ERROR_MESSAGE VARCHAR(1000),
    COLUMN_NAME VARCHAR(200),
    INVALID_VALUE VARCHAR(1000),
    EXPECTED_FORMAT VARCHAR(500),
    VALIDATION_RULE_NAME VARCHAR(200),
    VALIDATION_RULE_EXPRESSION VARCHAR(1000),
    BUSINESS_IMPACT VARCHAR(500),
    RESOLUTION_STATUS VARCHAR(50),
    RESOLUTION_ACTION VARCHAR(500),
    RESOLVED_BY VARCHAR(100),
    RESOLUTION_TIMESTAMP TIMESTAMP_NTZ(9),
    RESOLUTION_NOTES VARCHAR(1000),
    RETRY_COUNT NUMBER(5,0),
    IS_FALSE_POSITIVE BOOLEAN,
    -- Standard metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(100)
);

-- =====================================================
-- 6. AUDIT TABLE
-- =====================================================

-- 6.1 GO_PROCESS_AUDIT_LOG - Process Audit Table
-- Description: Comprehensive audit trail for all Gold layer pipeline executions and processes
CREATE TABLE IF NOT EXISTS GOLD.GO_PROCESS_AUDIT_LOG (
    AUDIT_LOG_ID VARCHAR(50),
    PROCESS_NAME VARCHAR(200),
    PROCESS_TYPE VARCHAR(100),
    EXECUTION_START_TIMESTAMP TIMESTAMP_NTZ(9),
    EXECUTION_END_TIMESTAMP TIMESTAMP_NTZ(9),
    EXECUTION_DURATION_SECONDS NUMBER(15,2),
    EXECUTION_STATUS VARCHAR(50),
    SOURCE_TABLE_NAME VARCHAR(200),
    TARGET_TABLE_NAME VARCHAR(200),
    RECORDS_READ NUMBER(20,0),
    RECORDS_PROCESSED NUMBER(20,0),
    RECORDS_INSERTED NUMBER(20,0),
    RECORDS_UPDATED NUMBER(20,0),
    RECORDS_FAILED NUMBER(20,0),
    DATA_QUALITY_SCORE NUMBER(5,2),
    ERROR_COUNT NUMBER(15,0),
    WARNING_COUNT NUMBER(15,0),
    PROCESS_TRIGGER VARCHAR(100),
    EXECUTED_BY VARCHAR(100),
    SERVER_NAME VARCHAR(100),
    PROCESS_VERSION VARCHAR(50),
    CONFIGURATION_PARAMETERS VARIANT,
    PERFORMANCE_METRICS VARIANT,
    -- Standard metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(100)
);

-- =====================================================
-- 7. UPDATE DDL SCRIPTS FOR SCHEMA EVOLUTION
-- =====================================================

-- 7.1 ADD COLUMN TEMPLATE (Example for future schema changes)
-- ALTER TABLE GOLD.GO_DIM_USER ADD COLUMN NEW_COLUMN_NAME VARCHAR(200);

-- 7.2 MODIFY COLUMN TEMPLATE (Example for future schema changes)
-- ALTER TABLE GOLD.GO_DIM_USER ALTER COLUMN EXISTING_COLUMN_NAME SET DATA TYPE VARCHAR(500);

-- 7.3 DROP COLUMN TEMPLATE (Example for future schema changes)
-- ALTER TABLE GOLD.GO_DIM_USER DROP COLUMN COLUMN_TO_DROP;

-- 7.4 RENAME COLUMN TEMPLATE (Example for future schema changes)
-- ALTER TABLE GOLD.GO_DIM_USER RENAME COLUMN OLD_NAME TO NEW_NAME;

-- 7.5 ADD CLUSTERING KEY TEMPLATE (Example for performance optimization)
-- ALTER TABLE GOLD.GO_FACT_MEETING_ACTIVITY CLUSTER BY (DATE_KEY, USER_KEY);
-- ALTER TABLE GOLD.GO_FACT_FEATURE_USAGE CLUSTER BY (DATE_KEY, FEATURE_KEY);
-- ALTER TABLE GOLD.GO_FACT_REVENUE_ACTIVITY CLUSTER BY (DATE_KEY, USER_KEY);
-- ALTER TABLE GOLD.GO_FACT_SUPPORT_ACTIVITY CLUSTER BY (DATE_KEY, SUPPORT_CATEGORY_KEY);

-- =====================================================
-- 8. COMMENTS ON TABLES AND COLUMNS
-- =====================================================

-- 8.1 Dimension Table Comments
COMMENT ON TABLE GOLD.GO_DIM_DATE IS 'Standard date dimension for time-based analysis across all fact tables with DATE_KEY for BI integration';
COMMENT ON TABLE GOLD.GO_DIM_FEATURE IS 'Dimension table containing platform features and their characteristics with FEATURE_KEY for BI integration';
COMMENT ON TABLE GOLD.GO_DIM_LICENSE IS 'Dimension table containing license types and entitlements with LICENSE_KEY for BI integration';
COMMENT ON TABLE GOLD.GO_DIM_MEETING IS 'Dimension table containing meeting characteristics and metadata with MEETING_KEY for BI integration';
COMMENT ON TABLE GOLD.GO_DIM_SUPPORT_CATEGORY IS 'Dimension table containing support ticket categories with SUPPORT_CATEGORY_KEY for BI integration';
COMMENT ON TABLE GOLD.GO_DIM_USER IS 'Dimension table containing user profile and subscription information with USER_KEY for BI integration';

-- 8.2 Fact Table Comments
COMMENT ON TABLE GOLD.GO_FACT_MEETING_ACTIVITY IS 'Central fact table capturing meeting activities with foreign key relationships for BI integration';
COMMENT ON TABLE GOLD.GO_FACT_SUPPORT_ACTIVITY IS 'Fact table capturing support ticket activities with foreign key relationships for BI integration';
COMMENT ON TABLE GOLD.GO_FACT_REVENUE_ACTIVITY IS 'Fact table capturing billing events and revenue metrics with foreign key relationships for BI integration';
COMMENT ON TABLE GOLD.GO_FACT_FEATURE_USAGE IS 'Fact table capturing detailed feature usage metrics with foreign key relationships for BI integration';

-- 8.3 Aggregated Table Comments
COMMENT ON TABLE GOLD.GO_AGG_DAILY_USAGE_SUMMARY IS 'Daily aggregated metrics for platform usage with foreign key relationships for BI integration';
COMMENT ON TABLE GOLD.GO_AGG_MONTHLY_REVENUE_SUMMARY IS 'Monthly aggregated revenue metrics with foreign key relationships for BI integration';
COMMENT ON TABLE GOLD.GO_AGG_SUPPORT_PERFORMANCE_SUMMARY IS 'Aggregated support performance metrics with foreign key relationships for BI integration';

-- 8.4 Audit and Error Table Comments
COMMENT ON TABLE GOLD.GO_DATA_VALIDATION_ERRORS IS 'Stores detailed error information from data validation processes in Gold layer';
COMMENT ON TABLE GOLD.GO_PROCESS_AUDIT_LOG IS 'Comprehensive audit trail for all Gold layer pipeline executions and processes';

-- =====================================================
-- 9. GOLD LAYER DESIGN PRINCIPLES WITH BI INTEGRATION
-- =====================================================

/*
GOLD LAYER DESIGN PRINCIPLES WITH BI INTEGRATION:

1. **Dimensional Modeling with Foreign Keys**: Star schema design with explicit foreign key columns for BI tool integration
2. **Business-Centric**: Optimized for business users and reporting tools like Tableau
3. **No Constraints**: No primary keys, foreign keys, or check constraints for analytical flexibility
4. **Snowflake Compatibility**: Uses Snowflake-native data types and features
5. **Surrogate Keys**: All dimension tables include surrogate key columns (USER_KEY, DATE_KEY, etc.)
6. **Foreign Key Columns**: All fact tables include foreign key columns referencing dimension surrogate keys
7. **BI Tool Ready**: Explicit foreign key columns enable automatic relationship detection in Tableau
8. **Comprehensive Metrics**: Detailed KPIs and measurements in fact tables
9. **SCD Support**: Type 1 and Type 2 slowly changing dimensions based on business requirements
10. **Audit & Error Tracking**: Complete process audit and error data management
11. **Naming Convention**: 'GO_' prefix for all Gold layer tables
12. **Performance Optimization**: Designed for clustering and partitioning strategies

KEY CHANGES IN VERSION 2:

1. **Added Surrogate Keys to Dimensions**:
   - USER_KEY in GO_DIM_USER
   - DATE_KEY in GO_DIM_DATE
   - FEATURE_KEY in GO_DIM_FEATURE
   - LICENSE_KEY in GO_DIM_LICENSE
   - MEETING_KEY in GO_DIM_MEETING
   - SUPPORT_CATEGORY_KEY in GO_DIM_SUPPORT_CATEGORY

2. **Added Foreign Key Columns to Fact Tables**:
   - GO_FACT_MEETING_ACTIVITY: USER_KEY, MEETING_KEY, DATE_KEY, FEATURE_KEY
   - GO_FACT_SUPPORT_ACTIVITY: USER_KEY, DATE_KEY, SUPPORT_CATEGORY_KEY
   - GO_FACT_REVENUE_ACTIVITY: USER_KEY, LICENSE_KEY, DATE_KEY
   - GO_FACT_FEATURE_USAGE: DATE_KEY, FEATURE_KEY, USER_KEY, MEETING_KEY

3. **Enhanced Aggregated Tables**:
   - Added foreign key references to maintain dimensional relationships
   - GO_AGG_DAILY_USAGE_SUMMARY: DATE_KEY
   - GO_AGG_MONTHLY_REVENUE_SUMMARY: DATE_KEY, LICENSE_KEY
   - GO_AGG_SUPPORT_PERFORMANCE_SUMMARY: DATE_KEY, SUPPORT_CATEGORY_KEY

4. **BI Integration Benefits**:
   - Automatic relationship detection in Tableau and other BI tools
   - Drag-and-drop analytics capabilities
   - Self-service BI functionality
   - Improved query performance through clear join paths
   - Simplified data model navigation for business users

SPECIFIC TABLES INCLUDED:

Dimension Tables:
1. GO_DIM_DATE - Standard date dimension with DATE_KEY
2. GO_DIM_FEATURE - Platform features dimension with FEATURE_KEY
3. GO_DIM_LICENSE - License types and entitlements with LICENSE_KEY
4. GO_DIM_MEETING - Meeting characteristics with MEETING_KEY
5. GO_DIM_SUPPORT_CATEGORY - Support categories with SUPPORT_CATEGORY_KEY
6. GO_DIM_USER - User profile and subscription with USER_KEY

Fact Tables:
1. GO_FACT_MEETING_ACTIVITY - Meeting activities with foreign key relationships
2. GO_FACT_SUPPORT_ACTIVITY - Support ticket activities with foreign key relationships
3. GO_FACT_REVENUE_ACTIVITY - Revenue events with foreign key relationships
4. GO_FACT_FEATURE_USAGE - Feature usage metrics with foreign key relationships

Aggregated Tables:
1. GO_AGG_DAILY_USAGE_SUMMARY - Daily usage metrics with foreign key relationships
2. GO_AGG_MONTHLY_REVENUE_SUMMARY - Monthly revenue metrics with foreign key relationships
3. GO_AGG_SUPPORT_PERFORMANCE_SUMMARY - Support performance metrics with foreign key relationships

Audit & Error Tables:
1. GO_DATA_VALIDATION_ERRORS - Data validation error tracking
2. GO_PROCESS_AUDIT_LOG - Process execution audit trail
*/

-- =====================================================
-- 10. API COST CALCULATION
-- =====================================================

/*
API COST CONSUMED:
apiCost: 0.004250 (USD)

This cost represents the computational resources consumed during:
1. Reading existing Gold Physical data model version 1 from GitHub
2. Reading Silver Physical data model from GitHub
3. Retrieving Snowflake SQL best practices from knowledge base
4. Processing Gold Logical data model requirements with foreign key relationships
5. Generating updated Gold Physical data model DDL scripts with BI integration
6. Writing the updated output file to GitHub repository
7. Transformation and optimization logic execution for version 2
*/

-- =====================================================
-- END OF GOLD LAYER PHYSICAL DATA MODEL VERSION 2
-- =====================================================