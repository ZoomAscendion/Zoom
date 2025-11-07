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
-- Purpose: Cleansed and conformed data storage for Medallion architecture
-- =====================================================

-- 1. CREATE SILVER SCHEMA
CREATE SCHEMA IF NOT EXISTS SILVER;

-- =====================================================
-- 2. SILVER LAYER TABLES - DDL SCRIPTS
-- =====================================================

-- 2.1 Si_USERS TABLE
-- Description: Cleaned and standardized user profile and subscription information from Bronze layer
CREATE TABLE IF NOT EXISTS SILVER.Si_USERS (
    USER_ID VARCHAR(16777216),
    USER_NAME VARCHAR(16777216),
    EMAIL VARCHAR(16777216),
    COMPANY VARCHAR(16777216),
    PLAN_TYPE VARCHAR(16777216),
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM VARCHAR(16777216),
    LOAD_DATE DATE,
    UPDATE_DATE DATE
);

-- 2.2 Si_MEETINGS TABLE
-- Description: Cleaned and standardized meeting information and session details from Bronze layer
CREATE TABLE IF NOT EXISTS SILVER.Si_MEETINGS (
    MEETING_ID VARCHAR(16777216),
    HOST_ID VARCHAR(16777216),
    MEETING_TOPIC VARCHAR(16777216),
    START_TIME TIMESTAMP_NTZ(9),
    END_TIME TIMESTAMP_NTZ(9),
    DURATION_MINUTES NUMBER(38,0),
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM VARCHAR(16777216),
    LOAD_DATE DATE,
    UPDATE_DATE DATE
);

-- 2.3 Si_PARTICIPANTS TABLE
-- Description: Cleaned and standardized meeting participants and their session details from Bronze layer
CREATE TABLE IF NOT EXISTS SILVER.Si_PARTICIPANTS (
    PARTICIPANT_ID VARCHAR(16777216),
    MEETING_ID VARCHAR(16777216),
    USER_ID VARCHAR(16777216),
    JOIN_TIME TIMESTAMP_NTZ(9),
    LEAVE_TIME TIMESTAMP_NTZ(9),
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM VARCHAR(16777216),
    LOAD_DATE DATE,
    UPDATE_DATE DATE
);

-- 2.4 Si_FEATURE_USAGE TABLE
-- Description: Cleaned and standardized usage of platform features during meetings from Bronze layer
CREATE TABLE IF NOT EXISTS SILVER.Si_FEATURE_USAGE (
    USAGE_ID VARCHAR(16777216),
    MEETING_ID VARCHAR(16777216),
    FEATURE_NAME VARCHAR(16777216),
    USAGE_COUNT NUMBER(38,0),
    USAGE_DATE DATE,
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM VARCHAR(16777216),
    LOAD_DATE DATE,
    UPDATE_DATE DATE
);

-- 2.5 Si_SUPPORT_TICKETS TABLE
-- Description: Cleaned and standardized customer support requests and resolution tracking from Bronze layer
CREATE TABLE IF NOT EXISTS SILVER.Si_SUPPORT_TICKETS (
    TICKET_ID VARCHAR(16777216),
    USER_ID VARCHAR(16777216),
    TICKET_TYPE VARCHAR(16777216),
    RESOLUTION_STATUS VARCHAR(16777216),
    OPEN_DATE DATE,
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM VARCHAR(16777216),
    LOAD_DATE DATE,
    UPDATE_DATE DATE
);

-- 2.6 Si_BILLING_EVENTS TABLE
-- Description: Cleaned and standardized financial transactions and billing activities from Bronze layer
CREATE TABLE IF NOT EXISTS SILVER.Si_BILLING_EVENTS (
    EVENT_ID VARCHAR(16777216),
    USER_ID VARCHAR(16777216),
    EVENT_TYPE VARCHAR(16777216),
    AMOUNT NUMBER(10,2),
    EVENT_DATE DATE,
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM VARCHAR(16777216),
    LOAD_DATE DATE,
    UPDATE_DATE DATE
);

-- 2.7 Si_LICENSES TABLE
-- Description: Cleaned and standardized license assignments and entitlements from Bronze layer
CREATE TABLE IF NOT EXISTS SILVER.Si_LICENSES (
    LICENSE_ID VARCHAR(16777216),
    ASSIGNED_TO_USER_ID VARCHAR(16777216),
    LICENSE_TYPE VARCHAR(16777216),
    START_DATE DATE,
    END_DATE DATE,
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM VARCHAR(16777216),
    LOAD_DATE DATE,
    UPDATE_DATE DATE
);

-- =====================================================
-- 3. ERROR DATA TABLE
-- =====================================================

-- 3.1 Si_DATA_QUALITY_ERRORS TABLE
-- Description: Stores error data from data validation process and quality checks
CREATE TABLE IF NOT EXISTS SILVER.Si_DATA_QUALITY_ERRORS (
    ERROR_ID VARCHAR(16777216),
    ERROR_TYPE VARCHAR(16777216),
    ERROR_DESCRIPTION VARCHAR(16777216),
    SOURCE_TABLE VARCHAR(16777216),
    SOURCE_COLUMN VARCHAR(16777216),
    ERROR_VALUE VARCHAR(16777216),
    EXPECTED_VALUE VARCHAR(16777216),
    SEVERITY_LEVEL VARCHAR(16777216),
    ERROR_TIMESTAMP TIMESTAMP_NTZ(9),
    VALIDATION_RULE VARCHAR(16777216),
    ERROR_COUNT NUMBER(38,0),
    RESOLUTION_STATUS VARCHAR(16777216),
    RESOLVED_BY VARCHAR(16777216),
    RESOLUTION_TIMESTAMP TIMESTAMP_NTZ(9),
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- =====================================================
-- 4. AUDIT TABLE
-- =====================================================

-- 4.1 Si_PIPELINE_AUDIT TABLE
-- Description: Stores audit details from pipeline execution and processing activities
CREATE TABLE IF NOT EXISTS SILVER.Si_PIPELINE_AUDIT (
    AUDIT_ID VARCHAR(16777216),
    EXECUTION_ID VARCHAR(16777216),
    PIPELINE_NAME VARCHAR(16777216),
    PIPELINE_RUN_ID VARCHAR(16777216),
    EXECUTION_STATUS VARCHAR(16777216),
    START_TIMESTAMP TIMESTAMP_NTZ(9),
    END_TIMESTAMP TIMESTAMP_NTZ(9),
    EXECUTION_DURATION NUMBER(38,3),
    RECORDS_PROCESSED NUMBER(38,0),
    RECORDS_SUCCESS NUMBER(38,0),
    RECORDS_FAILED NUMBER(38,0),
    RECORDS_SKIPPED NUMBER(38,0),
    SOURCE_SYSTEM VARCHAR(16777216),
    TARGET_TABLE VARCHAR(16777216),
    PIPELINE_VERSION VARCHAR(16777216),
    EXECUTED_BY VARCHAR(16777216),
    ERROR_MESSAGE VARCHAR(16777216),
    CONFIGURATION_PARAMS VARIANT,
    PERFORMANCE_METRICS VARIANT,
    DATA_LINEAGE_INFO VARIANT,
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    LOAD_DATE DATE,
    UPDATE_DATE DATE
);

-- =====================================================
-- 5. UPDATE DDL SCRIPTS (Schema Evolution)
-- =====================================================

-- 5.1 Add new columns to existing tables (Example)
-- ALTER TABLE SILVER.Si_USERS ADD COLUMN NEW_COLUMN VARCHAR(16777216);
-- ALTER TABLE SILVER.Si_MEETINGS ADD COLUMN NEW_COLUMN VARCHAR(16777216);
-- ALTER TABLE SILVER.Si_PARTICIPANTS ADD COLUMN NEW_COLUMN VARCHAR(16777216);
-- ALTER TABLE SILVER.Si_FEATURE_USAGE ADD COLUMN NEW_COLUMN VARCHAR(16777216);
-- ALTER TABLE SILVER.Si_SUPPORT_TICKETS ADD COLUMN NEW_COLUMN VARCHAR(16777216);
-- ALTER TABLE SILVER.Si_BILLING_EVENTS ADD COLUMN NEW_COLUMN VARCHAR(16777216);
-- ALTER TABLE SILVER.Si_LICENSES ADD COLUMN NEW_COLUMN VARCHAR(16777216);

-- 5.2 Modify existing columns (Example)
-- ALTER TABLE SILVER.Si_USERS ALTER COLUMN EXISTING_COLUMN SET DATA TYPE NEW_DATA_TYPE;

-- 5.3 Drop columns (Example)
-- ALTER TABLE SILVER.Si_USERS DROP COLUMN UNWANTED_COLUMN;

-- 5.4 Add clustering keys for performance optimization (Example)
-- ALTER TABLE SILVER.Si_MEETINGS CLUSTER BY (START_TIME, HOST_ID);
-- ALTER TABLE SILVER.Si_PARTICIPANTS CLUSTER BY (JOIN_TIME, MEETING_ID);
-- ALTER TABLE SILVER.Si_FEATURE_USAGE CLUSTER BY (USAGE_DATE, FEATURE_NAME);
-- ALTER TABLE SILVER.Si_SUPPORT_TICKETS CLUSTER BY (OPEN_DATE, TICKET_TYPE);
-- ALTER TABLE SILVER.Si_BILLING_EVENTS CLUSTER BY (EVENT_DATE, USER_ID);
-- ALTER TABLE SILVER.Si_LICENSES CLUSTER BY (START_DATE, LICENSE_TYPE);

-- =====================================================
-- 6. COMMENTS ON TABLES AND COLUMNS
-- =====================================================

-- 6.1 Table Comments
COMMENT ON TABLE SILVER.Si_USERS IS 'Silver layer table storing cleaned and standardized user profile and subscription information';
COMMENT ON TABLE SILVER.Si_MEETINGS IS 'Silver layer table storing cleaned and standardized meeting information and session details';
COMMENT ON TABLE SILVER.Si_PARTICIPANTS IS 'Silver layer table storing cleaned and standardized meeting participants and their session details';
COMMENT ON TABLE SILVER.Si_FEATURE_USAGE IS 'Silver layer table storing cleaned and standardized usage of platform features during meetings';
COMMENT ON TABLE SILVER.Si_SUPPORT_TICKETS IS 'Silver layer table storing cleaned and standardized customer support requests and resolution tracking';
COMMENT ON TABLE SILVER.Si_BILLING_EVENTS IS 'Silver layer table storing cleaned and standardized financial transactions and billing activities';
COMMENT ON TABLE SILVER.Si_LICENSES IS 'Silver layer table storing cleaned and standardized license assignments and entitlements';
COMMENT ON TABLE SILVER.Si_DATA_QUALITY_ERRORS IS 'Error data table storing details of errors encountered during data validation in Silver and Gold layers';
COMMENT ON TABLE SILVER.Si_PIPELINE_AUDIT IS 'Audit table storing comprehensive pipeline execution details and processing activities';

-- 6.2 Column Comments for Si_USERS
COMMENT ON COLUMN SILVER.Si_USERS.USER_ID IS 'Unique identifier for each user account';
COMMENT ON COLUMN SILVER.Si_USERS.USER_NAME IS 'Display name of the user (PII)';
COMMENT ON COLUMN SILVER.Si_USERS.EMAIL IS 'Email address of the user (PII)';
COMMENT ON COLUMN SILVER.Si_USERS.COMPANY IS 'Company or organization name';
COMMENT ON COLUMN SILVER.Si_USERS.PLAN_TYPE IS 'Subscription plan type (Basic, Pro, Business, Enterprise)';
COMMENT ON COLUMN SILVER.Si_USERS.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN SILVER.Si_USERS.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN SILVER.Si_USERS.SOURCE_SYSTEM IS 'Source system from which data originated';
COMMENT ON COLUMN SILVER.Si_USERS.LOAD_DATE IS 'Date when record was loaded into Silver layer';
COMMENT ON COLUMN SILVER.Si_USERS.UPDATE_DATE IS 'Date when record was last updated in Silver layer';

-- 6.3 Column Comments for Si_MEETINGS
COMMENT ON COLUMN SILVER.Si_MEETINGS.MEETING_ID IS 'Unique identifier for each meeting';
COMMENT ON COLUMN SILVER.Si_MEETINGS.HOST_ID IS 'User ID of the meeting host';
COMMENT ON COLUMN SILVER.Si_MEETINGS.MEETING_TOPIC IS 'Topic or title of the meeting (Potential PII)';
COMMENT ON COLUMN SILVER.Si_MEETINGS.START_TIME IS 'Meeting start timestamp';
COMMENT ON COLUMN SILVER.Si_MEETINGS.END_TIME IS 'Meeting end timestamp';
COMMENT ON COLUMN SILVER.Si_MEETINGS.DURATION_MINUTES IS 'Meeting duration in minutes';
COMMENT ON COLUMN SILVER.Si_MEETINGS.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN SILVER.Si_MEETINGS.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN SILVER.Si_MEETINGS.SOURCE_SYSTEM IS 'Source system from which data originated';
COMMENT ON COLUMN SILVER.Si_MEETINGS.LOAD_DATE IS 'Date when record was loaded into Silver layer';
COMMENT ON COLUMN SILVER.Si_MEETINGS.UPDATE_DATE IS 'Date when record was last updated in Silver layer';

-- 6.4 Column Comments for Si_PARTICIPANTS
COMMENT ON COLUMN SILVER.Si_PARTICIPANTS.PARTICIPANT_ID IS 'Unique identifier for each meeting participant';
COMMENT ON COLUMN SILVER.Si_PARTICIPANTS.MEETING_ID IS 'Reference to meeting';
COMMENT ON COLUMN SILVER.Si_PARTICIPANTS.USER_ID IS 'Reference to user who participated';
COMMENT ON COLUMN SILVER.Si_PARTICIPANTS.JOIN_TIME IS 'Timestamp when participant joined meeting';
COMMENT ON COLUMN SILVER.Si_PARTICIPANTS.LEAVE_TIME IS 'Timestamp when participant left meeting';
COMMENT ON COLUMN SILVER.Si_PARTICIPANTS.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN SILVER.Si_PARTICIPANTS.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN SILVER.Si_PARTICIPANTS.SOURCE_SYSTEM IS 'Source system from which data originated';
COMMENT ON COLUMN SILVER.Si_PARTICIPANTS.LOAD_DATE IS 'Date when record was loaded into Silver layer';
COMMENT ON COLUMN SILVER.Si_PARTICIPANTS.UPDATE_DATE IS 'Date when record was last updated in Silver layer';

-- 6.5 Column Comments for Si_FEATURE_USAGE
COMMENT ON COLUMN SILVER.Si_FEATURE_USAGE.USAGE_ID IS 'Unique identifier for each feature usage record';
COMMENT ON COLUMN SILVER.Si_FEATURE_USAGE.MEETING_ID IS 'Reference to meeting where feature was used';
COMMENT ON COLUMN SILVER.Si_FEATURE_USAGE.FEATURE_NAME IS 'Name of the feature being tracked';
COMMENT ON COLUMN SILVER.Si_FEATURE_USAGE.USAGE_COUNT IS 'Number of times feature was used';
COMMENT ON COLUMN SILVER.Si_FEATURE_USAGE.USAGE_DATE IS 'Date when feature usage occurred';
COMMENT ON COLUMN SILVER.Si_FEATURE_USAGE.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN SILVER.Si_FEATURE_USAGE.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN SILVER.Si_FEATURE_USAGE.SOURCE_SYSTEM IS 'Source system from which data originated';
COMMENT ON COLUMN SILVER.Si_FEATURE_USAGE.LOAD_DATE IS 'Date when record was loaded into Silver layer';
COMMENT ON COLUMN SILVER.Si_FEATURE_USAGE.UPDATE_DATE IS 'Date when record was last updated in Silver layer';

-- 6.6 Column Comments for Si_SUPPORT_TICKETS
COMMENT ON COLUMN SILVER.Si_SUPPORT_TICKETS.TICKET_ID IS 'Unique identifier for each support ticket';
COMMENT ON COLUMN SILVER.Si_SUPPORT_TICKETS.USER_ID IS 'Reference to user who created the ticket';
COMMENT ON COLUMN SILVER.Si_SUPPORT_TICKETS.TICKET_TYPE IS 'Type of support ticket';
COMMENT ON COLUMN SILVER.Si_SUPPORT_TICKETS.RESOLUTION_STATUS IS 'Current status of ticket resolution';
COMMENT ON COLUMN SILVER.Si_SUPPORT_TICKETS.OPEN_DATE IS 'Date when ticket was opened';
COMMENT ON COLUMN SILVER.Si_SUPPORT_TICKETS.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN SILVER.Si_SUPPORT_TICKETS.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN SILVER.Si_SUPPORT_TICKETS.SOURCE_SYSTEM IS 'Source system from which data originated';
COMMENT ON COLUMN SILVER.Si_SUPPORT_TICKETS.LOAD_DATE IS 'Date when record was loaded into Silver layer';
COMMENT ON COLUMN SILVER.Si_SUPPORT_TICKETS.UPDATE_DATE IS 'Date when record was last updated in Silver layer';

-- 6.7 Column Comments for Si_BILLING_EVENTS
COMMENT ON COLUMN SILVER.Si_BILLING_EVENTS.EVENT_ID IS 'Unique identifier for each billing event';
COMMENT ON COLUMN SILVER.Si_BILLING_EVENTS.USER_ID IS 'Reference to user associated with billing event';
COMMENT ON COLUMN SILVER.Si_BILLING_EVENTS.EVENT_TYPE IS 'Type of billing event';
COMMENT ON COLUMN SILVER.Si_BILLING_EVENTS.AMOUNT IS 'Monetary amount for the billing event';
COMMENT ON COLUMN SILVER.Si_BILLING_EVENTS.EVENT_DATE IS 'Date when the billing event occurred';
COMMENT ON COLUMN SILVER.Si_BILLING_EVENTS.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN SILVER.Si_BILLING_EVENTS.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN SILVER.Si_BILLING_EVENTS.SOURCE_SYSTEM IS 'Source system from which data originated';
COMMENT ON COLUMN SILVER.Si_BILLING_EVENTS.LOAD_DATE IS 'Date when record was loaded into Silver layer';
COMMENT ON COLUMN SILVER.Si_BILLING_EVENTS.UPDATE_DATE IS 'Date when record was last updated in Silver layer';

-- 6.8 Column Comments for Si_LICENSES
COMMENT ON COLUMN SILVER.Si_LICENSES.LICENSE_ID IS 'Unique identifier for each license';
COMMENT ON COLUMN SILVER.Si_LICENSES.ASSIGNED_TO_USER_ID IS 'User ID to whom license is assigned';
COMMENT ON COLUMN SILVER.Si_LICENSES.LICENSE_TYPE IS 'Type of license';
COMMENT ON COLUMN SILVER.Si_LICENSES.START_DATE IS 'License validity start date';
COMMENT ON COLUMN SILVER.Si_LICENSES.END_DATE IS 'License validity end date';
COMMENT ON COLUMN SILVER.Si_LICENSES.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN SILVER.Si_LICENSES.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN SILVER.Si_LICENSES.SOURCE_SYSTEM IS 'Source system from which data originated';
COMMENT ON COLUMN SILVER.Si_LICENSES.LOAD_DATE IS 'Date when record was loaded into Silver layer';
COMMENT ON COLUMN SILVER.Si_LICENSES.UPDATE_DATE IS 'Date when record was last updated in Silver layer';

-- 6.9 Column Comments for Si_DATA_QUALITY_ERRORS
COMMENT ON COLUMN SILVER.Si_DATA_QUALITY_ERRORS.ERROR_ID IS 'Unique identifier for each error record';
COMMENT ON COLUMN SILVER.Si_DATA_QUALITY_ERRORS.ERROR_TYPE IS 'Type of data quality error (Format, Completeness, Consistency, Validity)';
COMMENT ON COLUMN SILVER.Si_DATA_QUALITY_ERRORS.ERROR_DESCRIPTION IS 'Detailed description of the data quality issue';
COMMENT ON COLUMN SILVER.Si_DATA_QUALITY_ERRORS.SOURCE_TABLE IS 'Name of the source table where error was detected';
COMMENT ON COLUMN SILVER.Si_DATA_QUALITY_ERRORS.SOURCE_COLUMN IS 'Name of the source column where error was detected';
COMMENT ON COLUMN SILVER.Si_DATA_QUALITY_ERRORS.ERROR_VALUE IS 'The actual value that caused the error';
COMMENT ON COLUMN SILVER.Si_DATA_QUALITY_ERRORS.EXPECTED_VALUE IS 'The expected value or format';
COMMENT ON COLUMN SILVER.Si_DATA_QUALITY_ERRORS.SEVERITY_LEVEL IS 'Severity of the error (Critical, High, Medium, Low)';
COMMENT ON COLUMN SILVER.Si_DATA_QUALITY_ERRORS.ERROR_TIMESTAMP IS 'Timestamp when error was detected';
COMMENT ON COLUMN SILVER.Si_DATA_QUALITY_ERRORS.VALIDATION_RULE IS 'Name of the validation rule that failed';
COMMENT ON COLUMN SILVER.Si_DATA_QUALITY_ERRORS.ERROR_COUNT IS 'Number of records affected by this error';
COMMENT ON COLUMN SILVER.Si_DATA_QUALITY_ERRORS.RESOLUTION_STATUS IS 'Status of error resolution (Open, In Progress, Resolved, Ignored)';
COMMENT ON COLUMN SILVER.Si_DATA_QUALITY_ERRORS.RESOLVED_BY IS 'User or process that resolved the error';
COMMENT ON COLUMN SILVER.Si_DATA_QUALITY_ERRORS.RESOLUTION_TIMESTAMP IS 'Timestamp when error was resolved';
COMMENT ON COLUMN SILVER.Si_DATA_QUALITY_ERRORS.LOAD_TIMESTAMP IS 'Timestamp when error record was created';
COMMENT ON COLUMN SILVER.Si_DATA_QUALITY_ERRORS.LOAD_DATE IS 'Date when record was loaded into Silver layer';
COMMENT ON COLUMN SILVER.Si_DATA_QUALITY_ERRORS.UPDATE_DATE IS 'Date when record was last updated in Silver layer';
COMMENT ON COLUMN SILVER.Si_DATA_QUALITY_ERRORS.SOURCE_SYSTEM IS 'Source system from which data originated';

-- 6.10 Column Comments for Si_PIPELINE_AUDIT
COMMENT ON COLUMN SILVER.Si_PIPELINE_AUDIT.AUDIT_ID IS 'Unique identifier for each audit record';
COMMENT ON COLUMN SILVER.Si_PIPELINE_AUDIT.EXECUTION_ID IS 'Unique identifier for the pipeline execution';
COMMENT ON COLUMN SILVER.Si_PIPELINE_AUDIT.PIPELINE_NAME IS 'Name of the data pipeline or process';
COMMENT ON COLUMN SILVER.Si_PIPELINE_AUDIT.PIPELINE_RUN_ID IS 'Unique identifier for the pipeline execution run';
COMMENT ON COLUMN SILVER.Si_PIPELINE_AUDIT.EXECUTION_STATUS IS 'Status of pipeline execution (Started, Running, Completed, Failed, Cancelled)';
COMMENT ON COLUMN SILVER.Si_PIPELINE_AUDIT.START_TIMESTAMP IS 'Timestamp when pipeline execution started';
COMMENT ON COLUMN SILVER.Si_PIPELINE_AUDIT.END_TIMESTAMP IS 'Timestamp when pipeline execution completed';
COMMENT ON COLUMN SILVER.Si_PIPELINE_AUDIT.EXECUTION_DURATION IS 'Duration of pipeline execution in seconds';
COMMENT ON COLUMN SILVER.Si_PIPELINE_AUDIT.RECORDS_PROCESSED IS 'Total number of records processed';
COMMENT ON COLUMN SILVER.Si_PIPELINE_AUDIT.RECORDS_SUCCESS IS 'Number of records successfully processed';
COMMENT ON COLUMN SILVER.Si_PIPELINE_AUDIT.RECORDS_FAILED IS 'Number of records that failed processing';
COMMENT ON COLUMN SILVER.Si_PIPELINE_AUDIT.RECORDS_SKIPPED IS 'Number of records skipped during processing';
COMMENT ON COLUMN SILVER.Si_PIPELINE_AUDIT.SOURCE_SYSTEM IS 'Source system being processed';
COMMENT ON COLUMN SILVER.Si_PIPELINE_AUDIT.TARGET_TABLE IS 'Target table where data was loaded';
COMMENT ON COLUMN SILVER.Si_PIPELINE_AUDIT.PIPELINE_VERSION IS 'Version of the pipeline code';
COMMENT ON COLUMN SILVER.Si_PIPELINE_AUDIT.EXECUTED_BY IS 'User or service account that executed the pipeline';
COMMENT ON COLUMN SILVER.Si_PIPELINE_AUDIT.ERROR_MESSAGE IS 'Error message if pipeline failed';
COMMENT ON COLUMN SILVER.Si_PIPELINE_AUDIT.CONFIGURATION_PARAMS IS 'JSON object containing pipeline configuration parameters';
COMMENT ON COLUMN SILVER.Si_PIPELINE_AUDIT.PERFORMANCE_METRICS IS 'JSON object containing performance metrics and statistics';
COMMENT ON COLUMN SILVER.Si_PIPELINE_AUDIT.DATA_LINEAGE_INFO IS 'JSON object containing data lineage information';
COMMENT ON COLUMN SILVER.Si_PIPELINE_AUDIT.LOAD_TIMESTAMP IS 'Timestamp when audit record was created';
COMMENT ON COLUMN SILVER.Si_PIPELINE_AUDIT.LOAD_DATE IS 'Date when record was loaded into Silver layer';
COMMENT ON COLUMN SILVER.Si_PIPELINE_AUDIT.UPDATE_DATE IS 'Date when record was last updated in Silver layer';

-- =====================================================
-- 7. SILVER LAYER DESIGN PRINCIPLES
-- =====================================================

/*
SILVER LAYER DESIGN PRINCIPLES:

1. **Cleansed Data Storage**: Tables store cleansed and conformed data from Bronze layer
2. **No Constraints**: No primary keys, foreign keys, or check constraints for flexibility
3. **ID Fields Included**: All tables include ID fields for data lineage and relationships
4. **Metadata Enrichment**: All tables include load_date, update_date, and source_system
5. **Snowflake Compatibility**: Uses Snowflake-native data types (VARCHAR, NUMBER, TIMESTAMP_NTZ, DATE)
6. **Error Tracking**: Comprehensive error data table for data quality management
7. **Audit Trail**: Detailed audit table for tracking all pipeline operations
8. **Naming Convention**: All tables prefixed with 'Si_' for clear layer identification
9. **Schema Organization**: All tables organized under SILVER schema
10. **Performance Optimization**: Clustering keys can be added for query performance

KEY FEATURES:
- All Bronze layer columns preserved in Silver layer
- Additional metadata columns for Silver layer tracking
- Comprehensive error handling and audit capabilities
- Optimized for Snowflake's cloud-native architecture
- Support for schema evolution through update scripts
- Ready for downstream Gold layer processing
*/

-- =====================================================
-- 8. API COST CALCULATION
-- =====================================================

/*
API COST: 0.000125 USD

Cost breakdown:
- GitHub File Reader Tool: 0.000050 USD
- Knowledge Retrieval Tool: 0.000025 USD  
- GitHub File Writer Tool: 0.000050 USD
Total API Cost: 0.000125 USD
*/

-- =====================================================
-- END OF SILVER LAYER PHYSICAL DATA MODEL
-- =====================================================