_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze Layer Physical Data Model for Zoom Platform Analytics System following medallion architecture
## *Version*: 1 
## *Updated on*: 
_____________________________________________

-- =====================================================
-- BRONZE LAYER PHYSICAL DATA MODEL DDL SCRIPTS
-- Zoom Platform Analytics System
-- Medallion Architecture - Bronze Layer
-- =====================================================

-- Create Bronze Schema if not exists
CREATE SCHEMA IF NOT EXISTS DB_POC_ZOOM.BRONZE;

-- Use Bronze Schema
USE SCHEMA DB_POC_ZOOM.BRONZE;

-- =====================================================
-- 1. BRONZE LAYER AUDIT TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS Bronze.bz_audit_log (
    record_id NUMBER AUTOINCREMENT,
    source_table STRING,
    load_timestamp TIMESTAMP_NTZ,
    processed_by STRING,
    processing_time NUMBER,
    status STRING
);

-- =====================================================
-- 2. BRONZE LAYER DATA TABLES
-- =====================================================

-- -----------------------------------------------------
-- 2.1 Bronze Billing Events Table
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Bronze.bz_billing_events (
    event_type STRING,
    amount NUMBER(10,2),
    event_date DATE,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);

-- -----------------------------------------------------
-- 2.2 Bronze Feature Usage Table
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Bronze.bz_feature_usage (
    feature_name STRING,
    usage_count NUMBER(38,0),
    usage_date DATE,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);

-- -----------------------------------------------------
-- 2.3 Bronze Licenses Table
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Bronze.bz_licenses (
    license_type STRING,
    start_date DATE,
    end_date DATE,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);

-- -----------------------------------------------------
-- 2.4 Bronze Meetings Table
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Bronze.bz_meetings (
    meeting_topic STRING,
    start_time TIMESTAMP_NTZ,
    end_time TIMESTAMP_NTZ,
    duration_minutes NUMBER(38,0),
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);

-- -----------------------------------------------------
-- 2.5 Bronze Participants Table
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Bronze.bz_participants (
    join_time TIMESTAMP_NTZ,
    leave_time TIMESTAMP_NTZ,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);

-- -----------------------------------------------------
-- 2.6 Bronze Support Tickets Table
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Bronze.bz_support_tickets (
    ticket_type STRING,
    resolution_status STRING,
    open_date DATE,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);

-- -----------------------------------------------------
-- 2.7 Bronze Users Table
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Bronze.bz_users (
    user_name STRING,
    email STRING,
    company STRING,
    plan_type STRING,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);

-- -----------------------------------------------------
-- 2.8 Bronze Webinars Table
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Bronze.bz_webinars (
    webinar_topic STRING,
    start_time TIMESTAMP_NTZ,
    end_time TIMESTAMP_NTZ,
    registrants NUMBER(38,0),
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);

-- =====================================================
-- 3. BRONZE LAYER TABLE COMMENTS
-- =====================================================

-- Add table comments for documentation
COMMENT ON TABLE Bronze.bz_audit_log IS 'Audit table for tracking Bronze layer data processing activities';
COMMENT ON TABLE Bronze.bz_billing_events IS 'Bronze layer table containing raw billing and payment event data from source systems';
COMMENT ON TABLE Bronze.bz_feature_usage IS 'Bronze layer table containing raw feature usage data during meetings';
COMMENT ON TABLE Bronze.bz_licenses IS 'Bronze layer table containing raw license assignment and validity data';
COMMENT ON TABLE Bronze.bz_meetings IS 'Bronze layer table containing raw meeting information and duration data';
COMMENT ON TABLE Bronze.bz_participants IS 'Bronze layer table containing raw participant join/leave data for meetings';
COMMENT ON TABLE Bronze.bz_support_tickets IS 'Bronze layer table containing raw customer support ticket information';
COMMENT ON TABLE Bronze.bz_users IS 'Bronze layer table containing raw user account and profile information';
COMMENT ON TABLE Bronze.bz_webinars IS 'Bronze layer table containing raw webinar data including registrant information';

-- =====================================================
-- 4. BRONZE LAYER IMPLEMENTATION NOTES
-- =====================================================

/*
BRONZE LAYER IMPLEMENTATION GUIDELINES:

1. DATA INGESTION:
   - All tables are designed for raw data ingestion from source systems
   - No data transformations should be applied at this layer
   - Preserve original data types and formats where possible

2. NAMING CONVENTIONS:
   - Schema: Bronze
   - Table prefix: bz_
   - Column names: lowercase with underscores
   - Follow Snowflake SQL standards

3. DATA QUALITY:
   - No constraints applied (PRIMARY KEY, FOREIGN KEY, NOT NULL)
   - Data quality checks should be implemented in Silver layer
   - Audit logging captures all processing activities

4. METADATA MANAGEMENT:
   - All tables include standard metadata columns
   - load_timestamp: When data was ingested
   - update_timestamp: When data was last modified
   - source_system: Origin system identifier

5. SCALABILITY:
   - Tables designed for high-volume data ingestion
   - Use appropriate Snowflake data types for performance
   - Consider partitioning strategies for large tables

6. AUDIT TRAIL:
   - bz_audit_log table tracks all processing activities
   - Enables data lineage and troubleshooting
   - Supports compliance and governance requirements

7. DATA RETENTION:
   - Implement appropriate data retention policies
   - Consider archiving strategies for historical data
   - Align with business and regulatory requirements
*/

-- =====================================================
-- END OF BRONZE LAYER PHYSICAL DATA MODEL
-- =====================================================