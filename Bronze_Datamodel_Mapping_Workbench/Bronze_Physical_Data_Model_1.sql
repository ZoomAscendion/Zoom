_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze layer physical data model DDL scripts for Zoom Platform Analytics System following Medallion architecture
## *Version*: 1 
## *Updated on*: 
_____________________________________________

/*
=============================================================================
BRONZE LAYER PHYSICAL DATA MODEL - ZOOM PLATFORM ANALYTICS SYSTEM
=============================================================================

Purpose: This script creates the Bronze layer physical data model for the 
         Zoom Platform Analytics System following the Medallion architecture.
         The Bronze layer stores raw data as-is with minimal transformation 
         and essential metadata for data lineage.

Target Database: DB_POC_ZOOM
Target Schema: BRONZE
Compatibility: Snowflake SQL

Key Features:
- Exact source data mirroring with bz_ prefix
- Standard metadata columns for audit trail
- No primary keys, foreign keys, or constraints (Snowflake best practice)
- Snowflake-compatible data types
- Comprehensive audit table for data operations tracking

=============================================================================
*/

-- =============================================================================
-- 1. BRONZE LAYER DDL SCRIPTS
-- =============================================================================

-- 1.1 Bronze Users Table
-- Purpose: Stores user profile and subscription information from source systems
-- Source Mapping: RAW.USERS → BRONZE.bz_users

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
-- Purpose: Stores meeting information and session details
-- Source Mapping: RAW.MEETINGS → BRONZE.bz_meetings

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
-- Purpose: Tracks meeting participants and their session details
-- Source Mapping: RAW.PARTICIPANTS → BRONZE.bz_participants

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
-- Purpose: Records usage of platform features during meetings
-- Source Mapping: RAW.FEATURE_USAGE → BRONZE.bz_feature_usage

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
-- Purpose: Manages customer support requests and resolution tracking
-- Source Mapping: RAW.SUPPORT_TICKETS → BRONZE.bz_support_tickets

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
-- Purpose: Tracks financial transactions and billing activities
-- Source Mapping: RAW.BILLING_EVENTS → BRONZE.bz_billing_events

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
-- Purpose: Manages license assignments and entitlements
-- Source Mapping: RAW.LICENSES → BRONZE.bz_licenses

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

-- 1.8 Bronze Audit Table
-- Purpose: Comprehensive audit trail for all Bronze layer data operations

CREATE TABLE IF NOT EXISTS Bronze.bz_data_audit (
    record_id              NUMBER AUTOINCREMENT,
    source_table           STRING,
    load_timestamp         TIMESTAMP_NTZ,
    processed_by           STRING,
    processing_time        NUMBER,
    status                 STRING
);

-- =============================================================================
-- 2. TABLE COMMENTS AND DOCUMENTATION
-- =============================================================================

-- Add table comments for documentation
COMMENT ON TABLE Bronze.bz_users IS 'Bronze layer table storing user profile and subscription information from source systems';
COMMENT ON TABLE Bronze.bz_meetings IS 'Bronze layer table storing meeting information and session details';
COMMENT ON TABLE Bronze.bz_participants IS 'Bronze layer table tracking meeting participants and their session details';
COMMENT ON TABLE Bronze.bz_feature_usage IS 'Bronze layer table recording usage of platform features during meetings';
COMMENT ON TABLE Bronze.bz_support_tickets IS 'Bronze layer table managing customer support requests and resolution tracking';
COMMENT ON TABLE Bronze.bz_billing_events IS 'Bronze layer table tracking financial transactions and billing activities';
COMMENT ON TABLE Bronze.bz_licenses IS 'Bronze layer table managing license assignments and entitlements';
COMMENT ON TABLE Bronze.bz_data_audit IS 'Comprehensive audit trail for all Bronze layer data operations';

-- Add column comments for key fields
COMMENT ON COLUMN Bronze.bz_users.user_id IS 'Unique identifier for each user account';
COMMENT ON COLUMN Bronze.bz_users.user_name IS 'Display name of the user - PII field';
COMMENT ON COLUMN Bronze.bz_users.email IS 'Email address of the user - PII field';
COMMENT ON COLUMN Bronze.bz_users.plan_type IS 'Subscription plan type (Basic, Pro, Business, Enterprise)';

COMMENT ON COLUMN Bronze.bz_meetings.meeting_id IS 'Unique identifier for each meeting';
COMMENT ON COLUMN Bronze.bz_meetings.host_id IS 'User ID of the meeting host';
COMMENT ON COLUMN Bronze.bz_meetings.meeting_topic IS 'Topic or title of the meeting - Potential PII';

COMMENT ON COLUMN Bronze.bz_participants.participant_id IS 'Unique identifier for each meeting participant';
COMMENT ON COLUMN Bronze.bz_participants.meeting_id IS 'Reference to meeting';
COMMENT ON COLUMN Bronze.bz_participants.user_id IS 'Reference to user who participated';

COMMENT ON COLUMN Bronze.bz_feature_usage.usage_id IS 'Unique identifier for each feature usage record';
COMMENT ON COLUMN Bronze.bz_feature_usage.feature_name IS 'Name of the feature being tracked';

COMMENT ON COLUMN Bronze.bz_support_tickets.ticket_id IS 'Unique identifier for each support ticket';
COMMENT ON COLUMN Bronze.bz_support_tickets.resolution_status IS 'Current status (Open, In Progress, Resolved, Closed)';

COMMENT ON COLUMN Bronze.bz_billing_events.event_id IS 'Unique identifier for each billing event';
COMMENT ON COLUMN Bronze.bz_billing_events.event_type IS 'Type of billing event (Subscription, Upgrade, Refund, etc.)';

COMMENT ON COLUMN Bronze.bz_licenses.license_id IS 'Unique identifier for each license';
COMMENT ON COLUMN Bronze.bz_licenses.license_type IS 'Type of license (Basic, Pro, Enterprise, Add-on)';

COMMENT ON COLUMN Bronze.bz_data_audit.record_id IS 'Auto-incrementing unique identifier for audit records';
COMMENT ON COLUMN Bronze.bz_data_audit.source_table IS 'Name of the source table being audited';
COMMENT ON COLUMN Bronze.bz_data_audit.processed_by IS 'User or process that performed the operation';

-- =============================================================================
-- 3. DATA QUALITY AND VALIDATION FRAMEWORK
-- =============================================================================

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
    COUNT(CASE WHEN leave_time >= join_time THEN 1 END) as valid_time_records,
    COUNT(*) as total_records_check,
    (COUNT(CASE WHEN leave_time >= join_time THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0)) as valid_time_pct,
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
    COUNT(CASE WHEN amount >= 0 THEN 1 END) as valid_amount_records,
    COUNT(event_type) as event_type_populated,
    (COUNT(CASE WHEN amount >= 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0)) as valid_amount_pct,
    MAX(load_timestamp) as last_load_time
FROM Bronze.bz_billing_events

UNION ALL

SELECT 
    'bz_licenses' as table_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN end_date >= start_date THEN 1 END) as valid_date_records,
    COUNT(license_type) as license_type_populated,
    (COUNT(CASE WHEN end_date >= start_date THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0)) as valid_date_pct,
    MAX(load_timestamp) as last_load_time
FROM Bronze.bz_licenses;

COMMENT ON VIEW Bronze.vw_data_quality_summary IS 'Data quality monitoring view for all Bronze layer tables';

-- =============================================================================
-- 4. PERFORMANCE OPTIMIZATION RECOMMENDATIONS
-- =============================================================================

/*
Clustering Recommendations (to be applied after data loading):

-- For large tables, consider clustering on frequently filtered columns
ALTER TABLE Bronze.bz_meetings CLUSTER BY (start_time, host_id);
ALTER TABLE Bronze.bz_participants CLUSTER BY (meeting_id, join_time);
ALTER TABLE Bronze.bz_billing_events CLUSTER BY (event_date, user_id);
ALTER TABLE Bronze.bz_feature_usage CLUSTER BY (usage_date, meeting_id);
ALTER TABLE Bronze.bz_support_tickets CLUSTER BY (open_date, user_id);
ALTER TABLE Bronze.bz_licenses CLUSTER BY (start_date, assigned_to_user_id);

Note: Clustering should be implemented after initial data loading and 
      based on actual query patterns and data volumes.
*/

-- =============================================================================
-- 5. SECURITY AND COMPLIANCE FRAMEWORK
-- =============================================================================

/*
PII Fields Identified:
- Bronze.bz_users.user_name (Direct PII)
- Bronze.bz_users.email (Direct PII)
- Bronze.bz_meetings.meeting_topic (Potential PII)

Recommended Security Implementations:

1. Data Masking Policies (to be implemented by security team):

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
    ELSE LEFT(val, 1) || '***'
END;

-- Apply masking policies
ALTER TABLE Bronze.bz_users MODIFY COLUMN email SET MASKING POLICY email_mask;
ALTER TABLE Bronze.bz_users MODIFY COLUMN user_name SET MASKING POLICY name_mask;

2. Role-Based Access Control:

CREATE ROLE IF NOT EXISTS BRONZE_READER;
CREATE ROLE IF NOT EXISTS BRONZE_WRITER;
CREATE ROLE IF NOT EXISTS BRONZE_ADMIN;

GRANT SELECT ON ALL TABLES IN SCHEMA Bronze TO ROLE BRONZE_READER;
GRANT INSERT, UPDATE ON ALL TABLES IN SCHEMA Bronze TO ROLE BRONZE_WRITER;
GRANT ALL PRIVILEGES ON SCHEMA Bronze TO ROLE BRONZE_ADMIN;
*/

-- =============================================================================
-- 6. DATA LINEAGE AND AUDIT FRAMEWORK
-- =============================================================================

-- Create view for data lineage tracking
CREATE OR REPLACE VIEW Bronze.vw_data_lineage AS
SELECT 
    'bz_users' as bronze_table,
    'RAW.USERS' as source_table,
    'user_id' as key_field,
    COUNT(*) as record_count,
    MIN(load_timestamp) as first_load,
    MAX(load_timestamp) as last_load,
    COUNT(DISTINCT source_system) as source_system_count
FROM Bronze.bz_users
GROUP BY 1, 2, 3

UNION ALL

SELECT 
    'bz_meetings' as bronze_table,
    'RAW.MEETINGS' as source_table,
    'meeting_id' as key_field,
    COUNT(*) as record_count,
    MIN(load_timestamp) as first_load,
    MAX(load_timestamp) as last_load,
    COUNT(DISTINCT source_system) as source_system_count
FROM Bronze.bz_meetings
GROUP BY 1, 2, 3

UNION ALL

SELECT 
    'bz_participants' as bronze_table,
    'RAW.PARTICIPANTS' as source_table,
    'participant_id' as key_field,
    COUNT(*) as record_count,
    MIN(load_timestamp) as first_load,
    MAX(load_timestamp) as last_load,
    COUNT(DISTINCT source_system) as source_system_count
FROM Bronze.bz_participants
GROUP BY 1, 2, 3

UNION ALL

SELECT 
    'bz_feature_usage' as bronze_table,
    'RAW.FEATURE_USAGE' as source_table,
    'usage_id' as key_field,
    COUNT(*) as record_count,
    MIN(load_timestamp) as first_load,
    MAX(load_timestamp) as last_load,
    COUNT(DISTINCT source_system) as source_system_count
FROM Bronze.bz_feature_usage
GROUP BY 1, 2, 3

UNION ALL

SELECT 
    'bz_support_tickets' as bronze_table,
    'RAW.SUPPORT_TICKETS' as source_table,
    'ticket_id' as key_field,
    COUNT(*) as record_count,
    MIN(load_timestamp) as first_load,
    MAX(load_timestamp) as last_load,
    COUNT(DISTINCT source_system) as source_system_count
FROM Bronze.bz_support_tickets
GROUP BY 1, 2, 3

UNION ALL

SELECT 
    'bz_billing_events' as bronze_table,
    'RAW.BILLING_EVENTS' as source_table,
    'event_id' as key_field,
    COUNT(*) as record_count,
    MIN(load_timestamp) as first_load,
    MAX(load_timestamp) as last_load,
    COUNT(DISTINCT source_system) as source_system_count
FROM Bronze.bz_billing_events
GROUP BY 1, 2, 3

UNION ALL

SELECT 
    'bz_licenses' as bronze_table,
    'RAW.LICENSES' as source_table,
    'license_id' as key_field,
    COUNT(*) as record_count,
    MIN(load_timestamp) as first_load,
    MAX(load_timestamp) as last_load,
    COUNT(DISTINCT source_system) as source_system_count
FROM Bronze.bz_licenses
GROUP BY 1, 2, 3;

COMMENT ON VIEW Bronze.vw_data_lineage IS 'Data lineage tracking view showing source to Bronze layer mappings';

-- =============================================================================
-- 7. DEPLOYMENT AND VALIDATION SCRIPTS
-- =============================================================================

-- Validation script to verify table creation
SELECT 
    table_name,
    table_type,
    row_count,
    bytes,
    created
FROM information_schema.tables 
WHERE table_schema = 'BRONZE' 
  AND table_name LIKE 'BZ_%'
ORDER BY table_name;

-- Validation script to verify column structure
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable,
    column_default,
    comment
FROM information_schema.columns 
WHERE table_schema = 'BRONZE' 
  AND table_name LIKE 'BZ_%'
ORDER BY table_name, ordinal_position;

/*
=============================================================================
DEPLOYMENT CHECKLIST:
=============================================================================

1. ✓ Create Bronze schema if not exists
2. ✓ Execute DDL scripts for all Bronze tables
3. ✓ Add table and column comments
4. ✓ Create data quality monitoring views
5. ✓ Create data lineage tracking views
6. ✓ Validate table creation and structure
7. □ Implement security policies (masking, RBAC)
8. □ Set up data ingestion pipelines from RAW to Bronze
9. □ Configure clustering based on query patterns
10. □ Implement monitoring and alerting
11. □ Test data loading and validation processes
12. □ Document operational procedures

=============================================================================
SUCCESS CRITERIA:
=============================================================================

- All Bronze layer tables created successfully
- Table structure matches source RAW layer
- Metadata columns added for audit trail
- Data quality monitoring framework in place
- Security framework documented and ready for implementation
- Performance optimization recommendations documented
- Complete data lineage tracking capability

=============================================================================
*/