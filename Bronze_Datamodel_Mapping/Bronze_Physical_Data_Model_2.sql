_____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Bronze Physical Data Model for Zoom Platform Analytics System with updated schema naming conventions
## *Version*: 2
## *Changes*: Updated schema naming convention from 'Bronze' to 'zoom_bronze_schema' and aligned table naming patterns
## *Reason*: Align with raw schema naming conventions as per requirement
## *Updated on*: 
_____________________________________________

# Bronze Physical Data Model for Zoom Platform Analytics System

## 1. Bronze Layer DDL Script

### 1.1 Schema Creation

```sql
-- Create Bronze Schema
CREATE SCHEMA IF NOT EXISTS zoom_bronze_schema;
```

### 1.2 Users Table

```sql
-- Bronze Users Table
CREATE TABLE IF NOT EXISTS zoom_bronze_schema.bz_users (
    user_id VARCHAR(16777216),
    user_name VARCHAR(16777216),
    email VARCHAR(16777216),
    company VARCHAR(16777216),
    plan_type VARCHAR(16777216),
    load_timestamp TIMESTAMP_NTZ(9),
    update_timestamp TIMESTAMP_NTZ(9),
    source_system VARCHAR(16777216)
);
```

### 1.3 Meetings Table

```sql
-- Bronze Meetings Table
CREATE TABLE IF NOT EXISTS zoom_bronze_schema.bz_meetings (
    meeting_id VARCHAR(16777216),
    host_id VARCHAR(16777216),
    meeting_topic VARCHAR(16777216),
    start_time TIMESTAMP_NTZ(9),
    end_time TIMESTAMP_NTZ(9),
    duration_minutes NUMBER(38,0),
    load_timestamp TIMESTAMP_NTZ(9),
    update_timestamp TIMESTAMP_NTZ(9),
    source_system VARCHAR(16777216)
);
```

### 1.4 Participants Table

```sql
-- Bronze Participants Table
CREATE TABLE IF NOT EXISTS zoom_bronze_schema.bz_participants (
    participant_id VARCHAR(16777216),
    meeting_id VARCHAR(16777216),
    user_id VARCHAR(16777216),
    join_time TIMESTAMP_NTZ(9),
    leave_time TIMESTAMP_NTZ(9),
    load_timestamp TIMESTAMP_NTZ(9),
    update_timestamp TIMESTAMP_NTZ(9),
    source_system VARCHAR(16777216)
);
```

### 1.5 Feature Usage Table

```sql
-- Bronze Feature Usage Table
CREATE TABLE IF NOT EXISTS zoom_bronze_schema.bz_feature_usage (
    usage_id VARCHAR(16777216),
    meeting_id VARCHAR(16777216),
    feature_name VARCHAR(16777216),
    usage_count NUMBER(38,0),
    usage_date DATE,
    load_timestamp TIMESTAMP_NTZ(9),
    update_timestamp TIMESTAMP_NTZ(9),
    source_system VARCHAR(16777216)
);
```

### 1.6 Support Tickets Table

```sql
-- Bronze Support Tickets Table
CREATE TABLE IF NOT EXISTS zoom_bronze_schema.bz_support_tickets (
    ticket_id VARCHAR(16777216),
    user_id VARCHAR(16777216),
    ticket_type VARCHAR(16777216),
    resolution_status VARCHAR(16777216),
    open_date DATE,
    load_timestamp TIMESTAMP_NTZ(9),
    update_timestamp TIMESTAMP_NTZ(9),
    source_system VARCHAR(16777216)
);
```

### 1.7 Billing Events Table

```sql
-- Bronze Billing Events Table
CREATE TABLE IF NOT EXISTS zoom_bronze_schema.bz_billing_events (
    event_id VARCHAR(16777216),
    user_id VARCHAR(16777216),
    event_type VARCHAR(16777216),
    amount NUMBER(10,2),
    event_date DATE,
    load_timestamp TIMESTAMP_NTZ(9),
    update_timestamp TIMESTAMP_NTZ(9),
    source_system VARCHAR(16777216)
);
```

### 1.8 Licenses Table

```sql
-- Bronze Licenses Table
CREATE TABLE IF NOT EXISTS zoom_bronze_schema.bz_licenses (
    license_id VARCHAR(16777216),
    license_type VARCHAR(16777216),
    assigned_to_user_id VARCHAR(16777216),
    start_date DATE,
    end_date DATE,
    load_timestamp TIMESTAMP_NTZ(9),
    update_timestamp TIMESTAMP_NTZ(9),
    source_system VARCHAR(16777216)
);
```

### 1.9 Webinars Table

```sql
-- Bronze Webinars Table
CREATE TABLE IF NOT EXISTS zoom_bronze_schema.bz_webinars (
    webinar_id VARCHAR(16777216),
    host_id VARCHAR(16777216),
    webinar_topic VARCHAR(16777216),
    start_time TIMESTAMP_NTZ(9),
    end_time TIMESTAMP_NTZ(9),
    registrants NUMBER(38,0),
    load_timestamp TIMESTAMP_NTZ(9),
    update_timestamp TIMESTAMP_NTZ(9),
    source_system VARCHAR(16777216)
);
```

### 1.10 Audit Table

```sql
-- Bronze Audit Table
CREATE TABLE IF NOT EXISTS zoom_bronze_schema.bz_audit_log (
    record_id NUMBER(38,0) AUTOINCREMENT,
    source_table VARCHAR(16777216),
    load_timestamp TIMESTAMP_NTZ(9),
    processed_by VARCHAR(16777216),
    processing_time NUMBER(38,0),
    status VARCHAR(16777216)
);
```

## 2. Table Descriptions and Column Details

### 2.1 zoom_bronze_schema.bz_users
**Purpose**: Stores raw user account and profile information from source systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| user_id | VARCHAR(16777216) | Unique identifier for each user account |
| user_name | VARCHAR(16777216) | Display name of the user |
| email | VARCHAR(16777216) | Email address of the user |
| company | VARCHAR(16777216) | Company or organization the user belongs to |
| plan_type | VARCHAR(16777216) | Type of subscription plan the user has |
| load_timestamp | TIMESTAMP_NTZ(9) | Timestamp when the record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated |
| source_system | VARCHAR(16777216) | System from which the data originated |

### 2.2 zoom_bronze_schema.bz_meetings
**Purpose**: Stores raw meeting information and session data

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| meeting_id | VARCHAR(16777216) | Unique identifier for each meeting |
| host_id | VARCHAR(16777216) | User ID of the meeting host |
| meeting_topic | VARCHAR(16777216) | Topic or title of the meeting |
| start_time | TIMESTAMP_NTZ(9) | Timestamp when the meeting started |
| end_time | TIMESTAMP_NTZ(9) | Timestamp when the meeting ended |
| duration_minutes | NUMBER(38,0) | Duration of the meeting in minutes |
| load_timestamp | TIMESTAMP_NTZ(9) | Timestamp when the record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated |
| source_system | VARCHAR(16777216) | System from which the data originated |

### 2.3 zoom_bronze_schema.bz_participants
**Purpose**: Stores raw participant join/leave data for meetings

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| participant_id | VARCHAR(16777216) | Unique identifier for each participant record |
| meeting_id | VARCHAR(16777216) | Reference to the meeting the participant joined |
| user_id | VARCHAR(16777216) | User ID of the participant |
| join_time | TIMESTAMP_NTZ(9) | Timestamp when the participant joined the meeting |
| leave_time | TIMESTAMP_NTZ(9) | Timestamp when the participant left the meeting |
| load_timestamp | TIMESTAMP_NTZ(9) | Timestamp when the record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated |
| source_system | VARCHAR(16777216) | System from which the data originated |

### 2.4 zoom_bronze_schema.bz_feature_usage
**Purpose**: Stores raw feature utilization data during meetings

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| usage_id | VARCHAR(16777216) | Unique identifier for each feature usage record |
| meeting_id | VARCHAR(16777216) | Reference to the meeting where the feature was used |
| feature_name | VARCHAR(16777216) | Name of the feature that was used |
| usage_count | NUMBER(38,0) | Number of times the feature was used |
| usage_date | DATE | Date when the feature was used |
| load_timestamp | TIMESTAMP_NTZ(9) | Timestamp when the record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated |
| source_system | VARCHAR(16777216) | System from which the data originated |

### 2.5 zoom_bronze_schema.bz_support_tickets
**Purpose**: Stores raw customer support ticket information

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| ticket_id | VARCHAR(16777216) | Unique identifier for each support ticket |
| user_id | VARCHAR(16777216) | User ID who created the support ticket |
| ticket_type | VARCHAR(16777216) | Type or category of the support ticket |
| resolution_status | VARCHAR(16777216) | Current status of the ticket resolution |
| open_date | DATE | Date when the support ticket was opened |
| load_timestamp | TIMESTAMP_NTZ(9) | Timestamp when the record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated |
| source_system | VARCHAR(16777216) | System from which the data originated |

### 2.6 zoom_bronze_schema.bz_billing_events
**Purpose**: Stores raw billing and payment event data

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| event_id | VARCHAR(16777216) | Unique identifier for each billing event |
| user_id | VARCHAR(16777216) | Reference to the user associated with the billing event |
| event_type | VARCHAR(16777216) | Type of billing event (subscription, payment, refund, etc.) |
| amount | NUMBER(10,2) | Monetary amount associated with the billing event |
| event_date | DATE | Date when the billing event occurred |
| load_timestamp | TIMESTAMP_NTZ(9) | Timestamp when the record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated |
| source_system | VARCHAR(16777216) | System from which the data originated |

### 2.7 zoom_bronze_schema.bz_licenses
**Purpose**: Stores raw license assignment and validity data

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| license_id | VARCHAR(16777216) | Unique identifier for each license |
| license_type | VARCHAR(16777216) | Type of license (Basic, Pro, Business, Enterprise) |
| assigned_to_user_id | VARCHAR(16777216) | User ID to whom the license is assigned |
| start_date | DATE | Date when the license becomes active |
| end_date | DATE | Date when the license expires |
| load_timestamp | TIMESTAMP_NTZ(9) | Timestamp when the record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated |
| source_system | VARCHAR(16777216) | System from which the data originated |

### 2.8 zoom_bronze_schema.bz_webinars
**Purpose**: Stores raw webinar information and registration data

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| webinar_id | VARCHAR(16777216) | Unique identifier for each webinar |
| host_id | VARCHAR(16777216) | User ID of the webinar host |
| webinar_topic | VARCHAR(16777216) | Topic or title of the webinar |
| start_time | TIMESTAMP_NTZ(9) | Timestamp when the webinar started |
| end_time | TIMESTAMP_NTZ(9) | Timestamp when the webinar ended |
| registrants | NUMBER(38,0) | Number of users registered for the webinar |
| load_timestamp | TIMESTAMP_NTZ(9) | Timestamp when the record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated |
| source_system | VARCHAR(16777216) | System from which the data originated |

### 2.9 zoom_bronze_schema.bz_audit_log
**Purpose**: Stores audit information for data processing and lineage tracking

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| record_id | NUMBER(38,0) AUTOINCREMENT | Auto-incrementing unique identifier for each audit record |
| source_table | VARCHAR(16777216) | Name of the source table being processed |
| load_timestamp | TIMESTAMP_NTZ(9) | Timestamp when the data load process occurred |
| processed_by | VARCHAR(16777216) | Identifier of the process or user that performed the operation |
| processing_time | NUMBER(38,0) | Time taken to process the data (in milliseconds) |
| status | VARCHAR(16777216) | Status of the processing operation (SUCCESS, FAILED, PARTIAL) |

## 3. Bronze Layer Design Principles

### 3.1 Raw Data Preservation
- All tables store data in its raw format as received from source systems
- No data transformations or business logic applied
- Maintains complete data lineage and audit trail

### 3.2 Schema Design Characteristics
- **No Primary Keys**: Bronze layer does not enforce primary key constraints to accommodate duplicate or invalid source data
- **No Foreign Keys**: No referential integrity constraints to allow flexible data ingestion
- **No Check Constraints**: No data validation constraints to preserve raw data integrity
- **Flexible Data Types**: Uses VARCHAR(16777216) for maximum flexibility in string data storage

### 3.3 Metadata and Audit Fields
- **load_timestamp**: Tracks when data was first loaded into the Bronze layer
- **update_timestamp**: Tracks when data was last modified
- **source_system**: Identifies the originating system for data lineage

### 3.4 Naming Conventions
- **Schema**: zoom_bronze_schema (aligned with updated naming requirements)
- **Tables**: bz_ prefix followed by descriptive table name
- **Columns**: snake_case naming convention for consistency

## 4. Data Loading Considerations

### 4.1 Ingestion Patterns
- Support for both batch and streaming data ingestion
- Append-only pattern to maintain historical data
- Idempotent loading processes with upsert capabilities

### 4.2 Data Quality
- Preserve all source data including invalid or incomplete records
- Log data quality issues in audit table for downstream processing
- Enable data profiling and quality assessment at Bronze layer

### 4.3 Performance Optimization
- Partitioning by load_timestamp for efficient data management
- Clustering on frequently queried columns (user_id, meeting_id)
- Compression settings optimized for Snowflake storage

## 5. Integration with Medallion Architecture

### 5.1 Source Integration
- Direct ingestion from Zoom API endpoints
- File-based ingestion from data exports
- Real-time streaming from event sources

### 5.2 Silver Layer Preparation
- Bronze tables serve as source for Silver layer transformations
- Data cleansing and standardization performed in Silver layer
- Business rules and data validation applied in Silver layer

### 5.3 Monitoring and Alerting
- Audit table enables monitoring of data processing pipelines
- Status tracking for data quality and processing performance
- Integration with data observability tools for operational monitoring