_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze Physical Data Model for Zoom Platform Analytics System
## *Version*: 1 
## *Updated on*: 
_____________________________________________

-- =============================================
-- BRONZE LAYER PHYSICAL DATA MODEL
-- Database: DB_POC_ZOOM
-- Schema: BRONZE
-- Medallion Architecture - Bronze Layer
-- =============================================

-- Create Bronze Schema if not exists
CREATE SCHEMA IF NOT EXISTS BRONZE;

-- =============================================
-- BRONZE LAYER TABLES
-- =============================================

-- 1. Bronze Billing Events Table
CREATE TABLE IF NOT EXISTS BRONZE.bz_billing_events (
    EVENT_ID VARCHAR(16777216),
    USER_ID VARCHAR(16777216),
    EVENT_TYPE VARCHAR(16777216),
    AMOUNT NUMBER(10,2),
    EVENT_DATE DATE,
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- 2. Bronze Feature Usage Table
CREATE TABLE IF NOT EXISTS BRONZE.bz_feature_usage (
    USAGE_ID VARCHAR(16777216),
    MEETING_ID VARCHAR(16777216),
    FEATURE_NAME VARCHAR(16777216),
    USAGE_COUNT NUMBER(38,0),
    USAGE_DATE DATE,
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- 3. Bronze Licenses Table
CREATE TABLE IF NOT EXISTS BRONZE.bz_licenses (
    LICENSE_ID VARCHAR(16777216),
    LICENSE_TYPE VARCHAR(16777216),
    ASSIGNED_TO_USER_ID VARCHAR(16777216),
    START_DATE DATE,
    END_DATE DATE,
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- 4. Bronze Meetings Table
CREATE TABLE IF NOT EXISTS BRONZE.bz_meetings (
    MEETING_ID VARCHAR(16777216),
    HOST_ID VARCHAR(16777216),
    MEETING_TOPIC VARCHAR(16777216),
    START_TIME TIMESTAMP_NTZ(9),
    END_TIME TIMESTAMP_NTZ(9),
    DURATION_MINUTES NUMBER(38,0),
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- 5. Bronze Participants Table
CREATE TABLE IF NOT EXISTS BRONZE.bz_participants (
    PARTICIPANT_ID VARCHAR(16777216),
    MEETING_ID VARCHAR(16777216),
    USER_ID VARCHAR(16777216),
    JOIN_TIME TIMESTAMP_NTZ(9),
    LEAVE_TIME TIMESTAMP_NTZ(9),
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- 6. Bronze Support Tickets Table
CREATE TABLE IF NOT EXISTS BRONZE.bz_support_tickets (
    TICKET_ID VARCHAR(16777216),
    USER_ID VARCHAR(16777216),
    TICKET_TYPE VARCHAR(16777216),
    RESOLUTION_STATUS VARCHAR(16777216),
    OPEN_DATE DATE,
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- 7. Bronze Users Table
CREATE TABLE IF NOT EXISTS BRONZE.bz_users (
    USER_ID VARCHAR(16777216),
    USER_NAME VARCHAR(16777216),
    EMAIL VARCHAR(16777216),
    COMPANY VARCHAR(16777216),
    PLAN_TYPE VARCHAR(16777216),
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- 8. Bronze Webinars Table
CREATE TABLE IF NOT EXISTS BRONZE.bz_webinars (
    WEBINAR_ID VARCHAR(16777216),
    HOST_ID VARCHAR(16777216),
    WEBINAR_TOPIC VARCHAR(16777216),
    START_TIME TIMESTAMP_NTZ(9),
    END_TIME TIMESTAMP_NTZ(9),
    REGISTRANTS NUMBER(38,0),
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ(9),
    SOURCE_SYSTEM VARCHAR(16777216)
);

-- =============================================
-- BRONZE LAYER AUDIT TABLE
-- =============================================

-- Bronze Audit Table for tracking data processing
CREATE TABLE IF NOT EXISTS BRONZE.bz_audit_table (
    RECORD_ID NUMBER AUTOINCREMENT,
    SOURCE_TABLE VARCHAR(16777216),
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    PROCESSED_BY VARCHAR(16777216),
    PROCESSING_TIME NUMBER,
    STATUS VARCHAR(16777216)
);

-- =============================================
-- BRONZE LAYER TABLE SUMMARY
-- =============================================

/*
• Bronze Layer Tables Created:
  ○ BRONZE.bz_billing_events - Billing event data from RAW layer
  ○ BRONZE.bz_feature_usage - Feature usage tracking data
  ○ BRONZE.bz_licenses - License management data
  ○ BRONZE.bz_meetings - Meeting information and metadata
  ○ BRONZE.bz_participants - Meeting participant details
  ○ BRONZE.bz_support_tickets - Support ticket tracking
  ○ BRONZE.bz_users - User account information
  ○ BRONZE.bz_webinars - Webinar data and statistics
  ○ BRONZE.bz_audit_table - Data processing audit trail

• Key Features:
  ○ All tables follow 'bz_' naming convention
  ○ No primary keys, foreign keys, or constraints as per requirements
  ○ Snowflake-compatible data types used
  ○ CREATE TABLE IF NOT EXISTS syntax implemented
  ○ Metadata columns preserved from RAW layer
  ○ Audit table with autoincrement record_id

• Data Types Used:
  ○ VARCHAR(16777216) - For string data
  ○ NUMBER(10,2) - For monetary amounts
  ○ NUMBER(38,0) - For integer counts
  ○ DATE - For date fields
  ○ TIMESTAMP_NTZ(9) - For timestamp fields
  ○ NUMBER AUTOINCREMENT - For audit table record_id

• Schema Mapping:
  ○ Source: RAW schema
  ○ Target: BRONZE schema
  ○ Follows Medallion Architecture principles
*/

-- End of Bronze Physical Data Model