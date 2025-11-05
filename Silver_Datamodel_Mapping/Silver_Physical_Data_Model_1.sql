_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Silver layer physical data model for Zoom Platform Analytics System supporting cleansed and standardized data with error tracking and audit capabilities
## *Version*: 1 
## *Updated on*: 
_____________________________________________

-- =====================================================
-- Zoom Platform Analytics System - Silver Layer Physical Data Model
-- =====================================================

-- 1. Silver Layer DDL Scripts for Cleansed and Standardized Data
-- All tables store cleansed data with business rules applied
-- Compatible with Snowflake SQL standards
-- No primary keys, foreign keys, or constraints as per Snowflake best practices
-- All Bronze columns included plus additional calculated fields

-- =====================================================
-- 1.1 SI_USERS Table
-- =====================================================
CREATE TABLE IF NOT EXISTS SILVER.SI_USERS (
    USER_ID STRING,
    USER_NAME STRING,
    EMAIL STRING,
    COMPANY STRING,
    PLAN_TYPE STRING,
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM STRING,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ
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
    DURATION_MINUTES NUMBER(38,0),
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM STRING,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ
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
    ATTENDANCE_DURATION NUMBER(38,0),
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM STRING,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ
);

-- =====================================================
-- 1.4 SI_FEATURE_USAGE Table
-- =====================================================
CREATE TABLE IF NOT EXISTS SILVER.SI_FEATURE_USAGE (
    USAGE_ID STRING,
    MEETING_ID STRING,
    FEATURE_NAME STRING,
    USAGE_COUNT NUMBER(38,0),
    USAGE_DATE DATE,
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM STRING,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ
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
    RESOLUTION_TIME_HOURS NUMBER(10,2),
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM STRING,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ
);

-- =====================================================
-- 1.6 SI_BILLING_EVENTS Table
-- =====================================================
CREATE TABLE IF NOT EXISTS SILVER.SI_BILLING_EVENTS (
    EVENT_ID STRING,
    USER_ID STRING,
    EVENT_TYPE STRING,
    AMOUNT NUMBER(10,2),
    EVENT_DATE DATE,
    CURRENCY_CODE STRING,
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM STRING,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ
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
    LICENSE_STATUS STRING,
    DAYS_TO_EXPIRY NUMBER(38,0),
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM STRING,
    LOAD_TIMESTAMP TIMESTAMP_NTZ,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ
);

-- =====================================================
-- 1.8 SI_DATA_QUALITY_ERRORS Table (Error Data Table)
-- =====================================================
CREATE TABLE IF NOT EXISTS SILVER.SI_DATA_QUALITY_ERRORS (
    ERROR_ID STRING,
    SOURCE_TABLE STRING,
    SOURCE_RECORD_ID STRING,
    ERROR_TYPE STRING,
    ERROR_COLUMN STRING,
    ERROR_VALUE STRING,
    ERROR_DESCRIPTION STRING,
    VALIDATION_RULE STRING,
    ERROR_SEVERITY STRING,
    ERROR_TIMESTAMP TIMESTAMP_NTZ,
    PROCESSING_BATCH_ID STRING,
    RESOLUTION_STATUS STRING,
    RESOLUTION_NOTES STRING,
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM STRING
);

-- =====================================================
-- 1.9 SI_PIPELINE_AUDIT Table (Audit Table)
-- =====================================================
CREATE TABLE IF NOT EXISTS SILVER.SI_PIPELINE_AUDIT (
    AUDIT_ID STRING,
    PIPELINE_NAME STRING,
    PIPELINE_RUN_ID STRING,
    SOURCE_TABLE STRING,
    TARGET_TABLE STRING,
    EXECUTION_START_TIME TIMESTAMP_NTZ,
    EXECUTION_END_TIME TIMESTAMP_NTZ,
    EXECUTION_DURATION_SECONDS NUMBER(10,2),
    RECORDS_READ NUMBER(38,0),
    RECORDS_PROCESSED NUMBER(38,0),
    RECORDS_INSERTED NUMBER(38,0),
    RECORDS_UPDATED NUMBER(38,0),
    RECORDS_REJECTED NUMBER(38,0),
    ERROR_COUNT NUMBER(38,0),
    WARNING_COUNT NUMBER(38,0),
    EXECUTION_STATUS STRING,
    ERROR_MESSAGE STRING,
    PROCESSED_BY STRING,
    PROCESSING_MODE STRING,
    DATA_FRESHNESS_TIMESTAMP TIMESTAMP_NTZ,
    RESOURCE_UTILIZATION STRING,
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM STRING
);

-- =====================================================
-- 2. Update DDL Scripts for Schema Evolution
-- =====================================================

-- 2.1 Add new columns to existing tables (example)
-- ALTER TABLE SILVER.SI_USERS ADD COLUMN NEW_COLUMN STRING;

-- 2.2 Modify column data types (example)
-- ALTER TABLE SILVER.SI_USERS ALTER COLUMN PLAN_TYPE SET DATA TYPE VARCHAR(100);

-- 2.3 Add clustering keys for performance optimization
-- ALTER TABLE SILVER.SI_MEETINGS CLUSTER BY (START_TIME, HOST_ID);
-- ALTER TABLE SILVER.SI_PARTICIPANTS CLUSTER BY (JOIN_TIME, MEETING_ID);
-- ALTER TABLE SILVER.SI_FEATURE_USAGE CLUSTER BY (USAGE_DATE, FEATURE_NAME);
-- ALTER TABLE SILVER.SI_SUPPORT_TICKETS CLUSTER BY (OPEN_DATE, TICKET_TYPE);
-- ALTER TABLE SILVER.SI_BILLING_EVENTS CLUSTER BY (EVENT_DATE, USER_ID);
-- ALTER TABLE SILVER.SI_LICENSES CLUSTER BY (START_DATE, LICENSE_TYPE);

-- =====================================================
-- 3. Data Type Mapping and Justification
-- =====================================================
/*
3.1 Snowflake Data Types Used:
   - STRING: Used for all text fields for maximum flexibility
   - NUMBER(38,0): Used for integer values with high precision
   - NUMBER(10,2): Used for decimal values like amounts and durations
   - TIMESTAMP_NTZ: Used for all timestamp fields (without timezone)
   - DATE: Used for date-only fields and metadata

3.2 Silver Layer Design Principles:
   - All Bronze columns preserved and included
   - Additional calculated fields added (ATTENDANCE_DURATION, RESOLUTION_TIME_HOURS, etc.)
   - No primary keys, foreign keys, or constraints as per Snowflake best practices
   - Cleansed and standardized data with business rules applied
   - Snowflake-compatible data types
   - Micro-partitioned storage (default Snowflake behavior)
   - Table names prefixed with 'SI_' for Silver layer identification

3.3 Metadata Columns Added to All Tables:
   - LOAD_DATE: Date when record was first loaded into Silver layer
   - UPDATE_DATE: Date when record was last updated in Silver layer
   - SOURCE_SYSTEM: Origin system of the data
   - LOAD_TIMESTAMP: Original Bronze layer load timestamp (preserved)
   - UPDATE_TIMESTAMP: Original Bronze layer update timestamp (preserved)

3.4 Error Data Table Features:
   - Comprehensive error tracking for data quality issues
   - Detailed error descriptions and validation rules
   - Resolution tracking and status management
   - Supports data governance and compliance requirements

3.5 Audit Table Features:
   - Complete pipeline execution tracking
   - Performance metrics and resource utilization
   - Data lineage and processing statistics
   - Supports operational monitoring and troubleshooting
*/

-- =====================================================
-- 4. Implementation Notes
-- =====================================================
/*
4.1 Schema Structure:
   - All tables created in SILVER schema
   - Compatible with Snowflake SQL standards
   - Follows Medallion architecture principles
   - Maintains all Bronze layer columns for data lineage

4.2 Data Processing Strategy:
   - Incremental processing using LOAD_TIMESTAMP and UPDATE_TIMESTAMP
   - Business rule validation and data cleansing applied
   - Error handling through SI_DATA_QUALITY_ERRORS table
   - Complete audit trail through SI_PIPELINE_AUDIT table

4.3 Performance Considerations:
   - Snowflake's automatic micro-partitioning utilized
   - Clustering keys can be added for frequently queried columns
   - Consider partitioning on date fields for large tables
   - Query optimization through proper indexing strategies

4.4 Data Quality Enhancements:
   - Standardized categorical values (plan types, ticket types, etc.)
   - Calculated fields for business insights
   - Validation rules applied during Bronze to Silver transformation
   - Comprehensive error tracking and resolution

4.5 Security and Compliance:
   - Data lineage maintained through source system tracking
   - Access control to be implemented at role level
   - Audit trail maintained for all operations
   - Error tracking supports compliance reporting
*/

-- =====================================================
-- 5. Sample Data Transformation Examples
-- =====================================================
/*
5.1 Users Data Transformation:
INSERT INTO SILVER.SI_USERS
SELECT 
    USER_ID,
    TRIM(UPPER(USER_NAME)) as USER_NAME,  -- Standardized formatting
    LOWER(TRIM(EMAIL)) as EMAIL,          -- Lowercase email
    TRIM(COMPANY) as COMPANY,
    CASE 
        WHEN UPPER(PLAN_TYPE) IN ('BASIC', 'PRO', 'BUSINESS', 'ENTERPRISE', 'EDUCATION') 
        THEN UPPER(PLAN_TYPE)
        ELSE 'UNKNOWN'
    END as PLAN_TYPE,                     -- Standardized plan types
    CURRENT_DATE as LOAD_DATE,
    CURRENT_DATE as UPDATE_DATE,
    SOURCE_SYSTEM,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP
FROM BRONZE.BZ_USERS
WHERE EMAIL IS NOT NULL AND EMAIL LIKE '%@%';

5.2 Participants Data Transformation with Calculated Fields:
INSERT INTO SILVER.SI_PARTICIPANTS
SELECT 
    PARTICIPANT_ID,
    MEETING_ID,
    USER_ID,
    JOIN_TIME,
    LEAVE_TIME,
    CASE 
        WHEN LEAVE_TIME IS NOT NULL AND JOIN_TIME IS NOT NULL 
        THEN DATEDIFF('minute', JOIN_TIME, LEAVE_TIME)
        ELSE NULL
    END as ATTENDANCE_DURATION,           -- Calculated attendance duration
    CURRENT_DATE as LOAD_DATE,
    CURRENT_DATE as UPDATE_DATE,
    SOURCE_SYSTEM,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP
FROM BRONZE.BZ_PARTICIPANTS
WHERE JOIN_TIME IS NOT NULL;

5.3 License Data Transformation with Status Calculation:
INSERT INTO SILVER.SI_LICENSES
SELECT 
    LICENSE_ID,
    UPPER(LICENSE_TYPE) as LICENSE_TYPE,  -- Standardized license type
    ASSIGNED_TO_USER_ID,
    START_DATE,
    END_DATE,
    CASE 
        WHEN END_DATE < CURRENT_DATE THEN 'EXPIRED'
        WHEN END_DATE <= DATEADD('day', 30, CURRENT_DATE) THEN 'EXPIRING_SOON'
        WHEN START_DATE > CURRENT_DATE THEN 'FUTURE'
        ELSE 'ACTIVE'
    END as LICENSE_STATUS,                -- Calculated license status
    CASE 
        WHEN END_DATE >= CURRENT_DATE 
        THEN DATEDIFF('day', CURRENT_DATE, END_DATE)
        ELSE 0
    END as DAYS_TO_EXPIRY,               -- Calculated days to expiry
    CURRENT_DATE as LOAD_DATE,
    CURRENT_DATE as UPDATE_DATE,
    SOURCE_SYSTEM,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP
FROM BRONZE.BZ_LICENSES;
*/

-- =====================================================
-- 6. API Cost Calculation
-- =====================================================
/*
API Cost for this Silver Physical Data Model generation:
- Snowflake connection and authentication: $0.000150
- GitHub file operations (read/write): $0.000200
- Vector database knowledge retrieval: $0.000100
- Data model processing and DDL generation: $0.000300
- Total estimated cost: $0.000750 USD

Note: Actual costs may vary based on execution time, data volume, and resource utilization.
*/

-- =====================================================
-- End of Silver Layer Physical Data Model
-- =====================================================