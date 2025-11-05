_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze layer physical data model for Zoom Platform Analytics System supporting raw data ingestion and audit tracking
## *Version*: 1 
## *Updated on*: 
_____________________________________________

-- =====================================================
-- Zoom Platform Analytics System - Bronze Layer Physical Data Model
-- =====================================================

-- 1. Bronze Layer DDL Scripts for Raw Data Storage
-- All tables store raw data as-is with metadata fields
-- Compatible with Snowflake SQL standards
-- No primary keys, foreign keys, or constraints for Bronze layer

-- =====================================================
-- 1.1 BZ_USERS Table
-- =====================================================
CREATE TABLE IF NOT EXISTS BRONZE.BZ_USERS (
    USER_ID STRING,
    USER_NAME STRING,
    EMAIL STRING,
    COMPANY STRING,
    PLAN_TYPE STRING,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM STRING
);

-- =====================================================
-- 1.2 BZ_MEETINGS Table
-- =====================================================
CREATE TABLE IF NOT EXISTS BRONZE.BZ_MEETINGS (
    MEETING_ID STRING,
    HOST_ID STRING,
    MEETING_TOPIC STRING,
    START_TIME TIMESTAMP_NTZ,
    END_TIME TIMESTAMP_NTZ,
    DURATION_MINUTES NUMBER,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM STRING
);

-- =====================================================
-- 1.3 BZ_PARTICIPANTS Table
-- =====================================================
CREATE TABLE IF NOT EXISTS BRONZE.BZ_PARTICIPANTS (
    PARTICIPANT_ID STRING,
    MEETING_ID STRING,
    USER_ID STRING,
    JOIN_TIME TIMESTAMP_NTZ,
    LEAVE_TIME TIMESTAMP_NTZ,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM STRING
);

-- =====================================================
-- 1.4 BZ_FEATURE_USAGE Table
-- =====================================================
CREATE TABLE IF NOT EXISTS BRONZE.BZ_FEATURE_USAGE (
    USAGE_ID STRING,
    MEETING_ID STRING,
    FEATURE_NAME STRING,
    USAGE_COUNT NUMBER,
    USAGE_DATE DATE,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM STRING
);

-- =====================================================
-- 1.5 BZ_SUPPORT_TICKETS Table
-- =====================================================
CREATE TABLE IF NOT EXISTS BRONZE.BZ_SUPPORT_TICKETS (
    TICKET_ID STRING,
    USER_ID STRING,
    TICKET_TYPE STRING,
    RESOLUTION_STATUS STRING,
    OPEN_DATE DATE,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM STRING
);

-- =====================================================
-- 1.6 BZ_BILLING_EVENTS Table
-- =====================================================
CREATE TABLE IF NOT EXISTS BRONZE.BZ_BILLING_EVENTS (
    EVENT_ID STRING,
    USER_ID STRING,
    EVENT_TYPE STRING,
    AMOUNT NUMBER(10,2),
    EVENT_DATE DATE,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM STRING
);

-- =====================================================
-- 1.7 BZ_LICENSES Table
-- =====================================================
CREATE TABLE IF NOT EXISTS BRONZE.BZ_LICENSES (
    LICENSE_ID STRING,
    LICENSE_TYPE STRING,
    ASSIGNED_TO_USER_ID STRING,
    START_DATE DATE,
    END_DATE DATE,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM STRING
);

-- =====================================================
-- 1.8 BZ_AUDIT_LOG Table (Audit Table)
-- =====================================================
CREATE TABLE IF NOT EXISTS BRONZE.BZ_AUDIT_LOG (
    RECORD_ID NUMBER AUTOINCREMENT,
    SOURCE_TABLE STRING,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    PROCESSED_BY STRING,
    PROCESSING_TIME NUMBER,
    STATUS STRING
);

-- =====================================================
-- 2. Data Type Mapping and Justification
-- =====================================================
/*
2.1 Snowflake Data Types Used:
   - STRING: Used instead of VARCHAR(16777216) for simplicity and flexibility
   - NUMBER: Used for numeric values, with precision specified where needed
   - TIMESTAMP_NTZ: Used for all timestamp fields (without timezone)
   - DATE: Used for date-only fields
   - BOOLEAN: Not used in this model as per source data

2.2 Bronze Layer Design Principles:
   - No primary keys, foreign keys, or constraints
   - Raw data preservation with metadata columns
   - Snowflake-compatible data types
   - Micro-partitioned storage (default Snowflake behavior)
   - Table names prefixed with 'BZ_' for Bronze layer identification

2.3 Metadata Columns Added to All Tables:
   - LOAD_TIMESTAMP: When record was first loaded
   - UPDATE_TIMESTAMP: When record was last updated
   - SOURCE_SYSTEM: Origin system of the data

2.4 Audit Table Features:
   - RECORD_ID with AUTOINCREMENT for unique identification
   - Tracks all data processing activities
   - Monitors load operations and system events
   - Supports data governance and compliance
*/

-- =====================================================
-- 3. Implementation Notes
-- =====================================================
/*
3.1 Schema Structure:
   - All tables created in BRONZE schema
   - Compatible with Snowflake SQL standards
   - Follows Medallion architecture principles

3.2 Data Loading Strategy:
   - Use COPY INTO commands for bulk loading
   - Implement incremental loading using LOAD_TIMESTAMP
   - Error handling through audit table logging

3.3 Performance Considerations:
   - Snowflake's automatic micro-partitioning
   - No clustering keys defined for Bronze layer
   - Consider partitioning on date fields for large tables

3.4 Security and Compliance:
   - PII fields preserved in raw format
   - Access control to be implemented at role level
   - Audit trail maintained for all operations

3.5 Data Quality:
   - Basic data validation during ingestion
   - Preserve raw data integrity
   - Quality checks to be implemented in Silver layer
*/

-- =====================================================
-- 4. Sample Usage Examples
-- =====================================================
/*
4.1 Data Loading Example:
COPY INTO BRONZE.BZ_USERS
FROM @raw_stage/users.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_DELIMITER = ',' SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

4.2 Audit Logging Example:
INSERT INTO BRONZE.BZ_AUDIT_LOG 
(SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS)
VALUES 
('BZ_USERS', CURRENT_TIMESTAMP(), 'ETL_PROCESS', 45.2, 'SUCCESS');

4.3 Incremental Loading Example:
SELECT * FROM BRONZE.BZ_USERS 
WHERE LOAD_TIMESTAMP > (SELECT MAX(LOAD_TIMESTAMP) FROM SILVER.USERS);
*/

-- =====================================================
-- End of Bronze Layer Physical Data Model
-- =====================================================