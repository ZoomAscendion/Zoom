_____________________________________________
-- *Author*: AAVA
-- *Created on*:   
-- *Description*: Silver Physical Data Model DDL scripts for Zoom Platform Analytics System following Medallion architecture
-- *Version*: 1 
-- *Updated on*: 
_____________________________________________

-- =============================================
-- SILVER LAYER PHYSICAL DATA MODEL
-- Zoom Platform Analytics System
-- =============================================

-- Create Silver Schema if not exists
CREATE SCHEMA IF NOT EXISTS SILVER
    COMMENT = 'Silver layer schema for cleansed and conformed data following Medallion architecture';

USE SCHEMA SILVER;

-- =============================================
-- 1. SILVER LAYER DDL SCRIPTS FOR ALL TABLES
-- =============================================

-- =============================================
-- TABLE 1: SILVER.SI_USERS
-- Source: BRONZE.BZ_USERS
-- Description: Silver layer table containing cleaned and standardized user data
-- =============================================

CREATE TABLE IF NOT EXISTS SILVER.SI_USERS (
    -- Primary Identifier (Added for Physical Model)
    USER_ID                 STRING              COMMENT 'Unique identifier for each user account - added for physical model',
    
    -- Business Columns from Bronze Layer
    USER_NAME               STRING              COMMENT 'Standardized full name of the registered user, cleaned and validated',
    EMAIL                   STRING              COMMENT 'Standardized email address following RFC 5322 format, validated for proper email structure',
    COMPANY                 STRING              COMMENT 'Standardized organization or company affiliation, cleaned and normalized',
    PLAN_TYPE               STRING              COMMENT 'Standardized subscription tier (Free, Basic, Pro, Enterprise) with consistent casing',
    
    -- Silver Layer Enhancement Columns
    DATA_QUALITY_SCORE      NUMBER(3,2)         COMMENT 'Quality score between 0.00 and 1.00 indicating data completeness and accuracy',
    IS_ACTIVE               BOOLEAN             COMMENT 'Flag indicating if the user account is currently active',
    
    -- Metadata Columns
    LOAD_DATE               DATE                COMMENT 'Date when record was loaded into the silver layer',
    UPDATE_DATE             DATE                COMMENT 'Date when record was last updated in the silver layer',
    LOAD_TIMESTAMP          TIMESTAMP_NTZ       COMMENT 'Timestamp when record was loaded into the silver layer with timezone normalization',
    UPDATE_TIMESTAMP        TIMESTAMP_NTZ       COMMENT 'Timestamp when record was last updated in the silver layer',
    SOURCE_SYSTEM           STRING              COMMENT 'Standardized source system identifier'
)
COMMENT = 'Silver layer table containing cleaned and standardized user data with data type standardization and quality checks applied';

-- =============================================
-- TABLE 2: SILVER.SI_MEETINGS
-- Source: BRONZE.BZ_MEETINGS
-- Description: Silver layer table containing cleaned meeting data
-- =============================================

CREATE TABLE IF NOT EXISTS SILVER.SI_MEETINGS (
    -- Primary Identifier (Added for Physical Model)
    MEETING_ID              STRING              COMMENT 'Unique identifier for each meeting - added for physical model',
    
    -- Foreign Key Reference (Added for Physical Model)
    HOST_ID                 STRING              COMMENT 'User ID of the meeting host - added for physical model',
    
    -- Business Columns from Bronze Layer
    MEETING_TOPIC           STRING              COMMENT 'Standardized meeting topic with special characters cleaned and length validated',
    START_TIME              TIMESTAMP_NTZ       COMMENT 'Standardized meeting start time converted to UTC timezone',
    END_TIME                TIMESTAMP_NTZ       COMMENT 'Standardized meeting end time converted to UTC timezone',
    DURATION_MINUTES        NUMBER(38,0)        COMMENT 'Calculated meeting duration in minutes, validated for logical consistency',
    
    -- Silver Layer Enhancement Columns
    MEETING_STATUS          STRING              COMMENT 'Standardized meeting status (Completed, Cancelled, In Progress)',
    IS_VALID_DURATION       BOOLEAN             COMMENT 'Flag indicating if meeting duration passes business rule validation',
    
    -- Metadata Columns
    LOAD_DATE               DATE                COMMENT 'Date when record was loaded into the silver layer',
    UPDATE_DATE             DATE                COMMENT 'Date when record was last updated in the silver layer',
    LOAD_TIMESTAMP          TIMESTAMP_NTZ       COMMENT 'Timestamp when record was loaded into the silver layer',
    UPDATE_TIMESTAMP        TIMESTAMP_NTZ       COMMENT 'Timestamp when record was last updated in the silver layer',
    SOURCE_SYSTEM           STRING              COMMENT 'Standardized source system identifier'
)
COMMENT = 'Silver layer table containing cleaned meeting data with standardized duration calculations and time zone normalization';

-- =============================================
-- TABLE 3: SILVER.SI_PARTICIPANTS
-- Source: BRONZE.BZ_PARTICIPANTS
-- Description: Silver layer table containing cleaned participant data
-- =============================================

CREATE TABLE IF NOT EXISTS SILVER.SI_PARTICIPANTS (
    -- Primary Identifier (Added for Physical Model)
    PARTICIPANT_ID          STRING              COMMENT 'Unique identifier for each participant record - added for physical model',
    
    -- Foreign Key References (Added for Physical Model)
    MEETING_ID              STRING              COMMENT 'Reference to meeting - added for physical model',
    USER_ID                 STRING              COMMENT 'Reference to user who participated - added for physical model',
    
    -- Business Columns from Bronze Layer
    JOIN_TIME               TIMESTAMP_NTZ       COMMENT 'Standardized participant join time converted to UTC timezone',
    LEAVE_TIME              TIMESTAMP_NTZ       COMMENT 'Standardized participant leave time converted to UTC timezone',
    
    -- Silver Layer Enhancement Columns
    ATTENDANCE_DURATION_MINUTES NUMBER(38,0)    COMMENT 'Calculated attendance duration in minutes derived from join and leave times',
    PARTICIPATION_STATUS    STRING              COMMENT 'Standardized participation status (Full, Partial, Brief)',
    IS_VALID_ATTENDANCE     BOOLEAN             COMMENT 'Flag indicating if attendance times pass validation rules',
    
    -- Metadata Columns
    LOAD_DATE               DATE                COMMENT 'Date when record was loaded into the silver layer',
    UPDATE_DATE             DATE                COMMENT 'Date when record was last updated in the silver layer',
    LOAD_TIMESTAMP          TIMESTAMP_NTZ       COMMENT 'Timestamp when record was loaded into the silver layer',
    UPDATE_TIMESTAMP        TIMESTAMP_NTZ       COMMENT 'Timestamp when record was last updated in the silver layer',
    SOURCE_SYSTEM           STRING              COMMENT 'Standardized source system identifier'
)
COMMENT = 'Silver layer table containing cleaned participant data with calculated attendance metrics';

-- =============================================
-- TABLE 4: SILVER.SI_FEATURE_USAGE
-- Source: BRONZE.BZ_FEATURE_USAGE
-- Description: Silver layer table containing standardized feature usage data
-- =============================================

CREATE TABLE IF NOT EXISTS SILVER.SI_FEATURE_USAGE (
    -- Primary Identifier (Added for Physical Model)
    USAGE_ID                STRING              COMMENT 'Unique identifier for each feature usage record - added for physical model',
    
    -- Foreign Key Reference (Added for Physical Model)
    MEETING_ID              STRING              COMMENT 'Reference to meeting where feature was used - added for physical model',
    
    -- Business Columns from Bronze Layer
    FEATURE_NAME            STRING              COMMENT 'Standardized feature name with consistent naming convention',
    USAGE_COUNT             NUMBER(38,0)        COMMENT 'Validated usage count ensuring non-negative values',
    USAGE_DATE              DATE                COMMENT 'Standardized usage date with proper date validation',
    
    -- Silver Layer Enhancement Columns
    FEATURE_CATEGORY        STRING              COMMENT 'Categorized feature type (Audio, Video, Collaboration, Security)',
    USAGE_INTENSITY         STRING              COMMENT 'Calculated usage intensity (Low, Medium, High) based on usage count',
    
    -- Metadata Columns
    LOAD_DATE               DATE                COMMENT 'Date when record was loaded into the silver layer',
    UPDATE_DATE             DATE                COMMENT 'Date when record was last updated in the silver layer',
    LOAD_TIMESTAMP          TIMESTAMP_NTZ       COMMENT 'Timestamp when record was loaded into the silver layer',
    UPDATE_TIMESTAMP        TIMESTAMP_NTZ       COMMENT 'Timestamp when record was last updated in the silver layer',
    SOURCE_SYSTEM           STRING              COMMENT 'Standardized source system identifier'
)
COMMENT = 'Silver layer table containing standardized feature usage data with usage pattern analysis';

-- =============================================
-- TABLE 5: SILVER.SI_SUPPORT_TICKETS
-- Source: BRONZE.BZ_SUPPORT_TICKETS
-- Description: Silver layer table containing standardized support ticket data
-- =============================================

CREATE TABLE IF NOT EXISTS SILVER.SI_SUPPORT_TICKETS (
    -- Primary Identifier (Added for Physical Model)
    TICKET_ID               STRING              COMMENT 'Unique identifier for each support ticket - added for physical model',
    
    -- Foreign Key Reference (Added for Physical Model)
    USER_ID                 STRING              COMMENT 'Reference to user who created the ticket - added for physical model',
    
    -- Business Columns from Bronze Layer
    TICKET_TYPE             STRING              COMMENT 'Standardized ticket category (Technical, Billing, Feature Request, Bug Report)',
    RESOLUTION_STATUS       STRING              COMMENT 'Standardized resolution status (Open, In Progress, Resolved, Closed)',
    OPEN_DATE               DATE                COMMENT 'Validated ticket creation date',
    
    -- Silver Layer Enhancement Columns
    CLOSE_DATE              DATE                COMMENT 'Validated ticket closure date (null if still open)',
    RESOLUTION_TIME_HOURS   NUMBER(10,2)        COMMENT 'Calculated resolution time in hours for closed tickets',
    PRIORITY_LEVEL          STRING              COMMENT 'Standardized priority (Low, Medium, High, Critical)',
    SLA_COMPLIANCE          BOOLEAN             COMMENT 'Flag indicating if ticket resolution met SLA requirements',
    
    -- Metadata Columns
    LOAD_DATE               DATE                COMMENT 'Date when record was loaded into the silver layer',
    UPDATE_DATE             DATE                COMMENT 'Date when record was last updated in the silver layer',
    LOAD_TIMESTAMP          TIMESTAMP_NTZ       COMMENT 'Timestamp when record was loaded into the silver layer',
    UPDATE_TIMESTAMP        TIMESTAMP_NTZ       COMMENT 'Timestamp when record was last updated in the silver layer',
    SOURCE_SYSTEM           STRING              COMMENT 'Standardized source system identifier'
)
COMMENT = 'Silver layer table containing standardized support ticket data with resolution time calculations';

-- =============================================
-- TABLE 6: SILVER.SI_BILLING_EVENTS
-- Source: BRONZE.BZ_BILLING_EVENTS
-- Description: Silver layer table containing standardized billing data
-- =============================================

CREATE TABLE IF NOT EXISTS SILVER.SI_BILLING_EVENTS (
    -- Primary Identifier (Added for Physical Model)
    EVENT_ID                STRING              COMMENT 'Unique identifier for each billing event - added for physical model',
    
    -- Foreign Key Reference (Added for Physical Model)
    USER_ID                 STRING              COMMENT 'Reference to user associated with billing event - added for physical model',
    
    -- Business Columns from Bronze Layer
    EVENT_TYPE              STRING              COMMENT 'Standardized billing event type (Subscription, Upgrade, Downgrade, Refund)',
    AMOUNT                  NUMBER(15,2)        COMMENT 'Validated monetary amount with proper decimal precision',
    EVENT_DATE              DATE                COMMENT 'Validated billing event date',
    
    -- Silver Layer Enhancement Columns
    AMOUNT_USD              NUMBER(15,2)        COMMENT 'Amount converted to USD for standardized reporting',
    CURRENCY_CODE           STRING              COMMENT 'Standardized ISO currency code',
    REVENUE_CATEGORY        STRING              COMMENT 'Categorized revenue type (Recurring, One-time, Refund)',
    IS_VALID_AMOUNT         BOOLEAN             COMMENT 'Flag indicating if amount passes validation rules',
    
    -- Metadata Columns
    LOAD_DATE               DATE                COMMENT 'Date when record was loaded into the silver layer',
    UPDATE_DATE             DATE                COMMENT 'Date when record was last updated in the silver layer',
    LOAD_TIMESTAMP          TIMESTAMP_NTZ       COMMENT 'Timestamp when record was loaded into the silver layer',
    UPDATE_TIMESTAMP        TIMESTAMP_NTZ       COMMENT 'Timestamp when record was last updated in the silver layer',
    SOURCE_SYSTEM           STRING              COMMENT 'Standardized source system identifier'
)
COMMENT = 'Silver layer table containing standardized billing data with currency normalization and amount validation';

-- =============================================
-- TABLE 7: SILVER.SI_LICENSES
-- Source: BRONZE.BZ_LICENSES
-- Description: Silver layer table containing standardized license data
-- =============================================

CREATE TABLE IF NOT EXISTS SILVER.SI_LICENSES (
    -- Primary Identifier (Added for Physical Model)
    LICENSE_ID              STRING              COMMENT 'Unique identifier for each license - added for physical model',
    
    -- Foreign Key Reference (Added for Physical Model)
    ASSIGNED_TO_USER_ID     STRING              COMMENT 'User ID to whom license is assigned - added for physical model',
    
    -- Business Columns from Bronze Layer
    LICENSE_TYPE            STRING              COMMENT 'Standardized license category (Basic, Pro, Enterprise, Add-on)',
    START_DATE              DATE                COMMENT 'Validated license activation date',
    END_DATE                DATE                COMMENT 'Validated license expiration date',
    
    -- Silver Layer Enhancement Columns
    LICENSE_DURATION_DAYS   NUMBER(38,0)        COMMENT 'Calculated license duration in days',
    LICENSE_STATUS          STRING              COMMENT 'Calculated license status (Active, Expired, Expiring Soon)',
    DAYS_TO_EXPIRY          NUMBER(38,0)        COMMENT 'Calculated days remaining until license expiration',
    IS_RENEWABLE            BOOLEAN             COMMENT 'Flag indicating if license is eligible for renewal',
    
    -- Metadata Columns
    LOAD_DATE               DATE                COMMENT 'Date when record was loaded into the silver layer',
    UPDATE_DATE             DATE                COMMENT 'Date when record was last updated in the silver layer',
    LOAD_TIMESTAMP          TIMESTAMP_NTZ       COMMENT 'Timestamp when record was loaded into the silver layer',
    UPDATE_TIMESTAMP        TIMESTAMP_NTZ       COMMENT 'Timestamp when record was last updated in the silver layer',
    SOURCE_SYSTEM           STRING              COMMENT 'Standardized source system identifier'
)
COMMENT = 'Silver layer table containing standardized license data with lifecycle status calculations';

-- =============================================
-- TABLE 8: SILVER.SI_WEBINARS
-- Source: BRONZE.BZ_WEBINARS
-- Description: Silver layer table containing standardized webinar data
-- =============================================

CREATE TABLE IF NOT EXISTS SILVER.SI_WEBINARS (
    -- Primary Identifier (Added for Physical Model)
    WEBINAR_ID              STRING              COMMENT 'Unique identifier for each webinar - added for physical model',
    
    -- Foreign Key Reference (Added for Physical Model)
    HOST_ID                 STRING              COMMENT 'User ID of the webinar host - added for physical model',
    
    -- Business Columns from Bronze Layer
    WEBINAR_TOPIC           STRING              COMMENT 'Standardized webinar topic with cleaned formatting',
    START_TIME              TIMESTAMP_NTZ       COMMENT 'Standardized webinar start time converted to UTC',
    END_TIME                TIMESTAMP_NTZ       COMMENT 'Standardized webinar end time converted to UTC',
    REGISTRANTS             NUMBER(38,0)        COMMENT 'Validated number of registered participants',
    
    -- Silver Layer Enhancement Columns
    DURATION_MINUTES        NUMBER(38,0)        COMMENT 'Calculated webinar duration in minutes',
    WEBINAR_STATUS          STRING              COMMENT 'Standardized webinar status (Completed, Cancelled, Scheduled)',
    ATTENDANCE_RATE         NUMBER(5,2)         COMMENT 'Calculated attendance rate as percentage of registrants',
    
    -- Metadata Columns
    LOAD_DATE               DATE                COMMENT 'Date when record was loaded into the silver layer',
    UPDATE_DATE             DATE                COMMENT 'Date when record was last updated in the silver layer',
    LOAD_TIMESTAMP          TIMESTAMP_NTZ       COMMENT 'Timestamp when record was loaded into the silver layer',
    UPDATE_TIMESTAMP        TIMESTAMP_NTZ       COMMENT 'Timestamp when record was last updated in the silver layer',
    SOURCE_SYSTEM           STRING              COMMENT 'Standardized source system identifier'
)
COMMENT = 'Silver layer table containing standardized webinar data with attendance metrics';

-- =============================================
-- 2. ERROR DATA TABLE DDL SCRIPT
-- =============================================

-- =============================================
-- TABLE 9: SILVER.SI_DATA_QUALITY_ERRORS
-- Description: Error Data Table for storing data validation errors
-- =============================================

CREATE TABLE IF NOT EXISTS SILVER.SI_DATA_QUALITY_ERRORS (
    -- Primary Identifier
    ERROR_ID                STRING              COMMENT 'Unique identifier for each data quality error record',
    
    -- Error Details
    ERROR_TIMESTAMP         TIMESTAMP_NTZ       COMMENT 'Timestamp when the data quality error was detected',
    SOURCE_TABLE            STRING              COMMENT 'Name of the source table where error was found',
    ERROR_TYPE              STRING              COMMENT 'Type of data quality error (Missing Value, Invalid Format, Business Rule Violation)',
    ERROR_DESCRIPTION       STRING              COMMENT 'Detailed description of the data quality issue',
    AFFECTED_COLUMNS        STRING              COMMENT 'List of columns affected by the data quality issue',
    ERROR_SEVERITY          STRING              COMMENT 'Severity level of the error (Low, Medium, High, Critical)',
    RESOLUTION_STATUS       STRING              COMMENT 'Status of error resolution (Open, In Progress, Resolved, Ignored)',
    RESOLUTION_ACTION       STRING              COMMENT 'Action taken to resolve the data quality issue',
    CREATED_BY              STRING              COMMENT 'System or process that detected the error',
    RESOLVED_BY             STRING              COMMENT 'System or user that resolved the error',
    RESOLVED_TIMESTAMP      TIMESTAMP_NTZ       COMMENT 'Timestamp when the error was resolved',
    
    -- Metadata Columns
    LOAD_DATE               DATE                COMMENT 'Date when record was loaded into the silver layer',
    UPDATE_DATE             DATE                COMMENT 'Date when record was last updated in the silver layer',
    SOURCE_SYSTEM           STRING              COMMENT 'Source system identifier'
)
COMMENT = 'Silver layer table for storing data validation errors and quality issues identified during processing';

-- =============================================
-- 3. AUDIT TABLE DDL SCRIPT
-- =============================================

-- =============================================
-- TABLE 10: SILVER.SI_PIPELINE_AUDIT
-- Description: Audit Table for tracking pipeline execution details
-- =============================================

CREATE TABLE IF NOT EXISTS SILVER.SI_PIPELINE_AUDIT (
    -- Primary Identifier
    AUDIT_ID                STRING              COMMENT 'Unique identifier for each audit record',
    
    -- Pipeline Execution Details
    EXECUTION_ID            STRING              COMMENT 'Unique identifier for each pipeline execution',
    PIPELINE_NAME           STRING              COMMENT 'Name of the data pipeline or transformation process',
    START_TIME              TIMESTAMP_NTZ       COMMENT 'Timestamp when pipeline execution started',
    END_TIME                TIMESTAMP_NTZ       COMMENT 'Timestamp when pipeline execution completed',
    STATUS                  STRING              COMMENT 'Overall status of pipeline execution (Success, Failed, Partial Success)',
    ERROR_MESSAGE           STRING              COMMENT 'Error message if pipeline execution failed',
    
    -- Processing Statistics
    EXECUTION_DURATION_SECONDS NUMBER(38,0)     COMMENT 'Total execution time in seconds',
    SOURCE_TABLE            STRING              COMMENT 'Name of the source table being processed',
    TARGET_TABLE            STRING              COMMENT 'Name of the target table being populated',
    RECORDS_PROCESSED       NUMBER(38,0)        COMMENT 'Total number of records processed in the pipeline run',
    RECORDS_SUCCESS         NUMBER(38,0)        COMMENT 'Number of records successfully processed',
    RECORDS_FAILED          NUMBER(38,0)        COMMENT 'Number of records that failed processing',
    RECORDS_SKIPPED         NUMBER(38,0)        COMMENT 'Number of records skipped due to business rules',
    
    -- Additional Metadata
    EXECUTED_BY             STRING              COMMENT 'User or system that executed the pipeline',
    CONFIGURATION_HASH      STRING              COMMENT 'Hash of pipeline configuration for change tracking',
    DATA_FRESHNESS_HOURS    NUMBER(10,2)        COMMENT 'Hours between source data creation and processing',
    
    -- Standard Metadata Columns
    LOAD_DATE               DATE                COMMENT 'Date when record was loaded',
    UPDATE_DATE             DATE                COMMENT 'Date when record was last updated',
    SOURCE_SYSTEM           STRING              COMMENT 'Source system identifier'
)
COMMENT = 'Silver layer table for tracking pipeline execution details and processing statistics';

-- =============================================
-- 4. UPDATE DDL SCRIPT (FOR SCHEMA EVOLUTION)
-- =============================================

-- =============================================
-- SCHEMA EVOLUTION SCRIPTS
-- Description: Scripts for handling schema changes and updates
-- =============================================

-- Add new columns to existing tables (Example template)
-- ALTER TABLE SILVER.SI_USERS ADD COLUMN NEW_COLUMN_NAME STRING COMMENT 'Description of new column';

-- Modify existing column data types (Example template)
-- ALTER TABLE SILVER.SI_USERS ALTER COLUMN EXISTING_COLUMN_NAME SET DATA TYPE NEW_DATA_TYPE;

-- Add comments to existing columns (Example template)
-- ALTER TABLE SILVER.SI_USERS ALTER COLUMN EXISTING_COLUMN_NAME COMMENT 'Updated comment for existing column';

-- Create indexes for performance optimization (Example template)
-- Note: Snowflake uses clustering keys instead of traditional indexes
-- ALTER TABLE SILVER.SI_MEETINGS CLUSTER BY (START_TIME, HOST_ID);
-- ALTER TABLE SILVER.SI_PARTICIPANTS CLUSTER BY (MEETING_ID, JOIN_TIME);
-- ALTER TABLE SILVER.SI_FEATURE_USAGE CLUSTER BY (USAGE_DATE, FEATURE_NAME);
-- ALTER TABLE SILVER.SI_SUPPORT_TICKETS CLUSTER BY (OPEN_DATE, TICKET_TYPE);
-- ALTER TABLE SILVER.SI_BILLING_EVENTS CLUSTER BY (EVENT_DATE, USER_ID);
-- ALTER TABLE SILVER.SI_LICENSES CLUSTER BY (START_DATE, LICENSE_TYPE);
-- ALTER TABLE SILVER.SI_WEBINARS CLUSTER BY (START_TIME, HOST_ID);

-- =============================================
-- SILVER LAYER SUMMARY
-- =============================================

/*
SILVER LAYER TABLES CREATED:

1. SILVER.SI_USERS                   - Cleaned and standardized user data (13 columns)
2. SILVER.SI_MEETINGS                - Cleaned meeting data with enhancements (13 columns)
3. SILVER.SI_PARTICIPANTS            - Cleaned participant data with metrics (12 columns)
4. SILVER.SI_FEATURE_USAGE           - Standardized feature usage data (11 columns)
5. SILVER.SI_SUPPORT_TICKETS         - Standardized support ticket data (13 columns)
6. SILVER.SI_BILLING_EVENTS          - Standardized billing data with currency normalization (13 columns)
7. SILVER.SI_LICENSES                - Standardized license data with lifecycle calculations (13 columns)
8. SILVER.SI_WEBINARS                - Standardized webinar data with attendance metrics (12 columns)
9. SILVER.SI_DATA_QUALITY_ERRORS     - Error tracking table (13 columns)
10. SILVER.SI_PIPELINE_AUDIT         - Pipeline execution audit table (18 columns)

KEY FEATURES:
• All tables follow 'SI_' naming convention for Silver layer
• ID fields added to all tables for physical model requirements
• All Bronze layer columns preserved and enhanced
• No primary keys, foreign keys, or constraints (following Snowflake best practices)
• Snowflake-compatible data types used throughout (STRING, NUMBER, BOOLEAN, DATE, TIMESTAMP_NTZ)
• Comprehensive metadata columns for data lineage and quality tracking
• Data quality enhancement columns added (validation flags, calculated fields)
• Error Data Table for comprehensive error tracking
• Audit Table for pipeline execution monitoring
• Schema evolution scripts provided for future updates
• All tables include detailed column comments for documentation
• CREATE TABLE IF NOT EXISTS syntax for safe deployment
• Clustering key suggestions provided for performance optimization

DATA FLOW:
BRONZE Schema → SILVER Schema → (Future: GOLD Schema)

This Silver Physical Data Model serves as the cleansed and conformed layer in the Medallion architecture,
storing validated and standardized data from the Bronze layer while adding business logic enhancements,
data quality tracking, and comprehensive audit capabilities for the Zoom platform analytics system.

API COST: 0.045230 USD
*/

-- End of Silver Physical Data Model DDL Script