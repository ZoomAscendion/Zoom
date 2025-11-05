_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze layer physical data model for Zoom Platform Analytics System with Snowflake-compatible DDL scripts
## *Version*: 1 
## *Updated on*: 
_____________________________________________

-- =====================================================
-- BRONZE LAYER PHYSICAL DATA MODEL
-- Zoom Platform Analytics System
-- Snowflake-Compatible DDL Scripts
-- =====================================================

-- 1. CREATE BRONZE SCHEMA
CREATE SCHEMA IF NOT EXISTS BRONZE;

-- 2. BRONZE LAYER TABLES DDL SCRIPTS

-- 2.1 Bronze Users Table
CREATE TABLE IF NOT EXISTS BRONZE.bz_users (
    user_id STRING,
    user_name STRING,
    email STRING,
    company STRING,
    plan_type STRING,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);

-- 2.2 Bronze Meetings Table
CREATE TABLE IF NOT EXISTS BRONZE.bz_meetings (
    meeting_id STRING,
    host_id STRING,
    meeting_topic STRING,
    start_time TIMESTAMP_NTZ,
    end_time TIMESTAMP_NTZ,
    duration_minutes NUMBER,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);

-- 2.3 Bronze Participants Table
CREATE TABLE IF NOT EXISTS BRONZE.bz_participants (
    participant_id STRING,
    meeting_id STRING,
    user_id STRING,
    join_time TIMESTAMP_NTZ,
    leave_time TIMESTAMP_NTZ,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);

-- 2.4 Bronze Feature Usage Table
CREATE TABLE IF NOT EXISTS BRONZE.bz_feature_usage (
    usage_id STRING,
    meeting_id STRING,
    feature_name STRING,
    usage_count NUMBER,
    usage_date DATE,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);

-- 2.5 Bronze Support Tickets Table
CREATE TABLE IF NOT EXISTS BRONZE.bz_support_tickets (
    ticket_id STRING,
    user_id STRING,
    ticket_type STRING,
    resolution_status STRING,
    open_date DATE,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);

-- 2.6 Bronze Billing Events Table
CREATE TABLE IF NOT EXISTS BRONZE.bz_billing_events (
    event_id STRING,
    user_id STRING,
    event_type STRING,
    amount NUMBER(10,2),
    event_date DATE,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);

-- 2.7 Bronze Licenses Table
CREATE TABLE IF NOT EXISTS BRONZE.bz_licenses (
    license_id STRING,
    license_type STRING,
    assigned_to_user_id STRING,
    start_date DATE,
    end_date DATE,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);

-- 3. AUDIT TABLE
CREATE TABLE IF NOT EXISTS BRONZE.bz_audit (
    record_id NUMBER AUTOINCREMENT,
    source_table STRING,
    load_timestamp TIMESTAMP_NTZ,
    processed_by STRING,
    processing_time NUMBER,
    status STRING
);

-- =====================================================
-- TABLE DESCRIPTIONS AND METADATA
-- =====================================================

/*
4. TABLE DESCRIPTIONS:

4.1 BRONZE.bz_users
- Purpose: Contains raw user account information from source systems
- Source: Zoom API, User Management System, Registration Portal
- Key Fields: user_id (unique identifier), email (unique), plan_type
- Data Types: All STRING except timestamps

4.2 BRONZE.bz_meetings
- Purpose: Contains raw meeting session data
- Source: Zoom API, Meeting Dashboard
- Key Fields: meeting_id (unique identifier), host_id (links to users)
- Data Types: STRING for IDs and text, TIMESTAMP_NTZ for times, NUMBER for duration

4.3 BRONZE.bz_participants
- Purpose: Contains raw participant data for meeting attendance
- Source: Zoom API, Participant Tracking System
- Key Fields: participant_id (unique), meeting_id (links to meetings), user_id (links to users)
- Data Types: STRING for IDs, TIMESTAMP_NTZ for join/leave times

4.4 BRONZE.bz_feature_usage
- Purpose: Contains raw feature usage tracking data
- Source: Zoom API, Analytics System
- Key Fields: usage_id (unique), meeting_id (links to meetings)
- Data Types: STRING for IDs and feature names, NUMBER for counts, DATE for usage date

4.5 BRONZE.bz_support_tickets
- Purpose: Contains raw customer support ticket information
- Source: Support Portal, CRM System, Email Integration
- Key Fields: ticket_id (unique), user_id (links to users)
- Data Types: STRING for IDs and status fields, DATE for dates

4.6 BRONZE.bz_billing_events
- Purpose: Contains raw billing and payment transaction data
- Source: Zoom API, Billing System, Manual Entry
- Key Fields: event_id (unique), user_id (links to users)
- Data Types: STRING for IDs and types, NUMBER(10,2) for monetary amounts, DATE for event date

4.7 BRONZE.bz_licenses
- Purpose: Contains raw license assignment and management data
- Source: Zoom Admin API, License Management System
- Key Fields: license_id (unique), assigned_to_user_id (links to users)
- Data Types: STRING for IDs and types, DATE for start/end dates

4.8 BRONZE.bz_audit
- Purpose: Tracks data processing activities and status for all Bronze layer operations
- Key Fields: record_id (auto-increment), source_table, status
- Data Types: NUMBER for IDs and processing time, STRING for table names and status, TIMESTAMP_NTZ for timestamps
*/

-- =====================================================
-- SNOWFLAKE COMPATIBILITY NOTES
-- =====================================================

/*
5. SNOWFLAKE COMPATIBILITY:

5.1 Data Types Used:
- STRING: Snowflake's variable-length string type (equivalent to VARCHAR)
- NUMBER: Snowflake's exact numeric type with optional precision and scale
- NUMBER(10,2): Specific precision for monetary amounts
- TIMESTAMP_NTZ: Timestamp without timezone (recommended for Bronze layer)
- DATE: Date only without time component
- AUTOINCREMENT: Snowflake's auto-incrementing sequence for unique IDs

5.2 Best Practices Implemented:
- No primary keys, foreign keys, or constraints (as per Bronze layer requirements)
- CREATE TABLE IF NOT EXISTS syntax for idempotent execution
- Consistent naming convention with 'bz_' prefix
- Metadata columns (load_timestamp, update_timestamp, source_system) for data lineage
- Appropriate data types for Snowflake optimization

5.3 Storage Format:
- Uses Snowflake's default micro-partitioned storage
- No external formats like Delta Lake specified
- Optimized for Snowflake's columnar storage and compression

5.4 Schema Organization:
- Bronze schema contains all raw data tables
- Audit table for tracking data processing activities
- Clear separation of concerns with dedicated tables for each entity
*/

-- =====================================================
-- END OF BRONZE LAYER PHYSICAL DATA MODEL
-- =====================================================