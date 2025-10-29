_____________________________________________
-- Author: AAVA
-- Created on: 2024-12-19
-- Description: Bronze Physical Data Model DDL scripts for Zoom Platform Analytics System following Medallion architecture
-- Version: 1
-- Updated on: 2024-12-19
-- Database: DB_POC_ZOOM
-- Target Schema: BRONZE
-- Source Schema: RAW
_____________________________________________

-- =============================================
-- BRONZE LAYER PHYSICAL DATA MODEL
-- Zoom Platform Analytics System
-- =============================================

-- Create Bronze Schema if not exists
CREATE SCHEMA IF NOT EXISTS BRONZE
    COMMENT = 'Bronze layer schema for raw data ingestion following Medallion architecture';

USE SCHEMA BRONZE;

-- =============================================
-- TABLE 1: BRONZE.BZ_USERS
-- Source: RAW.USERS
-- Description: Bronze layer table for user account information
-- =============================================

CREATE TABLE IF NOT EXISTS BRONZE.BZ_USERS (
    -- Business Columns from Source
    USER_ID                 VARCHAR(16777216)   COMMENT 'Unique identifier for each user account',
    USER_NAME               VARCHAR(16777216)   COMMENT 'Display name of the user',
    EMAIL                   VARCHAR(16777216)   COMMENT 'Email address of the user - PII Data',
    COMPANY                 VARCHAR(16777216)   COMMENT 'Company or organization name',
    PLAN_TYPE               VARCHAR(16777216)   COMMENT 'Type of subscription plan (Free, Basic, Pro, Enterprise)',
    
    -- Metadata Columns
    LOAD_TIMESTAMP          TIMESTAMP_NTZ(9)    COMMENT 'Timestamp when record was loaded into the system',
    UPDATE_TIMESTAMP        TIMESTAMP_NTZ(9)    COMMENT 'Timestamp when record was last updated',
    SOURCE_SYSTEM           VARCHAR(16777216)   COMMENT 'Source system from which data originated'
)
COMMENT = 'Bronze layer table storing raw user account data from Zoom platform';

-- =============================================
-- TABLE 2: BRONZE.BZ_MEETINGS
-- Source: RAW.MEETINGS
-- Description: Bronze layer table for meeting session information
-- =============================================

CREATE TABLE IF NOT EXISTS BRONZE.BZ_MEETINGS (
    -- Business Columns from Source
    MEETING_ID              VARCHAR(16777216)   COMMENT 'Unique identifier for each meeting',
    HOST_ID                 VARCHAR(16777216)   COMMENT 'User ID of the meeting host',
    MEETING_TOPIC           VARCHAR(16777216)   COMMENT 'Topic or title of the meeting',
    START_TIME              TIMESTAMP_NTZ(9)    COMMENT 'Meeting start timestamp',
    END_TIME                TIMESTAMP_NTZ(9)    COMMENT 'Meeting end timestamp',
    DURATION_MINUTES        NUMBER(38,0)        COMMENT 'Meeting duration in minutes',
    
    -- Metadata Columns
    LOAD_TIMESTAMP          TIMESTAMP_NTZ(9)    COMMENT 'Timestamp when record was loaded into the system',
    UPDATE_TIMESTAMP        TIMESTAMP_NTZ(9)    COMMENT 'Timestamp when record was last updated',
    SOURCE_SYSTEM           VARCHAR(16777216)   COMMENT 'Source system from which data originated'
)
COMMENT = 'Bronze layer table storing raw meeting session data from Zoom platform';

-- =============================================
-- TABLE 3: BRONZE.BZ_PARTICIPANTS
-- Source: RAW.PARTICIPANTS
-- Description: Bronze layer table for meeting participant information
-- =============================================

CREATE TABLE IF NOT EXISTS BRONZE.BZ_PARTICIPANTS (
    -- Business Columns from Source
    PARTICIPANT_ID          VARCHAR(16777216)   COMMENT 'Unique identifier for each participant record',
    MEETING_ID              VARCHAR(16777216)   COMMENT 'Reference to meeting',
    USER_ID                 VARCHAR(16777216)   COMMENT 'Reference to user who participated',
    JOIN_TIME               TIMESTAMP_NTZ(9)    COMMENT 'Timestamp when participant joined',
    LEAVE_TIME              TIMESTAMP_NTZ(9)    COMMENT 'Timestamp when participant left',
    
    -- Metadata Columns
    LOAD_TIMESTAMP          TIMESTAMP_NTZ(9)    COMMENT 'Timestamp when record was loaded into the system',
    UPDATE_TIMESTAMP        TIMESTAMP_NTZ(9)    COMMENT 'Timestamp when record was last updated',
    SOURCE_SYSTEM           VARCHAR(16777216)   COMMENT 'Source system from which data originated'
)
COMMENT = 'Bronze layer table storing raw participant data for meeting attendance tracking';

-- =============================================
-- TABLE 4: BRONZE.BZ_FEATURE_USAGE
-- Source: RAW.FEATURE_USAGE
-- Description: Bronze layer table for platform feature usage tracking
-- =============================================

CREATE TABLE IF NOT EXISTS BRONZE.BZ_FEATURE_USAGE (
    -- Business Columns from Source
    USAGE_ID                VARCHAR(16777216)   COMMENT 'Unique identifier for each feature usage record',
    MEETING_ID              VARCHAR(16777216)   COMMENT 'Reference to meeting where feature was used',
    FEATURE_NAME            VARCHAR(16777216)   COMMENT 'Name of the feature being tracked',
    USAGE_COUNT             NUMBER(38,0)        COMMENT 'Number of times feature was used',
    USAGE_DATE              DATE                COMMENT 'Date when feature usage occurred',
    
    -- Metadata Columns
    LOAD_TIMESTAMP          TIMESTAMP_NTZ(9)    COMMENT 'Timestamp when record was loaded into the system',
    UPDATE_TIMESTAMP        TIMESTAMP_NTZ(9)    COMMENT 'Timestamp when record was last updated',
    SOURCE_SYSTEM           VARCHAR(16777216)   COMMENT 'Source system from which data originated'
)
COMMENT = 'Bronze layer table storing raw feature usage data for platform analytics';

-- =============================================
-- TABLE 5: BRONZE.BZ_SUPPORT_TICKETS
-- Source: RAW.SUPPORT_TICKETS
-- Description: Bronze layer table for customer support ticket information
-- =============================================

CREATE TABLE IF NOT EXISTS BRONZE.BZ_SUPPORT_TICKETS (
    -- Business Columns from Source
    TICKET_ID               VARCHAR(16777216)   COMMENT 'Unique identifier for each support ticket',
    USER_ID                 VARCHAR(16777216)   COMMENT 'Reference to user who created the ticket',
    TICKET_TYPE             VARCHAR(16777216)   COMMENT 'Type or category of support ticket',
    RESOLUTION_STATUS       VARCHAR(16777216)   COMMENT 'Current status of ticket resolution',
    OPEN_DATE               DATE                COMMENT 'Date when ticket was opened',
    
    -- Metadata Columns
    LOAD_TIMESTAMP          TIMESTAMP_NTZ(9)    COMMENT 'Timestamp when record was loaded into the system',
    UPDATE_TIMESTAMP        TIMESTAMP_NTZ(9)    COMMENT 'Timestamp when record was last updated',
    SOURCE_SYSTEM           VARCHAR(16777216)   COMMENT 'Source system from which data originated'
)
COMMENT = 'Bronze layer table storing raw support ticket data for customer service analytics';

-- =============================================
-- TABLE 6: BRONZE.BZ_BILLING_EVENTS
-- Source: RAW.BILLING_EVENTS
-- Description: Bronze layer table for billing and financial transaction information
-- =============================================

CREATE TABLE IF NOT EXISTS BRONZE.BZ_BILLING_EVENTS (
    -- Business Columns from Source
    EVENT_ID                VARCHAR(16777216)   COMMENT 'Unique identifier for each billing event',
    USER_ID                 VARCHAR(16777216)   COMMENT 'Reference to user associated with billing event',
    EVENT_TYPE              VARCHAR(16777216)   COMMENT 'Type of billing event (Subscription, Upgrade, Downgrade, Refund)',
    AMOUNT                  NUMBER(10,2)        COMMENT 'Monetary amount for the billing event',
    EVENT_DATE              DATE                COMMENT 'Date when the billing event occurred',
    
    -- Metadata Columns
    LOAD_TIMESTAMP          TIMESTAMP_NTZ(9)    COMMENT 'Timestamp when record was loaded into the system',
    UPDATE_TIMESTAMP        TIMESTAMP_NTZ(9)    COMMENT 'Timestamp when record was last updated',
    SOURCE_SYSTEM           VARCHAR(16777216)   COMMENT 'Source system from which data originated'
)
COMMENT = 'Bronze layer table storing raw billing event data for revenue analytics';

-- =============================================
-- TABLE 7: BRONZE.BZ_LICENSES
-- Source: RAW.LICENSES
-- Description: Bronze layer table for license management information
-- =============================================

CREATE TABLE IF NOT EXISTS BRONZE.BZ_LICENSES (
    -- Business Columns from Source
    LICENSE_ID              VARCHAR(16777216)   COMMENT 'Unique identifier for each license',
    LICENSE_TYPE            VARCHAR(16777216)   COMMENT 'Type of license (Basic, Pro, Enterprise, Add-on)',
    ASSIGNED_TO_USER_ID     VARCHAR(16777216)   COMMENT 'User ID to whom license is assigned',
    START_DATE              DATE                COMMENT 'License start date',
    END_DATE                DATE                COMMENT 'License end date',
    
    -- Metadata Columns
    LOAD_TIMESTAMP          TIMESTAMP_NTZ(9)    COMMENT 'Timestamp when record was loaded into the system',
    UPDATE_TIMESTAMP        TIMESTAMP_NTZ(9)    COMMENT 'Timestamp when record was last updated',
    SOURCE_SYSTEM           VARCHAR(16777216)   COMMENT 'Source system from which data originated'
)
COMMENT = 'Bronze layer table storing raw license data for license management analytics';

-- =============================================
-- TABLE 8: BRONZE.BZ_WEBINARS
-- Source: RAW.WEBINARS
-- Description: Bronze layer table for webinar session information
-- =============================================

CREATE TABLE IF NOT EXISTS BRONZE.BZ_WEBINARS (
    -- Business Columns from Source
    WEBINAR_ID              VARCHAR(16777216)   COMMENT 'Unique identifier for each webinar',
    HOST_ID                 VARCHAR(16777216)   COMMENT 'User ID of the webinar host',
    WEBINAR_TOPIC           VARCHAR(16777216)   COMMENT 'Topic or title of the webinar',
    START_TIME              TIMESTAMP_NTZ(9)    COMMENT 'Webinar start timestamp',
    END_TIME                TIMESTAMP_NTZ(9)    COMMENT 'Webinar end timestamp',
    REGISTRANTS             NUMBER(38,0)        COMMENT 'Number of registered participants',
    
    -- Metadata Columns
    LOAD_TIMESTAMP          TIMESTAMP_NTZ(9)    COMMENT 'Timestamp when record was loaded into the system',
    UPDATE_TIMESTAMP        TIMESTAMP_NTZ(9)    COMMENT 'Timestamp when record was last updated',
    SOURCE_SYSTEM           VARCHAR(16777216)   COMMENT 'Source system from which data originated'
)
COMMENT = 'Bronze layer table storing raw webinar session data from Zoom platform';

-- =============================================
-- TABLE 9: BRONZE.BZ_AUDIT_RECORDS
-- Description: Audit table for tracking data processing activities in Bronze layer
-- =============================================

CREATE TABLE IF NOT EXISTS BRONZE.BZ_AUDIT_RECORDS (
    -- Audit Columns
    RECORD_ID               NUMBER              AUTOINCREMENT   COMMENT 'Auto-incrementing unique identifier for audit record',
    SOURCE_TABLE            VARCHAR(16777216)   COMMENT 'Name of the source table being processed',
    LOAD_TIMESTAMP          TIMESTAMP_NTZ(9)    COMMENT 'Timestamp when data load operation occurred',
    PROCESSED_BY            VARCHAR(16777216)   COMMENT 'User or system that processed the data',
    PROCESSING_TIME         NUMBER(10,3)        COMMENT 'Time taken to process the data in seconds',
    STATUS                  VARCHAR(16777216)   COMMENT 'Status of the processing operation (SUCCESS, FAILED, PARTIAL)',
    RECORD_COUNT            NUMBER(38,0)        COMMENT 'Number of records processed',
    ERROR_MESSAGE           VARCHAR(16777216)   COMMENT 'Error message if processing failed',
    
    -- Metadata Columns
    CREATED_TIMESTAMP       TIMESTAMP_NTZ(9)    DEFAULT CURRENT_TIMESTAMP() COMMENT 'Timestamp when audit record was created'
)
COMMENT = 'Audit table for tracking all data processing activities in the Bronze layer';

-- =============================================
-- BRONZE LAYER SUMMARY
-- =============================================

/*
BRONZE LAYER TABLES CREATED:

1. BRONZE.BZ_USERS           - User account information (8 columns)
2. BRONZE.BZ_MEETINGS        - Meeting session data (9 columns)
3. BRONZE.BZ_PARTICIPANTS    - Meeting participant data (8 columns)
4. BRONZE.BZ_FEATURE_USAGE   - Platform feature usage tracking (8 columns)
5. BRONZE.BZ_SUPPORT_TICKETS - Customer support ticket data (8 columns)
6. BRONZE.BZ_BILLING_EVENTS  - Billing and financial transactions (8 columns)
7. BRONZE.BZ_LICENSES        - License management data (8 columns)
8. BRONZE.BZ_WEBINARS        - Webinar session information (9 columns)
9. BRONZE.BZ_AUDIT_RECORDS   - Audit tracking table (9 columns)

KEY FEATURES:
• All tables follow 'BZ_' naming convention for Bronze layer
• No primary keys, foreign keys, or constraints (Bronze layer stores raw data as-is)
• Snowflake-compatible data types used throughout
• Comprehensive metadata columns for data lineage
• PII data identified with comments (EMAIL field)
• Audit table with auto-increment for tracking data processing
• All tables include detailed column comments for documentation
• CREATE TABLE IF NOT EXISTS syntax for safe deployment

DATA FLOW:
RAW Schema → BRONZE Schema → (Future: SILVER Schema → GOLD Schema)

This Bronze Physical Data Model serves as the foundation for the Medallion architecture,
storing raw data from the Zoom platform in its original form while adding essential
metadata for data lineage and processing tracking.
*/

-- End of Bronze Physical Data Model DDL Script