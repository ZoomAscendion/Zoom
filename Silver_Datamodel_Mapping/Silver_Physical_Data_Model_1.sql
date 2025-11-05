_____________________________________________
## *Author*: AAVA
## *Created on*: 2024
## *Description*: Silver layer physical data model for Zoom Platform Analytics System supporting cleaned, validated, and enriched data
## *Version*: 1 
## *Updated on*: 
_____________________________________________

-- =====================================================
-- Zoom Platform Analytics System - Silver Layer Physical Data Model
-- =====================================================

-- Silver Layer DDL Scripts for Cleaned and Enriched Data
-- All tables preserve Bronze layer columns and add Silver layer enhancements
-- Compatible with Snowflake SQL standards
-- No primary keys, foreign keys, or constraints as per requirements
-- Includes data quality and audit tracking capabilities

-- =====================================================
-- 1.1 SI_USERS Table
-- =====================================================
CREATE TABLE IF NOT EXISTS SILVER.SI_USERS (
    -- Bronze layer columns preserved
    USER_ID STRING,
    USER_NAME STRING,
    EMAIL STRING,
    COMPANY STRING,
    PLAN_TYPE STRING,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM STRING,
    
    -- Silver layer enhancements
    DATA_QUALITY_SCORE NUMBER(5,2),
    RECORD_STATUS STRING,
    PROCESSED_TIMESTAMP TIMESTAMP_NTZ,
    PROCESSED_BY STRING,
    VALIDATION_STATUS STRING,
    BUSINESS_KEY STRING,
    EFFECTIVE_DATE DATE,
    EXPIRY_DATE DATE,
    IS_CURRENT BOOLEAN,
    RECORD_HASH STRING
);

-- =====================================================
-- 1.2 SI_MEETINGS Table
-- =====================================================
CREATE TABLE IF NOT EXISTS SILVER.SI_MEETINGS (
    -- Bronze layer columns preserved
    MEETING_ID STRING,
    HOST_ID STRING,
    MEETING_TOPIC STRING,
    START_TIME TIMESTAMP_NTZ,
    END_TIME TIMESTAMP_NTZ,
    DURATION_MINUTES NUMBER,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM STRING,
    
    -- Silver layer enhancements
    DATA_QUALITY_SCORE NUMBER(5,2),
    RECORD_STATUS STRING,
    PROCESSED_TIMESTAMP TIMESTAMP_NTZ,
    PROCESSED_BY STRING,
    VALIDATION_STATUS STRING,
    BUSINESS_KEY STRING,
    EFFECTIVE_DATE DATE,
    EXPIRY_DATE DATE,
    IS_CURRENT BOOLEAN,
    RECORD_HASH STRING
);

-- =====================================================
-- 1.3 SI_PARTICIPANTS Table
-- =====================================================
CREATE TABLE IF NOT EXISTS SILVER.SI_PARTICIPANTS (
    -- Bronze layer columns preserved
    PARTICIPANT_ID STRING,
    MEETING_ID STRING,
    USER_ID STRING,
    JOIN_TIME TIMESTAMP_NTZ,
    LEAVE_TIME TIMESTAMP_NTZ,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM STRING,
    
    -- Silver layer enhancements
    DATA_QUALITY_SCORE NUMBER(5,2),
    RECORD_STATUS STRING,
    PROCESSED_TIMESTAMP TIMESTAMP_NTZ,
    PROCESSED_BY STRING,
    VALIDATION_STATUS STRING,
    BUSINESS_KEY STRING,
    EFFECTIVE_DATE DATE,
    EXPIRY_DATE DATE,
    IS_CURRENT BOOLEAN,
    RECORD_HASH STRING
);

-- =====================================================
-- 1.4 SI_FEATURE_USAGE Table
-- =====================================================
CREATE TABLE IF NOT EXISTS SILVER.SI_FEATURE_USAGE (
    -- Bronze layer columns preserved
    USAGE_ID STRING,
    MEETING_ID STRING,
    FEATURE_NAME STRING,
    USAGE_COUNT NUMBER,
    USAGE_DATE DATE,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM STRING,
    
    -- Silver layer enhancements
    DATA_QUALITY_SCORE NUMBER(5,2),
    RECORD_STATUS STRING,
    PROCESSED_TIMESTAMP TIMESTAMP_NTZ,
    PROCESSED_BY STRING,
    VALIDATION_STATUS STRING,
    BUSINESS_KEY STRING,
    EFFECTIVE_DATE DATE,
    EXPIRY_DATE DATE,
    IS_CURRENT BOOLEAN,
    RECORD_HASH STRING
);

-- =====================================================
-- 1.5 SI_SUPPORT_TICKETS Table
-- =====================================================
CREATE TABLE IF NOT EXISTS SILVER.SI_SUPPORT_TICKETS (
    -- Bronze layer columns preserved
    TICKET_ID STRING,
    USER_ID STRING,
    TICKET_TYPE STRING,
    RESOLUTION_STATUS STRING,
    OPEN_DATE DATE,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM STRING,
    
    -- Silver layer enhancements
    DATA_QUALITY_SCORE NUMBER(5,2),
    RECORD_STATUS STRING,
    PROCESSED_TIMESTAMP TIMESTAMP_NTZ,
    PROCESSED_BY STRING,
    VALIDATION_STATUS STRING,
    BUSINESS_KEY STRING,
    EFFECTIVE_DATE DATE,
    EXPIRY_DATE DATE,
    IS_CURRENT BOOLEAN,
    RECORD_HASH STRING
);

-- =====================================================
-- 1.6 SI_BILLING_EVENTS Table
-- =====================================================
CREATE TABLE IF NOT EXISTS SILVER.SI_BILLING_EVENTS (
    -- Bronze layer columns preserved
    EVENT_ID STRING,
    USER_ID STRING,
    EVENT_TYPE STRING,
    AMOUNT NUMBER(10,2),
    EVENT_DATE DATE,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM STRING,
    
    -- Silver layer enhancements
    DATA_QUALITY_SCORE NUMBER(5,2),
    RECORD_STATUS STRING,
    PROCESSED_TIMESTAMP TIMESTAMP_NTZ,
    PROCESSED_BY STRING,
    VALIDATION_STATUS STRING,
    BUSINESS_KEY STRING,
    EFFECTIVE_DATE DATE,
    EXPIRY_DATE DATE,
    IS_CURRENT BOOLEAN,
    RECORD_HASH STRING
);

-- =====================================================
-- 1.7 SI_LICENSES Table
-- =====================================================
CREATE TABLE IF NOT EXISTS SILVER.SI_LICENSES (
    -- Bronze layer columns preserved
    LICENSE_ID STRING,
    LICENSE_TYPE STRING,
    ASSIGNED_TO_USER_ID STRING,
    START_DATE DATE,
    END_DATE DATE,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ,
    SOURCE_SYSTEM STRING,
    
    -- Silver layer enhancements
    DATA_QUALITY_SCORE NUMBER(5,2),
    RECORD_STATUS STRING,
    PROCESSED_TIMESTAMP TIMESTAMP_NTZ,
    PROCESSED_BY STRING,
    VALIDATION_STATUS STRING,
    BUSINESS_KEY STRING,
    EFFECTIVE_DATE DATE,
    EXPIRY_DATE DATE,
    IS_CURRENT BOOLEAN,
    RECORD_HASH STRING
);

-- =====================================================
-- 1.8 SI_DATA_QUALITY_ERRORS Table
-- =====================================================
CREATE TABLE IF NOT EXISTS SILVER.SI_DATA_QUALITY_ERRORS (
    ERROR_ID NUMBER AUTOINCREMENT,
    SOURCE_TABLE STRING,
    SOURCE_RECORD_ID STRING,
    ERROR_TYPE STRING,
    ERROR_DESCRIPTION STRING,
    ERROR_COLUMN STRING,
    ERROR_VALUE STRING,
    VALIDATION_RULE STRING,
    SEVERITY_LEVEL STRING,
    ERROR_TIMESTAMP TIMESTAMP_NTZ,
    PROCESSED_BY STRING,
    RESOLUTION_STATUS STRING,
    RESOLUTION_TIMESTAMP TIMESTAMP_NTZ,
    RESOLUTION_NOTES STRING
);

-- =====================================================
-- 1.9 SI_PIPELINE_AUDIT Table
-- =====================================================
CREATE TABLE IF NOT EXISTS SILVER.SI_PIPELINE_AUDIT (
    AUDIT_ID NUMBER AUTOINCREMENT,
    PIPELINE_NAME STRING,
    PIPELINE_RUN_ID STRING,
    SOURCE_TABLE STRING,
    TARGET_TABLE STRING,
    EXECUTION_START_TIME TIMESTAMP_NTZ,
    EXECUTION_END_TIME TIMESTAMP_NTZ,
    EXECUTION_DURATION_SECONDS NUMBER,
    RECORDS_PROCESSED NUMBER,
    RECORDS_INSERTED NUMBER,
    RECORDS_UPDATED NUMBER,
    RECORDS_REJECTED NUMBER,
    PIPELINE_STATUS STRING,
    ERROR_MESSAGE STRING,
    PROCESSED_BY STRING,
    PROCESSING_DATE DATE,
    DATA_QUALITY_SCORE NUMBER(5,2),
    PERFORMANCE_METRICS STRING
);

-- =====================================================
-- 2. Data Type Mapping and Silver Layer Enhancements
-- =====================================================
/*
2.1 Silver Layer Enhancement Columns:
   - DATA_QUALITY_SCORE: Numeric score (0-100) indicating data quality
   - RECORD_STATUS: Status of the record (ACTIVE, INACTIVE, DELETED, QUARANTINED)
   - PROCESSED_TIMESTAMP: When the record was processed in Silver layer
   - PROCESSED_BY: System or user that processed the record
   - VALIDATION_STATUS: Result of data validation (PASSED, FAILED, WARNING)
   - BUSINESS_KEY: Natural business key for the record
   - EFFECTIVE_DATE: When the record becomes effective
   - EXPIRY_DATE: When the record expires
   - IS_CURRENT: Boolean flag indicating if this is the current version
   - RECORD_HASH: Hash value for change detection

2.2 Data Quality Error Tracking:
   - ERROR_ID: Unique identifier for each error
   - SOURCE_TABLE: Table where the error originated
   - SOURCE_RECORD_ID: ID of the problematic record
   - ERROR_TYPE: Category of error (MISSING_VALUE, INVALID_FORMAT, CONSTRAINT_VIOLATION)
   - ERROR_DESCRIPTION: Detailed description of the error
   - ERROR_COLUMN: Column where the error occurred
   - ERROR_VALUE: The problematic value
   - VALIDATION_RULE: Rule that was violated
   - SEVERITY_LEVEL: Impact level (CRITICAL, HIGH, MEDIUM, LOW)

2.3 Pipeline Audit Capabilities:
   - AUDIT_ID: Unique identifier for each pipeline execution
   - PIPELINE_NAME: Name of the ETL pipeline
   - PIPELINE_RUN_ID: Unique run identifier
   - EXECUTION_START_TIME/END_TIME: Pipeline execution timeframe
   - EXECUTION_DURATION_SECONDS: Total processing time
   - RECORDS_PROCESSED/INSERTED/UPDATED/REJECTED: Processing statistics
   - PIPELINE_STATUS: Execution status (SUCCESS, FAILED, WARNING)
   - PERFORMANCE_METRICS: JSON string with detailed performance data
*/

-- =====================================================
-- 3. Silver Layer Design Principles
-- =====================================================
/*
3.1 Data Quality Framework:
   - All Bronze layer columns preserved without modification
   - Data quality scoring based on completeness, accuracy, and consistency
   - Comprehensive error tracking and resolution workflow
   - Audit trail for all data processing activities

3.2 Change Data Capture:
   - Slowly Changing Dimension (SCD) Type 2 support
   - Effective and expiry date tracking
   - Current record flagging for easy querying
   - Hash-based change detection for performance

3.3 Data Validation Rules:
   - Referential integrity validation (without constraints)
   - Business rule validation based on requirements
   - Data format and range validation
   - Completeness and consistency checks

3.4 Performance Optimization:
   - Snowflake's automatic micro-partitioning
   - Clustering on frequently queried columns
   - Materialized views for complex aggregations
   - Query result caching for dashboard performance
*/

-- =====================================================
-- 4. Data Quality Validation Examples
-- =====================================================
/*
4.1 Sample Data Quality Checks:

-- Check for missing required fields
INSERT INTO SILVER.SI_DATA_QUALITY_ERRORS 
(SOURCE_TABLE, SOURCE_RECORD_ID, ERROR_TYPE, ERROR_DESCRIPTION, ERROR_COLUMN, SEVERITY_LEVEL, ERROR_TIMESTAMP, PROCESSED_BY)
SELECT 
    'SI_USERS' as SOURCE_TABLE,
    USER_ID as SOURCE_RECORD_ID,
    'MISSING_VALUE' as ERROR_TYPE,
    'Required field is null or empty' as ERROR_DESCRIPTION,
    'EMAIL' as ERROR_COLUMN,
    'CRITICAL' as SEVERITY_LEVEL,
    CURRENT_TIMESTAMP() as ERROR_TIMESTAMP,
    'DATA_QUALITY_VALIDATOR' as PROCESSED_BY
FROM SILVER.SI_USERS 
WHERE EMAIL IS NULL OR TRIM(EMAIL) = '';

-- Check for invalid email formats
INSERT INTO SILVER.SI_DATA_QUALITY_ERRORS 
(SOURCE_TABLE, SOURCE_RECORD_ID, ERROR_TYPE, ERROR_DESCRIPTION, ERROR_COLUMN, ERROR_VALUE, SEVERITY_LEVEL, ERROR_TIMESTAMP, PROCESSED_BY)
SELECT 
    'SI_USERS' as SOURCE_TABLE,
    USER_ID as SOURCE_RECORD_ID,
    'INVALID_FORMAT' as ERROR_TYPE,
    'Email format is invalid' as ERROR_DESCRIPTION,
    'EMAIL' as ERROR_COLUMN,
    EMAIL as ERROR_VALUE,
    'HIGH' as SEVERITY_LEVEL,
    CURRENT_TIMESTAMP() as ERROR_TIMESTAMP,
    'DATA_QUALITY_VALIDATOR' as PROCESSED_BY
FROM SILVER.SI_USERS 
WHERE EMAIL IS NOT NULL 
  AND NOT REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

4.2 Sample Pipeline Audit Logging:

INSERT INTO SILVER.SI_PIPELINE_AUDIT 
(PIPELINE_NAME, PIPELINE_RUN_ID, SOURCE_TABLE, TARGET_TABLE, EXECUTION_START_TIME, EXECUTION_END_TIME, 
 RECORDS_PROCESSED, RECORDS_INSERTED, RECORDS_UPDATED, PIPELINE_STATUS, PROCESSED_BY, PROCESSING_DATE)
VALUES 
('BRONZE_TO_SILVER_USERS', 'RUN_20241201_001', 'BRONZE.BZ_USERS', 'SILVER.SI_USERS', 
 '2024-12-01 10:00:00', '2024-12-01 10:05:30', 10000, 8500, 1500, 'SUCCESS', 'ETL_PIPELINE', '2024-12-01');
*/

-- =====================================================
-- 5. Implementation Guidelines
-- =====================================================
/*
5.1 Data Loading Strategy:
   - Implement incremental loading using MERGE statements
   - Use STREAM objects for change data capture
   - Implement data quality checks before Silver layer insertion
   - Log all processing activities in audit table

5.2 Error Handling:
   - Quarantine records that fail validation
   - Implement retry mechanisms for transient errors
   - Provide data steward interface for error resolution
   - Track error resolution metrics and trends

5.3 Performance Monitoring:
   - Monitor pipeline execution times and resource usage
   - Track data quality scores over time
   - Implement alerting for pipeline failures or quality degradation
   - Regular performance tuning based on usage patterns

5.4 Security and Compliance:
   - Implement row-level security for sensitive data
   - Maintain audit trail for compliance requirements
   - Data masking for non-production environments
   - Regular access reviews and permission audits
*/

-- =====================================================
-- End of Silver Layer Physical Data Model
-- =====================================================