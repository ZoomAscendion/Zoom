_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Silver layer physical data model for Zoom Platform Analytics System with cleaned, validated, and enriched data
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

-- =====================================================
-- Zoom Platform Analytics System - Silver Layer Physical Data Model
-- =====================================================

-- 1. Silver Layer DDL Scripts for Cleaned and Validated Data
-- All tables contain cleaned, validated, and enriched data
-- Compatible with Snowflake SQL standards
-- Includes primary keys, foreign keys, and constraints for data integrity
-- Includes clustering keys for performance optimization

-- =====================================================
-- 1.1 SI_USERS Table
-- =====================================================
CREATE TABLE IF NOT EXISTS SILVER.SI_USERS (
    USER_ID STRING NOT NULL,
    USER_NAME STRING NOT NULL,
    EMAIL STRING NOT NULL,
    COMPANY STRING,
    PLAN_TYPE STRING NOT NULL,
    -- Metadata columns from Bronze
    LOAD_TIMESTAMP TIMESTAMP_NTZ NOT NULL,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ NOT NULL,
    SOURCE_SYSTEM STRING NOT NULL,
    -- Silver layer enrichment columns
    DATA_QUALITY_SCORE NUMBER(3,2) DEFAULT 0.00,
    IS_ACTIVE BOOLEAN DEFAULT TRUE,
    CREATED_DATE DATE,
    LAST_MODIFIED_DATE DATE DEFAULT CURRENT_DATE(),
    RECORD_HASH STRING,
    -- Constraints
    CONSTRAINT PK_SI_USERS PRIMARY KEY (USER_ID),
    CONSTRAINT CHK_EMAIL_FORMAT CHECK (EMAIL LIKE '%@%.%'),
    CONSTRAINT CHK_PLAN_TYPE CHECK (PLAN_TYPE IN ('BASIC', 'PRO', 'BUSINESS', 'ENTERPRISE'))
)
CLUSTER BY (USER_ID, PLAN_TYPE);

-- =====================================================
-- 1.2 SI_MEETINGS Table
-- =====================================================
CREATE TABLE IF NOT EXISTS SILVER.SI_MEETINGS (
    MEETING_ID STRING NOT NULL,
    HOST_ID STRING NOT NULL,
    MEETING_TOPIC STRING,
    START_TIME TIMESTAMP_NTZ NOT NULL,
    END_TIME TIMESTAMP_NTZ,
    DURATION_MINUTES NUMBER,
    -- Metadata columns from Bronze
    LOAD_TIMESTAMP TIMESTAMP_NTZ NOT NULL,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ NOT NULL,
    SOURCE_SYSTEM STRING NOT NULL,
    -- Silver layer enrichment columns
    DATA_QUALITY_SCORE NUMBER(3,2) DEFAULT 0.00,
    IS_ACTIVE BOOLEAN DEFAULT TRUE,
    MEETING_STATUS STRING DEFAULT 'COMPLETED',
    PARTICIPANT_COUNT NUMBER DEFAULT 0,
    CREATED_DATE DATE,
    LAST_MODIFIED_DATE DATE DEFAULT CURRENT_DATE(),
    RECORD_HASH STRING,
    -- Constraints
    CONSTRAINT PK_SI_MEETINGS PRIMARY KEY (MEETING_ID),
    CONSTRAINT FK_SI_MEETINGS_HOST FOREIGN KEY (HOST_ID) REFERENCES SILVER.SI_USERS(USER_ID),
    CONSTRAINT CHK_DURATION CHECK (DURATION_MINUTES >= 0),
    CONSTRAINT CHK_MEETING_STATUS CHECK (MEETING_STATUS IN ('SCHEDULED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED'))
)
CLUSTER BY (MEETING_ID, START_TIME);

-- =====================================================
-- 1.3 SI_PARTICIPANTS Table
-- =====================================================
CREATE TABLE IF NOT EXISTS SILVER.SI_PARTICIPANTS (
    PARTICIPANT_ID STRING NOT NULL,
    MEETING_ID STRING NOT NULL,
    USER_ID STRING NOT NULL,
    JOIN_TIME TIMESTAMP_NTZ,
    LEAVE_TIME TIMESTAMP_NTZ,
    -- Metadata columns from Bronze
    LOAD_TIMESTAMP TIMESTAMP_NTZ NOT NULL,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ NOT NULL,
    SOURCE_SYSTEM STRING NOT NULL,
    -- Silver layer enrichment columns
    DATA_QUALITY_SCORE NUMBER(3,2) DEFAULT 0.00,
    IS_ACTIVE BOOLEAN DEFAULT TRUE,
    PARTICIPATION_DURATION_MINUTES NUMBER,
    PARTICIPATION_STATUS STRING DEFAULT 'ATTENDED',
    CREATED_DATE DATE,
    LAST_MODIFIED_DATE DATE DEFAULT CURRENT_DATE(),
    RECORD_HASH STRING,
    -- Constraints
    CONSTRAINT PK_SI_PARTICIPANTS PRIMARY KEY (PARTICIPANT_ID),
    CONSTRAINT FK_SI_PARTICIPANTS_MEETING FOREIGN KEY (MEETING_ID) REFERENCES SILVER.SI_MEETINGS(MEETING_ID),
    CONSTRAINT FK_SI_PARTICIPANTS_USER FOREIGN KEY (USER_ID) REFERENCES SILVER.SI_USERS(USER_ID),
    CONSTRAINT CHK_PARTICIPATION_STATUS CHECK (PARTICIPATION_STATUS IN ('ATTENDED', 'NO_SHOW', 'LEFT_EARLY'))
)
CLUSTER BY (MEETING_ID, USER_ID);

-- =====================================================
-- 1.4 SI_FEATURE_USAGE Table
-- =====================================================
CREATE TABLE IF NOT EXISTS SILVER.SI_FEATURE_USAGE (
    USAGE_ID STRING NOT NULL,
    MEETING_ID STRING NOT NULL,
    FEATURE_NAME STRING NOT NULL,
    USAGE_COUNT NUMBER NOT NULL,
    USAGE_DATE DATE NOT NULL,
    -- Metadata columns from Bronze
    LOAD_TIMESTAMP TIMESTAMP_NTZ NOT NULL,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ NOT NULL,
    SOURCE_SYSTEM STRING NOT NULL,
    -- Silver layer enrichment columns
    DATA_QUALITY_SCORE NUMBER(3,2) DEFAULT 0.00,
    IS_ACTIVE BOOLEAN DEFAULT TRUE,
    FEATURE_CATEGORY STRING,
    USAGE_INTENSITY STRING DEFAULT 'NORMAL',
    CREATED_DATE DATE,
    LAST_MODIFIED_DATE DATE DEFAULT CURRENT_DATE(),
    RECORD_HASH STRING,
    -- Constraints
    CONSTRAINT PK_SI_FEATURE_USAGE PRIMARY KEY (USAGE_ID),
    CONSTRAINT FK_SI_FEATURE_USAGE_MEETING FOREIGN KEY (MEETING_ID) REFERENCES SILVER.SI_MEETINGS(MEETING_ID),
    CONSTRAINT CHK_USAGE_COUNT CHECK (USAGE_COUNT >= 0),
    CONSTRAINT CHK_USAGE_INTENSITY CHECK (USAGE_INTENSITY IN ('LOW', 'NORMAL', 'HIGH', 'VERY_HIGH'))
)
CLUSTER BY (USAGE_DATE, FEATURE_NAME);

-- =====================================================
-- 1.5 SI_SUPPORT_TICKETS Table
-- =====================================================
CREATE TABLE IF NOT EXISTS SILVER.SI_SUPPORT_TICKETS (
    TICKET_ID STRING NOT NULL,
    USER_ID STRING NOT NULL,
    TICKET_TYPE STRING NOT NULL,
    RESOLUTION_STATUS STRING NOT NULL,
    OPEN_DATE DATE NOT NULL,
    -- Metadata columns from Bronze
    LOAD_TIMESTAMP TIMESTAMP_NTZ NOT NULL,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ NOT NULL,
    SOURCE_SYSTEM STRING NOT NULL,
    -- Silver layer enrichment columns
    DATA_QUALITY_SCORE NUMBER(3,2) DEFAULT 0.00,
    IS_ACTIVE BOOLEAN DEFAULT TRUE,
    PRIORITY_LEVEL STRING DEFAULT 'MEDIUM',
    RESOLUTION_DATE DATE,
    DAYS_TO_RESOLUTION NUMBER,
    CREATED_DATE DATE,
    LAST_MODIFIED_DATE DATE DEFAULT CURRENT_DATE(),
    RECORD_HASH STRING,
    -- Constraints
    CONSTRAINT PK_SI_SUPPORT_TICKETS PRIMARY KEY (TICKET_ID),
    CONSTRAINT FK_SI_SUPPORT_TICKETS_USER FOREIGN KEY (USER_ID) REFERENCES SILVER.SI_USERS(USER_ID),
    CONSTRAINT CHK_RESOLUTION_STATUS CHECK (RESOLUTION_STATUS IN ('OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED', 'CANCELLED')),
    CONSTRAINT CHK_PRIORITY_LEVEL CHECK (PRIORITY_LEVEL IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL'))
)
CLUSTER BY (OPEN_DATE, RESOLUTION_STATUS);

-- =====================================================
-- 1.6 SI_BILLING_EVENTS Table
-- =====================================================
CREATE TABLE IF NOT EXISTS SILVER.SI_BILLING_EVENTS (
    EVENT_ID STRING NOT NULL,
    USER_ID STRING NOT NULL,
    EVENT_TYPE STRING NOT NULL,
    AMOUNT NUMBER(10,2) NOT NULL,
    EVENT_DATE DATE NOT NULL,
    -- Metadata columns from Bronze
    LOAD_TIMESTAMP TIMESTAMP_NTZ NOT NULL,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ NOT NULL,
    SOURCE_SYSTEM STRING NOT NULL,
    -- Silver layer enrichment columns
    DATA_QUALITY_SCORE NUMBER(3,2) DEFAULT 0.00,
    IS_ACTIVE BOOLEAN DEFAULT TRUE,
    CURRENCY_CODE STRING DEFAULT 'USD',
    BILLING_PERIOD STRING,
    PAYMENT_STATUS STRING DEFAULT 'PENDING',
    CREATED_DATE DATE,
    LAST_MODIFIED_DATE DATE DEFAULT CURRENT_DATE(),
    RECORD_HASH STRING,
    -- Constraints
    CONSTRAINT PK_SI_BILLING_EVENTS PRIMARY KEY (EVENT_ID),
    CONSTRAINT FK_SI_BILLING_EVENTS_USER FOREIGN KEY (USER_ID) REFERENCES SILVER.SI_USERS(USER_ID),
    CONSTRAINT CHK_AMOUNT CHECK (AMOUNT >= 0),
    CONSTRAINT CHK_EVENT_TYPE CHECK (EVENT_TYPE IN ('SUBSCRIPTION', 'UPGRADE', 'DOWNGRADE', 'REFUND', 'PAYMENT')),
    CONSTRAINT CHK_PAYMENT_STATUS CHECK (PAYMENT_STATUS IN ('PENDING', 'COMPLETED', 'FAILED', 'CANCELLED'))
)
CLUSTER BY (EVENT_DATE, USER_ID);

-- =====================================================
-- 1.7 SI_LICENSES Table
-- =====================================================
CREATE TABLE IF NOT EXISTS SILVER.SI_LICENSES (
    LICENSE_ID STRING NOT NULL,
    LICENSE_TYPE STRING NOT NULL,
    ASSIGNED_TO_USER_ID STRING NOT NULL,
    START_DATE DATE NOT NULL,
    END_DATE DATE,
    -- Metadata columns from Bronze
    LOAD_TIMESTAMP TIMESTAMP_NTZ NOT NULL,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ NOT NULL,
    SOURCE_SYSTEM STRING NOT NULL,
    -- Silver layer enrichment columns
    DATA_QUALITY_SCORE NUMBER(3,2) DEFAULT 0.00,
    IS_ACTIVE BOOLEAN DEFAULT TRUE,
    LICENSE_STATUS STRING DEFAULT 'ACTIVE',
    DAYS_REMAINING NUMBER,
    AUTO_RENEWAL BOOLEAN DEFAULT FALSE,
    CREATED_DATE DATE,
    LAST_MODIFIED_DATE DATE DEFAULT CURRENT_DATE(),
    RECORD_HASH STRING,
    -- Constraints
    CONSTRAINT PK_SI_LICENSES PRIMARY KEY (LICENSE_ID),
    CONSTRAINT FK_SI_LICENSES_USER FOREIGN KEY (ASSIGNED_TO_USER_ID) REFERENCES SILVER.SI_USERS(USER_ID),
    CONSTRAINT CHK_LICENSE_DATES CHECK (END_DATE IS NULL OR END_DATE >= START_DATE),
    CONSTRAINT CHK_LICENSE_STATUS CHECK (LICENSE_STATUS IN ('ACTIVE', 'EXPIRED', 'SUSPENDED', 'CANCELLED')),
    CONSTRAINT CHK_LICENSE_TYPE CHECK (LICENSE_TYPE IN ('BASIC', 'PRO', 'BUSINESS', 'ENTERPRISE', 'TRIAL'))
)
CLUSTER BY (LICENSE_TYPE, START_DATE);

-- =====================================================
-- 1.8 SI_DATA_QUALITY_ERRORS Table (Data Quality Error Tracking)
-- =====================================================
CREATE TABLE IF NOT EXISTS SILVER.SI_DATA_QUALITY_ERRORS (
    ERROR_ID STRING NOT NULL,
    SOURCE_TABLE STRING NOT NULL,
    SOURCE_RECORD_ID STRING,
    ERROR_TYPE STRING NOT NULL,
    ERROR_DESCRIPTION STRING NOT NULL,
    ERROR_SEVERITY STRING NOT NULL,
    DETECTED_TIMESTAMP TIMESTAMP_NTZ NOT NULL DEFAULT CURRENT_TIMESTAMP(),
    RESOLVED_TIMESTAMP TIMESTAMP_NTZ,
    RESOLUTION_STATUS STRING DEFAULT 'OPEN',
    RESOLUTION_NOTES STRING,
    DETECTED_BY STRING NOT NULL,
    RESOLVED_BY STRING,
    ERROR_COUNT NUMBER DEFAULT 1,
    BUSINESS_IMPACT STRING,
    -- Metadata columns
    LOAD_TIMESTAMP TIMESTAMP_NTZ NOT NULL,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ NOT NULL,
    SOURCE_SYSTEM STRING NOT NULL,
    CREATED_DATE DATE DEFAULT CURRENT_DATE(),
    LAST_MODIFIED_DATE DATE DEFAULT CURRENT_DATE(),
    -- Constraints
    CONSTRAINT PK_SI_DATA_QUALITY_ERRORS PRIMARY KEY (ERROR_ID),
    CONSTRAINT CHK_ERROR_SEVERITY CHECK (ERROR_SEVERITY IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    CONSTRAINT CHK_RESOLUTION_STATUS_DQ CHECK (RESOLUTION_STATUS IN ('OPEN', 'IN_PROGRESS', 'RESOLVED', 'IGNORED')),
    CONSTRAINT CHK_ERROR_TYPE CHECK (ERROR_TYPE IN ('MISSING_VALUE', 'INVALID_FORMAT', 'DUPLICATE_RECORD', 'REFERENTIAL_INTEGRITY', 'BUSINESS_RULE_VIOLATION', 'DATA_INCONSISTENCY'))
)
CLUSTER BY (DETECTED_TIMESTAMP, ERROR_SEVERITY);

-- =====================================================
-- 1.9 SI_PIPELINE_AUDIT Table (Pipeline Execution Audit)
-- =====================================================
CREATE TABLE IF NOT EXISTS SILVER.SI_PIPELINE_AUDIT (
    AUDIT_ID STRING NOT NULL,
    PIPELINE_NAME STRING NOT NULL,
    PIPELINE_VERSION STRING,
    EXECUTION_ID STRING NOT NULL,
    START_TIMESTAMP TIMESTAMP_NTZ NOT NULL,
    END_TIMESTAMP TIMESTAMP_NTZ,
    EXECUTION_STATUS STRING NOT NULL,
    RECORDS_PROCESSED NUMBER DEFAULT 0,
    RECORDS_SUCCESS NUMBER DEFAULT 0,
    RECORDS_FAILED NUMBER DEFAULT 0,
    RECORDS_SKIPPED NUMBER DEFAULT 0,
    SOURCE_TABLE STRING,
    TARGET_TABLE STRING,
    PROCESSING_TIME_SECONDS NUMBER,
    ERROR_MESSAGE STRING,
    ERROR_DETAILS STRING,
    EXECUTED_BY STRING NOT NULL,
    EXECUTION_MODE STRING DEFAULT 'BATCH',
    DATA_VOLUME_MB NUMBER,
    PERFORMANCE_METRICS STRING,
    -- Metadata columns
    LOAD_TIMESTAMP TIMESTAMP_NTZ NOT NULL,
    UPDATE_TIMESTAMP TIMESTAMP_NTZ NOT NULL,
    SOURCE_SYSTEM STRING NOT NULL,
    CREATED_DATE DATE DEFAULT CURRENT_DATE(),
    LAST_MODIFIED_DATE DATE DEFAULT CURRENT_DATE(),
    -- Constraints
    CONSTRAINT PK_SI_PIPELINE_AUDIT PRIMARY KEY (AUDIT_ID),
    CONSTRAINT CHK_EXECUTION_STATUS CHECK (EXECUTION_STATUS IN ('RUNNING', 'SUCCESS', 'FAILED', 'CANCELLED', 'TIMEOUT')),
    CONSTRAINT CHK_EXECUTION_MODE CHECK (EXECUTION_MODE IN ('BATCH', 'STREAMING', 'INCREMENTAL', 'FULL_REFRESH')),
    CONSTRAINT CHK_RECORD_COUNTS CHECK (RECORDS_PROCESSED = RECORDS_SUCCESS + RECORDS_FAILED + RECORDS_SKIPPED)
)
CLUSTER BY (START_TIMESTAMP, PIPELINE_NAME);

-- =====================================================
-- 2. Indexes for Performance Optimization
-- =====================================================

-- Note: Snowflake uses automatic micro-partitioning and clustering keys instead of traditional indexes
-- The CLUSTER BY clauses above provide the necessary performance optimization

-- =====================================================
-- 3. Views for Common Business Queries
-- =====================================================

-- 3.1 Active Users View
CREATE OR REPLACE VIEW SILVER.VW_ACTIVE_USERS AS
SELECT 
    USER_ID,
    USER_NAME,
    EMAIL,
    COMPANY,
    PLAN_TYPE,
    DATA_QUALITY_SCORE,
    CREATED_DATE,
    LAST_MODIFIED_DATE
FROM SILVER.SI_USERS
WHERE IS_ACTIVE = TRUE;

-- 3.2 Meeting Summary View
CREATE OR REPLACE VIEW SILVER.VW_MEETING_SUMMARY AS
SELECT 
    m.MEETING_ID,
    m.HOST_ID,
    u.USER_NAME AS HOST_NAME,
    m.MEETING_TOPIC,
    m.START_TIME,
    m.END_TIME,
    m.DURATION_MINUTES,
    m.PARTICIPANT_COUNT,
    m.MEETING_STATUS
FROM SILVER.SI_MEETINGS m
JOIN SILVER.SI_USERS u ON m.HOST_ID = u.USER_ID
WHERE m.IS_ACTIVE = TRUE;

-- 3.3 Data Quality Dashboard View
CREATE OR REPLACE VIEW SILVER.VW_DATA_QUALITY_DASHBOARD AS
SELECT 
    SOURCE_TABLE,
    ERROR_TYPE,
    ERROR_SEVERITY,
    COUNT(*) AS ERROR_COUNT,
    COUNT(CASE WHEN RESOLUTION_STATUS = 'RESOLVED' THEN 1 END) AS RESOLVED_COUNT,
    COUNT(CASE WHEN RESOLUTION_STATUS = 'OPEN' THEN 1 END) AS OPEN_COUNT,
    AVG(DATEDIFF('hour', DETECTED_TIMESTAMP, COALESCE(RESOLVED_TIMESTAMP, CURRENT_TIMESTAMP()))) AS AVG_RESOLUTION_TIME_HOURS
FROM SILVER.SI_DATA_QUALITY_ERRORS
GROUP BY SOURCE_TABLE, ERROR_TYPE, ERROR_SEVERITY;

-- =====================================================
-- 4. Data Type Mapping and Justification
-- =====================================================
/*
4.1 Snowflake Data Types Used:
   - STRING: Used for all text fields with variable length
   - NUMBER: Used for numeric values with precision specified where needed
   - TIMESTAMP_NTZ: Used for all timestamp fields (without timezone)
   - DATE: Used for date-only fields
   - BOOLEAN: Used for flag fields (IS_ACTIVE, AUTO_RENEWAL)

4.2 Silver Layer Design Principles:
   - Primary keys and foreign keys for referential integrity
   - Check constraints for data validation
   - Clustering keys for query performance
   - Data quality scoring for monitoring
   - Audit trails for compliance
   - Enrichment columns for business intelligence

4.3 Enhanced Metadata Columns:
   - All Bronze layer columns preserved
   - DATA_QUALITY_SCORE: Numeric score for data quality assessment
   - IS_ACTIVE: Boolean flag for soft deletes
   - CREATED_DATE/LAST_MODIFIED_DATE: Business date tracking
   - RECORD_HASH: For change data capture

4.4 Data Quality and Audit Features:
   - SI_DATA_QUALITY_ERRORS: Comprehensive error tracking
   - SI_PIPELINE_AUDIT: Complete pipeline execution monitoring
   - Error categorization and severity levels
   - Performance metrics and processing statistics
*/

-- =====================================================
-- 5. Implementation Notes
-- =====================================================
/*
5.1 Schema Structure:
   - All tables created in SILVER schema
   - Compatible with Snowflake SQL standards
   - Follows Medallion architecture principles
   - Maintains all Bronze layer columns

5.2 Data Loading Strategy:
   - Implement CDC (Change Data Capture) using RECORD_HASH
   - Use MERGE statements for upsert operations
   - Validate data quality during transformation
   - Log all processing activities in audit table

5.3 Performance Considerations:
   - Clustering keys optimized for common query patterns
   - Micro-partitioning on date and ID fields
   - Views for complex business queries
   - Materialized views for heavy analytical workloads

5.4 Data Quality Framework:
   - Automated data quality checks during ingestion
   - Error categorization and severity assessment
   - Resolution workflow tracking
   - Business impact analysis

5.5 Security and Compliance:
   - Role-based access control (RBAC)
   - Audit trail for all data changes
   - Data lineage tracking
   - Compliance with data governance standards

5.6 Monitoring and Alerting:
   - Pipeline execution monitoring
   - Data quality threshold alerts
   - Performance degradation detection
   - Automated error notification
*/

-- =====================================================
-- 6. Sample Usage Examples
-- =====================================================
/*
6.1 Data Quality Check Example:
INSERT INTO SILVER.SI_DATA_QUALITY_ERRORS 
(ERROR_ID, SOURCE_TABLE, SOURCE_RECORD_ID, ERROR_TYPE, ERROR_DESCRIPTION, ERROR_SEVERITY, DETECTED_BY, LOAD_TIMESTAMP, UPDATE_TIMESTAMP, SOURCE_SYSTEM)
VALUES 
('DQ_001', 'SI_USERS', 'USER_123', 'INVALID_FORMAT', 'Email format validation failed', 'MEDIUM', 'DATA_VALIDATION_PROCESS', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 'SILVER_ETL');

6.2 Pipeline Audit Example:
INSERT INTO SILVER.SI_PIPELINE_AUDIT 
(AUDIT_ID, PIPELINE_NAME, EXECUTION_ID, START_TIMESTAMP, END_TIMESTAMP, EXECUTION_STATUS, RECORDS_PROCESSED, RECORDS_SUCCESS, EXECUTED_BY, LOAD_TIMESTAMP, UPDATE_TIMESTAMP, SOURCE_SYSTEM)
VALUES 
('AUDIT_001', 'BRONZE_TO_SILVER_USERS', 'EXEC_20241219_001', '2024-12-19 10:00:00', '2024-12-19 10:05:00', 'SUCCESS', 1000, 995, 'ETL_SERVICE', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 'SILVER_ETL');

6.3 Data Transformation Example:
MERGE INTO SILVER.SI_USERS AS target
USING (
    SELECT 
        USER_ID,
        TRIM(UPPER(USER_NAME)) AS USER_NAME,
        LOWER(EMAIL) AS EMAIL,
        COMPANY,
        PLAN_TYPE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        HASH(USER_ID, USER_NAME, EMAIL, COMPANY, PLAN_TYPE) AS RECORD_HASH
    FROM BRONZE.BZ_USERS
    WHERE LOAD_TIMESTAMP > (SELECT COALESCE(MAX(UPDATE_TIMESTAMP), '1900-01-01') FROM SILVER.SI_USERS)
) AS source
ON target.USER_ID = source.USER_ID
WHEN MATCHED AND target.RECORD_HASH != source.RECORD_HASH THEN
    UPDATE SET 
        USER_NAME = source.USER_NAME,
        EMAIL = source.EMAIL,
        COMPANY = source.COMPANY,
        PLAN_TYPE = source.PLAN_TYPE,
        UPDATE_TIMESTAMP = source.UPDATE_TIMESTAMP,
        LAST_MODIFIED_DATE = CURRENT_DATE(),
        RECORD_HASH = source.RECORD_HASH
WHEN NOT MATCHED THEN
    INSERT (USER_ID, USER_NAME, EMAIL, COMPANY, PLAN_TYPE, LOAD_TIMESTAMP, UPDATE_TIMESTAMP, SOURCE_SYSTEM, CREATED_DATE, RECORD_HASH)
    VALUES (source.USER_ID, source.USER_NAME, source.EMAIL, source.COMPANY, source.PLAN_TYPE, source.LOAD_TIMESTAMP, source.UPDATE_TIMESTAMP, source.SOURCE_SYSTEM, CURRENT_DATE(), source.RECORD_HASH);
*/

-- =====================================================
-- End of Silver Layer Physical Data Model
-- =====================================================