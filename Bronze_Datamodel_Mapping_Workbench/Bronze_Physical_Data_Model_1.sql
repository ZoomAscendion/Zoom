_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze layer physical data model DDL scripts for Zoom Platform Analytics System supporting usage, reliability, and revenue reporting
## *Version*: 1 
## *Updated on*: 
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
-- Description: Stores user profile information and subscription details
CREATE TABLE IF NOT EXISTS Bronze.bz_users (
    user_id STRING,
    user_name STRING,
    email STRING,
    company STRING,
    plan_type STRING,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);

-- 1.2 Bronze Meetings Table  
-- Description: Contains comprehensive information about video meetings conducted on the platform
CREATE TABLE IF NOT EXISTS Bronze.bz_meetings (
    meeting_id STRING,
    host_id STRING,
    meeting_topic STRING,
    start_time TIMESTAMP_NTZ,
    end_time TIMESTAMP_NTZ,
    duration_minutes NUMBER,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);

-- 1.3 Bronze Participants Table
-- Description: Tracks meeting participants and their engagement metrics
CREATE TABLE IF NOT EXISTS Bronze.bz_participants (
    participant_id STRING,
    meeting_id STRING,
    user_id STRING,
    join_time TIMESTAMP_NTZ,
    leave_time TIMESTAMP_NTZ,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);

-- 1.4 Bronze Feature Usage Table
-- Description: Records usage of specific platform features during meetings
CREATE TABLE IF NOT EXISTS Bronze.bz_feature_usage (
    usage_id STRING,
    meeting_id STRING,
    feature_name STRING,
    usage_count NUMBER,
    usage_date DATE,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);

-- 1.5 Bronze Support Tickets Table
-- Description: Manages customer support requests and their resolution process
CREATE TABLE IF NOT EXISTS Bronze.bz_support_tickets (
    ticket_id STRING,
    user_id STRING,
    ticket_type STRING,
    resolution_status STRING,
    open_date DATE,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);

-- 1.6 Bronze Billing Events Table
-- Description: Tracks all financial transactions and billing activities
CREATE TABLE IF NOT EXISTS Bronze.bz_billing_events (
    event_id STRING,
    user_id STRING,
    event_type STRING,
    amount STRING,
    event_date DATE,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);

-- 1.7 Bronze Licenses Table
-- Description: Manages license assignments and entitlements for users
CREATE TABLE IF NOT EXISTS Bronze.bz_licenses (
    license_id STRING,
    license_type STRING,
    assigned_to_user_id STRING,
    start_date DATE,
    end_date STRING,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);

-- =====================================================
-- 2. AUDIT TABLE CREATION
-- =====================================================

-- 2.1 Bronze Audit Log Table
-- Description: Comprehensive audit trail for tracking all data processing activities
CREATE TABLE IF NOT EXISTS Bronze.bz_audit_log (
    record_id NUMBER AUTOINCREMENT,
    source_table STRING,
    load_timestamp TIMESTAMP_NTZ,
    processed_by STRING,
    processing_time NUMBER,
    status STRING
);

-- =====================================================
-- 3. TABLE COMMENTS FOR DOCUMENTATION
-- =====================================================

COMMENT ON TABLE Bronze.bz_users IS 'Bronze layer table storing raw user profile information and subscription details from source systems';
COMMENT ON TABLE Bronze.bz_meetings IS 'Bronze layer table containing raw meeting data including timing, duration, and host information';
COMMENT ON TABLE Bronze.bz_participants IS 'Bronze layer table tracking raw participant data for meeting attendance and engagement analysis';
COMMENT ON TABLE Bronze.bz_feature_usage IS 'Bronze layer table recording raw feature usage data during meetings for adoption analysis';
COMMENT ON TABLE Bronze.bz_support_tickets IS 'Bronze layer table managing raw customer support ticket data for service quality tracking';
COMMENT ON TABLE Bronze.bz_billing_events IS 'Bronze layer table storing raw billing and financial transaction data for revenue analysis';
COMMENT ON TABLE Bronze.bz_licenses IS 'Bronze layer table managing raw license assignment and entitlement data';
COMMENT ON TABLE Bronze.bz_audit_log IS 'Audit table for tracking all Bronze layer data processing activities and operations';

-- =====================================================
-- 4. COLUMN COMMENTS FOR DETAILED DOCUMENTATION
-- =====================================================

-- Users Table Column Comments
COMMENT ON COLUMN Bronze.bz_users.user_id IS 'Unique identifier for each user account from source system';
COMMENT ON COLUMN Bronze.bz_users.user_name IS 'Display name of the user for identification and personalization';
COMMENT ON COLUMN Bronze.bz_users.email IS 'User email address for communication and login authentication';
COMMENT ON COLUMN Bronze.bz_users.company IS 'Company or organization name for business analytics and segmentation';
COMMENT ON COLUMN Bronze.bz_users.plan_type IS 'Subscription plan type for revenue analysis and feature access control';
COMMENT ON COLUMN Bronze.bz_users.load_timestamp IS 'System timestamp when record was initially loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_users.update_timestamp IS 'System timestamp when record was last updated in Bronze layer';
COMMENT ON COLUMN Bronze.bz_users.source_system IS 'Identifier of source system for data lineage tracking';

-- Meetings Table Column Comments
COMMENT ON COLUMN Bronze.bz_meetings.meeting_id IS 'Unique identifier for each meeting from source system';
COMMENT ON COLUMN Bronze.bz_meetings.host_id IS 'Identifier of the meeting host linking to user table';
COMMENT ON COLUMN Bronze.bz_meetings.meeting_topic IS 'Topic or title of the meeting for content categorization';
COMMENT ON COLUMN Bronze.bz_meetings.start_time IS 'Meeting start timestamp for duration calculation and usage analysis';
COMMENT ON COLUMN Bronze.bz_meetings.end_time IS 'Meeting end timestamp for duration calculation and resource tracking';
COMMENT ON COLUMN Bronze.bz_meetings.duration_minutes IS 'Total meeting duration in minutes for usage analytics';
COMMENT ON COLUMN Bronze.bz_meetings.load_timestamp IS 'System timestamp when record was initially loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_meetings.update_timestamp IS 'System timestamp when record was last updated in Bronze layer';
COMMENT ON COLUMN Bronze.bz_meetings.source_system IS 'Identifier of source system for data lineage tracking';

-- Participants Table Column Comments
COMMENT ON COLUMN Bronze.bz_participants.participant_id IS 'Unique identifier for each participant record from source system';
COMMENT ON COLUMN Bronze.bz_participants.meeting_id IS 'Identifier linking to the meeting for participation tracking';
COMMENT ON COLUMN Bronze.bz_participants.user_id IS 'Identifier of the participant user for engagement analysis';
COMMENT ON COLUMN Bronze.bz_participants.join_time IS 'Timestamp when participant joined the meeting';
COMMENT ON COLUMN Bronze.bz_participants.leave_time IS 'Timestamp when participant left the meeting';
COMMENT ON COLUMN Bronze.bz_participants.load_timestamp IS 'System timestamp when record was initially loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_participants.update_timestamp IS 'System timestamp when record was last updated in Bronze layer';
COMMENT ON COLUMN Bronze.bz_participants.source_system IS 'Identifier of source system for data lineage tracking';

-- Feature Usage Table Column Comments
COMMENT ON COLUMN Bronze.bz_feature_usage.usage_id IS 'Unique identifier for each feature usage record from source system';
COMMENT ON COLUMN Bronze.bz_feature_usage.meeting_id IS 'Identifier linking to the meeting where feature was used';
COMMENT ON COLUMN Bronze.bz_feature_usage.feature_name IS 'Name of the feature being tracked for adoption analysis';
COMMENT ON COLUMN Bronze.bz_feature_usage.usage_count IS 'Number of times feature was utilized during the session';
COMMENT ON COLUMN Bronze.bz_feature_usage.usage_date IS 'Date when feature usage occurred for temporal analysis';
COMMENT ON COLUMN Bronze.bz_feature_usage.load_timestamp IS 'System timestamp when record was initially loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_feature_usage.update_timestamp IS 'System timestamp when record was last updated in Bronze layer';
COMMENT ON COLUMN Bronze.bz_feature_usage.source_system IS 'Identifier of source system for data lineage tracking';

-- Support Tickets Table Column Comments
COMMENT ON COLUMN Bronze.bz_support_tickets.ticket_id IS 'Unique identifier for each support ticket from source system';
COMMENT ON COLUMN Bronze.bz_support_tickets.user_id IS 'Identifier of user who created the ticket';
COMMENT ON COLUMN Bronze.bz_support_tickets.ticket_type IS 'Type of support ticket for issue categorization';
COMMENT ON COLUMN Bronze.bz_support_tickets.resolution_status IS 'Current status of ticket resolution for progress tracking';
COMMENT ON COLUMN Bronze.bz_support_tickets.open_date IS 'Date when support ticket was created for response time calculation';
COMMENT ON COLUMN Bronze.bz_support_tickets.load_timestamp IS 'System timestamp when record was initially loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_support_tickets.update_timestamp IS 'System timestamp when record was last updated in Bronze layer';
COMMENT ON COLUMN Bronze.bz_support_tickets.source_system IS 'Identifier of source system for data lineage tracking';

-- Billing Events Table Column Comments
COMMENT ON COLUMN Bronze.bz_billing_events.event_id IS 'Unique identifier for each billing event from source system';
COMMENT ON COLUMN Bronze.bz_billing_events.user_id IS 'Identifier linking to user account for billing association';
COMMENT ON COLUMN Bronze.bz_billing_events.event_type IS 'Type of billing event for revenue categorization';
COMMENT ON COLUMN Bronze.bz_billing_events.amount IS 'Monetary amount for the billing event in specified currency';
COMMENT ON COLUMN Bronze.bz_billing_events.event_date IS 'Date when billing event occurred for revenue trend analysis';
COMMENT ON COLUMN Bronze.bz_billing_events.load_timestamp IS 'System timestamp when record was initially loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_billing_events.update_timestamp IS 'System timestamp when record was last updated in Bronze layer';
COMMENT ON COLUMN Bronze.bz_billing_events.source_system IS 'Identifier of source system for data lineage tracking';

-- Licenses Table Column Comments
COMMENT ON COLUMN Bronze.bz_licenses.license_id IS 'Unique identifier for each license from source system';
COMMENT ON COLUMN Bronze.bz_licenses.license_type IS 'Type of license for entitlement management and revenue analysis';
COMMENT ON COLUMN Bronze.bz_licenses.assigned_to_user_id IS 'User ID to whom license is assigned';
COMMENT ON COLUMN Bronze.bz_licenses.start_date IS 'License validity start date for active license tracking';
COMMENT ON COLUMN Bronze.bz_licenses.end_date IS 'License validity end date for renewal tracking and churn analysis';
COMMENT ON COLUMN Bronze.bz_licenses.load_timestamp IS 'System timestamp when record was initially loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_licenses.update_timestamp IS 'System timestamp when record was last updated in Bronze layer';
COMMENT ON COLUMN Bronze.bz_licenses.source_system IS 'Identifier of source system for data lineage tracking';

-- Audit Log Table Column Comments
COMMENT ON COLUMN Bronze.bz_audit_log.record_id IS 'Auto-incrementing unique identifier for each audit record';
COMMENT ON COLUMN Bronze.bz_audit_log.source_table IS 'Name of source table being processed for lineage tracking';
COMMENT ON COLUMN Bronze.bz_audit_log.load_timestamp IS 'Timestamp when data processing operation was initiated';
COMMENT ON COLUMN Bronze.bz_audit_log.processed_by IS 'Identifier of system, user, or process that performed the operation';
COMMENT ON COLUMN Bronze.bz_audit_log.processing_time IS 'Duration of processing operation in seconds for performance monitoring';
COMMENT ON COLUMN Bronze.bz_audit_log.status IS 'Status of processing operation for quality assurance';

-- =====================================================
-- 5. BRONZE LAYER DESIGN PRINCIPLES SUMMARY
-- =====================================================

/*
BRONZE LAYER DESIGN PRINCIPLES:

1. RAW DATA PRESERVATION:
   - Tables store data as-is from source systems
   - No data transformation or business logic applied
   - Original data types preserved where possible

2. METADATA ENRICHMENT:
   - All tables include load_timestamp, update_timestamp, source_system
   - Audit trail maintained for all processing activities
   - Data lineage tracking enabled through source_system field

3. SNOWFLAKE COMPATIBILITY:
   - Uses Snowflake-supported data types (STRING, NUMBER, DATE, TIMESTAMP_NTZ)
   - No primary keys, foreign keys, or constraints defined
   - CREATE TABLE IF NOT EXISTS syntax for idempotent execution
   - Micro-partitioned storage (Snowflake default)

4. NAMING CONVENTIONS:
   - All Bronze tables prefixed with 'bz_'
   - Schema name: Bronze
   - Consistent column naming across tables

5. AUDIT AND COMPLIANCE:
   - Comprehensive audit table for tracking all operations
   - Auto-incrementing record_id for audit trail
   - Processing status and timing captured

6. SCALABILITY:
   - Designed for high-volume data ingestion
   - Optimized for Snowflake's cloud-native architecture
   - Supports concurrent data loading operations
*/

-- =====================================================
-- END OF BRONZE LAYER PHYSICAL DATA MODEL
-- =====================================================