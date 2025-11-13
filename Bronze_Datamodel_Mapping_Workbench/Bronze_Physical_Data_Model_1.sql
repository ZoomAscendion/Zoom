_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze layer physical data model DDL scripts for Zoom Platform Analytics System following Medallion architecture
## *Version*: 1 
## *Updated on*: 
_____________________________________________

-- =====================================================
-- BRONZE LAYER PHYSICAL DATA MODEL DDL SCRIPTS
-- Database: DB_POC_ZOOM
-- Schema: BRONZE
-- Snowflake Compatible DDL Statements
-- =====================================================

-- Create Bronze Schema
CREATE SCHEMA IF NOT EXISTS BRONZE;
USE SCHEMA BRONZE;

-- =====================================================
-- 1. BRONZE LAYER TABLES
-- =====================================================

-- 1.1 Bronze Users Table
CREATE TABLE IF NOT EXISTS Bronze.bz_users (
    user_id VARCHAR(16777216),
    user_name VARCHAR(16777216),
    email VARCHAR(16777216),
    company VARCHAR(16777216),
    plan_type VARCHAR(16777216),
    load_timestamp TIMESTAMP_NTZ(9),
    update_timestamp TIMESTAMP_NTZ(9),
    source_system VARCHAR(16777216)
);

-- 1.2 Bronze Meetings Table
CREATE TABLE IF NOT EXISTS Bronze.bz_meetings (
    meeting_id VARCHAR(16777216),
    host_id VARCHAR(16777216),
    meeting_topic VARCHAR(16777216),
    start_time TIMESTAMP_NTZ(9),
    end_time TIMESTAMP_NTZ(9),
    duration_minutes NUMBER(38,0),
    load_timestamp TIMESTAMP_NTZ(9),
    update_timestamp TIMESTAMP_NTZ(9),
    source_system VARCHAR(16777216)
);

-- 1.3 Bronze Participants Table
CREATE TABLE IF NOT EXISTS Bronze.bz_participants (
    participant_id VARCHAR(16777216),
    meeting_id VARCHAR(16777216),
    user_id VARCHAR(16777216),
    join_time TIMESTAMP_NTZ(9),
    leave_time TIMESTAMP_NTZ(9),
    load_timestamp TIMESTAMP_NTZ(9),
    update_timestamp TIMESTAMP_NTZ(9),
    source_system VARCHAR(16777216)
);

-- 1.4 Bronze Feature Usage Table
CREATE TABLE IF NOT EXISTS Bronze.bz_feature_usage (
    usage_id VARCHAR(16777216),
    meeting_id VARCHAR(16777216),
    feature_name VARCHAR(16777216),
    usage_count NUMBER(38,0),
    usage_date DATE,
    load_timestamp TIMESTAMP_NTZ(9),
    update_timestamp TIMESTAMP_NTZ(9),
    source_system VARCHAR(16777216)
);

-- 1.5 Bronze Support Tickets Table
CREATE TABLE IF NOT EXISTS Bronze.bz_support_tickets (
    ticket_id VARCHAR(16777216),
    user_id VARCHAR(16777216),
    ticket_type VARCHAR(16777216),
    resolution_status VARCHAR(16777216),
    open_date DATE,
    load_timestamp TIMESTAMP_NTZ(9),
    update_timestamp TIMESTAMP_NTZ(9),
    source_system VARCHAR(16777216)
);

-- 1.6 Bronze Billing Events Table
CREATE TABLE IF NOT EXISTS Bronze.bz_billing_events (
    event_id VARCHAR(16777216),
    user_id VARCHAR(16777216),
    event_type VARCHAR(16777216),
    amount NUMBER(10,2),
    event_date DATE,
    load_timestamp TIMESTAMP_NTZ(9),
    update_timestamp TIMESTAMP_NTZ(9),
    source_system VARCHAR(16777216)
);

-- 1.7 Bronze Licenses Table
CREATE TABLE IF NOT EXISTS Bronze.bz_licenses (
    license_id VARCHAR(16777216),
    license_type VARCHAR(16777216),
    assigned_to_user_id VARCHAR(16777216),
    start_date DATE,
    end_date DATE,
    load_timestamp TIMESTAMP_NTZ(9),
    update_timestamp TIMESTAMP_NTZ(9),
    source_system VARCHAR(16777216)
);

-- =====================================================
-- 2. BRONZE LAYER AUDIT TABLE
-- =====================================================

-- 2.1 Bronze Data Audit Table
CREATE TABLE IF NOT EXISTS Bronze.bz_data_audit (
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

-- Add table comments for documentation
COMMENT ON TABLE Bronze.bz_users IS 'Bronze layer table storing raw user profile and subscription information from source systems';
COMMENT ON TABLE Bronze.bz_meetings IS 'Bronze layer table storing raw meeting information and session details from source systems';
COMMENT ON TABLE Bronze.bz_participants IS 'Bronze layer table storing raw meeting participants and their session details from source systems';
COMMENT ON TABLE Bronze.bz_feature_usage IS 'Bronze layer table storing raw platform feature usage data during meetings from source systems';
COMMENT ON TABLE Bronze.bz_support_tickets IS 'Bronze layer table storing raw customer support requests and resolution tracking from source systems';
COMMENT ON TABLE Bronze.bz_billing_events IS 'Bronze layer table storing raw financial transactions and billing activities from source systems';
COMMENT ON TABLE Bronze.bz_licenses IS 'Bronze layer table storing raw license assignments and entitlements from source systems';
COMMENT ON TABLE Bronze.bz_data_audit IS 'Audit table for tracking all Bronze layer data operations and lineage';

-- =====================================================
-- 4. COLUMN COMMENTS FOR BUSINESS CONTEXT
-- =====================================================

-- Users table column comments
COMMENT ON COLUMN Bronze.bz_users.user_id IS 'Unique identifier for each user account';
COMMENT ON COLUMN Bronze.bz_users.user_name IS 'Display name of the user (PII)';
COMMENT ON COLUMN Bronze.bz_users.email IS 'Email address of the user (PII)';
COMMENT ON COLUMN Bronze.bz_users.company IS 'Company or organization name';
COMMENT ON COLUMN Bronze.bz_users.plan_type IS 'Subscription plan type (Basic, Pro, Business, Enterprise)';
COMMENT ON COLUMN Bronze.bz_users.load_timestamp IS 'Timestamp when record was first loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_users.update_timestamp IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_users.source_system IS 'Source system from which data originated';

-- Meetings table column comments
COMMENT ON COLUMN Bronze.bz_meetings.meeting_id IS 'Unique identifier for each meeting';
COMMENT ON COLUMN Bronze.bz_meetings.host_id IS 'User ID of the meeting host';
COMMENT ON COLUMN Bronze.bz_meetings.meeting_topic IS 'Topic or title of the meeting (Potential PII)';
COMMENT ON COLUMN Bronze.bz_meetings.start_time IS 'Meeting start timestamp';
COMMENT ON COLUMN Bronze.bz_meetings.end_time IS 'Meeting end timestamp';
COMMENT ON COLUMN Bronze.bz_meetings.duration_minutes IS 'Meeting duration in minutes';
COMMENT ON COLUMN Bronze.bz_meetings.load_timestamp IS 'Timestamp when record was first loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_meetings.update_timestamp IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_meetings.source_system IS 'Source system from which data originated';

-- Participants table column comments
COMMENT ON COLUMN Bronze.bz_participants.participant_id IS 'Unique identifier for each meeting participant';
COMMENT ON COLUMN Bronze.bz_participants.meeting_id IS 'Reference to meeting';
COMMENT ON COLUMN Bronze.bz_participants.user_id IS 'Reference to user who participated';
COMMENT ON COLUMN Bronze.bz_participants.join_time IS 'Timestamp when participant joined meeting';
COMMENT ON COLUMN Bronze.bz_participants.leave_time IS 'Timestamp when participant left meeting';
COMMENT ON COLUMN Bronze.bz_participants.load_timestamp IS 'Timestamp when record was first loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_participants.update_timestamp IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_participants.source_system IS 'Source system from which data originated';

-- Feature Usage table column comments
COMMENT ON COLUMN Bronze.bz_feature_usage.usage_id IS 'Unique identifier for each feature usage record';
COMMENT ON COLUMN Bronze.bz_feature_usage.meeting_id IS 'Reference to meeting where feature was used';
COMMENT ON COLUMN Bronze.bz_feature_usage.feature_name IS 'Name of the feature being tracked';
COMMENT ON COLUMN Bronze.bz_feature_usage.usage_count IS 'Number of times feature was used';
COMMENT ON COLUMN Bronze.bz_feature_usage.usage_date IS 'Date when feature usage occurred';
COMMENT ON COLUMN Bronze.bz_feature_usage.load_timestamp IS 'Timestamp when record was first loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_feature_usage.update_timestamp IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_feature_usage.source_system IS 'Source system from which data originated';

-- Support Tickets table column comments
COMMENT ON COLUMN Bronze.bz_support_tickets.ticket_id IS 'Unique identifier for each support ticket';
COMMENT ON COLUMN Bronze.bz_support_tickets.user_id IS 'Reference to user who created the ticket';
COMMENT ON COLUMN Bronze.bz_support_tickets.ticket_type IS 'Type of support ticket (Technical, Billing, Feature Request, etc.)';
COMMENT ON COLUMN Bronze.bz_support_tickets.resolution_status IS 'Current status of ticket resolution (Open, In Progress, Resolved, Closed)';
COMMENT ON COLUMN Bronze.bz_support_tickets.open_date IS 'Date when ticket was opened';
COMMENT ON COLUMN Bronze.bz_support_tickets.load_timestamp IS 'Timestamp when record was first loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_support_tickets.update_timestamp IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_support_tickets.source_system IS 'Source system from which data originated';

-- Billing Events table column comments
COMMENT ON COLUMN Bronze.bz_billing_events.event_id IS 'Unique identifier for each billing event';
COMMENT ON COLUMN Bronze.bz_billing_events.user_id IS 'Reference to user associated with billing event';
COMMENT ON COLUMN Bronze.bz_billing_events.event_type IS 'Type of billing event (Subscription, Upgrade, Refund, etc.)';
COMMENT ON COLUMN Bronze.bz_billing_events.amount IS 'Monetary amount for the billing event';
COMMENT ON COLUMN Bronze.bz_billing_events.event_date IS 'Date when the billing event occurred';
COMMENT ON COLUMN Bronze.bz_billing_events.load_timestamp IS 'Timestamp when record was first loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_billing_events.update_timestamp IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_billing_events.source_system IS 'Source system from which data originated';

-- Licenses table column comments
COMMENT ON COLUMN Bronze.bz_licenses.license_id IS 'Unique identifier for each license';
COMMENT ON COLUMN Bronze.bz_licenses.license_type IS 'Type of license (Basic, Pro, Enterprise, Add-on)';
COMMENT ON COLUMN Bronze.bz_licenses.assigned_to_user_id IS 'User ID to whom license is assigned';
COMMENT ON COLUMN Bronze.bz_licenses.start_date IS 'License validity start date';
COMMENT ON COLUMN Bronze.bz_licenses.end_date IS 'License validity end date';
COMMENT ON COLUMN Bronze.bz_licenses.load_timestamp IS 'Timestamp when record was first loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_licenses.update_timestamp IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_licenses.source_system IS 'Source system from which data originated';

-- Audit table column comments
COMMENT ON COLUMN Bronze.bz_data_audit.record_id IS 'Auto-incrementing unique identifier for each audit record';
COMMENT ON COLUMN Bronze.bz_data_audit.source_table IS 'Name of the source table being audited';
COMMENT ON COLUMN Bronze.bz_data_audit.load_timestamp IS 'Timestamp when the data load operation occurred';
COMMENT ON COLUMN Bronze.bz_data_audit.processed_by IS 'User or process that performed the data operation';
COMMENT ON COLUMN Bronze.bz_data_audit.processing_time IS 'Time taken to process the data operation in seconds';
COMMENT ON COLUMN Bronze.bz_data_audit.status IS 'Status of the data operation (SUCCESS, FAILED, PARTIAL)';

-- =====================================================
-- 5. SAMPLE DATA LOADING PATTERNS
-- =====================================================

-- Example: Sample INSERT pattern for Bronze layer data loading
-- This demonstrates how data would be loaded from RAW to Bronze layer

/*
-- Sample data loading from RAW to Bronze layer
INSERT INTO Bronze.bz_users (
    user_id, user_name, email, company, plan_type,
    load_timestamp, update_timestamp, source_system
)
SELECT 
    user_id, user_name, email, company, plan_type,
    CURRENT_TIMESTAMP() as load_timestamp,
    CURRENT_TIMESTAMP() as update_timestamp,
    source_system
FROM RAW.USERS
WHERE update_timestamp > (SELECT COALESCE(MAX(update_timestamp), '1900-01-01') FROM Bronze.bz_users);

-- Sample audit record insertion
INSERT INTO Bronze.bz_data_audit (
    source_table, load_timestamp, processed_by, processing_time, status
)
VALUES (
    'bz_users', 
    CURRENT_TIMESTAMP(), 
    CURRENT_USER(), 
    DATEDIFF('second', :start_time, CURRENT_TIMESTAMP()), 
    'SUCCESS'
);
*/

-- =====================================================
-- 6. DATA QUALITY AND MONITORING VIEWS
-- =====================================================

-- Create view for data quality monitoring
CREATE OR REPLACE VIEW Bronze.vw_data_quality_summary AS
SELECT 
    'bz_users' as table_name,
    COUNT(*) as total_records,
    COUNT(user_name) as user_name_populated,
    COUNT(email) as email_populated,
    (COUNT(email) * 100.0 / NULLIF(COUNT(*), 0)) as email_completeness_pct,
    MAX(load_timestamp) as last_load_time
FROM Bronze.bz_users
UNION ALL
SELECT 
    'bz_meetings' as table_name,
    COUNT(*) as total_records,
    COUNT(meeting_topic) as meeting_topic_populated,
    COUNT(CASE WHEN duration_minutes > 0 THEN 1 END) as valid_duration_count,
    (COUNT(CASE WHEN duration_minutes > 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0)) as valid_duration_pct,
    MAX(load_timestamp) as last_load_time
FROM Bronze.bz_meetings
UNION ALL
SELECT 
    'bz_participants' as table_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN leave_time >= join_time THEN 1 END) as valid_time_range_count,
    COUNT(*) as total_participants,
    (COUNT(CASE WHEN leave_time >= join_time THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0)) as valid_time_range_pct,
    MAX(load_timestamp) as last_load_time
FROM Bronze.bz_participants
UNION ALL
SELECT 
    'bz_feature_usage' as table_name,
    COUNT(*) as total_records,
    COUNT(feature_name) as feature_name_populated,
    COUNT(CASE WHEN usage_count >= 0 THEN 1 END) as valid_usage_count,
    (COUNT(CASE WHEN usage_count >= 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0)) as valid_usage_pct,
    MAX(load_timestamp) as last_load_time
FROM Bronze.bz_feature_usage
UNION ALL
SELECT 
    'bz_support_tickets' as table_name,
    COUNT(*) as total_records,
    COUNT(ticket_type) as ticket_type_populated,
    COUNT(resolution_status) as status_populated,
    (COUNT(resolution_status) * 100.0 / NULLIF(COUNT(*), 0)) as status_completeness_pct,
    MAX(load_timestamp) as last_load_time
FROM Bronze.bz_support_tickets
UNION ALL
SELECT 
    'bz_billing_events' as table_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN amount >= 0 THEN 1 END) as valid_amount_count,
    COUNT(event_type) as event_type_populated,
    (COUNT(CASE WHEN amount >= 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0)) as valid_amount_pct,
    MAX(load_timestamp) as last_load_time
FROM Bronze.bz_billing_events
UNION ALL
SELECT 
    'bz_licenses' as table_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN end_date >= start_date THEN 1 END) as valid_date_range_count,
    COUNT(license_type) as license_type_populated,
    (COUNT(CASE WHEN end_date >= start_date THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0)) as valid_date_range_pct,
    MAX(load_timestamp) as last_load_time
FROM Bronze.bz_licenses;

-- Create view for audit summary
CREATE OR REPLACE VIEW Bronze.vw_audit_summary AS
SELECT 
    source_table,
    COUNT(*) as total_operations,
    COUNT(CASE WHEN status = 'SUCCESS' THEN 1 END) as successful_operations,
    COUNT(CASE WHEN status = 'FAILED' THEN 1 END) as failed_operations,
    AVG(processing_time) as avg_processing_time_seconds,
    MAX(load_timestamp) as last_operation_time
FROM Bronze.bz_data_audit
GROUP BY source_table
ORDER BY source_table;

-- =====================================================
-- 7. PERFORMANCE OPTIMIZATION RECOMMENDATIONS
-- =====================================================

-- Note: The following clustering recommendations should be applied based on query patterns
-- Uncomment and modify based on actual usage patterns after deployment

/*
-- Recommended clustering for large tables based on common query patterns
ALTER TABLE Bronze.bz_meetings CLUSTER BY (start_time, host_id);
ALTER TABLE Bronze.bz_participants CLUSTER BY (meeting_id, join_time);
ALTER TABLE Bronze.bz_billing_events CLUSTER BY (event_date, user_id);
ALTER TABLE Bronze.bz_feature_usage CLUSTER BY (usage_date, meeting_id);
ALTER TABLE Bronze.bz_support_tickets CLUSTER BY (open_date, user_id);
ALTER TABLE Bronze.bz_licenses CLUSTER BY (start_date, assigned_to_user_id);
*/

-- =====================================================
-- 8. SECURITY AND COMPLIANCE SETUP
-- =====================================================

-- Note: The following security policies should be implemented based on organizational requirements
-- Uncomment and modify based on actual security requirements

/*
-- Example masking policy for PII fields
CREATE MASKING POLICY IF NOT EXISTS email_mask AS (val STRING) 
RETURNS STRING ->
CASE 
    WHEN CURRENT_ROLE() IN ('BRONZE_ADMIN', 'PII_READER') THEN val
    ELSE REGEXP_REPLACE(val, '(.{2}).*(@.*)', '\\1***\\2')
END;

-- Apply masking policy to email column
ALTER TABLE Bronze.bz_users MODIFY COLUMN email 
SET MASKING POLICY email_mask;

-- Example masking policy for user names
CREATE MASKING POLICY IF NOT EXISTS name_mask AS (val STRING) 
RETURNS STRING ->
CASE 
    WHEN CURRENT_ROLE() IN ('BRONZE_ADMIN', 'PII_READER') THEN val
    ELSE LEFT(val, 1) || REPEAT('*', GREATEST(LENGTH(val) - 2, 0)) || RIGHT(val, 1)
END;

-- Apply masking policy to user_name column
ALTER TABLE Bronze.bz_users MODIFY COLUMN user_name 
SET MASKING POLICY name_mask;
*/

-- =====================================================
-- END OF BRONZE LAYER PHYSICAL DATA MODEL DDL
-- =====================================================

-- Summary:
-- 1. Created 7 Bronze layer tables with bz_ prefix
-- 2. All tables include standard metadata columns (load_timestamp, update_timestamp, source_system)
-- 3. Created audit table for data lineage and monitoring
-- 4. Added comprehensive table and column comments
-- 5. Created data quality monitoring views
-- 6. Included performance optimization recommendations
-- 7. Included security and compliance setup templates
-- 8. All DDL statements are Snowflake compatible
-- 9. No primary keys, foreign keys, or constraints as per Bronze layer requirements
-- 10. Used appropriate Snowflake data types (VARCHAR, NUMBER, DATE, TIMESTAMP_NTZ)
