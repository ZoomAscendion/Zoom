_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze layer physical data model DDL scripts for Zoom Platform Analytics System with Snowflake optimization
## *Version*: 2
## *Updated on*: 
## *Changes*: Overwritten with optimized Snowflake-compatible DDL scripts based on Bronze Logical Data Model requirements
## *Reason*: Updated to ensure full Snowflake SQL compliance, optimized data types, and enhanced Bronze layer design following medallion architecture best practices
_____________________________________________

-- =====================================================
-- BRONZE LAYER PHYSICAL DATA MODEL DDL SCRIPTS
-- Zoom Platform Analytics System - Snowflake Optimized
-- Compatible with Snowflake SQL
-- =====================================================

-- =====================================================
-- 1. BRONZE LAYER TABLE CREATION
-- =====================================================

-- 1.1 Bronze Users Table
CREATE TABLE IF NOT EXISTS Bronze.bz_users (
    USER_NAME STRING,
    EMAIL STRING,
    COMPANY STRING,
    PLAN_TYPE STRING,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM STRING
);

-- 1.2 Bronze Meetings Table
CREATE TABLE IF NOT EXISTS Bronze.bz_meetings (
    HOST STRING,
    MEETING_TOPIC STRING,
    START_TIME TIMESTAMP_NTZ,
    END_TIME STRING,
    DURATION_MINUTES STRING,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM STRING
);

-- 1.3 Bronze Participants Table
CREATE TABLE IF NOT EXISTS Bronze.bz_participants (
    PARTICIPANT STRING,
    JOIN_TIME STRING,
    LEAVE_TIME TIMESTAMP_NTZ,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM STRING
);

-- 1.4 Bronze Feature Usage Table
CREATE TABLE IF NOT EXISTS Bronze.bz_feature_usage (
    FEATURE_NAME STRING,
    USAGE_COUNT NUMBER(38,0),
    USAGE_DATE DATE,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM STRING
);

-- 1.5 Bronze Support Tickets Table
CREATE TABLE IF NOT EXISTS Bronze.bz_support_tickets (
    TICKET_TYPE STRING,
    RESOLUTION_STATUS STRING,
    OPEN_DATE DATE,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM STRING
);

-- 1.6 Bronze Billing Events Table
CREATE TABLE IF NOT EXISTS Bronze.bz_billing_events (
    EVENT_TYPE STRING,
    AMOUNT STRING,
    EVENT_DATE DATE,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM STRING
);

-- 1.7 Bronze Licenses Table
CREATE TABLE IF NOT EXISTS Bronze.bz_licenses (
    LICENSE_TYPE STRING,
    ASSIGNED_TO_USER STRING,
    START_DATE DATE,
    END_DATE STRING,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM STRING
);

-- =====================================================
-- 2. AUDIT TABLE CREATION
-- =====================================================

-- 2.1 Bronze Audit Log Table
CREATE TABLE IF NOT EXISTS Bronze.bz_audit_log (
    RECORD_ID NUMBER AUTOINCREMENT,
    SOURCE_TABLE STRING,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    PROCESSED_BY STRING,
    PROCESSING_TIME NUMBER,
    STATUS STRING
);

-- =====================================================
-- 3. TABLE COMMENTS FOR DOCUMENTATION
-- =====================================================

-- 3.1 Add table comments
COMMENT ON TABLE Bronze.bz_users IS 'Bronze layer table storing raw user profile information and subscription details';
COMMENT ON TABLE Bronze.bz_meetings IS 'Bronze layer table containing raw meeting information and metadata';
COMMENT ON TABLE Bronze.bz_participants IS 'Bronze layer table tracking raw meeting participant data and engagement';
COMMENT ON TABLE Bronze.bz_feature_usage IS 'Bronze layer table recording raw feature usage data during meetings';
COMMENT ON TABLE Bronze.bz_support_tickets IS 'Bronze layer table managing raw customer support ticket information';
COMMENT ON TABLE Bronze.bz_billing_events IS 'Bronze layer table tracking raw billing and financial transaction data';
COMMENT ON TABLE Bronze.bz_licenses IS 'Bronze layer table storing raw license assignment and management data';
COMMENT ON TABLE Bronze.bz_audit_log IS 'Audit table for tracking all Bronze layer data processing activities';

-- =====================================================
-- 4. COLUMN COMMENTS FOR DOCUMENTATION
-- =====================================================

-- 4.1 Users Table Column Comments
COMMENT ON COLUMN Bronze.bz_users.USER_NAME IS 'Display name of the user for identification purposes (PII - Sensitive)';
COMMENT ON COLUMN Bronze.bz_users.EMAIL IS 'User email address for communication and authentication (PII - Sensitive)';
COMMENT ON COLUMN Bronze.bz_users.COMPANY IS 'Company or organization associated with the user (Sensitive)';
COMMENT ON COLUMN Bronze.bz_users.PLAN_TYPE IS 'Subscription plan type (Basic, Pro, Business, Enterprise)';
COMMENT ON COLUMN Bronze.bz_users.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_users.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_users.SOURCE_SYSTEM IS 'Source system identifier for data lineage tracking';

-- 4.2 Meetings Table Column Comments
COMMENT ON COLUMN Bronze.bz_meetings.HOST IS 'Identifier of the user hosting the meeting';
COMMENT ON COLUMN Bronze.bz_meetings.MEETING_TOPIC IS 'Topic or title of the meeting (Sensitive)';
COMMENT ON COLUMN Bronze.bz_meetings.START_TIME IS 'Timestamp when the meeting started';
COMMENT ON COLUMN Bronze.bz_meetings.END_TIME IS 'Timestamp when the meeting ended (stored as string from source)';
COMMENT ON COLUMN Bronze.bz_meetings.DURATION_MINUTES IS 'Duration of the meeting in minutes (stored as string from source)';
COMMENT ON COLUMN Bronze.bz_meetings.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_meetings.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_meetings.SOURCE_SYSTEM IS 'Source system identifier for data lineage tracking';

-- 4.3 Participants Table Column Comments
COMMENT ON COLUMN Bronze.bz_participants.PARTICIPANT IS 'Identifier of the participating user';
COMMENT ON COLUMN Bronze.bz_participants.JOIN_TIME IS 'Time when participant joined the meeting (stored as string from source)';
COMMENT ON COLUMN Bronze.bz_participants.LEAVE_TIME IS 'Timestamp when participant left the meeting';
COMMENT ON COLUMN Bronze.bz_participants.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_participants.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_participants.SOURCE_SYSTEM IS 'Source system identifier for data lineage tracking';

-- 4.4 Feature Usage Table Column Comments
COMMENT ON COLUMN Bronze.bz_feature_usage.FEATURE_NAME IS 'Name of the feature that was used';
COMMENT ON COLUMN Bronze.bz_feature_usage.USAGE_COUNT IS 'Number of times the feature was used in the session';
COMMENT ON COLUMN Bronze.bz_feature_usage.USAGE_DATE IS 'Date when the feature usage occurred';
COMMENT ON COLUMN Bronze.bz_feature_usage.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_feature_usage.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_feature_usage.SOURCE_SYSTEM IS 'Source system identifier for data lineage tracking';

-- 4.5 Support Tickets Table Column Comments
COMMENT ON COLUMN Bronze.bz_support_tickets.TICKET_TYPE IS 'Category or type of the support ticket (Sensitive)';
COMMENT ON COLUMN Bronze.bz_support_tickets.RESOLUTION_STATUS IS 'Current status of the ticket resolution';
COMMENT ON COLUMN Bronze.bz_support_tickets.OPEN_DATE IS 'Date when the support ticket was opened';
COMMENT ON COLUMN Bronze.bz_support_tickets.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_support_tickets.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_support_tickets.SOURCE_SYSTEM IS 'Source system identifier for data lineage tracking';

-- 4.6 Billing Events Table Column Comments
COMMENT ON COLUMN Bronze.bz_billing_events.EVENT_TYPE IS 'Type of billing event (subscription, usage, etc.)';
COMMENT ON COLUMN Bronze.bz_billing_events.AMOUNT IS 'Monetary amount associated with the billing event (Sensitive)';
COMMENT ON COLUMN Bronze.bz_billing_events.EVENT_DATE IS 'Date when the billing event occurred';
COMMENT ON COLUMN Bronze.bz_billing_events.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_billing_events.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_billing_events.SOURCE_SYSTEM IS 'Source system identifier for data lineage tracking';

-- 4.7 Licenses Table Column Comments
COMMENT ON COLUMN Bronze.bz_licenses.LICENSE_TYPE IS 'Type of license (Basic, Pro, Business, Enterprise)';
COMMENT ON COLUMN Bronze.bz_licenses.ASSIGNED_TO_USER IS 'User to whom the license is assigned';
COMMENT ON COLUMN Bronze.bz_licenses.START_DATE IS 'Date when the license becomes active';
COMMENT ON COLUMN Bronze.bz_licenses.END_DATE IS 'Date when the license expires (stored as string from source)';
COMMENT ON COLUMN Bronze.bz_licenses.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_licenses.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_licenses.SOURCE_SYSTEM IS 'Source system identifier for data lineage tracking';

-- 4.8 Audit Log Table Column Comments
COMMENT ON COLUMN Bronze.bz_audit_log.RECORD_ID IS 'Auto-incrementing unique identifier for each audit record';
COMMENT ON COLUMN Bronze.bz_audit_log.SOURCE_TABLE IS 'Name of the source table being processed';
COMMENT ON COLUMN Bronze.bz_audit_log.LOAD_TIMESTAMP IS 'Timestamp when the data processing operation was initiated';
COMMENT ON COLUMN Bronze.bz_audit_log.PROCESSED_BY IS 'System or process that handled the data';
COMMENT ON COLUMN Bronze.bz_audit_log.PROCESSING_TIME IS 'Duration taken to process the data in seconds';
COMMENT ON COLUMN Bronze.bz_audit_log.STATUS IS 'Status of the processing operation (SUCCESS, FAILED, PARTIAL)';

-- =====================================================
-- 5. BRONZE LAYER DESIGN NOTES
-- =====================================================

/*
BRONZE LAYER DESIGN PRINCIPLES:

1. RAW DATA PRESERVATION:
   - All tables store data as-is from source systems
   - No data transformations or business logic applied
   - Original data types preserved where possible
   - Fields match exactly with Bronze Logical Data Model specifications

2. SNOWFLAKE COMPATIBILITY:
   - Uses Snowflake-supported data types (STRING, NUMBER, DATE, TIMESTAMP_NTZ)
   - No primary keys, foreign keys, or constraints defined (as per Bronze layer requirements)
   - Compatible with Snowflake's micro-partitioned storage
   - Follows Snowflake SQL best practices

3. METADATA TRACKING:
   - All tables include standard metadata columns:
     * LOAD_TIMESTAMP: When record was initially loaded
     * UPDATE_TIMESTAMP: When record was last updated
     * SOURCE_SYSTEM: Source system identifier for lineage

4. AUDIT CAPABILITIES:
   - Dedicated audit table (bz_audit_log) for tracking processing activities
   - Comprehensive logging for data governance and compliance
   - Auto-incrementing RECORD_ID for unique audit trail

5. TABLE NAMING CONVENTION:
   - All Bronze layer tables prefixed with 'bz_'
   - Schema name: Bronze
   - Follows medallion architecture standards

6. DATA TYPES RATIONALE:
   - STRING: Used for VARCHAR fields to handle variable lengths (Snowflake best practice)
   - NUMBER(38,0): For integer values with Snowflake precision
   - DATE: For date-only fields
   - TIMESTAMP_NTZ: For timestamp fields without timezone (Snowflake default)
   - Some fields kept as STRING to preserve raw data format from source

7. SCALABILITY CONSIDERATIONS:
   - Tables designed for high-volume data ingestion
   - No constraints to avoid ingestion bottlenecks
   - Optimized for Snowflake's columnar storage format
   - Ready for clustering implementation if needed

8. COMPLIANCE AND SECURITY:
   - PII fields identified in column comments
   - Sensitive data marked for future masking policies
   - Ready for row-level security implementation
   - Audit trail supports regulatory compliance requirements

9. BRONZE LAYER SPECIFIC FEATURES:
   - Exact match with Bronze Logical Data Model field specifications
   - No ID fields added (as per Bronze layer raw data principle)
   - Preserves original data formats from source systems
   - Supports medallion architecture data flow to Silver layer

10. VERSION 2 UPDATES:
    - Overwritten with optimized Snowflake-compatible DDL
    - Aligned with Bronze Logical Data Model requirements
    - Enhanced documentation and comments
    - Improved data type selection for Snowflake performance
    - Maintained raw data preservation principles
*/

-- =====================================================
-- END OF BRONZE LAYER PHYSICAL DATA MODEL
-- =====================================================