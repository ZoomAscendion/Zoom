_____________________________________________
-- Author: AAVA
-- Created on: 2024
-- Description: Bronze Layer Physical Data Model for Zoom Platform Analytics System
-- Version: 1
-- Updated on: 2024
-- Database: DB_POC_ZOOM
-- Schema: BRONZE
-- Compatible with: Snowflake SQL
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

CREATE TABLE IF NOT EXISTS BRONZE.bz_audit_log (
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
CREATE TABLE IF NOT EXISTS BRONZE.bz_billing_events (
    event_id STRING,
    user_id STRING,
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
CREATE TABLE IF NOT EXISTS BRONZE.bz_feature_usage (
    usage_id STRING,
    meeting_id STRING,
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
CREATE TABLE IF NOT EXISTS BRONZE.bz_licenses (
    license_id STRING,
    license_type STRING,
    assigned_to_user_id STRING,
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
CREATE TABLE IF NOT EXISTS BRONZE.bz_meetings (
    meeting_id STRING,
    host_id STRING,
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
CREATE TABLE IF NOT EXISTS BRONZE.bz_participants (
    participant_id STRING,
    meeting_id STRING,
    user_id STRING,
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
CREATE TABLE IF NOT EXISTS BRONZE.bz_support_tickets (
    ticket_id STRING,
    user_id STRING,
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
CREATE TABLE IF NOT EXISTS BRONZE.bz_users (
    user_id STRING,
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
CREATE TABLE IF NOT EXISTS BRONZE.bz_webinars (
    webinar_id STRING,
    host_id STRING,
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
COMMENT ON TABLE BRONZE.bz_audit_log IS 'Audit table for tracking Bronze layer data processing activities';
COMMENT ON TABLE BRONZE.bz_billing_events IS 'Bronze layer table containing raw billing and payment event data from source systems';
COMMENT ON TABLE BRONZE.bz_feature_usage IS 'Bronze layer table containing raw feature usage data during meetings';
COMMENT ON TABLE BRONZE.bz_licenses IS 'Bronze layer table containing raw license assignment and validity data';
COMMENT ON TABLE BRONZE.bz_meetings IS 'Bronze layer table containing raw meeting information and duration data';
COMMENT ON TABLE BRONZE.bz_participants IS 'Bronze layer table containing raw participant join/leave data for meetings';
COMMENT ON TABLE BRONZE.bz_support_tickets IS 'Bronze layer table containing raw customer support ticket information';
COMMENT ON TABLE BRONZE.bz_users IS 'Bronze layer table containing raw user account and profile information';
COMMENT ON TABLE BRONZE.bz_webinars IS 'Bronze layer table containing raw webinar data including registrant information';

-- =====================================================
-- 4. BRONZE LAYER COLUMN COMMENTS
-- =====================================================

-- Audit Log Table Column Comments
COMMENT ON COLUMN BRONZE.bz_audit_log.record_id IS 'Auto-incrementing unique identifier for audit records';
COMMENT ON COLUMN BRONZE.bz_audit_log.source_table IS 'Name of the source table being processed';
COMMENT ON COLUMN BRONZE.bz_audit_log.load_timestamp IS 'Timestamp when the data processing occurred';
COMMENT ON COLUMN BRONZE.bz_audit_log.processed_by IS 'System or user that processed the data';
COMMENT ON COLUMN BRONZE.bz_audit_log.processing_time IS 'Time taken to process the data in seconds';
COMMENT ON COLUMN BRONZE.bz_audit_log.status IS 'Status of the data processing (SUCCESS, FAILED, IN_PROGRESS)';

-- Billing Events Table Column Comments
COMMENT ON COLUMN BRONZE.bz_billing_events.event_id IS 'Unique identifier for each billing event';
COMMENT ON COLUMN BRONZE.bz_billing_events.user_id IS 'Reference to the user associated with the billing event';
COMMENT ON COLUMN BRONZE.bz_billing_events.event_type IS 'Type of billing event (subscription, payment, refund, etc.)';
COMMENT ON COLUMN BRONZE.bz_billing_events.amount IS 'Monetary amount associated with the billing event';
COMMENT ON COLUMN BRONZE.bz_billing_events.event_date IS 'Date when the billing event occurred';

-- Feature Usage Table Column Comments
COMMENT ON COLUMN BRONZE.bz_feature_usage.usage_id IS 'Unique identifier for each feature usage record';
COMMENT ON COLUMN BRONZE.bz_feature_usage.meeting_id IS 'Reference to the meeting where the feature was used';
COMMENT ON COLUMN BRONZE.bz_feature_usage.feature_name IS 'Name of the feature that was used';
COMMENT ON COLUMN BRONZE.bz_feature_usage.usage_count IS 'Number of times the feature was used';
COMMENT ON COLUMN BRONZE.bz_feature_usage.usage_date IS 'Date when the feature was used';

-- Licenses Table Column Comments
COMMENT ON COLUMN BRONZE.bz_licenses.license_id IS 'Unique identifier for each license';
COMMENT ON COLUMN BRONZE.bz_licenses.license_type IS 'Type of license (Basic, Pro, Business, Enterprise)';
COMMENT ON COLUMN BRONZE.bz_licenses.assigned_to_user_id IS 'User ID to whom the license is assigned';
COMMENT ON COLUMN BRONZE.bz_licenses.start_date IS 'Date when the license becomes active';
COMMENT ON COLUMN BRONZE.bz_licenses.end_date IS 'Date when the license expires';

-- Meetings Table Column Comments
COMMENT ON COLUMN BRONZE.bz_meetings.meeting_id IS 'Unique identifier for each meeting';
COMMENT ON COLUMN BRONZE.bz_meetings.host_id IS 'User ID of the meeting host';
COMMENT ON COLUMN BRONZE.bz_meetings.meeting_topic IS 'Topic or title of the meeting';
COMMENT ON COLUMN BRONZE.bz_meetings.start_time IS 'Timestamp when the meeting started';
COMMENT ON COLUMN BRONZE.bz_meetings.end_time IS 'Timestamp when the meeting ended';
COMMENT ON COLUMN BRONZE.bz_meetings.duration_minutes IS 'Duration of the meeting in minutes';

-- Participants Table Column Comments
COMMENT ON COLUMN BRONZE.bz_participants.participant_id IS 'Unique identifier for each participant record';
COMMENT ON COLUMN BRONZE.bz_participants.meeting_id IS 'Reference to the meeting the participant joined';
COMMENT ON COLUMN BRONZE.bz_participants.user_id IS 'User ID of the participant';
COMMENT ON COLUMN BRONZE.bz_participants.join_time IS 'Timestamp when the participant joined the meeting';
COMMENT ON COLUMN BRONZE.bz_participants.leave_time IS 'Timestamp when the participant left the meeting';

-- Support Tickets Table Column Comments
COMMENT ON COLUMN BRONZE.bz_support_tickets.ticket_id IS 'Unique identifier for each support ticket';
COMMENT ON COLUMN BRONZE.bz_support_tickets.user_id IS 'User ID who created the support ticket';
COMMENT ON COLUMN BRONZE.bz_support_tickets.ticket_type IS 'Type or category of the support ticket';
COMMENT ON COLUMN BRONZE.bz_support_tickets.resolution_status IS 'Current status of the ticket resolution';
COMMENT ON COLUMN BRONZE.bz_support_tickets.open_date IS 'Date when the support ticket was opened';

-- Users Table Column Comments
COMMENT ON COLUMN BRONZE.bz_users.user_id IS 'Unique identifier for each user account';
COMMENT ON COLUMN BRONZE.bz_users.user_name IS 'Display name of the user';
COMMENT ON COLUMN BRONZE.bz_users.email IS 'Email address of the user';
COMMENT ON COLUMN BRONZE.bz_users.company IS 'Company or organization the user belongs to';
COMMENT ON COLUMN BRONZE.bz_users.plan_type IS 'Type of subscription plan the user has';

-- Webinars Table Column Comments
COMMENT ON COLUMN BRONZE.bz_webinars.webinar_id IS 'Unique identifier for each webinar';
COMMENT ON COLUMN BRONZE.bz_webinars.host_id IS 'User ID of the webinar host';
COMMENT ON COLUMN BRONZE.bz_webinars.webinar_topic IS 'Topic or title of the webinar';
COMMENT ON COLUMN BRONZE.bz_webinars.start_time IS 'Timestamp when the webinar started';
COMMENT ON COLUMN BRONZE.bz_webinars.end_time IS 'Timestamp when the webinar ended';
COMMENT ON COLUMN BRONZE.bz_webinars.registrants IS 'Number of users registered for the webinar';

-- Common Metadata Column Comments (Applied to all data tables)
-- Note: These comments apply to all Bronze layer data tables
-- load_timestamp: Timestamp when the record was loaded into the Bronze layer
-- update_timestamp: Timestamp when the record was last updated in the Bronze layer
-- source_system: System from which the data originated (e.g., 'ZOOM_API', 'BILLING_SYSTEM', etc.)

-- =====================================================
-- 5. BRONZE LAYER IMPLEMENTATION NOTES
-- =====================================================

/*
BRONZE LAYER IMPLEMENTATION GUIDELINES:

1. DATA INGESTION:
   - All tables are designed for raw data ingestion from source systems
   - No data transformations should be applied at this layer
   - Preserve original data types and formats where possible

2. NAMING CONVENTIONS:
   - Schema: BRONZE
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