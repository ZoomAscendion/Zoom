_____________________________________________
-- Author: AAVA
-- Created on: 2024-12-19
-- Description: Bronze Layer Physical Data Model for Zoom Platform Analytics System
-- Version: 1
-- Updated on: 2024-12-19
-- Target Database: DB_POC_ZOOM
-- Target Schema: BRONZE
-- Medallion Architecture Layer: Bronze (Raw Data Ingestion Layer)
_____________________________________________

/*
=============================================================================
BRONZE LAYER PHYSICAL DATA MODEL - ZOOM PLATFORM ANALYTICS SYSTEM
=============================================================================

Purpose: This script creates the Bronze layer tables for the Medallion architecture
of the Zoom Platform Analytics System. The Bronze layer serves as the raw data
ingestion layer, storing data in its original format with minimal transformation.

Key Features:
• 1. Raw data preservation with original source structure
• 2. Audit trail and metadata tracking capabilities
• 3. Snowflake-optimized data types and storage
• 4. No primary keys, foreign keys, or constraints (Bronze layer principle)
• 5. Standardized naming convention with 'bz_' prefix
• 6. Comprehensive metadata columns for data lineage
• 7. Support for incremental data loading patterns
• 8. Schema follows BRONZE naming convention aligned with RAW schema

Source Systems: Zoom Platform APIs, Database Extracts, File Feeds
Target Platform: Snowflake Data Cloud
Data Refresh: Near real-time and batch processing
*/

-- =============================================================================
-- SCHEMA CREATION
-- =============================================================================

CREATE SCHEMA IF NOT EXISTS BRONZE
    COMMENT = 'Bronze layer schema for Zoom Platform Analytics System - Raw data ingestion layer';

USE SCHEMA BRONZE;

-- =============================================================================
-- BRONZE LAYER TABLES CREATION
-- =============================================================================

-- • 1. Bronze Billing Events Table
-- Purpose: Stores raw billing transaction data from Zoom platform
-- Source: RAW.BILLING_EVENTS
CREATE TABLE IF NOT EXISTS BRONZE.bz_billing_events (
    event_id                VARCHAR(16777216)     COMMENT 'Unique identifier for billing event',
    user_id                 VARCHAR(16777216)     COMMENT 'User identifier associated with billing event',
    event_type              VARCHAR(16777216)     COMMENT 'Type of billing event (Subscription, Upgrade, Refund, Payment)',
    amount                  NUMBER(18,2)          COMMENT 'Monetary amount of the billing transaction',
    event_date              DATE                  COMMENT 'Date when the billing event occurred',
    load_timestamp          TIMESTAMP_NTZ         COMMENT 'Timestamp when record was loaded into Bronze layer',
    update_timestamp        TIMESTAMP_NTZ         COMMENT 'Timestamp when record was last updated',
    source_system           VARCHAR(16777216)     COMMENT 'Source system identifier for data lineage'
)
COMMENT = 'Bronze layer table storing raw billing events data from Zoom platform';

-- • 2. Bronze Feature Usage Table
-- Purpose: Stores raw feature utilization data during meetings
-- Source: RAW.FEATURE_USAGE
CREATE TABLE IF NOT EXISTS BRONZE.bz_feature_usage (
    usage_id                VARCHAR(16777216)     COMMENT 'Unique identifier for feature usage record',
    meeting_id              VARCHAR(16777216)     COMMENT 'Meeting identifier where feature was used',
    feature_name            VARCHAR(16777216)     COMMENT 'Name of the feature used (Screen Share, Recording, Chat, etc.)',
    usage_count             NUMBER                COMMENT 'Number of times feature was used during meeting',
    usage_date              DATE                  COMMENT 'Date when feature usage occurred',
    load_timestamp          TIMESTAMP_NTZ         COMMENT 'Timestamp when record was loaded into Bronze layer',
    update_timestamp        TIMESTAMP_NTZ         COMMENT 'Timestamp when record was last updated',
    source_system           VARCHAR(16777216)     COMMENT 'Source system identifier for data lineage'
)
COMMENT = 'Bronze layer table storing raw feature usage data from Zoom meetings';

-- • 3. Bronze Licenses Table
-- Purpose: Stores raw license assignment and management data
-- Source: RAW.LICENSES
CREATE TABLE IF NOT EXISTS BRONZE.bz_licenses (
    license_id              VARCHAR(16777216)     COMMENT 'Unique identifier for license record',
    license_type            VARCHAR(16777216)     COMMENT 'Type of license (Basic, Pro, Enterprise, Add-on)',
    assigned_to_user_id     VARCHAR(16777216)     COMMENT 'User ID to whom license is assigned',
    start_date              DATE                  COMMENT 'License activation date',
    end_date                DATE                  COMMENT 'License expiration date',
    load_timestamp          TIMESTAMP_NTZ         COMMENT 'Timestamp when record was loaded into Bronze layer',
    update_timestamp        TIMESTAMP_NTZ         COMMENT 'Timestamp when record was last updated',
    source_system           VARCHAR(16777216)     COMMENT 'Source system identifier for data lineage'
)
COMMENT = 'Bronze layer table storing raw license management data from Zoom platform';

-- • 4. Bronze Meetings Table
-- Purpose: Stores raw meeting session data
-- Source: RAW.MEETINGS
CREATE TABLE IF NOT EXISTS BRONZE.bz_meetings (
    meeting_id              VARCHAR(16777216)     COMMENT 'Unique identifier for meeting session',
    host_id                 VARCHAR(16777216)     COMMENT 'User ID of meeting host',
    meeting_topic           VARCHAR(16777216)     COMMENT 'Topic or title of the meeting',
    start_time              TIMESTAMP_NTZ         COMMENT 'Meeting start timestamp',
    end_time                TIMESTAMP_NTZ         COMMENT 'Meeting end timestamp',
    duration_minutes        NUMBER                COMMENT 'Total meeting duration in minutes',
    load_timestamp          TIMESTAMP_NTZ         COMMENT 'Timestamp when record was loaded into Bronze layer',
    update_timestamp        TIMESTAMP_NTZ         COMMENT 'Timestamp when record was last updated',
    source_system           VARCHAR(16777216)     COMMENT 'Source system identifier for data lineage'
)
COMMENT = 'Bronze layer table storing raw meeting session data from Zoom platform';

-- • 5. Bronze Participants Table
-- Purpose: Stores raw meeting participant data
-- Source: RAW.PARTICIPANTS
CREATE TABLE IF NOT EXISTS BRONZE.bz_participants (
    participant_id          VARCHAR(16777216)     COMMENT 'Unique identifier for participant record',
    meeting_id              VARCHAR(16777216)     COMMENT 'Meeting identifier where user participated',
    user_id                 VARCHAR(16777216)     COMMENT 'User identifier of meeting participant',
    join_time               TIMESTAMP_NTZ         COMMENT 'Timestamp when participant joined meeting',
    leave_time              TIMESTAMP_NTZ         COMMENT 'Timestamp when participant left meeting',
    load_timestamp          TIMESTAMP_NTZ         COMMENT 'Timestamp when record was loaded into Bronze layer',
    update_timestamp        TIMESTAMP_NTZ         COMMENT 'Timestamp when record was last updated',
    source_system           VARCHAR(16777216)     COMMENT 'Source system identifier for data lineage'
)
COMMENT = 'Bronze layer table storing raw meeting participant data from Zoom platform';

-- • 6. Bronze Support Tickets Table
-- Purpose: Stores raw customer support ticket data
-- Source: RAW.SUPPORT_TICKETS
CREATE TABLE IF NOT EXISTS BRONZE.bz_support_tickets (
    ticket_id               VARCHAR(16777216)     COMMENT 'Unique identifier for support ticket',
    user_id                 VARCHAR(16777216)     COMMENT 'User ID who created the support ticket',
    ticket_type             VARCHAR(16777216)     COMMENT 'Category of support ticket (Technical, Billing, Feature Request)',
    resolution_status       VARCHAR(16777216)     COMMENT 'Current status of ticket (Open, In Progress, Resolved, Closed)',
    open_date               DATE                  COMMENT 'Date when support ticket was created',
    load_timestamp          TIMESTAMP_NTZ         COMMENT 'Timestamp when record was loaded into Bronze layer',
    update_timestamp        TIMESTAMP_NTZ         COMMENT 'Timestamp when record was last updated',
    source_system           VARCHAR(16777216)     COMMENT 'Source system identifier for data lineage'
)
COMMENT = 'Bronze layer table storing raw support ticket data from Zoom platform';

-- • 7. Bronze Users Table
-- Purpose: Stores raw user profile and account data
-- Source: RAW.USERS
CREATE TABLE IF NOT EXISTS BRONZE.bz_users (
    user_id                 VARCHAR(16777216)     COMMENT 'Unique identifier for user account',
    user_name               VARCHAR(16777216)     COMMENT 'Full name of the platform user',
    email                   VARCHAR(16777216)     COMMENT 'Primary email address of user',
    company                 VARCHAR(16777216)     COMMENT 'Company or organization associated with user',
    plan_type               VARCHAR(16777216)     COMMENT 'Subscription plan type (Free, Basic, Pro, Enterprise)',
    load_timestamp          TIMESTAMP_NTZ         COMMENT 'Timestamp when record was loaded into Bronze layer',
    update_timestamp        TIMESTAMP_NTZ         COMMENT 'Timestamp when record was last updated',
    source_system           VARCHAR(16777216)     COMMENT 'Source system identifier for data lineage'
)
COMMENT = 'Bronze layer table storing raw user profile data from Zoom platform';

-- • 8. Bronze Webinars Table
-- Purpose: Stores raw webinar session data
-- Source: RAW.WEBINARS
CREATE TABLE IF NOT EXISTS BRONZE.bz_webinars (
    webinar_id              VARCHAR(16777216)     COMMENT 'Unique identifier for webinar session',
    host_id                 VARCHAR(16777216)     COMMENT 'User ID of webinar host',
    webinar_topic           VARCHAR(16777216)     COMMENT 'Topic or title of the webinar',
    start_time              TIMESTAMP_NTZ         COMMENT 'Webinar start timestamp',
    end_time                TIMESTAMP_NTZ         COMMENT 'Webinar end timestamp',
    registrants             NUMBER                COMMENT 'Number of registered attendees for webinar',
    load_timestamp          TIMESTAMP_NTZ         COMMENT 'Timestamp when record was loaded into Bronze layer',
    update_timestamp        TIMESTAMP_NTZ         COMMENT 'Timestamp when record was last updated',
    source_system           VARCHAR(16777216)     COMMENT 'Source system identifier for data lineage'
)
COMMENT = 'Bronze layer table storing raw webinar session data from Zoom platform';

-- =============================================================================
-- AUDIT AND METADATA MANAGEMENT
-- =============================================================================

-- • 9. Bronze Audit Log Table
-- Purpose: Tracks all data processing activities in Bronze layer
-- Usage: Data lineage, processing monitoring, error tracking
CREATE TABLE IF NOT EXISTS BRONZE.bz_audit_log (
    record_id               NUMBER AUTOINCREMENT  COMMENT 'Auto-incrementing unique record identifier',
    source_table            STRING                COMMENT 'Name of source table being processed',
    load_timestamp          TIMESTAMP_NTZ         COMMENT 'Timestamp when processing occurred',
    processed_by            STRING                COMMENT 'Process or user that performed the operation',
    processing_time         NUMBER                COMMENT 'Processing duration in seconds',
    status                  STRING                COMMENT 'Processing status (SUCCESS, FAILED, WARNING)'
)
COMMENT = 'Audit log table for tracking Bronze layer data processing activities';

-- =============================================================================
-- BRONZE LAYER IMPLEMENTATION NOTES
-- =============================================================================

/*
Implementation Guidelines:

• 1. Data Loading Strategy:
   - Use COPY INTO commands for bulk data loading
   - Implement incremental loading based on load_timestamp
   - Handle duplicate records through MERGE operations

• 2. Data Quality Considerations:
   - Preserve all source data including nulls and empty strings
   - No data validation or cleansing at Bronze layer
   - Maintain original data types and formats where possible

• 3. Performance Optimization:
   - Consider clustering keys on frequently queried columns
   - Implement appropriate retention policies
   - Monitor storage costs and optimize as needed

• 4. Security and Governance:
   - Apply appropriate access controls
   - Implement data masking for sensitive fields if required
   - Maintain data lineage documentation

• 5. Monitoring and Maintenance:
   - Regular monitoring of data freshness
   - Automated alerting for failed loads
   - Periodic data quality assessments

• 6. Integration with Silver Layer:
   - Bronze tables serve as source for Silver layer transformations
   - Maintain stable schema to minimize downstream impacts
   - Document any schema changes through version control
*/

-- =============================================================================
-- END OF BRONZE LAYER PHYSICAL DATA MODEL
-- =============================================================================