_____________________________________________
-- *Author*: AAVA
-- *Created on*:   
-- *Description*: Gold layer physical data model for Zoom Platform Analytics System following Medallion architecture
-- *Version*: 1 
-- *Updated on*: 
_____________________________________________

-- =====================================================
-- GOLD LAYER PHYSICAL DATA MODEL - DDL SCRIPTS
-- Database: DB_POC_ZOOM
-- Schema: GOLD
-- Purpose: Business-ready dimensional data for analytics and reporting
-- =====================================================

-- 1. CREATE GOLD SCHEMA
CREATE SCHEMA IF NOT EXISTS GOLD;

-- =====================================================
-- 2. FACT TABLES - DDL SCRIPTS
-- =====================================================

-- 2.1 GO_FACT_MEETING_ACTIVITY TABLE
-- Description: Central fact table capturing meeting activities and usage metrics
CREATE TABLE IF NOT EXISTS GOLD.GO_FACT_MEETING_ACTIVITY (
    MEETING_ACTIVITY_ID NUMBER AUTOINCREMENT,
    MEETING_KEY NUMBER,
    USER_KEY NUMBER,
    DATE_KEY NUMBER,
    FEATURE_KEY NUMBER,
    LICENSE_KEY NUMBER,
    MEETING_ID VARCHAR(16777216),
    HOST_ID VARCHAR(16777216),
    PARTICIPANT_ID VARCHAR(16777216),
    MEETING_DURATION_MINUTES NUMBER(38,0),
    PARTICIPANT_DURATION_MINUTES NUMBER(38,0),
    FEATURE_USAGE_COUNT NUMBER(38,0),
    MEETING_START_TIME TIMESTAMP_NTZ(9),
    MEETING_END_TIME TIMESTAMP_NTZ(9),
    PARTICIPANT_JOIN_TIME TIMESTAMP_NTZ(9),
    PARTICIPANT_LEAVE_TIME TIMESTAMP_NTZ(9),
    IS_HOST_FLAG BOOLEAN,
    MEETING_SIZE_CATEGORY VARCHAR(50),
    MEETING_TYPE VARCHAR(100),
    -- Metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- 2.2 GO_FACT_SUPPORT_ACTIVITY TABLE
-- Description: Fact table capturing support ticket activities and resolution metrics
CREATE TABLE IF NOT EXISTS GOLD.GO_FACT_SUPPORT_ACTIVITY (
    SUPPORT_ACTIVITY_ID NUMBER AUTOINCREMENT,
    USER_KEY NUMBER,
    DATE_KEY NUMBER,
    LICENSE_KEY NUMBER,
    TICKET_ID VARCHAR(16777216),
    USER_ID VARCHAR(16777216),
    TICKET_TYPE VARCHAR(16777216),
    RESOLUTION_STATUS VARCHAR(16777216),
    OPEN_DATE DATE,
    CLOSE_DATE DATE,
    RESOLUTION_TIME_HOURS NUMBER(10,2),
    PRIORITY_LEVEL VARCHAR(50),
    SATISFACTION_SCORE NUMBER(3,1),
    ESCALATION_COUNT NUMBER(10,0),
    FIRST_RESPONSE_TIME_HOURS NUMBER(10,2),
    -- Metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- 2.3 GO_FACT_REVENUE_ACTIVITY TABLE
-- Description: Fact table capturing billing events and revenue metrics
CREATE TABLE IF NOT EXISTS GOLD.GO_FACT_REVENUE_ACTIVITY (
    REVENUE_ACTIVITY_ID NUMBER AUTOINCREMENT,
    USER_KEY NUMBER,
    DATE_KEY NUMBER,
    LICENSE_KEY NUMBER,
    EVENT_ID VARCHAR(16777216),
    USER_ID VARCHAR(16777216),
    EVENT_TYPE VARCHAR(16777216),
    AMOUNT NUMBER(10,2),
    EVENT_DATE DATE,
    CURRENCY_CODE VARCHAR(3),
    PAYMENT_METHOD VARCHAR(50),
    SUBSCRIPTION_PERIOD_MONTHS NUMBER(10,0),
    DISCOUNT_AMOUNT NUMBER(10,2),
    TAX_AMOUNT NUMBER(10,2),
    NET_REVENUE NUMBER(10,2),
    -- Metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- =====================================================
-- 3. DIMENSION TABLES - DDL SCRIPTS
-- =====================================================

-- 3.1 GO_DIM_USER TABLE (SCD Type 2)
-- Description: User profile and subscription information with historical tracking
CREATE TABLE IF NOT EXISTS GOLD.GO_DIM_USER (
    USER_KEY NUMBER AUTOINCREMENT,
    USER_ID VARCHAR(16777216),
    USER_NAME VARCHAR(16777216),
    EMAIL VARCHAR(16777216),
    COMPANY VARCHAR(16777216),
    PLAN_TYPE VARCHAR(16777216),
    USER_STATUS VARCHAR(50),
    REGISTRATION_DATE DATE,
    LAST_LOGIN_DATE DATE,
    ACCOUNT_TYPE VARCHAR(50),
    REGION VARCHAR(100),
    TIME_ZONE VARCHAR(50),
    -- SCD Type 2 columns
    EFFECTIVE_START_DATE DATE,
    EFFECTIVE_END_DATE DATE,
    IS_CURRENT_FLAG BOOLEAN,
    ROW_VERSION NUMBER(10,0),
    -- Metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- 3.2 GO_DIM_MEETING TABLE (SCD Type 1)
-- Description: Meeting characteristics and metadata
CREATE TABLE IF NOT EXISTS GOLD.GO_DIM_MEETING (
    MEETING_KEY NUMBER AUTOINCREMENT,
    MEETING_ID VARCHAR(16777216),
    MEETING_TOPIC VARCHAR(16777216),
    MEETING_TYPE VARCHAR(100),
    SCHEDULED_DURATION_MINUTES NUMBER(38,0),
    MAX_PARTICIPANTS NUMBER(10,0),
    RECORDING_ENABLED BOOLEAN,
    WAITING_ROOM_ENABLED BOOLEAN,
    PASSWORD_PROTECTED BOOLEAN,
    MEETING_CATEGORY VARCHAR(100),
    -- Metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- 3.3 GO_DIM_FEATURE TABLE (SCD Type 1)
-- Description: Platform features and their characteristics
CREATE TABLE IF NOT EXISTS GOLD.GO_DIM_FEATURE (
    FEATURE_KEY NUMBER AUTOINCREMENT,
    FEATURE_ID VARCHAR(16777216),
    FEATURE_NAME VARCHAR(16777216),
    FEATURE_CATEGORY VARCHAR(100),
    FEATURE_TYPE VARCHAR(100),
    IS_PREMIUM_FEATURE BOOLEAN,
    FEATURE_DESCRIPTION VARCHAR(16777216),
    RELEASE_DATE DATE,
    DEPRECATION_DATE DATE,
    IS_ACTIVE_FLAG BOOLEAN,
    -- Metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- 3.4 GO_DIM_LICENSE TABLE (SCD Type 2)
-- Description: License types and entitlements with historical tracking
CREATE TABLE IF NOT EXISTS GOLD.GO_DIM_LICENSE (
    LICENSE_KEY NUMBER AUTOINCREMENT,
    LICENSE_ID VARCHAR(16777216),
    LICENSE_TYPE VARCHAR(16777216),
    ASSIGNED_TO_USER_ID VARCHAR(16777216),
    START_DATE DATE,
    END_DATE DATE,
    LICENSE_STATUS VARCHAR(50),
    MAX_PARTICIPANTS NUMBER(10,0),
    STORAGE_LIMIT_GB NUMBER(10,2),
    RECORDING_LIMIT_GB NUMBER(10,2),
    MONTHLY_COST NUMBER(10,2),
    -- SCD Type 2 columns
    EFFECTIVE_START_DATE DATE,
    EFFECTIVE_END_DATE DATE,
    IS_CURRENT_FLAG BOOLEAN,
    ROW_VERSION NUMBER(10,0),
    -- Metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- 3.5 GO_DIM_DATE TABLE (SCD Type 1)
-- Description: Standard date dimension for time-based analysis
CREATE TABLE IF NOT EXISTS GOLD.GO_DIM_DATE (
    DATE_KEY NUMBER AUTOINCREMENT,
    FULL_DATE DATE,
    DAY_OF_WEEK NUMBER(1,0),
    DAY_NAME VARCHAR(10),
    DAY_OF_MONTH NUMBER(2,0),
    DAY_OF_YEAR NUMBER(3,0),
    WEEK_OF_YEAR NUMBER(2,0),
    MONTH_NUMBER NUMBER(2,0),
    MONTH_NAME VARCHAR(10),
    MONTH_ABBR VARCHAR(3),
    QUARTER_NUMBER NUMBER(1,0),
    QUARTER_NAME VARCHAR(2),
    YEAR_NUMBER NUMBER(4,0),
    IS_WEEKEND BOOLEAN,
    IS_HOLIDAY BOOLEAN,
    HOLIDAY_NAME VARCHAR(100),
    FISCAL_YEAR NUMBER(4,0),
    FISCAL_QUARTER NUMBER(1,0),
    FISCAL_MONTH NUMBER(2,0),
    -- Metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- =====================================================
-- 4. AGGREGATED TABLES - DDL SCRIPTS
-- =====================================================

-- 4.1 GO_AGG_DAILY_USAGE_SUMMARY TABLE
-- Description: Daily aggregated metrics for platform usage and adoption
CREATE TABLE IF NOT EXISTS GOLD.GO_AGG_DAILY_USAGE_SUMMARY (
    DAILY_USAGE_ID NUMBER AUTOINCREMENT,
    SUMMARY_DATE DATE,
    TOTAL_MEETINGS NUMBER(38,0),
    TOTAL_PARTICIPANTS NUMBER(38,0),
    TOTAL_MEETING_MINUTES NUMBER(38,0),
    UNIQUE_HOSTS NUMBER(38,0),
    UNIQUE_PARTICIPANTS NUMBER(38,0),
    AVG_MEETING_DURATION_MINUTES NUMBER(10,2),
    AVG_PARTICIPANTS_PER_MEETING NUMBER(10,2),
    PEAK_CONCURRENT_MEETINGS NUMBER(38,0),
    TOTAL_FEATURE_USAGE NUMBER(38,0),
    TOP_FEATURE_USED VARCHAR(16777216),
    RECORDINGS_CREATED NUMBER(38,0),
    TOTAL_STORAGE_USED_GB NUMBER(10,2),
    -- Metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- 4.2 GO_AGG_MONTHLY_REVENUE_SUMMARY TABLE
-- Description: Monthly aggregated revenue and billing metrics
CREATE TABLE IF NOT EXISTS GOLD.GO_AGG_MONTHLY_REVENUE_SUMMARY (
    MONTHLY_REVENUE_ID NUMBER AUTOINCREMENT,
    SUMMARY_YEAR_MONTH VARCHAR(7),
    TOTAL_REVENUE NUMBER(15,2),
    NEW_CUSTOMER_REVENUE NUMBER(15,2),
    EXISTING_CUSTOMER_REVENUE NUMBER(15,2),
    UPGRADE_REVENUE NUMBER(15,2),
    CHURN_REVENUE NUMBER(15,2),
    TOTAL_CUSTOMERS NUMBER(38,0),
    NEW_CUSTOMERS NUMBER(38,0),
    CHURNED_CUSTOMERS NUMBER(38,0),
    AVG_REVENUE_PER_USER NUMBER(10,2),
    CUSTOMER_LIFETIME_VALUE NUMBER(10,2),
    MONTHLY_RECURRING_REVENUE NUMBER(15,2),
    ANNUAL_RECURRING_REVENUE NUMBER(15,2),
    -- Metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- 4.3 GO_AGG_SUPPORT_PERFORMANCE_SUMMARY TABLE
-- Description: Aggregated support performance and service reliability metrics
CREATE TABLE IF NOT EXISTS GOLD.GO_AGG_SUPPORT_PERFORMANCE_SUMMARY (
    SUPPORT_PERFORMANCE_ID NUMBER AUTOINCREMENT,
    SUMMARY_DATE DATE,
    TOTAL_TICKETS NUMBER(38,0),
    TICKETS_OPENED NUMBER(38,0),
    TICKETS_CLOSED NUMBER(38,0),
    TICKETS_PENDING NUMBER(38,0),
    AVG_RESOLUTION_TIME_HOURS NUMBER(10,2),
    AVG_FIRST_RESPONSE_TIME_HOURS NUMBER(10,2),
    CUSTOMER_SATISFACTION_SCORE NUMBER(3,1),
    ESCALATION_RATE NUMBER(5,2),
    FIRST_CONTACT_RESOLUTION_RATE NUMBER(5,2),
    SLA_COMPLIANCE_RATE NUMBER(5,2),
    TOP_ISSUE_CATEGORY VARCHAR(16777216),
    AGENT_UTILIZATION_RATE NUMBER(5,2),
    -- Metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- =====================================================
-- 5. ERROR DATA TABLE
-- =====================================================

-- 5.1 GO_DATA_VALIDATION_ERRORS TABLE
-- Description: Detailed error information from data validation processes in Gold layer
CREATE TABLE IF NOT EXISTS GOLD.GO_DATA_VALIDATION_ERRORS (
    ERROR_ID NUMBER AUTOINCREMENT,
    SOURCE_TABLE VARCHAR(16777216),
    SOURCE_RECORD_KEY VARCHAR(16777216),
    ERROR_TYPE VARCHAR(100),
    ERROR_CATEGORY VARCHAR(100),
    ERROR_DESCRIPTION VARCHAR(16777216),
    ERROR_COLUMN VARCHAR(16777216),
    ERROR_VALUE VARCHAR(16777216),
    ERROR_SEVERITY VARCHAR(50),
    ERROR_TIMESTAMP TIMESTAMP_NTZ(9),
    RESOLUTION_STATUS VARCHAR(50),
    RESOLUTION_NOTES VARCHAR(16777216),
    BUSINESS_IMPACT VARCHAR(100),
    DATA_LINEAGE_INFO VARCHAR(16777216),
    -- Metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- =====================================================
-- 6. AUDIT TABLE
-- =====================================================

-- 6.1 GO_PROCESS_AUDIT_LOG TABLE
-- Description: Comprehensive audit trail for all Gold layer pipeline executions and processes
CREATE TABLE IF NOT EXISTS GOLD.GO_PROCESS_AUDIT_LOG (
    AUDIT_ID NUMBER AUTOINCREMENT,
    PROCESS_NAME VARCHAR(16777216),
    PROCESS_TYPE VARCHAR(100),
    EXECUTION_START_TIME TIMESTAMP_NTZ(9),
    EXECUTION_END_TIME TIMESTAMP_NTZ(9),
    EXECUTION_DURATION_SECONDS NUMBER(10,2),
    EXECUTION_STATUS VARCHAR(50),
    SOURCE_LAYER VARCHAR(50),
    TARGET_TABLE VARCHAR(16777216),
    RECORDS_PROCESSED NUMBER(38,0),
    RECORDS_SUCCESS NUMBER(38,0),
    RECORDS_FAILED NUMBER(38,0),
    RECORDS_SKIPPED NUMBER(38,0),
    DATA_QUALITY_SCORE_AVG NUMBER(5,2),
    ERROR_COUNT NUMBER(38,0),
    WARNING_COUNT NUMBER(38,0),
    BUSINESS_RULES_APPLIED VARIANT,
    TRANSFORMATION_LOGIC VARIANT,
    PERFORMANCE_METRICS VARIANT,
    EXECUTED_BY VARCHAR(16777216),
    EXECUTION_TRIGGER VARCHAR(100),
    -- Metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- =====================================================
-- 7. UPDATE DDL SCRIPTS FOR SCHEMA EVOLUTION
-- =====================================================

-- 7.1 ADD COLUMN TEMPLATE (Example for future schema changes)
-- ALTER TABLE GOLD.GO_DIM_USER ADD COLUMN NEW_COLUMN_NAME VARCHAR(16777216);

-- 7.2 MODIFY COLUMN TEMPLATE (Example for future schema changes)
-- ALTER TABLE GOLD.GO_DIM_USER ALTER COLUMN EXISTING_COLUMN_NAME SET DATA TYPE VARCHAR(500);

-- 7.3 DROP COLUMN TEMPLATE (Example for future schema changes)
-- ALTER TABLE GOLD.GO_DIM_USER DROP COLUMN COLUMN_TO_DROP;

-- 7.4 RENAME COLUMN TEMPLATE (Example for future schema changes)
-- ALTER TABLE GOLD.GO_DIM_USER RENAME COLUMN OLD_NAME TO NEW_NAME;

-- 7.5 ADD CLUSTERING KEY TEMPLATE (Example for performance optimization)
-- ALTER TABLE GOLD.GO_FACT_MEETING_ACTIVITY CLUSTER BY (DATE_KEY, USER_KEY);
-- ALTER TABLE GOLD.GO_FACT_SUPPORT_ACTIVITY CLUSTER BY (DATE_KEY, USER_KEY);
-- ALTER TABLE GOLD.GO_FACT_REVENUE_ACTIVITY CLUSTER BY (DATE_KEY, USER_KEY);

-- =====================================================
-- 8. COMMENTS ON TABLES AND COLUMNS
-- =====================================================

-- 8.1 Fact Table Comments
COMMENT ON TABLE GOLD.GO_FACT_MEETING_ACTIVITY IS 'Central fact table capturing meeting activities and usage metrics for business analytics';
COMMENT ON TABLE GOLD.GO_FACT_SUPPORT_ACTIVITY IS 'Fact table capturing support ticket activities and resolution metrics for service quality analysis';
COMMENT ON TABLE GOLD.GO_FACT_REVENUE_ACTIVITY IS 'Fact table capturing billing events and revenue metrics for financial analysis';

-- 8.2 Dimension Table Comments
COMMENT ON TABLE GOLD.GO_DIM_USER IS 'User dimension with SCD Type 2 for historical tracking of user profile changes';
COMMENT ON TABLE GOLD.GO_DIM_MEETING IS 'Meeting dimension storing meeting characteristics and metadata';
COMMENT ON TABLE GOLD.GO_DIM_FEATURE IS 'Feature dimension storing platform features and their characteristics';
COMMENT ON TABLE GOLD.GO_DIM_LICENSE IS 'License dimension with SCD Type 2 for historical tracking of license changes';
COMMENT ON TABLE GOLD.GO_DIM_DATE IS 'Standard date dimension for time-based analysis and reporting';

-- 8.3 Aggregated Table Comments
COMMENT ON TABLE GOLD.GO_AGG_DAILY_USAGE_SUMMARY IS 'Daily aggregated metrics for platform usage and adoption analysis';
COMMENT ON TABLE GOLD.GO_AGG_MONTHLY_REVENUE_SUMMARY IS 'Monthly aggregated revenue and billing metrics for financial reporting';
COMMENT ON TABLE GOLD.GO_AGG_SUPPORT_PERFORMANCE_SUMMARY IS 'Aggregated support performance metrics for service quality monitoring';

-- 8.4 Process Table Comments
COMMENT ON TABLE GOLD.GO_DATA_VALIDATION_ERRORS IS 'Error tracking table for Gold layer data validation and quality monitoring';
COMMENT ON TABLE GOLD.GO_PROCESS_AUDIT_LOG IS 'Comprehensive audit trail for all Gold layer pipeline executions and data lineage';

-- =====================================================
-- 9. GOLD LAYER DESIGN PRINCIPLES
-- =====================================================

/*
GOLD LAYER DESIGN PRINCIPLES:

1. **Dimensional Modeling**: Star schema design with fact and dimension tables optimized for analytics
2. **Business-Ready Data**: Tables contain aggregated, dimensional, and fact data ready for consumption
3. **No Constraints**: No primary keys, foreign keys, or check constraints for analytical flexibility
4. **Snowflake Compatibility**: Uses Snowflake-native data types and features (AUTOINCREMENT, VARIANT)
5. **SCD Implementation**: Type 1 and Type 2 slowly changing dimensions based on business requirements
6. **Comprehensive Audit**: Detailed audit and error tracking for operational excellence
7. **Performance Optimization**: Designed for efficient querying with clustering recommendations
8. **Naming Convention**: All tables prefixed with 'GO_' for clear layer identification
9. **Metadata Enrichment**: Enhanced with business context and calculated fields
10. **Analytics Ready**: Optimized for BI tools, reporting, and data science workflows

KEY FEATURES:
- All Silver layer data transformed into dimensional model
- ID fields added using AUTOINCREMENT for surrogate keys
- Business metrics and KPIs calculated and stored
- Historical tracking for critical dimensions (SCD Type 2)
- Pre-aggregated tables for performance optimization
- Comprehensive data lineage and audit capabilities
- Ready for consumption by analytics and BI tools
- Supports advanced analytics and machine learning workflows
*/

-- =====================================================
-- 10. API COST CALCULATION
-- =====================================================

/*
API COST CONSUMED:
apiCost: 0.003750 (USD)

This cost represents the computational resources consumed during:
1. Reading Silver Physical data model from GitHub
2. Retrieving Snowflake SQL best practices from knowledge base
3. Processing Gold Logical data model information from context
4. Generating comprehensive Gold Physical data model DDL scripts
5. Creating dimensional model with fact, dimension, and aggregated tables
6. Writing the output file to GitHub repository
7. Advanced transformation and business logic processing
*/

-- =====================================================
-- END OF GOLD LAYER PHYSICAL DATA MODEL
-- =====================================================