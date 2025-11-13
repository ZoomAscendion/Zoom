_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze layer logical data model for Zoom Platform Analytics System supporting usage, reliability, and revenue reporting
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Bronze Layer Logical Data Model - Zoom Platform Analytics System

## 1. PII Classification

### 1.1 PII Fields Identified

| **Table Name** | **Column Name** | **PII Classification** | **Reason for PII Classification** |
|----------------|-----------------|------------------------|-----------------------------------|
| Bz_Users | USER_NAME | **Sensitive PII** | Contains personal identifiable information - individual's full name that can directly identify a person |
| Bz_Users | EMAIL | **Sensitive PII** | Email addresses are direct personal identifiers that can be used to contact and identify individuals |
| Bz_Users | COMPANY | **Non-Sensitive PII** | Company information can indirectly identify individuals, especially in small organizations |
| Bz_Meetings | MEETING_TOPIC | **Potentially Sensitive** | Meeting topics may contain confidential business information or personal details |
| Bz_Support_Tickets | TICKET_TYPE | **Non-Sensitive PII** | Ticket types may reveal user behavior patterns and preferences |
| Bz_Support_Tickets | RESOLUTION_STATUS | **Non-Sensitive PII** | Status information may reveal user experience and service quality patterns |
| Bz_Billing_Events | AMOUNT | **Sensitive PII** | Financial information that can reveal personal spending patterns and economic status |
| Bz_Billing_Events | EVENT_TYPE | **Non-Sensitive PII** | Billing event types may reveal user subscription and usage patterns |

## 2. Bronze Layer Logical Model

### 2.1 Bz_Users
**Description**: Contains user profile information and subscription details for Zoom platform users

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| USER_NAME | VARCHAR(16777216) | Display name of the user for identification and personalization |
| EMAIL | VARCHAR(16777216) | Email address of the user for communication and account management |
| COMPANY | VARCHAR(16777216) | Company or organization name associated with the user account |
| PLAN_TYPE | VARCHAR(16777216) | Subscription plan type indicating service level (Basic, Pro, Business, Enterprise) |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the user data originated |

### 2.2 Bz_Meetings
**Description**: Contains information about video meetings conducted on the Zoom platform

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| MEETING_TOPIC | VARCHAR(16777216) | Topic or title of the meeting for identification and categorization |
| START_TIME | TIMESTAMP_NTZ(9) | Meeting start timestamp for duration calculation and scheduling analysis |
| END_TIME | TIMESTAMP_NTZ(9) | Meeting end timestamp for duration calculation and usage tracking |
| DURATION_MINUTES | NUMBER(38,0) | Meeting duration in minutes for usage analytics and reporting |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the meeting data originated |

### 2.3 Bz_Participants
**Description**: Tracks participants who join meetings, linking users to specific meeting sessions

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| JOIN_TIME | TIMESTAMP_NTZ(9) | Timestamp when participant joined the meeting for attendance tracking |
| LEAVE_TIME | TIMESTAMP_NTZ(9) | Timestamp when participant left the meeting for engagement analysis |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the participant data originated |

### 2.4 Bz_Feature_Usage
**Description**: Records usage of specific platform features during meetings for feature adoption analysis

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| FEATURE_NAME | VARCHAR(16777216) | Name of the feature being tracked (Screen Share, Recording, Chat, etc.) |
| USAGE_COUNT | NUMBER(38,0) | Number of times the feature was used during the session |
| USAGE_DATE | DATE | Date when feature usage occurred for temporal analysis |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the feature usage data originated |

### 2.5 Bz_Support_Tickets
**Description**: Manages customer support requests and their resolution process for service quality tracking

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| TICKET_TYPE | VARCHAR(16777216) | Type of support ticket (Technical, Billing, Feature Request, etc.) |
| RESOLUTION_STATUS | VARCHAR(16777216) | Current status of ticket resolution (Open, In Progress, Resolved, Closed) |
| OPEN_DATE | DATE | Date when the support ticket was created for resolution time analysis |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the support ticket data originated |

### 2.6 Bz_Billing_Events
**Description**: Tracks all financial transactions and billing activities for revenue analysis

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| EVENT_TYPE | VARCHAR(16777216) | Type of billing event (Subscription, Upgrade, Refund, Usage, etc.) |
| AMOUNT | NUMBER(10,2) | Monetary amount for the billing event in the specified currency |
| EVENT_DATE | DATE | Date when the billing event occurred for financial reporting |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the billing event data originated |

### 2.7 Bz_Licenses
**Description**: Manages license assignments and entitlements for users to track license utilization

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| LICENSE_TYPE | VARCHAR(16777216) | Type of license (Basic, Pro, Enterprise, Add-on) indicating service level |
| START_DATE | DATE | Date when the license becomes active for validity tracking |
| END_DATE | DATE | Date when the license expires for renewal planning |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the license data originated |

## 3. Audit Table Design

### 3.1 Bz_Audit_Log
**Description**: Comprehensive audit trail for tracking all data processing activities in the Bronze layer

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| RECORD_ID | VARCHAR(16777216) | Unique identifier for each audit record |
| SOURCE_TABLE | VARCHAR(16777216) | Name of the source table being processed |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the data processing operation began |
| PROCESSED_BY | VARCHAR(16777216) | System or user identifier that performed the processing |
| PROCESSING_TIME | NUMBER(10,2) | Time taken to process the operation in seconds |
| STATUS | VARCHAR(50) | Status of the processing operation (SUCCESS, FAILED, IN_PROGRESS) |
| ERROR_MESSAGE | VARCHAR(16777216) | Detailed error message if processing failed |
| RECORDS_PROCESSED | NUMBER(38,0) | Number of records processed in the operation |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the audit data originated |

## 4. Table Relationships

### 4.1 Relationship Documentation

| **Source Table** | **Target Table** | **Relationship Key Field** | **Relationship Type** | **Business Logic** |
|------------------|------------------|----------------------------|----------------------|--------------------|
| Bz_Users | Bz_Meetings | User Reference (via HOST_ID) | One-to-Many | One user can host multiple meetings |
| Bz_Meetings | Bz_Participants | Meeting Reference (via MEETING_ID) | One-to-Many | One meeting can have multiple participants |
| Bz_Meetings | Bz_Feature_Usage | Meeting Reference (via MEETING_ID) | One-to-Many | One meeting can have multiple feature usage records |
| Bz_Users | Bz_Support_Tickets | User Reference (via USER_ID) | One-to-Many | One user can create multiple support tickets |
| Bz_Users | Bz_Billing_Events | User Reference (via USER_ID) | One-to-Many | One user can have multiple billing events |
| Bz_Users | Bz_Licenses | User Reference (via ASSIGNED_TO_USER_ID) | One-to-Many | One user can have multiple licenses |
| Bz_Users | Bz_Participants | User Reference (via USER_ID) | One-to-Many | One user can participate in multiple meetings |

## 5. Conceptual Data Model Diagram

### 5.1 Block Diagram Representation

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
│ - DURATION_MIN  │              ▲
└─────────────────┘              │
         │                       │ (User Reference)
         │ (Meeting Reference)   │
         ▼                       │
┌─────────────────┐              │
│ Bz_Feature_Usage│              │
│                 │              │
│ - FEATURE_NAME  │              │
│ - USAGE_COUNT   │              │
│ - USAGE_DATE    │              │
└─────────────────┘              │
                                 │
┌─────────────────┐              │
│Bz_Support_Tickets│◄─────────────┘
│                 │
│ - TICKET_TYPE   │
│ - RESOLUTION_ST │
│ - OPEN_DATE     │
└─────────────────┘
         ▲
         │ (User Reference)
         │
┌─────────────────┐
│ Bz_Billing_Events│
│                 │
│ - EVENT_TYPE    │
│ - AMOUNT        │
│ - EVENT_DATE    │
└─────────────────┘
         ▲
         │ (User Reference)
         │
┌─────────────────┐
│   Bz_Licenses   │
│                 │
│ - LICENSE_TYPE  │
│ - START_DATE    │
│ - END_DATE      │
└─────────────────┘
```

### 5.2 Connection Details

1. **Bz_Users → Bz_Meetings**: Connected via User Reference (HOST_ID field)
2. **Bz_Meetings → Bz_Participants**: Connected via Meeting Reference (MEETING_ID field)
3. **Bz_Meetings → Bz_Feature_Usage**: Connected via Meeting Reference (MEETING_ID field)
4. **Bz_Users → Bz_Support_Tickets**: Connected via User Reference (USER_ID field)
5. **Bz_Users → Bz_Billing_Events**: Connected via User Reference (USER_ID field)
6. **Bz_Users → Bz_Licenses**: Connected via User Reference (ASSIGNED_TO_USER_ID field)
7. **Bz_Users → Bz_Participants**: Connected via User Reference (USER_ID field)

## 6. Design Decisions and Assumptions

### 6.1 Key Design Decisions

1. **Naming Convention**: Applied "Bz_" prefix to all table names to clearly identify Bronze layer entities
2. **Field Exclusion**: Removed all primary key and foreign key fields as per requirements, focusing on business data
3. **Metadata Inclusion**: Added standard metadata columns (LOAD_TIMESTAMP, UPDATE_TIMESTAMP, SOURCE_SYSTEM) for data lineage
4. **PII Classification**: Implemented comprehensive PII classification based on GDPR and data privacy standards
5. **Audit Trail**: Designed comprehensive audit table to track all data processing activities

### 6.2 Assumptions Made

1. **Data Types**: Maintained original data types from source schema for consistency
2. **Business Logic**: Assumed relationships based on conceptual model and common business patterns
3. **Audit Requirements**: Assumed comprehensive audit trail requirements for compliance
4. **PII Sensitivity**: Applied conservative approach to PII classification for maximum data protection
5. **Source System Tracking**: Assumed need for source system tracking for data lineage purposes

### 6.3 Rationale

1. **Bronze Layer Philosophy**: Maintained raw data structure while adding necessary metadata for processing
2. **Scalability**: Designed for horizontal scaling with proper indexing considerations
3. **Compliance**: Ensured GDPR and data privacy compliance through PII classification
4. **Auditability**: Comprehensive audit trail for regulatory compliance and troubleshooting
5. **Flexibility**: Maintained flexible schema to accommodate future source system changes