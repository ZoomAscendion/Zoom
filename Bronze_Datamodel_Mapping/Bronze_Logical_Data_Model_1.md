_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze layer logical data model for Zoom Platform Analytics System supporting raw data ingestion and audit tracking
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Zoom Platform Analytics System - Bronze Layer Logical Data Model

## 1. PII Classification

### 1.1 PII Fields Identified

| **Table Name** | **Column Name** | **PII Classification** | **Reason for PII Classification** |
|----------------|-----------------|------------------------|-----------------------------------|
| Bz_Users | USER_NAME | **Sensitive PII** | Contains personal identifiable names that can directly identify individuals |
| Bz_Users | EMAIL | **Sensitive PII** | Email addresses are direct personal identifiers and can be used to contact individuals |
| Bz_Users | COMPANY | **Non-Sensitive PII** | Company affiliation can be used to identify individuals in smaller organizations |
| Bz_Meetings | MEETING_TOPIC | **Potentially Sensitive** | Meeting topics may contain confidential business information or personal details |
| Bz_Support_Tickets | TICKET_TYPE | **Potentially Sensitive** | Support ticket types may reveal personal issues or business problems |

## 2. Bronze Layer Logical Model

### 2.1 Bz_Users
**Description:** Master table containing user account information including personal details and subscription plans in raw format from source systems.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| USER_NAME | VARCHAR(16777216) | Display name of the user account |
| EMAIL | VARCHAR(16777216) | Email address associated with the user account |
| COMPANY | VARCHAR(16777216) | Company or organization the user is affiliated with |
| PLAN_TYPE | VARCHAR(16777216) | Subscription plan type for the user (Basic, Pro, Business, Enterprise, Education) |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated |

### 2.2 Bz_Meetings
**Description:** Core table containing meeting information including scheduling, duration, and host details in raw format from source systems.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| MEETING_TOPIC | VARCHAR(16777216) | Subject or topic of the meeting |
| START_TIME | TIMESTAMP_NTZ(9) | Timestamp when the meeting started |
| END_TIME | TIMESTAMP_NTZ(9) | Timestamp when the meeting ended |
| DURATION_MINUTES | NUMBER(38,0) | Total duration of the meeting in minutes |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated |

### 2.3 Bz_Participants
**Description:** Tracks individual participants in meetings including join/leave times and user details in raw format from source systems.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| JOIN_TIME | TIMESTAMP_NTZ(9) | Timestamp when the participant joined the meeting |
| LEAVE_TIME | TIMESTAMP_NTZ(9) | Timestamp when the participant left the meeting |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated |

### 2.4 Bz_Feature_Usage
**Description:** Tracks usage of various Zoom features during meetings and sessions in raw format from source systems.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| FEATURE_NAME | VARCHAR(16777216) | Name of the Zoom feature that was used (screen_share, recording, chat, breakout_rooms, whiteboard) |
| USAGE_COUNT | NUMBER(38,0) | Number of times the feature was used in the meeting |
| USAGE_DATE | DATE | Date when the feature usage occurred |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated |

### 2.5 Bz_Support_Tickets
**Description:** Contains customer support ticket information including ticket types, status, and resolution details in raw format from source systems.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| TICKET_TYPE | VARCHAR(16777216) | Category or type of the support ticket (technical_issue, billing_inquiry, feature_request, account_access) |
| RESOLUTION_STATUS | VARCHAR(16777216) | Current status of the support ticket resolution (open, in_progress, resolved, closed, escalated) |
| OPEN_DATE | DATE | Date when the support ticket was created |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated |

### 2.6 Bz_Billing_Events
**Description:** Contains billing event information for Zoom services including charges, credits, and payment transactions in raw format from source systems.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| EVENT_TYPE | VARCHAR(16777216) | Type of billing event (charge, credit, refund, adjustment) |
| AMOUNT | NUMBER(10,2) | Monetary amount of the billing event |
| EVENT_DATE | DATE | Date when the billing event occurred |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated |

### 2.7 Bz_Licenses
**Description:** Contains information about Zoom licenses assigned to users including license types and validity periods in raw format from source systems.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| LICENSE_TYPE | VARCHAR(16777216) | Type of Zoom license (Basic, Pro, Business, Enterprise, Education) |
| START_DATE | DATE | Date when the license becomes active |
| END_DATE | DATE | Date when the license expires |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated |

## 3. Audit Table Design

### 3.1 Bz_Audit_Log
**Description:** Comprehensive audit table to track all data processing activities, load operations, and system events across the Bronze layer.

| **Field Name** | **Data Type** | **Description** |
|----------------|---------------|------------------|
| RECORD_ID | VARCHAR(16777216) | Unique identifier for each audit record |
| SOURCE_TABLE | VARCHAR(16777216) | Name of the source table being processed |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the data load operation occurred |
| PROCESSED_BY | VARCHAR(16777216) | System or user identifier that processed the data |
| PROCESSING_TIME | NUMBER(10,2) | Time taken to process the data in seconds |
| STATUS | VARCHAR(50) | Status of the processing operation (SUCCESS, FAILED, PARTIAL, IN_PROGRESS) |

## 4. Conceptual Data Model Diagram

### 4.1 Table Relationships in Block Diagram Format

```
┌─────────────────┐
│   Bz_Users      │
│                 │
│ - USER_NAME     │
│ - EMAIL         │
│ - COMPANY       │
│ - PLAN_TYPE     │
└─────────────────┘
         │
         │ (User Reference)
         ▼
┌─────────────────┐       ┌─────────────────┐
│   Bz_Meetings   │◄──────┤ Bz_Participants │
│                 │       │                 │
│ - MEETING_TOPIC │       │ - JOIN_TIME     │
│ - START_TIME    │       │ - LEAVE_TIME    │
│ - END_TIME      │       └─────────────────┘
│ - DURATION_MIN  │       (Meeting Reference)
└─────────────────┘
         │
         │ (Meeting Reference)
         ▼
┌─────────────────┐
│ Bz_Feature_Usage│
│                 │
│ - FEATURE_NAME  │
│ - USAGE_COUNT   │
│ - USAGE_DATE    │
└─────────────────┘

┌─────────────────┐       ┌─────────────────┐
│   Bz_Users      │◄──────┤Bz_Support_Tickets│
│                 │       │                 │
│ (User Reference)│       │ - TICKET_TYPE   │
└─────────────────┘       │ - RESOLUTION_ST │
                          │ - OPEN_DATE     │
                          └─────────────────┘

┌─────────────────┐       ┌─────────────────┐
│   Bz_Users      │◄──────┤ Bz_Billing_Events│
│                 │       │                 │
│ (User Reference)│       │ - EVENT_TYPE    │
└─────────────────┘       │ - AMOUNT        │
                          │ - EVENT_DATE    │
                          └─────────────────┘

┌─────────────────┐       ┌─────────────────┐
│   Bz_Users      │◄──────┤   Bz_Licenses   │
│                 │       │                 │
│ (User Reference)│       │ - LICENSE_TYPE  │
└─────────────────┘       │ - START_DATE    │
                          │ - END_DATE      │
                          └─────────────────┘
```

### 4.2 Key Relationships

1. **Bz_Users → Bz_Meetings**: One-to-Many relationship via User Reference (Host)
2. **Bz_Meetings → Bz_Participants**: One-to-Many relationship via Meeting Reference
3. **Bz_Meetings → Bz_Feature_Usage**: One-to-Many relationship via Meeting Reference
4. **Bz_Users → Bz_Support_Tickets**: One-to-Many relationship via User Reference
5. **Bz_Users → Bz_Billing_Events**: One-to-Many relationship via User Reference
6. **Bz_Users → Bz_Licenses**: One-to-Many relationship via User Reference
7. **Bz_Participants → Bz_Users**: Many-to-One relationship via User Reference (Attendee)

## 5. Design Decisions and Assumptions

### 5.1 Key Design Decisions

1. **Naming Convention**: All Bronze layer tables follow the 'Bz_' prefix to maintain consistency and clearly identify Bronze layer entities.

2. **Data Preservation**: All source data fields are preserved exactly as received, maintaining data lineage and enabling full traceability.

3. **Metadata Columns**: Standard metadata columns (LOAD_TIMESTAMP, UPDATE_TIMESTAMP, SOURCE_SYSTEM) are added to all tables for operational tracking.

4. **PII Handling**: PII fields are identified and classified but preserved in raw format for Bronze layer, with security to be implemented at access level.

5. **Audit Strategy**: Comprehensive audit table design to track all processing activities and ensure data governance compliance.

### 5.2 Assumptions Made

1. **Source System Reliability**: Assumed that source systems provide consistent data formats and structures.

2. **Data Volume**: Designed for high-volume data ingestion with appropriate data types and structures.

3. **Referential Integrity**: Foreign key relationships are logical and will be enforced through application logic rather than database constraints in Bronze layer.

4. **Schema Evolution**: Structure allows for schema evolution and addition of new fields without breaking existing processes.

5. **Compliance Requirements**: PII classification follows GDPR and standard data protection frameworks.

## 6. Implementation Guidelines

### 6.1 Data Loading Strategy

1. **Incremental Loading**: Use LOAD_TIMESTAMP and UPDATE_TIMESTAMP for incremental data processing.

2. **Error Handling**: Implement comprehensive error handling with detailed logging in the audit table.

3. **Data Validation**: Perform basic data quality checks while preserving raw data integrity.

4. **Performance Optimization**: Consider partitioning strategies based on date fields for large tables.

### 6.2 Security Considerations

1. **Access Control**: Implement role-based access control for PII-containing tables.

2. **Data Masking**: Consider implementing data masking for non-production environments.

3. **Audit Trail**: Maintain comprehensive audit trails for all data access and modifications.

4. **Encryption**: Implement encryption at rest and in transit for sensitive data.
