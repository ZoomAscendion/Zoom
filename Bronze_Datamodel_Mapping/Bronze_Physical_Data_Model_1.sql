_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze layer physical data model for Zoom Platform Analytics System supporting medallion architecture
## *Version*: 1 
## *Updated on*: 
_____________________________________________

-- =====================================================
-- Bronze Layer Physical Data Model - Zoom Platform Analytics System
-- =====================================================

-- 1. Bronze Layer DDL Scripts
-- =====================================================

-- 1.1 Table: Bronze.bz_users
-- Description: Master table containing user account information including personal details and subscription plans
CREATE TABLE IF NOT EXISTS Bronze.bz_users (
    user_name STRING COMMENT 'Display name of the user account',
    email STRING COMMENT 'Email address associated with the user account for communication and identification',
    company STRING COMMENT 'Company or organization the user is affiliated with for business analytics',
    plan_type STRING COMMENT 'Subscription plan type for the user (Basic, Pro, Business, Enterprise, Education)',
    load_timestamp TIMESTAMP_NTZ(9) COMMENT 'Timestamp when the record was first loaded into the bronze layer',
    update_timestamp TIMESTAMP_NTZ(9) COMMENT 'Timestamp when the record was last updated in the bronze layer',
    source_system STRING COMMENT 'Source system from which the data originated for data lineage tracking'
);

-- 1.2 Table: Bronze.bz_meetings
-- Description: Core table containing meeting information including scheduling, duration, and host details
CREATE TABLE IF NOT EXISTS Bronze.bz_meetings (
    meeting_topic STRING COMMENT 'Subject or topic of the meeting for content categorization',
    start_time TIMESTAMP_NTZ(9) COMMENT 'Timestamp when the meeting started for scheduling analytics',
    end_time TIMESTAMP_NTZ(9) COMMENT 'Timestamp when the meeting ended for duration calculations',
    duration_minutes NUMBER(38,0) COMMENT 'Total duration of the meeting in minutes for usage analytics',
    load_timestamp TIMESTAMP_NTZ(9) COMMENT 'Timestamp when the record was first loaded into the bronze layer',
    update_timestamp TIMESTAMP_NTZ(9) COMMENT 'Timestamp when the record was last updated in the bronze layer',
    source_system STRING COMMENT 'Source system from which the data originated for data lineage tracking'
);

-- 1.3 Table: Bronze.bz_participants
-- Description: Tracks individual participants in meetings including join/leave times and user details
CREATE TABLE IF NOT EXISTS Bronze.bz_participants (
    join_time TIMESTAMP_NTZ(9) COMMENT 'Timestamp when the participant joined the meeting for attendance tracking',
    leave_time TIMESTAMP_NTZ(9) COMMENT 'Timestamp when the participant left the meeting for session duration analysis',
    load_timestamp TIMESTAMP_NTZ(9) COMMENT 'Timestamp when the record was first loaded into the bronze layer',
    update_timestamp TIMESTAMP_NTZ(9) COMMENT 'Timestamp when the record was last updated in the bronze layer',
    source_system STRING COMMENT 'Source system from which the data originated for data lineage tracking'
);

-- 1.4 Table: Bronze.bz_feature_usage
-- Description: Tracks usage of various Zoom features during meetings and sessions
CREATE TABLE IF NOT EXISTS Bronze.bz_feature_usage (
    feature_name STRING COMMENT 'Name of the Zoom feature that was used (screen_share, recording, chat, breakout_rooms, whiteboard)',
    usage_count NUMBER(38,0) COMMENT 'Number of times the feature was used in the meeting for usage frequency analysis',
    usage_date DATE COMMENT 'Date when the feature usage occurred for temporal analytics',
    load_timestamp TIMESTAMP_NTZ(9) COMMENT 'Timestamp when the record was first loaded into the bronze layer',
    update_timestamp TIMESTAMP_NTZ(9) COMMENT 'Timestamp when the record was last updated in the bronze layer',
    source_system STRING COMMENT 'Source system from which the data originated for data lineage tracking'
);

-- 1.5 Table: Bronze.bz_support_tickets
-- Description: Contains customer support ticket information including ticket types, status, and resolution details
CREATE TABLE IF NOT EXISTS Bronze.bz_support_tickets (
    ticket_type STRING COMMENT 'Category or type of the support ticket (technical_issue, billing_inquiry, feature_request, account_access)',
    resolution_status STRING COMMENT 'Current status of the support ticket resolution (open, in_progress, resolved, closed, escalated)',
    open_date DATE COMMENT 'Date when the support ticket was created for resolution time analysis',
    load_timestamp TIMESTAMP_NTZ(9) COMMENT 'Timestamp when the record was first loaded into the bronze layer',
    update_timestamp TIMESTAMP_NTZ(9) COMMENT 'Timestamp when the record was last updated in the bronze layer',
    source_system STRING COMMENT 'Source system from which the data originated for data lineage tracking'
);

-- 1.6 Table: Bronze.bz_billing_events
-- Description: Contains billing event information for Zoom services including charges, credits, and payment transactions
CREATE TABLE IF NOT EXISTS Bronze.bz_billing_events (
    event_type STRING COMMENT 'Type of billing event (charge, credit, refund, adjustment) for financial categorization',
    amount NUMBER(10,2) COMMENT 'Monetary amount of the billing event for revenue calculations',
    event_date DATE COMMENT 'Date when the billing event occurred for financial reporting',
    load_timestamp TIMESTAMP_NTZ(9) COMMENT 'Timestamp when the record was first loaded into the bronze layer',
    update_timestamp TIMESTAMP_NTZ(9) COMMENT 'Timestamp when the record was last updated in the bronze layer',
    source_system STRING COMMENT 'Source system from which the data originated for data lineage tracking'
);

-- 1.7 Table: Bronze.bz_licenses
-- Description: Contains information about Zoom licenses assigned to users including license types and validity periods
CREATE TABLE IF NOT EXISTS Bronze.bz_licenses (
    license_type STRING COMMENT 'Type of Zoom license (Basic, Pro, Business, Enterprise, Education) for license categorization',
    start_date DATE COMMENT 'Date when the license becomes active for license lifecycle tracking',
    end_date DATE COMMENT 'Date when the license expires for renewal planning',
    load_timestamp TIMESTAMP_NTZ(9) COMMENT 'Timestamp when the record was first loaded into the bronze layer',
    update_timestamp TIMESTAMP_NTZ(9) COMMENT 'Timestamp when the record was last updated in the bronze layer',
    source_system STRING COMMENT 'Source system from which the data originated for data lineage tracking'
);

-- 1.8 Audit Table: Bronze.bz_audit_log
-- Description: Comprehensive audit table to track all data processing activities across bronze layer tables
CREATE TABLE IF NOT EXISTS Bronze.bz_audit_log (
    record_id NUMBER AUTOINCREMENT COMMENT 'Unique identifier for each audit record',
    source_table STRING COMMENT 'Name of the source table being processed',
    load_timestamp TIMESTAMP_NTZ(9) COMMENT 'Timestamp when the data processing occurred',
    processed_by STRING COMMENT 'System or user that processed the data',
    processing_time NUMBER(10,2) COMMENT 'Time taken to process the data in seconds',
    status STRING COMMENT 'Status of the processing (SUCCESS, FAILED, PARTIAL)'
);

-- =====================================================
-- 2. Bronze Layer Table Comments and Documentation
-- =====================================================

-- 2.1 Table Comments
COMMENT ON TABLE Bronze.bz_users IS 'Master table containing user account information including personal details and subscription plans, mirroring source data structure for bronze layer processing';
COMMENT ON TABLE Bronze.bz_meetings IS 'Core table containing meeting information including scheduling, duration, and host details for meeting analytics and reporting';
COMMENT ON TABLE Bronze.bz_participants IS 'Tracks individual participants in meetings including join/leave times and user details for attendance analytics';
COMMENT ON TABLE Bronze.bz_feature_usage IS 'Tracks usage of various Zoom features during meetings and sessions for feature adoption analytics';
COMMENT ON TABLE Bronze.bz_support_tickets IS 'Contains customer support ticket information including ticket types, status, and resolution details for service quality analytics';
COMMENT ON TABLE Bronze.bz_billing_events IS 'Contains billing event information for Zoom services including charges, credits, and payment transactions for revenue analytics';
COMMENT ON TABLE Bronze.bz_licenses IS 'Contains information about Zoom licenses assigned to users including license types and validity periods for license management analytics';
COMMENT ON TABLE Bronze.bz_audit_log IS 'Comprehensive audit table to track all data processing activities across bronze layer tables for data governance and lineage';

-- =====================================================
-- 3. Bronze Layer Design Specifications
-- =====================================================

-- 3.1 Data Type Standards
-- • STRING: Used for all text fields with variable length up to 16MB
-- • NUMBER(38,0): Used for integer values with high precision
-- • NUMBER(10,2): Used for monetary amounts with 2 decimal places
-- • TIMESTAMP_NTZ(9): Used for all timestamp fields without timezone
-- • DATE: Used for date-only fields
-- • BOOLEAN: Used for true/false values (not used in current model)

-- 3.2 Naming Conventions
-- • All table names prefixed with 'bz_' to identify bronze layer
-- • Schema name: Bronze (following bronze_schema convention)
-- • Column names use snake_case format
-- • Metadata columns standardized across all tables

-- 3.3 Metadata Standards
-- All bronze layer tables include:
-- • load_timestamp: When record was first inserted
-- • update_timestamp: When record was last modified
-- • source_system: Origin system for data lineage

-- 3.4 Audit Trail Design
-- • Dedicated audit table (bz_audit_log) for tracking all operations
-- • AUTOINCREMENT primary key for unique record identification
-- • Processing metrics for performance monitoring
-- • Status tracking for data quality assurance

-- 3.5 Snowflake Compatibility Features
-- • Uses CREATE TABLE IF NOT EXISTS for idempotent execution
-- • Leverages Snowflake native data types (STRING, NUMBER, TIMESTAMP_NTZ)
-- • No foreign key constraints (not enforced in Snowflake)
-- • No primary key constraints (not required for bronze layer)
-- • Micro-partitioned storage (Snowflake default)
-- • Time Travel enabled (Snowflake default)

-- =====================================================
-- 4. Implementation Notes
-- =====================================================

-- 4.1 Storage Optimization
-- • Tables use Snowflake's default micro-partitioned storage
-- • Automatic compression applied by Snowflake
-- • No clustering keys defined (to be added in silver layer if needed)

-- 4.2 Data Loading Considerations
-- • Tables designed for bulk loading using COPY INTO commands
-- • Support for incremental loading through timestamp columns
-- • Audit table tracks all loading operations

-- 4.3 Security and Compliance
-- • PII fields identified in logical model documentation
-- • Ready for masking policies implementation
-- • Audit trail supports compliance requirements

-- 4.4 Performance Considerations
-- • No indexes defined (Snowflake uses automatic optimization)
-- • Timestamp columns support time-based filtering
-- • Audit table uses AUTOINCREMENT for efficient inserts

-- =====================================================
-- End of Bronze Layer Physical Data Model
-- =====================================================