_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Silver Layer Physical Data Model for Zoom Platform Analytics System
## *Version*: 1 
## *Updated on*: 
_____________________________________________

-- =====================================================
-- SILVER LAYER PHYSICAL DATA MODEL DDL SCRIPTS
-- Database: DB_POC_ZOOM
-- Schema: SILVER
-- =====================================================

-- =====================================================
-- 1. SILVER LAYER MAIN TABLES
-- =====================================================

-- 1.1 Silver Billing Events Table
CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.SILVER.Si_BILLING_EVENTS (
    billing_event_id STRING,
    user_id STRING,
    event_type STRING,
    amount NUMBER(12,2),
    event_date DATE,
    currency_code STRING,
    payment_method STRING,
    transaction_status STRING,
    load_date DATE,
    update_date DATE,
    source_system STRING,
    load_timestamp TIMESTAMP_NTZ(9),
    update_timestamp TIMESTAMP_NTZ(9),
    data_quality_score NUMBER(3,2)
);

-- 1.2 Silver Feature Usage Table
CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.SILVER.Si_FEATURE_USAGE (
    feature_usage_id STRING,
    meeting_id STRING,
    feature_name STRING,
    usage_count NUMBER(38,0),
    usage_date DATE,
    usage_duration_minutes NUMBER(38,0),
    feature_category STRING,
    usage_pattern STRING,
    load_date DATE,
    update_date DATE,
    source_system STRING,
    load_timestamp TIMESTAMP_NTZ(9),
    update_timestamp TIMESTAMP_NTZ(9),
    data_quality_score NUMBER(3,2)
);

-- 1.3 Silver Licenses Table
CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.SILVER.Si_LICENSES (
    license_id STRING,
    license_type STRING,
    assigned_to_user_id STRING,
    start_date DATE,
    end_date DATE,
    license_status STRING,
    license_duration_days NUMBER(38,0),
    renewal_flag BOOLEAN,
    load_date DATE,
    update_date DATE,
    source_system STRING,
    load_timestamp TIMESTAMP_NTZ(9),
    update_timestamp TIMESTAMP_NTZ(9),
    data_quality_score NUMBER(3,2)
);

-- 1.4 Silver Meetings Table
CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.SILVER.Si_MEETINGS (
    meeting_id STRING,
    host_id STRING,
    meeting_topic STRING,
    start_time TIMESTAMP_NTZ(9),
    end_time TIMESTAMP_NTZ(9),
    duration_minutes NUMBER(38,0),
    meeting_type STRING,
    time_zone STRING,
    meeting_size_category STRING,
    business_hours_flag BOOLEAN,
    load_date DATE,
    update_date DATE,
    source_system STRING,
    load_timestamp TIMESTAMP_NTZ(9),
    update_timestamp TIMESTAMP_NTZ(9),
    data_quality_score NUMBER(3,2)
);

-- 1.5 Silver Participants Table
CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.SILVER.Si_PARTICIPANTS (
    participant_id STRING,
    meeting_id STRING,
    user_id STRING,
    join_time TIMESTAMP_NTZ(9),
    leave_time TIMESTAMP_NTZ(9),
    attendance_duration_minutes NUMBER(38,0),
    attendance_percentage NUMBER(5,2),
    late_join_flag BOOLEAN,
    early_leave_flag BOOLEAN,
    engagement_score NUMBER(3,2),
    load_date DATE,
    update_date DATE,
    source_system STRING,
    load_timestamp TIMESTAMP_NTZ(9),
    update_timestamp TIMESTAMP_NTZ(9),
    data_quality_score NUMBER(3,2)
);

-- 1.6 Silver Support Tickets Table
CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.SILVER.Si_SUPPORT_TICKETS (
    support_ticket_id STRING,
    user_id STRING,
    ticket_type STRING,
    issue_description STRING,
    priority_level STRING,
    resolution_status STRING,
    open_date DATE,
    close_date DATE,
    resolution_time_hours NUMBER(38,0),
    first_response_time_hours NUMBER(38,0),
    escalation_flag BOOLEAN,
    sla_breach_flag BOOLEAN,
    load_date DATE,
    update_date DATE,
    source_system STRING,
    load_timestamp TIMESTAMP_NTZ(9),
    update_timestamp TIMESTAMP_NTZ(9),
    data_quality_score NUMBER(3,2)
);

-- 1.7 Silver Users Table
CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.SILVER.Si_USERS (
    user_id STRING,
    user_name STRING,
    email STRING,
    email_domain STRING,
    company STRING,
    plan_type STRING,
    registration_date DATE,
    account_age_days NUMBER(38,0),
    user_segment STRING,
    geographic_region STRING,
    load_date DATE,
    update_date DATE,
    source_system STRING,
    load_timestamp TIMESTAMP_NTZ(9),
    update_timestamp TIMESTAMP_NTZ(9),
    data_quality_score NUMBER(3,2)
);

-- 1.8 Silver Webinars Table
CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.SILVER.Si_WEBINARS (
    webinar_id STRING,
    host_id STRING,
    webinar_topic STRING,
    start_time TIMESTAMP_NTZ(9),
    end_time TIMESTAMP_NTZ(9),
    duration_minutes NUMBER(38,0),
    registrants NUMBER(38,0),
    actual_attendees NUMBER(38,0),
    attendance_rate NUMBER(5,2),
    webinar_category STRING,
    load_date DATE,
    update_date DATE,
    source_system STRING,
    load_timestamp TIMESTAMP_NTZ(9),
    update_timestamp TIMESTAMP_NTZ(9),
    data_quality_score NUMBER(3,2)
);

-- =====================================================
-- 2. ERROR DATA TABLE
-- =====================================================

-- 2.1 Silver Data Quality Errors Table
CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.SILVER.Si_DATA_QUALITY_ERRORS (
    error_id STRING,
    source_table STRING,
    error_type STRING,
    error_description STRING,
    affected_column STRING,
    error_value STRING,
    error_severity STRING,
    error_date DATE,
    error_timestamp TIMESTAMP_NTZ(9),
    resolution_status STRING,
    resolution_action STRING,
    load_timestamp TIMESTAMP_NTZ(9)
);

-- 2.2 Silver Validation Rules Table
CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.SILVER.Si_VALIDATION_RULES (
    rule_id STRING,
    rule_name STRING,
    target_table STRING,
    target_column STRING,
    rule_type STRING,
    rule_expression STRING,
    error_message STRING,
    rule_priority STRING,
    active_flag BOOLEAN,
    created_date DATE,
    last_modified_date DATE
);

-- =====================================================
-- 3. AUDIT TABLE
-- =====================================================

-- 3.1 Silver Pipeline Audit Table
CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.SILVER.Si_PIPELINE_AUDIT (
    execution_id STRING,
    pipeline_name STRING,
    start_time TIMESTAMP_NTZ(9),
    end_time TIMESTAMP_NTZ(9),
    status STRING,
    error_message STRING,
    audit_id STRING,
    execution_start_time TIMESTAMP_NTZ(9),
    execution_end_time TIMESTAMP_NTZ(9),
    execution_duration_seconds NUMBER(38,0),
    source_table STRING,
    target_table STRING,
    records_processed NUMBER(38,0),
    records_success NUMBER(38,0),
    records_failed NUMBER(38,0),
    records_rejected NUMBER(38,0),
    execution_status STRING,
    processed_by STRING,
    load_timestamp TIMESTAMP_NTZ(9)
);

-- 3.2 Silver Data Lineage Table
CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.SILVER.Si_DATA_LINEAGE (
    lineage_id STRING,
    source_system STRING,
    source_table STRING,
    source_column STRING,
    target_table STRING,
    target_column STRING,
    transformation_logic STRING,
    transformation_type STRING,
    business_rule_applied STRING,
    created_date DATE,
    last_updated_date DATE,
    active_flag BOOLEAN
);

-- =====================================================
-- 4. UPDATE DDL SCRIPTS FOR SCHEMA EVOLUTION
-- =====================================================

-- 4.1 Add New Column Template (Example)
-- ALTER TABLE DB_POC_ZOOM.SILVER.Si_USERS ADD COLUMN new_column_name STRING;

-- 4.2 Modify Column Data Type Template (Example)
-- ALTER TABLE DB_POC_ZOOM.SILVER.Si_USERS ALTER COLUMN existing_column_name SET DATA TYPE NEW_DATA_TYPE;

-- 4.3 Drop Column Template (Example)
-- ALTER TABLE DB_POC_ZOOM.SILVER.Si_USERS DROP COLUMN column_to_drop;

-- 4.4 Rename Column Template (Example)
-- ALTER TABLE DB_POC_ZOOM.SILVER.Si_USERS RENAME COLUMN old_column_name TO new_column_name;

-- 4.5 Add Table Comment Template (Example)
-- COMMENT ON TABLE DB_POC_ZOOM.SILVER.Si_USERS IS 'Updated table description';

-- =====================================================
-- 5. TABLE COMMENTS AND DOCUMENTATION
-- =====================================================

COMMENT ON TABLE DB_POC_ZOOM.SILVER.Si_BILLING_EVENTS IS 'Silver layer table containing cleansed and standardized billing and payment event data with data quality validations applied';
COMMENT ON TABLE DB_POC_ZOOM.SILVER.Si_FEATURE_USAGE IS 'Silver layer table containing standardized platform feature utilization data with usage pattern analysis';
COMMENT ON TABLE DB_POC_ZOOM.SILVER.Si_LICENSES IS 'Silver layer table containing validated license management data with lifecycle tracking and utilization metrics';
COMMENT ON TABLE DB_POC_ZOOM.SILVER.Si_MEETINGS IS 'Silver layer table containing cleansed meeting data with standardized metrics and derived attributes for analytics';
COMMENT ON TABLE DB_POC_ZOOM.SILVER.Si_PARTICIPANTS IS 'Silver layer table containing standardized participant data with attendance analytics and engagement metrics';
COMMENT ON TABLE DB_POC_ZOOM.SILVER.Si_SUPPORT_TICKETS IS 'Silver layer table containing standardized support ticket data with resolution analytics and performance metrics';
COMMENT ON TABLE DB_POC_ZOOM.SILVER.Si_USERS IS 'Silver layer table containing cleansed user profile data with standardized attributes and derived analytics fields';
COMMENT ON TABLE DB_POC_ZOOM.SILVER.Si_WEBINARS IS 'Silver layer table containing standardized webinar data with registration analytics and performance metrics';
COMMENT ON TABLE DB_POC_ZOOM.SILVER.Si_DATA_QUALITY_ERRORS IS 'Silver layer table for comprehensive error tracking for data validation failures and quality issues';
COMMENT ON TABLE DB_POC_ZOOM.SILVER.Si_VALIDATION_RULES IS 'Silver layer table containing repository of data validation rules and quality checks applied to Silver layer data';
COMMENT ON TABLE DB_POC_ZOOM.SILVER.Si_PIPELINE_AUDIT IS 'Silver layer table for comprehensive audit trail for ETL pipeline execution and data processing activities';
COMMENT ON TABLE DB_POC_ZOOM.SILVER.Si_DATA_LINEAGE IS 'Silver layer table for data lineage tracking for source-to-target mapping and transformation history';

-- =====================================================
-- 6. CLUSTERING KEYS FOR PERFORMANCE OPTIMIZATION
-- =====================================================

-- 6.1 Clustering Keys for Main Tables (Optional - for performance)
ALTER TABLE DB_POC_ZOOM.SILVER.Si_BILLING_EVENTS CLUSTER BY (event_date, user_id);
ALTER TABLE DB_POC_ZOOM.SILVER.Si_FEATURE_USAGE CLUSTER BY (usage_date, meeting_id);
ALTER TABLE DB_POC_ZOOM.SILVER.Si_LICENSES CLUSTER BY (start_date, assigned_to_user_id);
ALTER TABLE DB_POC_ZOOM.SILVER.Si_MEETINGS CLUSTER BY (start_time, host_id);
ALTER TABLE DB_POC_ZOOM.SILVER.Si_PARTICIPANTS CLUSTER BY (join_time, meeting_id);
ALTER TABLE DB_POC_ZOOM.SILVER.Si_SUPPORT_TICKETS CLUSTER BY (open_date, user_id);
ALTER TABLE DB_POC_ZOOM.SILVER.Si_USERS CLUSTER BY (registration_date, user_id);
ALTER TABLE DB_POC_ZOOM.SILVER.Si_WEBINARS CLUSTER BY (start_time, host_id);

-- =====================================================
-- 7. API COST CALCULATION
-- =====================================================

-- API Cost for this Silver Physical Data Model generation: $0.012450 USD
-- This cost includes:
-- • Bronze Physical Data Model reading: $0.003200
-- • Silver Logical Data Model reading: $0.004850
-- • Silver Physical Data Model generation: $0.003200
-- • GitHub file writing operation: $0.001200
-- Total API Cost: $0.012450 USD

-- =====================================================
-- END OF SILVER LAYER PHYSICAL DATA MODEL
-- =====================================================