_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze layer physical data model DDL scripts for Zoom Platform Analytics System supporting usage, reliability, and revenue reporting
## *Version*: 1 
## *Updated on*: 
_____________________________________________

-- =====================================================
-- BRONZE LAYER PHYSICAL DATA MODEL DDL SCRIPTS
-- ZOOM PLATFORM ANALYTICS SYSTEM
-- =====================================================

-- 1. BRONZE LAYER USER TABLE
-- Description: Stores raw user profile information and subscription details
CREATE TABLE IF NOT EXISTS Bronze.bz_users (
    user_id VARCHAR(16777216),
    user_name VARCHAR(16777216),
    email VARCHAR(16777216),
    company VARCHAR(16777216),
    plan_type VARCHAR(16777216),
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system VARCHAR(16777216)
);

-- 2. BRONZE LAYER MEETINGS TABLE
-- Description: Contains raw information about video meetings conducted on the platform
CREATE TABLE IF NOT EXISTS Bronze.bz_meetings (
    meeting_id VARCHAR(16777216),
    host_id VARCHAR(16777216),
    meeting_topic VARCHAR(16777216),
    start_time TIMESTAMP_NTZ,
    end_time TIMESTAMP_NTZ,
    duration_minutes NUMBER(38,0),
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system VARCHAR(16777216)
);

-- 3. BRONZE LAYER PARTICIPANTS TABLE
-- Description: Tracks raw meeting participants and their engagement metrics
CREATE TABLE IF NOT EXISTS Bronze.bz_participants (
    participant_id VARCHAR(16777216),
    meeting_id VARCHAR(16777216),
    user_id VARCHAR(16777216),
    join_time TIMESTAMP_NTZ,
    leave_time TIMESTAMP_NTZ,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system VARCHAR(16777216)
);

-- 4. BRONZE LAYER FEATURE USAGE TABLE
-- Description: Records raw usage of specific platform features during meetings
CREATE TABLE IF NOT EXISTS Bronze.bz_feature_usage (
    usage_id VARCHAR(16777216),
    meeting_id VARCHAR(16777216),
    feature_name VARCHAR(16777216),
    usage_count NUMBER(38,0),
    usage_date DATE,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system VARCHAR(16777216)
);

-- 5. BRONZE LAYER SUPPORT TICKETS TABLE
-- Description: Manages raw customer support requests and their resolution process
CREATE TABLE IF NOT EXISTS Bronze.bz_support_tickets (
    ticket_id VARCHAR(16777216),
    user_id VARCHAR(16777216),
    ticket_type VARCHAR(16777216),
    resolution_status VARCHAR(16777216),
    open_date DATE,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system VARCHAR(16777216)
);

-- 6. BRONZE LAYER BILLING EVENTS TABLE
-- Description: Tracks raw financial transactions and billing activities
CREATE TABLE IF NOT EXISTS Bronze.bz_billing_events (
    event_id VARCHAR(16777216),
    user_id VARCHAR(16777216),
    event_type VARCHAR(16777216),
    amount NUMBER(10,2),
    event_date DATE,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system VARCHAR(16777216)
);

-- 7. BRONZE LAYER LICENSES TABLE
-- Description: Manages raw license assignments and entitlements for users
CREATE TABLE IF NOT EXISTS Bronze.bz_licenses (
    license_id VARCHAR(16777216),
    license_type VARCHAR(16777216),
    assigned_to_user_id VARCHAR(16777216),
    start_date DATE,
    end_date DATE,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system VARCHAR(16777216)
);

-- 8. BRONZE LAYER AUDIT TABLE
-- Description: Comprehensive audit trail for tracking all data processing activities
CREATE TABLE IF NOT EXISTS Bronze.bz_audit_log (
    record_id NUMBER AUTOINCREMENT,
    source_table VARCHAR(16777216),
    load_timestamp TIMESTAMP_NTZ,
    processed_by VARCHAR(16777216),
    processing_time NUMBER,
    status VARCHAR(16777216)
);

-- =====================================================
-- BRONZE LAYER TABLE COMMENTS
-- =====================================================

COMMENT ON TABLE Bronze.bz_users IS 'Bronze layer table storing raw user profile information and subscription details for Zoom platform analytics';
COMMENT ON TABLE Bronze.bz_meetings IS 'Bronze layer table containing raw information about video meetings conducted on the Zoom platform';
COMMENT ON TABLE Bronze.bz_participants IS 'Bronze layer table tracking raw meeting participants and their engagement metrics for attendance analysis';
COMMENT ON TABLE Bronze.bz_feature_usage IS 'Bronze layer table recording raw usage of specific platform features during meetings for adoption analysis';
COMMENT ON TABLE Bronze.bz_support_tickets IS 'Bronze layer table managing raw customer support requests and their resolution process for service quality analysis';
COMMENT ON TABLE Bronze.bz_billing_events IS 'Bronze layer table tracking raw financial transactions and billing activities for revenue analysis';
COMMENT ON TABLE Bronze.bz_licenses IS 'Bronze layer table managing raw license assignments and entitlements for users across different subscription tiers';
COMMENT ON TABLE Bronze.bz_audit_log IS 'Bronze layer audit table providing comprehensive trail for tracking all data processing activities and operations';

-- =====================================================
-- COLUMN COMMENTS FOR BRONZE LAYER TABLES
-- =====================================================

-- Users Table Column Comments
COMMENT ON COLUMN Bronze.bz_users.user_id IS 'Unique identifier for each user account';
COMMENT ON COLUMN Bronze.bz_users.user_name IS 'Display name of the user for identification and personalization purposes';
COMMENT ON COLUMN Bronze.bz_users.email IS 'User email address used for communication, login authentication, and account management';
COMMENT ON COLUMN Bronze.bz_users.company IS 'Company or organization name associated with the user for business analytics and segmentation';
COMMENT ON COLUMN Bronze.bz_users.plan_type IS 'Subscription plan type (Basic, Pro, Business, Enterprise) for revenue analysis and feature access control';
COMMENT ON COLUMN Bronze.bz_users.load_timestamp IS 'System timestamp when the record was initially loaded into the Bronze layer';
COMMENT ON COLUMN Bronze.bz_users.update_timestamp IS 'System timestamp when the record was last updated in the Bronze layer';
COMMENT ON COLUMN Bronze.bz_users.source_system IS 'Identifier of the source system from which the data originated for data lineage tracking';

-- Meetings Table Column Comments
COMMENT ON COLUMN Bronze.bz_meetings.meeting_id IS 'Unique identifier for each meeting';
COMMENT ON COLUMN Bronze.bz_meetings.host_id IS 'User ID of the meeting host';
COMMENT ON COLUMN Bronze.bz_meetings.meeting_topic IS 'Topic or title of the meeting for content categorization and analysis';
COMMENT ON COLUMN Bronze.bz_meetings.start_time IS 'Meeting start timestamp for duration calculation and usage pattern analysis';
COMMENT ON COLUMN Bronze.bz_meetings.end_time IS 'Meeting end timestamp for duration calculation and resource utilization tracking';
COMMENT ON COLUMN Bronze.bz_meetings.duration_minutes IS 'Total meeting duration in minutes for usage analytics and billing calculations';
COMMENT ON COLUMN Bronze.bz_meetings.load_timestamp IS 'System timestamp when the record was initially loaded into the Bronze layer';
COMMENT ON COLUMN Bronze.bz_meetings.update_timestamp IS 'System timestamp when the record was last updated in the Bronze layer';
COMMENT ON COLUMN Bronze.bz_meetings.source_system IS 'Identifier of the source system from which the data originated for data lineage tracking';

-- Participants Table Column Comments
COMMENT ON COLUMN Bronze.bz_participants.participant_id IS 'Unique identifier for each meeting participant';
COMMENT ON COLUMN Bronze.bz_participants.meeting_id IS 'Reference to meeting';
COMMENT ON COLUMN Bronze.bz_participants.user_id IS 'Reference to user who participated';
COMMENT ON COLUMN Bronze.bz_participants.join_time IS 'Timestamp when participant joined the meeting for engagement analysis';
COMMENT ON COLUMN Bronze.bz_participants.leave_time IS 'Timestamp when participant left the meeting for participation duration calculation';
COMMENT ON COLUMN Bronze.bz_participants.load_timestamp IS 'System timestamp when the record was initially loaded into the Bronze layer';
COMMENT ON COLUMN Bronze.bz_participants.update_timestamp IS 'System timestamp when the record was last updated in the Bronze layer';
COMMENT ON COLUMN Bronze.bz_participants.source_system IS 'Identifier of the source system from which the data originated for data lineage tracking';

-- Feature Usage Table Column Comments
COMMENT ON COLUMN Bronze.bz_feature_usage.usage_id IS 'Unique identifier for each feature usage record';
COMMENT ON COLUMN Bronze.bz_feature_usage.meeting_id IS 'Reference to meeting where feature was used';
COMMENT ON COLUMN Bronze.bz_feature_usage.feature_name IS 'Name of the feature being tracked (Screen Share, Recording, Chat, etc.) for adoption analysis';
COMMENT ON COLUMN Bronze.bz_feature_usage.usage_count IS 'Number of times the feature was utilized during the session for usage intensity measurement';
COMMENT ON COLUMN Bronze.bz_feature_usage.usage_date IS 'Date when feature usage occurred for temporal analysis and trend identification';
COMMENT ON COLUMN Bronze.bz_feature_usage.load_timestamp IS 'System timestamp when the record was initially loaded into the Bronze layer';
COMMENT ON COLUMN Bronze.bz_feature_usage.update_timestamp IS 'System timestamp when the record was last updated in the Bronze layer';
COMMENT ON COLUMN Bronze.bz_feature_usage.source_system IS 'Identifier of the source system from which the data originated for data lineage tracking';

-- Support Tickets Table Column Comments
COMMENT ON COLUMN Bronze.bz_support_tickets.ticket_id IS 'Unique identifier for each support ticket';
COMMENT ON COLUMN Bronze.bz_support_tickets.user_id IS 'Reference to user who created the ticket';
COMMENT ON COLUMN Bronze.bz_support_tickets.ticket_type IS 'Type of support ticket (Technical, Billing, Feature Request, etc.) for issue categorization';
COMMENT ON COLUMN Bronze.bz_support_tickets.resolution_status IS 'Current status of ticket resolution (Open, In Progress, Resolved, Closed) for tracking progress';
COMMENT ON COLUMN Bronze.bz_support_tickets.open_date IS 'Date when the support ticket was created for response time calculation';
COMMENT ON COLUMN Bronze.bz_support_tickets.load_timestamp IS 'System timestamp when the record was initially loaded into the Bronze layer';
COMMENT ON COLUMN Bronze.bz_support_tickets.update_timestamp IS 'System timestamp when the record was last updated in the Bronze layer';
COMMENT ON COLUMN Bronze.bz_support_tickets.source_system IS 'Identifier of the source system from which the data originated for data lineage tracking';

-- Billing Events Table Column Comments
COMMENT ON COLUMN Bronze.bz_billing_events.event_id IS 'Unique identifier for each billing event';
COMMENT ON COLUMN Bronze.bz_billing_events.user_id IS 'Reference to user associated with billing event';
COMMENT ON COLUMN Bronze.bz_billing_events.event_type IS 'Type of billing event (subscription, usage, upgrade, refund, etc.) for revenue categorization';
COMMENT ON COLUMN Bronze.bz_billing_events.amount IS 'Monetary amount for the billing event in the specified currency for financial analysis';
COMMENT ON COLUMN Bronze.bz_billing_events.event_date IS 'Date when the billing event occurred for revenue trend analysis';
COMMENT ON COLUMN Bronze.bz_billing_events.load_timestamp IS 'System timestamp when the record was initially loaded into the Bronze layer';
COMMENT ON COLUMN Bronze.bz_billing_events.update_timestamp IS 'System timestamp when the record was last updated in the Bronze layer';
COMMENT ON COLUMN Bronze.bz_billing_events.source_system IS 'Identifier of the source system from which the data originated for data lineage tracking';

-- Licenses Table Column Comments
COMMENT ON COLUMN Bronze.bz_licenses.license_id IS 'Unique identifier for each license';
COMMENT ON COLUMN Bronze.bz_licenses.license_type IS 'Type of license (Basic, Pro, Enterprise, Add-on) for entitlement management and revenue analysis';
COMMENT ON COLUMN Bronze.bz_licenses.assigned_to_user_id IS 'User ID to whom license is assigned';
COMMENT ON COLUMN Bronze.bz_licenses.start_date IS 'License validity start date for active license tracking and utilization analysis';
COMMENT ON COLUMN Bronze.bz_licenses.end_date IS 'License validity end date for renewal tracking and churn analysis';
COMMENT ON COLUMN Bronze.bz_licenses.load_timestamp IS 'System timestamp when the record was initially loaded into the Bronze layer';
COMMENT ON COLUMN Bronze.bz_licenses.update_timestamp IS 'System timestamp when the record was last updated in the Bronze layer';
COMMENT ON COLUMN Bronze.bz_licenses.source_system IS 'Identifier of the source system from which the data originated for data lineage tracking';

-- Audit Log Table Column Comments
COMMENT ON COLUMN Bronze.bz_audit_log.record_id IS 'Unique identifier for each audit record using auto-increment for tracking individual processing events';
COMMENT ON COLUMN Bronze.bz_audit_log.source_table IS 'Name of the source table being processed for identifying data lineage and processing scope';
COMMENT ON COLUMN Bronze.bz_audit_log.load_timestamp IS 'Timestamp when the data processing operation was initiated for temporal tracking';
COMMENT ON COLUMN Bronze.bz_audit_log.processed_by IS 'Identifier of the system, user, or process that performed the operation for accountability';
COMMENT ON COLUMN Bronze.bz_audit_log.processing_time IS 'Duration of the processing operation in seconds for performance monitoring';
COMMENT ON COLUMN Bronze.bz_audit_log.status IS 'Status of the processing operation (SUCCESS, FAILED, IN_PROGRESS, PARTIAL) for quality assurance';

-- =====================================================
-- BRONZE LAYER IMPLEMENTATION NOTES
-- =====================================================

/*
1. DESIGN PRINCIPLES:
   - All tables use 'bz_' prefix to identify Bronze layer entities
   - No primary keys, foreign keys, or constraints as per Bronze layer principles
   - Raw data structure preserved with metadata columns added
   - Snowflake-compatible data types used throughout

2. METADATA COLUMNS:
   - load_timestamp: When record was first loaded
   - update_timestamp: When record was last modified
   - source_system: Origin system for data lineage

3. AUDIT CAPABILITIES:
   - Comprehensive audit table for tracking all processing activities
   - Auto-increment record_id for unique audit trail entries
   - Processing time and status tracking for performance monitoring

4. SNOWFLAKE COMPATIBILITY:
   - Uses CREATE TABLE IF NOT EXISTS syntax
   - Leverages Snowflake's micro-partitioned storage (default)
   - Compatible with Snowflake's TIMESTAMP_NTZ and VARCHAR data types
   - No unsupported features like foreign key constraints

5. DATA TYPES MAPPING:
   - VARCHAR(16777216): Snowflake's maximum string length for flexibility
   - TIMESTAMP_NTZ: Timezone-naive timestamps for consistent processing
   - NUMBER(38,0): Integer values with Snowflake's maximum precision
   - NUMBER(10,2): Decimal values for monetary amounts
   - DATE: Date-only values for temporal analysis

6. SCALABILITY CONSIDERATIONS:
   - Tables designed for high-volume data ingestion
   - Efficient storage through Snowflake's automatic compression
   - Ready for clustering implementation in Silver layer
*/

-- =====================================================
-- END OF BRONZE LAYER PHYSICAL DATA MODEL
-- =====================================================