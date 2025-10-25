_____________________________________________
## *Author*: AAVA
## *Created on*: [Leave empty]
## *Description*: Bronze Layer Physical Data Model for Zoom Platform Analytics System
## *Version*: 1
## *Updated on*: [Leave empty]
_____________________________________________

-- =====================================================
-- BRONZE LAYER PHYSICAL DATA MODEL
-- Zoom Platform Analytics System
-- =====================================================

-- Create Bronze Schema
CREATE SCHEMA IF NOT EXISTS BRONZE;

-- =====================================================
-- 1. BRONZE LAYER DDL SCRIPTS
-- =====================================================

-- -----------------------------------------------------
-- Table: BRONZE.bz_users
-- Description: Bronze layer table for user account and profile information
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS BRONZE.bz_users (
    user_id STRING COMMENT 'Unique identifier for each user account',
    user_name STRING COMMENT 'Display name of the user',
    email STRING COMMENT 'Email address of the user',
    company STRING COMMENT 'Company or organization the user belongs to',
    plan_type STRING COMMENT 'Type of subscription plan the user has',
    load_timestamp TIMESTAMP_NTZ COMMENT 'Timestamp when the record was loaded into the system',
    update_timestamp TIMESTAMP_NTZ COMMENT 'Timestamp when the record was last updated',
    source_system STRING COMMENT 'System from which the data originated'
);

-- -----------------------------------------------------
-- Table: BRONZE.bz_meetings
-- Description: Bronze layer table for core meeting information and duration data
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS BRONZE.bz_meetings (
    meeting_id STRING COMMENT 'Unique identifier for each meeting',
    host_id STRING COMMENT 'User ID of the meeting host',
    meeting_topic STRING COMMENT 'Topic or title of the meeting',
    start_time TIMESTAMP_NTZ COMMENT 'Timestamp when the meeting started',
    end_time TIMESTAMP_NTZ COMMENT 'Timestamp when the meeting ended',
    duration_minutes NUMBER COMMENT 'Duration of the meeting in minutes',
    load_timestamp TIMESTAMP_NTZ COMMENT 'Timestamp when the record was loaded into the system',
    update_timestamp TIMESTAMP_NTZ COMMENT 'Timestamp when the record was last updated',
    source_system STRING COMMENT 'System from which the data originated'
);

-- -----------------------------------------------------
-- Table: BRONZE.bz_participants
-- Description: Bronze layer table for participant join/leave times for meetings
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS BRONZE.bz_participants (
    participant_id STRING COMMENT 'Unique identifier for each participant record',
    meeting_id STRING COMMENT 'Reference to the meeting the participant joined',
    user_id STRING COMMENT 'User ID of the participant',
    join_time TIMESTAMP_NTZ COMMENT 'Timestamp when the participant joined the meeting',
    leave_time TIMESTAMP_NTZ COMMENT 'Timestamp when the participant left the meeting',
    load_timestamp TIMESTAMP_NTZ COMMENT 'Timestamp when the record was loaded into the system',
    update_timestamp TIMESTAMP_NTZ COMMENT 'Timestamp when the record was last updated',
    source_system STRING COMMENT 'System from which the data originated'
);

-- -----------------------------------------------------
-- Table: BRONZE.bz_feature_usage
-- Description: Bronze layer table for tracking usage of various Zoom features during meetings
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS BRONZE.bz_feature_usage (
    usage_id STRING COMMENT 'Unique identifier for each feature usage record',
    meeting_id STRING COMMENT 'Reference to the meeting where the feature was used',
    feature_name STRING COMMENT 'Name of the feature that was used',
    usage_count NUMBER COMMENT 'Number of times the feature was used',
    usage_date DATE COMMENT 'Date when the feature was used',
    load_timestamp TIMESTAMP_NTZ COMMENT 'Timestamp when the record was loaded into the system',
    update_timestamp TIMESTAMP_NTZ COMMENT 'Timestamp when the record was last updated',
    source_system STRING COMMENT 'System from which the data originated'
);

-- -----------------------------------------------------
-- Table: BRONZE.bz_support_tickets
-- Description: Bronze layer table for customer support ticket information
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS BRONZE.bz_support_tickets (
    ticket_id STRING COMMENT 'Unique identifier for each support ticket',
    user_id STRING COMMENT 'User ID who created the support ticket',
    ticket_type STRING COMMENT 'Type or category of the support ticket',
    resolution_status STRING COMMENT 'Current status of the ticket resolution',
    open_date DATE COMMENT 'Date when the support ticket was opened',
    load_timestamp TIMESTAMP_NTZ COMMENT 'Timestamp when the record was loaded into the system',
    update_timestamp TIMESTAMP_NTZ COMMENT 'Timestamp when the record was last updated',
    source_system STRING COMMENT 'System from which the data originated'
);

-- -----------------------------------------------------
-- Table: BRONZE.bz_billing_events
-- Description: Bronze layer table for billing and payment event data
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS BRONZE.bz_billing_events (
    event_id STRING COMMENT 'Unique identifier for each billing event',
    user_id STRING COMMENT 'Reference to the user associated with the billing event',
    event_type STRING COMMENT 'Type of billing event (subscription, payment, refund, etc.)',
    amount NUMBER(10,2) COMMENT 'Monetary amount associated with the billing event',
    event_date DATE COMMENT 'Date when the billing event occurred',
    load_timestamp TIMESTAMP_NTZ COMMENT 'Timestamp when the record was loaded into the system',
    update_timestamp TIMESTAMP_NTZ COMMENT 'Timestamp when the record was last updated',
    source_system STRING COMMENT 'System from which the data originated'
);

-- -----------------------------------------------------
-- Table: BRONZE.bz_licenses
-- Description: Bronze layer table for license assignments and validity periods
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS BRONZE.bz_licenses (
    license_id STRING COMMENT 'Unique identifier for each license',
    license_type STRING COMMENT 'Type of license (Basic, Pro, Business, Enterprise)',
    assigned_to_user_id STRING COMMENT 'User ID to whom the license is assigned',
    start_date DATE COMMENT 'Date when the license becomes active',
    end_date DATE COMMENT 'Date when the license expires',
    load_timestamp TIMESTAMP_NTZ COMMENT 'Timestamp when the record was loaded into the system',
    update_timestamp TIMESTAMP_NTZ COMMENT 'Timestamp when the record was last updated',
    source_system STRING COMMENT 'System from which the data originated'
);

-- -----------------------------------------------------
-- Table: BRONZE.bz_webinars
-- Description: Bronze layer table for webinar-specific data including registrant counts
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS BRONZE.bz_webinars (
    webinar_id STRING COMMENT 'Unique identifier for each webinar',
    host_id STRING COMMENT 'User ID of the webinar host',
    webinar_topic STRING COMMENT 'Topic or title of the webinar',
    start_time TIMESTAMP_NTZ COMMENT 'Timestamp when the webinar started',
    end_time TIMESTAMP_NTZ COMMENT 'Timestamp when the webinar ended',
    registrants NUMBER COMMENT 'Number of users registered for the webinar',
    load_timestamp TIMESTAMP_NTZ COMMENT 'Timestamp when the record was loaded into the system',
    update_timestamp TIMESTAMP_NTZ COMMENT 'Timestamp when the record was last updated',
    source_system STRING COMMENT 'System from which the data originated'
);

-- -----------------------------------------------------
-- Table: BRONZE.bz_audit_records
-- Description: Audit table for tracking data processing and lineage
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS BRONZE.bz_audit_records (
    record_id NUMBER AUTOINCREMENT COMMENT 'Auto-incrementing unique identifier for each audit record',
    source_table STRING COMMENT 'Name of the source table being processed',
    load_timestamp TIMESTAMP_NTZ COMMENT 'Timestamp when the data load process started',
    processed_by STRING COMMENT 'User or system that processed the data',
    processing_time NUMBER COMMENT 'Time taken to process the data in seconds',
    status STRING COMMENT 'Status of the data processing (SUCCESS, FAILED, IN_PROGRESS)'
);

-- =====================================================
-- BRONZE LAYER TABLE SUMMARY
-- =====================================================
/*
The Bronze Layer contains the following tables:

• BRONZE.bz_users - User account and profile information
• BRONZE.bz_meetings - Core meeting information and duration data
• BRONZE.bz_participants - Participant join/leave times for meetings
• BRONZE.bz_feature_usage - Usage tracking of various Zoom features during meetings
• BRONZE.bz_support_tickets - Customer support ticket information
• BRONZE.bz_billing_events - Billing and payment event data
• BRONZE.bz_licenses - License assignments and validity periods
• BRONZE.bz_webinars - Webinar-specific data including registrant counts
• BRONZE.bz_audit_records - Audit table for data processing and lineage tracking

Key Features:
• All tables use Snowflake-compatible data types (STRING, NUMBER, DATE, TIMESTAMP_NTZ)
• No primary keys, foreign keys, indexes, clustering keys, or constraints as per Bronze layer requirements
• All ID fields from the raw schema are preserved
• Standard metadata columns included: load_timestamp, update_timestamp, source_system
• CREATE TABLE IF NOT EXISTS syntax for safe deployment
• Comprehensive comments for documentation and maintenance
• Follows bz_ naming convention for Bronze layer tables
*/

-- =====================================================
-- END OF BRONZE LAYER PHYSICAL DATA MODEL
-- =====================================================