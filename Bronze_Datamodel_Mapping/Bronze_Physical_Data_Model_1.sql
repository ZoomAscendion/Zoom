_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze Layer Physical Data Model for Zoom Platform Analytics System - Medallion Architecture
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Bronze Layer Physical Data Model - Zoom Platform Analytics System

## Overview

This document contains the comprehensive Bronze Layer Physical Data Model for the Zoom Platform Analytics System following the Medallion architecture pattern. The Bronze layer serves as the first transformation layer from the RAW data, providing cleaned and standardized data structures while maintaining data lineage and audit capabilities.

## Schema Information

- **Database**: DB_POC_ZOOM
- **Schema**: BRONZE
- **Naming Convention**: All Bronze tables use the prefix 'bz_'
- **Architecture**: Medallion Architecture - Bronze Layer
- **Compatibility**: Snowflake SQL

## Bronze Layer DDL Scripts

### 1. Bronze Users Table

```sql
CREATE TABLE IF NOT EXISTS BRONZE.bz_users (
    user_id STRING COMMENT 'Unique identifier for each user account',
    user_name STRING COMMENT 'Display name of the user',
    email STRING COMMENT 'Email address of the user',
    company STRING COMMENT 'Company or organization the user belongs to',
    plan_type STRING COMMENT 'Type of subscription plan the user has',
    registration_date DATE COMMENT 'Date when the user first registered',
    load_timestamp TIMESTAMP_NTZ COMMENT 'Timestamp when the record was loaded into Bronze layer',
    update_timestamp TIMESTAMP_NTZ COMMENT 'Timestamp when the record was last updated',
    source_system STRING COMMENT 'System from which the data originated'
) COMMENT = 'Bronze layer table containing user account and profile information';
```

### 2. Bronze Meetings Table

```sql
CREATE TABLE IF NOT EXISTS BRONZE.bz_meetings (
    meeting_id STRING COMMENT 'Unique identifier for each meeting',
    host_id STRING COMMENT 'User ID of the meeting host',
    meeting_title STRING COMMENT 'Topic or title of the meeting',
    duration_minutes NUMBER COMMENT 'Duration of the meeting in minutes',
    start_time TIMESTAMP_NTZ COMMENT 'Timestamp when the meeting started',
    end_time TIMESTAMP_NTZ COMMENT 'Timestamp when the meeting ended',
    meeting_type STRING COMMENT 'Category of meeting (Scheduled, Instant, Recurring, Webinar)',
    host_name STRING COMMENT 'Name of the user who organized and hosted the meeting',
    load_timestamp TIMESTAMP_NTZ COMMENT 'Timestamp when the record was loaded into Bronze layer',
    update_timestamp TIMESTAMP_NTZ COMMENT 'Timestamp when the record was last updated',
    source_system STRING COMMENT 'System from which the data originated'
) COMMENT = 'Bronze layer table containing meeting information and duration data';
```

### 3. Bronze Attendees Table

```sql
CREATE TABLE IF NOT EXISTS BRONZE.bz_attendees (
    participant_id STRING COMMENT 'Unique identifier for each participant record',
    meeting_id STRING COMMENT 'Reference to the meeting the participant joined',
    user_id STRING COMMENT 'User ID of the participant',
    participant_name STRING COMMENT 'Name of the individual attending the meeting',
    join_time TIMESTAMP_NTZ COMMENT 'Timestamp when the participant joined the meeting',
    leave_time TIMESTAMP_NTZ COMMENT 'Timestamp when the participant left the meeting',
    attendance_duration NUMBER COMMENT 'Total time the attendee spent in the meeting (in minutes)',
    load_timestamp TIMESTAMP_NTZ COMMENT 'Timestamp when the record was loaded into Bronze layer',
    update_timestamp TIMESTAMP_NTZ COMMENT 'Timestamp when the record was last updated',
    source_system STRING COMMENT 'System from which the data originated'
) COMMENT = 'Bronze layer table tracking participant join/leave times for meetings';
```

### 4. Bronze Feature Usage Table

```sql
CREATE TABLE IF NOT EXISTS BRONZE.bz_feature_usage (
    usage_id STRING COMMENT 'Unique identifier for each feature usage record',
    meeting_id STRING COMMENT 'Reference to the meeting where the feature was used',
    feature_name STRING COMMENT 'Name of the feature that was used',
    usage_count NUMBER COMMENT 'Number of times the feature was used',
    usage_duration NUMBER COMMENT 'Total time the feature was active during the meeting (in minutes)',
    usage_date DATE COMMENT 'Date when the feature was used',
    load_timestamp TIMESTAMP_NTZ COMMENT 'Timestamp when the record was loaded into Bronze layer',
    update_timestamp TIMESTAMP_NTZ COMMENT 'Timestamp when the record was last updated',
    source_system STRING COMMENT 'System from which the data originated'
) COMMENT = 'Bronze layer table tracking usage of various Zoom features during meetings';
```

### 5. Bronze Support Tickets Table

```sql
CREATE TABLE IF NOT EXISTS BRONZE.bz_support_tickets (
    ticket_id STRING COMMENT 'Unique identifier for each support ticket',
    user_id STRING COMMENT 'User ID who created the support ticket',
    ticket_type STRING COMMENT 'Type or category of the support ticket',
    issue_description STRING COMMENT 'Detailed explanation of the problem or request',
    priority_level STRING COMMENT 'Urgency classification (Low, Medium, High, Critical)',
    resolution_status STRING COMMENT 'Current status of the ticket resolution',
    open_date DATE COMMENT 'Date when the support ticket was opened',
    close_date DATE COMMENT 'Date when the support ticket was resolved',
    assigned_agent STRING COMMENT 'Support team member handling the ticket',
    load_timestamp TIMESTAMP_NTZ COMMENT 'Timestamp when the record was loaded into Bronze layer',
    update_timestamp TIMESTAMP_NTZ COMMENT 'Timestamp when the record was last updated',
    source_system STRING COMMENT 'System from which the data originated'
) COMMENT = 'Bronze layer table containing customer support ticket information';
```

### 6. Bronze Billing Events Table

```sql
CREATE TABLE IF NOT EXISTS BRONZE.bz_billing_events (
    event_id STRING COMMENT 'Unique identifier for each billing event',
    user_id STRING COMMENT 'Reference to the user associated with the billing event',
    event_type STRING COMMENT 'Type of billing event (subscription, payment, refund, etc.)',
    amount NUMBER(10,2) COMMENT 'Monetary amount associated with the billing event',
    currency STRING COMMENT 'Currency denomination for the transaction',
    transaction_date DATE COMMENT 'Date when the billing event occurred',
    payment_method STRING COMMENT 'Method used for payment (Credit Card, Bank Transfer, etc.)',
    load_timestamp TIMESTAMP_NTZ COMMENT 'Timestamp when the record was loaded into Bronze layer',
    update_timestamp TIMESTAMP_NTZ COMMENT 'Timestamp when the record was last updated',
    source_system STRING COMMENT 'System from which the data originated'
) COMMENT = 'Bronze layer table containing billing and payment event data';
```

### 7. Bronze Licenses Table

```sql
CREATE TABLE IF NOT EXISTS BRONZE.bz_licenses (
    license_id STRING COMMENT 'Unique identifier for each license',
    license_type STRING COMMENT 'Type of license (Basic, Pro, Business, Enterprise)',
    assigned_to_user_id STRING COMMENT 'User ID to whom the license is assigned',
    assigned_user_name STRING COMMENT 'Name of the user to whom the license is allocated',
    start_date DATE COMMENT 'Date when the license becomes active',
    end_date DATE COMMENT 'Date when the license expires',
    license_status STRING COMMENT 'Current state of the license (Active, Expired, Suspended)',
    load_timestamp TIMESTAMP_NTZ COMMENT 'Timestamp when the record was loaded into Bronze layer',
    update_timestamp TIMESTAMP_NTZ COMMENT 'Timestamp when the record was last updated',
    source_system STRING COMMENT 'System from which the data originated'
) COMMENT = 'Bronze layer table managing license assignments and validity periods';
```

### 8. Bronze Webinars Table

```sql
CREATE TABLE IF NOT EXISTS BRONZE.bz_webinars (
    webinar_id STRING COMMENT 'Unique identifier for each webinar',
    host_id STRING COMMENT 'User ID of the webinar host',
    webinar_topic STRING COMMENT 'Topic or title of the webinar',
    start_time TIMESTAMP_NTZ COMMENT 'Timestamp when the webinar started',
    end_time TIMESTAMP_NTZ COMMENT 'Timestamp when the webinar ended',
    registrants NUMBER COMMENT 'Number of users registered for the webinar',
    load_timestamp TIMESTAMP_NTZ COMMENT 'Timestamp when the record was loaded into Bronze layer',
    update_timestamp TIMESTAMP_NTZ COMMENT 'Timestamp when the record was last updated',
    source_system STRING COMMENT 'System from which the data originated'
) COMMENT = 'Bronze layer table containing webinar-specific data including registrant counts';
```

### 9. Bronze Audit Table

```sql
CREATE TABLE IF NOT EXISTS BRONZE.bz_audit_log (
    record_id NUMBER AUTOINCREMENT COMMENT 'Auto-incrementing unique identifier for each audit record',
    source_table STRING COMMENT 'Name of the source table being audited',
    operation_type STRING COMMENT 'Type of operation performed (INSERT, UPDATE, DELETE)',
    record_count NUMBER COMMENT 'Number of records affected by the operation',
    load_timestamp TIMESTAMP_NTZ COMMENT 'Timestamp when the audit record was created',
    processed_by STRING COMMENT 'System or user that processed the data',
    processing_time NUMBER COMMENT 'Time taken to process the operation (in seconds)',
    status STRING COMMENT 'Status of the operation (SUCCESS, FAILED, PARTIAL)',
    error_message STRING COMMENT 'Error details if operation failed',
    source_system STRING COMMENT 'System from which the data originated'
) COMMENT = 'Bronze layer audit table for tracking data lineage and processing history';
```

## Data Type Mapping

| Conceptual Type | Snowflake Type | Usage |
|----------------|----------------|-------|
| Text/String | STRING | Names, descriptions, identifiers |
| Numeric | NUMBER | Counts, durations, amounts |
| Decimal | NUMBER(10,2) | Monetary amounts |
| Date | DATE | Date-only fields |
| Timestamp | TIMESTAMP_NTZ | Date and time fields |
| Boolean | BOOLEAN | True/false flags |

## Bronze Layer Design Principles

### 1. Data Preservation
- All source data is preserved with minimal transformation
- Original data types are maintained where possible
- No data filtering or aggregation at Bronze layer

### 2. Standardization
- Consistent naming conventions (bz_ prefix)
- Standardized metadata columns across all tables
- Uniform data types for similar fields

### 3. Audit and Lineage
- Every table includes load_timestamp, update_timestamp, source_system
- Dedicated audit table for tracking processing history
- Complete data lineage from RAW to Bronze layer

### 4. Scalability
- No constraints or foreign keys for maximum flexibility
- Designed for high-volume data ingestion
- Optimized for Snowflake's columnar storage

## Metadata Columns

All Bronze tables include these standard metadata columns:

- **load_timestamp**: When the record was first loaded into Bronze layer
- **update_timestamp**: When the record was last modified
- **source_system**: Originating system for data lineage tracking

## Data Transformation Notes

### From RAW to Bronze Layer:

1. **Users**: Added registration_date derived from user creation patterns
2. **Meetings**: Added meeting_type and host_name for enhanced analytics
3. **Attendees**: Added attendance_duration calculated from join/leave times
4. **Feature Usage**: Added usage_duration for comprehensive feature analytics
5. **Support Tickets**: Added issue_description, priority_level, close_date, assigned_agent
6. **Billing Events**: Added currency and payment_method for financial analysis
7. **Licenses**: Added license_status and assigned_user_name for license management
8. **Webinars**: Maintained structure with enhanced metadata

## Usage Guidelines

### Data Loading
- Use MERGE statements for upsert operations
- Implement incremental loading based on update_timestamp
- Maintain data freshness through scheduled pipelines

### Data Quality
- Implement data validation rules in Silver layer
- Use Bronze layer for initial data quality assessment
- Monitor audit table for processing issues

### Performance Optimization
- Consider clustering keys for large tables
- Implement appropriate retention policies
- Use Snowflake's automatic optimization features

## Integration with Medallion Architecture

### Bronze Layer Role
- **Input**: RAW layer tables from source systems
- **Processing**: Minimal transformation, data standardization
- **Output**: Clean, standardized data for Silver layer consumption

### Next Steps
- Silver layer will implement business rules and data quality checks
- Gold layer will provide aggregated, business-ready datasets
- Analytics and reporting will primarily consume Gold layer data

---

**Document Control**
- **Created**: 2024
- **Author**: AAVA
- **Version**: 1.0
- **Status**: Active
- **Next Review**: As per project requirements

**Change Log**
- v1.0: Initial Bronze Layer Physical Data Model creation

---

*This document serves as the definitive guide for implementing the Bronze layer of the Zoom Platform Analytics System within the Medallion architecture framework.*