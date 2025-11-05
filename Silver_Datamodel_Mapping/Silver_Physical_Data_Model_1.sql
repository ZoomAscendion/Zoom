_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Silver layer physical data model for Zoom Platform Analytics System with data quality, validation, and audit tracking
## *Version*: 1 
## *Updated on*: 
_____________________________________________

-- =====================================================
-- Zoom Platform Analytics System - Silver Layer Physical Data Model
-- =====================================================

-- 1. Silver Layer DDL Scripts for Cleaned and Validated Data
-- All tables store cleaned, validated, and enriched data from Bronze layer
-- Compatible with Snowflake SQL standards
-- No primary keys, foreign keys, or constraints for Silver layer
-- Includes data quality, validation, and audit tracking capabilities

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
    IS_VALID_RECORD BOOLEAN,
    VALIDATION_STATUS STRING,
    CLEANSED_TIMESTAMP TIMESTAMP_NTZ,
    PROCESSED_BY STRING,
    SILVER_LOAD_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    SILVER_UPDATE_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
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
    IS_VALID_RECORD BOOLEAN,
    VALIDATION_STATUS STRING,
    CLEANSED_TIMESTAMP TIMESTAMP_NTZ,
    PROCESSED_BY STRING,
    SILVER_LOAD_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    SILVER_UPDATE_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
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
    IS_VALID_RECORD BOOLEAN,
    VALIDATION_STATUS STRING,
    CLEANSED_TIMESTAMP TIMESTAMP_NTZ,
    PROCESSED_BY STRING,
    SILVER_LOAD_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    SILVER_UPDATE_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
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
    IS_VALID_RECORD BOOLEAN,
    VALIDATION_STATUS STRING,
    CLEANSED_TIMESTAMP TIMESTAMP_NTZ,
    PROCESSED_BY STRING,
    SILVER_LOAD_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    SILVER_UPDATE_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
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
    IS_VALID_RECORD BOOLEAN,
    VALIDATION_STATUS STRING,
    CLEANSED_TIMESTAMP TIMESTAMP_NTZ,
    PROCESSED_BY STRING,
    SILVER_LOAD_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    SILVER_UPDATE_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
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
    IS_VALID_RECORD BOOLEAN,
    VALIDATION_STATUS STRING,
    CLEANSED_TIMESTAMP TIMESTAMP_NTZ,
    PROCESSED_BY STRING,
    SILVER_LOAD_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    SILVER_UPDATE_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
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
    IS_VALID_RECORD BOOLEAN,
    VALIDATION_STATUS STRING,
    CLEANSED_TIMESTAMP TIMESTAMP_NTZ,
    PROCESSED_BY STRING,
    SILVER_LOAD_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    SILVER_UPDATE_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- =====================================================
-- 2. Data Quality and Error Handling Tables
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
    ERROR_COLUMN STRING,
    ERROR_VALUE STRING,
    SEVERITY_LEVEL STRING,
    ERROR_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    RESOLUTION_STATUS STRING,
    RESOLVED_BY STRING,
    RESOLVED_TIMESTAMP TIMESTAMP_NTZ,
    RESOLUTION_NOTES STRING,
    CREATED_BY STRING,
    CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- =====================================================
-- 2.2 SI_VALIDATION_RULES Table
-- =====================================================
CREATE TABLE IF NOT EXISTS SILVER.SI_VALIDATION_RULES (
    RULE_ID STRING,
    RULE_NAME STRING,
    RULE_DESCRIPTION STRING,
    TARGET_TABLE STRING,
    TARGET_COLUMN STRING,
    RULE_TYPE STRING,
    RULE_EXPRESSION STRING,
    SEVERITY_LEVEL STRING,
    IS_ACTIVE BOOLEAN,
    CREATED_BY STRING,
    CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_BY STRING,
    UPDATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    EFFECTIVE_START_DATE DATE,
    EFFECTIVE_END_DATE DATE
);

-- =====================================================
-- 3. Audit and Lineage Tables
-- =====================================================

-- =====================================================
-- 3.1 SI_PIPELINE_AUDIT Table
-- =====================================================
CREATE TABLE IF NOT EXISTS SILVER.SI_PIPELINE_AUDIT (
    AUDIT_ID STRING,
    PIPELINE_NAME STRING,
    PIPELINE_RUN_ID STRING,
    SOURCE_TABLE STRING,
    TARGET_TABLE STRING,
    OPERATION_TYPE STRING,
    START_TIMESTAMP TIMESTAMP_NTZ,
    END_TIMESTAMP TIMESTAMP_NTZ,
    DURATION_SECONDS NUMBER,
    RECORDS_PROCESSED NUMBER,
    RECORDS_SUCCESS NUMBER,
    RECORDS_FAILED NUMBER,
    RECORDS_SKIPPED NUMBER,
    STATUS STRING,
    ERROR_MESSAGE STRING,
    EXECUTED_BY STRING,
    EXECUTION_ENVIRONMENT STRING,
    PIPELINE_VERSION STRING,
    CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- =====================================================
-- 3.2 SI_DATA_LINEAGE Table
-- =====================================================
CREATE TABLE IF NOT EXISTS SILVER.SI_DATA_LINEAGE (
    LINEAGE_ID STRING,
    SOURCE_SYSTEM STRING,
    SOURCE_TABLE STRING,
    SOURCE_COLUMN STRING,
    TARGET_SYSTEM STRING,
    TARGET_TABLE STRING,
    TARGET_COLUMN STRING,
    TRANSFORMATION_LOGIC STRING,
    TRANSFORMATION_TYPE STRING,
    DEPENDENCY_LEVEL NUMBER,
    IS_DIRECT_MAPPING BOOLEAN,
    DATA_FLOW_DIRECTION STRING,
    CREATED_BY STRING,
    CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_BY STRING,
    UPDATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    IS_ACTIVE BOOLEAN DEFAULT TRUE
);

-- =====================================================
-- 4. Data Type Mapping and Justification
-- =====================================================
/*
4.1 Snowflake Data Types Used:
   - STRING: Used for all text fields, provides maximum flexibility
   - NUMBER: Used for numeric values with appropriate precision
   - TIMESTAMP_NTZ: Used for all timestamp fields (without timezone)
   - DATE: Used for date-only fields
   - BOOLEAN: Used for true/false flags
   - DECIMAL/NUMBER(10,2): Used for monetary amounts

4.2 Silver Layer Design Principles:
   - All Bronze layer columns preserved for data lineage
   - Additional Silver layer columns for data quality tracking
   - No primary keys, foreign keys, or constraints
   - Snowflake-compatible data types
   - Table names prefixed with 'SI_' for Silver layer identification

4.3 Data Quality Enhancements:
   - DATA_QUALITY_SCORE: Numeric score (0-100) indicating data quality
   - IS_VALID_RECORD: Boolean flag for record validity
   - VALIDATION_STATUS: Text description of validation results
   - CLEANSED_TIMESTAMP: When data cleansing was performed
   - PROCESSED_BY: System/user that processed the record

4.4 Error Handling Features:
   - Comprehensive error logging with detailed descriptions
   - Error categorization and severity levels
   - Resolution tracking and audit trail
   - Support for data quality rule management

4.5 Audit and Lineage Features:
   - Pipeline execution tracking with performance metrics
   - Complete data lineage from source to target
   - Transformation logic documentation
   - Version control and change tracking
*/

-- =====================================================
-- 5. Implementation Notes
-- =====================================================
/*
5.1 Schema Structure:
   - All tables created in SILVER schema
   - Compatible with Snowflake SQL standards
   - Follows Medallion architecture principles

5.2 Data Processing Strategy:
   - Incremental processing using timestamp fields
   - Data quality validation before Silver layer insertion
   - Error handling with detailed logging
   - Audit trail for all operations

5.3 Performance Considerations:
   - Snowflake's automatic micro-partitioning
   - Consider clustering keys for large tables
   - Optimize for analytical workloads

5.4 Data Quality Framework:
   - Configurable validation rules
   - Automated data quality scoring
   - Exception handling and resolution workflow
   - Comprehensive error reporting

5.5 Governance and Compliance:
   - Complete audit trail for regulatory compliance
   - Data lineage for impact analysis
   - Change tracking and version control
   - Access control at role level
*/

-- =====================================================
-- 6. Sample Usage Examples
-- =====================================================
/*
6.1 Data Quality Check Example:
INSERT INTO SILVER.SI_DATA_QUALITY_ERRORS 
(ERROR_ID, SOURCE_TABLE, SOURCE_RECORD_ID, ERROR_TYPE, ERROR_DESCRIPTION, ERROR_COLUMN, SEVERITY_LEVEL, CREATED_BY)
VALUES 
('ERR_001', 'SI_USERS', 'USER_123', 'NULL_VALUE', 'Email field is null', 'EMAIL', 'HIGH', 'DQ_PROCESS');

6.2 Pipeline Audit Example:
INSERT INTO SILVER.SI_PIPELINE_AUDIT 
(AUDIT_ID, PIPELINE_NAME, SOURCE_TABLE, TARGET_TABLE, OPERATION_TYPE, START_TIMESTAMP, END_TIMESTAMP, RECORDS_PROCESSED, STATUS, EXECUTED_BY)
VALUES 
('AUDIT_001', 'BRONZE_TO_SILVER_USERS', 'BZ_USERS', 'SI_USERS', 'TRANSFORM', '2024-01-01 10:00:00', '2024-01-01 10:05:00', 1000, 'SUCCESS', 'ETL_PROCESS');

6.3 Data Lineage Example:
INSERT INTO SILVER.SI_DATA_LINEAGE 
(LINEAGE_ID, SOURCE_SYSTEM, SOURCE_TABLE, SOURCE_COLUMN, TARGET_SYSTEM, TARGET_TABLE, TARGET_COLUMN, TRANSFORMATION_TYPE, IS_DIRECT_MAPPING, CREATED_BY)
VALUES 
('LIN_001', 'BRONZE', 'BZ_USERS', 'USER_NAME', 'SILVER', 'SI_USERS', 'USER_NAME', 'DIRECT_COPY', TRUE, 'LINEAGE_PROCESS');

6.4 Validation Rule Example:
INSERT INTO SILVER.SI_VALIDATION_RULES 
(RULE_ID, RULE_NAME, RULE_DESCRIPTION, TARGET_TABLE, TARGET_COLUMN, RULE_TYPE, RULE_EXPRESSION, SEVERITY_LEVEL, IS_ACTIVE, CREATED_BY)
VALUES 
('RULE_001', 'Email Format Check', 'Validates email format using regex', 'SI_USERS', 'EMAIL', 'REGEX', '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$', 'HIGH', TRUE, 'DQ_ADMIN');
*/

-- =====================================================
-- End of Silver Layer Physical Data Model
-- =====================================================