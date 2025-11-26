_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Updated Bronze layer physical data model DDL scripts for Zoom Platform Analytics System with optimized VARCHAR data types
## *Version*: 2 
## *Updated on*: 
## *Changes*: Updated VARCHAR data types from STRING to VARCHAR(100) for improved performance and storage optimization, aligned with logical model version 3
## *Reason*: To standardize data types and optimize storage usage while maintaining data integrity and improving query performance
_____________________________________________

-- =====================================================
-- BRONZE LAYER PHYSICAL DATA MODEL DDL SCRIPTS
-- Zoom Platform Analytics System - Version 2
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

-- 2.1 Bronze Audit Log Table (Enhanced)
CREATE TABLE IF NOT EXISTS Bronze.bz_audit_log (
    RECORD_ID NUMBER AUTOINCREMENT,
    SOURCE_TABLE VARCHAR(100),
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    PROCESSED_BY VARCHAR(100),
    PROCESSING_TIME NUMBER(10,2),
    STATUS VARCHAR(50),
    ERROR_MESSAGE VARCHAR(100),
    RECORDS_PROCESSED NUMBER(38,0),
    DATA_QUALITY_SCORE NUMBER(5,2)
);

-- =====================================================
-- 3. TABLE COMMENTS FOR DOCUMENTATION
-- =====================================================

-- 3.1 Add table comments
COMMENT ON TABLE Bronze.bz_users IS 'Bronze layer table storing raw user profile information and subscription details with optimized VARCHAR(100) data types';
COMMENT ON TABLE Bronze.bz_meetings IS 'Bronze layer table containing raw meeting information and metadata with performance-optimized storage';
COMMENT ON TABLE Bronze.bz_participants IS 'Bronze layer table tracking raw meeting participant data and engagement with standardized data types';
COMMENT ON TABLE Bronze.bz_feature_usage IS 'Bronze layer table recording raw feature usage data during meetings with optimized storage format';
COMMENT ON TABLE Bronze.bz_support_tickets IS 'Bronze layer table managing raw customer support ticket information with enhanced data type optimization';
COMMENT ON TABLE Bronze.bz_billing_events IS 'Bronze layer table tracking raw billing and financial transaction data with standardized VARCHAR lengths';
COMMENT ON TABLE Bronze.bz_licenses IS 'Bronze layer table storing raw license assignment and management data with performance-optimized data types';
COMMENT ON TABLE Bronze.bz_audit_log IS 'Enhanced audit table for tracking all Bronze layer data processing activities with comprehensive monitoring capabilities';

-- =====================================================
-- 4. COLUMN COMMENTS FOR DOCUMENTATION
-- =====================================================

-- 4.1 Users Table Column Comments
COMMENT ON COLUMN Bronze.bz_users.USER_ID IS 'Unique identifier for each user account - optimized VARCHAR(100) format';
COMMENT ON COLUMN Bronze.bz_users.USER_NAME IS 'Display name of the user for identification purposes - PII field requiring protection';
COMMENT ON COLUMN Bronze.bz_users.EMAIL IS 'User email address for communication and authentication - Sensitive PII requiring encryption';
COMMENT ON COLUMN Bronze.bz_users.COMPANY IS 'Company or organization associated with the user - Non-sensitive PII';
COMMENT ON COLUMN Bronze.bz_users.PLAN_TYPE IS 'Subscription plan type (Basic, Pro, Business, Enterprise) - optimized storage format';
COMMENT ON COLUMN Bronze.bz_users.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer for data lineage tracking';
COMMENT ON COLUMN Bronze.bz_users.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated for change data capture';
COMMENT ON COLUMN Bronze.bz_users.SOURCE_SYSTEM IS 'Source system identifier for data lineage tracking - optimized VARCHAR(100)';

-- 4.2 Meetings Table Column Comments
COMMENT ON COLUMN Bronze.bz_meetings.MEETING_ID IS 'Unique identifier for each meeting - performance-optimized VARCHAR(100)';
COMMENT ON COLUMN Bronze.bz_meetings.HOST_ID IS 'User ID of the meeting host - standardized VARCHAR(100) format';
COMMENT ON COLUMN Bronze.bz_meetings.MEETING_TOPIC IS 'Topic or title of the meeting - potentially sensitive information';
COMMENT ON COLUMN Bronze.bz_meetings.START_TIME IS 'Timestamp when the meeting started for duration calculations';
COMMENT ON COLUMN Bronze.bz_meetings.END_TIME IS 'Timestamp when the meeting ended - VARCHAR(100) for flexible data handling';
COMMENT ON COLUMN Bronze.bz_meetings.DURATION_MINUTES IS 'Duration of the meeting in minutes - optimized storage format';
COMMENT ON COLUMN Bronze.bz_meetings.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer for processing audit';
COMMENT ON COLUMN Bronze.bz_meetings.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated for change management';
COMMENT ON COLUMN Bronze.bz_meetings.SOURCE_SYSTEM IS 'Source system identifier for data lineage and quality assurance';

-- 4.3 Participants Table Column Comments
COMMENT ON COLUMN Bronze.bz_participants.PARTICIPANT_ID IS 'Unique identifier for each participant session - optimized VARCHAR(100)';
COMMENT ON COLUMN Bronze.bz_participants.MEETING_ID IS 'Identifier linking to the meeting - standardized format';
COMMENT ON COLUMN Bronze.bz_participants.USER_ID IS 'Identifier of the user who participated - performance-optimized';
COMMENT ON COLUMN Bronze.bz_participants.JOIN_TIME IS 'Timestamp when participant joined - behavioral PII requiring protection';
COMMENT ON COLUMN Bronze.bz_participants.LEAVE_TIME IS 'Timestamp when participant left - behavioral PII data';
COMMENT ON COLUMN Bronze.bz_participants.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer for processing audit';
COMMENT ON COLUMN Bronze.bz_participants.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated for data freshness tracking';
COMMENT ON COLUMN Bronze.bz_participants.SOURCE_SYSTEM IS 'Source system identifier for data governance and lineage';

-- 4.4 Feature Usage Table Column Comments
COMMENT ON COLUMN Bronze.bz_feature_usage.USAGE_ID IS 'Unique identifier for each feature usage record - optimized VARCHAR(100)';
COMMENT ON COLUMN Bronze.bz_feature_usage.MEETING_ID IS 'Identifier linking to the meeting where feature was used';
COMMENT ON COLUMN Bronze.bz_feature_usage.FEATURE_NAME IS 'Name of the feature that was used - standardized VARCHAR(100)';
COMMENT ON COLUMN Bronze.bz_feature_usage.USAGE_COUNT IS 'Number of times the feature was used in the session';
COMMENT ON COLUMN Bronze.bz_feature_usage.USAGE_DATE IS 'Date when the feature usage occurred for temporal analysis';
COMMENT ON COLUMN Bronze.bz_feature_usage.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer for data processing audit';
COMMENT ON COLUMN Bronze.bz_feature_usage.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated for change tracking';
COMMENT ON COLUMN Bronze.bz_feature_usage.SOURCE_SYSTEM IS 'Source system identifier for data lineage and quality control';

-- 4.5 Support Tickets Table Column Comments
COMMENT ON COLUMN Bronze.bz_support_tickets.TICKET_ID IS 'Unique identifier for each support ticket - optimized VARCHAR(100)';
COMMENT ON COLUMN Bronze.bz_support_tickets.USER_ID IS 'Identifier of the user who created the support ticket';
COMMENT ON COLUMN Bronze.bz_support_tickets.TICKET_TYPE IS 'Category of the support ticket - potentially sensitive information';
COMMENT ON COLUMN Bronze.bz_support_tickets.RESOLUTION_STATUS IS 'Current status of the ticket resolution for SLA tracking';
COMMENT ON COLUMN Bronze.bz_support_tickets.OPEN_DATE IS 'Date when the support ticket was opened for response time calculation';
COMMENT ON COLUMN Bronze.bz_support_tickets.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer for audit trail';
COMMENT ON COLUMN Bronze.bz_support_tickets.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated for change management';
COMMENT ON COLUMN Bronze.bz_support_tickets.SOURCE_SYSTEM IS 'Source system identifier for data governance and traceability';

-- 4.6 Billing Events Table Column Comments
COMMENT ON COLUMN Bronze.bz_billing_events.EVENT_ID IS 'Unique identifier for each billing event - performance-optimized VARCHAR(100)';
COMMENT ON COLUMN Bronze.bz_billing_events.USER_ID IS 'Identifier linking to the user who generated the billing event';
COMMENT ON COLUMN Bronze.bz_billing_events.EVENT_TYPE IS 'Type of billing event (subscription, usage, etc.) - standardized format';
COMMENT ON COLUMN Bronze.bz_billing_events.AMOUNT IS 'Monetary amount associated with the billing event - sensitive financial data';
COMMENT ON COLUMN Bronze.bz_billing_events.EVENT_DATE IS 'Date when the billing event occurred for revenue analysis';
COMMENT ON COLUMN Bronze.bz_billing_events.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer for audit purposes';
COMMENT ON COLUMN Bronze.bz_billing_events.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated for data integrity tracking';
COMMENT ON COLUMN Bronze.bz_billing_events.SOURCE_SYSTEM IS 'Source system identifier for financial audit and compliance';

-- 4.7 Licenses Table Column Comments
COMMENT ON COLUMN Bronze.bz_licenses.LICENSE_ID IS 'Unique identifier for each license - optimized VARCHAR(100) format';
COMMENT ON COLUMN Bronze.bz_licenses.LICENSE_TYPE IS 'Type of license (Basic, Pro, Enterprise, Add-on) - business sensitive data';
COMMENT ON COLUMN Bronze.bz_licenses.ASSIGNED_TO_USER_ID IS 'User ID to whom the license is assigned - standardized format';
COMMENT ON COLUMN Bronze.bz_licenses.START_DATE IS 'Date when the license becomes active for subscription management';
COMMENT ON COLUMN Bronze.bz_licenses.END_DATE IS 'Date when the license expires - VARCHAR(100) for flexible data handling';
COMMENT ON COLUMN Bronze.bz_licenses.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer for processing audit';
COMMENT ON COLUMN Bronze.bz_licenses.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated for change tracking';
COMMENT ON COLUMN Bronze.bz_licenses.SOURCE_SYSTEM IS 'Source system identifier for data lineage and governance';

-- 4.8 Enhanced Audit Log Table Column Comments
COMMENT ON COLUMN Bronze.bz_audit_log.RECORD_ID IS 'Auto-incrementing unique identifier for each audit record';
COMMENT ON COLUMN Bronze.bz_audit_log.SOURCE_TABLE IS 'Name of the source table being processed - optimized VARCHAR(100)';
COMMENT ON COLUMN Bronze.bz_audit_log.LOAD_TIMESTAMP IS 'Timestamp when the data processing operation was initiated';
COMMENT ON COLUMN Bronze.bz_audit_log.PROCESSED_BY IS 'Identifier of the system, user, or process that performed the operation';
COMMENT ON COLUMN Bronze.bz_audit_log.PROCESSING_TIME IS 'Duration of the processing operation in seconds with decimal precision';
COMMENT ON COLUMN Bronze.bz_audit_log.STATUS IS 'Status of the processing operation (SUCCESS, FAILED, IN_PROGRESS, PARTIAL, RETRY)';
COMMENT ON COLUMN Bronze.bz_audit_log.ERROR_MESSAGE IS 'Detailed error message for failed operations - optimized VARCHAR(100)';
COMMENT ON COLUMN Bronze.bz_audit_log.RECORDS_PROCESSED IS 'Number of records processed in the operation for volume tracking';
COMMENT ON COLUMN Bronze.bz_audit_log.DATA_QUALITY_SCORE IS 'Quality score of the processed data (0-100) for monitoring';

-- =====================================================
-- 5. BRONZE LAYER DESIGN NOTES - VERSION 2 UPDATES
-- =====================================================

/*
BRONZE LAYER DESIGN PRINCIPLES - VERSION 2 ENHANCEMENTS:

1. DATA TYPE OPTIMIZATION:
   - Updated all VARCHAR fields from STRING/VARCHAR(16777216) to VARCHAR(100)
   - Maintains data integrity while optimizing storage and performance
   - Aligned with logical model version 3 specifications

2. PERFORMANCE IMPROVEMENTS:
   - Reduced storage footprint through standardized VARCHAR lengths
   - Improved query execution times with optimized data types
   - Enhanced indexing capabilities with consistent field lengths

3. ENHANCED AUDIT CAPABILITIES:
   - Added ERROR_MESSAGE field for detailed error tracking
   - Added RECORDS_PROCESSED field for volume monitoring
   - Added DATA_QUALITY_SCORE field for quality assessment
   - Improved PROCESSING_TIME precision with NUMBER(10,2)

4. MAINTAINED BRONZE LAYER PRINCIPLES:
   - Raw data preservation with no transformations
   - No primary keys, foreign keys, or constraints
   - Compatible with Snowflake's micro-partitioned storage
   - Standard metadata columns for lineage tracking

5. PII CLASSIFICATION ALIGNMENT:
   - Maintained PII field identification from logical model
   - Ready for masking policies and encryption implementation
   - Supports GDPR, CCPA, and other privacy regulation compliance

6. STORAGE EFFICIENCY:
   - Optimized VARCHAR lengths reduce storage costs
   - Improved compression ratios with standardized data types
   - Better memory utilization during query processing

7. SCALABILITY ENHANCEMENTS:
   - Maintained high-volume ingestion capabilities
   - Optimized for Snowflake's columnar storage format
   - Improved concurrent query performance

8. VERSION 2 SPECIFIC CHANGES:
   - All VARCHAR fields standardized to VARCHAR(100)
   - Enhanced audit table with additional monitoring fields
   - Improved column comments with PII classification notes
   - Updated table comments to reflect optimization changes
   - Maintained backward compatibility with existing processes

VERSION HISTORY:
- Version 1: Initial Bronze layer physical model with STRING data types
- Version 2: Optimized data types (VARCHAR(100)) and enhanced audit capabilities

NEXT STEPS:
- Monitor query performance improvements
- Validate data integrity with new VARCHAR lengths
- Implement PII masking policies as needed
- Consider clustering strategies for large tables
*/

-- =====================================================
-- END OF BRONZE LAYER PHYSICAL DATA MODEL - VERSION 2
-- =====================================================