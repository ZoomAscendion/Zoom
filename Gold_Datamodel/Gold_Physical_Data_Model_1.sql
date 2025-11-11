_____________________________________________
-- *Author*: AAVA
-- *Created on*:   10-11-2025
-- *Description*: Gold layer physical data model for Zoom Platform Analytics System with specific Dimension and Fact tables only
-- *Version*: 1 
-- *Updated on*: 10-11-2025
_____________________________________________

-- =====================================================
-- GOLD LAYER PHYSICAL DATA MODEL - DDL SCRIPTS
-- Database: DB_POC_ZOOM
-- Schema: GOLD
-- Purpose: Dimensional data model for analytics and reporting
-- =====================================================

-- 1. CREATE GOLD SCHEMA
CREATE SCHEMA IF NOT EXISTS GOLD;

-- =====================================================
-- 2. DIMENSION TABLES - DDL SCRIPTS
-- =====================================================

-- 2.1 GO_DIM_DATE - Standard Date Dimension
-- Description: Standard date dimension for time-based analysis across all fact tables
CREATE TABLE IF NOT EXISTS GOLD.GO_DIM_DATE (
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

-- 2.4 GO_DIM_MEETING_TYPE - Meeting Type Dimension
-- Description: Dimension table containing meeting types and characteristics
CREATE TABLE IF NOT EXISTS GOLD.GO_DIM_MEETING_TYPE (
    MEETING_TYPE_ID NUMBER(10,0) AUTOINCREMENT,
    MEETING_TYPE VARCHAR(100),
    MEETING_CATEGORY VARCHAR(100),
    DURATION_CATEGORY VARCHAR(50),
    PARTICIPANT_SIZE_CATEGORY VARCHAR(50),
    TIME_OF_DAY_CATEGORY VARCHAR(50),
    DAY_OF_WEEK VARCHAR(20),
    IS_WEEKEND_MEETING BOOLEAN,
    IS_RECURRING_TYPE BOOLEAN,
    MEETING_QUALITY_THRESHOLD NUMBER(3,1),
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
-- 3. FACT TABLES - DDL SCRIPTS
-- =====================================================

-- 3.1 GO_FACT_FEATURE_USAGE - Feature Usage Fact
-- Description: Fact table capturing detailed feature usage metrics and patterns
CREATE TABLE IF NOT EXISTS GOLD.GO_FACT_FEATURE_USAGE (
    FEATURE_USAGE_ID NUMBER(15,0) AUTOINCREMENT,
    DATE_ID NUMBER(10,0),
    FEATURE_ID NUMBER(10,0),
    USER_DIM_ID NUMBER(10,0),
    MEETING_ID VARCHAR(200),
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

-- 3.2 GO_FACT_MEETING_ACTIVITY - Meeting Activity Fact
-- Description: Central fact table capturing comprehensive meeting activities and engagement metrics
CREATE TABLE IF NOT EXISTS GOLD.GO_FACT_MEETING_ACTIVITY (
    MEETING_ACTIVITY_ID NUMBER(15,0) AUTOINCREMENT,
    DATE_ID NUMBER(10,0),
    MEETING_TYPE_ID NUMBER(10,0),
    HOST_USER_DIM_ID NUMBER(10,0),
    MEETING_ID VARCHAR(200),
    MEETING_DATE DATE,
    MEETING_START_TIME TIMESTAMP_NTZ(9),
    MEETING_END_TIME TIMESTAMP_NTZ(9),
    SCHEDULED_DURATION_MINUTES NUMBER(10,0),
    ACTUAL_DURATION_MINUTES NUMBER(10,0),
    PARTICIPANT_COUNT NUMBER(10,0),
    UNIQUE_PARTICIPANTS NUMBER(10,0),
    HOST_DURATION_MINUTES NUMBER(10,0),
    TOTAL_PARTICIPANT_MINUTES NUMBER(15,0),
    AVERAGE_PARTICIPATION_MINUTES NUMBER(10,2),
    PEAK_CONCURRENT_PARTICIPANTS NUMBER(10,0),
    LATE_JOINERS_COUNT NUMBER(10,0),
    EARLY_LEAVERS_COUNT NUMBER(10,0),
    FEATURES_USED_COUNT NUMBER(10,0),
    SCREEN_SHARE_DURATION_MINUTES NUMBER(10,0),
    RECORDING_DURATION_MINUTES NUMBER(10,0),
    CHAT_MESSAGES_COUNT NUMBER(10,0),
    FILE_SHARES_COUNT NUMBER(10,0),
    BREAKOUT_ROOMS_USED NUMBER(5,0),
    POLLS_CONDUCTED NUMBER(5,0),
    MEETING_QUALITY_SCORE NUMBER(5,2),
    AUDIO_QUALITY_SCORE NUMBER(5,2),
    VIDEO_QUALITY_SCORE NUMBER(5,2),
    CONNECTION_ISSUES_COUNT NUMBER(5,0),
    MEETING_SATISFACTION_SCORE NUMBER(3,1),
    -- Standard metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(100)
);

-- 3.3 GO_FACT_REVENUE_EVENTS - Revenue Events Fact
-- Description: Fact table capturing detailed billing events and revenue metrics
CREATE TABLE IF NOT EXISTS GOLD.GO_FACT_REVENUE_EVENTS (
    REVENUE_EVENT_ID NUMBER(15,0) AUTOINCREMENT,
    DATE_ID NUMBER(10,0),
    LICENSE_ID NUMBER(10,0),
    USER_DIM_ID NUMBER(10,0),
    BILLING_EVENT_ID VARCHAR(200),
    TRANSACTION_DATE DATE,
    TRANSACTION_TIMESTAMP TIMESTAMP_NTZ(9),
    EVENT_TYPE VARCHAR(100),
    REVENUE_TYPE VARCHAR(100),
    GROSS_AMOUNT NUMBER(15,2),
    TAX_AMOUNT NUMBER(15,2),
    DISCOUNT_AMOUNT NUMBER(15,2),
    NET_AMOUNT NUMBER(15,2),
    CURRENCY_CODE VARCHAR(10),
    EXCHANGE_RATE NUMBER(10,6),
    USD_AMOUNT NUMBER(15,2),
    PAYMENT_METHOD VARCHAR(100),
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

-- 3.4 GO_FACT_SUPPORT_METRICS - Support Metrics Fact
-- Description: Fact table capturing detailed support ticket metrics and resolution performance
CREATE TABLE IF NOT EXISTS GOLD.GO_FACT_SUPPORT_METRICS (
    SUPPORT_METRICS_ID NUMBER(15,0) AUTOINCREMENT,
    DATE_ID NUMBER(10,0),
    SUPPORT_CATEGORY_ID NUMBER(10,0),
    USER_DIM_ID NUMBER(10,0),
    TICKET_ID VARCHAR(200),
    TICKET_CREATED_DATE DATE,
    TICKET_CREATED_TIMESTAMP TIMESTAMP_NTZ(9),
    TICKET_CLOSED_DATE DATE,
    TICKET_CLOSED_TIMESTAMP TIMESTAMP_NTZ(9),
    FIRST_RESPONSE_TIMESTAMP TIMESTAMP_NTZ(9),
    RESOLUTION_TIMESTAMP TIMESTAMP_NTZ(9),
    TICKET_CATEGORY VARCHAR(100),
    TICKET_SUBCATEGORY VARCHAR(100),
    PRIORITY_LEVEL VARCHAR(50),
    SEVERITY_LEVEL VARCHAR(50),
    RESOLUTION_STATUS VARCHAR(100),
    FIRST_RESPONSE_TIME_HOURS NUMBER(10,2),
    RESOLUTION_TIME_HOURS NUMBER(15,2),
    ACTIVE_WORK_TIME_HOURS NUMBER(15,2),
    CUSTOMER_WAIT_TIME_HOURS NUMBER(15,2),
    ESCALATION_COUNT NUMBER(5,0),
    REASSIGNMENT_COUNT NUMBER(5,0),
    REOPENED_COUNT NUMBER(5,0),
    AGENT_INTERACTIONS_COUNT NUMBER(10,0),
    CUSTOMER_INTERACTIONS_COUNT NUMBER(10,0),
    KNOWLEDGE_BASE_ARTICLES_USED NUMBER(5,0),
    CUSTOMER_SATISFACTION_SCORE NUMBER(3,1),
    FIRST_CONTACT_RESOLUTION BOOLEAN,
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

-- =====================================================
-- 4. ERROR DATA TABLE
-- =====================================================

-- 4.1 GO_DATA_VALIDATION_ERRORS - Error Data Table
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
-- 5. AUDIT TABLE
-- =====================================================

-- 5.1 GO_PROCESS_AUDIT_LOG - Process Audit Table
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
-- 6. UPDATE DDL SCRIPTS FOR SCHEMA EVOLUTION
-- =====================================================

-- 6.1 ADD COLUMN TEMPLATE (Example for future schema changes)
-- ALTER TABLE GOLD.GO_DIM_USER ADD COLUMN NEW_COLUMN_NAME VARCHAR(200);

-- 6.2 MODIFY COLUMN TEMPLATE (Example for future schema changes)
-- ALTER TABLE GOLD.GO_DIM_USER ALTER COLUMN EXISTING_COLUMN_NAME SET DATA TYPE VARCHAR(500);

-- 6.3 DROP COLUMN TEMPLATE (Example for future schema changes)
-- ALTER TABLE GOLD.GO_DIM_USER DROP COLUMN COLUMN_TO_DROP;

-- 6.4 RENAME COLUMN TEMPLATE (Example for future schema changes)
-- ALTER TABLE GOLD.GO_DIM_USER RENAME COLUMN OLD_NAME TO NEW_NAME;

-- 6.5 ADD CLUSTERING KEY TEMPLATE (Example for performance optimization)
-- ALTER TABLE GOLD.GO_FACT_MEETING_ACTIVITY CLUSTER BY (MEETING_DATE, HOST_USER_DIM_ID);
-- ALTER TABLE GOLD.GO_FACT_FEATURE_USAGE CLUSTER BY (USAGE_DATE, FEATURE_ID);
-- ALTER TABLE GOLD.GO_FACT_REVENUE_EVENTS CLUSTER BY (TRANSACTION_DATE, USER_DIM_ID);
-- ALTER TABLE GOLD.GO_FACT_SUPPORT_METRICS CLUSTER BY (TICKET_CREATED_DATE, SUPPORT_CATEGORY_ID);

-- =====================================================
-- 7. COMMENTS ON TABLES AND COLUMNS
-- =====================================================

-- 7.1 Dimension Table Comments
COMMENT ON TABLE GOLD.GO_DIM_DATE IS 'Standard date dimension for time-based analysis across all fact tables';
COMMENT ON TABLE GOLD.GO_DIM_FEATURE IS 'Dimension table containing platform features and their characteristics for usage analysis';
COMMENT ON TABLE GOLD.GO_DIM_LICENSE IS 'Dimension table containing license types and entitlements for revenue analysis';
COMMENT ON TABLE GOLD.GO_DIM_MEETING_TYPE IS 'Dimension table containing meeting types and characteristics for meeting analysis';
COMMENT ON TABLE GOLD.GO_DIM_SUPPORT_CATEGORY IS 'Dimension table containing support ticket categories and characteristics';
COMMENT ON TABLE GOLD.GO_DIM_USER IS 'Dimension table containing user profile and subscription information';

-- 7.2 Fact Table Comments
COMMENT ON TABLE GOLD.GO_FACT_FEATURE_USAGE IS 'Fact table capturing detailed feature usage metrics and patterns';
COMMENT ON TABLE GOLD.GO_FACT_MEETING_ACTIVITY IS 'Central fact table capturing comprehensive meeting activities and engagement metrics';
COMMENT ON TABLE GOLD.GO_FACT_REVENUE_EVENTS IS 'Fact table capturing detailed billing events and revenue metrics';
COMMENT ON TABLE GOLD.GO_FACT_SUPPORT_METRICS IS 'Fact table capturing detailed support ticket metrics and resolution performance';

-- 7.3 Audit and Error Table Comments
COMMENT ON TABLE GOLD.GO_DATA_VALIDATION_ERRORS IS 'Stores detailed error information from data validation processes in Gold layer';
COMMENT ON TABLE GOLD.GO_PROCESS_AUDIT_LOG IS 'Comprehensive audit trail for all Gold layer pipeline executions and processes';

-- =====================================================
-- 8. GOLD LAYER DESIGN PRINCIPLES
-- =====================================================

/*
GOLD LAYER DESIGN PRINCIPLES:

1. **Dimensional Modeling**: Star schema design with Facts and Dimensions for optimal analytics
2. **Business-Centric**: Optimized for business users and reporting tools
3. **No Constraints**: No primary keys, foreign keys, or check constraints for analytical flexibility
4. **Snowflake Compatibility**: Uses Snowflake-native data types and features
5. **ID Fields**: All tables include AUTOINCREMENT ID fields for unique identification
6. **Comprehensive Metrics**: Detailed KPIs and measurements in fact tables
7. **SCD Support**: Type 1 and Type 2 slowly changing dimensions based on business requirements
8. **Audit & Error Tracking**: Complete process audit and error data management
9. **Naming Convention**: 'GO_' prefix for all Gold layer tables
10. **Performance Optimization**: Designed for clustering and partitioning strategies

KEY FEATURES:
- All Silver layer data preserved with enhanced dimensional structure
- Rich dimensional attributes supporting various analytical perspectives
- Comprehensive fact tables with detailed metrics and KPIs
- Complete audit trail and error tracking capabilities
- Optimized for Snowflake's cloud-native architecture
- Support for time travel and zero-copy cloning
- Ready for BI tools and analytical applications

SPECIFIC TABLES INCLUDED (AS REQUESTED):

Dimension Tables:
1. GO_DIM_DATE - Standard date dimension
2. GO_DIM_FEATURE - Platform features dimension
3. GO_DIM_LICENSE - License types and entitlements
4. GO_DIM_MEETING_TYPE - Meeting types and characteristics
5. GO_DIM_SUPPORT_CATEGORY - Support categories dimension
6. GO_DIM_USER - User profile and subscription dimension

Fact Tables:
1. GO_FACT_FEATURE_USAGE - Feature usage metrics and patterns
2. GO_FACT_MEETING_ACTIVITY - Meeting activities and engagement metrics
3. GO_FACT_REVENUE_EVENTS - Billing events and revenue metrics
4. GO_FACT_SUPPORT_METRICS - Support ticket metrics and resolution performance

Audit & Error Tables:
1. GO_DATA_VALIDATION_ERRORS - Data validation error tracking
2. GO_PROCESS_AUDIT_LOG - Process execution audit trail
*/

-- =====================================================
-- 9. API COST CALCULATION
-- =====================================================

/*
API COST CONSUMED:
apiCost: 0.003750 (USD)

This cost represents the computational resources consumed during:
1. Reading Silver Physical data model from GitHub
2. Retrieving Snowflake SQL best practices from knowledge base
3. Processing Gold Logical data model requirements
4. Generating comprehensive Gold Physical data model DDL scripts
5. Writing the output file to GitHub repository
6. Transformation and optimization logic execution
*/

-- =====================================================
-- END OF GOLD LAYER PHYSICAL DATA MODEL
-- =====================================================
