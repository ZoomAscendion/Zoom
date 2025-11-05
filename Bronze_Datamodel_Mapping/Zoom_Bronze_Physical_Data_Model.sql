_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Bronze Physical Data Model for Zoom Platform Analytics System following Medallion architecture with Snowflake-compatible DDL scripts
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Zoom Platform Analytics System - Bronze Physical Data Model

## Overview
This document contains the Bronze layer physical data model for the Zoom Platform Analytics System following the Medallion architecture. The Bronze layer serves as the raw data ingestion layer, storing data in its original format with minimal transformation while adding essential metadata columns for data lineage and audit purposes.

## Key Design Principles
• **Snowflake Compatibility**: All DDL scripts use Snowflake-supported data types and syntax
• **No Constraints**: Following Bronze layer best practices, no primary keys, foreign keys, or constraints are defined
• **Metadata Columns**: Each table includes load_timestamp, update_timestamp, and source_system for audit trail
• **Naming Convention**: All Bronze tables use 'bz_' prefix (e.g., BRONZE.bz_users)
• **Data Types**: Uses Snowflake native types (STRING, NUMBER, TIMESTAMP_NTZ, DATE, BOOLEAN)
• **Audit Trail**: Comprehensive audit table for tracking all data processing activities

## Schema Structure
• **Database**: DB_POC_ZOOM
• **Schema**: BRONZE
• **Tables**: 7 main tables + 1 audit table
• **Naming Pattern**: BRONZE.bz_[table_name]

---

## Bronze Layer DDL Scripts

### 1. Bronze Users Table
```sql
-- Bronze Users Table
-- Stores user account information including personal details and subscription plans
CREATE TABLE IF NOT EXISTS BRONZE.bz_users (
    user_id STRING,
    user_name STRING,
    email STRING,
    company STRING,
    plan_type STRING,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);
```

### 2. Bronze Meetings Table
```sql
-- Bronze Meetings Table
-- Core table containing meeting information including scheduling, duration, and host details
CREATE TABLE IF NOT EXISTS BRONZE.bz_meetings (
    meeting_id STRING,
    host_id STRING,
    meeting_topic STRING,
    start_time TIMESTAMP_NTZ,
    end_time TIMESTAMP_NTZ,
    duration_minutes NUMBER,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);
```

### 3. Bronze Participants Table
```sql
-- Bronze Participants Table
-- Tracks individual participants in meetings including join/leave times and user details
CREATE TABLE IF NOT EXISTS BRONZE.bz_participants (
    participant_id STRING,
    meeting_id STRING,
    user_id STRING,
    join_time TIMESTAMP_NTZ,
    leave_time TIMESTAMP_NTZ,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);
```

### 4. Bronze Feature Usage Table
```sql
-- Bronze Feature Usage Table
-- Tracks usage of various Zoom features during meetings and sessions
CREATE TABLE IF NOT EXISTS BRONZE.bz_feature_usage (
    usage_id STRING,
    meeting_id STRING,
    feature_name STRING,
    usage_count NUMBER,
    usage_date DATE,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);
```

### 5. Bronze Support Tickets Table
```sql
-- Bronze Support Tickets Table
-- Contains customer support ticket information including ticket types, status, and resolution details
CREATE TABLE IF NOT EXISTS BRONZE.bz_support_tickets (
    ticket_id STRING,
    user_id STRING,
    ticket_type STRING,
    resolution_status STRING,
    open_date DATE,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);
```

### 6. Bronze Billing Events Table
```sql
-- Bronze Billing Events Table
-- Contains billing event information for Zoom services including charges, credits, and payment transactions
CREATE TABLE IF NOT EXISTS BRONZE.bz_billing_events (
    event_id STRING,
    user_id STRING,
    event_type STRING,
    amount NUMBER(10,2),
    event_date DATE,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);
```

### 7. Bronze Licenses Table
```sql
-- Bronze Licenses Table
-- Contains information about Zoom licenses assigned to users including license types and validity periods
CREATE TABLE IF NOT EXISTS BRONZE.bz_licenses (
    license_id STRING,
    license_type STRING,
    assigned_to_user_id STRING,
    start_date DATE,
    end_date DATE,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);
```

### 8. Bronze Audit Table
```sql
-- Bronze Audit Table
-- Comprehensive audit table for tracking all data processing activities and lineage
CREATE TABLE IF NOT EXISTS BRONZE.bz_audit_log (
    record_id NUMBER AUTOINCREMENT,
    source_table STRING,
    load_timestamp TIMESTAMP_NTZ,
    processed_by STRING,
    processing_time NUMBER,
    status STRING
);
```

---

## Table Descriptions and Field Details

### bz_users
**Purpose**: Master table containing user account information
• **user_id**: Unique identifier for each user account
• **user_name**: Display name of the user
• **email**: Email address of the user account
• **company**: Company or organization the user is associated with
• **plan_type**: Subscription plan type (Basic, Pro, Business, Enterprise, Education)
• **load_timestamp**: Timestamp when the record was first loaded
• **update_timestamp**: Timestamp when the record was last updated
• **source_system**: Source system from which the data originated

### bz_meetings
**Purpose**: Core table for meeting session information
• **meeting_id**: Unique identifier for each meeting session
• **host_id**: User ID of the meeting host
• **meeting_topic**: Subject or topic of the meeting
• **start_time**: Timestamp when the meeting started
• **end_time**: Timestamp when the meeting ended
• **duration_minutes**: Total duration of the meeting in minutes
• **load_timestamp**: Timestamp when the record was first loaded
• **update_timestamp**: Timestamp when the record was last updated
• **source_system**: Source system from which the data originated

### bz_participants
**Purpose**: Tracking individual meeting participants
• **participant_id**: Unique identifier for each participant session
• **meeting_id**: Identifier linking to the meeting
• **user_id**: Identifier of the user who participated
• **join_time**: Timestamp when the participant joined
• **leave_time**: Timestamp when the participant left
• **load_timestamp**: Timestamp when the record was first loaded
• **update_timestamp**: Timestamp when the record was last updated
• **source_system**: Source system from which the data originated

### bz_feature_usage
**Purpose**: Tracking Zoom feature utilization
• **usage_id**: Unique identifier for each feature usage record
• **meeting_id**: Identifier linking to the meeting where feature was used
• **feature_name**: Name of the Zoom feature (screen_share, recording, chat, breakout_rooms, whiteboard)
• **usage_count**: Number of times the feature was used
• **usage_date**: Date when the feature usage occurred
• **load_timestamp**: Timestamp when the record was first loaded
• **update_timestamp**: Timestamp when the record was last updated
• **source_system**: Source system from which the data originated

### bz_support_tickets
**Purpose**: Customer support ticket management
• **ticket_id**: Unique identifier for each support ticket
• **user_id**: Identifier of the user who created the ticket
• **ticket_type**: Category of the support ticket (technical_issue, billing_inquiry, feature_request, account_access)
• **resolution_status**: Current status (open, in_progress, resolved, closed, escalated)
• **open_date**: Date when the support ticket was created
• **load_timestamp**: Timestamp when the record was first loaded
• **update_timestamp**: Timestamp when the record was last updated
• **source_system**: Source system from which the data originated

### bz_billing_events
**Purpose**: Financial transaction tracking
• **event_id**: Unique identifier for each billing event
• **user_id**: Identifier linking to the user
• **event_type**: Type of billing event (charge, credit, refund, adjustment)
• **amount**: Monetary amount of the billing event
• **event_date**: Date when the billing event occurred
• **load_timestamp**: Timestamp when the record was first loaded
• **update_timestamp**: Timestamp when the record was last updated
• **source_system**: Source system from which the data originated

### bz_licenses
**Purpose**: License assignment and management
• **license_id**: Unique identifier for each license
• **license_type**: Type of Zoom license (Basic, Pro, Business, Enterprise, Education)
• **assigned_to_user_id**: User ID to whom the license is assigned
• **start_date**: Date when the license becomes active
• **end_date**: Date when the license expires
• **load_timestamp**: Timestamp when the record was first loaded
• **update_timestamp**: Timestamp when the record was last updated
• **source_system**: Source system from which the data originated

### bz_audit_log
**Purpose**: Comprehensive audit trail for data processing
• **record_id**: Auto-incrementing unique identifier for each audit record
• **source_table**: Name of the table being processed
• **load_timestamp**: Timestamp when the processing occurred
• **processed_by**: Identifier of the process or user performing the operation
• **processing_time**: Time taken for the processing operation (in seconds)
• **status**: Status of the processing operation (SUCCESS, FAILED, IN_PROGRESS)

---

## Data Type Mappings

### From Raw Schema to Bronze Layer
• **VARCHAR(16777216)** → **STRING** (Snowflake native string type)
• **NUMBER(38,0)** → **NUMBER** (Snowflake native numeric type)
• **NUMBER(10,2)** → **NUMBER(10,2)** (Preserved precision for monetary amounts)
• **TIMESTAMP_NTZ(9)** → **TIMESTAMP_NTZ** (Snowflake timestamp without timezone)
• **DATE** → **DATE** (Snowflake native date type)

---

## Metadata Columns Standard

All Bronze layer tables include the following standard metadata columns:
• **load_timestamp**: TIMESTAMP_NTZ - When the record was first inserted
• **update_timestamp**: TIMESTAMP_NTZ - When the record was last modified
• **source_system**: STRING - Identifies the originating system

---

## Source System Values

Expected values for source_system field:
• **Zoom_API**: Data from Zoom API endpoints
• **Billing_System**: Data from billing and payment systems
• **Support_Portal**: Data from customer support systems
• **License_Management_System**: Data from license management systems
• **Analytics_System**: Data from analytics and reporting systems
• **Manual_Entry**: Manually entered data
• **CRM_System**: Data from customer relationship management systems
• **Email_Integration**: Data from email integration systems

---

## Implementation Notes

### Snowflake Best Practices Applied
• **CREATE TABLE IF NOT EXISTS**: Prevents errors during repeated deployments
• **No Constraints**: Bronze layer follows ELT pattern with no data validation constraints
• **Appropriate Data Types**: Uses Snowflake-optimized data types for performance
• **Consistent Naming**: All tables follow bz_ prefix convention
• **Metadata Inclusion**: Every table includes audit trail columns

### Data Loading Considerations
• Tables are designed for bulk loading using COPY INTO commands
• No foreign key constraints allow for flexible data loading order
• Audit table supports comprehensive data lineage tracking
• All timestamp fields use TIMESTAMP_NTZ for consistent timezone handling

### Performance Optimization
• Tables can be clustered on frequently queried columns (e.g., load_timestamp, user_id)
• Consider partitioning large tables by date columns for better query performance
• Implement appropriate retention policies for audit logs

---

## Usage Examples

### Loading Data into Bronze Tables
```sql
-- Example: Loading users data
COPY INTO BRONZE.bz_users
FROM @raw_data_stage/users/
FILE_FORMAT = (TYPE = 'JSON')
ON_ERROR = 'CONTINUE';

-- Update audit log
INSERT INTO BRONZE.bz_audit_log 
(source_table, load_timestamp, processed_by, processing_time, status)
VALUES 
('bz_users', CURRENT_TIMESTAMP(), 'ETL_PROCESS', 45.2, 'SUCCESS');
```

### Querying Bronze Data
```sql
-- Example: Get recent user registrations
SELECT user_id, user_name, email, plan_type, load_timestamp
FROM BRONZE.bz_users
WHERE load_timestamp >= DATEADD(day, -7, CURRENT_TIMESTAMP())
ORDER BY load_timestamp DESC;

-- Example: Monitor data processing status
SELECT source_table, COUNT(*) as record_count, 
       AVG(processing_time) as avg_processing_time,
       MAX(load_timestamp) as last_processed
FROM BRONZE.bz_audit_log
WHERE status = 'SUCCESS'
GROUP BY source_table
ORDER BY last_processed DESC;
```

---

## Maintenance and Monitoring

### Regular Maintenance Tasks
• Monitor audit log for failed processing operations
• Implement data retention policies for historical data
• Regular clustering maintenance for large tables
• Monitor storage usage and optimize as needed

### Data Quality Checks
• Validate source_system values against expected list
• Monitor for null values in critical fields
• Check for duplicate records based on business keys
• Validate timestamp consistency across related tables

---

**End of Bronze Physical Data Model**

*This model serves as the foundation for the Medallion architecture, providing a robust and scalable Bronze layer for the Zoom Platform Analytics System.*