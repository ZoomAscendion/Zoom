_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Bronze Layer Logical Data Model for Medallion Architecture
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Bronze Layer Logical Data Model

## 1. PII Classification

### 1.1 Identified PII Fields

| Table Name | Column Name | PII Classification | Reason |
|------------|-------------|-------------------|--------|
| Bz_Users | USER_NAME | PII | Contains personal identifiable name information that can identify an individual |
| Bz_Users | EMAIL | PII | Email addresses are direct personal identifiers that can be used to contact and identify individuals |
| Bz_Users | COMPANY | Sensitive | Company affiliation can be used to identify individuals in combination with other data |
| Bz_Meetings | MEETING_TOPIC | Sensitive | Meeting topics may contain confidential business information or personal discussions |
| Bz_Support_Tickets | TICKET_TYPE | Sensitive | Support ticket types may reveal personal issues or business-sensitive problems |
| Bz_Billing_Events | AMOUNT | Sensitive | Financial information that reveals spending patterns and financial status |

## 2. Bronze Layer Logical Model

### 2.1 Bz_Billing_Events
**Description**: Stores raw billing event data from source systems without transformation

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| EVENT_TYPE | Type of billing event that occurred | VARCHAR(16777216) |
| AMOUNT | Monetary amount associated with the billing event | VARCHAR(16777216) |
| EVENT_DATE | Date when the billing event occurred | DATE |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the system | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | Source system from which the data originated | VARCHAR(16777216) |

### 2.2 Bz_Feature_Usage
**Description**: Captures raw feature usage data from source systems

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| FEATURE_NAME | Name of the feature that was used | VARCHAR(16777216) |
| USAGE_COUNT | Number of times the feature was used | NUMBER(38,0) |
| USAGE_DATE | Date when the feature usage occurred | DATE |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the system | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | Source system from which the data originated | VARCHAR(16777216) |

### 2.3 Bz_Licenses
**Description**: Stores raw license information from source systems

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| LICENSE_TYPE | Type or category of the license | VARCHAR(16777216) |
| ASSIGNED_TO_USER | User to whom the license is assigned | VARCHAR(16777216) |
| START_DATE | Date when the license becomes active | DATE |
| END_DATE | Date when the license expires | VARCHAR(16777216) |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the system | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | Source system from which the data originated | VARCHAR(16777216) |

### 2.4 Bz_Meetings
**Description**: Contains raw meeting data from source systems

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| HOST | Identifier of the user hosting the meeting | VARCHAR(16777216) |
| MEETING_TOPIC | Subject or topic of the meeting | VARCHAR(16777216) |
| START_TIME | Timestamp when the meeting started | TIMESTAMP_NTZ(9) |
| END_TIME | Timestamp when the meeting ended | VARCHAR(16777216) |
| DURATION_MINUTES | Duration of the meeting in minutes | VARCHAR(16777216) |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the system | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | Source system from which the data originated | VARCHAR(16777216) |

### 2.5 Bz_Participants
**Description**: Stores raw participant data for meetings from source systems

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| PARTICIPANT | Identifier of the participating user | VARCHAR(16777216) |
| JOIN_TIME | Time when participant joined the meeting | VARCHAR(16777216) |
| LEAVE_TIME | Time when participant left the meeting | TIMESTAMP_NTZ(9) |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the system | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | Source system from which the data originated | VARCHAR(16777216) |

### 2.6 Bz_Support_Tickets
**Description**: Contains raw support ticket data from source systems

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| TICKET_TYPE | Category or type of the support ticket | VARCHAR(16777216) |
| RESOLUTION_STATUS | Current status of the ticket resolution | VARCHAR(16777216) |
| OPEN_DATE | Date when the support ticket was opened | DATE |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the system | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | Source system from which the data originated | VARCHAR(16777216) |

### 2.7 Bz_Users
**Description**: Stores raw user account data from source systems

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| USER_NAME | Display name of the user | VARCHAR(16777216) |
| EMAIL | Email address of the user | VARCHAR(16777216) |
| COMPANY | Company or organization the user belongs to | VARCHAR(16777216) |
| PLAN_TYPE | Type of subscription plan the user has | VARCHAR(16777216) |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the system | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | Source system from which the data originated | VARCHAR(16777216) |

## 3. Audit Table Design

### 3.1 Bz_Audit_Log
**Description**: Tracks data processing activities across all Bronze layer tables

| Field Name | Description | Data Type |
|------------|-------------|----------|
| RECORD_ID | Unique identifier for each audit record | VARCHAR(16777216) |
| SOURCE_TABLE | Name of the source table being processed | VARCHAR(16777216) |
| LOAD_TIMESTAMP | Timestamp when the data processing occurred | TIMESTAMP_NTZ(9) |
| PROCESSED_BY | System or process that handled the data | VARCHAR(16777216) |
| PROCESSING_TIME | Duration taken to process the data | NUMBER(38,0) |
| STATUS | Status of the processing operation (SUCCESS, FAILED, PARTIAL) | VARCHAR(16777216) |

## 4. Conceptual Data Model Diagram

### 4.1 Entity Relationships (Block Diagram Format)

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
         │
         ▼
┌─────────────────┐       ┌─────────────────┐
│ Bz_Billing_     │       │   Bz_Meetings   │
│ Events          │       │                 │
│                 │       │ - HOST          │
│ - EVENT_TYPE    │       │ - MEETING_TOPIC │
│ - AMOUNT        │       │ - START_TIME    │
│ - EVENT_DATE    │       │ - END_TIME      │
└─────────────────┘       │ - DURATION_MIN  │
                          └─────────────────┘
                                   │
                                   │ (Connected via MEETING reference)
                                   │
                                   ▼
┌─────────────────┐       ┌─────────────────┐
│ Bz_Support_     │       │ Bz_Participants │
│ Tickets         │       │                 │
│                 │       │ - PARTICIPANT   │
│ - TICKET_TYPE   │       │ - JOIN_TIME     │
│ - RESOLUTION_   │       │ - LEAVE_TIME    │
│   STATUS        │       └─────────────────┘
│ - OPEN_DATE     │                │
└─────────────────┘                │
         │                         │
         │ (Connected via USER reference)
         │                         │
         ▼                         ▼
┌─────────────────┐       ┌─────────────────┐
│ Bz_Licenses     │       │ Bz_Feature_     │
│                 │       │ Usage           │
│ - LICENSE_TYPE  │       │                 │
│ - ASSIGNED_TO_  │       │ - FEATURE_NAME  │
│   USER          │       │ - USAGE_COUNT   │
│ - START_DATE    │       │ - USAGE_DATE    │
│ - END_DATE      │       └─────────────────┘
└─────────────────┘
```

### 4.2 Key Relationships

1. **Bz_Users** connects to:
   - **Bz_Billing_Events** via USER reference field
   - **Bz_Support_Tickets** via USER reference field
   - **Bz_Licenses** via ASSIGNED_TO_USER field
   - **Bz_Meetings** via HOST field
   - **Bz_Participants** via PARTICIPANT field

2. **Bz_Meetings** connects to:
   - **Bz_Participants** via MEETING reference field
   - **Bz_Feature_Usage** via MEETING reference field

3. **Bz_Audit_Log** tracks all tables via SOURCE_TABLE field

## 5. Design Decisions and Assumptions

### 5.1 Key Design Decisions

1. **Naming Convention**: All Bronze layer tables prefixed with 'Bz_' for consistent identification
2. **Data Preservation**: All source data fields preserved except primary/foreign key fields as instructed
3. **Metadata Columns**: Standard metadata columns (LOAD_TIMESTAMP, UPDATE_TIMESTAMP, SOURCE_SYSTEM) included for data lineage
4. **PII Classification**: Implemented based on GDPR and common data privacy standards
5. **Audit Trail**: Comprehensive audit table design for tracking all data processing activities

### 5.2 Assumptions Made

1. **Source System Integration**: Assumed multiple source systems will feed into Bronze layer
2. **Data Volume**: Designed for high-volume data processing with appropriate data types
3. **Processing Patterns**: Assumed batch and real-time data ingestion patterns
4. **Compliance Requirements**: Assumed GDPR and similar data privacy regulations apply
5. **Scalability**: Designed for horizontal scaling in cloud environments

### 5.3 Rationale

1. **Bronze Layer Purpose**: Maintains raw data fidelity while adding essential metadata for downstream processing
2. **Relationship Preservation**: Logical relationships maintained through reference fields rather than formal foreign keys
3. **Flexibility**: Schema design allows for easy extension and modification as business requirements evolve
4. **Data Governance**: PII classification and audit capabilities support compliance and governance requirements