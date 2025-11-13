_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze layer logical data model for Zoom Platform Analytics System supporting usage, reliability, and revenue reporting
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Bronze Layer Logical Data Model - Zoom Platform Analytics System

## 1. PII Classification

### 1.1 Identified PII Fields

| **Table Name** | **Column Name** | **PII Classification** | **Reason for PII Classification** |
|----------------|-----------------|------------------------|-----------------------------------|
| Bz_Users | USER_NAME | **Sensitive PII** | Contains personal identifiable information - individual's full name that can directly identify a person |
| Bz_Users | EMAIL | **Sensitive PII** | Email addresses are personally identifiable information that can be used to contact and identify individuals |
| Bz_Users | COMPANY | **Non-Sensitive PII** | Company information may indirectly identify individuals, especially in small organizations |
| Bz_Meetings | MEETING_TOPIC | **Potentially Sensitive** | Meeting topics may contain confidential business information or personal details |
| Bz_Support_Tickets | TICKET_TYPE | **Potentially Sensitive** | Support ticket types may reveal sensitive business or personal issues |
| Bz_Support_Tickets | RESOLUTION_STATUS | **Non-Sensitive** | Status information is operational data but may be combined with other data for profiling |
| Bz_Billing_Events | AMOUNT | **Sensitive Financial** | Financial transaction amounts are sensitive personal financial information |
| Bz_Billing_Events | EVENT_TYPE | **Potentially Sensitive** | Billing event types may reveal financial behavior patterns |

## 2. Bronze Layer Logical Model

### 2.1 Bz_Users
**Description**: Bronze layer table storing raw user account information from source systems

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| USER_NAME | VARCHAR(16777216) | Display name of the user for identification and personalization |
| EMAIL | VARCHAR(16777216) | User's email address used for communication and account authentication |
| COMPANY | VARCHAR(16777216) | Company or organization name associated with the user account |
| PLAN_TYPE | VARCHAR(16777216) | Subscription plan type indicating service level (Basic, Pro, Business, Enterprise) |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last modified or updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated |

### 2.2 Bz_Meetings
**Description**: Bronze layer table containing raw meeting session data and metadata

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| MEETING_TOPIC | VARCHAR(16777216) | Topic or title of the meeting as specified by the host |
| START_TIME | TIMESTAMP_NTZ(9) | Timestamp indicating when the meeting session began |
| END_TIME | TIMESTAMP_NTZ(9) | Timestamp indicating when the meeting session concluded |
| DURATION_MINUTES | NUMBER(38,0) | Total duration of the meeting calculated in minutes |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last modified or updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated |

### 2.3 Bz_Participants
**Description**: Bronze layer table tracking meeting participation and attendance details

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| JOIN_TIME | TIMESTAMP_NTZ(9) | Timestamp when the participant joined the meeting session |
| LEAVE_TIME | TIMESTAMP_NTZ(9) | Timestamp when the participant left the meeting session |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last modified or updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated |

### 2.4 Bz_Feature_Usage
**Description**: Bronze layer table capturing raw feature utilization data during meetings

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| FEATURE_NAME | VARCHAR(16777216) | Name of the specific platform feature that was utilized |
| USAGE_COUNT | NUMBER(38,0) | Number of times the feature was activated or used during the session |
| USAGE_DATE | DATE | Date when the feature usage occurred |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last modified or updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated |

### 2.5 Bz_Support_Tickets
**Description**: Bronze layer table storing raw customer support request and resolution data

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| TICKET_TYPE | VARCHAR(16777216) | Category classification of the support request (Technical, Billing, Feature Request, etc.) |
| RESOLUTION_STATUS | VARCHAR(16777216) | Current state of the support ticket (Open, In Progress, Resolved, Closed) |
| OPEN_DATE | DATE | Date when the support ticket was initially created and submitted |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last modified or updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated |

### 2.6 Bz_Billing_Events
**Description**: Bronze layer table containing raw financial transaction and billing activity data

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| EVENT_TYPE | VARCHAR(16777216) | Type of billing transaction (Subscription, Upgrade, Refund, Usage Charge, etc.) |
| AMOUNT | NUMBER(10,2) | Monetary value of the billing event in the specified currency |
| EVENT_DATE | DATE | Date when the billing transaction or event occurred |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last modified or updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated |

### 2.7 Bz_Licenses
**Description**: Bronze layer table managing raw license assignment and entitlement data

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| LICENSE_TYPE | VARCHAR(16777216) | Category of license entitlement (Basic, Pro, Enterprise, Add-on features) |
| START_DATE | DATE | Date when the license becomes active and available for use |
| END_DATE | DATE | Date when the license expires and is no longer valid |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last modified or updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated |

## 3. Audit Table Design

### 3.1 Bz_Audit_Log
**Description**: Comprehensive audit trail table tracking all data processing activities across Bronze layer tables

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| RECORD_ID | VARCHAR(16777216) | Unique identifier for each audit log entry |
| SOURCE_TABLE | VARCHAR(16777216) | Name of the Bronze layer table that was processed |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the data processing operation began |
| PROCESSED_BY | VARCHAR(16777216) | Identifier of the system, process, or user that performed the operation |
| PROCESSING_TIME | NUMBER(10,3) | Duration in seconds required to complete the processing operation |
| STATUS | VARCHAR(50) | Outcome status of the processing operation (SUCCESS, FAILED, PARTIAL, WARNING) |
| RECORD_COUNT | NUMBER(38,0) | Number of records processed in the operation |
| ERROR_MESSAGE | VARCHAR(16777216) | Detailed error description if processing failed |
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
         │ (User Reference)
         ▼
┌─────────────────┐       ┌─────────────────┐
│   Bz_Meetings   │◄──────┤ Bz_Participants │
│                 │       │                 │
│ - MEETING_TOPIC │       │ - JOIN_TIME     │
│ - START_TIME    │       │ - LEAVE_TIME    │
│ - END_TIME      │       └─────────────────┘
│ - DURATION_MIN  │              │
└─────────────────┘              │ (User Reference)
         │                       ▼
         │ (Meeting Reference)   ┌─────────────────┐
         ▼                       │   Bz_Users      │
┌─────────────────┐              │ (Referenced)    │
│Bz_Feature_Usage │              └─────────────────┘
│                 │
│ - FEATURE_NAME  │
│ - USAGE_COUNT   │
│ - USAGE_DATE    │
└─────────────────┘

┌─────────────────┐
│   Bz_Users      │
│ (Referenced)    │
└─────────────────┘
         │
         │ (User Reference)
         ▼
┌─────────────────┐
│Bz_Support_Tickets│
│                 │
│ - TICKET_TYPE   │
│ - RESOLUTION_ST │
│ - OPEN_DATE     │
└─────────────────┘

┌─────────────────┐
│   Bz_Users      │
│ (Referenced)    │
└─────────────────┘
         │
         │ (User Reference)
         ▼
┌─────────────────┐
│Bz_Billing_Events│
│                 │
│ - EVENT_TYPE    │
│ - AMOUNT        │
│ - EVENT_DATE    │
└─────────────────┘

┌─────────────────┐
│   Bz_Users      │
│ (Referenced)    │
└─────────────────┘
         │
         │ (Assigned User Reference)
         ▼
┌─────────────────┐
│   Bz_Licenses   │
│                 │
│ - LICENSE_TYPE  │
│ - START_DATE    │
│ - END_DATE      │
└─────────────────┘
```

### 4.2 Relationship Descriptions

1. **Bz_Users → Bz_Meetings**: One-to-Many relationship where one user can host multiple meetings (Host User Reference)
2. **Bz_Meetings → Bz_Participants**: One-to-Many relationship where one meeting can have multiple participants (Meeting Reference)
3. **Bz_Users → Bz_Participants**: One-to-Many relationship where one user can participate in multiple meetings (Attendee User Reference)
4. **Bz_Meetings → Bz_Feature_Usage**: One-to-Many relationship where one meeting can have multiple feature usage records (Meeting Reference)
5. **Bz_Users → Bz_Support_Tickets**: One-to-Many relationship where one user can create multiple support tickets (User Reference)
6. **Bz_Users → Bz_Billing_Events**: One-to-Many relationship where one user can have multiple billing events (User Reference)
7. **Bz_Users → Bz_Licenses**: One-to-Many relationship where one user can be assigned multiple licenses (Assigned User Reference)

## 5. Design Rationale and Assumptions

### 5.1 Key Design Decisions

1. **Naming Convention**: All Bronze layer tables use 'Bz_' prefix to clearly identify the medallion architecture layer
2. **Data Preservation**: All source data fields are preserved exactly as they appear in the raw schema, excluding primary and foreign key fields
3. **Metadata Standardization**: Consistent metadata columns (LOAD_TIMESTAMP, UPDATE_TIMESTAMP, SOURCE_SYSTEM) across all tables for data lineage tracking
4. **PII Classification**: Comprehensive identification of sensitive data fields to support data governance and compliance requirements
5. **Audit Trail**: Dedicated audit table to track all data processing activities for compliance and troubleshooting

### 5.2 Assumptions Made

1. **Source System Integration**: All source systems provide consistent timestamp formats and data quality
2. **Data Volume**: The VARCHAR(16777216) data type is sufficient for text fields based on Snowflake's maximum capacity
3. **Processing Frequency**: Data loads occur regularly enough to make timestamp tracking meaningful
4. **Relationship Integrity**: Source systems maintain referential integrity that will be preserved in Bronze layer
5. **Compliance Requirements**: PII classification follows GDPR and similar data protection frameworks
6. **Audit Retention**: Audit logs will be retained according to organizational data retention policies

### 5.3 Bronze Layer Benefits

1. **Data Preservation**: Complete historical record of all source data changes
2. **Flexibility**: Raw data format allows for multiple downstream transformation approaches
3. **Debugging**: Ability to trace data issues back to original source
4. **Compliance**: Comprehensive audit trail and PII classification support regulatory requirements
5. **Scalability**: Design supports high-volume data ingestion with minimal transformation overhead