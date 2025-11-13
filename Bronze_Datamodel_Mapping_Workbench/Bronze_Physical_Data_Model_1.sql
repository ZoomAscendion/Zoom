_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze layer physical data model for Zoom Platform Analytics System with Snowflake-compatible DDL scripts
## *Version*: 1 
## *Updated on*: 
_____________________________________________

-- =====================================================
-- BRONZE LAYER PHYSICAL DATA MODEL
-- Zoom Platform Analytics System - Medallion Architecture
-- Target Database: DB_POC_ZOOM
-- Target Schema: BRONZE
-- =====================================================

-- Create Bronze Schema
CREATE SCHEMA IF NOT EXISTS BRONZE;
USE SCHEMA BRONZE;

-- =====================================================
-- 1. BRONZE LAYER TABLES DDL SCRIPTS
-- =====================================================

-- 1.1 Bronze Users Table
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

-- 1.2 Bronze Meetings Table
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

-- 1.3 Bronze Participants Table
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

-- 1.4 Bronze Feature Usage Table
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

-- 1.5 Bronze Support Tickets Table
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

-- 1.6 Bronze Billing Events Table
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

-- 1.7 Bronze Licenses Table
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
-- 2. AUDIT TABLE
-- =====================================================

-- 2.1 Bronze Audit Table for Data Lineage and Processing Tracking
CREATE TABLE IF NOT EXISTS Bronze.bz_audit_table (
    record_id              NUMBER AUTOINCREMENT,
    source_table           STRING,
    load_timestamp         TIMESTAMP_NTZ,
    processed_by           STRING,
    processing_time        NUMBER,
    status                 STRING
);

-- =====================================================
-- 3. TABLE COMMENTS FOR DOCUMENTATION
-- =====================================================

-- Add table comments for documentation
COMMENT ON TABLE Bronze.bz_users IS 'Bronze layer table storing raw user profile and subscription information from source systems';
COMMENT ON TABLE Bronze.bz_meetings IS 'Bronze layer table storing raw meeting information and session details from source systems';
COMMENT ON TABLE Bronze.bz_participants IS 'Bronze layer table storing raw meeting participant data and session details from source systems';
COMMENT ON TABLE Bronze.bz_feature_usage IS 'Bronze layer table storing raw platform feature usage data during meetings from source systems';
COMMENT ON TABLE Bronze.bz_support_tickets IS 'Bronze layer table storing raw customer support request and resolution tracking data from source systems';
COMMENT ON TABLE Bronze.bz_billing_events IS 'Bronze layer table storing raw financial transaction and billing activity data from source systems';
COMMENT ON TABLE Bronze.bz_licenses IS 'Bronze layer table storing raw license assignment and entitlement data from source systems';
COMMENT ON TABLE Bronze.bz_audit_table IS 'Audit table for tracking Bronze layer data operations, lineage, and processing metadata';

-- =====================================================
-- 4. COLUMN COMMENTS FOR METADATA DOCUMENTATION
-- =====================================================

-- Users Table Column Comments
COMMENT ON COLUMN Bronze.bz_users.user_id IS 'Unique identifier for each user account';
COMMENT ON COLUMN Bronze.bz_users.user_name IS 'Display name of the user (PII - requires masking policy)';
COMMENT ON COLUMN Bronze.bz_users.email IS 'Email address of the user (PII - requires masking policy)';
COMMENT ON COLUMN Bronze.bz_users.company IS 'Company or organization name';
COMMENT ON COLUMN Bronze.bz_users.plan_type IS 'Subscription plan type (Basic, Pro, Business, Enterprise)';
COMMENT ON COLUMN Bronze.bz_users.load_timestamp IS 'Timestamp when record was first loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_users.update_timestamp IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_users.source_system IS 'Source system identifier for data lineage';

-- Meetings Table Column Comments
COMMENT ON COLUMN Bronze.bz_meetings.meeting_id IS 'Unique identifier for each meeting';
COMMENT ON COLUMN Bronze.bz_meetings.host_id IS 'User ID of the meeting host (references bz_users.user_id)';
COMMENT ON COLUMN Bronze.bz_meetings.meeting_topic IS 'Topic or title of the meeting (potential PII)';
COMMENT ON COLUMN Bronze.bz_meetings.start_time IS 'Meeting start timestamp';
COMMENT ON COLUMN Bronze.bz_meetings.end_time IS 'Meeting end timestamp';
COMMENT ON COLUMN Bronze.bz_meetings.duration_minutes IS 'Meeting duration in minutes';
COMMENT ON COLUMN Bronze.bz_meetings.load_timestamp IS 'Timestamp when record was first loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_meetings.update_timestamp IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_meetings.source_system IS 'Source system identifier for data lineage';

-- Participants Table Column Comments
COMMENT ON COLUMN Bronze.bz_participants.participant_id IS 'Unique identifier for each meeting participant';
COMMENT ON COLUMN Bronze.bz_participants.meeting_id IS 'Reference to meeting (references bz_meetings.meeting_id)';
COMMENT ON COLUMN Bronze.bz_participants.user_id IS 'Reference to user who participated (references bz_users.user_id)';
COMMENT ON COLUMN Bronze.bz_participants.join_time IS 'Timestamp when participant joined meeting';
COMMENT ON COLUMN Bronze.bz_participants.leave_time IS 'Timestamp when participant left meeting';
COMMENT ON COLUMN Bronze.bz_participants.load_timestamp IS 'Timestamp when record was first loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_participants.update_timestamp IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_participants.source_system IS 'Source system identifier for data lineage';

-- Feature Usage Table Column Comments
COMMENT ON COLUMN Bronze.bz_feature_usage.usage_id IS 'Unique identifier for each feature usage record';
COMMENT ON COLUMN Bronze.bz_feature_usage.meeting_id IS 'Reference to meeting where feature was used (references bz_meetings.meeting_id)';
COMMENT ON COLUMN Bronze.bz_feature_usage.feature_name IS 'Name of the feature being tracked';
COMMENT ON COLUMN Bronze.bz_feature_usage.usage_count IS 'Number of times feature was used';
COMMENT ON COLUMN Bronze.bz_feature_usage.usage_date IS 'Date when feature usage occurred';
COMMENT ON COLUMN Bronze.bz_feature_usage.load_timestamp IS 'Timestamp when record was first loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_feature_usage.update_timestamp IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_feature_usage.source_system IS 'Source system identifier for data lineage';

-- Support Tickets Table Column Comments
COMMENT ON COLUMN Bronze.bz_support_tickets.ticket_id IS 'Unique identifier for each support ticket';
COMMENT ON COLUMN Bronze.bz_support_tickets.user_id IS 'Reference to user who created the ticket (references bz_users.user_id)';
COMMENT ON COLUMN Bronze.bz_support_tickets.ticket_type IS 'Type of support ticket (Technical, Billing, Feature Request, etc.)';
COMMENT ON COLUMN Bronze.bz_support_tickets.resolution_status IS 'Current status of ticket resolution (Open, In Progress, Resolved, Closed)';
COMMENT ON COLUMN Bronze.bz_support_tickets.open_date IS 'Date when ticket was opened';
COMMENT ON COLUMN Bronze.bz_support_tickets.load_timestamp IS 'Timestamp when record was first loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_support_tickets.update_timestamp IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_support_tickets.source_system IS 'Source system identifier for data lineage';

-- Billing Events Table Column Comments
COMMENT ON COLUMN Bronze.bz_billing_events.event_id IS 'Unique identifier for each billing event';
COMMENT ON COLUMN Bronze.bz_billing_events.user_id IS 'Reference to user associated with billing event (references bz_users.user_id)';
COMMENT ON COLUMN Bronze.bz_billing_events.event_type IS 'Type of billing event (Subscription, Upgrade, Refund, etc.)';
COMMENT ON COLUMN Bronze.bz_billing_events.amount IS 'Monetary amount for the billing event';
COMMENT ON COLUMN Bronze.bz_billing_events.event_date IS 'Date when the billing event occurred';
COMMENT ON COLUMN Bronze.bz_billing_events.load_timestamp IS 'Timestamp when record was first loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_billing_events.update_timestamp IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_billing_events.source_system IS 'Source system identifier for data lineage';

-- Licenses Table Column Comments
COMMENT ON COLUMN Bronze.bz_licenses.license_id IS 'Unique identifier for each license';
COMMENT ON COLUMN Bronze.bz_licenses.license_type IS 'Type of license (Basic, Pro, Enterprise, Add-on)';
COMMENT ON COLUMN Bronze.bz_licenses.assigned_to_user_id IS 'User ID to whom license is assigned (references bz_users.user_id)';
COMMENT ON COLUMN Bronze.bz_licenses.start_date IS 'License validity start date';
COMMENT ON COLUMN Bronze.bz_licenses.end_date IS 'License validity end date';
COMMENT ON COLUMN Bronze.bz_licenses.load_timestamp IS 'Timestamp when record was first loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_licenses.update_timestamp IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_licenses.source_system IS 'Source system identifier for data lineage';

-- Audit Table Column Comments
COMMENT ON COLUMN Bronze.bz_audit_table.record_id IS 'Auto-incrementing unique identifier for each audit record';
COMMENT ON COLUMN Bronze.bz_audit_table.source_table IS 'Name of the source table being processed';
COMMENT ON COLUMN Bronze.bz_audit_table.load_timestamp IS 'Timestamp when the data load operation occurred';
COMMENT ON COLUMN Bronze.bz_audit_table.processed_by IS 'User or process that performed the data operation';
COMMENT ON COLUMN Bronze.bz_audit_table.processing_time IS 'Time taken to process the data operation in seconds';
COMMENT ON COLUMN Bronze.bz_audit_table.status IS 'Status of the data operation (SUCCESS, FAILED, IN_PROGRESS)';

-- =====================================================
-- 5. SNOWFLAKE OPTIMIZATION RECOMMENDATIONS
-- =====================================================

-- Note: The following are recommendations for production implementation
-- These are not executed in this DDL script but provided as guidance

/*
-- Clustering recommendations for large tables (implement based on query patterns):
ALTER TABLE Bronze.bz_meetings CLUSTER BY (start_time, host_id);
ALTER TABLE Bronze.bz_participants CLUSTER BY (meeting_id, join_time);
ALTER TABLE Bronze.bz_billing_events CLUSTER BY (event_date, user_id);
ALTER TABLE Bronze.bz_feature_usage CLUSTER BY (usage_date, meeting_id);
ALTER TABLE Bronze.bz_support_tickets CLUSTER BY (open_date, user_id);

-- Data masking policies for PII fields (implement based on security requirements):
CREATE MASKING POLICY email_mask AS (val STRING) 
RETURNS STRING ->
CASE 
    WHEN CURRENT_ROLE() IN ('BRONZE_ADMIN', 'PII_READER') THEN val
    ELSE REGEXP_REPLACE(val, '(.{2}).*(@.*)', '\\1***\\2')
END;

CREATE MASKING POLICY name_mask AS (val STRING) 
RETURNS STRING ->
CASE 
    WHEN CURRENT_ROLE() IN ('BRONZE_ADMIN', 'PII_READER') THEN val
    ELSE LEFT(val, 2) || '***'
END;

-- Apply masking policies:
ALTER TABLE Bronze.bz_users MODIFY COLUMN email SET MASKING POLICY email_mask;
ALTER TABLE Bronze.bz_users MODIFY COLUMN user_name SET MASKING POLICY name_mask;

-- Role-based access control (implement based on organizational requirements):
CREATE ROLE IF NOT EXISTS BRONZE_READER;
CREATE ROLE IF NOT EXISTS BRONZE_WRITER;
CREATE ROLE IF NOT EXISTS BRONZE_ADMIN;

GRANT SELECT ON ALL TABLES IN SCHEMA Bronze TO ROLE BRONZE_READER;
GRANT INSERT, UPDATE ON ALL TABLES IN SCHEMA Bronze TO ROLE BRONZE_WRITER;
GRANT ALL PRIVILEGES ON SCHEMA Bronze TO ROLE BRONZE_ADMIN;
*/

-- =====================================================
-- 6. DATA QUALITY AND VALIDATION FRAMEWORK
-- =====================================================

-- Note: The following are sample data quality checks
-- Implement these as part of your data pipeline validation

/*
-- Sample data quality validation queries:

-- Check for duplicate user emails
SELECT email, COUNT(*) as duplicate_count
FROM Bronze.bz_users 
GROUP BY email 
HAVING COUNT(*) > 1;

-- Validate meeting duration consistency
SELECT meeting_id, start_time, end_time, duration_minutes,
       DATEDIFF('minute', start_time, end_time) as calculated_duration
FROM Bronze.bz_meetings 
WHERE duration_minutes != DATEDIFF('minute', start_time, end_time);

-- Check for orphaned participants (participants without valid meetings)
SELECT p.participant_id, p.meeting_id
FROM Bronze.bz_participants p
LEFT JOIN Bronze.bz_meetings m ON p.meeting_id = m.meeting_id
WHERE m.meeting_id IS NULL;

-- Validate billing amounts are non-negative
SELECT event_id, amount
FROM Bronze.bz_billing_events 
WHERE amount < 0;

-- Check license date validity
SELECT license_id, start_date, end_date
FROM Bronze.bz_licenses 
WHERE end_date < start_date;
*/

-- =====================================================
-- 7. SAMPLE DATA INGESTION PATTERNS
-- =====================================================

-- Note: The following are sample patterns for data ingestion from RAW to Bronze
-- Customize these based on your specific ETL requirements

/*
-- Sample batch ingestion pattern for users:
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

-- Sample MERGE pattern for incremental updates:
MERGE INTO Bronze.bz_meetings AS target
USING (
    SELECT meeting_id, host_id, meeting_topic, start_time, end_time, 
           duration_minutes, source_system
    FROM RAW.MEETINGS
    WHERE update_timestamp > (SELECT COALESCE(MAX(update_timestamp), '1900-01-01') FROM Bronze.bz_meetings)
) AS source
ON target.meeting_id = source.meeting_id
WHEN MATCHED THEN
    UPDATE SET
        host_id = source.host_id,
        meeting_topic = source.meeting_topic,
        start_time = source.start_time,
        end_time = source.end_time,
        duration_minutes = source.duration_minutes,
        update_timestamp = CURRENT_TIMESTAMP(),
        source_system = source.source_system
WHEN NOT MATCHED THEN
    INSERT (meeting_id, host_id, meeting_topic, start_time, end_time, 
            duration_minutes, load_timestamp, update_timestamp, source_system)
    VALUES (source.meeting_id, source.host_id, source.meeting_topic, 
            source.start_time, source.end_time, source.duration_minutes,
            CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), source.source_system);
*/

-- =====================================================
-- END OF BRONZE LAYER PHYSICAL DATA MODEL
-- =====================================================

-- Summary:
-- 1. Created 7 Bronze layer tables with bz_ prefix
-- 2. All tables include standard metadata columns (load_timestamp, update_timestamp, source_system)
-- 3. Used Snowflake-compatible data types (STRING, NUMBER, DATE, TIMESTAMP_NTZ)
-- 4. No primary keys, foreign keys, or constraints as per Bronze layer requirements
-- 5. Included comprehensive audit table for data lineage tracking
-- 6. Added detailed comments for documentation and metadata
-- 7. Provided optimization recommendations and data quality framework
-- 8. All DDL scripts are Snowflake SQL compliant
-- 9. Tables mirror RAW layer structure with Bronze layer enhancements
-- 10. Ready for implementation in Snowflake environment