_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze layer logical data model for Zoom Platform Analytics System supporting medallion architecture
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Bronze Layer Logical Data Model - Zoom Platform Analytics System

## 1. PII Classification

### 1.1 Identified PII Fields

| **Table Name** | **Column Name** | **PII Classification** | **Reason for PII Classification** |
|----------------|-----------------|------------------------|-----------------------------------|
| Bz_Users | USER_NAME | **High Sensitivity PII** | Contains personal identifiable information - individual's full name that can directly identify a person |
| Bz_Users | EMAIL | **High Sensitivity PII** | Email addresses are direct personal identifiers and can be used to contact individuals, regulated under GDPR and other privacy laws |
| Bz_Users | COMPANY | **Medium Sensitivity PII** | Company affiliation can be used to identify individuals in smaller organizations or specific roles |
| Bz_Meetings | MEETING_TOPIC | **Low Sensitivity PII** | Meeting topics may contain sensitive business information or personal references that could identify participants |
| Bz_Support_Tickets | TICKET_TYPE | **Low Sensitivity PII** | Support ticket types may reveal personal issues or business-sensitive information about users |

## 2. Bronze Layer Logical Model

### 2.1 Bz_Users
**Description**: Stores user account information and subscription details for the Zoom platform

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| USER_NAME | VARCHAR(16777216) | Display name of the user for identification and communication purposes |
| EMAIL | VARCHAR(16777216) | User's email address used for login authentication and communication |
| COMPANY | VARCHAR(16777216) | Company or organization name associated with the user account |
| PLAN_TYPE | VARCHAR(16777216) | Subscription plan type indicating service level (Basic, Pro, Business, Enterprise) |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system identifier from which the data originated |

### 2.2 Bz_Meetings
**Description**: Contains meeting session information including timing, duration, and host details

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| MEETING_TOPIC | VARCHAR(16777216) | Topic or title of the meeting session for identification purposes |
| START_TIME | TIMESTAMP_NTZ(9) | Timestamp indicating when the meeting session began |
| END_TIME | TIMESTAMP_NTZ(9) | Timestamp indicating when the meeting session concluded |
| DURATION_MINUTES | NUMBER(38,0) | Total duration of the meeting session measured in minutes |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system identifier from which the data originated |

### 2.3 Bz_Participants
**Description**: Tracks meeting participants and their session engagement metrics

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| JOIN_TIME | TIMESTAMP_NTZ(9) | Timestamp when the participant joined the meeting session |
| LEAVE_TIME | TIMESTAMP_NTZ(9) | Timestamp when the participant left the meeting session |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system identifier from which the data originated |

### 2.4 Bz_Feature_Usage
**Description**: Records usage statistics for platform features during meetings

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| FEATURE_NAME | VARCHAR(16777216) | Name of the specific platform feature being tracked (Screen Share, Recording, Chat, etc.) |
| USAGE_COUNT | NUMBER(38,0) | Number of times the feature was utilized during the session |
| USAGE_DATE | DATE | Date when the feature usage occurred |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system identifier from which the data originated |

### 2.5 Bz_Support_Tickets
**Description**: Manages customer support requests and their resolution tracking

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| TICKET_TYPE | VARCHAR(16777216) | Category of support request (Technical, Billing, Feature Request, etc.) |
| RESOLUTION_STATUS | VARCHAR(16777216) | Current status of the support ticket (Open, In Progress, Resolved, Closed) |
| OPEN_DATE | DATE | Date when the support ticket was initially created |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system identifier from which the data originated |

### 2.6 Bz_Billing_Events
**Description**: Tracks financial transactions and billing activities for user accounts

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| EVENT_TYPE | VARCHAR(16777216) | Type of billing transaction (Subscription, Upgrade, Refund, Usage, etc.) |
| AMOUNT | NUMBER(10,2) | Monetary value of the billing transaction |
| EVENT_DATE | DATE | Date when the billing event occurred |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system identifier from which the data originated |

### 2.7 Bz_Licenses
**Description**: Manages license assignments and entitlements for platform users

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| LICENSE_TYPE | VARCHAR(16777216) | Category of license (Basic, Pro, Enterprise, Add-on) |
| START_DATE | DATE | Date when the license becomes active and valid |
| END_DATE | DATE | Date when the license expires and becomes invalid |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system identifier from which the data originated |

## 3. Audit Table Design

### 3.1 Bz_Audit_Log
**Description**: Comprehensive audit trail for tracking data processing activities across all Bronze layer tables

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| RECORD_ID | VARCHAR(16777216) | Unique identifier for each audit log entry |
| SOURCE_TABLE | VARCHAR(16777216) | Name of the Bronze layer table being audited |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the data processing operation occurred |
| PROCESSED_BY | VARCHAR(16777216) | Identifier of the system or process that performed the operation |
| PROCESSING_TIME | NUMBER(10,3) | Duration in seconds taken to complete the processing operation |
| STATUS | VARCHAR(16777216) | Status of the processing operation (SUCCESS, FAILED, PARTIAL, RETRY) |
| RECORD_COUNT | NUMBER(38,0) | Number of records processed in the operation |
| ERROR_MESSAGE | VARCHAR(16777216) | Detailed error message if processing failed |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system identifier from which the data originated |

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
┌─────────────────┐
│   Bz_Meetings   │
│                 │
│ - MEETING_TOPIC │
│ - START_TIME    │
│ - END_TIME      │
│ - DURATION_MIN  │
└─────────────────┘
         │
         │ (Meeting Reference)
         ▼
┌─────────────────┐
│ Bz_Participants │
│                 │
│ - JOIN_TIME     │
│ - LEAVE_TIME    │
└─────────────────┘

┌─────────────────┐
│   Bz_Meetings   │
└─────────────────┘
         │
         │ (Meeting Reference)
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

┌─────────────────┐
│   Bz_Users      │
└─────────────────┘
         │
         │ (Attendee User Reference)
         ▼
┌─────────────────┐
│ Bz_Participants │
└─────────────────┘
```

### 4.2 Relationship Details

1. **Bz_Users → Bz_Meetings**: One-to-Many relationship via Host User Reference
   - One user can host multiple meetings
   - Connection Key: User identifier linking host to meetings

2. **Bz_Meetings → Bz_Participants**: One-to-Many relationship via Meeting Reference
   - One meeting can have multiple participants
   - Connection Key: Meeting identifier linking sessions to attendees

3. **Bz_Meetings → Bz_Feature_Usage**: One-to-Many relationship via Meeting Reference
   - One meeting can have multiple feature usage records
   - Connection Key: Meeting identifier linking sessions to feature utilization

4. **Bz_Users → Bz_Support_Tickets**: One-to-Many relationship via User Reference
   - One user can create multiple support tickets
   - Connection Key: User identifier linking accounts to support requests

5. **Bz_Users → Bz_Billing_Events**: One-to-Many relationship via User Reference
   - One user can have multiple billing events
   - Connection Key: User identifier linking accounts to financial transactions

6. **Bz_Users → Bz_Licenses**: One-to-Many relationship via Assigned User Reference
   - One user can be assigned multiple licenses
   - Connection Key: User identifier linking accounts to license entitlements

7. **Bz_Users → Bz_Participants**: One-to-Many relationship via Attendee User Reference
   - One user can participate in multiple meetings
   - Connection Key: User identifier linking accounts to meeting participation

## 5. Design Rationale and Assumptions

### 5.1 Key Design Decisions

1. **Naming Convention**: All Bronze layer tables use 'Bz_' prefix to clearly identify the medallion architecture layer

2. **Primary/Foreign Key Exclusion**: Following Bronze layer principles, primary and foreign key fields are excluded to maintain raw data structure while adding metadata

3. **Metadata Standardization**: All tables include consistent metadata columns (LOAD_TIMESTAMP, UPDATE_TIMESTAMP, SOURCE_SYSTEM) for data lineage and auditing

4. **PII Classification**: Implemented comprehensive PII identification based on GDPR and privacy regulations to ensure compliance

5. **Audit Trail**: Dedicated audit table provides comprehensive tracking of all data processing activities

### 5.2 Assumptions Made

1. **Data Volume**: Assumed high-volume data processing requiring efficient timestamp-based tracking

2. **Source Systems**: Multiple source systems may feed into Bronze layer, requiring source system identification

3. **Processing Patterns**: Batch and real-time processing patterns supported through flexible timestamp fields

4. **Compliance Requirements**: GDPR and similar privacy regulations apply, requiring PII classification and protection

5. **Scalability**: Design supports horizontal scaling through partitioning on timestamp fields

6. **Data Quality**: Bronze layer maintains raw data fidelity while adding essential metadata for downstream processing