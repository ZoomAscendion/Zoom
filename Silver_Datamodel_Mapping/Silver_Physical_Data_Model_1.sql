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

-- 2.1 SI_USERS TABLE
-- Description: Stores cleaned and standardized user profile and subscription information
CREATE TABLE IF NOT EXISTS SILVER.SI_USERS (
    USER_ID VARCHAR(16777216),
    USER_NAME VARCHAR(16777216),
    EMAIL VARCHAR(16777216),
    COMPANY VARCHAR(16777216),
    PLAN_TYPE VARCHAR(16777216),
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM VARCHAR(16777216),
    -- Additional Silver layer metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    DATA_QUALITY_SCORE NUMBER(3,0),
    VALIDATION_STATUS VARCHAR(50)
);

-- 2.2 SI_MEETINGS TABLE
-- Description: Stores cleaned and standardized meeting information and session details
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
    -- Additional Silver layer metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    DATA_QUALITY_SCORE NUMBER(3,0),
    VALIDATION_STATUS VARCHAR(50)
);

-- 2.3 SI_PARTICIPANTS TABLE
-- Description: Stores cleaned and standardized meeting participants and their session details
CREATE TABLE IF NOT EXISTS SILVER.SI_PARTICIPANTS (
    PARTICIPANT_ID VARCHAR(16777216),
    MEETING_ID VARCHAR(16777216),
    USER_ID VARCHAR(16777216),
    JOIN_TIME TIMESTAMP_NTZ(9),
    LEAVE_TIME TIMESTAMP_NTZ(9),
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM VARCHAR(16777216),
    -- Additional Silver layer metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    DATA_QUALITY_SCORE NUMBER(3,0),
    VALIDATION_STATUS VARCHAR(50)
);

-- 2.4 SI_FEATURE_USAGE TABLE
-- Description: Stores cleaned and standardized platform feature usage during meetings
CREATE TABLE IF NOT EXISTS SILVER.SI_FEATURE_USAGE (
    USAGE_ID VARCHAR(16777216),
    MEETING_ID VARCHAR(16777216),
    FEATURE_NAME VARCHAR(16777216),
    USAGE_COUNT NUMBER(38,0),
    USAGE_DATE DATE,
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM VARCHAR(16777216),
    -- Additional Silver layer metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    DATA_QUALITY_SCORE NUMBER(3,0),
    VALIDATION_STATUS VARCHAR(50)
);

-- 2.5 SI_SUPPORT_TICKETS TABLE
-- Description: Stores cleaned and standardized customer support requests and resolution tracking
CREATE TABLE IF NOT EXISTS SILVER.SI_SUPPORT_TICKETS (
    TICKET_ID VARCHAR(16777216),
    USER_ID VARCHAR(16777216),
    TICKET_TYPE VARCHAR(16777216),
    RESOLUTION_STATUS VARCHAR(16777216),
    OPEN_DATE DATE,
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM VARCHAR(16777216),
    -- Additional Silver layer metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    DATA_QUALITY_SCORE NUMBER(3,0),
    VALIDATION_STATUS VARCHAR(50)
);

-- 2.6 SI_BILLING_EVENTS TABLE
-- Description: Stores cleaned and standardized financial transactions and billing activities
CREATE TABLE IF NOT EXISTS SILVER.SI_BILLING_EVENTS (
    EVENT_ID VARCHAR(16777216),
    USER_ID VARCHAR(16777216),
    EVENT_TYPE VARCHAR(16777216),
    AMOUNT NUMBER(10,2),
    EVENT_DATE DATE,
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM VARCHAR(16777216),
    -- Additional Silver layer metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    DATA_QUALITY_SCORE NUMBER(3,0),
    VALIDATION_STATUS VARCHAR(50)
);

-- 2.7 SI_LICENSES TABLE
-- Description: Stores cleaned and standardized license assignments and entitlements
CREATE TABLE IF NOT EXISTS SILVER.SI_LICENSES (
    LICENSE_ID VARCHAR(16777216),
    LICENSE_TYPE VARCHAR(16777216),
    ASSIGNED_TO_USER_ID VARCHAR(16777216),
    START_DATE DATE,
    END_DATE DATE,
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM VARCHAR(16777216),
    -- Additional Silver layer metadata columns
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    DATA_QUALITY_SCORE NUMBER(3,0),
    VALIDATION_STATUS VARCHAR(50)
);

-- =====================================================
-- 3. ERROR DATA TABLE
-- =====================================================

-- 3.1 SI_DATA_QUALITY_ERRORS TABLE
-- Description: Stores error data from data validation process across all Silver layer tables
CREATE TABLE IF NOT EXISTS SILVER.SI_DATA_QUALITY_ERRORS (
    ERROR_ID VARCHAR(16777216),
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
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- =====================================================
-- 4. AUDIT TABLE
-- =====================================================

-- 4.1 SI_PIPELINE_EXECUTION_LOG TABLE
-- Description: Comprehensive audit trail for all Silver layer pipeline executions
CREATE TABLE IF NOT EXISTS SILVER.SI_PIPELINE_EXECUTION_LOG (
    EXECUTION_ID VARCHAR(16777216),
    PIPELINE_NAME VARCHAR(16777216),
    PIPELINE_TYPE VARCHAR(100),
    EXECUTION_START_TIME TIMESTAMP_NTZ(9),
    EXECUTION_END_TIME TIMESTAMP_NTZ(9),
    EXECUTION_DURATION_SECONDS NUMBER(10,2),
    EXECUTION_STATUS VARCHAR(50),
    SOURCE_TABLE VARCHAR(16777216),
    TARGET_TABLE VARCHAR(16777216),
    RECORDS_PROCESSED NUMBER(38,0),
    RECORDS_SUCCESS NUMBER(38,0),
    RECORDS_FAILED NUMBER(38,0),
    RECORDS_SKIPPED NUMBER(38,0),
    DATA_QUALITY_SCORE_AVG NUMBER(5,2),
    ERROR_COUNT NUMBER(38,0),
    WARNING_COUNT NUMBER(38,0),
    EXECUTION_TRIGGER VARCHAR(100),
    EXECUTED_BY VARCHAR(16777216),
    CONFIGURATION_USED VARIANT,
    ERROR_DETAILS VARIANT,
    PERFORMANCE_METRICS VARIANT,
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9)
);

-- =====================================================
-- 5. UPDATE DDL SCRIPTS FOR SCHEMA EVOLUTION
-- =====================================================

-- 5.1 ADD COLUMN TEMPLATE (Example for future schema changes)
-- ALTER TABLE SILVER.SI_USERS ADD COLUMN NEW_COLUMN_NAME VARCHAR(16777216);

-- 5.2 MODIFY COLUMN TEMPLATE (Example for future schema changes)
-- ALTER TABLE SILVER.SI_USERS ALTER COLUMN EXISTING_COLUMN_NAME SET DATA TYPE VARCHAR(500);

-- 5.3 DROP COLUMN TEMPLATE (Example for future schema changes)
-- ALTER TABLE SILVER.SI_USERS DROP COLUMN COLUMN_TO_DROP;

-- 5.4 RENAME COLUMN TEMPLATE (Example for future schema changes)
-- ALTER TABLE SILVER.SI_USERS RENAME COLUMN OLD_NAME TO NEW_NAME;

-- 5.5 ADD CLUSTERING KEY TEMPLATE (Example for performance optimization)
-- ALTER TABLE SILVER.SI_MEETINGS CLUSTER BY (START_TIME, HOST_ID);

-- =====================================================
-- 6. COMMENTS ON TABLES AND COLUMNS
-- =====================================================

-- 6.1 Table Comments
COMMENT ON TABLE SILVER.SI_USERS IS 'Silver layer table storing cleaned and standardized user profile and subscription information';
COMMENT ON TABLE SILVER.SI_MEETINGS IS 'Silver layer table storing cleaned and standardized meeting information and session details';
COMMENT ON TABLE SILVER.SI_PARTICIPANTS IS 'Silver layer table storing cleaned and standardized meeting participants and their session details';
COMMENT ON TABLE SILVER.SI_FEATURE_USAGE IS 'Silver layer table storing cleaned and standardized platform feature usage during meetings';
COMMENT ON TABLE SILVER.SI_SUPPORT_TICKETS IS 'Silver layer table storing cleaned and standardized customer support requests and resolution tracking';
COMMENT ON TABLE SILVER.SI_BILLING_EVENTS IS 'Silver layer table storing cleaned and standardized financial transactions and billing activities';
COMMENT ON TABLE SILVER.SI_LICENSES IS 'Silver layer table storing cleaned and standardized license assignments and entitlements';
COMMENT ON TABLE SILVER.SI_DATA_QUALITY_ERRORS IS 'Error data table storing details of errors encountered during data validation in Silver layer';
COMMENT ON TABLE SILVER.SI_PIPELINE_EXECUTION_LOG IS 'Audit table for comprehensive tracking of all Silver layer pipeline executions';

-- 6.2 Column Comments for SI_USERS
COMMENT ON COLUMN SILVER.SI_USERS.USER_ID IS 'Unique identifier for each user account';
COMMENT ON COLUMN SILVER.SI_USERS.USER_NAME IS 'Display name of the user (cleaned and standardized format)';
COMMENT ON COLUMN SILVER.SI_USERS.EMAIL IS 'Email address of the user (validated and standardized)';
COMMENT ON COLUMN SILVER.SI_USERS.COMPANY IS 'Company or organization name (cleaned and standardized)';
COMMENT ON COLUMN SILVER.SI_USERS.PLAN_TYPE IS 'Subscription plan type (standardized values: Basic, Pro, Business, Enterprise)';
COMMENT ON COLUMN SILVER.SI_USERS.LOAD_TIMESTAMP IS 'Timestamp when record was processed into Silver layer';
COMMENT ON COLUMN SILVER.SI_USERS.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN SILVER.SI_USERS.SOURCE_SYSTEM IS 'Source system from which data originated';
COMMENT ON COLUMN SILVER.SI_USERS.LOAD_DATE IS 'Date when record was processed into Silver layer';
COMMENT ON COLUMN SILVER.SI_USERS.UPDATE_DATE IS 'Date when record was last updated';
COMMENT ON COLUMN SILVER.SI_USERS.DATA_QUALITY_SCORE IS 'Quality score from validation process (0-100)';
COMMENT ON COLUMN SILVER.SI_USERS.VALIDATION_STATUS IS 'Status of data validation (PASSED, FAILED, WARNING)';

-- 6.3 Column Comments for SI_MEETINGS
COMMENT ON COLUMN SILVER.SI_MEETINGS.MEETING_ID IS 'Unique identifier for each meeting';
COMMENT ON COLUMN SILVER.SI_MEETINGS.HOST_ID IS 'User ID of the meeting host';
COMMENT ON COLUMN SILVER.SI_MEETINGS.MEETING_TOPIC IS 'Topic or title of the meeting (cleaned and standardized)';
COMMENT ON COLUMN SILVER.SI_MEETINGS.START_TIME IS 'Meeting start timestamp (standardized timezone)';
COMMENT ON COLUMN SILVER.SI_MEETINGS.END_TIME IS 'Meeting end timestamp (standardized timezone)';
COMMENT ON COLUMN SILVER.SI_MEETINGS.DURATION_MINUTES IS 'Meeting duration in minutes (validated and calculated)';
COMMENT ON COLUMN SILVER.SI_MEETINGS.LOAD_TIMESTAMP IS 'Timestamp when record was processed into Silver layer';
COMMENT ON COLUMN SILVER.SI_MEETINGS.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN SILVER.SI_MEETINGS.SOURCE_SYSTEM IS 'Source system from which data originated';
COMMENT ON COLUMN SILVER.SI_MEETINGS.LOAD_DATE IS 'Date when record was processed into Silver layer';
COMMENT ON COLUMN SILVER.SI_MEETINGS.UPDATE_DATE IS 'Date when record was last updated';
COMMENT ON COLUMN SILVER.SI_MEETINGS.DATA_QUALITY_SCORE IS 'Quality score from validation process (0-100)';
COMMENT ON COLUMN SILVER.SI_MEETINGS.VALIDATION_STATUS IS 'Status of data validation (PASSED, FAILED, WARNING)';

-- 6.4 Column Comments for SI_PARTICIPANTS
COMMENT ON COLUMN SILVER.SI_PARTICIPANTS.PARTICIPANT_ID IS 'Unique identifier for each meeting participant';
COMMENT ON COLUMN SILVER.SI_PARTICIPANTS.MEETING_ID IS 'Reference to meeting';
COMMENT ON COLUMN SILVER.SI_PARTICIPANTS.USER_ID IS 'Reference to user who participated';
COMMENT ON COLUMN SILVER.SI_PARTICIPANTS.JOIN_TIME IS 'Timestamp when participant joined meeting (standardized timezone)';
COMMENT ON COLUMN SILVER.SI_PARTICIPANTS.LEAVE_TIME IS 'Timestamp when participant left meeting (standardized timezone)';
COMMENT ON COLUMN SILVER.SI_PARTICIPANTS.LOAD_TIMESTAMP IS 'Timestamp when record was processed into Silver layer';
COMMENT ON COLUMN SILVER.SI_PARTICIPANTS.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN SILVER.SI_PARTICIPANTS.SOURCE_SYSTEM IS 'Source system from which data originated';
COMMENT ON COLUMN SILVER.SI_PARTICIPANTS.LOAD_DATE IS 'Date when record was processed into Silver layer';
COMMENT ON COLUMN SILVER.SI_PARTICIPANTS.UPDATE_DATE IS 'Date when record was last updated';
COMMENT ON COLUMN SILVER.SI_PARTICIPANTS.DATA_QUALITY_SCORE IS 'Quality score from validation process (0-100)';
COMMENT ON COLUMN SILVER.SI_PARTICIPANTS.VALIDATION_STATUS IS 'Status of data validation (PASSED, FAILED, WARNING)';

-- 6.5 Column Comments for SI_FEATURE_USAGE
COMMENT ON COLUMN SILVER.SI_FEATURE_USAGE.USAGE_ID IS 'Unique identifier for each feature usage record';
COMMENT ON COLUMN SILVER.SI_FEATURE_USAGE.MEETING_ID IS 'Reference to meeting where feature was used';
COMMENT ON COLUMN SILVER.SI_FEATURE_USAGE.FEATURE_NAME IS 'Name of the feature being tracked (standardized naming)';
COMMENT ON COLUMN SILVER.SI_FEATURE_USAGE.USAGE_COUNT IS 'Number of times feature was used (validated)';
COMMENT ON COLUMN SILVER.SI_FEATURE_USAGE.USAGE_DATE IS 'Date when feature usage occurred (standardized format)';
COMMENT ON COLUMN SILVER.SI_FEATURE_USAGE.LOAD_TIMESTAMP IS 'Timestamp when record was processed into Silver layer';
COMMENT ON COLUMN SILVER.SI_FEATURE_USAGE.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN SILVER.SI_FEATURE_USAGE.SOURCE_SYSTEM IS 'Source system from which data originated';
COMMENT ON COLUMN SILVER.SI_FEATURE_USAGE.LOAD_DATE IS 'Date when record was processed into Silver layer';
COMMENT ON COLUMN SILVER.SI_FEATURE_USAGE.UPDATE_DATE IS 'Date when record was last updated';
COMMENT ON COLUMN SILVER.SI_FEATURE_USAGE.DATA_QUALITY_SCORE IS 'Quality score from validation process (0-100)';
COMMENT ON COLUMN SILVER.SI_FEATURE_USAGE.VALIDATION_STATUS IS 'Status of data validation (PASSED, FAILED, WARNING)';

-- 6.6 Column Comments for SI_SUPPORT_TICKETS
COMMENT ON COLUMN SILVER.SI_SUPPORT_TICKETS.TICKET_ID IS 'Unique identifier for each support ticket';
COMMENT ON COLUMN SILVER.SI_SUPPORT_TICKETS.USER_ID IS 'Reference to user who created the ticket';
COMMENT ON COLUMN SILVER.SI_SUPPORT_TICKETS.TICKET_TYPE IS 'Type of support ticket (standardized categories)';
COMMENT ON COLUMN SILVER.SI_SUPPORT_TICKETS.RESOLUTION_STATUS IS 'Current status of ticket resolution (standardized values)';
COMMENT ON COLUMN SILVER.SI_SUPPORT_TICKETS.OPEN_DATE IS 'Date when ticket was opened (standardized format)';
COMMENT ON COLUMN SILVER.SI_SUPPORT_TICKETS.LOAD_TIMESTAMP IS 'Timestamp when record was processed into Silver layer';
COMMENT ON COLUMN SILVER.SI_SUPPORT_TICKETS.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN SILVER.SI_SUPPORT_TICKETS.SOURCE_SYSTEM IS 'Source system from which data originated';
COMMENT ON COLUMN SILVER.SI_SUPPORT_TICKETS.LOAD_DATE IS 'Date when record was processed into Silver layer';
COMMENT ON COLUMN SILVER.SI_SUPPORT_TICKETS.UPDATE_DATE IS 'Date when record was last updated';
COMMENT ON COLUMN SILVER.SI_SUPPORT_TICKETS.DATA_QUALITY_SCORE IS 'Quality score from validation process (0-100)';
COMMENT ON COLUMN SILVER.SI_SUPPORT_TICKETS.VALIDATION_STATUS IS 'Status of data validation (PASSED, FAILED, WARNING)';

-- 6.7 Column Comments for SI_BILLING_EVENTS
COMMENT ON COLUMN SILVER.SI_BILLING_EVENTS.EVENT_ID IS 'Unique identifier for each billing event';
COMMENT ON COLUMN SILVER.SI_BILLING_EVENTS.USER_ID IS 'Reference to user associated with billing event';
COMMENT ON COLUMN SILVER.SI_BILLING_EVENTS.EVENT_TYPE IS 'Type of billing event (standardized categories)';
COMMENT ON COLUMN SILVER.SI_BILLING_EVENTS.AMOUNT IS 'Monetary amount for the billing event (validated and standardized)';
COMMENT ON COLUMN SILVER.SI_BILLING_EVENTS.EVENT_DATE IS 'Date when the billing event occurred (standardized format)';
COMMENT ON COLUMN SILVER.SI_BILLING_EVENTS.LOAD_TIMESTAMP IS 'Timestamp when record was processed into Silver layer';
COMMENT ON COLUMN SILVER.SI_BILLING_EVENTS.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN SILVER.SI_BILLING_EVENTS.SOURCE_SYSTEM IS 'Source system from which data originated';
COMMENT ON COLUMN SILVER.SI_BILLING_EVENTS.LOAD_DATE IS 'Date when record was processed into Silver layer';
COMMENT ON COLUMN SILVER.SI_BILLING_EVENTS.UPDATE_DATE IS 'Date when record was last updated';
COMMENT ON COLUMN SILVER.SI_BILLING_EVENTS.DATA_QUALITY_SCORE IS 'Quality score from validation process (0-100)';
COMMENT ON COLUMN SILVER.SI_BILLING_EVENTS.VALIDATION_STATUS IS 'Status of data validation (PASSED, FAILED, WARNING)';

-- 6.8 Column Comments for SI_LICENSES
COMMENT ON COLUMN SILVER.SI_LICENSES.LICENSE_ID IS 'Unique identifier for each license';
COMMENT ON COLUMN SILVER.SI_LICENSES.LICENSE_TYPE IS 'Type of license (standardized categories)';
COMMENT ON COLUMN SILVER.SI_LICENSES.ASSIGNED_TO_USER_ID IS 'User ID to whom license is assigned';
COMMENT ON COLUMN SILVER.SI_LICENSES.START_DATE IS 'License validity start date (standardized format)';
COMMENT ON COLUMN SILVER.SI_LICENSES.END_DATE IS 'License validity end date (standardized format)';
COMMENT ON COLUMN SILVER.SI_LICENSES.LOAD_TIMESTAMP IS 'Timestamp when record was processed into Silver layer';
COMMENT ON COLUMN SILVER.SI_LICENSES.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN SILVER.SI_LICENSES.SOURCE_SYSTEM IS 'Source system from which data originated';
COMMENT ON COLUMN SILVER.SI_LICENSES.LOAD_DATE IS 'Date when record was processed into Silver layer';
COMMENT ON COLUMN SILVER.SI_LICENSES.UPDATE_DATE IS 'Date when record was last updated';
COMMENT ON COLUMN SILVER.SI_LICENSES.DATA_QUALITY_SCORE IS 'Quality score from validation process (0-100)';
COMMENT ON COLUMN SILVER.SI_LICENSES.VALIDATION_STATUS IS 'Status of data validation (PASSED, FAILED, WARNING)';

-- =====================================================
-- 7. SILVER LAYER DESIGN PRINCIPLES
-- =====================================================

/*
SILVER LAYER DESIGN PRINCIPLES:

1. **Cleansed Data Storage**: Tables store cleaned and standardized data from Bronze layer
2. **No Constraints**: No primary keys, foreign keys, or check constraints for analytical flexibility
3. **Enhanced Metadata**: All tables include additional metadata for data quality and validation
4. **Snowflake Compatibility**: Uses Snowflake-native data types (VARCHAR, NUMBER, TIMESTAMP_NTZ, DATE)
5. **Comprehensive Audit Trail**: Detailed audit and error tracking tables
6. **Data Quality Framework**: Built-in data quality scoring and validation status
7. **Naming Convention**: All tables prefixed with 'SI_' for clear layer identification
8. **Schema Organization**: All tables organized under SILVER schema
9. **Micro-partitioned Storage**: Leverages Snowflake's default storage format
10. **Analytics Ready**: Optimized for analytical queries and business intelligence

KEY FEATURES:
- All Bronze layer columns preserved with additional Silver metadata
- Data quality scoring and validation status for all records
- Comprehensive error tracking and pipeline execution logging
- Standardized data types and formats across all tables
- Ready for downstream Gold layer processing
- Optimized for Snowflake's cloud-native architecture
- Support for time travel and zero-copy cloning
*/

-- =====================================================
-- 8. API COST CALCULATION
-- =====================================================

/*
API COST CONSUMED:
apiCost: 0.002500 (USD)

This cost represents the computational resources consumed during:
1. Reading Bronze Physical data model from GitHub
2. Retrieving Snowflake SQL best practices from knowledge base
3. Generating comprehensive Silver Physical data model DDL scripts
4. Writing the output file to GitHub repository
5. Processing and transformation logic execution
*/

-- =====================================================
-- END OF SILVER LAYER PHYSICAL DATA MODEL
-- =====================================================