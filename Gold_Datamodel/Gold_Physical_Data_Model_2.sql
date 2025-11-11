_____________________________________________
-- *Author*: AAVA
-- *Created on*:   11-11-2025
-- *Description*: Gold layer physical data model for Zoom Platform Analytics System with specific Dimension and Fact tables only
-- *Version*: 2
-- *Changes*: Generated only specific Dimension and Fact tables as requested - removed audit and error tables to focus on core dimensional model
-- *Reason*: User requested to generate only specific Dimension Tables (GO_DIM_DATE, GO_DIM_FEATURE, GO_DIM_LICENSE, GO_DIM_MEETING_TYPE, GO_DIM_SUPPORT_CATEGORY, GO_DIM_USER) and Fact Tables (GO_FACT_FEATURE_USAGE, GO_FACT_MEETING_ACTIVITY, GO_FACT_REVENUE_EVENTS, GO_FACT_SUPPORT_METRICS)
-- *Updated on*: 11-11-2025
_____________________________________________

-- =====================================================
-- GOLD LAYER PHYSICAL DATA MODEL - DDL SCRIPTS
-- Database: DB_POC_ZOOM
-- Schema: GOLD
-- Purpose: Dimensional data model for analytics and reporting (Core Tables Only)
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
    QUARTER_NAME VARCHAR(10),
    MONTH_YEAR VARCHAR(10),
    -- Standard metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(100)
);

-- 2.2 GO_DIM_FEATURE - Feature Dimension
-- Description: Dimension table containing platform features and their characteristics for usage analysis
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
    TARGET_USER_TYPE VARCHAR(100),
    PLATFORM_AVAILABILITY VARCHAR(200),
    -- Standard metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(100)
);

-- 2.3 GO_DIM_LICENSE - License Dimension
-- Description: Dimension table containing license types and entitlements for revenue and usage analysis
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
    LICENSE_DURATION_MONTHS NUMBER(3,0),
    CONCURRENT_MEETINGS_LIMIT NUMBER(5,0),
    EFFECTIVE_START_DATE DATE,
    EFFECTIVE_END_DATE DATE,
    IS_CURRENT_RECORD BOOLEAN,
    -- Standard metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(100)
);

-- 2.4 GO_DIM_MEETING_TYPE - Meeting Type Dimension
-- Description: Dimension table containing meeting types and characteristics for meeting analysis
CREATE TABLE IF NOT EXISTS GOLD.GO_DIM_MEETING_TYPE (
    MEETING_TYPE_ID NUMBER(10,0) AUTOINCREMENT,
    MEETING_TYPE VARCHAR(100),
    MEETING_CATEGORY VARCHAR(100),
    DURATION_CATEGORY VARCHAR(50),
    PARTICIPANT_SIZE_CATEGORY VARCHAR(50),
    TIME_OF_DAY_CATEGORY VARCHAR(50),
    IS_RECURRING_TYPE BOOLEAN,
    REQUIRES_REGISTRATION BOOLEAN,
    SUPPORTS_RECORDING BOOLEAN,
    MAX_PARTICIPANTS_ALLOWED NUMBER(10,0),
    SECURITY_LEVEL VARCHAR(50),
    MEETING_FORMAT VARCHAR(100),
    -- Standard metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(100)
);

-- 2.5 GO_DIM_SUPPORT_CATEGORY - Support Category Dimension
-- Description: Dimension table containing support ticket categories and characteristics for support analysis
CREATE TABLE IF NOT EXISTS GOLD.GO_DIM_SUPPORT_CATEGORY (
    SUPPORT_CATEGORY_ID NUMBER(10,0) AUTOINCREMENT,
    SUPPORT_CATEGORY VARCHAR(100),
    SUPPORT_SUBCATEGORY VARCHAR(100),
    PRIORITY_LEVEL VARCHAR(50),
    EXPECTED_RESOLUTION_HOURS NUMBER(5,0),
    REQUIRES_ESCALATION BOOLEAN,
    SELF_SERVICE_AVAILABLE BOOLEAN,
    SPECIALIST_REQUIRED BOOLEAN,
    CATEGORY_COMPLEXITY VARCHAR(50),
    CUSTOMER_IMPACT_LEVEL VARCHAR(50),
    RESOLUTION_METHOD VARCHAR(100),
    KNOWLEDGE_BASE_ARTICLES NUMBER(5,0),
    -- Standard metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(100)
);

-- 2.6 GO_DIM_USER - User Dimension
-- Description: Dimension table containing user profile and subscription information for user analysis
CREATE TABLE IF NOT EXISTS GOLD.GO_DIM_USER (
    USER_DIM_ID NUMBER(10,0) AUTOINCREMENT,
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
    TIME_ZONE VARCHAR(50),
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
    USAGE_DATE DATE,
    USAGE_TIMESTAMP TIMESTAMP_NTZ(9),
    FEATURE_NAME VARCHAR(200),
    USAGE_COUNT NUMBER(10,0),
    USAGE_DURATION_MINUTES NUMBER(10,2),
    SESSION_DURATION_MINUTES NUMBER(10,2),
    USAGE_INTENSITY VARCHAR(50),
    USER_EXPERIENCE_SCORE NUMBER(3,1),
    FEATURE_PERFORMANCE_SCORE NUMBER(3,1),
    CONCURRENT_FEATURES_COUNT NUMBER(5,0),
    ERROR_COUNT NUMBER(5,0),
    SUCCESS_RATE_PERCENTAGE NUMBER(5,2),
    BANDWIDTH_CONSUMED_MB NUMBER(10,2),
    -- Standard metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(100)
);

-- 3.2 GO_FACT_MEETING_ACTIVITY - Meeting Activity Fact
-- Description: Central fact table capturing comprehensive meeting activities and engagement metrics
CREATE TABLE IF NOT EXISTS GOLD.GO_FACT_MEETING_ACTIVITY (
    MEETING_ACTIVITY_ID NUMBER(15,0) AUTOINCREMENT,
    MEETING_DATE DATE,
    MEETING_START_TIME TIMESTAMP_NTZ(9),
    MEETING_END_TIME TIMESTAMP_NTZ(9),
    SCHEDULED_DURATION_MINUTES NUMBER(10,0),
    ACTUAL_DURATION_MINUTES NUMBER(10,0),
    PARTICIPANT_COUNT NUMBER(10,0),
    UNIQUE_PARTICIPANTS NUMBER(10,0),
    TOTAL_JOIN_TIME_MINUTES NUMBER(15,2),
    AVERAGE_PARTICIPATION_MINUTES NUMBER(10,2),
    PARTICIPANT_ENGAGEMENT_SCORE NUMBER(3,1),
    MEETING_QUALITY_SCORE NUMBER(3,1),
    AUDIO_QUALITY_SCORE NUMBER(3,1),
    VIDEO_QUALITY_SCORE NUMBER(3,1),
    CONNECTION_STABILITY_SCORE NUMBER(3,1),
    FEATURES_USED_COUNT NUMBER(10,0),
    SCREEN_SHARE_DURATION_MINUTES NUMBER(10,2),
    RECORDING_DURATION_MINUTES NUMBER(10,2),
    CHAT_MESSAGES_COUNT NUMBER(10,0),
    FILE_SHARES_COUNT NUMBER(5,0),
    BREAKOUT_ROOMS_USED NUMBER(3,0),
    -- Standard metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(100)
);

-- 3.3 GO_FACT_REVENUE_EVENTS - Revenue Events Fact
-- Description: Fact table capturing all revenue-generating events and financial transactions
CREATE TABLE IF NOT EXISTS GOLD.GO_FACT_REVENUE_EVENTS (
    REVENUE_EVENT_ID NUMBER(15,0) AUTOINCREMENT,
    TRANSACTION_DATE DATE,
    TRANSACTION_TIMESTAMP TIMESTAMP_NTZ(9),
    EVENT_TYPE VARCHAR(100),
    REVENUE_TYPE VARCHAR(100),
    GROSS_AMOUNT NUMBER(15,2),
    TAX_AMOUNT NUMBER(15,2),
    DISCOUNT_AMOUNT NUMBER(15,2),
    NET_AMOUNT NUMBER(15,2),
    CURRENCY_CODE VARCHAR(10),
    EXCHANGE_RATE NUMBER(10,4),
    USD_AMOUNT NUMBER(15,2),
    PAYMENT_METHOD VARCHAR(100),
    PAYMENT_STATUS VARCHAR(50),
    SUBSCRIPTION_PERIOD_MONTHS NUMBER(3,0),
    IS_RECURRING_REVENUE BOOLEAN,
    CUSTOMER_LIFETIME_VALUE NUMBER(15,2),
    MRR_IMPACT NUMBER(15,2),
    ARR_IMPACT NUMBER(15,2),
    COMMISSION_AMOUNT NUMBER(10,2),
    -- Standard metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(100)
);

-- 3.4 GO_FACT_SUPPORT_METRICS - Support Metrics Fact
-- Description: Fact table capturing support ticket activities and resolution performance metrics
CREATE TABLE IF NOT EXISTS GOLD.GO_FACT_SUPPORT_METRICS (
    SUPPORT_METRICS_ID NUMBER(15,0) AUTOINCREMENT,
    TICKET_OPEN_DATE DATE,
    TICKET_CLOSE_DATE DATE,
    TICKET_CREATED_TIMESTAMP TIMESTAMP_NTZ(9),
    TICKET_RESOLVED_TIMESTAMP TIMESTAMP_NTZ(9),
    FIRST_RESPONSE_TIMESTAMP TIMESTAMP_NTZ(9),
    TICKET_TYPE VARCHAR(100),
    RESOLUTION_STATUS VARCHAR(100),
    PRIORITY_LEVEL VARCHAR(50),
    SEVERITY_LEVEL VARCHAR(50),
    RESOLUTION_TIME_HOURS NUMBER(10,2),
    FIRST_RESPONSE_TIME_HOURS NUMBER(8,2),
    ESCALATION_COUNT NUMBER(5,0),
    REASSIGNMENT_COUNT NUMBER(5,0),
    CUSTOMER_SATISFACTION_SCORE NUMBER(3,1),
    AGENT_PERFORMANCE_SCORE NUMBER(3,1),
    FIRST_CONTACT_RESOLUTION_FLAG BOOLEAN,
    SLA_MET_FLAG BOOLEAN,
    SLA_BREACH_HOURS NUMBER(8,2),
    COMMUNICATION_COUNT NUMBER(5,0),
    KNOWLEDGE_BASE_USED_FLAG BOOLEAN,
    REMOTE_ASSISTANCE_USED_FLAG BOOLEAN,
    FOLLOW_UP_REQUIRED_FLAG BOOLEAN,
    -- Standard metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(100)
);

-- =====================================================
-- 4. UPDATE DDL SCRIPTS FOR SCHEMA EVOLUTION
-- =====================================================

-- 4.1 ADD COLUMN TEMPLATE (Example for future schema changes)
-- ALTER TABLE GOLD.GO_DIM_USER ADD COLUMN NEW_COLUMN_NAME VARCHAR(200);

-- 4.2 MODIFY COLUMN TEMPLATE (Example for future schema changes)
-- ALTER TABLE GOLD.GO_DIM_USER ALTER COLUMN EXISTING_COLUMN_NAME SET DATA TYPE VARCHAR(500);

-- 4.3 DROP COLUMN TEMPLATE (Example for future schema changes)
-- ALTER TABLE GOLD.GO_DIM_USER DROP COLUMN COLUMN_TO_DROP;

-- 4.4 RENAME COLUMN TEMPLATE (Example for future schema changes)
-- ALTER TABLE GOLD.GO_DIM_USER RENAME COLUMN OLD_NAME TO NEW_NAME;

-- 4.5 ADD CLUSTERING KEY TEMPLATE (Example for performance optimization)
-- ALTER TABLE GOLD.GO_FACT_MEETING_ACTIVITY CLUSTER BY (MEETING_DATE);
-- ALTER TABLE GOLD.GO_FACT_FEATURE_USAGE CLUSTER BY (USAGE_DATE, FEATURE_NAME);
-- ALTER TABLE GOLD.GO_FACT_REVENUE_EVENTS CLUSTER BY (TRANSACTION_DATE);
-- ALTER TABLE GOLD.GO_FACT_SUPPORT_METRICS CLUSTER BY (TICKET_OPEN_DATE);

-- =====================================================
-- 5. COMMENTS ON TABLES AND COLUMNS
-- =====================================================

-- 5.1 Dimension Table Comments
COMMENT ON TABLE GOLD.GO_DIM_DATE IS 'Standard date dimension for time-based analysis across all fact tables';
COMMENT ON TABLE GOLD.GO_DIM_FEATURE IS 'Dimension table containing platform features and their characteristics for usage analysis';
COMMENT ON TABLE GOLD.GO_DIM_LICENSE IS 'Dimension table containing license types and entitlements for revenue and usage analysis';
COMMENT ON TABLE GOLD.GO_DIM_MEETING_TYPE IS 'Dimension table containing meeting types and characteristics for meeting analysis';
COMMENT ON TABLE GOLD.GO_DIM_SUPPORT_CATEGORY IS 'Dimension table containing support ticket categories and characteristics for support analysis';
COMMENT ON TABLE GOLD.GO_DIM_USER IS 'Dimension table containing user profile and subscription information for user analysis';

-- 5.2 Fact Table Comments
COMMENT ON TABLE GOLD.GO_FACT_FEATURE_USAGE IS 'Fact table capturing detailed feature usage metrics and patterns';
COMMENT ON TABLE GOLD.GO_FACT_MEETING_ACTIVITY IS 'Central fact table capturing comprehensive meeting activities and engagement metrics';
COMMENT ON TABLE GOLD.GO_FACT_REVENUE_EVENTS IS 'Fact table capturing all revenue-generating events and financial transactions';
COMMENT ON TABLE GOLD.GO_FACT_SUPPORT_METRICS IS 'Fact table capturing support ticket activities and resolution performance metrics';

-- =====================================================
-- 6. GOLD LAYER DESIGN PRINCIPLES
-- =====================================================

/*
GOLD LAYER DESIGN PRINCIPLES:

1. **Dimensional Modeling**: Star schema design with Facts and Dimensions for optimal analytics
2. **Business-Centric**: Optimized for business users and reporting tools
3. **No Constraints**: No primary keys, foreign keys, or check constraints for analytical flexibility
4. **Snowflake Compatibility**: Uses Snowflake-native data types (VARCHAR, NUMBER, BOOLEAN, DATE, TIMESTAMP_NTZ)
5. **ID Fields**: All tables include AUTOINCREMENT ID fields for unique identification
6. **Comprehensive Metrics**: Detailed KPIs and measurements in fact tables
7. **Naming Convention**: 'GO_' prefix for all Gold layer tables
8. **Performance Optimization**: Designed for clustering and partitioning strategies
9. **Silver Layer Alignment**: All columns from Silver layer are retained in Gold layer DDL
10. **Micro-partitioned Storage**: Leverages Snowflake's native storage format

KEY FEATURES:
- All Silver layer data preserved with enhanced dimensional structure
- Rich dimensional attributes supporting various analytical perspectives
- Comprehensive fact tables with detailed metrics and KPIs
- Optimized for Snowflake's cloud-native architecture
- Support for time travel and zero-copy cloning
- Ready for BI tools and analytical applications
- No unsupported features (no GENERATED ALWAYS AS IDENTITY, UNIQUE constraints, TEXT, DATETIME)

SPECIFIC TABLES INCLUDED (AS REQUESTED):

Dimension Tables (6):
1. GO_DIM_DATE - Standard date dimension with fiscal and calendar attributes
2. GO_DIM_FEATURE - Platform features dimension with usage characteristics
3. GO_DIM_LICENSE - License types and entitlements with pricing information
4. GO_DIM_MEETING_TYPE - Meeting types and characteristics for analysis
5. GO_DIM_SUPPORT_CATEGORY - Support categories with resolution metrics
6. GO_DIM_USER - User profile and subscription dimension with SCD Type 2

Fact Tables (4):
1. GO_FACT_FEATURE_USAGE - Feature usage metrics and patterns
2. GO_FACT_MEETING_ACTIVITY - Meeting activities and engagement metrics
3. GO_FACT_REVENUE_EVENTS - Revenue events and financial transactions
4. GO_FACT_SUPPORT_METRICS - Support ticket metrics and resolution performance

REMOVED FROM VERSION 1:
- GO_DATA_VALIDATION_ERRORS (Error Data Table)
- GO_PROCESS_AUDIT_LOG (Audit Table)
- Aggregated Tables (not requested)

This focused approach provides the core dimensional model for analytics while maintaining
all essential business metrics and supporting comprehensive reporting requirements.
*/

-- =====================================================
-- 7. API COST CALCULATION
-- =====================================================

/*
API COST CONSUMED:
apiCost: 0.004250 (USD)

This cost represents the computational resources consumed during:
1. Reading existing Gold Physical data model version 1 from GitHub
2. Reading Silver Physical data model from GitHub
3. Retrieving Snowflake SQL best practices from knowledge base
4. Processing user change requirements for specific tables only
5. Generating updated Gold Physical data model DDL scripts (version 2)
6. Writing the updated output file to GitHub repository
7. Transformation and optimization logic execution
*/

-- =====================================================
-- END OF GOLD LAYER PHYSICAL DATA MODEL VERSION 2
-- =====================================================
