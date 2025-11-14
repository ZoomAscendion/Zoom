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
|----------------|-----------------|------------------------|------------------------------------|
| Bz_Users | USER_NAME | **Sensitive PII** | Contains personal identifiable information - individual's full name that can directly identify a person |
| Bz_Users | EMAIL | **Sensitive PII** | Email addresses are direct personal identifiers and can be used to contact or identify individuals |
| Bz_Users | COMPANY | **Non-Sensitive PII** | Company information can indirectly identify individuals, especially in small organizations |
| Bz_Meetings | MEETING_TOPIC | **Potentially Sensitive** | Meeting topics may contain confidential business information or personal details |
| Bz_Support_Tickets | TICKET_TYPE | **Non-Sensitive PII** | May reveal user behavior patterns and preferences |
| Bz_Support_Tickets | RESOLUTION_STATUS | **Non-Sensitive PII** | Combined with user data, can reveal user experience patterns |
| Bz_Participants | JOIN_TIME | **Non-Sensitive PII** | Participation timestamps can reveal user behavior and location patterns |
| Bz_Participants | LEAVE_TIME | **Non-Sensitive PII** | Participation timestamps can reveal user behavior and location patterns |

## 2. Bronze Layer Logical Model

### 2.1 Bz_Users
**Description**: Stores user profile information and subscription details for the Zoom platform

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| USER_NAME | VARCHAR(16777216) | Display name of the user for identification and communication purposes |
| EMAIL | VARCHAR(16777216) | User's email address used for login authentication and communication |
| COMPANY | VARCHAR(16777216) | Organization or company name associated with the user account |
| PLAN_TYPE | VARCHAR(16777216) | Subscription plan category (Basic, Pro, Business, Enterprise) |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last modified or updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated |

### 2.2 Bz_Meetings
**Description**: Contains comprehensive information about video meetings conducted on the Zoom platform

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| MEETING_TOPIC | VARCHAR(16777216) | Subject or title of the meeting as defined by the host |
| START_TIME | TIMESTAMP_NTZ(9) | Exact timestamp when the meeting session began |
| END_TIME | TIMESTAMP_NTZ(9) | Exact timestamp when the meeting session concluded |
| DURATION_MINUTES | NUMBER(38,0) | Total duration of the meeting calculated in minutes |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last modified or updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated |

### 2.3 Bz_Participants
**Description**: Tracks meeting participants and their engagement details for each meeting session

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| JOIN_TIME | TIMESTAMP_NTZ(9) | Exact timestamp when the participant joined the meeting |
| LEAVE_TIME | TIMESTAMP_NTZ(9) | Exact timestamp when the participant left the meeting |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last modified or updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated |

### 2.4 Bz_Feature_Usage
**Description**: Records usage statistics of specific platform features during meetings

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| FEATURE_NAME | VARCHAR(16777216) | Name of the specific feature being tracked (Screen Share, Recording, Chat, etc.) |
| USAGE_COUNT | NUMBER(38,0) | Number of times the feature was utilized during the session |
| USAGE_DATE | DATE | Date when the feature usage occurred |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last modified or updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated |

### 2.5 Bz_Support_Tickets
**Description**: Manages customer support requests and tracks their resolution lifecycle

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| TICKET_TYPE | VARCHAR(16777216) | Category of the support issue (Technical, Billing, Feature Request, etc.) |
| RESOLUTION_STATUS | VARCHAR(16777216) | Current state of the ticket (Open, In Progress, Resolved, Closed) |
| OPEN_DATE | DATE | Date when the support ticket was initially created |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last modified or updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated |

### 2.6 Bz_Billing_Events
**Description**: Tracks all financial transactions and billing activities for revenue analysis

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| EVENT_TYPE | VARCHAR(16777216) | Type of billing transaction (Subscription, Upgrade, Refund, etc.) |
| AMOUNT | NUMBER(10,2) | Monetary value of the transaction in the specified currency |
| EVENT_DATE | DATE | Date when the billing event was processed |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last modified or updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated |

### 2.7 Bz_Licenses
**Description**: Manages license assignments and entitlements for platform users

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| LICENSE_TYPE | VARCHAR(16777216) | Category of license (Basic, Pro, Enterprise, Add-on) |
| START_DATE | DATE | Date when the license becomes active and usable |
| END_DATE | DATE | Date when the license expires and becomes inactive |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last modified or updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated |

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
| STATUS | VARCHAR(50) | Status of the processing operation (SUCCESS, FAILED, PARTIAL) |
| RECORD_COUNT | NUMBER(38,0) | Number of records processed in the operation |
| ERROR_MESSAGE | VARCHAR(16777216) | Detailed error message if the operation failed |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated |

## 4. Conceptual Data Model Diagram

### 4.1 Table Relationships in Block Diagram Format

```
┌─────────────────┐
│   Bz_Users      │
│                 │
└─────────────────┘
         │
         │ (USER_NAME connects to HOST reference)
         ▼
┌─────────────────┐
│   Bz_Meetings   │
│                 │
└─────────────────┘
         │
         │ (MEETING reference)
         ▼
┌─────────────────┐
│ Bz_Participants │
│                 │
└─────────────────┘

┌─────────────────┐
│   Bz_Users      │
│                 │
└─────────────────┘
         │
         │ (USER_NAME connects to USER reference)
         ▼
┌─────────────────┐
│Bz_Support_Tickets│
│                 │
└─────────────────┘

┌─────────────────┐
│   Bz_Users      │
│                 │
└─────────────────┘
         │
         │ (USER_NAME connects to USER reference)
         ▼
┌─────────────────┐
│Bz_Billing_Events│
│                 │
└─────────────────┘

┌─────────────────┐
│   Bz_Users      │
│                 │
└─────────────────┘
         │
         │ (USER_NAME connects to ASSIGNED_USER reference)
         ▼
┌─────────────────┐
│   Bz_Licenses   │
│                 │
└─────────────────┘

┌─────────────────┐
│   Bz_Meetings   │
│                 │
└─────────────────┘
         │
         │ (MEETING reference)
         ▼
┌─────────────────┐
│Bz_Feature_Usage │
│                 │
└─────────────────┘

┌─────────────────┐
│   Bz_Users      │
│                 │
└─────────────────┘
         │
         │ (USER_NAME connects to ATTENDEE reference)
         ▼
┌─────────────────┐
│ Bz_Participants │
│                 │
└─────────────────┘
```

### 4.2 Relationship Summary

1. **Bz_Users → Bz_Meetings**: One-to-Many relationship via HOST reference field
2. **Bz_Meetings → Bz_Participants**: One-to-Many relationship via MEETING reference field
3. **Bz_Meetings → Bz_Feature_Usage**: One-to-Many relationship via MEETING reference field
4. **Bz_Users → Bz_Support_Tickets**: One-to-Many relationship via USER reference field
5. **Bz_Users → Bz_Billing_Events**: One-to-Many relationship via USER reference field
6. **Bz_Users → Bz_Licenses**: One-to-Many relationship via ASSIGNED_USER reference field
7. **Bz_Users → Bz_Participants**: One-to-Many relationship via ATTENDEE reference field

## 5. Design Rationale and Key Decisions

### 5.1 Naming Convention
- **Prefix 'Bz_'**: Applied to all Bronze layer tables to clearly identify the data layer and maintain consistency across the medallion architecture
- **Descriptive Names**: Table and column names reflect business terminology for better understanding

### 5.2 Data Structure Decisions
- **Exact Source Mirroring**: Bronze layer maintains the exact structure from source systems without transformation
- **Metadata Columns**: Added LOAD_TIMESTAMP, UPDATE_TIMESTAMP, and SOURCE_SYSTEM for data lineage and auditing
- **No Primary/Foreign Keys**: Removed key constraints as per Bronze layer principles, focusing on raw data ingestion

### 5.3 PII Handling
- **Classification Framework**: Applied GDPR-based classification for sensitive data identification
- **Documentation**: Clearly documented PII fields for downstream data governance and compliance

### 5.4 Audit Strategy
- **Comprehensive Logging**: Audit table captures all processing activities for compliance and troubleshooting
- **Performance Metrics**: Included processing time and record counts for operational monitoring

### 5.5 Assumptions Made
- Source systems provide consistent data formats
- All timestamp fields are in UTC timezone
- VARCHAR(16777216) provides sufficient storage for text fields
- Numeric precision requirements are met by specified data types