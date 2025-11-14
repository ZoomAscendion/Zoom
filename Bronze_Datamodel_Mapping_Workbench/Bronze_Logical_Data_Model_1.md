_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze layer logical data model for Zoom Platform Analytics System supporting raw data ingestion with audit capabilities
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Bronze Layer Logical Data Model - Zoom Platform Analytics System

## 1. PII Classification

### 1.1 Identified PII Fields

| **Table Name** | **Column Name** | **PII Classification** | **Reason for PII Classification** |
|----------------|-----------------|------------------------|-----------------------------------|
| Bz_Users | USER_NAME | **High Sensitivity PII** | Contains personal identifiable information - individual's full name that can directly identify a person |
| Bz_Users | EMAIL | **High Sensitivity PII** | Email addresses are direct personal identifiers that can be used to contact and identify individuals, regulated under GDPR and other privacy laws |
| Bz_Users | COMPANY | **Medium Sensitivity PII** | Company affiliation can be used to identify individuals in smaller organizations or specific roles |
| Bz_Meetings | MEETING_TOPIC | **Medium Sensitivity PII** | Meeting topics may contain confidential business information or personal details that could identify participants |
| Bz_Support_Tickets | TICKET_TYPE | **Low Sensitivity PII** | Support ticket types may reveal user behavior patterns and technical issues that could be used for profiling |
| Bz_Support_Tickets | RESOLUTION_STATUS | **Low Sensitivity PII** | Resolution status combined with other data could reveal user experience patterns and service quality issues |
| Bz_Billing_Events | AMOUNT | **Medium Sensitivity PII** | Financial transaction amounts are sensitive personal financial information protected under financial privacy regulations |
| Bz_Billing_Events | EVENT_TYPE | **Low Sensitivity PII** | Billing event types can reveal user subscription patterns and financial behavior |
| Bz_Licenses | LICENSE_TYPE | **Low Sensitivity PII** | License types can reveal organizational structure and user roles within companies |

## 2. Bronze Layer Logical Model

### 2.1 Bz_Users
**Description**: Bronze layer table storing raw user account information and profile data from source systems

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| USER_NAME | VARCHAR(16777216) | Display name of the user for identification and communication purposes |
| EMAIL | VARCHAR(16777216) | User's email address used for login authentication and communication |
| COMPANY | VARCHAR(16777216) | Company or organization name associated with the user account |
| PLAN_TYPE | VARCHAR(16777216) | Subscription plan type indicating service level (Basic, Pro, Business, Enterprise) |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last modified or updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the user data originated |

### 2.2 Bz_Meetings
**Description**: Bronze layer table containing raw meeting session data and metadata

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| MEETING_TOPIC | VARCHAR(16777216) | Topic or title of the meeting as specified by the host |
| START_TIME | TIMESTAMP_NTZ(9) | Timestamp when the meeting session began |
| END_TIME | TIMESTAMP_NTZ(9) | Timestamp when the meeting session concluded |
| DURATION_MINUTES | NUMBER(38,0) | Total duration of the meeting calculated in minutes |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last modified or updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the meeting data originated |

### 2.3 Bz_Participants
**Description**: Bronze layer table tracking meeting participation and attendance details

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| JOIN_TIME | TIMESTAMP_NTZ(9) | Timestamp when the participant joined the meeting session |
| LEAVE_TIME | TIMESTAMP_NTZ(9) | Timestamp when the participant left the meeting session |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last modified or updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the participant data originated |

### 2.4 Bz_Feature_Usage
**Description**: Bronze layer table storing raw feature utilization data during meetings

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| FEATURE_NAME | VARCHAR(16777216) | Name of the platform feature being tracked (Screen Share, Recording, Chat, etc.) |
| USAGE_COUNT | NUMBER(38,0) | Number of times the specific feature was utilized during the session |
| USAGE_DATE | DATE | Date when the feature usage occurred |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last modified or updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the feature usage data originated |

### 2.5 Bz_Support_Tickets
**Description**: Bronze layer table containing raw customer support request and resolution data

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| TICKET_TYPE | VARCHAR(16777216) | Category of the support issue (Technical, Billing, Feature Request, etc.) |
| RESOLUTION_STATUS | VARCHAR(16777216) | Current state of the ticket (Open, In Progress, Resolved, Closed) |
| OPEN_DATE | DATE | Date when the support ticket was initially created |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last modified or updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the support ticket data originated |

### 2.6 Bz_Billing_Events
**Description**: Bronze layer table storing raw financial transaction and billing activity data

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| EVENT_TYPE | VARCHAR(16777216) | Type of billing transaction (Subscription, Upgrade, Refund, Payment, etc.) |
| AMOUNT | NUMBER(10,2) | Monetary value of the transaction in the specified currency |
| EVENT_DATE | DATE | Date when the billing event or transaction occurred |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last modified or updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the billing data originated |

### 2.7 Bz_Licenses
**Description**: Bronze layer table containing raw license assignment and entitlement data

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| LICENSE_TYPE | VARCHAR(16777216) | Category of license (Basic, Pro, Enterprise, Add-on) indicating service level |
| START_DATE | DATE | Date when the license becomes active and available for use |
| END_DATE | DATE | Date when the license expires and is no longer valid |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last modified or updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the license data originated |

## 3. Audit Table Design

### 3.1 Bz_Audit_Log
**Description**: Comprehensive audit table tracking all data processing activities and changes across Bronze layer tables

| **Field Name** | **Data Type** | **Description** |
|----------------|---------------|------------------|
| RECORD_ID | VARCHAR(16777216) | Unique identifier for each audit log entry |
| SOURCE_TABLE | VARCHAR(16777216) | Name of the Bronze layer table being audited |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the data processing operation occurred |
| PROCESSED_BY | VARCHAR(16777216) | Identifier of the system, process, or user that performed the operation |
| PROCESSING_TIME | NUMBER(10,3) | Duration in seconds taken to complete the processing operation |
| STATUS | VARCHAR(50) | Status of the processing operation (SUCCESS, FAILED, PARTIAL, RETRY) |
| RECORD_COUNT | NUMBER(38,0) | Number of records processed in the operation |
| ERROR_MESSAGE | VARCHAR(16777216) | Detailed error message if the operation failed |
| OPERATION_TYPE | VARCHAR(50) | Type of operation performed (INSERT, UPDATE, DELETE, MERGE) |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated |

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
         │ (Connected via USER reference)
         ▼
┌─────────────────┐
│  Bz_Meetings    │
│                 │
│ - MEETING_TOPIC │
│ - START_TIME    │
│ - END_TIME      │
│ - DURATION_MIN  │
└─────────────────┘
         │
         │ (Connected via MEETING reference)
         ▼
┌─────────────────┐
│ Bz_Participants │
│                 │
│ - JOIN_TIME     │
│ - LEAVE_TIME    │
└─────────────────┘

┌─────────────────┐
│  Bz_Meetings    │ ────────────► ┌─────────────────┐
│                 │               │Bz_Feature_Usage │
│ (MEETING ref)   │               │                 │
└─────────────────┘               │ - FEATURE_NAME  │
                                  │ - USAGE_COUNT   │
                                  │ - USAGE_DATE    │
                                  └─────────────────┘

┌─────────────────┐
│   Bz_Users      │ ────────────► ┌─────────────────┐
│                 │               │Bz_Support_Tickets│
│ (USER ref)      │               │                 │
└─────────────────┘               │ - TICKET_TYPE   │
                                  │ - RESOLUTION_ST │
                                  │ - OPEN_DATE     │
                                  └─────────────────┘

┌─────────────────┐
│   Bz_Users      │ ────────────► ┌─────────────────┐
│                 │               │Bz_Billing_Events│
│ (USER ref)      │               │                 │
└─────────────────┘               │ - EVENT_TYPE    │
                                  │ - AMOUNT        │
                                  │ - EVENT_DATE    │
                                  └─────────────────┘

┌─────────────────┐
│   Bz_Users      │ ────────────► ┌─────────────────┐
│                 │               │   Bz_Licenses   │
│ (USER ref)      │               │                 │
└─────────────────┘               │ - LICENSE_TYPE  │
                                  │ - START_DATE    │
                                  │ - END_DATE      │
                                  └─────────────────┘

┌─────────────────┐
│   Bz_Users      │ ────────────► ┌─────────────────┐
│                 │               │ Bz_Participants │
│ (USER ref)      │               │                 │
└─────────────────┘               │ (Attendee ref)  │
                                  └─────────────────┘
```

### 4.2 Key Relationship Connections

1. **Bz_Users → Bz_Meetings**: Connected via HOST_USER reference field (One-to-Many)
2. **Bz_Meetings → Bz_Participants**: Connected via MEETING reference field (One-to-Many)
3. **Bz_Meetings → Bz_Feature_Usage**: Connected via MEETING reference field (One-to-Many)
4. **Bz_Users → Bz_Support_Tickets**: Connected via USER reference field (One-to-Many)
5. **Bz_Users → Bz_Billing_Events**: Connected via USER reference field (One-to-Many)
6. **Bz_Users → Bz_Licenses**: Connected via ASSIGNED_USER reference field (One-to-Many)
7. **Bz_Users → Bz_Participants**: Connected via ATTENDEE_USER reference field (One-to-Many)

## 5. Design Rationale and Assumptions

### 5.1 Key Design Decisions

1. **Naming Convention**: All Bronze layer tables use 'Bz_' prefix to clearly identify the medallion architecture layer
2. **Primary/Foreign Key Exclusion**: Removed all primary key and foreign key fields from source structure to focus on business data
3. **Metadata Standardization**: Added consistent load_timestamp, update_timestamp, and source_system fields across all tables
4. **PII Classification**: Implemented comprehensive PII identification based on GDPR and privacy regulation standards
5. **Audit Trail**: Designed comprehensive audit table to track all data processing activities and ensure data lineage

### 5.2 Assumptions Made

1. **Source Data Quality**: Assumed source systems provide consistent data formats and structures
2. **Timestamp Precision**: Used TIMESTAMP_NTZ(9) for high precision temporal data tracking
3. **String Length**: Used VARCHAR(16777216) to accommodate variable-length text data without truncation
4. **Numeric Precision**: Used NUMBER(10,2) for monetary amounts to ensure accurate financial calculations
5. **Audit Retention**: Assumed audit logs will be retained for compliance and troubleshooting purposes
6. **Data Volume**: Designed for scalable data processing with consideration for high-volume ingestion

### 5.3 Bronze Layer Characteristics

1. **Raw Data Preservation**: Maintains exact structure and content from source systems
2. **Minimal Transformation**: No business logic applied, only technical metadata addition
3. **Historical Tracking**: Supports temporal analysis through timestamp fields
4. **Source Traceability**: Maintains clear lineage through source_system identification
5. **Audit Compliance**: Comprehensive logging for regulatory and operational requirements