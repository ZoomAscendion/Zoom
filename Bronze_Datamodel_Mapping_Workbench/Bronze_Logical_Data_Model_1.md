_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze layer logical data model for Zoom Platform Analytics System supporting medallion architecture
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Bronze Layer Logical Data Model - Zoom Platform Analytics System

## 1. PII Classification

### 1.1 PII Fields Identification

| **Table Name** | **Column Name** | **PII Classification** | **Reason for PII Classification** |
|----------------|-----------------|------------------------|-----------------------------------|
| Bz_Users | USER_NAME | **Sensitive PII** | Contains personal identifiable information - individual's full name that can directly identify a person |
| Bz_Users | EMAIL | **Sensitive PII** | Email addresses are direct personal identifiers and can be used to contact or identify individuals |
| Bz_Users | COMPANY | **Non-Sensitive PII** | Company information can indirectly identify individuals, especially in small organizations |
| Bz_Participants | USER_NAME | **Sensitive PII** | Contains personal identifiable information - participant's name that can directly identify a person |
| Bz_Support_Tickets | USER_NAME | **Sensitive PII** | Contains personal identifiable information - ticket creator's name for identification purposes |
| Bz_Licenses | ASSIGNED_USER_NAME | **Sensitive PII** | Contains personal identifiable information - name of user assigned to license |

## 2. Bronze Layer Logical Model

### 2.1 Table: Bz_Users
**Description**: Stores user profile information and subscription details for Zoom platform users

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| USER_NAME | VARCHAR(16777216) | Display name of the user for identification purposes |
| EMAIL | VARCHAR(16777216) | Email address of the user for communication and login |
| COMPANY | VARCHAR(16777216) | Company or organization name associated with the user |
| PLAN_TYPE | VARCHAR(16777216) | Subscription plan type (Basic, Pro, Business, Enterprise) |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the user data originated |

### 2.2 Table: Bz_Meetings
**Description**: Contains information about video meetings conducted on the Zoom platform

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| MEETING_TOPIC | VARCHAR(16777216) | Topic or title of the meeting for identification |
| START_TIME | TIMESTAMP_NTZ(9) | Meeting start timestamp indicating when meeting began |
| END_TIME | TIMESTAMP_NTZ(9) | Meeting end timestamp indicating when meeting concluded |
| DURATION_MINUTES | NUMBER(38,0) | Meeting duration in minutes for usage analysis |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the meeting data originated |

### 2.3 Table: Bz_Participants
**Description**: Tracks participants who join meetings, linking users to specific meeting sessions

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| JOIN_TIME | TIMESTAMP_NTZ(9) | Timestamp when participant joined the meeting |
| LEAVE_TIME | TIMESTAMP_NTZ(9) | Timestamp when participant left the meeting |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the participant data originated |

### 2.4 Table: Bz_Feature_Usage
**Description**: Records usage of specific platform features during meetings for feature adoption analysis

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| FEATURE_NAME | VARCHAR(16777216) | Name of the feature being tracked (Screen Share, Recording, Chat, etc.) |
| USAGE_COUNT | NUMBER(38,0) | Number of times the feature was utilized during the session |
| USAGE_DATE | DATE | Date when feature usage occurred for temporal analysis |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the feature usage data originated |

### 2.5 Table: Bz_Support_Tickets
**Description**: Manages customer support requests and their resolution process for service quality tracking

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| TICKET_TYPE | VARCHAR(16777216) | Type of support ticket (Technical, Billing, Feature Request, etc.) |
| RESOLUTION_STATUS | VARCHAR(16777216) | Current status of ticket resolution (Open, In Progress, Resolved, Closed) |
| OPEN_DATE | DATE | Date when the support ticket was created |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the support ticket data originated |

### 2.6 Table: Bz_Billing_Events
**Description**: Tracks all financial transactions and billing activities for revenue analysis

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| EVENT_TYPE | VARCHAR(16777216) | Type of billing event (Subscription, Upgrade, Refund, etc.) |
| AMOUNT | NUMBER(10,2) | Monetary amount for the billing event in the specified currency |
| EVENT_DATE | DATE | Date when the billing event occurred for financial reporting |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the billing event data originated |

### 2.7 Table: Bz_Licenses
**Description**: Manages license assignments and entitlements for users to track license utilization

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| LICENSE_TYPE | VARCHAR(16777216) | Type of license (Basic, Pro, Enterprise, Add-on) |
| START_DATE | DATE | Date when the license becomes active for the user |
| END_DATE | DATE | Date when the license expires for renewal tracking |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the license data originated |

## 3. Audit Table Design

### 3.1 Table: Bz_Audit_Log
**Description**: Comprehensive audit trail for tracking all data processing activities in the Bronze layer

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| RECORD_ID | VARCHAR(16777216) | Unique identifier for each audit record |
| SOURCE_TABLE | VARCHAR(16777216) | Name of the source table being processed |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the data processing operation began |
| PROCESSED_BY | VARCHAR(16777216) | System or process identifier that performed the operation |
| PROCESSING_TIME | NUMBER(10,2) | Duration of processing operation in seconds |
| STATUS | VARCHAR(50) | Status of the processing operation (SUCCESS, FAILED, PARTIAL) |
| ERROR_MESSAGE | VARCHAR(16777216) | Detailed error message if processing failed |
| RECORDS_PROCESSED | NUMBER(38,0) | Number of records processed in the operation |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the audit data originated |

## 4. Conceptual Data Model Diagram

### 4.1 Entity Relationship Block Diagram

```
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│   Bz_Users      │──────▶│   Bz_Meetings   │──────▶│ Bz_Participants │
│                 │       │                 │       │                 │
│ - USER_NAME     │       │ - MEETING_TOPIC │       │ - JOIN_TIME     │
│ - EMAIL         │       │ - START_TIME    │       │ - LEAVE_TIME    │
│ - COMPANY       │       │ - END_TIME      │       │                 │
│ - PLAN_TYPE     │       │ - DURATION_MIN  │       │                 │
└─────────────────┘       └─────────────────┘       └─────────────────┘
         │                         │
         │                         │
         ▼                         ▼
┌─────────────────┐       ┌─────────────────┐
│Bz_Support_Tickets│       │ Bz_Feature_Usage│
│                 │       │                 │
│ - TICKET_TYPE   │       │ - FEATURE_NAME  │
│ - RESOLUTION_ST │       │ - USAGE_COUNT   │
│ - OPEN_DATE     │       │ - USAGE_DATE    │
└─────────────────┘       └─────────────────┘
         │
         ▼
┌─────────────────┐       ┌─────────────────┐
│Bz_Billing_Events│       │   Bz_Licenses   │
│                 │       │                 │
│ - EVENT_TYPE    │       │ - LICENSE_TYPE  │
│ - AMOUNT        │◀──────│ - START_DATE    │
│ - EVENT_DATE    │       │ - END_DATE      │
└─────────────────┘       └─────────────────┘
```

### 4.2 Table Relationships

1. **Bz_Users → Bz_Meetings**: Connected through user reference (host relationship)
2. **Bz_Meetings → Bz_Participants**: Connected through meeting reference (attendance relationship)
3. **Bz_Meetings → Bz_Feature_Usage**: Connected through meeting reference (feature utilization relationship)
4. **Bz_Users → Bz_Support_Tickets**: Connected through user reference (ticket ownership relationship)
5. **Bz_Users → Bz_Billing_Events**: Connected through user reference (billing relationship)
6. **Bz_Users → Bz_Licenses**: Connected through user reference (license assignment relationship)
7. **Bz_Users → Bz_Participants**: Connected through user reference (participation relationship)

## 5. Design Rationale and Assumptions

### 5.1 Key Design Decisions

1. **Naming Convention**: All Bronze layer tables use 'Bz_' prefix to clearly identify them as Bronze layer entities
2. **Data Preservation**: All source data fields are preserved except primary and foreign key fields to maintain raw data integrity
3. **Metadata Columns**: Consistent metadata columns (LOAD_TIMESTAMP, UPDATE_TIMESTAMP, SOURCE_SYSTEM) across all tables for data lineage
4. **PII Classification**: Implemented comprehensive PII identification for compliance with data privacy regulations
5. **Audit Trail**: Dedicated audit table to track all data processing operations for governance and troubleshooting

### 5.2 Assumptions Made

1. **Data Types**: Maintained original data types from source schema to preserve data fidelity
2. **Business Logic**: No business transformations applied in Bronze layer, maintaining raw data state
3. **Relationships**: Logical relationships inferred from conceptual model and source schema structure
4. **Compliance**: PII classification based on GDPR and common data privacy standards
5. **Scalability**: Design supports high-volume data ingestion with timestamp-based tracking

### 5.3 Bronze Layer Characteristics

1. **Raw Data Storage**: Maintains source data structure with minimal transformation
2. **Schema Flexibility**: Accommodates varying source data formats and structures
3. **Data Lineage**: Complete traceability through metadata columns and audit logging
4. **Incremental Loading**: Supports both full and incremental data loading patterns
5. **Data Quality**: Foundation for downstream Silver layer data quality improvements