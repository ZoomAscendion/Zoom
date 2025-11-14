_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze layer physical data model DDL scripts for Zoom Platform Analytics System following Medallion architecture
## *Version*: 1 
## *Updated on*: 
_____________________________________________

-- =====================================================
-- BRONZE LAYER PHYSICAL DATA MODEL DDL SCRIPTS
-- Zoom Platform Analytics System - Medallion Architecture
-- Database: DB_POC_ZOOM
-- Schema: BRONZE
-- =====================================================

-- =====================================================
-- 1. SCHEMA CREATION
-- =====================================================

-- Create Bronze schema if not exists
CREATE SCHEMA IF NOT EXISTS BRONZE;

-- Set context to Bronze schema
USE SCHEMA BRONZE;

-- =====================================================
-- 2. BRONZE LAYER TABLES DDL
-- =====================================================

-- -----------------------------------------------------
-- 2.1 Bz_USERS Table
-- Purpose: Stores user profile and subscription information
-- Source: RAW.USERS
-- -----------------------------------------------------

CREATE TABLE IF NOT EXISTS Bronze.bz_users (
    user_id                 STRING,
    user_name              STRING,
    email                  STRING,
    company                STRING,
    plan_type              STRING,
    load_timestamp         TIMESTAMP_NTZ,
    update_timestamp       TIMESTAMP_NTZ,
    source_system          STRING
);

-- -----------------------------------------------------
-- 2.2 Bz_MEETINGS Table
-- Purpose: Stores meeting information and session details
-- Source: RAW.MEETINGS
-- -----------------------------------------------------

CREATE TABLE IF NOT EXISTS Bronze.bz_meetings (
    meeting_id             STRING,
    host_id                STRING,
    meeting_topic          STRING,
    start_time             TIMESTAMP_NTZ,
    end_time               TIMESTAMP_NTZ,
    duration_minutes       NUMBER,
    load_timestamp         TIMESTAMP_NTZ,
    update_timestamp       TIMESTAMP_NTZ,
    source_system          STRING
);

-- -----------------------------------------------------
-- 2.3 Bz_PARTICIPANTS Table
-- Purpose: Tracks meeting participants and their session details
-- Source: RAW.PARTICIPANTS
-- -----------------------------------------------------

CREATE TABLE IF NOT EXISTS Bronze.bz_participants (
    participant_id         STRING,
    meeting_id             STRING,
    user_id                STRING,
    join_time              TIMESTAMP_NTZ,
    leave_time             TIMESTAMP_NTZ,
    load_timestamp         TIMESTAMP_NTZ,
    update_timestamp       TIMESTAMP_NTZ,
    source_system          STRING
);

-- -----------------------------------------------------
-- 2.4 Bz_FEATURE_USAGE Table
-- Purpose: Records usage of platform features during meetings
-- Source: RAW.FEATURE_USAGE
-- -----------------------------------------------------

CREATE TABLE IF NOT EXISTS Bronze.bz_feature_usage (
    usage_id               STRING,
    meeting_id             STRING,
    feature_name           STRING,
    usage_count            NUMBER,
    usage_date             DATE,
    load_timestamp         TIMESTAMP_NTZ,
    update_timestamp       TIMESTAMP_NTZ,
    source_system          STRING
);

-- -----------------------------------------------------
-- 2.5 Bz_SUPPORT_TICKETS Table
-- Purpose: Manages customer support requests and resolution tracking
-- Source: RAW.SUPPORT_TICKETS
-- -----------------------------------------------------

CREATE TABLE IF NOT EXISTS Bronze.bz_support_tickets (
    ticket_id              STRING,
    user_id                STRING,
    ticket_type            STRING,
    resolution_status      STRING,
    open_date              DATE,
    load_timestamp         TIMESTAMP_NTZ,
    update_timestamp       TIMESTAMP_NTZ,
    source_system          STRING
);

-- -----------------------------------------------------
-- 2.6 Bz_BILLING_EVENTS Table
-- Purpose: Tracks financial transactions and billing activities
-- Source: RAW.BILLING_EVENTS
-- -----------------------------------------------------

CREATE TABLE IF NOT EXISTS Bronze.bz_billing_events (
    event_id               STRING,
    user_id                STRING,
    event_type             STRING,
    amount                 NUMBER(10,2),
    event_date             DATE,
    load_timestamp         TIMESTAMP_NTZ,
    update_timestamp       TIMESTAMP_NTZ,
    source_system          STRING
);

-- -----------------------------------------------------
-- 2.7 Bz_LICENSES Table
-- Purpose: Manages license assignments and entitlements
-- Source: RAW.LICENSES
-- -----------------------------------------------------

CREATE TABLE IF NOT EXISTS Bronze.bz_licenses (
    license_id             STRING,
    license_type           STRING,
    assigned_to_user_id    STRING,
    start_date             DATE,
    end_date               DATE,
    load_timestamp         TIMESTAMP_NTZ,
    update_timestamp       TIMESTAMP_NTZ,
    source_system          STRING
);

-- =====================================================
-- 3. AUDIT TABLE
-- =====================================================

-- -----------------------------------------------------
-- 3.1 Audit Table for Bronze Layer Operations
-- Purpose: Comprehensive audit trail for all Bronze layer data operations
-- -----------------------------------------------------

CREATE TABLE IF NOT EXISTS Bronze.bz_data_audit (
    record_id              NUMBER AUTOINCREMENT,
    source_table           STRING,
    load_timestamp         TIMESTAMP_NTZ,
    processed_by           STRING,
    processing_time        NUMBER,
    status                 STRING
);

-- =====================================================
-- 4. COMMENTS ON TABLES
-- =====================================================

-- Add comments for documentation
COMMENT ON TABLE Bronze.bz_users IS 'Bronze layer table storing user profile and subscription information from source systems';
COMMENT ON TABLE Bronze.bz_meetings IS 'Bronze layer table storing meeting information and session details';
COMMENT ON TABLE Bronze.bz_participants IS 'Bronze layer table tracking meeting participants and their session details';
COMMENT ON TABLE Bronze.bz_feature_usage IS 'Bronze layer table recording usage of platform features during meetings';
COMMENT ON TABLE Bronze.bz_support_tickets IS 'Bronze layer table managing customer support requests and resolution tracking';
COMMENT ON TABLE Bronze.bz_billing_events IS 'Bronze layer table tracking financial transactions and billing activities';
COMMENT ON TABLE Bronze.bz_licenses IS 'Bronze layer table managing license assignments and entitlements';
COMMENT ON TABLE Bronze.bz_data_audit IS 'Audit table for tracking all Bronze layer data operations and changes';

-- =====================================================
-- 5. COLUMN COMMENTS FOR DOCUMENTATION
-- =====================================================

-- Bz_USERS table column comments
COMMENT ON COLUMN Bronze.bz_users.user_id IS 'Unique identifier for each user account';
COMMENT ON COLUMN Bronze.bz_users.user_name IS 'Display name of the user (PII)';
COMMENT ON COLUMN Bronze.bz_users.email IS 'Email address of the user (PII)';
COMMENT ON COLUMN Bronze.bz_users.company IS 'Company or organization name';
COMMENT ON COLUMN Bronze.bz_users.plan_type IS 'Subscription plan type (Basic, Pro, Business, Enterprise)';
COMMENT ON COLUMN Bronze.bz_users.load_timestamp IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_users.update_timestamp IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_users.source_system IS 'Source system from which data originated';

-- Bz_MEETINGS table column comments
COMMENT ON COLUMN Bronze.bz_meetings.meeting_id IS 'Unique identifier for each meeting';
COMMENT ON COLUMN Bronze.bz_meetings.host_id IS 'User ID of the meeting host';
COMMENT ON COLUMN Bronze.bz_meetings.meeting_topic IS 'Topic or title of the meeting (Potential PII)';
COMMENT ON COLUMN Bronze.bz_meetings.start_time IS 'Meeting start timestamp';
COMMENT ON COLUMN Bronze.bz_meetings.end_time IS 'Meeting end timestamp';
COMMENT ON COLUMN Bronze.bz_meetings.duration_minutes IS 'Meeting duration in minutes';
COMMENT ON COLUMN Bronze.bz_meetings.load_timestamp IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_meetings.update_timestamp IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_meetings.source_system IS 'Source system from which data originated';

-- Bz_PARTICIPANTS table column comments
COMMENT ON COLUMN Bronze.bz_participants.participant_id IS 'Unique identifier for each meeting participant';
COMMENT ON COLUMN Bronze.bz_participants.meeting_id IS 'Reference to meeting';
COMMENT ON COLUMN Bronze.bz_participants.user_id IS 'Reference to user who participated';
COMMENT ON COLUMN Bronze.bz_participants.join_time IS 'Timestamp when participant joined meeting';
COMMENT ON COLUMN Bronze.bz_participants.leave_time IS 'Timestamp when participant left meeting';
COMMENT ON COLUMN Bronze.bz_participants.load_timestamp IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_participants.update_timestamp IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_participants.source_system IS 'Source system from which data originated';

-- Bz_FEATURE_USAGE table column comments
COMMENT ON COLUMN Bronze.bz_feature_usage.usage_id IS 'Unique identifier for each feature usage record';
COMMENT ON COLUMN Bronze.bz_feature_usage.meeting_id IS 'Reference to meeting where feature was used';
COMMENT ON COLUMN Bronze.bz_feature_usage.feature_name IS 'Name of the feature being tracked';
COMMENT ON COLUMN Bronze.bz_feature_usage.usage_count IS 'Number of times feature was used';
COMMENT ON COLUMN Bronze.bz_feature_usage.usage_date IS 'Date when feature usage occurred';
COMMENT ON COLUMN Bronze.bz_feature_usage.load_timestamp IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_feature_usage.update_timestamp IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_feature_usage.source_system IS 'Source system from which data originated';

-- Bz_SUPPORT_TICKETS table column comments
COMMENT ON COLUMN Bronze.bz_support_tickets.ticket_id IS 'Unique identifier for each support ticket';
COMMENT ON COLUMN Bronze.bz_support_tickets.user_id IS 'Reference to user who created the ticket';
COMMENT ON COLUMN Bronze.bz_support_tickets.ticket_type IS 'Type of support ticket (Technical, Billing, Feature Request, etc.)';
COMMENT ON COLUMN Bronze.bz_support_tickets.resolution_status IS 'Current status of ticket resolution (Open, In Progress, Resolved, Closed)';
COMMENT ON COLUMN Bronze.bz_support_tickets.open_date IS 'Date when ticket was opened';
COMMENT ON COLUMN Bronze.bz_support_tickets.load_timestamp IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_support_tickets.update_timestamp IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_support_tickets.source_system IS 'Source system from which data originated';

-- Bz_BILLING_EVENTS table column comments
COMMENT ON COLUMN Bronze.bz_billing_events.event_id IS 'Unique identifier for each billing event';
COMMENT ON COLUMN Bronze.bz_billing_events.user_id IS 'Reference to user associated with billing event';
COMMENT ON COLUMN Bronze.bz_billing_events.event_type IS 'Type of billing event (Subscription, Upgrade, Refund, etc.)';
COMMENT ON COLUMN Bronze.bz_billing_events.amount IS 'Monetary amount for the billing event';
COMMENT ON COLUMN Bronze.bz_billing_events.event_date IS 'Date when the billing event occurred';
COMMENT ON COLUMN Bronze.bz_billing_events.load_timestamp IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_billing_events.update_timestamp IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_billing_events.source_system IS 'Source system from which data originated';

-- Bz_LICENSES table column comments
COMMENT ON COLUMN Bronze.bz_licenses.license_id IS 'Unique identifier for each license';
COMMENT ON COLUMN Bronze.bz_licenses.license_type IS 'Type of license (Basic, Pro, Enterprise, Add-on)';
COMMENT ON COLUMN Bronze.bz_licenses.assigned_to_user_id IS 'User ID to whom license is assigned';
COMMENT ON COLUMN Bronze.bz_licenses.start_date IS 'License validity start date';
COMMENT ON COLUMN Bronze.bz_licenses.end_date IS 'License validity end date';
COMMENT ON COLUMN Bronze.bz_licenses.load_timestamp IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_licenses.update_timestamp IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_licenses.source_system IS 'Source system from which data originated';

-- Audit table column comments
COMMENT ON COLUMN Bronze.bz_data_audit.record_id IS 'Auto-incrementing unique identifier for audit records';
COMMENT ON COLUMN Bronze.bz_data_audit.source_table IS 'Name of the Bronze layer table being audited';
COMMENT ON COLUMN Bronze.bz_data_audit.load_timestamp IS 'Timestamp when the audit record was created';
COMMENT ON COLUMN Bronze.bz_data_audit.processed_by IS 'User or process that performed the operation';
COMMENT ON COLUMN Bronze.bz_data_audit.processing_time IS 'Time taken to process the operation in seconds';
COMMENT ON COLUMN Bronze.bz_data_audit.status IS 'Status of the operation (SUCCESS, FAILED, WARNING)';

-- =====================================================
-- 6. DATA VALIDATION AND QUALITY CHECKS
-- =====================================================

-- Example data quality check views (optional)
CREATE OR REPLACE VIEW Bronze.vw_data_quality_summary AS
SELECT 
    'bz_users' as table_name,
    COUNT(*) as total_records,
    COUNT(user_name) as user_name_populated,
    COUNT(email) as email_populated,
    (COUNT(email) * 100.0 / COUNT(*)) as email_completeness_pct
FROM Bronze.bz_users
UNION ALL
SELECT 
    'bz_meetings' as table_name,
    COUNT(*) as total_records,
    COUNT(meeting_topic) as topic_populated,
    COUNT(CASE WHEN end_time > start_time THEN 1 END) as valid_duration_count,
    (COUNT(CASE WHEN end_time > start_time THEN 1 END) * 100.0 / COUNT(*)) as valid_duration_pct
FROM Bronze.bz_meetings;

-- =====================================================
-- 7. PERFORMANCE OPTIMIZATION RECOMMENDATIONS
-- =====================================================

-- Clustering recommendations for large tables (to be applied after data loading)
-- ALTER TABLE Bronze.bz_meetings CLUSTER BY (start_time, host_id);
-- ALTER TABLE Bronze.bz_participants CLUSTER BY (meeting_id, join_time);
-- ALTER TABLE Bronze.bz_billing_events CLUSTER BY (event_date, user_id);
-- ALTER TABLE Bronze.bz_feature_usage CLUSTER BY (usage_date, meeting_id);

-- =====================================================
-- 8. SECURITY AND ACCESS CONTROL SETUP
-- =====================================================

-- Role-based access control (to be customized based on organization needs)
-- CREATE ROLE IF NOT EXISTS BRONZE_READER;
-- CREATE ROLE IF NOT EXISTS BRONZE_WRITER;
-- CREATE ROLE IF NOT EXISTS BRONZE_ADMIN;

-- Grant permissions (examples)
-- GRANT SELECT ON ALL TABLES IN SCHEMA Bronze TO ROLE BRONZE_READER;
-- GRANT INSERT, UPDATE ON ALL TABLES IN SCHEMA Bronze TO ROLE BRONZE_WRITER;
-- GRANT ALL PRIVILEGES ON SCHEMA Bronze TO ROLE BRONZE_ADMIN;

-- =====================================================
-- 9. DATA LINEAGE AND MONITORING
-- =====================================================

-- Create view for monitoring data freshness
CREATE OR REPLACE VIEW Bronze.vw_data_freshness AS
SELECT 
    'bz_users' as table_name,
    MAX(load_timestamp) as last_load_time,
    COUNT(*) as record_count
FROM Bronze.bz_users
UNION ALL
SELECT 
    'bz_meetings' as table_name,
    MAX(load_timestamp) as last_load_time,
    COUNT(*) as record_count
FROM Bronze.bz_meetings
UNION ALL
SELECT 
    'bz_participants' as table_name,
    MAX(load_timestamp) as last_load_time,
    COUNT(*) as record_count
FROM Bronze.bz_participants
UNION ALL
SELECT 
    'bz_feature_usage' as table_name,
    MAX(load_timestamp) as last_load_time,
    COUNT(*) as record_count
FROM Bronze.bz_feature_usage
UNION ALL
SELECT 
    'bz_support_tickets' as table_name,
    MAX(load_timestamp) as last_load_time,
    COUNT(*) as record_count
FROM Bronze.bz_support_tickets
UNION ALL
SELECT 
    'bz_billing_events' as table_name,
    MAX(load_timestamp) as last_load_time,
    COUNT(*) as record_count
FROM Bronze.bz_billing_events
UNION ALL
SELECT 
    'bz_licenses' as table_name,
    MAX(load_timestamp) as last_load_time,
    COUNT(*) as record_count
FROM Bronze.bz_licenses;

-- =====================================================
-- 10. DEPLOYMENT VERIFICATION
-- =====================================================

-- Verify all tables are created successfully
SELECT 
    table_name,
    table_type,
    created as creation_time
FROM information_schema.tables 
WHERE table_schema = 'BRONZE' 
    AND table_name LIKE 'BZ_%'
ORDER BY table_name;

-- Verify all columns are created with correct data types
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'BRONZE' 
    AND table_name LIKE 'BZ_%'
ORDER BY table_name, ordinal_position;

-- =====================================================
-- END OF BRONZE LAYER PHYSICAL DATA MODEL DDL
-- =====================================================

/*
DEPLOYMENT NOTES:
1. Execute this script in the target Snowflake environment
2. Ensure proper database context (USE DATABASE DB_POC_ZOOM;)
3. Verify all tables are created successfully using verification queries
4. Apply clustering after initial data load for performance optimization
5. Implement security policies based on organizational requirements
6. Set up monitoring and alerting for data quality and freshness
7. Test data ingestion pipelines from RAW to Bronze layer
8. Document any customizations or modifications made during deployment

COMPLIANCE NOTES:
- PII fields identified: user_name, email, meeting_topic (potential)
- Implement masking policies for PII fields as per organizational requirements
- Ensure GDPR, CCPA compliance for personal data handling
- Regular audit of access patterns and data usage

PERFORMANCE NOTES:
- Tables use Snowflake's default micro-partitioned storage
- Clustering recommendations provided for large tables
- Monitor query performance and adjust clustering as needed
- Consider partitioning strategies for very large datasets
*/