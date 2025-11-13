_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze Layer Logical Data Model for Zoom Platform Analytics System supporting Medallion architecture
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Bronze Layer Logical Data Model - Zoom Platform Analytics System

## 1. PII Classification

### 1.1 Identified PII Fields

| **Table Name** | **Column Name** | **PII Classification** | **Reason for PII Classification** |
|----------------|-----------------|------------------------|-----------------------------------|
| Bz_Users | USER_NAME | **Sensitive PII** | Contains personal identifiable information - individual's full name that can directly identify a person |
| Bz_Users | EMAIL | **Sensitive PII** | Email addresses are personally identifiable information that can be used to contact and identify individuals directly |
| Bz_Users | COMPANY | **Non-Sensitive PII** | Company information can indirectly identify individuals, especially in small organizations, but is less sensitive than direct personal identifiers |
| Bz_Meetings | MEETING_TOPIC | **Potentially Sensitive** | Meeting topics may contain confidential business information or personal details that could be sensitive in certain contexts |
| Bz_Support_Tickets | TICKET_TYPE | **Non-Sensitive PII** | While not directly identifying, ticket types combined with user information could reveal personal issues or business problems |

## 2. Bronze Layer Logical Model

### 2.1 Bz_Users
**Description**: Bronze layer table storing raw user account information and profile details from source systems

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
**Description**: Bronze layer table containing raw meeting data including scheduling and duration information

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| MEETING_TOPIC | VARCHAR(16777216) | Topic or title of the meeting as specified by the host |
| START_TIME | TIMESTAMP_NTZ(9) | Timestamp indicating when the meeting session began |
| END_TIME | TIMESTAMP_NTZ(9) | Timestamp indicating when the meeting session concluded |
| DURATION_MINUTES | NUMBER(38,0) | Total duration of the meeting calculated in minutes |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last modified or updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the meeting data originated |

### 2.3 Bz_Participants
**Description**: Bronze layer table tracking meeting participation details and attendance patterns

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
| FEATURE_NAME | VARCHAR(16777216) | Name of the specific platform feature being tracked (Screen Share, Recording, Chat, etc.) |
| USAGE_COUNT | NUMBER(38,0) | Number of times the feature was activated or utilized during the session |
| USAGE_DATE | DATE | Date when the feature usage occurred |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last modified or updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the feature usage data originated |

### 2.5 Bz_Support_Tickets
**Description**: Bronze layer table containing raw customer support request and resolution data

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| TICKET_TYPE | VARCHAR(16777216) | Category classification of the support request (Technical, Billing, Feature Request, etc.) |
| RESOLUTION_STATUS | VARCHAR(16777216) | Current state of the ticket in the resolution workflow (Open, In Progress, Resolved, Closed) |
| OPEN_DATE | DATE | Date when the support ticket was initially created and submitted |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last modified or updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the support ticket data originated |

### 2.6 Bz_Billing_Events
**Description**: Bronze layer table storing raw financial transaction and billing activity data

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| EVENT_TYPE | VARCHAR(16777216) | Type of billing transaction (Subscription, Upgrade, Refund, Usage Charge, etc.) |
| AMOUNT | NUMBER(10,2) | Monetary value of the billing event in the specified currency |
| EVENT_DATE | DATE | Date when the billing transaction or event occurred |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last modified or updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the billing event data originated |

### 2.7 Bz_Licenses
**Description**: Bronze layer table containing raw license assignment and entitlement information

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| LICENSE_TYPE | VARCHAR(16777216) | Category of license entitlement (Basic, Pro, Enterprise, Add-on) |
| START_DATE | DATE | Date when the license becomes active and available for use |
| END_DATE | DATE | Date when the license expires and is no longer valid |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last modified or updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the license data originated |

## 3. Audit Table Design

### 3.1 Bz_Audit_Log
**Description**: Comprehensive audit table tracking all data processing activities across Bronze layer tables

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| RECORD_ID | VARCHAR(16777216) | Unique identifier for each audit log entry |
| SOURCE_TABLE | VARCHAR(16777216) | Name of the Bronze layer table being processed |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the data processing operation began |
| PROCESSED_BY | VARCHAR(16777216) | Identifier of the system, process, or user that performed the operation |
| PROCESSING_TIME | NUMBER(10,2) | Duration in seconds required to complete the processing operation |
| STATUS | VARCHAR(16777216) | Result status of the processing operation (SUCCESS, FAILED, PARTIAL, RETRY) |

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
         │ (Connected via User Reference)
         │
         ▼
┌─────────────────┐       ┌─────────────────┐
│   Bz_Meetings   │◄──────┤ Bz_Participants │
│                 │       │                 │
│ - MEETING_TOPIC │       │ - JOIN_TIME     │
│ - START_TIME    │       │ - LEAVE_TIME    │
│ - END_TIME      │       └─────────────────┘
│ - DURATION_MIN  │       (Connected via Meeting Reference)
└─────────────────┘
         │
         │ (Connected via Meeting Reference)
         │
         ▼
┌─────────────────┐
│Bz_Feature_Usage │
│                 │
│ - FEATURE_NAME  │
│ - USAGE_COUNT   │
│ - USAGE_DATE    │
└─────────────────┘

┌─────────────────┐
│   Bz_Users      │
└─────────────────┘
         │
         │ (Connected via User Reference)
         │
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
└─────────────────┘
         │
         │ (Connected via User Reference)
         │
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
└─────────────────┘
         │
         │ (Connected via Assigned User Reference)
         │
         ▼
┌─────────────────┐
│   Bz_Licenses   │
│                 │
│ - LICENSE_TYPE  │
│ - START_DATE    │
│ - END_DATE      │
└─────────────────┘
```

### 4.2 Relationship Summary

1. **Bz_Users → Bz_Meetings**: One-to-Many relationship via Host User Reference
2. **Bz_Meetings → Bz_Participants**: One-to-Many relationship via Meeting Reference
3. **Bz_Meetings → Bz_Feature_Usage**: One-to-Many relationship via Meeting Reference
4. **Bz_Users → Bz_Support_Tickets**: One-to-Many relationship via User Reference
5. **Bz_Users → Bz_Billing_Events**: One-to-Many relationship via User Reference
6. **Bz_Users → Bz_Licenses**: One-to-Many relationship via Assigned User Reference
7. **Bz_Users → Bz_Participants**: One-to-Many relationship via Attendee User Reference

## 5. Design Rationale and Assumptions

### 5.1 Key Design Decisions

1. **Naming Convention**: All Bronze layer tables use 'Bz_' prefix to clearly identify the medallion architecture layer
2. **Data Preservation**: All source data fields are preserved exactly as received, maintaining data lineage and traceability
3. **Metadata Enrichment**: Standard metadata columns (LOAD_TIMESTAMP, UPDATE_TIMESTAMP, SOURCE_SYSTEM) added to all tables for operational tracking
4. **PII Classification**: Implemented comprehensive PII identification to support data governance and compliance requirements
5. **Audit Framework**: Dedicated audit table designed to track all processing activities for monitoring and troubleshooting

### 5.2 Assumptions Made

1. **Source System Reliability**: Assumed that source systems provide consistent data formats and structures
2. **Data Volume**: Designed for scalable data volumes typical of enterprise video conferencing platforms
3. **Processing Frequency**: Model supports both batch and real-time data ingestion patterns
4. **Compliance Requirements**: PII classification follows GDPR and common data protection standards
5. **Relationship Integrity**: Assumed that referential relationships exist in source systems even though foreign keys are not explicitly maintained in Bronze layer

---

**Output URL**: https://github.com/ZoomAscendion/Zoom/tree/Agent_Output/Bronze_DataModel_Mapping_Workbench
**Pipeline ID**: 8285