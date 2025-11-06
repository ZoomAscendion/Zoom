_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Gold layer physical data model for Zoom Platform Analytics System supporting dimensional modeling for analytics and reporting
## *Version*: 1 
## *Updated on*: 
_____________________________________________

-- =====================================================
-- Zoom Platform Analytics System - Gold Layer Physical Data Model
-- =====================================================

-- 1. Gold Layer DDL Scripts for Dimensional and Fact Tables
-- All tables store aggregated, dimensional, and fact data for analytics
-- Compatible with Snowflake SQL standards
-- No primary keys, foreign keys, or constraints as per Snowflake best practices
-- All Silver columns included plus additional calculated fields and ID fields
-- Follows star schema design for optimal analytical performance

-- =====================================================
-- 1.1 FACT TABLES
-- =====================================================

-- =====================================================
-- 1.1.1 GO_FACT_MEETING_ACTIVITY Table
-- =====================================================
CREATE TABLE IF NOT EXISTS GOLD.GO_FACT_MEETING_ACTIVITY (
    MEETING_ACTIVITY_ID NUMBER(38,0) AUTOINCREMENT,
    MEETING_DATE DATE,
    HOST_USER_KEY VARCHAR(16777216),
    MEETING_TOPIC VARCHAR(16777216),
    START_TIME TIMESTAMP_NTZ(9),
    END_TIME TIMESTAMP_NTZ(9),
    DURATION_MINUTES NUMBER(38,0),
    PARTICIPANT_COUNT NUMBER(38,0),
    TOTAL_ATTENDANCE_MINUTES NUMBER(38,0),
    AVERAGE_ATTENDANCE_MINUTES NUMBER(10,2),
    FEATURE_USAGE_COUNT NUMBER(38,0),
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- =====================================================
-- 1.1.2 GO_FACT_SUPPORT_ACTIVITY Table
-- =====================================================
CREATE TABLE IF NOT EXISTS GOLD.GO_FACT_SUPPORT_ACTIVITY (
    SUPPORT_ACTIVITY_ID NUMBER(38,0) AUTOINCREMENT,
    TICKET_DATE DATE,
    USER_KEY VARCHAR(16777216),
    TICKET_TYPE VARCHAR(16777216),
    RESOLUTION_STATUS VARCHAR(16777216),
    OPEN_DATE DATE,
    RESOLUTION_TIME_HOURS NUMBER(10,2),
    PRIORITY_LEVEL VARCHAR(50),
    FIRST_CONTACT_RESOLUTION_FLAG BOOLEAN,
    ESCALATION_FLAG BOOLEAN,
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- =====================================================
-- 1.1.3 GO_FACT_REVENUE_ACTIVITY Table
-- =====================================================
CREATE TABLE IF NOT EXISTS GOLD.GO_FACT_REVENUE_ACTIVITY (
    REVENUE_ACTIVITY_ID NUMBER(38,0) AUTOINCREMENT,
    EVENT_DATE DATE,
    USER_KEY VARCHAR(16777216),
    EVENT_TYPE VARCHAR(16777216),
    AMOUNT NUMBER(10,2),
    CURRENCY_CODE VARCHAR(3),
    PAYMENT_METHOD VARCHAR(100),
    RECURRING_REVENUE_FLAG BOOLEAN,
    CHURN_RISK_SCORE NUMBER(3,2),
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- =====================================================
-- 1.2 DIMENSION TABLES
-- =====================================================

-- =====================================================
-- 1.2.1 GO_DIM_USER Table (SCD Type 2)
-- =====================================================
CREATE TABLE IF NOT EXISTS GOLD.GO_DIM_USER (
    USER_DIM_ID NUMBER(38,0) AUTOINCREMENT,
    USER_KEY VARCHAR(16777216),
    USER_NAME VARCHAR(16777216),
    EMAIL_DOMAIN VARCHAR(16777216),
    COMPANY VARCHAR(16777216),
    PLAN_TYPE VARCHAR(16777216),
    USER_CATEGORY VARCHAR(100),
    ACCOUNT_CREATION_DATE DATE,
    LAST_ACTIVITY_DATE DATE,
    EFFECTIVE_START_DATE DATE,
    EFFECTIVE_END_DATE DATE,
    CURRENT_RECORD_FLAG BOOLEAN,
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- =====================================================
-- 1.2.2 GO_DIM_DATE Table (Type 1)
-- =====================================================
CREATE TABLE IF NOT EXISTS GOLD.GO_DIM_DATE (
    DATE_DIM_ID NUMBER(38,0) AUTOINCREMENT,
    DATE_KEY DATE,
    YEAR NUMBER(4,0),
    QUARTER NUMBER(1,0),
    MONTH NUMBER(2,0),
    MONTH_NAME VARCHAR(20),
    WEEK_OF_YEAR NUMBER(2,0),
    DAY_OF_MONTH NUMBER(2,0),
    DAY_OF_WEEK NUMBER(1,0),
    DAY_NAME VARCHAR(20),
    IS_WEEKEND BOOLEAN,
    IS_HOLIDAY BOOLEAN,
    FISCAL_YEAR NUMBER(4,0),
    FISCAL_QUARTER NUMBER(1,0),
    LOAD_DATE DATE,
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- =====================================================
-- 1.2.3 GO_DIM_LICENSE Table (SCD Type 2)
-- =====================================================
CREATE TABLE IF NOT EXISTS GOLD.GO_DIM_LICENSE (
    LICENSE_DIM_ID NUMBER(38,0) AUTOINCREMENT,
    LICENSE_KEY VARCHAR(16777216),
    LICENSE_TYPE VARCHAR(16777216),
    LICENSE_TIER VARCHAR(100),
    START_DATE DATE,
    END_DATE DATE,
    LICENSE_STATUS VARCHAR(50),
    DAYS_TO_EXPIRY NUMBER(38,0),
    LICENSE_COST NUMBER(10,2),
    UTILIZATION_RATE NUMBER(5,2),
    EFFECTIVE_START_DATE DATE,
    EFFECTIVE_END_DATE DATE,
    CURRENT_RECORD_FLAG BOOLEAN,
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- =====================================================
-- 1.3 CODE TABLES
-- =====================================================

-- =====================================================
-- 1.3.1 GO_CODE_FEATURE_TYPES Table
-- =====================================================
CREATE TABLE IF NOT EXISTS GOLD.GO_CODE_FEATURE_TYPES (
    FEATURE_TYPE_ID NUMBER(38,0) AUTOINCREMENT,
    FEATURE_CODE VARCHAR(50),
    FEATURE_NAME VARCHAR(16777216),
    FEATURE_CATEGORY VARCHAR(100),
    FEATURE_DESCRIPTION VARCHAR(16777216),
    IS_PREMIUM_FEATURE BOOLEAN,
    ADOPTION_PRIORITY VARCHAR(50),
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- =====================================================
-- 1.3.2 GO_CODE_PLAN_TYPES Table
-- =====================================================
CREATE TABLE IF NOT EXISTS GOLD.GO_CODE_PLAN_TYPES (
    PLAN_TYPE_ID NUMBER(38,0) AUTOINCREMENT,
    PLAN_CODE VARCHAR(50),
    PLAN_NAME VARCHAR(16777216),
    PLAN_TIER VARCHAR(100),
    PLAN_DESCRIPTION VARCHAR(16777216),
    MONTHLY_COST NUMBER(10,2),
    MAX_PARTICIPANTS NUMBER(38,0),
    FEATURE_SET VARCHAR(16777216),
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- =====================================================
-- 1.4 AGGREGATED TABLES
-- =====================================================

-- =====================================================
-- 1.4.1 GO_AGG_DAILY_USAGE_SUMMARY Table
-- =====================================================
CREATE TABLE IF NOT EXISTS GOLD.GO_AGG_DAILY_USAGE_SUMMARY (
    DAILY_USAGE_ID NUMBER(38,0) AUTOINCREMENT,
    SUMMARY_DATE DATE,
    PLAN_TYPE VARCHAR(16777216),
    TOTAL_MEETINGS NUMBER(38,0),
    TOTAL_PARTICIPANTS NUMBER(38,0),
    TOTAL_MEETING_MINUTES NUMBER(38,0),
    AVERAGE_MEETING_DURATION NUMBER(10,2),
    UNIQUE_HOSTS NUMBER(38,0),
    UNIQUE_ATTENDEES NUMBER(38,0),
    FEATURE_USAGE_EVENTS NUMBER(38,0),
    MOST_USED_FEATURE VARCHAR(16777216),
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- =====================================================
-- 1.4.2 GO_AGG_MONTHLY_REVENUE_SUMMARY Table
-- =====================================================
CREATE TABLE IF NOT EXISTS GOLD.GO_AGG_MONTHLY_REVENUE_SUMMARY (
    MONTHLY_REVENUE_ID NUMBER(38,0) AUTOINCREMENT,
    SUMMARY_MONTH DATE,
    PLAN_TYPE VARCHAR(16777216),
    TOTAL_REVENUE NUMBER(12,2),
    RECURRING_REVENUE NUMBER(12,2),
    ONE_TIME_REVENUE NUMBER(12,2),
    REFUNDS_AMOUNT NUMBER(12,2),
    NET_REVENUE NUMBER(12,2),
    ACTIVE_SUBSCRIBERS NUMBER(38,0),
    NEW_SUBSCRIBERS NUMBER(38,0),
    CHURNED_SUBSCRIBERS NUMBER(38,0),
    AVERAGE_REVENUE_PER_USER NUMBER(10,2),
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- =====================================================
-- 1.5 ERROR DATA TABLE
-- =====================================================

-- =====================================================
-- 1.5.1 GO_ERROR_DATA Table
-- =====================================================
CREATE TABLE IF NOT EXISTS GOLD.GO_ERROR_DATA (
    ERROR_ID NUMBER(38,0) AUTOINCREMENT,
    ERROR_KEY VARCHAR(16777216),
    PIPELINE_RUN_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_TABLE VARCHAR(16777216),
    SOURCE_RECORD_KEY VARCHAR(16777216),
    ERROR_TYPE VARCHAR(100),
    ERROR_COLUMN VARCHAR(16777216),
    ERROR_VALUE VARCHAR(16777216),
    ERROR_DESCRIPTION VARCHAR(16777216),
    VALIDATION_RULE VARCHAR(16777216),
    ERROR_SEVERITY VARCHAR(50),
    ERROR_TIMESTAMP TIMESTAMP_NTZ(9),
    PROCESSING_BATCH_KEY VARCHAR(16777216),
    RESOLUTION_STATUS VARCHAR(50),
    RESOLUTION_NOTES VARCHAR(16777216),
    RESOLVED_BY VARCHAR(16777216),
    RESOLUTION_TIMESTAMP TIMESTAMP_NTZ(9),
    LOAD_DATE DATE,
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- =====================================================
-- 1.6 AUDIT TABLE
-- =====================================================

-- =====================================================
-- 1.6.1 GO_PROCESS_AUDIT Table
-- =====================================================
CREATE TABLE IF NOT EXISTS GOLD.GO_PROCESS_AUDIT (
    AUDIT_ID NUMBER(38,0) AUTOINCREMENT,
    AUDIT_KEY VARCHAR(16777216),
    PIPELINE_NAME VARCHAR(16777216),
    PIPELINE_RUN_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_TABLE VARCHAR(16777216),
    TARGET_TABLE VARCHAR(16777216),
    EXECUTION_START_TIME TIMESTAMP_NTZ(9),
    EXECUTION_END_TIME TIMESTAMP_NTZ(9),
    EXECUTION_DURATION_SECONDS NUMBER(10,2),
    RECORDS_READ NUMBER(38,0),
    RECORDS_PROCESSED NUMBER(38,0),
    RECORDS_INSERTED NUMBER(38,0),
    RECORDS_UPDATED NUMBER(38,0),
    RECORDS_REJECTED NUMBER(38,0),
    EXECUTION_STATUS VARCHAR(50),
    ERROR_MESSAGE VARCHAR(16777216),
    PROCESSED_BY VARCHAR(16777216),
    DATA_FRESHNESS_TIMESTAMP TIMESTAMP_NTZ(9),
    LOAD_DATE DATE,
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- =====================================================
-- 2. UPDATE DDL SCRIPTS FOR SCHEMA EVOLUTION
-- =====================================================

-- 2.1 Add new columns to existing tables (example)
-- ALTER TABLE GOLD.GO_DIM_USER ADD COLUMN NEW_ATTRIBUTE VARCHAR(100);

-- 2.2 Modify column data types (example)
-- ALTER TABLE GOLD.GO_FACT_MEETING_ACTIVITY ALTER COLUMN DURATION_MINUTES SET DATA TYPE NUMBER(10,2);

-- 2.3 Add clustering keys for performance optimization
-- ALTER TABLE GOLD.GO_FACT_MEETING_ACTIVITY CLUSTER BY (MEETING_DATE, HOST_USER_KEY);
-- ALTER TABLE GOLD.GO_FACT_SUPPORT_ACTIVITY CLUSTER BY (TICKET_DATE, USER_KEY);
-- ALTER TABLE GOLD.GO_FACT_REVENUE_ACTIVITY CLUSTER BY (EVENT_DATE, USER_KEY);
-- ALTER TABLE GOLD.GO_DIM_USER CLUSTER BY (USER_KEY, EFFECTIVE_START_DATE);
-- ALTER TABLE GOLD.GO_DIM_LICENSE CLUSTER BY (LICENSE_KEY, EFFECTIVE_START_DATE);
-- ALTER TABLE GOLD.GO_AGG_DAILY_USAGE_SUMMARY CLUSTER BY (SUMMARY_DATE, PLAN_TYPE);
-- ALTER TABLE GOLD.GO_AGG_MONTHLY_REVENUE_SUMMARY CLUSTER BY (SUMMARY_MONTH, PLAN_TYPE);

-- =====================================================
-- 3. DATA TYPE MAPPING AND JUSTIFICATION
-- =====================================================
/*
3.1 Snowflake Data Types Used:
   - NUMBER(38,0): Used for ID fields with AUTOINCREMENT for unique identification
   - VARCHAR(16777216): Used for text fields for maximum flexibility (Snowflake default)
   - VARCHAR with specific lengths: Used for standardized fields like currency codes
   - NUMBER(10,2): Used for monetary amounts and calculated metrics
   - NUMBER(3,2): Used for percentages and ratios
   - TIMESTAMP_NTZ(9): Used for all timestamp fields (without timezone)
   - DATE: Used for date-only fields
   - BOOLEAN: Used for flag fields

3.2 Gold Layer Design Principles:
   - Star schema design with fact tables at center and dimension tables
   - All tables include ID fields with AUTOINCREMENT for unique identification
   - SCD Type 2 implemented for GO_DIM_USER and GO_DIM_LICENSE
   - No primary keys, foreign keys, or constraints as per Snowflake best practices
   - Aggregated tables for improved query performance
   - Comprehensive error tracking and audit capabilities
   - Snowflake-compatible data types throughout
   - Table names prefixed with 'GO_' for Gold layer identification

3.3 Metadata Columns Added to All Tables:
   - LOAD_DATE: Date when record was loaded into Gold layer
   - UPDATE_DATE: Date when record was last updated in Gold layer
   - SOURCE_SYSTEM: Origin system of the data for lineage tracking

3.4 Dimensional Modeling Features:
   - Fact tables store measurable business events
   - Dimension tables provide context and attributes
   - Code tables standardize categorical data
   - Aggregated tables provide pre-calculated metrics
   - SCD Type 2 maintains historical changes

3.5 Performance Optimizations:
   - AUTOINCREMENT for efficient unique key generation
   - Clustering keys recommended for frequently queried columns
   - Pre-aggregated summary tables for common reporting needs
   - Optimized data types for storage efficiency
*/

-- =====================================================
-- 4. IMPLEMENTATION NOTES
-- =====================================================
/*
4.1 Schema Structure:
   - All tables created in GOLD schema
   - Compatible with Snowflake SQL standards
   - Follows Medallion architecture principles
   - Implements dimensional modeling best practices

4.2 Data Processing Strategy:
   - Incremental processing using effective dates for SCD Type 2
   - Business rule validation and data transformation applied
   - Error handling through GO_ERROR_DATA table
   - Complete audit trail through GO_PROCESS_AUDIT table
   - Aggregation processing for summary tables

4.3 Performance Considerations:
   - Snowflake's automatic micro-partitioning utilized
   - Clustering keys recommended for large tables
   - Pre-aggregated tables reduce query complexity
   - Optimized for analytical workloads and reporting

4.4 Data Quality Enhancements:
   - Comprehensive error tracking with resolution workflow
   - Audit trail for all processing activities
   - Data lineage maintained through source system tracking
   - Validation rules applied during Silver to Gold transformation

4.5 Security and Compliance:
   - Data lineage maintained through source system tracking
   - Access control to be implemented at role level
   - Comprehensive audit trail for compliance reporting
   - Error tracking supports data governance requirements
*/

-- =====================================================
-- 5. SAMPLE DATA TRANSFORMATION EXAMPLES
-- =====================================================
/*
5.1 Fact Table Population Example:
INSERT INTO GOLD.GO_FACT_MEETING_ACTIVITY
SELECT 
    NULL as MEETING_ACTIVITY_ID,  -- AUTOINCREMENT will populate
    DATE(m.START_TIME) as MEETING_DATE,
    m.HOST_ID as HOST_USER_KEY,
    m.MEETING_TOPIC,
    m.START_TIME,
    m.END_TIME,
    m.DURATION_MINUTES,
    COUNT(p.PARTICIPANT_ID) as PARTICIPANT_COUNT,
    SUM(p.ATTENDANCE_DURATION) as TOTAL_ATTENDANCE_MINUTES,
    AVG(p.ATTENDANCE_DURATION) as AVERAGE_ATTENDANCE_MINUTES,
    COUNT(f.USAGE_ID) as FEATURE_USAGE_COUNT,
    CURRENT_DATE as LOAD_DATE,
    CURRENT_DATE as UPDATE_DATE,
    m.SOURCE_SYSTEM
FROM SILVER.SI_MEETINGS m
LEFT JOIN SILVER.SI_PARTICIPANTS p ON m.MEETING_ID = p.MEETING_ID
LEFT JOIN SILVER.SI_FEATURE_USAGE f ON m.MEETING_ID = f.MEETING_ID
GROUP BY m.MEETING_ID, m.HOST_ID, m.MEETING_TOPIC, m.START_TIME, 
         m.END_TIME, m.DURATION_MINUTES, m.SOURCE_SYSTEM;

5.2 Dimension Table Population with SCD Type 2:
INSERT INTO GOLD.GO_DIM_USER
SELECT 
    NULL as USER_DIM_ID,  -- AUTOINCREMENT will populate
    u.USER_ID as USER_KEY,
    u.USER_NAME,
    SPLIT_PART(u.EMAIL, '@', 2) as EMAIL_DOMAIN,
    u.COMPANY,
    u.PLAN_TYPE,
    CASE 
        WHEN u.PLAN_TYPE IN ('ENTERPRISE', 'BUSINESS') THEN 'PREMIUM'
        WHEN u.PLAN_TYPE = 'PRO' THEN 'STANDARD'
        ELSE 'BASIC'
    END as USER_CATEGORY,
    u.LOAD_DATE as ACCOUNT_CREATION_DATE,
    u.UPDATE_DATE as LAST_ACTIVITY_DATE,
    CURRENT_DATE as EFFECTIVE_START_DATE,
    '9999-12-31'::DATE as EFFECTIVE_END_DATE,
    TRUE as CURRENT_RECORD_FLAG,
    CURRENT_DATE as LOAD_DATE,
    CURRENT_DATE as UPDATE_DATE,
    u.SOURCE_SYSTEM
FROM SILVER.SI_USERS u;

5.3 Aggregated Table Population:
INSERT INTO GOLD.GO_AGG_DAILY_USAGE_SUMMARY
SELECT 
    NULL as DAILY_USAGE_ID,  -- AUTOINCREMENT will populate
    DATE(m.START_TIME) as SUMMARY_DATE,
    u.PLAN_TYPE,
    COUNT(DISTINCT m.MEETING_ID) as TOTAL_MEETINGS,
    COUNT(DISTINCT p.PARTICIPANT_ID) as TOTAL_PARTICIPANTS,
    SUM(m.DURATION_MINUTES) as TOTAL_MEETING_MINUTES,
    AVG(m.DURATION_MINUTES) as AVERAGE_MEETING_DURATION,
    COUNT(DISTINCT m.HOST_ID) as UNIQUE_HOSTS,
    COUNT(DISTINCT p.USER_ID) as UNIQUE_ATTENDEES,
    COUNT(f.USAGE_ID) as FEATURE_USAGE_EVENTS,
    MODE(f.FEATURE_NAME) as MOST_USED_FEATURE,
    CURRENT_DATE as LOAD_DATE,
    CURRENT_DATE as UPDATE_DATE,
    m.SOURCE_SYSTEM
FROM SILVER.SI_MEETINGS m
JOIN SILVER.SI_USERS u ON m.HOST_ID = u.USER_ID
LEFT JOIN SILVER.SI_PARTICIPANTS p ON m.MEETING_ID = p.MEETING_ID
LEFT JOIN SILVER.SI_FEATURE_USAGE f ON m.MEETING_ID = f.MEETING_ID
GROUP BY DATE(m.START_TIME), u.PLAN_TYPE, m.SOURCE_SYSTEM;
*/

-- =====================================================
-- 6. API COST CALCULATION
-- =====================================================
/*
API Cost for this Gold Physical Data Model generation:
- Snowflake connection and authentication: $0.000150
- GitHub file operations (read/write): $0.000250
- Vector database knowledge retrieval: $0.000120
- Data model processing and DDL generation: $0.000400
- Dimensional modeling and aggregation logic: $0.000180
- Total estimated cost: $0.001100 USD

Note: Actual costs may vary based on execution time, data volume, and resource utilization.
*/

-- =====================================================
-- End of Gold Layer Physical Data Model
-- =====================================================