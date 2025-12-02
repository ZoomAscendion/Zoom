_____________________________________________
## *Author*: AAVA
## *Created on*: 2025-12-02
## *Description*: Bronze layer physical data model DDL scripts for Zoom Platform Analytics System
## *Version*: 2 
## *Updated on*: 2025-12-02
## *Changes*: Updated data types from STRING to VARCHAR(100) to align with logical model optimization and improve storage efficiency
## *Reason*: Optimize storage and improve performance by using specific VARCHAR lengths instead of generic STRING types
_____________________________________________

-- =====================================================
-- BRONZE LAYER PHYSICAL DATA MODEL DDL SCRIPTS
-- Zoom Platform Analytics System
-- Compatible with Snowflake SQL
-- =====================================================

-- =====================================================
-- 1. BRONZE LAYER TABLE CREATION
-- =====================================================

-- 1.1 Bronze Users Table
CREATE TABLE IF NOT EXISTS Bronze.bz_users (
    USER_ID VARCHAR(100),
    USER_NAME VARCHAR(100),
    EMAIL VARCHAR(100),
    COMPANY VARCHAR(100),
    PLAN_TYPE VARCHAR(100),
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM VARCHAR(100)
);

-- 1.2 Bronze Meetings Table
CREATE TABLE IF NOT EXISTS Bronze.bz_meetings (
    MEETING_ID VARCHAR(100),
    HOST_ID VARCHAR(100),
    MEETING_TOPIC VARCHAR(100),
    START_TIME TIMESTAMP_NTZ,
    END_TIME VARCHAR(100),
    DURATION_MINUTES VARCHAR(100),
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM VARCHAR(100)
);

-- 1.3 Bronze Participants Table
CREATE TABLE IF NOT EXISTS Bronze.bz_participants (
    PARTICIPANT_ID VARCHAR(100),
    MEETING_ID VARCHAR(100),
    USER_ID VARCHAR(100),
    JOIN_TIME VARCHAR(100),
    LEAVE_TIME TIMESTAMP_NTZ,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM VARCHAR(100)
);

-- 1.4 Bronze Feature Usage Table
CREATE TABLE IF NOT EXISTS Bronze.bz_feature_usage (
    USAGE_ID VARCHAR(100),
    MEETING_ID VARCHAR(100),
    FEATURE_NAME VARCHAR(100),
    USAGE_COUNT NUMBER(38,0),
    USAGE_DATE DATE,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM VARCHAR(100)
);

-- 1.5 Bronze Support Tickets Table
CREATE TABLE IF NOT EXISTS Bronze.bz_support_tickets (
    TICKET_ID VARCHAR(100),
    USER_ID VARCHAR(100),
    TICKET_TYPE VARCHAR(100),
    RESOLUTION_STATUS VARCHAR(100),
    OPEN_DATE DATE,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM VARCHAR(100)
);

-- 1.6 Bronze Billing Events Table
CREATE TABLE IF NOT EXISTS Bronze.bz_billing_events (
    EVENT_ID VARCHAR(100),
    USER_ID VARCHAR(100),
    EVENT_TYPE VARCHAR(100),
    AMOUNT VARCHAR(100),
    EVENT_DATE DATE,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM VARCHAR(100)
);

-- 1.7 Bronze Licenses Table
CREATE TABLE IF NOT EXISTS Bronze.bz_licenses (
    LICENSE_ID VARCHAR(100),
    LICENSE_TYPE VARCHAR(100),
    ASSIGNED_TO_USER_ID VARCHAR(100),
    START_DATE DATE,
    END_DATE VARCHAR(100),
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM VARCHAR(100)
);

-- =====================================================
-- 2. AUDIT TABLE CREATION
-- =====================================================

-- 2.1 Bronze Audit Log Table
CREATE TABLE IF NOT EXISTS Bronze.bz_audit_log (
    RECORD_ID NUMBER AUTOINCREMENT,
    SOURCE_TABLE VARCHAR(100),
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    PROCESSED_BY VARCHAR(100),
    PROCESSING_TIME NUMBER,
    STATUS VARCHAR(100)
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
COMMENT ON COLUMN Bronze.bz_users.USER_ID IS 'Unique identifier for each user account';
COMMENT ON COLUMN Bronze.bz_users.USER_NAME IS 'Display name of the user for identification purposes';
COMMENT ON COLUMN Bronze.bz_users.EMAIL IS 'User email address for communication and authentication';
COMMENT ON COLUMN Bronze.bz_users.COMPANY IS 'Company or organization associated with the user';
COMMENT ON COLUMN Bronze.bz_users.PLAN_TYPE IS 'Subscription plan type (Basic, Pro, Business, Enterprise)';
COMMENT ON COLUMN Bronze.bz_users.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_users.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_users.SOURCE_SYSTEM IS 'Source system identifier for data lineage tracking';

-- 4.2 Meetings Table Column Comments
COMMENT ON COLUMN Bronze.bz_meetings.MEETING_ID IS 'Unique identifier for each meeting';
COMMENT ON COLUMN Bronze.bz_meetings.HOST_ID IS 'User ID of the meeting host';
COMMENT ON COLUMN Bronze.bz_meetings.MEETING_TOPIC IS 'Topic or title of the meeting';
COMMENT ON COLUMN Bronze.bz_meetings.START_TIME IS 'Timestamp when the meeting started';
COMMENT ON COLUMN Bronze.bz_meetings.END_TIME IS 'Timestamp when the meeting ended';
COMMENT ON COLUMN Bronze.bz_meetings.DURATION_MINUTES IS 'Duration of the meeting in minutes';
COMMENT ON COLUMN Bronze.bz_meetings.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_meetings.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_meetings.SOURCE_SYSTEM IS 'Source system identifier for data lineage tracking';

-- 4.3 Participants Table Column Comments
COMMENT ON COLUMN Bronze.bz_participants.PARTICIPANT_ID IS 'Unique identifier for each participant session';
COMMENT ON COLUMN Bronze.bz_participants.MEETING_ID IS 'Identifier linking to the meeting';
COMMENT ON COLUMN Bronze.bz_participants.USER_ID IS 'Identifier of the user who participated';
COMMENT ON COLUMN Bronze.bz_participants.JOIN_TIME IS 'Timestamp when participant joined the meeting';
COMMENT ON COLUMN Bronze.bz_participants.LEAVE_TIME IS 'Timestamp when participant left the meeting';
COMMENT ON COLUMN Bronze.bz_participants.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_participants.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_participants.SOURCE_SYSTEM IS 'Source system identifier for data lineage tracking';

-- 4.4 Feature Usage Table Column Comments
COMMENT ON COLUMN Bronze.bz_feature_usage.USAGE_ID IS 'Unique identifier for each feature usage record';
COMMENT ON COLUMN Bronze.bz_feature_usage.MEETING_ID IS 'Identifier linking to the meeting where feature was used';
COMMENT ON COLUMN Bronze.bz_feature_usage.FEATURE_NAME IS 'Name of the feature that was used';
COMMENT ON COLUMN Bronze.bz_feature_usage.USAGE_COUNT IS 'Number of times the feature was used in the session';
COMMENT ON COLUMN Bronze.bz_feature_usage.USAGE_DATE IS 'Date when the feature usage occurred';
COMMENT ON COLUMN Bronze.bz_feature_usage.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_feature_usage.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_feature_usage.SOURCE_SYSTEM IS 'Source system identifier for data lineage tracking';

-- 4.5 Support Tickets Table Column Comments
COMMENT ON COLUMN Bronze.bz_support_tickets.TICKET_ID IS 'Unique identifier for each support ticket';
COMMENT ON COLUMN Bronze.bz_support_tickets.USER_ID IS 'Identifier of the user who created the support ticket';
COMMENT ON COLUMN Bronze.bz_support_tickets.TICKET_TYPE IS 'Category of the support ticket';
COMMENT ON COLUMN Bronze.bz_support_tickets.RESOLUTION_STATUS IS 'Current status of the ticket resolution';
COMMENT ON COLUMN Bronze.bz_support_tickets.OPEN_DATE IS 'Date when the support ticket was opened';
COMMENT ON COLUMN Bronze.bz_support_tickets.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_support_tickets.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_support_tickets.SOURCE_SYSTEM IS 'Source system identifier for data lineage tracking';

-- 4.6 Billing Events Table Column Comments
COMMENT ON COLUMN Bronze.bz_billing_events.EVENT_ID IS 'Unique identifier for each billing event';
COMMENT ON COLUMN Bronze.bz_billing_events.USER_ID IS 'Identifier linking to the user who generated the billing event';
COMMENT ON COLUMN Bronze.bz_billing_events.EVENT_TYPE IS 'Type of billing event (subscription, usage, etc.)';
COMMENT ON COLUMN Bronze.bz_billing_events.AMOUNT IS 'Monetary amount associated with the billing event';
COMMENT ON COLUMN Bronze.bz_billing_events.EVENT_DATE IS 'Date when the billing event occurred';
COMMENT ON COLUMN Bronze.bz_billing_events.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_billing_events.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_billing_events.SOURCE_SYSTEM IS 'Source system identifier for data lineage tracking';

-- 4.7 Licenses Table Column Comments
COMMENT ON COLUMN Bronze.bz_licenses.LICENSE_ID IS 'Unique identifier for each license';
COMMENT ON COLUMN Bronze.bz_licenses.LICENSE_TYPE IS 'Type of license (Basic, Pro, Business, Enterprise)';
COMMENT ON COLUMN Bronze.bz_licenses.ASSIGNED_TO_USER_ID IS 'User ID to whom the license is assigned';
COMMENT ON COLUMN Bronze.bz_licenses.START_DATE IS 'Date when the license becomes active';
COMMENT ON COLUMN Bronze.bz_licenses.END_DATE IS 'Date when the license expires';
COMMENT ON COLUMN Bronze.bz_licenses.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_licenses.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_licenses.SOURCE_SYSTEM IS 'Source system identifier for data lineage tracking';

-- 4.8 Audit Log Table Column Comments
COMMENT ON COLUMN Bronze.bz_audit_log.RECORD_ID IS 'Auto-incrementing unique identifier for each audit record';
COMMENT ON COLUMN Bronze.bz_audit_log.SOURCE_TABLE IS 'Name of the source table being processed';
COMMENT ON COLUMN Bronze.bz_audit_log.LOAD_TIMESTAMP IS 'Timestamp when the data processing operation was initiated';
COMMENT ON COLUMN Bronze.bz_audit_log.PROCESSED_BY IS 'Identifier of the system, user, or process that performed the operation';
COMMENT ON COLUMN Bronze.bz_audit_log.PROCESSING_TIME IS 'Duration of the processing operation in seconds';
COMMENT ON COLUMN Bronze.bz_audit_log.STATUS IS 'Status of the processing operation (SUCCESS, FAILED, IN_PROGRESS, PARTIAL)';

-- =====================================================
-- 5. BRONZE LAYER DESIGN NOTES
-- =====================================================

/*
BRONZE LAYER DESIGN PRINCIPLES:

1. RAW DATA PRESERVATION:
   - All tables store data as-is from source systems
   - No data transformations or business logic applied
   - Original data types preserved where possible

2. SNOWFLAKE COMPATIBILITY:
   - Uses Snowflake-supported data types (VARCHAR, NUMBER, DATE, TIMESTAMP_NTZ)
   - No primary keys, foreign keys, or constraints defined
   - Compatible with Snowflake's micro-partitioned storage

3. METADATA TRACKING:
   - All tables include standard metadata columns:
     * LOAD_TIMESTAMP: When record was initially loaded
     * UPDATE_TIMESTAMP: When record was last updated
     * SOURCE_SYSTEM: Source system identifier for lineage

4. AUDIT CAPABILITIES:
   - Dedicated audit table (bz_audit_log) for tracking processing activities
   - Comprehensive logging for data governance and compliance

5. TABLE NAMING CONVENTION:
   - All Bronze layer tables prefixed with 'bz_'
   - Schema name: Bronze
   - Follows medallion architecture standards

6. DATA TYPES RATIONALE:
   - VARCHAR(100): Optimized for typical business data lengths
   - NUMBER(38,0): For integer values with Snowflake precision
   - DATE: For date-only fields
   - TIMESTAMP_NTZ: For timestamp fields without timezone

7. SCALABILITY CONSIDERATIONS:
   - Tables designed for high-volume data ingestion
   - No constraints to avoid ingestion bottlenecks
   - Optimized for Snowflake's columnar storage format

8. COMPLIANCE AND SECURITY:
   - PII fields identified in logical model documentation
   - Ready for masking policies and row-level security implementation
   - Audit trail supports regulatory compliance requirements

9. PERFORMANCE OPTIMIZATION:
   - VARCHAR(100) provides better storage efficiency than generic STRING
   - Reduced memory footprint improves query performance
   - Maintains data integrity while optimizing resource usage
*/

-- =====================================================
-- 6. VERSION HISTORY AND CHANGES
-- =====================================================

/*
VERSION 2 CHANGES:
- Updated all STRING data types to VARCHAR(100) for better storage efficiency
- Aligned with Bronze Logical Data Model version 3 specifications
- Improved performance characteristics while maintaining data integrity
- Enhanced compatibility with Snowflake best practices
- Maintained all existing functionality and structure

REASON FOR CHANGES:
- Storage optimization: VARCHAR(100) uses less storage than generic STRING
- Performance improvement: Specific length constraints improve query performance
- Consistency: Aligns physical model with logical model specifications
- Best practices: Follows Snowflake recommendations for data type usage
*/

-- =====================================================
-- END OF BRONZE LAYER PHYSICAL DATA MODEL
-- =====================================================