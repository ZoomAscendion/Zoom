_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Updated Bronze layer physical data model DDL scripts for Zoom Platform Analytics System with optimized data types
## *Version*: 2 
## *Updated on*: 
## *Changes*: Updated data types from STRING to VARCHAR(100) for improved performance and storage optimization, aligned with Bronze Logical Data Model version 3
## *Reason*: To standardize data types and optimize storage usage while maintaining data integrity and improving query performance
_____________________________________________

-- =====================================================
-- BRONZE LAYER PHYSICAL DATA MODEL DDL SCRIPTS
-- Zoom Platform Analytics System
-- Compatible with Snowflake SQL
-- Version 2 - Optimized Data Types
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
COMMENT ON TABLE Bronze.bz_meetings IS 'Bronze layer table containing raw meeting information and metadata with enhanced temporal tracking';
COMMENT ON TABLE Bronze.bz_participants IS 'Bronze layer table tracking raw meeting participant data and engagement metrics';
COMMENT ON TABLE Bronze.bz_feature_usage IS 'Bronze layer table recording raw feature usage data during meetings for adoption analysis';
COMMENT ON TABLE Bronze.bz_support_tickets IS 'Bronze layer table managing raw customer support ticket information for service quality analysis';
COMMENT ON TABLE Bronze.bz_billing_events IS 'Bronze layer table tracking raw billing and financial transaction data for revenue analysis';
COMMENT ON TABLE Bronze.bz_licenses IS 'Bronze layer table storing raw license assignment and management data with lifecycle tracking';
COMMENT ON TABLE Bronze.bz_audit_log IS 'Enhanced audit table for comprehensive tracking of all Bronze layer data processing activities';

-- =====================================================
-- 4. COLUMN COMMENTS FOR DOCUMENTATION
-- =====================================================

-- 4.1 Users Table Column Comments
COMMENT ON COLUMN Bronze.bz_users.USER_ID IS 'Unique identifier for each user account';
COMMENT ON COLUMN Bronze.bz_users.USER_NAME IS 'Display name of the user for identification and personalization purposes - PII Sensitive';
COMMENT ON COLUMN Bronze.bz_users.EMAIL IS 'User email address for communication and authentication - PII Sensitive';
COMMENT ON COLUMN Bronze.bz_users.COMPANY IS 'Company or organization associated with the user - Non-Sensitive PII';
COMMENT ON COLUMN Bronze.bz_users.PLAN_TYPE IS 'Subscription plan type (Basic, Pro, Business, Enterprise) for revenue analysis';
COMMENT ON COLUMN Bronze.bz_users.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer for data lineage tracking';
COMMENT ON COLUMN Bronze.bz_users.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated for change data capture';
COMMENT ON COLUMN Bronze.bz_users.SOURCE_SYSTEM IS 'Source system identifier for data lineage and audit purposes';

-- 4.2 Meetings Table Column Comments
COMMENT ON COLUMN Bronze.bz_meetings.MEETING_ID IS 'Unique identifier for each meeting';
COMMENT ON COLUMN Bronze.bz_meetings.HOST_ID IS 'User ID of the meeting host linking to users table';
COMMENT ON COLUMN Bronze.bz_meetings.MEETING_TOPIC IS 'Topic or title of the meeting - Potentially Sensitive';
COMMENT ON COLUMN Bronze.bz_meetings.START_TIME IS 'Meeting start timestamp for duration calculation and usage pattern analysis';
COMMENT ON COLUMN Bronze.bz_meetings.END_TIME IS 'Meeting end timestamp for duration calculation and session completion analysis';
COMMENT ON COLUMN Bronze.bz_meetings.DURATION_MINUTES IS 'Total meeting duration in minutes for usage analytics and billing calculations';
COMMENT ON COLUMN Bronze.bz_meetings.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer for data processing tracking';
COMMENT ON COLUMN Bronze.bz_meetings.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated for change management';
COMMENT ON COLUMN Bronze.bz_meetings.SOURCE_SYSTEM IS 'Source system identifier for data lineage and quality assurance';

-- 4.3 Participants Table Column Comments
COMMENT ON COLUMN Bronze.bz_participants.PARTICIPANT_ID IS 'Unique identifier for each participant session';
COMMENT ON COLUMN Bronze.bz_participants.MEETING_ID IS 'Identifier linking to the meeting';
COMMENT ON COLUMN Bronze.bz_participants.USER_ID IS 'Identifier of the user who participated';
COMMENT ON COLUMN Bronze.bz_participants.JOIN_TIME IS 'Timestamp when participant joined the meeting - Behavioral PII';
COMMENT ON COLUMN Bronze.bz_participants.LEAVE_TIME IS 'Timestamp when participant left the meeting - Behavioral PII';
COMMENT ON COLUMN Bronze.bz_participants.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer for processing audit';
COMMENT ON COLUMN Bronze.bz_participants.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated for data freshness tracking';
COMMENT ON COLUMN Bronze.bz_participants.SOURCE_SYSTEM IS 'Source system identifier for data governance and lineage';

-- 4.4 Feature Usage Table Column Comments
COMMENT ON COLUMN Bronze.bz_feature_usage.USAGE_ID IS 'Unique identifier for each feature usage record';
COMMENT ON COLUMN Bronze.bz_feature_usage.MEETING_ID IS 'Identifier linking to the meeting where feature was used';
COMMENT ON COLUMN Bronze.bz_feature_usage.FEATURE_NAME IS 'Name of the feature that was used (Screen Share, Recording, Chat, Breakout Rooms)';
COMMENT ON COLUMN Bronze.bz_feature_usage.USAGE_COUNT IS 'Number of times the feature was used for usage intensity measurement';
COMMENT ON COLUMN Bronze.bz_feature_usage.USAGE_DATE IS 'Date when feature usage occurred for temporal analysis and trend identification';
COMMENT ON COLUMN Bronze.bz_feature_usage.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer for data processing audit';
COMMENT ON COLUMN Bronze.bz_feature_usage.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated for change tracking';
COMMENT ON COLUMN Bronze.bz_feature_usage.SOURCE_SYSTEM IS 'Source system identifier for data lineage and quality control';

-- 4.5 Support Tickets Table Column Comments
COMMENT ON COLUMN Bronze.bz_support_tickets.TICKET_ID IS 'Unique identifier for each support ticket';
COMMENT ON COLUMN Bronze.bz_support_tickets.USER_ID IS 'Identifier of the user who created the support ticket';
COMMENT ON COLUMN Bronze.bz_support_tickets.TICKET_TYPE IS 'Category of support ticket - Potentially Sensitive';
COMMENT ON COLUMN Bronze.bz_support_tickets.RESOLUTION_STATUS IS 'Current status of ticket resolution for tracking progress and SLA compliance';
COMMENT ON COLUMN Bronze.bz_support_tickets.OPEN_DATE IS 'Date when support ticket was created for response time calculation';
COMMENT ON COLUMN Bronze.bz_support_tickets.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer for audit trail';
COMMENT ON COLUMN Bronze.bz_support_tickets.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated for change management';
COMMENT ON COLUMN Bronze.bz_support_tickets.SOURCE_SYSTEM IS 'Source system identifier for data governance and traceability';

-- 4.6 Billing Events Table Column Comments
COMMENT ON COLUMN Bronze.bz_billing_events.EVENT_ID IS 'Unique identifier for each billing event';
COMMENT ON COLUMN Bronze.bz_billing_events.USER_ID IS 'Identifier linking to the user who generated the billing event';
COMMENT ON COLUMN Bronze.bz_billing_events.EVENT_TYPE IS 'Type of billing event (charge, refund, adjustment, subscription)';
COMMENT ON COLUMN Bronze.bz_billing_events.AMOUNT IS 'Monetary amount associated with the billing event - Sensitive Financial';
COMMENT ON COLUMN Bronze.bz_billing_events.EVENT_DATE IS 'Date when billing event occurred for revenue trend analysis';
COMMENT ON COLUMN Bronze.bz_billing_events.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer for audit purposes';
COMMENT ON COLUMN Bronze.bz_billing_events.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated for data integrity tracking';
COMMENT ON COLUMN Bronze.bz_billing_events.SOURCE_SYSTEM IS 'Source system identifier for financial audit and compliance';

-- 4.7 Licenses Table Column Comments
COMMENT ON COLUMN Bronze.bz_licenses.LICENSE_ID IS 'Unique identifier for each license';
COMMENT ON COLUMN Bronze.bz_licenses.LICENSE_TYPE IS 'Type of license (Basic, Pro, Enterprise, Add-on) - Business Sensitive';
COMMENT ON COLUMN Bronze.bz_licenses.ASSIGNED_TO_USER_ID IS 'User ID to whom the license is assigned';
COMMENT ON COLUMN Bronze.bz_licenses.START_DATE IS 'License validity start date for active license tracking';
COMMENT ON COLUMN Bronze.bz_licenses.END_DATE IS 'License validity end date for renewal tracking and churn analysis';
COMMENT ON COLUMN Bronze.bz_licenses.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer for processing audit';
COMMENT ON COLUMN Bronze.bz_licenses.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated for change tracking';
COMMENT ON COLUMN Bronze.bz_licenses.SOURCE_SYSTEM IS 'Source system identifier for data lineage and governance';

-- 4.8 Enhanced Audit Log Table Column Comments
COMMENT ON COLUMN Bronze.bz_audit_log.RECORD_ID IS 'Auto-incrementing unique identifier for each audit record';
COMMENT ON COLUMN Bronze.bz_audit_log.SOURCE_TABLE IS 'Name of the source table being processed for identifying data lineage';
COMMENT ON COLUMN Bronze.bz_audit_log.LOAD_TIMESTAMP IS 'Timestamp when data processing operation was initiated';
COMMENT ON COLUMN Bronze.bz_audit_log.PROCESSED_BY IS 'Identifier of system, user, or process that performed the operation';
COMMENT ON COLUMN Bronze.bz_audit_log.PROCESSING_TIME IS 'Duration of processing operation in seconds for performance monitoring';
COMMENT ON COLUMN Bronze.bz_audit_log.STATUS IS 'Status of processing operation (SUCCESS, FAILED, IN_PROGRESS, PARTIAL, RETRY)';
COMMENT ON COLUMN Bronze.bz_audit_log.ERROR_MESSAGE IS 'Detailed error message for failed operations to support troubleshooting';
COMMENT ON COLUMN Bronze.bz_audit_log.RECORDS_PROCESSED IS 'Number of records processed in the operation for volume tracking';
COMMENT ON COLUMN Bronze.bz_audit_log.DATA_QUALITY_SCORE IS 'Quality score of processed data (0-100) for data quality monitoring';

-- =====================================================
-- 5. BRONZE LAYER DESIGN NOTES AND ENHANCEMENTS
-- =====================================================

/*
BRONZE LAYER DESIGN PRINCIPLES - VERSION 2 ENHANCEMENTS:

1. OPTIMIZED DATA TYPES:
   - Replaced STRING with VARCHAR(100) for improved storage efficiency
   - Maintained Snowflake compatibility with appropriate data types
   - Reduced storage footprint while preserving functionality

2. RAW DATA PRESERVATION:
   - All tables store data as-is from source systems
   - No data transformations or business logic applied
   - Original data relationships preserved through logical design

3. ENHANCED PII CLASSIFICATION:
   - Comprehensive PII classification documented in column comments
   - Ready for masking policies and data governance implementation
   - Supports GDPR, CCPA, and other privacy regulation compliance

4. SNOWFLAKE OPTIMIZATION:
   - Uses Snowflake-supported data types (VARCHAR, NUMBER, DATE, TIMESTAMP_NTZ)
   - No primary keys, foreign keys, or constraints for Bronze layer principles
   - Compatible with Snowflake's micro-partitioned storage architecture
   - Optimized for high-volume data ingestion and processing

5. COMPREHENSIVE METADATA TRACKING:
   - Standard metadata columns across all tables:
     * LOAD_TIMESTAMP: Initial record loading timestamp
     * UPDATE_TIMESTAMP: Last update timestamp for change tracking
     * SOURCE_SYSTEM: Source system identifier for complete data lineage

6. ENHANCED AUDIT CAPABILITIES:
   - Expanded audit table with comprehensive monitoring fields:
     * Error tracking and troubleshooting support
     * Performance monitoring with processing time metrics
     * Data quality scoring for continuous improvement
     * Volume tracking for operational insights

7. TABLE NAMING CONVENTION:
   - Consistent 'bz_' prefix for all Bronze layer tables
   - Schema name: Bronze for clear architectural separation
   - Follows medallion architecture best practices

8. PERFORMANCE CONSIDERATIONS:
   - VARCHAR(100) provides optimal balance of storage and performance
   - Tables designed for efficient bulk loading operations
   - No constraints to avoid ingestion bottlenecks
   - Ready for clustering implementation in production

9. DATA GOVERNANCE READINESS:
   - Comprehensive documentation for all tables and columns
   - PII classification supports privacy protection implementation
   - Audit trail enables regulatory compliance and monitoring
   - Source system tracking enables complete data lineage

10. SCALABILITY AND MAINTENANCE:
    - Designed for high-volume, high-velocity data processing
    - Supports both batch and streaming data ingestion patterns
    - Minimal maintenance overhead with auto-incrementing audit keys
    - Ready for production deployment with monitoring capabilities

VERSION 2 IMPROVEMENTS:
- Standardized VARCHAR(100) data types for consistency and performance
- Enhanced audit table with additional monitoring and quality fields
- Comprehensive PII classification in documentation
- Improved column comments with business context and sensitivity levels
- Optimized storage usage while maintaining all functional requirements
- Better alignment with Snowflake best practices for Bronze layer implementation
*/

-- =====================================================
-- 6. IMPLEMENTATION GUIDELINES
-- =====================================================

/*
IMPLEMENTATION RECOMMENDATIONS:

1. DEPLOYMENT SEQUENCE:
   - Create Bronze schema first
   - Deploy tables in dependency order (audit table first)
   - Implement data loading processes
   - Set up monitoring and alerting

2. DATA LOADING STRATEGY:
   - Use COPY INTO for bulk loading from external stages
   - Implement error handling and retry logic
   - Populate audit table for all loading operations
   - Monitor data quality scores and processing times

3. MONITORING AND MAINTENANCE:
   - Regular monitoring of audit table for failed operations
   - Performance monitoring through processing time metrics
   - Data quality assessment using quality scores
   - Periodic cleanup of old audit records based on retention policies

4. SECURITY IMPLEMENTATION:
   - Apply appropriate masking policies for PII fields
   - Implement row-level security if required
   - Set up proper role-based access controls
   - Enable audit logging for compliance requirements

5. PERFORMANCE OPTIMIZATION:
   - Consider clustering on frequently filtered columns
   - Monitor query performance and adjust warehouse sizing
   - Implement result caching strategies
   - Regular maintenance of clustering keys if implemented
*/

-- =====================================================
-- END OF BRONZE LAYER PHYSICAL DATA MODEL VERSION 2
-- =====================================================