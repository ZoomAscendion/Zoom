/*
===============================================================================
                    BRONZE PHYSICAL DATA MODEL
===============================================================================
Project Name: Zoom Platform Analytics System
Author: AAVA
Version: 1.0
Date Created: 2024-12-19
Database: DB_POC_ZOOM
Schema: BRONZE
Description: Bronze layer physical data model for Zoom Platform Analytics System
             following Medallion architecture. This layer stores raw data as-is
             with metadata columns for data lineage and auditing.

Source Schema: DB_POC_ZOOM.RAW
Target Schema: DB_POC_ZOOM.BRONZE

Tables Included:
1. BZ_BILLING_EVENTS
2. BZ_FEATURE_USAGE
3. BZ_LICENSES
4. BZ_MEETINGS
5. BZ_PARTICIPANTS
6. BZ_SUPPORT_TICKETS
7. BZ_USERS
8. BZ_AUDIT_TABLE

Note: Bronze layer does not include primary keys, foreign keys, or constraints
      as it stores raw data as-is for further processing in Silver layer.
===============================================================================
*/

-- Create Bronze Schema if not exists
CREATE SCHEMA IF NOT EXISTS DB_POC_ZOOM.BRONZE;

-- Use Bronze Schema
USE SCHEMA DB_POC_ZOOM.BRONZE;

/*
===============================================================================
                           TABLE 1: BZ_BILLING_EVENTS
===============================================================================
Description: Contains billing event information for Zoom services including 
             charges, credits, and payment transactions.
Source Table: DB_POC_ZOOM.RAW.BILLING_EVENTS
===============================================================================
*/

CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.BRONZE.BZ_BILLING_EVENTS (
    EVENT_ID STRING COMMENT 'Unique identifier for each billing event',
    USER_ID STRING COMMENT 'Identifier linking to the user associated with the billing event',
    EVENT_TYPE STRING COMMENT 'Type of billing event (charge, credit, refund, etc.)',
    AMOUNT NUMBER(10,2) COMMENT 'Monetary amount of the billing event',
    EVENT_DATE DATE COMMENT 'Date when the billing event occurred',
    LOAD_TIMESTAMP TIMESTAMP_NTZ COMMENT 'Timestamp when the record was first loaded into the system',
    UPDATE_TIMESTAMP TIMESTAMP_NTZ COMMENT 'Timestamp when the record was last updated',
    SOURCE_SYSTEM STRING COMMENT 'Source system from which the data originated'
) COMMENT = 'Bronze layer table for billing events data from Zoom Platform Analytics System';

/*
===============================================================================
                           TABLE 2: BZ_FEATURE_USAGE
===============================================================================
Description: Tracks usage of various Zoom features during meetings and sessions.
Source Table: DB_POC_ZOOM.RAW.FEATURE_USAGE
===============================================================================
*/

CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.BRONZE.BZ_FEATURE_USAGE (
    USAGE_ID STRING COMMENT 'Unique identifier for each feature usage record',
    MEETING_ID STRING COMMENT 'Identifier linking to the meeting where feature was used',
    FEATURE_NAME STRING COMMENT 'Name of the Zoom feature that was used',
    USAGE_COUNT NUMBER(38,0) COMMENT 'Number of times the feature was used in the meeting',
    USAGE_DATE DATE COMMENT 'Date when the feature usage occurred',
    LOAD_TIMESTAMP TIMESTAMP_NTZ COMMENT 'Timestamp when the record was first loaded into the system',
    UPDATE_TIMESTAMP TIMESTAMP_NTZ COMMENT 'Timestamp when the record was last updated',
    SOURCE_SYSTEM STRING COMMENT 'Source system from which the data originated'
) COMMENT = 'Bronze layer table for feature usage data from Zoom Platform Analytics System';

/*
===============================================================================
                           TABLE 3: BZ_LICENSES
===============================================================================
Description: Contains information about Zoom licenses assigned to users 
             including license types and validity periods.
Source Table: DB_POC_ZOOM.RAW.LICENSES
===============================================================================
*/

CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.BRONZE.BZ_LICENSES (
    LICENSE_ID STRING COMMENT 'Unique identifier for each license',
    LICENSE_TYPE STRING COMMENT 'Type of Zoom license (Basic, Pro, Business, Enterprise)',
    ASSIGNED_TO_USER_ID STRING COMMENT 'User ID to whom the license is assigned',
    START_DATE DATE COMMENT 'Date when the license becomes active',
    END_DATE DATE COMMENT 'Date when the license expires',
    LOAD_TIMESTAMP TIMESTAMP_NTZ COMMENT 'Timestamp when the record was first loaded into the system',
    UPDATE_TIMESTAMP TIMESTAMP_NTZ COMMENT 'Timestamp when the record was last updated',
    SOURCE_SYSTEM STRING COMMENT 'Source system from which the data originated'
) COMMENT = 'Bronze layer table for license data from Zoom Platform Analytics System';

/*
===============================================================================
                           TABLE 4: BZ_MEETINGS
===============================================================================
Description: Core table containing meeting information including scheduling, 
             duration, and host details.
Source Table: DB_POC_ZOOM.RAW.MEETINGS
===============================================================================
*/

CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.BRONZE.BZ_MEETINGS (
    MEETING_ID STRING COMMENT 'Unique identifier for each meeting session',
    HOST_ID STRING COMMENT 'User ID of the meeting host',
    MEETING_TOPIC STRING COMMENT 'Subject or topic of the meeting',
    START_TIME TIMESTAMP_NTZ COMMENT 'Timestamp when the meeting started',
    END_TIME TIMESTAMP_NTZ COMMENT 'Timestamp when the meeting ended',
    DURATION_MINUTES NUMBER(38,0) COMMENT 'Total duration of the meeting in minutes',
    LOAD_TIMESTAMP TIMESTAMP_NTZ COMMENT 'Timestamp when the record was first loaded into the system',
    UPDATE_TIMESTAMP TIMESTAMP_NTZ COMMENT 'Timestamp when the record was last updated',
    SOURCE_SYSTEM STRING COMMENT 'Source system from which the data originated'
) COMMENT = 'Bronze layer table for meeting data from Zoom Platform Analytics System';

/*
===============================================================================
                           TABLE 5: BZ_PARTICIPANTS
===============================================================================
Description: Tracks individual participants in meetings including join/leave 
             times and user details.
Source Table: DB_POC_ZOOM.RAW.PARTICIPANTS
===============================================================================
*/

CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.BRONZE.BZ_PARTICIPANTS (
    PARTICIPANT_ID STRING COMMENT 'Unique identifier for each participant session',
    MEETING_ID STRING COMMENT 'Identifier linking to the meeting the participant joined',
    USER_ID STRING COMMENT 'Identifier of the user who participated in the meeting',
    JOIN_TIME TIMESTAMP_NTZ COMMENT 'Timestamp when the participant joined the meeting',
    LEAVE_TIME TIMESTAMP_NTZ COMMENT 'Timestamp when the participant left the meeting',
    LOAD_TIMESTAMP TIMESTAMP_NTZ COMMENT 'Timestamp when the record was first loaded into the system',
    UPDATE_TIMESTAMP TIMESTAMP_NTZ COMMENT 'Timestamp when the record was last updated',
    SOURCE_SYSTEM STRING COMMENT 'Source system from which the data originated'
) COMMENT = 'Bronze layer table for participant data from Zoom Platform Analytics System';

/*
===============================================================================
                           TABLE 6: BZ_SUPPORT_TICKETS
===============================================================================
Description: Contains customer support ticket information including ticket types, 
             status, and resolution details.
Source Table: DB_POC_ZOOM.RAW.SUPPORT_TICKETS
===============================================================================
*/

CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.BRONZE.BZ_SUPPORT_TICKETS (
    TICKET_ID STRING COMMENT 'Unique identifier for each support ticket',
    USER_ID STRING COMMENT 'Identifier of the user who created the support ticket',
    TICKET_TYPE STRING COMMENT 'Category or type of the support ticket',
    RESOLUTION_STATUS STRING COMMENT 'Current status of the support ticket resolution',
    OPEN_DATE DATE COMMENT 'Date when the support ticket was created',
    LOAD_TIMESTAMP TIMESTAMP_NTZ COMMENT 'Timestamp when the record was first loaded into the system',
    UPDATE_TIMESTAMP TIMESTAMP_NTZ COMMENT 'Timestamp when the record was last updated',
    SOURCE_SYSTEM STRING COMMENT 'Source system from which the data originated'
) COMMENT = 'Bronze layer table for support ticket data from Zoom Platform Analytics System';

/*
===============================================================================
                           TABLE 7: BZ_USERS
===============================================================================
Description: Master table containing user account information including personal 
             details and subscription plans.
Source Table: DB_POC_ZOOM.RAW.USERS
Note: Contains PII fields (USER_NAME, EMAIL, COMPANY) - consider data masking
      policies for production environments.
===============================================================================
*/

CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.BRONZE.BZ_USERS (
    USER_ID STRING COMMENT 'Unique identifier for each user account',
    USER_NAME STRING COMMENT 'Display name of the user (PII)',
    EMAIL STRING COMMENT 'Email address of the user account (PII)',
    COMPANY STRING COMMENT 'Company or organization the user is associated with (PII)',
    PLAN_TYPE STRING COMMENT 'Subscription plan type for the user',
    LOAD_TIMESTAMP TIMESTAMP_NTZ COMMENT 'Timestamp when the record was first loaded into the system',
    UPDATE_TIMESTAMP TIMESTAMP_NTZ COMMENT 'Timestamp when the record was last updated',
    SOURCE_SYSTEM STRING COMMENT 'Source system from which the data originated'
) COMMENT = 'Bronze layer table for user data from Zoom Platform Analytics System';

/*
===============================================================================
                           TABLE 8: BZ_AUDIT_TABLE
===============================================================================
Description: Audit table to track data processing activities, load statistics,
             and data lineage for all Bronze layer tables.
===============================================================================
*/

CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.BRONZE.BZ_AUDIT_TABLE (
    RECORD_ID NUMBER AUTOINCREMENT COMMENT 'Auto-incrementing unique identifier for each audit record',
    SOURCE_TABLE STRING COMMENT 'Name of the source table being processed',
    LOAD_TIMESTAMP TIMESTAMP_NTZ COMMENT 'Timestamp when the data load process started',
    PROCESSED_BY STRING COMMENT 'User or system that processed the data',
    PROCESSING_TIME NUMBER COMMENT 'Time taken to process the data in seconds',
    STATUS STRING COMMENT 'Status of the data processing (SUCCESS, FAILED, IN_PROGRESS)',
    RECORDS_PROCESSED NUMBER COMMENT 'Number of records processed in the operation',
    ERROR_MESSAGE STRING COMMENT 'Error message if processing failed',
    BATCH_ID STRING COMMENT 'Batch identifier for grouping related processing operations'
) COMMENT = 'Audit table for tracking data processing activities in Bronze layer';

/*
===============================================================================
                           BRONZE LAYER SUMMARY
===============================================================================
Total Tables Created: 8
- 7 Business Tables (BZ_BILLING_EVENTS, BZ_FEATURE_USAGE, BZ_LICENSES, 
  BZ_MEETINGS, BZ_PARTICIPANTS, BZ_SUPPORT_TICKETS, BZ_USERS)
- 1 Audit Table (BZ_AUDIT_TABLE)

Key Features:
- All tables use Snowflake-compatible data types (STRING, NUMBER, DATE, TIMESTAMP_NTZ)
- No primary keys, foreign keys, or constraints (Bronze layer best practice)
- Comprehensive comments for documentation
- Metadata columns for data lineage (LOAD_TIMESTAMP, UPDATE_TIMESTAMP, SOURCE_SYSTEM)
- PII fields identified in BZ_USERS table
- Audit table for tracking data processing activities

Next Steps:
1. Execute this DDL script in Snowflake
2. Set up data ingestion pipelines from RAW to BRONZE layer
3. Implement data quality checks and monitoring
4. Configure appropriate access controls and data masking policies
5. Proceed with Silver layer design for data transformation and cleansing
===============================================================================
*/