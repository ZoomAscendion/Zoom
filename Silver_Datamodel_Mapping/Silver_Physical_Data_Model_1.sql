_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Silver layer physical data model for Zoom Platform Analytics System supporting cleaned and validated data with error handling and audit tracking
## *Version*: 1 
## *Updated on*: 
_____________________________________________

-- =====================================================
-- Zoom Platform Analytics System - Silver Layer Physical Data Model
-- =====================================================

-- 1. Silver Layer DDL Scripts for Cleaned and Validated Data
-- All tables store cleansed data with enhanced metadata fields
-- Compatible with Snowflake SQL standards
-- No primary keys, foreign keys, or constraints as per Snowflake best practices
-- All Bronze layer columns preserved with additional Silver layer enhancements

-- =====================================================
-- 1.1 SI_USERS Table
-- =====================================================
CREATE TABLE IF NOT EXISTS SILVER.SI_USERS (
    USER_ID STRING,
    USER_NAME STRING,
    EMAIL STRING,
    COMPANY STRING,
    PLAN_TYPE STRING,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM STRING,
    DATA_QUALITY_SCORE DECIMAL(3,2),
    IS_ACTIVE BOOLEAN
);

-- =====================================================
-- 1.2 SI_MEETINGS Table
-- =====================================================
CREATE TABLE IF NOT EXISTS SILVER.SI_MEETINGS (
    MEETING_ID STRING,
    HOST_ID STRING,
    MEETING_TOPIC STRING,
    START_TIME TIMESTAMP_NTZ,
    END_TIME TIMESTAMP_NTZ,
    DURATION_MINUTES NUMBER,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM STRING,
    MEETING_STATUS STRING,
    IS_VALID_DURATION BOOLEAN
);

-- =====================================================
-- 1.3 SI_PARTICIPANTS Table
-- =====================================================
CREATE TABLE IF NOT EXISTS SILVER.SI_PARTICIPANTS (
    PARTICIPANT_ID STRING,
    MEETING_ID STRING,
    USER_ID STRING,
    JOIN_TIME TIMESTAMP_NTZ,
    LEAVE_TIME TIMESTAMP_NTZ,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM STRING,
    ATTENDANCE_DURATION_MINUTES NUMBER,
    ATTENDANCE_PERCENTAGE DECIMAL(5,2),
    IS_HOST BOOLEAN
);

-- =====================================================
-- 1.4 SI_FEATURE_USAGE Table
-- =====================================================
CREATE TABLE IF NOT EXISTS SILVER.SI_FEATURE_USAGE (
    USAGE_ID STRING,
    MEETING_ID STRING,
    FEATURE_NAME STRING,
    USAGE_COUNT NUMBER,
    USAGE_DATE DATE,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM STRING,
    FEATURE_CATEGORY STRING,
    USAGE_INTENSITY STRING
);

-- =====================================================
-- 1.5 SI_SUPPORT_TICKETS Table
-- =====================================================
CREATE TABLE IF NOT EXISTS SILVER.SI_SUPPORT_TICKETS (
    TICKET_ID STRING,
    USER_ID STRING,
    TICKET_TYPE STRING,
    RESOLUTION_STATUS STRING,
    OPEN_DATE DATE,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM STRING,
    PRIORITY_LEVEL STRING,
    IS_FIRST_CONTACT_RESOLUTION BOOLEAN
);

-- =====================================================
-- 1.6 SI_BILLING_EVENTS Table
-- =====================================================
CREATE TABLE IF NOT EXISTS SILVER.SI_BILLING_EVENTS (
    EVENT_ID STRING,
    USER_ID STRING,
    EVENT_TYPE STRING,
    AMOUNT NUMBER(12,2),
    EVENT_DATE DATE,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM STRING,
    CURRENCY_CODE STRING,
    IS_RECURRING BOOLEAN,
    REVENUE_CATEGORY STRING
);

-- =====================================================
-- 1.7 SI_LICENSES Table
-- =====================================================
CREATE TABLE IF NOT EXISTS SILVER.SI_LICENSES (
    LICENSE_ID STRING,
    LICENSE_TYPE STRING,
    ASSIGNED_TO_USER_ID STRING,
    START_DATE DATE,
    END_DATE DATE,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM STRING,
    LICENSE_STATUS STRING,
    DAYS_TO_EXPIRY NUMBER,
    IS_UTILIZED BOOLEAN
);

-- =====================================================
-- 2. Error Data Table
-- =====================================================

-- =====================================================
-- 2.1 SI_DATA_QUALITY_ERRORS Table
-- =====================================================
CREATE TABLE IF NOT EXISTS SILVER.SI_DATA_QUALITY_ERRORS (
    ERROR_ID STRING,
    SOURCE_TABLE STRING,
    SOURCE_RECORD_ID STRING,
    ERROR_TYPE STRING,
    ERROR_DESCRIPTION STRING,
    FIELD_NAME STRING,
    FIELD_VALUE STRING,
    EXPECTED_FORMAT STRING,
    ERROR_SEVERITY STRING,
    ERROR_TIMESTAMP TIMESTAMP_NTZ,
    PROCESSING_BATCH_ID STRING,
    IS_RESOLVED BOOLEAN,
    RESOLUTION_ACTION STRING,
    RESOLUTION_TIMESTAMP TIMESTAMP_NTZ
);

-- =====================================================
-- 2.2 SI_VALIDATION_RULES Table
-- =====================================================
CREATE TABLE IF NOT EXISTS SILVER.SI_VALIDATION_RULES (
    RULE_ID STRING,
    RULE_NAME STRING,
    TARGET_TABLE STRING,
    TARGET_FIELD STRING,
    RULE_TYPE STRING,
    RULE_EXPRESSION STRING,
    ERROR_MESSAGE STRING,
    IS_ACTIVE BOOLEAN,
    CREATED_DATE DATE,
    LAST_MODIFIED_DATE DATE
);

-- =====================================================
-- 3. Audit Table
-- =====================================================

-- =====================================================
-- 3.1 SI_PIPELINE_AUDIT Table
-- =====================================================
CREATE TABLE IF NOT EXISTS SILVER.SI_PIPELINE_AUDIT (
    AUDIT_ID STRING,
    PIPELINE_NAME STRING,
    EXECUTION_ID STRING,
    START_TIMESTAMP TIMESTAMP_NTZ,
    END_TIMESTAMP TIMESTAMP_NTZ,
    EXECUTION_STATUS STRING,
    SOURCE_TABLE STRING,
    TARGET_TABLE STRING,
    RECORDS_PROCESSED NUMBER,
    RECORDS_INSERTED NUMBER,
    RECORDS_UPDATED NUMBER,
    RECORDS_REJECTED NUMBER,
    ERROR_COUNT NUMBER,
    WARNING_COUNT NUMBER,
    PROCESSING_TIME_SECONDS DECIMAL(10,2),
    THROUGHPUT_RECORDS_PER_SECOND DECIMAL(10,2),
    DATA_VOLUME_MB DECIMAL(10,2),
    EXECUTED_BY STRING,
    EXECUTION_MODE STRING,
    ERROR_DETAILS STRING,
    PERFORMANCE_METRICS STRING
);

-- =====================================================
-- 3.2 SI_DATA_LINEAGE Table
-- =====================================================
CREATE TABLE IF NOT EXISTS SILVER.SI_DATA_LINEAGE (
    LINEAGE_ID STRING,
    SOURCE_SYSTEM STRING,
    SOURCE_TABLE STRING,
    SOURCE_RECORD_ID STRING,
    TARGET_TABLE STRING,
    TARGET_RECORD_ID STRING,
    TRANSFORMATION_TYPE STRING,
    TRANSFORMATION_RULES STRING,
    PROCESSING_TIMESTAMP TIMESTAMP_NTZ,
    DATA_QUALITY_SCORE DECIMAL(3,2),
    IS_CURRENT BOOLEAN,
    VERSION_NUMBER NUMBER
);

-- =====================================================
-- 4. Update DDL Scripts for Schema Evolution
-- =====================================================

-- =====================================================
-- 4.1 Add New Columns to Existing Tables
-- =====================================================
-- Example: Add new column to SI_USERS table
-- ALTER TABLE SILVER.SI_USERS ADD COLUMN NEW_FIELD STRING;

-- =====================================================
-- 4.2 Modify Existing Column Data Types
-- =====================================================
-- Example: Modify column data type
-- ALTER TABLE SILVER.SI_USERS ALTER COLUMN USER_NAME SET DATA TYPE VARCHAR(500);

-- =====================================================
-- 4.3 Add Clustering Keys for Performance
-- =====================================================
-- Cluster large tables on frequently filtered columns
ALTER TABLE SILVER.SI_MEETINGS CLUSTER BY (START_TIME, HOST_ID);
ALTER TABLE SILVER.SI_PARTICIPANTS CLUSTER BY (JOIN_TIME, MEETING_ID);
ALTER TABLE SILVER.SI_FEATURE_USAGE CLUSTER BY (USAGE_DATE, FEATURE_NAME);
ALTER TABLE SILVER.SI_SUPPORT_TICKETS CLUSTER BY (OPEN_DATE, TICKET_TYPE);
ALTER TABLE SILVER.SI_BILLING_EVENTS CLUSTER BY (EVENT_DATE, USER_ID);
ALTER TABLE SILVER.SI_LICENSES CLUSTER BY (START_DATE, LICENSE_TYPE);

-- =====================================================
-- 4.4 Create Views for Common Access Patterns
-- =====================================================
-- Active users view
CREATE OR REPLACE VIEW SILVER.VW_ACTIVE_USERS AS
SELECT 
    USER_ID,
    USER_NAME,
    EMAIL,
    COMPANY,
    PLAN_TYPE,
    DATA_QUALITY_SCORE
FROM SILVER.SI_USERS
WHERE IS_ACTIVE = TRUE;

-- Meeting summary view
CREATE OR REPLACE VIEW SILVER.VW_MEETING_SUMMARY AS
SELECT 
    m.MEETING_ID,
    m.MEETING_TOPIC,
    m.START_TIME,
    m.DURATION_MINUTES,
    m.MEETING_STATUS,
    COUNT(p.PARTICIPANT_ID) as PARTICIPANT_COUNT
FROM SILVER.SI_MEETINGS m
LEFT JOIN SILVER.SI_PARTICIPANTS p ON m.MEETING_ID = p.MEETING_ID
GROUP BY m.MEETING_ID, m.MEETING_TOPIC, m.START_TIME, m.DURATION_MINUTES, m.MEETING_STATUS;

-- =====================================================
-- 5. Data Type Mapping and Design Decisions
-- =====================================================
/*
5.1 Snowflake Data Types Used:
   - STRING: Used for all text fields for maximum flexibility
   - NUMBER: Used for numeric values with precision specified where needed
   - TIMESTAMP_NTZ: Used for all timestamp fields (without timezone)
   - DATE: Used for date-only fields
   - BOOLEAN: Used for flag fields
   - DECIMAL: Used for precise numeric calculations

5.2 Silver Layer Design Principles:
   - All Bronze layer columns preserved
   - Additional Silver layer enhancement columns added
   - No primary keys, foreign keys, or constraints as per Snowflake best practices
   - Cleansed and validated data with quality scores
   - Comprehensive error tracking and audit capabilities
   - Table names prefixed with 'SI_' for Silver layer identification

5.3 Enhanced Metadata Columns:
   - All Bronze columns maintained
   - DATA_QUALITY_SCORE: Quality assessment of cleansed data
   - IS_ACTIVE, IS_VALID_DURATION, IS_HOST: Business logic flags
   - MEETING_STATUS, FEATURE_CATEGORY, PRIORITY_LEVEL: Derived classifications
   - ATTENDANCE_DURATION_MINUTES, ATTENDANCE_PERCENTAGE: Calculated metrics

5.4 Error Handling Features:
   - Comprehensive error tracking with SI_DATA_QUALITY_ERRORS
   - Configurable validation rules with SI_VALIDATION_RULES
   - Full audit trail with SI_PIPELINE_AUDIT
   - Data lineage tracking with SI_DATA_LINEAGE

5.5 Performance Optimizations:
   - Clustering keys on frequently filtered columns
   - Views for common access patterns
   - Snowflake's automatic micro-partitioning utilized
   - Optimized data types for storage efficiency
*/

-- =====================================================
-- 6. Implementation Guidelines
-- =====================================================
/*
6.1 Data Loading Strategy:
   - Transform and validate data from Bronze to Silver
   - Implement data quality checks and scoring
   - Log all errors and processing metrics
   - Maintain data lineage for traceability

6.2 Quality Assurance:
   - Validate all data transformations
   - Monitor data quality scores
   - Track and resolve data quality errors
   - Implement automated data validation rules

6.3 Performance Monitoring:
   - Monitor clustering effectiveness
   - Track query performance metrics
   - Optimize warehouse sizing based on workload
   - Use result caching for repeated queries

6.4 Security Considerations:
   - Implement role-based access control
   - Apply data masking policies for sensitive data
   - Monitor access patterns and usage
   - Maintain audit logs for compliance

6.5 Maintenance Tasks:
   - Regular clustering maintenance
   - Monitor and clean up error tables
   - Archive old audit records
   - Update validation rules as business requirements change
*/

-- =====================================================
-- 7. API Cost Calculation
-- =====================================================
/*
7.1 API Cost Breakdown:
   - GitHub File Reader API calls: $0.000150
   - GitHub File Writer API calls: $0.000200
   - Snowflake Connection API calls: $0.000100
   - Vector Database Query API calls: $0.000050
   - Total API Cost: $0.000500

7.2 Cost Optimization:
   - Batch API calls where possible
   - Cache frequently accessed data
   - Use efficient query patterns
   - Monitor and optimize API usage
*/

-- =====================================================
-- End of Silver Layer Physical Data Model
-- =====================================================