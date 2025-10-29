_____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Bronze Layer Physical Data Model for Zoom Platform Analytics System
## *Version*: 1
## *Updated on*: 
_____________________________________________

/*
=============================================================================
                    BRONZE LAYER PHYSICAL DATA MODEL
                    Zoom Platform Analytics System
=============================================================================

Purpose: This script creates the Bronze layer tables for the Medallion 
         architecture, transforming raw data into a structured format
         suitable for further processing in Silver and Gold layers.

Database: DB_POC_ZOOM
Schema: BRONZE
Naming Convention: bz_<table_name>

Key Features:
- Snowflake-optimized data types
- Metadata columns for data lineage
- No constraints (following Bronze layer best practices)
- Audit table for processing tracking

=============================================================================
*/

-- =============================================================================
-- SECTION 1: SCHEMA CREATION
-- =============================================================================

CREATE SCHEMA IF NOT EXISTS BRONZE
    COMMENT = 'Bronze layer schema for Zoom Platform Analytics System - contains cleansed and structured raw data';

USE SCHEMA BRONZE;

-- =============================================================================
-- SECTION 2: BRONZE LAYER TABLES
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 2.1 BILLING EVENTS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS BRONZE.bz_billing_events (
    event_id                VARCHAR(16777216)    COMMENT 'Unique identifier for each billing event',
    user_id                 VARCHAR(16777216)    COMMENT 'Reference to user associated with billing event',
    event_type              VARCHAR(16777216)    COMMENT 'Type of billing event (Subscription, Upgrade, Downgrade, Refund)',
    amount                  NUMBER(10,2)         COMMENT 'Monetary amount for the billing event',
    event_date              DATE                 COMMENT 'Date when the billing event occurred',
    load_timestamp          TIMESTAMP_NTZ(9)     COMMENT 'Timestamp when record was loaded into Bronze layer',
    update_timestamp        TIMESTAMP_NTZ(9)     COMMENT 'Timestamp when record was last updated in Bronze layer',
    source_system           VARCHAR(16777216)    COMMENT 'Source system from which data originated',
    bronze_load_timestamp   TIMESTAMP_NTZ(9)     DEFAULT CURRENT_TIMESTAMP() COMMENT 'Bronze layer processing timestamp',
    bronze_update_timestamp TIMESTAMP_NTZ(9)     DEFAULT CURRENT_TIMESTAMP() COMMENT 'Bronze layer last update timestamp',
    record_hash             VARCHAR(64)          COMMENT 'Hash of record for change detection'
)
COMMENT = 'Bronze layer table containing billing events and financial transactions';

-- -----------------------------------------------------------------------------
-- 2.2 FEATURE USAGE TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS BRONZE.bz_feature_usage (
    usage_id                VARCHAR(16777216)    COMMENT 'Unique identifier for each feature usage record',
    meeting_id              VARCHAR(16777216)    COMMENT 'Reference to meeting where feature was used',
    feature_name            VARCHAR(16777216)    COMMENT 'Name of the feature being tracked',
    usage_count             NUMBER(38,0)         COMMENT 'Number of times feature was used',
    usage_date              DATE                 COMMENT 'Date when feature usage occurred',
    load_timestamp          TIMESTAMP_NTZ(9)     COMMENT 'Timestamp when record was loaded into system',
    update_timestamp        TIMESTAMP_NTZ(9)     COMMENT 'Timestamp when record was last updated',
    source_system           VARCHAR(16777216)    COMMENT 'Source system from which data originated',
    bronze_load_timestamp   TIMESTAMP_NTZ(9)     DEFAULT CURRENT_TIMESTAMP() COMMENT 'Bronze layer processing timestamp',
    bronze_update_timestamp TIMESTAMP_NTZ(9)     DEFAULT CURRENT_TIMESTAMP() COMMENT 'Bronze layer last update timestamp',
    record_hash             VARCHAR(64)          COMMENT 'Hash of record for change detection'
)
COMMENT = 'Bronze layer table containing feature usage tracking data';

-- -----------------------------------------------------------------------------
-- 2.3 LICENSES TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS BRONZE.bz_licenses (
    license_id              VARCHAR(16777216)    COMMENT 'Unique identifier for each license',
    license_type            VARCHAR(16777216)    COMMENT 'Type of license (Basic, Pro, Enterprise, Add-on)',
    assigned_to_user_id     VARCHAR(16777216)    COMMENT 'User ID to whom license is assigned',
    start_date              DATE                 COMMENT 'License start date',
    end_date                DATE                 COMMENT 'License end date',
    load_timestamp          TIMESTAMP_NTZ(9)     COMMENT 'Timestamp when record was loaded into system',
    update_timestamp        TIMESTAMP_NTZ(9)     COMMENT 'Timestamp when record was last updated',
    source_system           VARCHAR(16777216)    COMMENT 'Source system from which data originated',
    bronze_load_timestamp   TIMESTAMP_NTZ(9)     DEFAULT CURRENT_TIMESTAMP() COMMENT 'Bronze layer processing timestamp',
    bronze_update_timestamp TIMESTAMP_NTZ(9)     DEFAULT CURRENT_TIMESTAMP() COMMENT 'Bronze layer last update timestamp',
    record_hash             VARCHAR(64)          COMMENT 'Hash of record for change detection'
)
COMMENT = 'Bronze layer table containing license management and assignment data';

-- -----------------------------------------------------------------------------
-- 2.4 MEETINGS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS BRONZE.bz_meetings (
    meeting_id              VARCHAR(16777216)    COMMENT 'Unique identifier for each meeting',
    host_id                 VARCHAR(16777216)    COMMENT 'User ID of the meeting host',
    meeting_topic           VARCHAR(16777216)    COMMENT 'Topic or title of the meeting',
    start_time              TIMESTAMP_NTZ(9)     COMMENT 'Meeting start timestamp',
    end_time                TIMESTAMP_NTZ(9)     COMMENT 'Meeting end timestamp',
    duration_minutes        NUMBER(38,0)         COMMENT 'Meeting duration in minutes',
    load_timestamp          TIMESTAMP_NTZ(9)     COMMENT 'Timestamp when record was loaded into system',
    update_timestamp        TIMESTAMP_NTZ(9)     COMMENT 'Timestamp when record was last updated',
    source_system           VARCHAR(16777216)    COMMENT 'Source system from which data originated',
    bronze_load_timestamp   TIMESTAMP_NTZ(9)     DEFAULT CURRENT_TIMESTAMP() COMMENT 'Bronze layer processing timestamp',
    bronze_update_timestamp TIMESTAMP_NTZ(9)     DEFAULT CURRENT_TIMESTAMP() COMMENT 'Bronze layer last update timestamp',
    record_hash             VARCHAR(64)          COMMENT 'Hash of record for change detection'
)
COMMENT = 'Bronze layer table containing meeting session data and metadata';

-- -----------------------------------------------------------------------------
-- 2.5 PARTICIPANTS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS BRONZE.bz_participants (
    participant_id          VARCHAR(16777216)    COMMENT 'Unique identifier for each participant record',
    meeting_id              VARCHAR(16777216)    COMMENT 'Reference to meeting',
    user_id                 VARCHAR(16777216)    COMMENT 'Reference to user who participated',
    join_time               TIMESTAMP_NTZ(9)     COMMENT 'Timestamp when participant joined',
    leave_time              TIMESTAMP_NTZ(9)     COMMENT 'Timestamp when participant left',
    load_timestamp          TIMESTAMP_NTZ(9)     COMMENT 'Timestamp when record was loaded into system',
    update_timestamp        TIMESTAMP_NTZ(9)     COMMENT 'Timestamp when record was last updated',
    source_system           VARCHAR(16777216)    COMMENT 'Source system from which data originated',
    bronze_load_timestamp   TIMESTAMP_NTZ(9)     DEFAULT CURRENT_TIMESTAMP() COMMENT 'Bronze layer processing timestamp',
    bronze_update_timestamp TIMESTAMP_NTZ(9)     DEFAULT CURRENT_TIMESTAMP() COMMENT 'Bronze layer last update timestamp',
    record_hash             VARCHAR(64)          COMMENT 'Hash of record for change detection'
)
COMMENT = 'Bronze layer table containing meeting participation data';

-- -----------------------------------------------------------------------------
-- 2.6 SUPPORT TICKETS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS BRONZE.bz_support_tickets (
    ticket_id               VARCHAR(16777216)    COMMENT 'Unique identifier for each support ticket',
    user_id                 VARCHAR(16777216)    COMMENT 'Reference to user who created the ticket',
    ticket_type             VARCHAR(16777216)    COMMENT 'Type or category of support ticket',
    resolution_status       VARCHAR(16777216)    COMMENT 'Current status of ticket resolution',
    open_date               DATE                 COMMENT 'Date when ticket was opened',
    load_timestamp          TIMESTAMP_NTZ(9)     COMMENT 'Timestamp when record was loaded into system',
    update_timestamp        TIMESTAMP_NTZ(9)     COMMENT 'Timestamp when record was last updated',
    source_system           VARCHAR(16777216)    COMMENT 'Source system from which data originated',
    bronze_load_timestamp   TIMESTAMP_NTZ(9)     DEFAULT CURRENT_TIMESTAMP() COMMENT 'Bronze layer processing timestamp',
    bronze_update_timestamp TIMESTAMP_NTZ(9)     DEFAULT CURRENT_TIMESTAMP() COMMENT 'Bronze layer last update timestamp',
    record_hash             VARCHAR(64)          COMMENT 'Hash of record for change detection'
)
COMMENT = 'Bronze layer table containing customer support ticket data';

-- -----------------------------------------------------------------------------
-- 2.7 USERS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS BRONZE.bz_users (
    user_id                 VARCHAR(16777216)    COMMENT 'Unique identifier for each user account',
    user_name               VARCHAR(16777216)    COMMENT 'Display name of the user',
    email                   VARCHAR(16777216)    COMMENT 'Email address of the user',
    company                 VARCHAR(16777216)    COMMENT 'Company or organization name',
    plan_type               VARCHAR(16777216)    COMMENT 'Type of subscription plan',
    load_timestamp          TIMESTAMP_NTZ(9)     COMMENT 'Timestamp when record was loaded into system',
    update_timestamp        TIMESTAMP_NTZ(9)     COMMENT 'Timestamp when record was last updated',
    source_system           VARCHAR(16777216)    COMMENT 'Source system from which data originated',
    bronze_load_timestamp   TIMESTAMP_NTZ(9)     DEFAULT CURRENT_TIMESTAMP() COMMENT 'Bronze layer processing timestamp',
    bronze_update_timestamp TIMESTAMP_NTZ(9)     DEFAULT CURRENT_TIMESTAMP() COMMENT 'Bronze layer last update timestamp',
    record_hash             VARCHAR(64)          COMMENT 'Hash of record for change detection'
)
COMMENT = 'Bronze layer table containing user account and profile data';

-- -----------------------------------------------------------------------------
-- 2.8 WEBINARS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS BRONZE.bz_webinars (
    webinar_id              VARCHAR(16777216)    COMMENT 'Unique identifier for each webinar',
    host_id                 VARCHAR(16777216)    COMMENT 'User ID of the webinar host',
    webinar_topic           VARCHAR(16777216)    COMMENT 'Topic or title of the webinar',
    start_time              TIMESTAMP_NTZ(9)     COMMENT 'Webinar start timestamp',
    end_time                TIMESTAMP_NTZ(9)     COMMENT 'Webinar end timestamp',
    registrants             NUMBER(38,0)         COMMENT 'Number of registered participants',
    load_timestamp          TIMESTAMP_NTZ(9)     COMMENT 'Timestamp when record was loaded into system',
    update_timestamp        TIMESTAMP_NTZ(9)     COMMENT 'Timestamp when record was last updated',
    source_system           VARCHAR(16777216)    COMMENT 'Source system from which data originated',
    bronze_load_timestamp   TIMESTAMP_NTZ(9)     DEFAULT CURRENT_TIMESTAMP() COMMENT 'Bronze layer processing timestamp',
    bronze_update_timestamp TIMESTAMP_NTZ(9)     DEFAULT CURRENT_TIMESTAMP() COMMENT 'Bronze layer last update timestamp',
    record_hash             VARCHAR(64)          COMMENT 'Hash of record for change detection'
)
COMMENT = 'Bronze layer table containing webinar session data and registration metrics';

-- =============================================================================
-- SECTION 3: AUDIT AND METADATA TABLES
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 3.1 BRONZE LAYER AUDIT TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS BRONZE.bz_audit_log (
    record_id               NUMBER AUTOINCREMENT COMMENT 'Auto-incrementing unique identifier for audit records',
    source_table            VARCHAR(16777216)    COMMENT 'Name of the source table being processed',
    target_table            VARCHAR(16777216)    COMMENT 'Name of the target Bronze table',
    load_timestamp          TIMESTAMP_NTZ(9)     DEFAULT CURRENT_TIMESTAMP() COMMENT 'Timestamp when processing started',
    processed_by            VARCHAR(16777216)    COMMENT 'User or process that performed the operation',
    processing_time         NUMBER(10,3)         COMMENT 'Time taken to process in seconds',
    records_processed       NUMBER(38,0)         COMMENT 'Number of records processed',
    records_inserted        NUMBER(38,0)         COMMENT 'Number of records inserted',
    records_updated         NUMBER(38,0)         COMMENT 'Number of records updated',
    records_failed          NUMBER(38,0)         COMMENT 'Number of records that failed processing',
    status                  VARCHAR(50)          COMMENT 'Processing status (SUCCESS, FAILED, PARTIAL)',
    error_message           VARCHAR(16777216)    COMMENT 'Error message if processing failed',
    batch_id                VARCHAR(16777216)    COMMENT 'Batch identifier for grouping related operations',
    source_system           VARCHAR(16777216)    COMMENT 'Source system from which data originated'
)
COMMENT = 'Audit table for tracking Bronze layer data processing operations and lineage';

-- -----------------------------------------------------------------------------
-- 3.2 DATA QUALITY METRICS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS BRONZE.bz_data_quality_metrics (
    metric_id               NUMBER AUTOINCREMENT COMMENT 'Auto-incrementing unique identifier for quality metrics',
    table_name              VARCHAR(16777216)    COMMENT 'Name of the table being assessed',
    metric_name             VARCHAR(16777216)    COMMENT 'Name of the data quality metric',
    metric_value            NUMBER(38,6)         COMMENT 'Value of the metric',
    metric_threshold        NUMBER(38,6)         COMMENT 'Threshold value for the metric',
    metric_status           VARCHAR(50)          COMMENT 'Status of the metric (PASS, FAIL, WARNING)',
    measurement_timestamp   TIMESTAMP_NTZ(9)     DEFAULT CURRENT_TIMESTAMP() COMMENT 'When the metric was measured',
    batch_id                VARCHAR(16777216)    COMMENT 'Batch identifier for grouping related measurements'
)
COMMENT = 'Table for storing data quality metrics and monitoring results';

-- =============================================================================
-- SECTION 4: BRONZE LAYER VIEWS FOR DATA ACCESS
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 4.1 CURRENT ACTIVE USERS VIEW
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW BRONZE.vw_active_users AS
SELECT 
    user_id,
    user_name,
    email,
    company,
    plan_type,
    bronze_load_timestamp,
    bronze_update_timestamp
FROM BRONZE.bz_users
WHERE user_id IS NOT NULL
    AND email IS NOT NULL
COMMENT = 'View showing active users with valid identifiers';

-- -----------------------------------------------------------------------------
-- 4.2 RECENT MEETINGS VIEW
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW BRONZE.vw_recent_meetings AS
SELECT 
    meeting_id,
    host_id,
    meeting_topic,
    start_time,
    end_time,
    duration_minutes,
    bronze_load_timestamp
FROM BRONZE.bz_meetings
WHERE start_time >= DATEADD('day', -30, CURRENT_DATE())
    AND meeting_id IS NOT NULL
COMMENT = 'View showing meetings from the last 30 days';

-- -----------------------------------------------------------------------------
-- 4.3 BILLING SUMMARY VIEW
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW BRONZE.vw_billing_summary AS
SELECT 
    user_id,
    event_type,
    SUM(amount) as total_amount,
    COUNT(*) as event_count,
    MIN(event_date) as first_event_date,
    MAX(event_date) as last_event_date
FROM BRONZE.bz_billing_events
WHERE user_id IS NOT NULL
    AND amount IS NOT NULL
GROUP BY user_id, event_type
COMMENT = 'View providing billing summary by user and event type';

-- =============================================================================
-- SECTION 5: BRONZE LAYER SEQUENCES
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 5.1 BATCH ID SEQUENCE
-- -----------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS BRONZE.seq_batch_id
    START = 1
    INCREMENT = 1
    COMMENT = 'Sequence for generating unique batch identifiers';

-- =============================================================================
-- SECTION 6: COMPLETION MESSAGE
-- =============================================================================

/*
=============================================================================
                        BRONZE LAYER CREATION COMPLETE
=============================================================================

The following objects have been created in the BRONZE schema:

TABLES (8):
- bz_billing_events      : Billing and financial transaction data
- bz_feature_usage       : Platform feature utilization tracking
- bz_licenses           : License management and assignments
- bz_meetings           : Meeting session data and metadata
- bz_participants       : Meeting participation records
- bz_support_tickets    : Customer support interaction data
- bz_users              : User account and profile information
- bz_webinars           : Webinar session and registration data

AUDIT & METADATA TABLES (2):
- bz_audit_log          : Processing audit trail and lineage
- bz_data_quality_metrics : Data quality monitoring results

VIEWS (3):
- vw_active_users       : Active user summary view
- vw_recent_meetings    : Recent meetings view
- vw_billing_summary    : Billing summary by user and event type

SEQUENCES (1):
- seq_batch_id          : Batch identifier sequence

All tables include:
- Original source columns with appropriate Snowflake data types
- Bronze layer metadata columns (bronze_load_timestamp, bronze_update_timestamp)
- Record hash column for change detection
- Comprehensive column comments for documentation

Next Steps:
1. Configure data pipelines to populate Bronze tables from RAW layer
2. Implement data quality checks using the metrics table
3. Set up monitoring and alerting for audit log
4. Create Silver layer transformations based on Bronze data

=============================================================================
*/