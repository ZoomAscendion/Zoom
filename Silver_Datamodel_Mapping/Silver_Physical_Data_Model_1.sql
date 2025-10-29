_____________________________________________
-- Author: AAVA
-- Created on: 
-- Description: Silver Physical Data Model DDL scripts for Zoom Platform Analytics System following Medallion architecture with data quality and audit capabilities
-- Version: 1
-- Updated on: 
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
-- SECTION 1: SILVER LAYER TABLES
-- =============================================

-- =============================================
-- TABLE 1: SILVER.SI_USERS
-- Source: BRONZE.BZ_USERS
-- Description: Silver layer table containing cleaned and standardized user data with data quality validations applied
-- =============================================

CREATE TABLE IF NOT EXISTS SILVER.SI_USERS (
    -- ID Field (Added in Physical Model)
    USER_ID                 STRING              COMMENT 'Unique identifier for each user account',
    
    -- Business Columns from Bronze + Silver Logical Model
    USER_NAME               STRING              COMMENT 'Standardized full name of the registered user with proper case formatting',
    EMAIL                   STRING              COMMENT 'Validated and standardized email address for user communication',
    COMPANY                 STRING              COMMENT 'Standardized organization or company affiliation of the user',
    PLAN_TYPE               STRING              COMMENT 'Standardized subscription tier (Free, Basic, Pro, Enterprise)',
    REGISTRATION_DATE       DATE                COMMENT 'Date when the user first registered on the platform',
    LAST_LOGIN_DATE         DATE                COMMENT 'Most recent date the user accessed the platform',
    ACCOUNT_STATUS          STRING              COMMENT 'Current status of user account (Active, Inactive, Suspended)',
    
    -- Silver Layer Metadata Columns
    LOAD_TIMESTAMP          TIMESTAMP_NTZ(9)    COMMENT 'Timestamp when record was loaded into the silver layer',
    UPDATE_TIMESTAMP        TIMESTAMP_NTZ(9)    COMMENT 'Timestamp when record was last updated in the silver layer',
    SOURCE_SYSTEM           STRING              COMMENT 'Source system from which data originated',
    DATA_QUALITY_SCORE      NUMBER(3,2)         COMMENT 'Overall data quality score for the record (0.00 to 1.00)',
    
    -- Standard Metadata Columns
    LOAD_DATE               DATE                COMMENT 'Date when record was loaded',
    UPDATE_DATE             DATE                COMMENT 'Date when record was last updated'
)
COMMENT = 'Silver layer table storing cleaned and standardized user data with data quality validations';

-- =============================================
-- TABLE 2: SILVER.SI_MEETINGS
-- Source: BRONZE.BZ_MEETINGS
-- Description: Silver layer table containing cleaned and enriched meeting data with calculated metrics
-- =============================================

CREATE TABLE IF NOT EXISTS SILVER.SI_MEETINGS (
    -- ID Field (Added in Physical Model)
    MEETING_ID              STRING              COMMENT 'Unique identifier for each meeting',
    HOST_ID                 STRING              COMMENT 'User ID of the meeting host',
    
    -- Business Columns from Bronze + Silver Logical Model
    MEETING_TOPIC           STRING              COMMENT 'Cleaned and standardized meeting subject or title',
    MEETING_TYPE            STRING              COMMENT 'Standardized meeting category (Scheduled, Instant, Webinar, Personal)',
    START_TIME              TIMESTAMP_NTZ(9)    COMMENT 'Validated meeting start timestamp in UTC',
    END_TIME                TIMESTAMP_NTZ(9)    COMMENT 'Validated meeting end timestamp in UTC',
    DURATION_MINUTES        NUMBER              COMMENT 'Calculated and validated meeting duration in minutes',
    HOST_NAME               STRING              COMMENT 'Standardized name of the user who hosted the meeting',
    MEETING_STATUS          STRING              COMMENT 'Current state (Scheduled, In Progress, Completed, Cancelled)',
    RECORDING_STATUS        STRING              COMMENT 'Whether the meeting was recorded (Yes, No)',
    PARTICIPANT_COUNT       NUMBER              COMMENT 'Total number of participants who joined the meeting',
    
    -- Silver Layer Metadata Columns
    LOAD_TIMESTAMP          TIMESTAMP_NTZ(9)    COMMENT 'Timestamp when record was loaded into the silver layer',
    UPDATE_TIMESTAMP        TIMESTAMP_NTZ(9)    COMMENT 'Timestamp when record was last updated in the silver layer',
    SOURCE_SYSTEM           STRING              COMMENT 'Source system from which data originated',
    DATA_QUALITY_SCORE      NUMBER(3,2)         COMMENT 'Overall data quality score for the record (0.00 to 1.00)',
    
    -- Standard Metadata Columns
    LOAD_DATE               DATE                COMMENT 'Date when record was loaded',
    UPDATE_DATE             DATE                COMMENT 'Date when record was last updated'
)
COMMENT = 'Silver layer table storing cleaned and enriched meeting data with calculated metrics';

-- =============================================
-- TABLE 3: SILVER.SI_PARTICIPANTS
-- Source: BRONZE.BZ_PARTICIPANTS
-- Description: Silver layer table containing cleaned participant attendance data with calculated metrics
-- =============================================

CREATE TABLE IF NOT EXISTS SILVER.SI_PARTICIPANTS (
    -- ID Fields (Added in Physical Model)
    PARTICIPANT_ID          STRING              COMMENT 'Unique identifier for each participant record',
    MEETING_ID              STRING              COMMENT 'Reference to meeting',
    USER_ID                 STRING              COMMENT 'Reference to user who participated',
    
    -- Business Columns from Bronze + Silver Logical Model
    JOIN_TIME               TIMESTAMP_NTZ(9)    COMMENT 'Validated timestamp when participant joined the meeting',
    LEAVE_TIME              TIMESTAMP_NTZ(9)    COMMENT 'Validated timestamp when participant left the meeting',
    ATTENDANCE_DURATION     NUMBER              COMMENT 'Calculated time participant spent in meeting (minutes)',
    PARTICIPANT_ROLE        STRING              COMMENT 'Role of attendee (Host, Co-host, Participant, Observer)',
    CONNECTION_QUALITY      STRING              COMMENT 'Network connection quality during participation',
    
    -- Silver Layer Metadata Columns
    LOAD_TIMESTAMP          TIMESTAMP_NTZ(9)    COMMENT 'Timestamp when record was loaded into the silver layer',
    UPDATE_TIMESTAMP        TIMESTAMP_NTZ(9)    COMMENT 'Timestamp when record was last updated in the silver layer',
    SOURCE_SYSTEM           STRING              COMMENT 'Source system from which data originated',
    DATA_QUALITY_SCORE      NUMBER(3,2)         COMMENT 'Overall data quality score for the record (0.00 to 1.00)',
    
    -- Standard Metadata Columns
    LOAD_DATE               DATE                COMMENT 'Date when record was loaded',
    UPDATE_DATE             DATE                COMMENT 'Date when record was last updated'
)
COMMENT = 'Silver layer table storing cleaned participant attendance data with calculated metrics';

-- =============================================
-- TABLE 4: SILVER.SI_FEATURE_USAGE
-- Source: BRONZE.BZ_FEATURE_USAGE
-- Description: Silver layer table containing standardized feature usage data with categorization
-- =============================================

CREATE TABLE IF NOT EXISTS SILVER.SI_FEATURE_USAGE (
    -- ID Fields (Added in Physical Model)
    USAGE_ID                STRING              COMMENT 'Unique identifier for each feature usage record',
    MEETING_ID              STRING              COMMENT 'Reference to meeting where feature was used',
    
    -- Business Columns from Bronze + Silver Logical Model
    FEATURE_NAME            STRING              COMMENT 'Standardized name of the platform feature used',
    USAGE_COUNT             NUMBER              COMMENT 'Validated number of times feature was utilized',
    USAGE_DURATION          NUMBER              COMMENT 'Total time the feature was active during meeting (minutes)',
    FEATURE_CATEGORY        STRING              COMMENT 'Classification of feature type (Audio, Video, Collaboration, Security)',
    USAGE_DATE              DATE                COMMENT 'Date when feature usage occurred',
    
    -- Silver Layer Metadata Columns
    LOAD_TIMESTAMP          TIMESTAMP_NTZ(9)    COMMENT 'Timestamp when record was loaded into the silver layer',
    UPDATE_TIMESTAMP        TIMESTAMP_NTZ(9)    COMMENT 'Timestamp when record was last updated in the silver layer',
    SOURCE_SYSTEM           STRING              COMMENT 'Source system from which data originated',
    DATA_QUALITY_SCORE      NUMBER(3,2)         COMMENT 'Overall data quality score for the record (0.00 to 1.00)',
    
    -- Standard Metadata Columns
    LOAD_DATE               DATE                COMMENT 'Date when record was loaded',
    UPDATE_DATE             DATE                COMMENT 'Date when record was last updated'
)
COMMENT = 'Silver layer table storing standardized feature usage data with categorization';

-- =============================================
-- TABLE 5: SILVER.SI_SUPPORT_TICKETS
-- Source: BRONZE.BZ_SUPPORT_TICKETS
-- Description: Silver layer table containing standardized customer support ticket data with resolution metrics
-- =============================================

CREATE TABLE IF NOT EXISTS SILVER.SI_SUPPORT_TICKETS (
    -- ID Fields (Added in Physical Model)
    TICKET_ID               STRING              COMMENT 'Unique identifier for each support ticket',
    USER_ID                 STRING              COMMENT 'Reference to user who created the ticket',
    
    -- Business Columns from Bronze + Silver Logical Model
    TICKET_TYPE             STRING              COMMENT 'Standardized category (Technical, Billing, Feature Request, Bug Report)',
    PRIORITY_LEVEL          STRING              COMMENT 'Urgency level of ticket (Low, Medium, High, Critical)',
    OPEN_DATE               DATE                COMMENT 'Date when the support ticket was created',
    CLOSE_DATE              DATE                COMMENT 'Date when the support ticket was resolved',
    RESOLUTION_STATUS       STRING              COMMENT 'Current status (Open, In Progress, Resolved, Closed)',
    ISSUE_DESCRIPTION       STRING              COMMENT 'Cleaned and standardized description of the problem',
    RESOLUTION_NOTES        STRING              COMMENT 'Summary of actions taken to resolve the issue',
    RESOLUTION_TIME_HOURS   NUMBER              COMMENT 'Calculated time to resolve ticket in business hours',
    
    -- Silver Layer Metadata Columns
    LOAD_TIMESTAMP          TIMESTAMP_NTZ(9)    COMMENT 'Timestamp when record was loaded into the silver layer',
    UPDATE_TIMESTAMP        TIMESTAMP_NTZ(9)    COMMENT 'Timestamp when record was last updated in the silver layer',
    SOURCE_SYSTEM           STRING              COMMENT 'Source system from which data originated',
    DATA_QUALITY_SCORE      NUMBER(3,2)         COMMENT 'Overall data quality score for the record (0.00 to 1.00)',
    
    -- Standard Metadata Columns
    LOAD_DATE               DATE                COMMENT 'Date when record was loaded',
    UPDATE_DATE             DATE                COMMENT 'Date when record was last updated'
)
COMMENT = 'Silver layer table storing standardized customer support ticket data with resolution metrics';

-- =============================================
-- TABLE 6: SILVER.SI_BILLING_EVENTS
-- Source: BRONZE.BZ_BILLING_EVENTS
-- Description: Silver layer table containing validated billing and financial transaction data
-- =============================================

CREATE TABLE IF NOT EXISTS SILVER.SI_BILLING_EVENTS (
    -- ID Fields (Added in Physical Model)
    EVENT_ID                STRING              COMMENT 'Unique identifier for each billing event',
    USER_ID                 STRING              COMMENT 'Reference to user associated with billing event',
    
    -- Business Columns from Bronze + Silver Logical Model
    EVENT_TYPE              STRING              COMMENT 'Standardized billing transaction type (Subscription, Upgrade, Downgrade, Refund)',
    TRANSACTION_AMOUNT      NUMBER(10,2)        COMMENT 'Validated monetary value of the billing event',
    TRANSACTION_DATE        DATE                COMMENT 'Date when the billing event occurred',
    PAYMENT_METHOD          STRING              COMMENT 'Method used for payment (Credit Card, Bank Transfer, PayPal)',
    CURRENCY_CODE           STRING              COMMENT 'ISO currency code for the transaction',
    INVOICE_NUMBER          STRING              COMMENT 'Unique identifier for the billing invoice',
    TRANSACTION_STATUS      STRING              COMMENT 'Status of transaction (Completed, Pending, Failed, Refunded)',
    
    -- Silver Layer Metadata Columns
    LOAD_TIMESTAMP          TIMESTAMP_NTZ(9)    COMMENT 'Timestamp when record was loaded into the silver layer',
    UPDATE_TIMESTAMP        TIMESTAMP_NTZ(9)    COMMENT 'Timestamp when record was last updated in the silver layer',
    SOURCE_SYSTEM           STRING              COMMENT 'Source system from which data originated',
    DATA_QUALITY_SCORE      NUMBER(3,2)         COMMENT 'Overall data quality score for the record (0.00 to 1.00)',
    
    -- Standard Metadata Columns
    LOAD_DATE               DATE                COMMENT 'Date when record was loaded',
    UPDATE_DATE             DATE                COMMENT 'Date when record was last updated'
)
COMMENT = 'Silver layer table storing validated billing and financial transaction data';

-- =============================================
-- TABLE 7: SILVER.SI_LICENSES
-- Source: BRONZE.BZ_LICENSES
-- Description: Silver layer table containing validated license assignment and management data
-- =============================================

CREATE TABLE IF NOT EXISTS SILVER.SI_LICENSES (
    -- ID Fields (Added in Physical Model)
    LICENSE_ID              STRING              COMMENT 'Unique identifier for each license',
    ASSIGNED_TO_USER_ID     STRING              COMMENT 'User ID to whom license is assigned',
    
    -- Business Columns from Bronze + Silver Logical Model
    LICENSE_TYPE            STRING              COMMENT 'Standardized category (Basic, Pro, Enterprise, Add-on)',
    START_DATE              DATE                COMMENT 'Validated date when the license becomes active',
    END_DATE                DATE                COMMENT 'Validated date when the license expires',
    LICENSE_STATUS          STRING              COMMENT 'Current state (Active, Expired, Suspended)',
    ASSIGNED_USER_NAME      STRING              COMMENT 'Name of user to whom license is assigned',
    LICENSE_COST            NUMBER(10,2)        COMMENT 'Price associated with the license',
    RENEWAL_STATUS          STRING              COMMENT 'Whether license is set for automatic renewal (Yes, No)',
    UTILIZATION_PERCENTAGE  NUMBER(5,2)         COMMENT 'Percentage of license features being utilized',
    
    -- Silver Layer Metadata Columns
    LOAD_TIMESTAMP          TIMESTAMP_NTZ(9)    COMMENT 'Timestamp when record was loaded into the silver layer',
    UPDATE_TIMESTAMP        TIMESTAMP_NTZ(9)    COMMENT 'Timestamp when record was last updated in the silver layer',
    SOURCE_SYSTEM           STRING              COMMENT 'Source system from which data originated',
    DATA_QUALITY_SCORE      NUMBER(3,2)         COMMENT 'Overall data quality score for the record (0.00 to 1.00)',
    
    -- Standard Metadata Columns
    LOAD_DATE               DATE                COMMENT 'Date when record was loaded',
    UPDATE_DATE             DATE                COMMENT 'Date when record was last updated'
)
COMMENT = 'Silver layer table storing validated license assignment and management data';

-- =============================================
-- TABLE 8: SILVER.SI_WEBINARS
-- Source: BRONZE.BZ_WEBINARS
-- Description: Silver layer table containing cleaned webinar data with engagement metrics
-- =============================================

CREATE TABLE IF NOT EXISTS SILVER.SI_WEBINARS (
    -- ID Fields (Added in Physical Model)
    WEBINAR_ID              STRING              COMMENT 'Unique identifier for each webinar',
    HOST_ID                 STRING              COMMENT 'User ID of the webinar host',
    
    -- Business Columns from Bronze + Silver Logical Model
    WEBINAR_TOPIC           STRING              COMMENT 'Cleaned and standardized topic or title of the webinar',
    START_TIME              TIMESTAMP_NTZ(9)    COMMENT 'Validated webinar start timestamp in UTC',
    END_TIME                TIMESTAMP_NTZ(9)    COMMENT 'Validated webinar end timestamp in UTC',
    DURATION_MINUTES        NUMBER              COMMENT 'Calculated webinar duration in minutes',
    REGISTRANTS             NUMBER              COMMENT 'Number of registered participants',
    ATTENDEES               NUMBER              COMMENT 'Number of actual attendees who joined',
    ATTENDANCE_RATE         NUMBER(5,2)         COMMENT 'Percentage of registrants who attended',
    
    -- Silver Layer Metadata Columns
    LOAD_TIMESTAMP          TIMESTAMP_NTZ(9)    COMMENT 'Timestamp when record was loaded into the silver layer',
    UPDATE_TIMESTAMP        TIMESTAMP_NTZ(9)    COMMENT 'Timestamp when record was last updated in the silver layer',
    SOURCE_SYSTEM           STRING              COMMENT 'Source system from which data originated',
    DATA_QUALITY_SCORE      NUMBER(3,2)         COMMENT 'Overall data quality score for the record (0.00 to 1.00)',
    
    -- Standard Metadata Columns
    LOAD_DATE               DATE                COMMENT 'Date when record was loaded',
    UPDATE_DATE             DATE                COMMENT 'Date when record was last updated'
)
COMMENT = 'Silver layer table storing cleaned webinar data with engagement metrics';

-- =============================================
-- SECTION 2: ERROR DATA TABLE
-- =============================================

-- =============================================
-- TABLE 9: SILVER.SI_DATA_QUALITY_ERRORS
-- Description: Table to store data validation errors and quality issues identified during Silver layer processing
-- =============================================

CREATE TABLE IF NOT EXISTS SILVER.SI_DATA_QUALITY_ERRORS (
    -- ID Field (Added in Physical Model)
    ERROR_ID                STRING              COMMENT 'Unique identifier for each data quality error',
    
    -- Error Details
    SOURCE_TABLE            STRING              COMMENT 'Name of the source table where error was detected',
    SOURCE_RECORD_ID        STRING              COMMENT 'Identifier of the source record with data quality issues',
    ERROR_TYPE              STRING              COMMENT 'Type of error (Missing Value, Invalid Format, Constraint Violation, Duplicate)',
    ERROR_COLUMN            STRING              COMMENT 'Column name where the error was detected',
    ERROR_DESCRIPTION       STRING              COMMENT 'Detailed description of the data quality issue',
    ERROR_SEVERITY          STRING              COMMENT 'Severity level (Critical, High, Medium, Low)',
    DETECTED_TIMESTAMP      TIMESTAMP_NTZ(9)    COMMENT 'When the error was detected',
    RESOLUTION_STATUS       STRING              COMMENT 'Status of error resolution (Open, In Progress, Resolved, Ignored)',
    RESOLUTION_ACTION       STRING              COMMENT 'Action taken to resolve the error',
    RESOLVED_TIMESTAMP      TIMESTAMP_NTZ(9)    COMMENT 'When the error was resolved',
    RESOLVED_BY             STRING              COMMENT 'User or process that resolved the error',
    
    -- Standard Metadata Columns
    LOAD_DATE               DATE                COMMENT 'Date when record was loaded',
    UPDATE_DATE             DATE                COMMENT 'Date when record was last updated',
    SOURCE_SYSTEM           STRING              COMMENT 'Source system from which data originated'
)
COMMENT = 'Table to store data validation errors and quality issues identified during Silver and Gold layer processing';

-- =============================================
-- SECTION 3: AUDIT TABLE
-- =============================================

-- =============================================
-- TABLE 10: SILVER.SI_PIPELINE_AUDIT
-- Description: Comprehensive audit table for tracking all Silver layer pipeline execution details
-- =============================================

CREATE TABLE IF NOT EXISTS SILVER.SI_PIPELINE_AUDIT (
    -- ID Field (Added in Physical Model)
    EXECUTION_ID            STRING              COMMENT 'Unique identifier for each pipeline execution',
    
    -- Pipeline Execution Details
    PIPELINE_NAME           STRING              COMMENT 'Name of the data pipeline or process',
    START_TIME              TIMESTAMP_NTZ(9)    COMMENT 'When the pipeline execution started',
    END_TIME                TIMESTAMP_NTZ(9)    COMMENT 'When the pipeline execution completed',
    STATUS                  STRING              COMMENT 'Status (Success, Failed, Partial Success, Cancelled)',
    ERROR_MESSAGE           STRING              COMMENT 'Error message if pipeline failed',
    EXECUTION_DURATION_SECONDS NUMBER           COMMENT 'Total time taken for pipeline execution',
    SOURCE_TABLES_PROCESSED STRING              COMMENT 'List of source tables processed in this execution',
    TARGET_TABLES_UPDATED   STRING              COMMENT 'List of target tables updated in this execution',
    RECORDS_PROCESSED       NUMBER              COMMENT 'Total number of records processed',
    RECORDS_INSERTED        NUMBER              COMMENT 'Number of new records inserted',
    RECORDS_UPDATED         NUMBER              COMMENT 'Number of existing records updated',
    RECORDS_REJECTED        NUMBER              COMMENT 'Number of records rejected due to quality issues',
    EXECUTED_BY             STRING              COMMENT 'User or system that executed the pipeline',
    EXECUTION_ENVIRONMENT   STRING              COMMENT 'Environment where pipeline was executed (Dev, Test, Prod)',
    DATA_LINEAGE_INFO       STRING              COMMENT 'Information about data lineage and transformations',
    
    -- Standard Metadata Columns
    LOAD_DATE               DATE                COMMENT 'Date when record was loaded',
    UPDATE_DATE             DATE                COMMENT 'Date when record was last updated',
    SOURCE_SYSTEM           STRING              COMMENT 'Source system from which data originated'
)
COMMENT = 'Comprehensive audit table for tracking all Silver layer pipeline execution details';

-- =============================================
-- SECTION 4: UPDATE DDL SCRIPTS
-- =============================================

-- =============================================
-- Schema Evolution Scripts
-- Description: Scripts to handle schema changes and updates
-- =============================================

-- Add new column to existing table (example)
-- ALTER TABLE SILVER.SI_USERS ADD COLUMN NEW_COLUMN STRING COMMENT 'Description of new column';

-- Modify column data type (example)
-- ALTER TABLE SILVER.SI_USERS ALTER COLUMN EXISTING_COLUMN SET DATA TYPE STRING;

-- Add clustering key for performance optimization (example)
-- ALTER TABLE SILVER.SI_MEETINGS CLUSTER BY (START_TIME, HOST_ID);

-- Create view for commonly used queries (example)
-- CREATE OR REPLACE VIEW SILVER.VW_ACTIVE_USERS AS
-- SELECT USER_ID, USER_NAME, EMAIL, PLAN_TYPE
-- FROM SILVER.SI_USERS
-- WHERE ACCOUNT_STATUS = 'Active';

-- =============================================
-- SILVER LAYER SUMMARY
-- =============================================

/*
SILVER LAYER TABLES CREATED:

1. SILVER.SI_USERS                  - Cleaned and standardized user data (15 columns)
2. SILVER.SI_MEETINGS               - Cleaned and enriched meeting data (16 columns)
3. SILVER.SI_PARTICIPANTS           - Cleaned participant attendance data (14 columns)
4. SILVER.SI_FEATURE_USAGE          - Standardized feature usage data (12 columns)
5. SILVER.SI_SUPPORT_TICKETS        - Standardized support ticket data (15 columns)
6. SILVER.SI_BILLING_EVENTS         - Validated billing transaction data (14 columns)
7. SILVER.SI_LICENSES               - Validated license management data (15 columns)
8. SILVER.SI_WEBINARS               - Cleaned webinar data with metrics (13 columns)
9. SILVER.SI_DATA_QUALITY_ERRORS    - Error tracking and management (13 columns)
10. SILVER.SI_PIPELINE_AUDIT        - Pipeline execution audit trail (18 columns)

KEY FEATURES:
• All tables follow 'SI_' naming convention for Silver layer
• ID fields added to all tables as required by physical model specifications
• All Bronze layer columns included plus additional Silver layer enhancements
• Snowflake-compatible data types used throughout (STRING, NUMBER, DATE, TIMESTAMP_NTZ, BOOLEAN)
• No primary keys, foreign keys, or constraints (following Snowflake best practices)
• Comprehensive metadata columns for data lineage and quality tracking
• Data quality score column for each business table
• Error tracking table for data validation issues
• Comprehensive audit table for pipeline execution monitoring
• CREATE TABLE IF NOT EXISTS syntax for safe deployment
• Detailed column comments for documentation
• Schema evolution scripts for future updates

DATA FLOW:
RAW Schema → BRONZE Schema → SILVER Schema → (Future: GOLD Schema)

This Silver Physical Data Model serves as the cleansed and conformed layer in the Medallion architecture,
storing validated and standardized data from the Bronze layer while adding essential data quality
and audit capabilities for downstream Gold layer consumption.

API Cost: 0.002847 USD
*/

-- End of Silver Physical Data Model DDL Script