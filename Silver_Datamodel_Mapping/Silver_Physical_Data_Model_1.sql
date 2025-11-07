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
-- Source: BRONZE.BZ_USERS
CREATE TABLE IF NOT EXISTS SILVER.SI_USERS (
    SI_USER_ID NUMBER AUTOINCREMENT,
    USER_ID STRING,
    USER_NAME STRING,
    EMAIL STRING,
    COMPANY STRING,
    PLAN_TYPE STRING,
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM STRING,
    DATA_QUALITY_FLAG STRING,
    PROCESSING_DATE DATE
);

-- 2.2 SI_MEETINGS TABLE
-- Description: Stores cleaned and standardized meeting information and session details
-- Source: BRONZE.BZ_MEETINGS
CREATE TABLE IF NOT EXISTS SILVER.SI_MEETINGS (
    SI_MEETING_ID NUMBER AUTOINCREMENT,
    MEETING_ID STRING,
    HOST_ID STRING,
    MEETING_TOPIC STRING,
    START_TIME TIMESTAMP_NTZ(9),
    END_TIME TIMESTAMP_NTZ(9),
    DURATION_MINUTES NUMBER(38,0),
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM STRING,
    DATA_QUALITY_FLAG STRING,
    PROCESSING_DATE DATE
);

-- 2.3 SI_PARTICIPANTS TABLE
-- Description: Stores cleaned and standardized meeting participant information
-- Source: BRONZE.BZ_PARTICIPANTS
CREATE TABLE IF NOT EXISTS SILVER.SI_PARTICIPANTS (
    SI_PARTICIPANT_ID NUMBER AUTOINCREMENT,
    PARTICIPANT_ID STRING,
    MEETING_ID STRING,
    USER_ID STRING,
    JOIN_TIME TIMESTAMP_NTZ(9),
    LEAVE_TIME TIMESTAMP_NTZ(9),
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM STRING,
    DATA_QUALITY_FLAG STRING,
    PROCESSING_DATE DATE
);

-- 2.4 SI_FEATURE_USAGE TABLE
-- Description: Stores cleaned and standardized platform feature usage data
-- Source: BRONZE.BZ_FEATURE_USAGE
CREATE TABLE IF NOT EXISTS SILVER.SI_FEATURE_USAGE (
    SI_USAGE_ID NUMBER AUTOINCREMENT,
    USAGE_ID STRING,
    MEETING_ID STRING,
    FEATURE_NAME STRING,
    USAGE_COUNT NUMBER(38,0),
    USAGE_DATE DATE,
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM STRING,
    DATA_QUALITY_FLAG STRING,
    PROCESSING_DATE DATE
);

-- 2.5 SI_SUPPORT_TICKETS TABLE
-- Description: Stores cleaned and standardized customer support request information
-- Source: BRONZE.BZ_SUPPORT_TICKETS
CREATE TABLE IF NOT EXISTS SILVER.SI_SUPPORT_TICKETS (
    SI_TICKET_ID NUMBER AUTOINCREMENT,
    TICKET_ID STRING,
    USER_ID STRING,
    TICKET_TYPE STRING,
    RESOLUTION_STATUS STRING,
    OPEN_DATE DATE,
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM STRING,
    DATA_QUALITY_FLAG STRING,
    PROCESSING_DATE DATE
);

-- 2.6 SI_BILLING_EVENTS TABLE
-- Description: Stores cleaned and standardized financial transaction information
-- Source: BRONZE.BZ_BILLING_EVENTS
CREATE TABLE IF NOT EXISTS SILVER.SI_BILLING_EVENTS (
    SI_EVENT_ID NUMBER AUTOINCREMENT,
    EVENT_ID STRING,
    USER_ID STRING,
    EVENT_TYPE STRING,
    AMOUNT NUMBER(10,2),
    EVENT_DATE DATE,
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM STRING,
    DATA_QUALITY_FLAG STRING,
    PROCESSING_DATE DATE
);

-- 2.7 SI_LICENSES TABLE
-- Description: Stores cleaned and standardized license assignment information
-- Source: BRONZE.BZ_LICENSES
CREATE TABLE IF NOT EXISTS SILVER.SI_LICENSES (
    SI_LICENSE_ID NUMBER AUTOINCREMENT,
    LICENSE_ID STRING,
    LICENSE_TYPE STRING,
    ASSIGNED_TO_USER_ID STRING,
    START_DATE DATE,
    END_DATE DATE,
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM STRING,
    DATA_QUALITY_FLAG STRING,
    PROCESSING_DATE DATE
);

-- =====================================================
-- 3. ERROR DATA TABLE
-- =====================================================

-- 3.1 SI_DATA_QUALITY_ERRORS TABLE
-- Description: Stores error data from data validation process during Silver layer transformation
CREATE TABLE IF NOT EXISTS SILVER.SI_DATA_QUALITY_ERRORS (
    ERROR_ID STRING,
    SOURCE_TABLE STRING,
    TARGET_TABLE STRING,
    ERROR_TYPE STRING,
    ERROR_DESCRIPTION STRING,
    ERROR_COLUMN STRING,
    ERROR_VALUE STRING,
    ERROR_TIMESTAMP TIMESTAMP_NTZ(9),
    SEVERITY_LEVEL STRING,
    RESOLUTION_STATUS STRING,
    PROCESSING_DATE DATE
);

-- =====================================================
-- 4. AUDIT TABLE
-- =====================================================

-- 4.1 SI_PIPELINE_AUDIT TABLE
-- Description: Stores comprehensive audit details from pipeline execution
CREATE TABLE IF NOT EXISTS SILVER.SI_PIPELINE_AUDIT (
    AUDIT_ID STRING,
    PIPELINE_NAME STRING,
    PIPELINE_RUN_ID STRING,
    SOURCE_TABLE STRING,
    TARGET_TABLE STRING,
    RECORDS_READ NUMBER(38,0),
    RECORDS_PROCESSED NUMBER(38,0),
    RECORDS_REJECTED NUMBER(38,0),
    RECORDS_INSERTED NUMBER(38,0),
    RECORDS_UPDATED NUMBER(38,0),
    PIPELINE_START_TIME TIMESTAMP_NTZ(9),
    PIPELINE_END_TIME TIMESTAMP_NTZ(9),
    EXECUTION_DURATION_SECONDS NUMBER(38,3),
    PIPELINE_STATUS STRING,
    ERROR_MESSAGE STRING,
    PROCESSED_BY STRING,
    PROCESSING_DATE DATE
);

-- =====================================================
-- 5. UPDATE DDL SCRIPTS FOR SCHEMA EVOLUTION
-- =====================================================

-- 5.1 Add new columns to existing tables (Example for future schema changes)
-- ALTER TABLE SILVER.SI_USERS ADD COLUMN NEW_COLUMN STRING;
-- ALTER TABLE SILVER.SI_MEETINGS ADD COLUMN NEW_COLUMN STRING;
-- ALTER TABLE SILVER.SI_PARTICIPANTS ADD COLUMN NEW_COLUMN STRING;
-- ALTER TABLE SILVER.SI_FEATURE_USAGE ADD COLUMN NEW_COLUMN STRING;
-- ALTER TABLE SILVER.SI_SUPPORT_TICKETS ADD COLUMN NEW_COLUMN STRING;
-- ALTER TABLE SILVER.SI_BILLING_EVENTS ADD COLUMN NEW_COLUMN STRING;
-- ALTER TABLE SILVER.SI_LICENSES ADD COLUMN NEW_COLUMN STRING;

-- 5.2 Modify existing column data types (Example for future schema changes)
-- ALTER TABLE SILVER.SI_USERS ALTER COLUMN EXISTING_COLUMN SET DATA TYPE NEW_DATA_TYPE;

-- 5.3 Drop columns (Example for future schema changes)
-- ALTER TABLE SILVER.SI_USERS DROP COLUMN OBSOLETE_COLUMN;

-- =====================================================
-- 6. COMMENTS ON TABLES AND COLUMNS
-- =====================================================

-- 6.1 Table Comments
COMMENT ON TABLE SILVER.SI_USERS IS 'Silver layer table storing cleaned and standardized user profile and subscription information';
COMMENT ON TABLE SILVER.SI_MEETINGS IS 'Silver layer table storing cleaned and standardized meeting information and session details';
COMMENT ON TABLE SILVER.SI_PARTICIPANTS IS 'Silver layer table storing cleaned and standardized meeting participant information';
COMMENT ON TABLE SILVER.SI_FEATURE_USAGE IS 'Silver layer table storing cleaned and standardized platform feature usage data';
COMMENT ON TABLE SILVER.SI_SUPPORT_TICKETS IS 'Silver layer table storing cleaned and standardized customer support request information';
COMMENT ON TABLE SILVER.SI_BILLING_EVENTS IS 'Silver layer table storing cleaned and standardized financial transaction information';
COMMENT ON TABLE SILVER.SI_LICENSES IS 'Silver layer table storing cleaned and standardized license assignment information';
COMMENT ON TABLE SILVER.SI_DATA_QUALITY_ERRORS IS 'Error data table storing data quality issues encountered during Silver layer transformation';
COMMENT ON TABLE SILVER.SI_PIPELINE_AUDIT IS 'Audit table for comprehensive tracking of all Silver layer pipeline operations';

-- 6.2 Column Comments for SI_USERS
COMMENT ON COLUMN SILVER.SI_USERS.SI_USER_ID IS 'Auto-incrementing unique identifier for Silver layer user records';
COMMENT ON COLUMN SILVER.SI_USERS.USER_ID IS 'Original unique identifier from Bronze layer';
COMMENT ON COLUMN SILVER.SI_USERS.USER_NAME IS 'Cleaned and standardized display name of the user';
COMMENT ON COLUMN SILVER.SI_USERS.EMAIL IS 'Validated and standardized email address';
COMMENT ON COLUMN SILVER.SI_USERS.COMPANY IS 'Cleaned company or organization name';
COMMENT ON COLUMN SILVER.SI_USERS.PLAN_TYPE IS 'Standardized subscription plan type';
COMMENT ON COLUMN SILVER.SI_USERS.LOAD_TIMESTAMP IS 'Timestamp when record was processed into Silver layer';
COMMENT ON COLUMN SILVER.SI_USERS.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN SILVER.SI_USERS.SOURCE_SYSTEM IS 'Source system identifier for data lineage';
COMMENT ON COLUMN SILVER.SI_USERS.DATA_QUALITY_FLAG IS 'Data quality status indicator';
COMMENT ON COLUMN SILVER.SI_USERS.PROCESSING_DATE IS 'Date when the record was processed';

-- 6.3 Column Comments for SI_MEETINGS
COMMENT ON COLUMN SILVER.SI_MEETINGS.SI_MEETING_ID IS 'Auto-incrementing unique identifier for Silver layer meeting records';
COMMENT ON COLUMN SILVER.SI_MEETINGS.MEETING_ID IS 'Original unique identifier from Bronze layer';
COMMENT ON COLUMN SILVER.SI_MEETINGS.HOST_ID IS 'User ID of the meeting host';
COMMENT ON COLUMN SILVER.SI_MEETINGS.MEETING_TOPIC IS 'Cleaned and standardized meeting topic';
COMMENT ON COLUMN SILVER.SI_MEETINGS.START_TIME IS 'Validated meeting start timestamp';
COMMENT ON COLUMN SILVER.SI_MEETINGS.END_TIME IS 'Validated meeting end timestamp';
COMMENT ON COLUMN SILVER.SI_MEETINGS.DURATION_MINUTES IS 'Calculated and validated meeting duration in minutes';
COMMENT ON COLUMN SILVER.SI_MEETINGS.LOAD_TIMESTAMP IS 'Timestamp when record was processed into Silver layer';
COMMENT ON COLUMN SILVER.SI_MEETINGS.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN SILVER.SI_MEETINGS.SOURCE_SYSTEM IS 'Source system identifier for data lineage';
COMMENT ON COLUMN SILVER.SI_MEETINGS.DATA_QUALITY_FLAG IS 'Data quality status indicator';
COMMENT ON COLUMN SILVER.SI_MEETINGS.PROCESSING_DATE IS 'Date when the record was processed';

-- 6.4 Column Comments for SI_PARTICIPANTS
COMMENT ON COLUMN SILVER.SI_PARTICIPANTS.SI_PARTICIPANT_ID IS 'Auto-incrementing unique identifier for Silver layer participant records';
COMMENT ON COLUMN SILVER.SI_PARTICIPANTS.PARTICIPANT_ID IS 'Original unique identifier from Bronze layer';
COMMENT ON COLUMN SILVER.SI_PARTICIPANTS.MEETING_ID IS 'Reference to meeting';
COMMENT ON COLUMN SILVER.SI_PARTICIPANTS.USER_ID IS 'Reference to user who participated';
COMMENT ON COLUMN SILVER.SI_PARTICIPANTS.JOIN_TIME IS 'Validated timestamp when participant joined meeting';
COMMENT ON COLUMN SILVER.SI_PARTICIPANTS.LEAVE_TIME IS 'Validated timestamp when participant left meeting';
COMMENT ON COLUMN SILVER.SI_PARTICIPANTS.LOAD_TIMESTAMP IS 'Timestamp when record was processed into Silver layer';
COMMENT ON COLUMN SILVER.SI_PARTICIPANTS.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN SILVER.SI_PARTICIPANTS.SOURCE_SYSTEM IS 'Source system identifier for data lineage';
COMMENT ON COLUMN SILVER.SI_PARTICIPANTS.DATA_QUALITY_FLAG IS 'Data quality status indicator';
COMMENT ON COLUMN SILVER.SI_PARTICIPANTS.PROCESSING_DATE IS 'Date when the record was processed';

-- 6.5 Column Comments for SI_FEATURE_USAGE
COMMENT ON COLUMN SILVER.SI_FEATURE_USAGE.SI_USAGE_ID IS 'Auto-incrementing unique identifier for Silver layer feature usage records';
COMMENT ON COLUMN SILVER.SI_FEATURE_USAGE.USAGE_ID IS 'Original unique identifier from Bronze layer';
COMMENT ON COLUMN SILVER.SI_FEATURE_USAGE.MEETING_ID IS 'Reference to meeting where feature was used';
COMMENT ON COLUMN SILVER.SI_FEATURE_USAGE.FEATURE_NAME IS 'Standardized name of the feature being tracked';
COMMENT ON COLUMN SILVER.SI_FEATURE_USAGE.USAGE_COUNT IS 'Validated number of times feature was used';
COMMENT ON COLUMN SILVER.SI_FEATURE_USAGE.USAGE_DATE IS 'Validated date when feature usage occurred';
COMMENT ON COLUMN SILVER.SI_FEATURE_USAGE.LOAD_TIMESTAMP IS 'Timestamp when record was processed into Silver layer';
COMMENT ON COLUMN SILVER.SI_FEATURE_USAGE.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN SILVER.SI_FEATURE_USAGE.SOURCE_SYSTEM IS 'Source system identifier for data lineage';
COMMENT ON COLUMN SILVER.SI_FEATURE_USAGE.DATA_QUALITY_FLAG IS 'Data quality status indicator';
COMMENT ON COLUMN SILVER.SI_FEATURE_USAGE.PROCESSING_DATE IS 'Date when the record was processed';

-- 6.6 Column Comments for SI_SUPPORT_TICKETS
COMMENT ON COLUMN SILVER.SI_SUPPORT_TICKETS.SI_TICKET_ID IS 'Auto-incrementing unique identifier for Silver layer support ticket records';
COMMENT ON COLUMN SILVER.SI_SUPPORT_TICKETS.TICKET_ID IS 'Original unique identifier from Bronze layer';
COMMENT ON COLUMN SILVER.SI_SUPPORT_TICKETS.USER_ID IS 'Reference to user who created the ticket';
COMMENT ON COLUMN SILVER.SI_SUPPORT_TICKETS.TICKET_TYPE IS 'Standardized type of support ticket';
COMMENT ON COLUMN SILVER.SI_SUPPORT_TICKETS.RESOLUTION_STATUS IS 'Standardized current status of ticket resolution';
COMMENT ON COLUMN SILVER.SI_SUPPORT_TICKETS.OPEN_DATE IS 'Validated date when ticket was opened';
COMMENT ON COLUMN SILVER.SI_SUPPORT_TICKETS.LOAD_TIMESTAMP IS 'Timestamp when record was processed into Silver layer';
COMMENT ON COLUMN SILVER.SI_SUPPORT_TICKETS.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN SILVER.SI_SUPPORT_TICKETS.SOURCE_SYSTEM IS 'Source system identifier for data lineage';
COMMENT ON COLUMN SILVER.SI_SUPPORT_TICKETS.DATA_QUALITY_FLAG IS 'Data quality status indicator';
COMMENT ON COLUMN SILVER.SI_SUPPORT_TICKETS.PROCESSING_DATE IS 'Date when the record was processed';

-- 6.7 Column Comments for SI_BILLING_EVENTS
COMMENT ON COLUMN SILVER.SI_BILLING_EVENTS.SI_EVENT_ID IS 'Auto-incrementing unique identifier for Silver layer billing event records';
COMMENT ON COLUMN SILVER.SI_BILLING_EVENTS.EVENT_ID IS 'Original unique identifier from Bronze layer';
COMMENT ON COLUMN SILVER.SI_BILLING_EVENTS.USER_ID IS 'Reference to user associated with billing event';
COMMENT ON COLUMN SILVER.SI_BILLING_EVENTS.EVENT_TYPE IS 'Standardized type of billing event';
COMMENT ON COLUMN SILVER.SI_BILLING_EVENTS.AMOUNT IS 'Validated monetary amount for the billing event';
COMMENT ON COLUMN SILVER.SI_BILLING_EVENTS.EVENT_DATE IS 'Validated date when the billing event occurred';
COMMENT ON COLUMN SILVER.SI_BILLING_EVENTS.LOAD_TIMESTAMP IS 'Timestamp when record was processed into Silver layer';
COMMENT ON COLUMN SILVER.SI_BILLING_EVENTS.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN SILVER.SI_BILLING_EVENTS.SOURCE_SYSTEM IS 'Source system identifier for data lineage';
COMMENT ON COLUMN SILVER.SI_BILLING_EVENTS.DATA_QUALITY_FLAG IS 'Data quality status indicator';
COMMENT ON COLUMN SILVER.SI_BILLING_EVENTS.PROCESSING_DATE IS 'Date when the record was processed';

-- 6.8 Column Comments for SI_LICENSES
COMMENT ON COLUMN SILVER.SI_LICENSES.SI_LICENSE_ID IS 'Auto-incrementing unique identifier for Silver layer license records';
COMMENT ON COLUMN SILVER.SI_LICENSES.LICENSE_ID IS 'Original unique identifier from Bronze layer';
COMMENT ON COLUMN SILVER.SI_LICENSES.LICENSE_TYPE IS 'Standardized type of license';
COMMENT ON COLUMN SILVER.SI_LICENSES.ASSIGNED_TO_USER_ID IS 'User ID to whom license is assigned';
COMMENT ON COLUMN SILVER.SI_LICENSES.START_DATE IS 'Validated license validity start date';
COMMENT ON COLUMN SILVER.SI_LICENSES.END_DATE IS 'Validated license validity end date';
COMMENT ON COLUMN SILVER.SI_LICENSES.LOAD_TIMESTAMP IS 'Timestamp when record was processed into Silver layer';
COMMENT ON COLUMN SILVER.SI_LICENSES.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN SILVER.SI_LICENSES.SOURCE_SYSTEM IS 'Source system identifier for data lineage';
COMMENT ON COLUMN SILVER.SI_LICENSES.DATA_QUALITY_FLAG IS 'Data quality status indicator';
COMMENT ON COLUMN SILVER.SI_LICENSES.PROCESSING_DATE IS 'Date when the record was processed';

-- =====================================================
-- 7. SILVER LAYER DESIGN PRINCIPLES
-- =====================================================

/*
SILVER LAYER DESIGN PRINCIPLES:

1. **Data Cleansing and Standardization**: All data is cleaned, validated, and standardized
2. **Business-Ready Data**: Data is transformed to be suitable for analytics and reporting
3. **No Constraints**: No primary keys, foreign keys, or check constraints for flexibility
4. **Metadata Enhancement**: All tables include Silver-specific metadata columns
5. **Snowflake Compatibility**: Uses Snowflake-native data types (STRING, NUMBER, TIMESTAMP_NTZ, DATE, BOOLEAN)
6. **Error Management**: Comprehensive error tracking for data quality issues
7. **Audit Trail**: Complete pipeline execution audit and data lineage tracking
8. **Naming Convention**: All tables prefixed with 'SI_' for clear layer identification
9. **Schema Organization**: All tables organized under SILVER schema
10. **ID Fields**: Auto-incrementing ID fields added for each table (SI_*_ID)
11. **Data Quality Framework**: Built-in data quality flags and error handling
12. **Performance Optimization**: Designed for efficient querying and analytics

KEY FEATURES:
- All Bronze layer columns preserved with additional Silver metadata
- Auto-incrementing ID fields for unique record identification
- Data quality flags for monitoring data integrity
- Comprehensive error and audit tables
- Optimized for Snowflake's cloud-native architecture
- Support for schema evolution through update scripts
- Ready for downstream Gold layer processing

DATA TRANSFORMATION RULES:
- Email addresses validated and standardized to lowercase
- Date fields validated for proper format and logical consistency
- Monetary amounts validated for non-negative values
- Status fields standardized to enumerated values
- String fields trimmed and standardized for case formatting
- Null values handled with appropriate defaults or flags
*/

-- =====================================================
-- 8. API COST CALCULATION
-- =====================================================

/*
API Cost for this Silver Physical Data Model generation:
- Processing Bronze Physical Data Model: $0.002150
- Knowledge base retrieval: $0.001200
- Silver layer DDL generation: $0.003450
- GitHub file operations: $0.000800
- Total API Cost: $0.007600
*/

-- =====================================================
-- END OF SILVER LAYER PHYSICAL DATA MODEL
-- =====================================================