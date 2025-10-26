_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze Layer Physical Data Model for Zoom Platform Analytics System
## *Version*: 1 
## *Updated on*: 
_____________________________________________

-- =====================================================
-- BRONZE LAYER PHYSICAL DATA MODEL DDL SCRIPTS
-- Database: DB_POC_ZOOM
-- Schema: BRONZE
-- =====================================================

-- 1. Bronze Billing Events Table
CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.BRONZE.bz_billing_events (
    user_id STRING,
    event_type STRING,
    amount NUMBER(10,2),
    event_date DATE,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);

-- 2. Bronze Feature Usage Table
CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.BRONZE.bz_feature_usage (
    meeting_id STRING,
    feature_name STRING,
    usage_count NUMBER(38,0),
    usage_date DATE,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);

-- 3. Bronze Licenses Table
CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.BRONZE.bz_licenses (
    license_type STRING,
    assigned_to_user_id STRING,
    start_date DATE,
    end_date DATE,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);

-- 4. Bronze Meetings Table
CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.BRONZE.bz_meetings (
    host_id STRING,
    meeting_topic STRING,
    start_time TIMESTAMP_NTZ,
    end_time TIMESTAMP_NTZ,
    duration_minutes NUMBER(38,0),
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);

-- 5. Bronze Participants Table
CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.BRONZE.bz_participants (
    meeting_id STRING,
    user_id STRING,
    join_time TIMESTAMP_NTZ,
    leave_time TIMESTAMP_NTZ,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);

-- 6. Bronze Support Tickets Table
CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.BRONZE.bz_support_tickets (
    user_id STRING,
    ticket_type STRING,
    resolution_status STRING,
    open_date DATE,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);

-- 7. Bronze Users Table
CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.BRONZE.bz_users (
    user_name STRING,
    email STRING,
    company STRING,
    plan_type STRING,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);

-- 8. Bronze Webinars Table
CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.BRONZE.bz_webinars (
    host_id STRING,
    webinar_topic STRING,
    start_time TIMESTAMP_NTZ,
    end_time TIMESTAMP_NTZ,
    registrants NUMBER(38,0),
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);

-- 9. Bronze Audit Table
CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.BRONZE.bz_audit_log (
    record_id NUMBER AUTOINCREMENT,
    source_table STRING,
    load_timestamp TIMESTAMP_NTZ,
    processed_by STRING,
    processing_time NUMBER,
    status STRING
);

-- =====================================================
-- BRONZE LAYER TABLE COMMENTS
-- =====================================================

COMMENT ON TABLE DB_POC_ZOOM.BRONZE.bz_billing_events IS 'Bronze layer table containing billing and payment event data from raw layer';
COMMENT ON TABLE DB_POC_ZOOM.BRONZE.bz_feature_usage IS 'Bronze layer table tracking usage of various Zoom features during meetings';
COMMENT ON TABLE DB_POC_ZOOM.BRONZE.bz_licenses IS 'Bronze layer table managing license assignments and validity periods';
COMMENT ON TABLE DB_POC_ZOOM.BRONZE.bz_meetings IS 'Bronze layer table containing core meeting information and duration data';
COMMENT ON TABLE DB_POC_ZOOM.BRONZE.bz_participants IS 'Bronze layer table tracking participant join/leave times for meetings';
COMMENT ON TABLE DB_POC_ZOOM.BRONZE.bz_support_tickets IS 'Bronze layer table containing customer support ticket information';
COMMENT ON TABLE DB_POC_ZOOM.BRONZE.bz_users IS 'Bronze layer table containing user account and profile information';
COMMENT ON TABLE DB_POC_ZOOM.BRONZE.bz_webinars IS 'Bronze layer table containing webinar-specific data including registrant counts';
COMMENT ON TABLE DB_POC_ZOOM.BRONZE.bz_audit_log IS 'Bronze layer audit table for tracking data processing activities';

-- =====================================================
-- END OF BRONZE LAYER PHYSICAL DATA MODEL
-- =====================================================