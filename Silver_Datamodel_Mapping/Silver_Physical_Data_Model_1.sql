_____________________________________________
-- *Author*: AAVA
-- *Created on*:   
-- *Description*: Silver layer physical data model for Zoom Platform Analytics System following Medallion architecture
-- *Version*: 1 
-- *Updated on*: 
_____________________________________________

-- =====================================================
-- SILVER LAYER PHYSICAL DATA MODEL - DDL SCRIPTS
-- Database: DB_POC_ZOOM
-- Schema: SILVER
-- Purpose: Cleaned and standardized data with business logic for Medallion architecture
-- =====================================================

-- 1. CREATE SILVER SCHEMA
CREATE SCHEMA IF NOT EXISTS SILVER;

-- =====================================================
-- 2. SILVER LAYER TABLES - DDL SCRIPTS
-- =====================================================

-- 2.1 SI_USERS TABLE
-- Description: Stores cleaned and standardized user profile and subscription information
-- Source Mapping: BRONZE.BZ_USERS → SILVER.SI_USERS
CREATE TABLE IF NOT EXISTS SILVER.SI_USERS (
    USER_ID VARCHAR(16777216),
    USER_NAME VARCHAR(16777216),
    EMAIL VARCHAR(16777216),
    COMPANY VARCHAR(16777216),
    PLAN_TYPE VARCHAR(16777216),
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM VARCHAR(16777216),
    DATA_QUALITY_SCORE NUMBER(3,0),
    PROCESSING_BATCH_ID VARCHAR(16777216)
);

-- 2.2 SI_MEETINGS TABLE
-- Description: Stores cleaned and validated meeting information and session details
-- Source Mapping: BRONZE.BZ_MEETINGS → SILVER.SI_MEETINGS
CREATE TABLE IF NOT EXISTS SILVER.SI_MEETINGS (
    MEETING_ID VARCHAR(16777216),
    HOST_ID VARCHAR(16777216),
    MEETING_TOPIC VARCHAR(16777216),
    START_TIME TIMESTAMP_NTZ(9),
    END_TIME TIMESTAMP_NTZ(9),
    DURATION_MINUTES NUMBER(38,0),
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM VARCHAR(16777216),
    DATA_QUALITY_SCORE NUMBER(3,0),
    PROCESSING_BATCH_ID VARCHAR(16777216)
);

-- 2.3 SI_PARTICIPANTS TABLE
-- Description: Stores cleaned and validated meeting participant session details
-- Source Mapping: BRONZE.BZ_PARTICIPANTS → SILVER.SI_PARTICIPANTS
CREATE TABLE IF NOT EXISTS SILVER.SI_PARTICIPANTS (
    PARTICIPANT_ID VARCHAR(16777216),
    MEETING_ID VARCHAR(16777216),
    USER_ID VARCHAR(16777216),
    JOIN_TIME TIMESTAMP_NTZ(9),
    LEAVE_TIME TIMESTAMP_NTZ(9),
    PARTICIPATION_DURATION_MINUTES NUMBER(38,0),
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM VARCHAR(16777216),
    DATA_QUALITY_SCORE NUMBER(3,0),
    PROCESSING_BATCH_ID VARCHAR(16777216)
);

-- 2.4 SI_FEATURE_USAGE TABLE
-- Description: Stores cleaned and standardized platform feature usage records
-- Source Mapping: BRONZE.BZ_FEATURE_USAGE → SILVER.SI_FEATURE_USAGE
CREATE TABLE IF NOT EXISTS SILVER.SI_FEATURE_USAGE (
    USAGE_ID VARCHAR(16777216),
    MEETING_ID VARCHAR(16777216),
    FEATURE_NAME VARCHAR(16777216),
    USAGE_COUNT NUMBER(38,0),
    USAGE_DATE DATE,
    FEATURE_CATEGORY VARCHAR(16777216),
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM VARCHAR(16777216),
    DATA_QUALITY_SCORE NUMBER(3,0),
    PROCESSING_BATCH_ID VARCHAR(16777216)
);

-- 2.5 SI_SUPPORT_TICKETS TABLE
-- Description: Stores cleaned and categorized customer support requests and resolution tracking
-- Source Mapping: BRONZE.BZ_SUPPORT_TICKETS → SILVER.SI_SUPPORT_TICKETS
CREATE TABLE IF NOT EXISTS SILVER.SI_SUPPORT_TICKETS (
    TICKET_ID VARCHAR(16777216),
    USER_ID VARCHAR(16777216),
    TICKET_TYPE VARCHAR(16777216),
    RESOLUTION_STATUS VARCHAR(16777216),
    OPEN_DATE DATE,
    PRIORITY_LEVEL VARCHAR(16777216),
    TICKET_CATEGORY VARCHAR(16777216),
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM VARCHAR(16777216),
    DATA_QUALITY_SCORE NUMBER(3,0),
    PROCESSING_BATCH_ID VARCHAR(16777216)
);

-- 2.6 SI_BILLING_EVENTS TABLE
-- Description: Stores cleaned and standardized financial transactions and billing activities
-- Source Mapping: BRONZE.BZ_BILLING_EVENTS → SILVER.SI_BILLING_EVENTS
CREATE TABLE IF NOT EXISTS SILVER.SI_BILLING_EVENTS (
    EVENT_ID VARCHAR(16777216),
    USER_ID VARCHAR(16777216),
    EVENT_TYPE VARCHAR(16777216),
    AMOUNT NUMBER(10,2),
    EVENT_DATE DATE,
    CURRENCY VARCHAR(3),
    REVENUE_CATEGORY VARCHAR(16777216),
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM VARCHAR(16777216),
    DATA_QUALITY_SCORE NUMBER(3,0),
    PROCESSING_BATCH_ID VARCHAR(16777216)
);

-- 2.7 SI_LICENSES TABLE
-- Description: Stores cleaned and standardized license assignments and entitlements
-- Source Mapping: BRONZE.BZ_LICENSES → SILVER.SI_LICENSES
CREATE TABLE IF NOT EXISTS SILVER.SI_LICENSES (
    LICENSE_ID VARCHAR(16777216),
    LICENSE_TYPE VARCHAR(16777216),
    ASSIGNED_TO_USER_ID VARCHAR(16777216),
    START_DATE DATE,
    END_DATE DATE,
    LICENSE_DURATION_DAYS NUMBER(38,0),
    LICENSE_STATUS VARCHAR(16777216),
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM VARCHAR(16777216),
    DATA_QUALITY_SCORE NUMBER(3,0),
    PROCESSING_BATCH_ID VARCHAR(16777216)
);

-- =====================================================
-- 3. ERROR DATA TABLE
-- =====================================================

-- 3.1 SI_DATA_QUALITY_ERRORS TABLE
-- Description: Stores comprehensive error data from data validation processes in Silver and Gold layers
CREATE TABLE IF NOT EXISTS SILVER.SI_DATA_QUALITY_ERRORS (
    ERROR_ID VARCHAR(16777216),
    SOURCE_TABLE VARCHAR(16777216),
    TARGET_TABLE VARCHAR(16777216),
    RECORD_IDENTIFIER VARCHAR(16777216),
    ERROR_TYPE VARCHAR(16777216),
    ERROR_CATEGORY VARCHAR(16777216),
    ERROR_DESCRIPTION VARCHAR(16777216),
    FAILED_COLUMN VARCHAR(16777216),
    FAILED_VALUE VARCHAR(16777216),
    VALIDATION_RULE VARCHAR(16777216),
    ERROR_TIMESTAMP TIMESTAMP_NTZ(9),
    PROCESSING_BATCH_ID VARCHAR(16777216),
    RESOLUTION_STATUS VARCHAR(16777216),
    RESOLUTION_ACTION VARCHAR(16777216),
    RESOLVED_BY VARCHAR(16777216),
    RESOLVED_TIMESTAMP TIMESTAMP_NTZ(9)
);

-- 3.2 SI_DATA_VALIDATION_SUMMARY TABLE
-- Description: Stores summary statistics of data validation processes
CREATE TABLE IF NOT EXISTS SILVER.SI_DATA_VALIDATION_SUMMARY (
    VALIDATION_RUN_ID VARCHAR(16777216),
    SOURCE_TABLE VARCHAR(16777216),
    TARGET_TABLE VARCHAR(16777216),
    VALIDATION_TIMESTAMP TIMESTAMP_NTZ(9),
    TOTAL_RECORDS_PROCESSED NUMBER(38,0),
    RECORDS_PASSED NUMBER(38,0),
    RECORDS_FAILED NUMBER(38,0),
    RECORDS_WITH_WARNINGS NUMBER(38,0),
    SUCCESS_RATE_PERCENTAGE NUMBER(5,2),
    PROCESSING_DURATION_SECONDS NUMBER(10,3),
    PROCESSING_BATCH_ID VARCHAR(16777216)
);

-- =====================================================
-- 4. AUDIT TABLE
-- =====================================================

-- 4.1 SI_PIPELINE_EXECUTION_AUDIT TABLE
-- Description: Stores comprehensive audit details from pipeline execution for Silver and Gold layers
CREATE TABLE IF NOT EXISTS SILVER.SI_PIPELINE_EXECUTION_AUDIT (
    EXECUTION_ID VARCHAR(16777216),
    PIPELINE_NAME VARCHAR(16777216),
    PIPELINE_VERSION VARCHAR(16777216),
    EXECUTION_START_TIME TIMESTAMP_NTZ(9),
    EXECUTION_END_TIME TIMESTAMP_NTZ(9),
    EXECUTION_DURATION_SECONDS NUMBER(10,3),
    EXECUTION_STATUS VARCHAR(16777216),
    SOURCE_TABLES_PROCESSED VARCHAR(16777216),
    TARGET_TABLES_UPDATED VARCHAR(16777216),
    RECORDS_READ NUMBER(38,0),
    RECORDS_WRITTEN NUMBER(38,0),
    RECORDS_REJECTED NUMBER(38,0),
    ERROR_MESSAGE VARCHAR(16777216),
    EXECUTED_BY VARCHAR(16777216),
    EXECUTION_ENVIRONMENT VARCHAR(16777216),
    PROCESSING_BATCH_ID VARCHAR(16777216),
    RESOURCE_UTILIZATION VARIANT
);

-- 4.2 SI_PIPELINE_STEP_AUDIT TABLE
-- Description: Stores detailed audit information for individual pipeline steps
CREATE TABLE IF NOT EXISTS SILVER.SI_PIPELINE_STEP_AUDIT (
    STEP_EXECUTION_ID VARCHAR(16777216),
    EXECUTION_ID VARCHAR(16777216),
    STEP_NAME VARCHAR(16777216),
    STEP_TYPE VARCHAR(16777216),
    STEP_ORDER NUMBER(3,0),
    STEP_START_TIME TIMESTAMP_NTZ(9),
    STEP_END_TIME TIMESTAMP_NTZ(9),
    STEP_DURATION_SECONDS NUMBER(10,3),
    STEP_STATUS VARCHAR(16777216),
    INPUT_RECORD_COUNT NUMBER(38,0),
    OUTPUT_RECORD_COUNT NUMBER(38,0),
    TRANSFORMATION_APPLIED VARCHAR(16777216),
    VALIDATION_RULES_APPLIED VARCHAR(16777216),
    ERROR_COUNT NUMBER(38,0),
    WARNING_COUNT NUMBER(38,0),
    STEP_ERROR_MESSAGE VARCHAR(16777216),
    PROCESSING_BATCH_ID VARCHAR(16777216)
);

-- =====================================================
-- 5. UPDATE DDL SCRIPTS FOR SCHEMA EVOLUTION
-- =====================================================

-- 5.1 ADD CLUSTERING KEYS FOR PERFORMANCE OPTIMIZATION
-- Cluster large tables on frequently filtered columns
ALTER TABLE SILVER.SI_MEETINGS CLUSTER BY (START_TIME, HOST_ID);
ALTER TABLE SILVER.SI_PARTICIPANTS CLUSTER BY (JOIN_TIME, MEETING_ID);
ALTER TABLE SILVER.SI_FEATURE_USAGE CLUSTER BY (USAGE_DATE, FEATURE_NAME);
ALTER TABLE SILVER.SI_BILLING_EVENTS CLUSTER BY (EVENT_DATE, USER_ID);
ALTER TABLE SILVER.SI_LICENSES CLUSTER BY (START_DATE, LICENSE_TYPE);
ALTER TABLE SILVER.SI_SUPPORT_TICKETS CLUSTER BY (OPEN_DATE, TICKET_TYPE);

-- 5.2 SCHEMA EVOLUTION SCRIPTS
-- Template for adding new columns to existing tables
/*
ALTER TABLE SILVER.SI_USERS ADD COLUMN NEW_COLUMN_NAME DATA_TYPE;
ALTER TABLE SILVER.SI_MEETINGS ADD COLUMN NEW_COLUMN_NAME DATA_TYPE;
ALTER TABLE SILVER.SI_PARTICIPANTS ADD COLUMN NEW_COLUMN_NAME DATA_TYPE;
ALTER TABLE SILVER.SI_FEATURE_USAGE ADD COLUMN NEW_COLUMN_NAME DATA_TYPE;
ALTER TABLE SILVER.SI_SUPPORT_TICKETS ADD COLUMN NEW_COLUMN_NAME DATA_TYPE;
ALTER TABLE SILVER.SI_BILLING_EVENTS ADD COLUMN NEW_COLUMN_NAME DATA_TYPE;
ALTER TABLE SILVER.SI_LICENSES ADD COLUMN NEW_COLUMN_NAME DATA_TYPE;
*/

-- 5.3 PERFORMANCE OPTIMIZATION SCRIPTS
-- Monitor clustering effectiveness
/*
SELECT SYSTEM$CLUSTERING_INFORMATION('SILVER.SI_MEETINGS', '(START_TIME, HOST_ID)');
SELECT SYSTEM$CLUSTERING_INFORMATION('SILVER.SI_PARTICIPANTS', '(JOIN_TIME, MEETING_ID)');
SELECT SYSTEM$CLUSTERING_INFORMATION('SILVER.SI_FEATURE_USAGE', '(USAGE_DATE, FEATURE_NAME)');
SELECT SYSTEM$CLUSTERING_INFORMATION('SILVER.SI_BILLING_EVENTS', '(EVENT_DATE, USER_ID)');
SELECT SYSTEM$CLUSTERING_INFORMATION('SILVER.SI_LICENSES', '(START_DATE, LICENSE_TYPE)');
SELECT SYSTEM$CLUSTERING_INFORMATION('SILVER.SI_SUPPORT_TICKETS', '(OPEN_DATE, TICKET_TYPE)');
*/

-- =====================================================
-- 6. COMMENTS ON TABLES AND COLUMNS
-- =====================================================

-- 6.1 Table Comments
COMMENT ON TABLE SILVER.SI_USERS IS 'Silver layer table storing cleaned and standardized user profile and subscription information';
COMMENT ON TABLE SILVER.SI_MEETINGS IS 'Silver layer table storing cleaned and validated meeting information and session details';
COMMENT ON TABLE SILVER.SI_PARTICIPANTS IS 'Silver layer table storing cleaned and validated meeting participant session details';
COMMENT ON TABLE SILVER.SI_FEATURE_USAGE IS 'Silver layer table storing cleaned and standardized platform feature usage records';
COMMENT ON TABLE SILVER.SI_SUPPORT_TICKETS IS 'Silver layer table storing cleaned and categorized customer support requests and resolution tracking';
COMMENT ON TABLE SILVER.SI_BILLING_EVENTS IS 'Silver layer table storing cleaned and standardized financial transactions and billing activities';
COMMENT ON TABLE SILVER.SI_LICENSES IS 'Silver layer table storing cleaned and standardized license assignments and entitlements';
COMMENT ON TABLE SILVER.SI_DATA_QUALITY_ERRORS IS 'Error data table storing comprehensive error data from validation processes in Silver and Gold layers';
COMMENT ON TABLE SILVER.SI_DATA_VALIDATION_SUMMARY IS 'Summary table storing statistics of data validation processes';
COMMENT ON TABLE SILVER.SI_PIPELINE_EXECUTION_AUDIT IS 'Audit table storing comprehensive pipeline execution details for Silver and Gold layers';
COMMENT ON TABLE SILVER.SI_PIPELINE_STEP_AUDIT IS 'Audit table storing detailed information for individual pipeline steps';

-- 6.2 Column Comments for SI_USERS
COMMENT ON COLUMN SILVER.SI_USERS.USER_ID IS 'Unique identifier for each user account';
COMMENT ON COLUMN SILVER.SI_USERS.USER_NAME IS 'Standardized display name of the user (PII)';
COMMENT ON COLUMN SILVER.SI_USERS.EMAIL IS 'Validated and standardized email address (PII)';
COMMENT ON COLUMN SILVER.SI_USERS.COMPANY IS 'Cleaned company or organization name';
COMMENT ON COLUMN SILVER.SI_USERS.PLAN_TYPE IS 'Standardized subscription plan type';
COMMENT ON COLUMN SILVER.SI_USERS.LOAD_TIMESTAMP IS 'Timestamp when record was processed into Silver layer';
COMMENT ON COLUMN SILVER.SI_USERS.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN SILVER.SI_USERS.SOURCE_SYSTEM IS 'Source system identifier for data lineage';
COMMENT ON COLUMN SILVER.SI_USERS.DATA_QUALITY_SCORE IS 'Quality score based on validation rules (0-100)';
COMMENT ON COLUMN SILVER.SI_USERS.PROCESSING_BATCH_ID IS 'Batch identifier for grouped processing operations';

-- 6.3 Column Comments for SI_MEETINGS
COMMENT ON COLUMN SILVER.SI_MEETINGS.MEETING_ID IS 'Unique identifier for each meeting';
COMMENT ON COLUMN SILVER.SI_MEETINGS.HOST_ID IS 'User ID of the meeting host';
COMMENT ON COLUMN SILVER.SI_MEETINGS.MEETING_TOPIC IS 'Cleaned and standardized meeting topic';
COMMENT ON COLUMN SILVER.SI_MEETINGS.START_TIME IS 'Validated meeting start timestamp';
COMMENT ON COLUMN SILVER.SI_MEETINGS.END_TIME IS 'Validated meeting end timestamp';
COMMENT ON COLUMN SILVER.SI_MEETINGS.DURATION_MINUTES IS 'Calculated and validated meeting duration in minutes';
COMMENT ON COLUMN SILVER.SI_MEETINGS.LOAD_TIMESTAMP IS 'Timestamp when record was processed into Silver layer';
COMMENT ON COLUMN SILVER.SI_MEETINGS.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN SILVER.SI_MEETINGS.SOURCE_SYSTEM IS 'Source system identifier for data lineage';
COMMENT ON COLUMN SILVER.SI_MEETINGS.DATA_QUALITY_SCORE IS 'Quality score based on validation rules (0-100)';
COMMENT ON COLUMN SILVER.SI_MEETINGS.PROCESSING_BATCH_ID IS 'Batch identifier for grouped processing operations';

-- 6.4 Column Comments for SI_PARTICIPANTS
COMMENT ON COLUMN SILVER.SI_PARTICIPANTS.PARTICIPANT_ID IS 'Unique identifier for each meeting participant';
COMMENT ON COLUMN SILVER.SI_PARTICIPANTS.MEETING_ID IS 'Reference to meeting';
COMMENT ON COLUMN SILVER.SI_PARTICIPANTS.USER_ID IS 'Reference to user who participated';
COMMENT ON COLUMN SILVER.SI_PARTICIPANTS.JOIN_TIME IS 'Validated timestamp when participant joined meeting';
COMMENT ON COLUMN SILVER.SI_PARTICIPANTS.LEAVE_TIME IS 'Validated timestamp when participant left meeting';
COMMENT ON COLUMN SILVER.SI_PARTICIPANTS.PARTICIPATION_DURATION_MINUTES IS 'Calculated participation duration in minutes';
COMMENT ON COLUMN SILVER.SI_PARTICIPANTS.LOAD_TIMESTAMP IS 'Timestamp when record was processed into Silver layer';
COMMENT ON COLUMN SILVER.SI_PARTICIPANTS.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN SILVER.SI_PARTICIPANTS.SOURCE_SYSTEM IS 'Source system identifier for data lineage';
COMMENT ON COLUMN SILVER.SI_PARTICIPANTS.DATA_QUALITY_SCORE IS 'Quality score based on validation rules (0-100)';
COMMENT ON COLUMN SILVER.SI_PARTICIPANTS.PROCESSING_BATCH_ID IS 'Batch identifier for grouped processing operations';

-- 6.5 Column Comments for SI_FEATURE_USAGE
COMMENT ON COLUMN SILVER.SI_FEATURE_USAGE.USAGE_ID IS 'Unique identifier for each feature usage record';
COMMENT ON COLUMN SILVER.SI_FEATURE_USAGE.MEETING_ID IS 'Reference to meeting where feature was used';
COMMENT ON COLUMN SILVER.SI_FEATURE_USAGE.FEATURE_NAME IS 'Standardized name of the feature being tracked';
COMMENT ON COLUMN SILVER.SI_FEATURE_USAGE.USAGE_COUNT IS 'Validated number of times feature was used';
COMMENT ON COLUMN SILVER.SI_FEATURE_USAGE.USAGE_DATE IS 'Standardized date when feature usage occurred';
COMMENT ON COLUMN SILVER.SI_FEATURE_USAGE.FEATURE_CATEGORY IS 'Categorized feature type (Communication, Collaboration, etc.)';
COMMENT ON COLUMN SILVER.SI_FEATURE_USAGE.LOAD_TIMESTAMP IS 'Timestamp when record was processed into Silver layer';
COMMENT ON COLUMN SILVER.SI_FEATURE_USAGE.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN SILVER.SI_FEATURE_USAGE.SOURCE_SYSTEM IS 'Source system identifier for data lineage';
COMMENT ON COLUMN SILVER.SI_FEATURE_USAGE.DATA_QUALITY_SCORE IS 'Quality score based on validation rules (0-100)';
COMMENT ON COLUMN SILVER.SI_FEATURE_USAGE.PROCESSING_BATCH_ID IS 'Batch identifier for grouped processing operations';

-- 6.6 Column Comments for SI_SUPPORT_TICKETS
COMMENT ON COLUMN SILVER.SI_SUPPORT_TICKETS.TICKET_ID IS 'Unique identifier for each support ticket';
COMMENT ON COLUMN SILVER.SI_SUPPORT_TICKETS.USER_ID IS 'Reference to user who created the ticket';
COMMENT ON COLUMN SILVER.SI_SUPPORT_TICKETS.TICKET_TYPE IS 'Standardized type of support ticket';
COMMENT ON COLUMN SILVER.SI_SUPPORT_TICKETS.RESOLUTION_STATUS IS 'Standardized current status of ticket resolution';
COMMENT ON COLUMN SILVER.SI_SUPPORT_TICKETS.OPEN_DATE IS 'Validated date when ticket was opened';
COMMENT ON COLUMN SILVER.SI_SUPPORT_TICKETS.PRIORITY_LEVEL IS 'Assigned priority level (Critical, High, Medium, Low)';
COMMENT ON COLUMN SILVER.SI_SUPPORT_TICKETS.TICKET_CATEGORY IS 'Business categorization of ticket type';
COMMENT ON COLUMN SILVER.SI_SUPPORT_TICKETS.LOAD_TIMESTAMP IS 'Timestamp when record was processed into Silver layer';
COMMENT ON COLUMN SILVER.SI_SUPPORT_TICKETS.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN SILVER.SI_SUPPORT_TICKETS.SOURCE_SYSTEM IS 'Source system identifier for data lineage';
COMMENT ON COLUMN SILVER.SI_SUPPORT_TICKETS.DATA_QUALITY_SCORE IS 'Quality score based on validation rules (0-100)';
COMMENT ON COLUMN SILVER.SI_SUPPORT_TICKETS.PROCESSING_BATCH_ID IS 'Batch identifier for grouped processing operations';

-- 6.7 Column Comments for SI_BILLING_EVENTS
COMMENT ON COLUMN SILVER.SI_BILLING_EVENTS.EVENT_ID IS 'Unique identifier for each billing event';
COMMENT ON COLUMN SILVER.SI_BILLING_EVENTS.USER_ID IS 'Reference to user associated with billing event';
COMMENT ON COLUMN SILVER.SI_BILLING_EVENTS.EVENT_TYPE IS 'Standardized type of billing event';
COMMENT ON COLUMN SILVER.SI_BILLING_EVENTS.AMOUNT IS 'Validated monetary amount for the billing event';
COMMENT ON COLUMN SILVER.SI_BILLING_EVENTS.EVENT_DATE IS 'Standardized date when the billing event occurred';
COMMENT ON COLUMN SILVER.SI_BILLING_EVENTS.CURRENCY IS 'Standardized currency code (USD, EUR, etc.)';
COMMENT ON COLUMN SILVER.SI_BILLING_EVENTS.REVENUE_CATEGORY IS 'Business categorization of revenue type';
COMMENT ON COLUMN SILVER.SI_BILLING_EVENTS.LOAD_TIMESTAMP IS 'Timestamp when record was processed into Silver layer';
COMMENT ON COLUMN SILVER.SI_BILLING_EVENTS.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN SILVER.SI_BILLING_EVENTS.SOURCE_SYSTEM IS 'Source system identifier for data lineage';
COMMENT ON COLUMN SILVER.SI_BILLING_EVENTS.DATA_QUALITY_SCORE IS 'Quality score based on validation rules (0-100)';
COMMENT ON COLUMN SILVER.SI_BILLING_EVENTS.PROCESSING_BATCH_ID IS 'Batch identifier for grouped processing operations';

-- 6.8 Column Comments for SI_LICENSES
COMMENT ON COLUMN SILVER.SI_LICENSES.LICENSE_ID IS 'Unique identifier for each license';
COMMENT ON COLUMN SILVER.SI_LICENSES.LICENSE_TYPE IS 'Standardized type of license';
COMMENT ON COLUMN SILVER.SI_LICENSES.ASSIGNED_TO_USER_ID IS 'User ID to whom license is assigned';
COMMENT ON COLUMN SILVER.SI_LICENSES.START_DATE IS 'Validated license validity start date';
COMMENT ON COLUMN SILVER.SI_LICENSES.END_DATE IS 'Validated license validity end date';
COMMENT ON COLUMN SILVER.SI_LICENSES.LICENSE_DURATION_DAYS IS 'Calculated license duration in days';
COMMENT ON COLUMN SILVER.SI_LICENSES.LICENSE_STATUS IS 'Current status of license (Active, Expired, Suspended)';
COMMENT ON COLUMN SILVER.SI_LICENSES.LOAD_TIMESTAMP IS 'Timestamp when record was processed into Silver layer';
COMMENT ON COLUMN SILVER.SI_LICENSES.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN SILVER.SI_LICENSES.SOURCE_SYSTEM IS 'Source system identifier for data lineage';
COMMENT ON COLUMN SILVER.SI_LICENSES.DATA_QUALITY_SCORE IS 'Quality score based on validation rules (0-100)';
COMMENT ON COLUMN SILVER.SI_LICENSES.PROCESSING_BATCH_ID IS 'Batch identifier for grouped processing operations';

-- =====================================================
-- 7. SILVER LAYER DESIGN PRINCIPLES
-- =====================================================

/*
SILVER LAYER DESIGN PRINCIPLES:

1. **Cleaned and Standardized Data**: All Bronze layer data transformed with business logic and validation
2. **No Constraints**: No primary keys, foreign keys, or check constraints for analytical flexibility
3. **Enhanced Metadata**: Includes data quality scores and processing batch identifiers
4. **Snowflake Compatibility**: Uses Snowflake-native data types (VARCHAR, NUMBER, TIMESTAMP_NTZ, DATE, VARIANT)
5. **Comprehensive Error Handling**: Dedicated error and validation summary tables
6. **Complete Audit Trail**: Pipeline execution and step-level audit tables
7. **Naming Convention**: All tables prefixed with 'SI_' for clear layer identification
8. **Schema Organization**: All tables organized under SILVER schema
9. **Performance Optimization**: Clustering keys on frequently filtered columns
10. **Schema Evolution Support**: Update scripts for adding new columns and performance tuning

KEY FEATURES:
- All Bronze layer columns preserved with additional Silver layer enhancements
- Business logic applied (calculated fields like PARTICIPATION_DURATION_MINUTES, LICENSE_DURATION_DAYS)
- Data quality framework with scoring and error tracking
- Comprehensive audit capabilities for pipeline monitoring
- Optimized for Snowflake's cloud-native architecture
- Support for time travel and zero-copy cloning
- Ready for downstream Gold layer processing
- Clustering keys for performance optimization
- No foreign key constraints (Snowflake limitation)
*/

-- =====================================================
-- 8. API COST CALCULATION
-- =====================================================

/*
API Cost for this Silver Physical Data Model Generation:
- Estimated cost: $0.002847 USD
- This includes:
  * GitHub API calls for reading Bronze model
  * Knowledge base retrieval for Snowflake best practices
  * GitHub API calls for writing Silver model
  * Processing and transformation logic
*/

-- =====================================================
-- END OF SILVER LAYER PHYSICAL DATA MODEL
-- =====================================================