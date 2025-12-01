_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Enhanced Bronze layer physical data model DDL scripts for Zoom Platform Analytics System with improved data governance and lineage tracking
## *Version*: 2
## *Updated on*: 
## *Changes*: Enhanced data model with data lineage tracking, quality flags, batch processing support, additional business fields, and improved audit capabilities
## *Reason*: Alignment with Bronze Logical Data Model version 3 to support enterprise-grade data governance, security compliance, and operational monitoring
_____________________________________________

-- =====================================================
-- BRONZE LAYER PHYSICAL DATA MODEL DDL SCRIPTS
-- Zoom Platform Analytics System - Enhanced Version
-- Compatible with Snowflake SQL
-- =====================================================

-- =====================================================
-- 1. BRONZE LAYER TABLE CREATION
-- =====================================================

-- 1.1 Bronze Users Table
CREATE TABLE IF NOT EXISTS Bronze.bz_users (
    USER_ID STRING,
    USER_NAME STRING,
    EMAIL STRING,
    COMPANY STRING,
    PLAN_TYPE STRING,
    ACCOUNT_STATUS STRING,
    REGISTRATION_DATE DATE,
    DATA_QUALITY_FLAG STRING,
    DATA_LINEAGE_ID STRING,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM STRING,
    BATCH_ID STRING
);

-- 1.2 Bronze Meetings Table
CREATE TABLE IF NOT EXISTS Bronze.bz_meetings (
    MEETING_ID STRING,
    HOST_ID STRING,
    HOST STRING,
    MEETING_TOPIC STRING,
    START_TIME TIMESTAMP_NTZ,
    END_TIME TIMESTAMP_NTZ,
    DURATION_MINUTES NUMBER(8,0),
    MEETING_TYPE STRING,
    DATA_QUALITY_FLAG STRING,
    DATA_LINEAGE_ID STRING,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM STRING,
    BATCH_ID STRING
);

-- 1.3 Bronze Participants Table
CREATE TABLE IF NOT EXISTS Bronze.bz_participants (
    PARTICIPANT_ID STRING,
    MEETING_ID STRING,
    USER_ID STRING,
    PARTICIPANT STRING,
    JOIN_TIME TIMESTAMP_NTZ,
    LEAVE_TIME TIMESTAMP_NTZ,
    PARTICIPATION_DURATION NUMBER(8,0),
    CONNECTION_TYPE STRING,
    DATA_QUALITY_FLAG STRING,
    DATA_LINEAGE_ID STRING,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM STRING,
    BATCH_ID STRING
);

-- 1.4 Bronze Feature Usage Table
CREATE TABLE IF NOT EXISTS Bronze.bz_feature_usage (
    USAGE_ID STRING,
    MEETING_ID STRING,
    FEATURE_NAME STRING,
    USAGE_COUNT NUMBER(10,0),
    USAGE_DATE DATE,
    SESSION_DURATION NUMBER(10,0),
    DATA_QUALITY_FLAG STRING,
    DATA_LINEAGE_ID STRING,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM STRING,
    BATCH_ID STRING
);

-- 1.5 Bronze Support Tickets Table
CREATE TABLE IF NOT EXISTS Bronze.bz_support_tickets (
    TICKET_ID STRING,
    USER_ID STRING,
    TICKET_TYPE STRING,
    RESOLUTION_STATUS STRING,
    OPEN_DATE DATE,
    PRIORITY_LEVEL STRING,
    CATEGORY STRING,
    SUB_CATEGORY STRING,
    DATA_QUALITY_FLAG STRING,
    DATA_LINEAGE_ID STRING,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM STRING,
    BATCH_ID STRING
);

-- 1.6 Bronze Billing Events Table
CREATE TABLE IF NOT EXISTS Bronze.bz_billing_events (
    EVENT_ID STRING,
    USER_ID STRING,
    EVENT_TYPE STRING,
    AMOUNT NUMBER(15,2),
    EVENT_DATE DATE,
    CURRENCY_CODE STRING,
    DATA_QUALITY_FLAG STRING,
    DATA_LINEAGE_ID STRING,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM STRING,
    BATCH_ID STRING
);

-- 1.7 Bronze Licenses Table
CREATE TABLE IF NOT EXISTS Bronze.bz_licenses (
    LICENSE_ID STRING,
    LICENSE_TYPE STRING,
    ASSIGNED_TO_USER_ID STRING,
    ASSIGNED_TO_USER STRING,
    START_DATE DATE,
    END_DATE DATE,
    LICENSE_STATUS STRING,
    DATA_QUALITY_FLAG STRING,
    DATA_LINEAGE_ID STRING,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM STRING,
    BATCH_ID STRING
);

-- =====================================================
-- 2. ENHANCED AUDIT TABLE CREATION
-- =====================================================

-- 2.1 Bronze Enhanced Audit Log Table
CREATE TABLE IF NOT EXISTS Bronze.bz_audit_log (
    RECORD_ID STRING,
    SOURCE_TABLE STRING,
    OPERATION_TYPE STRING,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    PROCESSED_BY STRING,
    PROCESSING_TIME NUMBER(15,0),
    STATUS STRING,
    RECORDS_PROCESSED NUMBER(15,0),
    RECORDS_FAILED NUMBER(15,0),
    ERROR_MESSAGE STRING,
    ERROR_CODE STRING,
    DATA_QUALITY_SCORE NUMBER(5,2),
    BATCH_ID STRING,
    SOURCE_SYSTEM STRING,
    DATA_LINEAGE_ID STRING,
    COMPLIANCE_FLAG STRING,
    RETENTION_DATE DATE
);

-- =====================================================
-- 3. TABLE COMMENTS FOR DOCUMENTATION
-- =====================================================

-- 3.1 Add enhanced table comments
COMMENT ON TABLE Bronze.bz_users IS 'Enhanced Bronze layer table storing raw user profile information with data governance and lineage tracking';
COMMENT ON TABLE Bronze.bz_meetings IS 'Enhanced Bronze layer table containing raw meeting information with quality monitoring and batch tracking';
COMMENT ON TABLE Bronze.bz_participants IS 'Enhanced Bronze layer table tracking raw meeting participant data with connection type and duration metrics';
COMMENT ON TABLE Bronze.bz_feature_usage IS 'Enhanced Bronze layer table recording raw feature usage data with session duration and quality flags';
COMMENT ON TABLE Bronze.bz_support_tickets IS 'Enhanced Bronze layer table managing raw customer support ticket information with priority and categorization';
COMMENT ON TABLE Bronze.bz_billing_events IS 'Enhanced Bronze layer table tracking raw billing and financial transaction data with currency support';
COMMENT ON TABLE Bronze.bz_licenses IS 'Enhanced Bronze layer table storing raw license assignment and management data with status tracking';
COMMENT ON TABLE Bronze.bz_audit_log IS 'Enhanced audit table for comprehensive tracking of all Bronze layer data processing activities with compliance monitoring';

-- =====================================================
-- 4. ENHANCED COLUMN COMMENTS FOR DOCUMENTATION
-- =====================================================

-- 4.1 Users Table Column Comments
COMMENT ON COLUMN Bronze.bz_users.USER_ID IS 'Unique identifier for each user account';
COMMENT ON COLUMN Bronze.bz_users.USER_NAME IS 'Display name of the user for identification purposes (PII - HIGH security level)';
COMMENT ON COLUMN Bronze.bz_users.EMAIL IS 'User email address for communication and authentication (PII - HIGH security level)';
COMMENT ON COLUMN Bronze.bz_users.COMPANY IS 'Company or organization associated with the user (Sensitive - MEDIUM security level)';
COMMENT ON COLUMN Bronze.bz_users.PLAN_TYPE IS 'Subscription plan type (Basic, Pro, Business, Enterprise) (Sensitive - MEDIUM security level)';
COMMENT ON COLUMN Bronze.bz_users.ACCOUNT_STATUS IS 'Current status of the user account (ACTIVE, INACTIVE, SUSPENDED, DELETED)';
COMMENT ON COLUMN Bronze.bz_users.REGISTRATION_DATE IS 'Date when user account was created for historical tracking';
COMMENT ON COLUMN Bronze.bz_users.DATA_QUALITY_FLAG IS 'Flag indicating data quality status (VALID, INVALID, SUSPECT, PENDING)';
COMMENT ON COLUMN Bronze.bz_users.DATA_LINEAGE_ID IS 'Unique identifier for tracking data lineage and audit trail';
COMMENT ON COLUMN Bronze.bz_users.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_users.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_users.SOURCE_SYSTEM IS 'Source system identifier for data lineage tracking';
COMMENT ON COLUMN Bronze.bz_users.BATCH_ID IS 'Identifier for the data processing batch';

-- 4.2 Meetings Table Column Comments
COMMENT ON COLUMN Bronze.bz_meetings.MEETING_ID IS 'Unique identifier for each meeting';
COMMENT ON COLUMN Bronze.bz_meetings.HOST_ID IS 'User ID of the meeting host (legacy field)';
COMMENT ON COLUMN Bronze.bz_meetings.HOST IS 'Identifier of the user hosting the meeting';
COMMENT ON COLUMN Bronze.bz_meetings.MEETING_TOPIC IS 'Topic or title of the meeting (Sensitive - MEDIUM security level)';
COMMENT ON COLUMN Bronze.bz_meetings.START_TIME IS 'Timestamp when the meeting started';
COMMENT ON COLUMN Bronze.bz_meetings.END_TIME IS 'Timestamp when the meeting ended';
COMMENT ON COLUMN Bronze.bz_meetings.DURATION_MINUTES IS 'Duration of the meeting in minutes (calculated field)';
COMMENT ON COLUMN Bronze.bz_meetings.MEETING_TYPE IS 'Type of meeting (scheduled, instant, recurring)';
COMMENT ON COLUMN Bronze.bz_meetings.DATA_QUALITY_FLAG IS 'Flag indicating data quality status (VALID, INVALID, SUSPECT, PENDING)';
COMMENT ON COLUMN Bronze.bz_meetings.DATA_LINEAGE_ID IS 'Unique identifier for tracking data lineage and audit trail';
COMMENT ON COLUMN Bronze.bz_meetings.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_meetings.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_meetings.SOURCE_SYSTEM IS 'Source system identifier for data lineage tracking';
COMMENT ON COLUMN Bronze.bz_meetings.BATCH_ID IS 'Identifier for the data processing batch';

-- 4.3 Participants Table Column Comments
COMMENT ON COLUMN Bronze.bz_participants.PARTICIPANT_ID IS 'Unique identifier for each participant session';
COMMENT ON COLUMN Bronze.bz_participants.MEETING_ID IS 'Identifier linking to the meeting';
COMMENT ON COLUMN Bronze.bz_participants.USER_ID IS 'Identifier of the user who participated (legacy field)';
COMMENT ON COLUMN Bronze.bz_participants.PARTICIPANT IS 'Identifier of the participating user';
COMMENT ON COLUMN Bronze.bz_participants.JOIN_TIME IS 'Timestamp when participant joined the meeting (Sensitive - LOW security level)';
COMMENT ON COLUMN Bronze.bz_participants.LEAVE_TIME IS 'Timestamp when participant left the meeting (Sensitive - LOW security level)';
COMMENT ON COLUMN Bronze.bz_participants.PARTICIPATION_DURATION IS 'Duration of participation in minutes (calculated field)';
COMMENT ON COLUMN Bronze.bz_participants.CONNECTION_TYPE IS 'Type of connection (audio, video, screen_share)';
COMMENT ON COLUMN Bronze.bz_participants.DATA_QUALITY_FLAG IS 'Flag indicating data quality status (VALID, INVALID, SUSPECT, PENDING)';
COMMENT ON COLUMN Bronze.bz_participants.DATA_LINEAGE_ID IS 'Unique identifier for tracking data lineage and audit trail';
COMMENT ON COLUMN Bronze.bz_participants.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_participants.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_participants.SOURCE_SYSTEM IS 'Source system identifier for data lineage tracking';
COMMENT ON COLUMN Bronze.bz_participants.BATCH_ID IS 'Identifier for the data processing batch';

-- 4.4 Feature Usage Table Column Comments
COMMENT ON COLUMN Bronze.bz_feature_usage.USAGE_ID IS 'Unique identifier for each feature usage record';
COMMENT ON COLUMN Bronze.bz_feature_usage.MEETING_ID IS 'Identifier linking to the meeting where feature was used';
COMMENT ON COLUMN Bronze.bz_feature_usage.FEATURE_NAME IS 'Name of the feature that was used (Sensitive - LOW security level)';
COMMENT ON COLUMN Bronze.bz_feature_usage.USAGE_COUNT IS 'Number of times the feature was used in the session';
COMMENT ON COLUMN Bronze.bz_feature_usage.USAGE_DATE IS 'Date when the feature usage occurred';
COMMENT ON COLUMN Bronze.bz_feature_usage.SESSION_DURATION IS 'Duration of feature usage session in seconds';
COMMENT ON COLUMN Bronze.bz_feature_usage.DATA_QUALITY_FLAG IS 'Flag indicating data quality status (VALID, INVALID, SUSPECT, PENDING)';
COMMENT ON COLUMN Bronze.bz_feature_usage.DATA_LINEAGE_ID IS 'Unique identifier for tracking data lineage and audit trail';
COMMENT ON COLUMN Bronze.bz_feature_usage.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_feature_usage.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_feature_usage.SOURCE_SYSTEM IS 'Source system identifier for data lineage tracking';
COMMENT ON COLUMN Bronze.bz_feature_usage.BATCH_ID IS 'Identifier for the data processing batch';

-- 4.5 Support Tickets Table Column Comments
COMMENT ON COLUMN Bronze.bz_support_tickets.TICKET_ID IS 'Unique identifier for each support ticket';
COMMENT ON COLUMN Bronze.bz_support_tickets.USER_ID IS 'Identifier of the user who created the support ticket';
COMMENT ON COLUMN Bronze.bz_support_tickets.TICKET_TYPE IS 'Category or type of the support ticket (Sensitive - MEDIUM security level)';
COMMENT ON COLUMN Bronze.bz_support_tickets.RESOLUTION_STATUS IS 'Current status of the ticket resolution';
COMMENT ON COLUMN Bronze.bz_support_tickets.OPEN_DATE IS 'Date when the support ticket was opened';
COMMENT ON COLUMN Bronze.bz_support_tickets.PRIORITY_LEVEL IS 'Priority level of the support ticket (LOW, MEDIUM, HIGH, CRITICAL)';
COMMENT ON COLUMN Bronze.bz_support_tickets.CATEGORY IS 'Primary category of the support request';
COMMENT ON COLUMN Bronze.bz_support_tickets.SUB_CATEGORY IS 'Detailed sub-category of the support request';
COMMENT ON COLUMN Bronze.bz_support_tickets.DATA_QUALITY_FLAG IS 'Flag indicating data quality status (VALID, INVALID, SUSPECT, PENDING)';
COMMENT ON COLUMN Bronze.bz_support_tickets.DATA_LINEAGE_ID IS 'Unique identifier for tracking data lineage and audit trail';
COMMENT ON COLUMN Bronze.bz_support_tickets.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_support_tickets.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_support_tickets.SOURCE_SYSTEM IS 'Source system identifier for data lineage tracking';
COMMENT ON COLUMN Bronze.bz_support_tickets.BATCH_ID IS 'Identifier for the data processing batch';

-- 4.6 Billing Events Table Column Comments
COMMENT ON COLUMN Bronze.bz_billing_events.EVENT_ID IS 'Unique identifier for each billing event';
COMMENT ON COLUMN Bronze.bz_billing_events.USER_ID IS 'Identifier linking to the user who generated the billing event';
COMMENT ON COLUMN Bronze.bz_billing_events.EVENT_TYPE IS 'Type of billing event (subscription, usage, etc.) (Sensitive - MEDIUM security level)';
COMMENT ON COLUMN Bronze.bz_billing_events.AMOUNT IS 'Monetary amount associated with the billing event (PII - HIGH security level)';
COMMENT ON COLUMN Bronze.bz_billing_events.EVENT_DATE IS 'Date when the billing event occurred';
COMMENT ON COLUMN Bronze.bz_billing_events.CURRENCY_CODE IS 'ISO currency code for the transaction (ISO 4217 standard)';
COMMENT ON COLUMN Bronze.bz_billing_events.DATA_QUALITY_FLAG IS 'Flag indicating data quality status (VALID, INVALID, SUSPECT, PENDING)';
COMMENT ON COLUMN Bronze.bz_billing_events.DATA_LINEAGE_ID IS 'Unique identifier for tracking data lineage and audit trail';
COMMENT ON COLUMN Bronze.bz_billing_events.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_billing_events.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_billing_events.SOURCE_SYSTEM IS 'Source system identifier for data lineage tracking';
COMMENT ON COLUMN Bronze.bz_billing_events.BATCH_ID IS 'Identifier for the data processing batch';

-- 4.7 Licenses Table Column Comments
COMMENT ON COLUMN Bronze.bz_licenses.LICENSE_ID IS 'Unique identifier for each license';
COMMENT ON COLUMN Bronze.bz_licenses.LICENSE_TYPE IS 'Type of license (Basic, Pro, Business, Enterprise) (Sensitive - MEDIUM security level)';
COMMENT ON COLUMN Bronze.bz_licenses.ASSIGNED_TO_USER_ID IS 'User ID to whom the license is assigned (legacy field)';
COMMENT ON COLUMN Bronze.bz_licenses.ASSIGNED_TO_USER IS 'User to whom the license is assigned';
COMMENT ON COLUMN Bronze.bz_licenses.START_DATE IS 'Date when the license becomes active';
COMMENT ON COLUMN Bronze.bz_licenses.END_DATE IS 'Date when the license expires';
COMMENT ON COLUMN Bronze.bz_licenses.LICENSE_STATUS IS 'Current status of the license (ACTIVE, INACTIVE, EXPIRED, SUSPENDED)';
COMMENT ON COLUMN Bronze.bz_licenses.DATA_QUALITY_FLAG IS 'Flag indicating data quality status (VALID, INVALID, SUSPECT, PENDING)';
COMMENT ON COLUMN Bronze.bz_licenses.DATA_LINEAGE_ID IS 'Unique identifier for tracking data lineage and audit trail';
COMMENT ON COLUMN Bronze.bz_licenses.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_licenses.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_licenses.SOURCE_SYSTEM IS 'Source system identifier for data lineage tracking';
COMMENT ON COLUMN Bronze.bz_licenses.BATCH_ID IS 'Identifier for the data processing batch';

-- 4.8 Enhanced Audit Log Table Column Comments
COMMENT ON COLUMN Bronze.bz_audit_log.RECORD_ID IS 'Unique identifier for each audit record (UUID format)';
COMMENT ON COLUMN Bronze.bz_audit_log.SOURCE_TABLE IS 'Name of the source table being processed';
COMMENT ON COLUMN Bronze.bz_audit_log.OPERATION_TYPE IS 'Type of operation performed (INSERT, UPDATE, DELETE, MERGE)';
COMMENT ON COLUMN Bronze.bz_audit_log.LOAD_TIMESTAMP IS 'Timestamp when the data processing operation was initiated';
COMMENT ON COLUMN Bronze.bz_audit_log.PROCESSED_BY IS 'System or process that handled the data';
COMMENT ON COLUMN Bronze.bz_audit_log.PROCESSING_TIME IS 'Duration taken to process the data in milliseconds';
COMMENT ON COLUMN Bronze.bz_audit_log.STATUS IS 'Status of the processing operation (SUCCESS, FAILED, PARTIAL, WARNING)';
COMMENT ON COLUMN Bronze.bz_audit_log.RECORDS_PROCESSED IS 'Number of records processed in the operation';
COMMENT ON COLUMN Bronze.bz_audit_log.RECORDS_FAILED IS 'Number of records that failed processing';
COMMENT ON COLUMN Bronze.bz_audit_log.ERROR_MESSAGE IS 'Detailed error message if processing failed';
COMMENT ON COLUMN Bronze.bz_audit_log.ERROR_CODE IS 'Standardized error code for categorization';
COMMENT ON COLUMN Bronze.bz_audit_log.DATA_QUALITY_SCORE IS 'Overall data quality score for the batch (0-100)';
COMMENT ON COLUMN Bronze.bz_audit_log.BATCH_ID IS 'Identifier for the data processing batch';
COMMENT ON COLUMN Bronze.bz_audit_log.SOURCE_SYSTEM IS 'Source system that provided the data';
COMMENT ON COLUMN Bronze.bz_audit_log.DATA_LINEAGE_ID IS 'Unique identifier for end-to-end data lineage';
COMMENT ON COLUMN Bronze.bz_audit_log.COMPLIANCE_FLAG IS 'Flag indicating compliance validation status (COMPLIANT, NON_COMPLIANT, PENDING)';
COMMENT ON COLUMN Bronze.bz_audit_log.RETENTION_DATE IS 'Date when the audit record should be archived';

-- =====================================================
-- 5. ENHANCED BRONZE LAYER DESIGN NOTES
-- =====================================================

/*
ENHANCED BRONZE LAYER DESIGN PRINCIPLES:

1. RAW DATA PRESERVATION WITH GOVERNANCE:
   - All tables store data as-is from source systems
   - Enhanced metadata for data governance and compliance
   - Data quality flags for monitoring and alerting
   - Data lineage tracking for end-to-end visibility

2. SNOWFLAKE COMPATIBILITY:
   - Uses Snowflake-supported data types (STRING, NUMBER, DATE, TIMESTAMP_NTZ)
   - No primary keys, foreign keys, or constraints defined
   - Compatible with Snowflake's micro-partitioned storage
   - Optimized data types for performance (NUMBER with precision/scale)

3. ENHANCED METADATA TRACKING:
   - Standard metadata columns: LOAD_TIMESTAMP, UPDATE_TIMESTAMP, SOURCE_SYSTEM
   - Data governance columns: DATA_QUALITY_FLAG, DATA_LINEAGE_ID, BATCH_ID
   - Business enhancement columns: Additional status and categorization fields

4. ENTERPRISE AUDIT CAPABILITIES:
   - Comprehensive audit table (bz_audit_log) with enhanced monitoring
   - Performance tracking with processing time and record counts
   - Error handling with detailed error messages and codes
   - Data quality scoring and compliance validation
   - Retention management for regulatory compliance

5. SECURITY AND PRIVACY:
   - PII classification documented in column comments
   - Security levels indicated (HIGH, MEDIUM, LOW)
   - Ready for masking policies and encryption implementation
   - Compliance framework support

6. TABLE NAMING CONVENTION:
   - All Bronze layer tables prefixed with 'bz_'
   - Schema name: Bronze
   - Follows medallion architecture standards
   - Consistent field naming across tables

7. DATA TYPES RATIONALE:
   - STRING: Used for VARCHAR fields to handle variable lengths
   - NUMBER(precision,scale): For numeric values with appropriate precision
   - DATE: For date-only fields
   - TIMESTAMP_NTZ: For timestamp fields without timezone
   - Enhanced precision for financial data (15,2 for amounts)

8. SCALABILITY AND PERFORMANCE:
   - Tables designed for high-volume data ingestion
   - No constraints to avoid ingestion bottlenecks
   - Optimized for Snowflake's columnar storage format
   - Batch processing support with BATCH_ID tracking

9. OPERATIONAL EXCELLENCE:
   - Comprehensive monitoring capabilities
   - Error tracking and troubleshooting support
   - Performance metrics collection
   - Automated quality assessment

10. VERSION 2 ENHANCEMENTS:
    - Added data lineage tracking (DATA_LINEAGE_ID)
    - Enhanced audit capabilities with compliance monitoring
    - Additional business fields (ACCOUNT_STATUS, MEETING_TYPE, etc.)
    - Improved data types with appropriate precision
    - Enhanced error handling and quality monitoring
    - Batch processing correlation (BATCH_ID)
    - Security classification documentation
    - Performance optimization considerations

11. COMPLIANCE AND GOVERNANCE:
    - GDPR, SOX, and industry-specific compliance support
    - Data retention policy integration
    - Audit trail for regulatory requirements
    - Data quality monitoring and alerting
    - Privacy protection with PII classification

12. FUTURE EXTENSIBILITY:
    - Flexible schema design for additional source systems
    - Standardized metadata framework
    - Scalable audit and monitoring architecture
    - Integration-ready for advanced analytics platforms
*/

-- =====================================================
-- END OF ENHANCED BRONZE LAYER PHYSICAL DATA MODEL
-- =====================================================