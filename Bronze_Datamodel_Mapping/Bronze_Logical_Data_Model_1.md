_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze layer logical data model for Zoom Platform Analytics System supporting medallion architecture
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Bronze Layer Logical Data Model - Zoom Platform Analytics System

## 1. PII Classification

### 1.1 PII Fields Identified

| **Column Name** | **Table** | **PII Classification** | **Reason** |
|-----------------|-----------|------------------------|------------|
| USER_NAME | Bz_Users | **Sensitive PII** | Contains personal identifiable information - individual's display name that can identify a specific person |
| EMAIL | Bz_Users | **Sensitive PII** | Email addresses are direct personal identifiers that can be used to contact and identify individuals, regulated under GDPR and other privacy laws |
| COMPANY | Bz_Users | **Non-Sensitive PII** | Company affiliation can be used in combination with other data to identify individuals, but is less sensitive than direct personal identifiers |
| MEETING_TOPIC | Bz_Meetings | **Potentially Sensitive** | Meeting topics may contain confidential business information or personal details that could identify individuals or sensitive discussions |

## 2. Bronze Layer Logical Model

### 2.1 Table: Bz_Users
**Description:** Master table containing user account information including personal details and subscription plans, mirroring source data structure for bronze layer processing.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| USER_NAME | VARCHAR(16777216) | Display name of the user account |
| EMAIL | VARCHAR(16777216) | Email address associated with the user account for communication and identification |
| COMPANY | VARCHAR(16777216) | Company or organization the user is affiliated with for business analytics |
| PLAN_TYPE | VARCHAR(16777216) | Subscription plan type for the user (Basic, Pro, Business, Enterprise, Education) |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated for data lineage tracking |

### 2.2 Table: Bz_Meetings
**Description:** Core table containing meeting information including scheduling, duration, and host details for meeting analytics and reporting.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| MEETING_TOPIC | VARCHAR(16777216) | Subject or topic of the meeting for content categorization |
| START_TIME | TIMESTAMP_NTZ(9) | Timestamp when the meeting started for scheduling analytics |
| END_TIME | TIMESTAMP_NTZ(9) | Timestamp when the meeting ended for duration calculations |
| DURATION_MINUTES | NUMBER(38,0) | Total duration of the meeting in minutes for usage analytics |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated for data lineage tracking |

### 2.3 Table: Bz_Participants
**Description:** Tracks individual participants in meetings including join/leave times and user details for attendance analytics.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| JOIN_TIME | TIMESTAMP_NTZ(9) | Timestamp when the participant joined the meeting for attendance tracking |
| LEAVE_TIME | TIMESTAMP_NTZ(9) | Timestamp when the participant left the meeting for session duration analysis |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated for data lineage tracking |

### 2.4 Table: Bz_Feature_Usage
**Description:** Tracks usage of various Zoom features during meetings and sessions for feature adoption analytics.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| FEATURE_NAME | VARCHAR(16777216) | Name of the Zoom feature that was used (screen_share, recording, chat, breakout_rooms, whiteboard) |
| USAGE_COUNT | NUMBER(38,0) | Number of times the feature was used in the meeting for usage frequency analysis |
| USAGE_DATE | DATE | Date when the feature usage occurred for temporal analytics |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated for data lineage tracking |

### 2.5 Table: Bz_Support_Tickets
**Description:** Contains customer support ticket information including ticket types, status, and resolution details for service quality analytics.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| TICKET_TYPE | VARCHAR(16777216) | Category or type of the support ticket (technical_issue, billing_inquiry, feature_request, account_access) |
| RESOLUTION_STATUS | VARCHAR(16777216) | Current status of the support ticket resolution (open, in_progress, resolved, closed, escalated) |
| OPEN_DATE | DATE | Date when the support ticket was created for resolution time analysis |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated for data lineage tracking |

### 2.6 Table: Bz_Billing_Events
**Description:** Contains billing event information for Zoom services including charges, credits, and payment transactions for revenue analytics.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| EVENT_TYPE | VARCHAR(16777216) | Type of billing event (charge, credit, refund, adjustment) for financial categorization |
| AMOUNT | NUMBER(10,2) | Monetary amount of the billing event for revenue calculations |
| EVENT_DATE | DATE | Date when the billing event occurred for financial reporting |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated for data lineage tracking |

### 2.7 Table: Bz_Licenses
**Description:** Contains information about Zoom licenses assigned to users including license types and validity periods for license management analytics.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| LICENSE_TYPE | VARCHAR(16777216) | Type of Zoom license (Basic, Pro, Business, Enterprise, Education) for license categorization |
| START_DATE | DATE | Date when the license becomes active for license lifecycle tracking |
| END_DATE | DATE | Date when the license expires for renewal planning |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated for data lineage tracking |

## 3. Audit Table Design

### 3.1 Table: Bz_Audit_Log
**Description:** Comprehensive audit table to track all data processing activities across bronze layer tables for data governance and lineage.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| RECORD_ID | VARCHAR(16777216) | Unique identifier for each audit record |
| SOURCE_TABLE | VARCHAR(16777216) | Name of the source table being processed |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the data processing occurred |
| PROCESSED_BY | VARCHAR(16777216) | System or user that processed the data |
| PROCESSING_TIME | NUMBER(10,2) | Time taken to process the data in seconds |
| STATUS | VARCHAR(50) | Status of the processing (SUCCESS, FAILED, PARTIAL) |

## 4. Conceptual Data Model Diagram

### 4.1 Entity Relationships in Block Diagram Format

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Bz_Users      │────│  Bz_Meetings    │────│ Bz_Participants │
│                 │    │                 │    │                 │
│ Connected by:   │    │ Connected by:   │    │ Connected by:   │
│ HOST_ID         │    │ MEETING_ID      │    │ USER_ID         │
│ (One-to-Many)   │    │ (One-to-Many)   │    │ (Many-to-One)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │
         │                       │
         │              ┌─────────────────┐
         │              │ Bz_Feature_Usage│
         │              │                 │
         │              │ Connected by:   │
         │              │ MEETING_ID      │
         │              │ (Many-to-One)   │
         │              └─────────────────┘
         │
         │
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│Bz_Support_Tickets│    │ Bz_Billing_Events│   │  Bz_Licenses    │
│                 │    │                 │    │                 │
│ Connected by:   │    │ Connected by:   │    │ Connected by:   │
│ USER_ID         │    │ USER_ID         │    │ASSIGNED_TO_USER │
│ (Many-to-One)   │    │ (Many-to-One)   │    │ (Many-to-One)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### 4.2 Relationship Details

1. **Bz_Users → Bz_Meetings**: One user can host multiple meetings (One-to-Many relationship via HOST_ID)
2. **Bz_Meetings → Bz_Participants**: One meeting can have multiple participants (One-to-Many relationship via MEETING_ID)
3. **Bz_Meetings → Bz_Feature_Usage**: One meeting can have multiple feature usage records (One-to-Many relationship via MEETING_ID)
4. **Bz_Users → Bz_Support_Tickets**: One user can create multiple support tickets (One-to-Many relationship via USER_ID)
5. **Bz_Users → Bz_Billing_Events**: One user can have multiple billing events (One-to-Many relationship via USER_ID)
6. **Bz_Users → Bz_Licenses**: One user can have multiple licenses over time (One-to-Many relationship via ASSIGNED_TO_USER_ID)
7. **Bz_Participants → Bz_Users**: Multiple participant records can reference the same user (Many-to-One relationship via USER_ID)

## 5. Design Rationale and Key Decisions

### 5.1 Naming Convention
- **Bronze Layer Prefix**: All tables use 'Bz_' prefix to clearly identify bronze layer tables
- **Schema Alignment**: Table names align with raw schema naming conventions (raw_schema → bronze_schema pattern)
- **Consistency**: Maintained consistent naming across all bronze layer objects

### 5.2 Data Structure Decisions
- **Source Mirroring**: Bronze layer exactly mirrors source data structure without primary/foreign key constraints
- **Metadata Inclusion**: Added standard metadata columns (LOAD_TIMESTAMP, UPDATE_TIMESTAMP, SOURCE_SYSTEM) for data lineage
- **Data Type Preservation**: Maintained original data types from source systems for data integrity

### 5.3 PII Handling
- **Classification Framework**: Applied GDPR-compliant PII classification standards
- **Sensitivity Levels**: Categorized PII into Sensitive, Non-Sensitive, and Potentially Sensitive levels
- **Documentation**: Provided clear rationale for each PII classification decision

### 5.4 Audit Strategy
- **Comprehensive Tracking**: Audit table captures all processing activities across bronze layer
- **Performance Monitoring**: Included processing time metrics for performance optimization
- **Status Tracking**: Implemented status tracking for data quality monitoring

## 6. Assumptions Made

1. **Data Volume**: Assumed moderate to high data volumes requiring scalable bronze layer design
2. **Source Systems**: Assumed multiple source systems (Zoom API, Admin systems, etc.) requiring source tracking
3. **Processing Frequency**: Assumed regular batch processing requiring comprehensive audit trails
4. **Compliance Requirements**: Assumed GDPR and similar privacy regulation compliance requirements
5. **Analytics Use Cases**: Assumed downstream silver and gold layers will require clean, well-structured data from bronze layer