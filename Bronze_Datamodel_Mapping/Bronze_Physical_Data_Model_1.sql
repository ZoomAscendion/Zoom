_____________________________________________
-- *Author*: AAVA
-- *Created on*:   11-11-2025
-- *Description*: Bronze layer physical data model for Zoom Platform Analytics System following Medallion architecture
-- *Version*: 1 
-- *Updated on*: 11-11-2025
_____________________________________________

-- =====================================================
-- BRONZE LAYER PHYSICAL DATA MODEL - DDL SCRIPTS
-- Database: DB_POC_ZOOM
-- Schema: BRONZE
-- Purpose: Raw data storage with metadata for Medallion architecture
-- =====================================================

-- 1. CREATE BRONZE SCHEMA
CREATE SCHEMA IF NOT EXISTS BRONZE;

-- =====================================================
-- 2. BRONZE LAYER TABLES - DDL SCRIPTS
-- =====================================================

-- 2.1 BZ_USERS TABLE
-- Description: Stores user profile and subscription information from source systems
CREATE TABLE IF NOT EXISTS BRONZE.BZ_USERS (
    USER_ID VARCHAR(16777216),
    USER_NAME VARCHAR(16777216),
    EMAIL VARCHAR(16777216),
    COMPANY VARCHAR(16777216),
    PLAN_TYPE VARCHAR(16777216),
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- 2.2 BZ_MEETINGS TABLE
-- Description: Stores meeting information and session details
CREATE TABLE IF NOT EXISTS BRONZE.BZ_MEETINGS (
    MEETING_ID VARCHAR(16777216),
    HOST_ID VARCHAR(16777216),
    MEETING_TOPIC VARCHAR(16777216),
    START_TIME TIMESTAMP_NTZ(9),
    END_TIME TIMESTAMP_NTZ(9),
    DURATION_MINUTES NUMBER(38,0),
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- 2.3 BZ_PARTICIPANTS TABLE
-- Description: Tracks meeting participants and their session details
CREATE TABLE IF NOT EXISTS BRONZE.BZ_PARTICIPANTS (
    PARTICIPANT_ID VARCHAR(16777216),
    MEETING_ID VARCHAR(16777216),
    USER_ID VARCHAR(16777216),
    JOIN_TIME TIMESTAMP_NTZ(9),
    LEAVE_TIME TIMESTAMP_NTZ(9),
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- 2.4 BZ_FEATURE_USAGE TABLE
-- Description: Records usage of platform features during meetings
CREATE TABLE IF NOT EXISTS BRONZE.BZ_FEATURE_USAGE (
    USAGE_ID VARCHAR(16777216),
    MEETING_ID VARCHAR(16777216),
    FEATURE_NAME VARCHAR(16777216),
    USAGE_COUNT NUMBER(38,0),
    USAGE_DATE DATE,
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- 2.5 BZ_SUPPORT_TICKETS TABLE
-- Description: Manages customer support requests and resolution tracking
CREATE TABLE IF NOT EXISTS BRONZE.BZ_SUPPORT_TICKETS (
    TICKET_ID VARCHAR(16777216),
    USER_ID VARCHAR(16777216),
    TICKET_TYPE VARCHAR(16777216),
    RESOLUTION_STATUS VARCHAR(16777216),
    OPEN_DATE DATE,
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- 2.6 BZ_BILLING_EVENTS TABLE
-- Description: Tracks financial transactions and billing activities
CREATE TABLE IF NOT EXISTS BRONZE.BZ_BILLING_EVENTS (
    EVENT_ID VARCHAR(16777216),
    USER_ID VARCHAR(16777216),
    EVENT_TYPE VARCHAR(16777216),
    AMOUNT NUMBER(10,2),
    EVENT_DATE DATE,
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- 2.7 BZ_LICENSES TABLE
-- Description: Manages license assignments and entitlements
CREATE TABLE IF NOT EXISTS BRONZE.BZ_LICENSES (
    LICENSE_ID VARCHAR(16777216),
    LICENSE_TYPE VARCHAR(16777216),
    ASSIGNED_TO_USER_ID VARCHAR(16777216),
    START_DATE DATE,
    END_DATE DATE,
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- =====================================================
-- 3. AUDIT TABLE
-- =====================================================

-- 3.1 BZ_DATA_AUDIT TABLE
-- Description: Comprehensive audit trail for all Bronze layer data operations
CREATE TABLE IF NOT EXISTS BRONZE.BZ_DATA_AUDIT (
    RECORD_ID NUMBER AUTOINCREMENT,
    SOURCE_TABLE VARCHAR(16777216),
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    PROCESSED_BY VARCHAR(16777216),
    PROCESSING_TIME NUMBER(38,3),
    STATUS VARCHAR(16777216)
);

-- =====================================================
-- 4. COMMENTS ON TABLES AND COLUMNS
-- =====================================================

-- 4.1 Table Comments
COMMENT ON TABLE BRONZE.BZ_USERS IS 'Bronze layer table storing raw user profile and subscription information';
COMMENT ON TABLE BRONZE.BZ_MEETINGS IS 'Bronze layer table storing raw meeting information and session details';
COMMENT ON TABLE BRONZE.BZ_PARTICIPANTS IS 'Bronze layer table tracking raw meeting participants and their session details';
COMMENT ON TABLE BRONZE.BZ_FEATURE_USAGE IS 'Bronze layer table recording raw usage of platform features during meetings';
COMMENT ON TABLE BRONZE.BZ_SUPPORT_TICKETS IS 'Bronze layer table managing raw customer support requests and resolution tracking';
COMMENT ON TABLE BRONZE.BZ_BILLING_EVENTS IS 'Bronze layer table tracking raw financial transactions and billing activities';
COMMENT ON TABLE BRONZE.BZ_LICENSES IS 'Bronze layer table managing raw license assignments and entitlements';
COMMENT ON TABLE BRONZE.BZ_DATA_AUDIT IS 'Audit table for comprehensive tracking of all Bronze layer data operations';

-- 4.2 Column Comments for BZ_USERS
COMMENT ON COLUMN BRONZE.BZ_USERS.USER_ID IS 'Unique identifier for each user account';
COMMENT ON COLUMN BRONZE.BZ_USERS.USER_NAME IS 'Display name of the user (PII)';
COMMENT ON COLUMN BRONZE.BZ_USERS.EMAIL IS 'Email address of the user (PII)';
COMMENT ON COLUMN BRONZE.BZ_USERS.COMPANY IS 'Company or organization name';
COMMENT ON COLUMN BRONZE.BZ_USERS.PLAN_TYPE IS 'Subscription plan type (Basic, Pro, Business, Enterprise)';
COMMENT ON COLUMN BRONZE.BZ_USERS.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN BRONZE.BZ_USERS.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN BRONZE.BZ_USERS.SOURCE_SYSTEM IS 'Source system from which data originated';

-- 4.3 Column Comments for BZ_MEETINGS
COMMENT ON COLUMN BRONZE.BZ_MEETINGS.MEETING_ID IS 'Unique identifier for each meeting';
COMMENT ON COLUMN BRONZE.BZ_MEETINGS.HOST_ID IS 'User ID of the meeting host';
COMMENT ON COLUMN BRONZE.BZ_MEETINGS.MEETING_TOPIC IS 'Topic or title of the meeting (Potential PII)';
COMMENT ON COLUMN BRONZE.BZ_MEETINGS.START_TIME IS 'Meeting start timestamp';
COMMENT ON COLUMN BRONZE.BZ_MEETINGS.END_TIME IS 'Meeting end timestamp';
COMMENT ON COLUMN BRONZE.BZ_MEETINGS.DURATION_MINUTES IS 'Meeting duration in minutes';
COMMENT ON COLUMN BRONZE.BZ_MEETINGS.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN BRONZE.BZ_MEETINGS.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN BRONZE.BZ_MEETINGS.SOURCE_SYSTEM IS 'Source system from which data originated';

-- 4.4 Column Comments for BZ_PARTICIPANTS
COMMENT ON COLUMN BRONZE.BZ_PARTICIPANTS.PARTICIPANT_ID IS 'Unique identifier for each meeting participant';
COMMENT ON COLUMN BRONZE.BZ_PARTICIPANTS.MEETING_ID IS 'Reference to meeting';
COMMENT ON COLUMN BRONZE.BZ_PARTICIPANTS.USER_ID IS 'Reference to user who participated';
COMMENT ON COLUMN BRONZE.BZ_PARTICIPANTS.JOIN_TIME IS 'Timestamp when participant joined meeting';
COMMENT ON COLUMN BRONZE.BZ_PARTICIPANTS.LEAVE_TIME IS 'Timestamp when participant left meeting';
COMMENT ON COLUMN BRONZE.BZ_PARTICIPANTS.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN BRONZE.BZ_PARTICIPANTS.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN BRONZE.BZ_PARTICIPANTS.SOURCE_SYSTEM IS 'Source system from which data originated';

-- 4.5 Column Comments for BZ_FEATURE_USAGE
COMMENT ON COLUMN BRONZE.BZ_FEATURE_USAGE.USAGE_ID IS 'Unique identifier for each feature usage record';
COMMENT ON COLUMN BRONZE.BZ_FEATURE_USAGE.MEETING_ID IS 'Reference to meeting where feature was used';
COMMENT ON COLUMN BRONZE.BZ_FEATURE_USAGE.FEATURE_NAME IS 'Name of the feature being tracked';
COMMENT ON COLUMN BRONZE.BZ_FEATURE_USAGE.USAGE_COUNT IS 'Number of times feature was used';
COMMENT ON COLUMN BRONZE.BZ_FEATURE_USAGE.USAGE_DATE IS 'Date when feature usage occurred';
COMMENT ON COLUMN BRONZE.BZ_FEATURE_USAGE.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN BRONZE.BZ_FEATURE_USAGE.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN BRONZE.BZ_FEATURE_USAGE.SOURCE_SYSTEM IS 'Source system from which data originated';

-- 4.6 Column Comments for BZ_SUPPORT_TICKETS
COMMENT ON COLUMN BRONZE.BZ_SUPPORT_TICKETS.TICKET_ID IS 'Unique identifier for each support ticket';
COMMENT ON COLUMN BRONZE.BZ_SUPPORT_TICKETS.USER_ID IS 'Reference to user who created the ticket';
COMMENT ON COLUMN BRONZE.BZ_SUPPORT_TICKETS.TICKET_TYPE IS 'Type of support ticket';
COMMENT ON COLUMN BRONZE.BZ_SUPPORT_TICKETS.RESOLUTION_STATUS IS 'Current status of ticket resolution';
COMMENT ON COLUMN BRONZE.BZ_SUPPORT_TICKETS.OPEN_DATE IS 'Date when ticket was opened';
COMMENT ON COLUMN BRONZE.BZ_SUPPORT_TICKETS.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN BRONZE.BZ_SUPPORT_TICKETS.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN BRONZE.BZ_SUPPORT_TICKETS.SOURCE_SYSTEM IS 'Source system from which data originated';

-- 4.7 Column Comments for BZ_BILLING_EVENTS
COMMENT ON COLUMN BRONZE.BZ_BILLING_EVENTS.EVENT_ID IS 'Unique identifier for each billing event';
COMMENT ON COLUMN BRONZE.BZ_BILLING_EVENTS.USER_ID IS 'Reference to user associated with billing event';
COMMENT ON COLUMN BRONZE.BZ_BILLING_EVENTS.EVENT_TYPE IS 'Type of billing event';
COMMENT ON COLUMN BRONZE.BZ_BILLING_EVENTS.AMOUNT IS 'Monetary amount for the billing event';
COMMENT ON COLUMN BRONZE.BZ_BILLING_EVENTS.EVENT_DATE IS 'Date when the billing event occurred';
COMMENT ON COLUMN BRONZE.BZ_BILLING_EVENTS.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN BRONZE.BZ_BILLING_EVENTS.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN BRONZE.BZ_BILLING_EVENTS.SOURCE_SYSTEM IS 'Source system from which data originated';

-- 4.8 Column Comments for BZ_LICENSES
COMMENT ON COLUMN BRONZE.BZ_LICENSES.LICENSE_ID IS 'Unique identifier for each license';
COMMENT ON COLUMN BRONZE.BZ_LICENSES.LICENSE_TYPE IS 'Type of license';
COMMENT ON COLUMN BRONZE.BZ_LICENSES.ASSIGNED_TO_USER_ID IS 'User ID to whom license is assigned';
COMMENT ON COLUMN BRONZE.BZ_LICENSES.START_DATE IS 'License validity start date';
COMMENT ON COLUMN BRONZE.BZ_LICENSES.END_DATE IS 'License validity end date';
COMMENT ON COLUMN BRONZE.BZ_LICENSES.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN BRONZE.BZ_LICENSES.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN BRONZE.BZ_LICENSES.SOURCE_SYSTEM IS 'Source system from which data originated';

-- 4.9 Column Comments for BZ_DATA_AUDIT
COMMENT ON COLUMN BRONZE.BZ_DATA_AUDIT.RECORD_ID IS 'Auto-incrementing unique identifier for each audit record';
COMMENT ON COLUMN BRONZE.BZ_DATA_AUDIT.SOURCE_TABLE IS 'Name of the Bronze layer table';
COMMENT ON COLUMN BRONZE.BZ_DATA_AUDIT.LOAD_TIMESTAMP IS 'When the operation occurred';
COMMENT ON COLUMN BRONZE.BZ_DATA_AUDIT.PROCESSED_BY IS 'User or process that performed the operation';
COMMENT ON COLUMN BRONZE.BZ_DATA_AUDIT.PROCESSING_TIME IS 'Time taken to process the operation in seconds';
COMMENT ON COLUMN BRONZE.BZ_DATA_AUDIT.STATUS IS 'Status of the operation (SUCCESS, FAILED, WARNING)';

-- =====================================================
-- 5. BRONZE LAYER DESIGN PRINCIPLES
-- =====================================================

/*
BRONZE LAYER DESIGN PRINCIPLES:

1. **Raw Data Storage**: Tables store data as-is from source systems without transformation
2. **No Constraints**: No primary keys, foreign keys, or check constraints for flexibility
3. **Metadata Enrichment**: All tables include load_timestamp, update_timestamp, and source_system
4. **Snowflake Compatibility**: Uses Snowflake-native data types (VARCHAR, NUMBER, TIMESTAMP_NTZ, DATE)
5. **Audit Trail**: Comprehensive audit table for tracking all data operations
6. **PII Identification**: Comments identify PII fields for compliance and security
7. **Naming Convention**: All tables prefixed with 'BZ_' for clear layer identification
8. **Schema Organization**: All tables organized under BRONZE schema
9. **Micro-partitioned Storage**: Leverages Snowflake's default storage format
10. **Scalability**: Designed to handle large volumes of raw data efficiently

KEY FEATURES:
- No enforced referential integrity (Bronze layer principle)
- Flexible schema to accommodate source system changes
- Comprehensive metadata for data lineage
- Optimized for Snowflake's cloud-native architecture
- Support for time travel and zero-copy cloning
- Ready for downstream Silver layer processing
*/

-- =====================================================
-- END OF BRONZE LAYER PHYSICAL DATA MODEL
-- =====================================================
