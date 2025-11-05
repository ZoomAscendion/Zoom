_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze layer logical data model for Zoom Platform Analytics System following Medallion architecture standards
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Bronze Logical Data Model for Zoom Platform Analytics System

## 1. PII Classification

| **Column Name** | **Table Name** | **Reason for PII Classification** |
|-----------------|----------------|------------------------------------|
| USER_NAME | Bz_Users | Contains personal display name of the user which can identify an individual |
| EMAIL | Bz_Users | Contains personal email address which is sensitive contact information and can directly identify an individual |
| COMPANY | Bz_Users | May reveal user's employer or organizational affiliation which can be used to identify the individual |

## 2. Bronze Layer Logical Model

### 2.1 Table: Bz_Billing_Events
**Description:** Contains billing event information for Zoom services including charges, credits, and payment transactions mirrored from RAW layer

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| EVENT_TYPE | VARCHAR(16777216) | Type of billing event (charge, credit, refund, adjustment) |
| AMOUNT | NUMBER(10,2) | Monetary amount of the billing event |
| EVENT_DATE | DATE | Date when the billing event occurred |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the system |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated |

### 2.2 Table: Bz_Feature_Usage
**Description:** Tracks usage of various Zoom features during meetings and sessions mirrored from RAW layer

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| FEATURE_NAME | VARCHAR(16777216) | Name of the Zoom feature that was used (screen_share, recording, chat, breakout_rooms, whiteboard) |
| USAGE_COUNT | NUMBER(38,0) | Number of times the feature was used in the meeting |
| USAGE_DATE | DATE | Date when the feature usage occurred |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the system |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated |

### 2.3 Table: Bz_Licenses
**Description:** Contains information about Zoom licenses assigned to users including license types and validity periods mirrored from RAW layer

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| LICENSE_TYPE | VARCHAR(16777216) | Type of Zoom license (Basic, Pro, Business, Enterprise, Education) |
| START_DATE | DATE | Date when the license becomes active |
| END_DATE | DATE | Date when the license expires |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the system |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated |

### 2.4 Table: Bz_Meetings
**Description:** Core table containing meeting information including scheduling, duration, and host details mirrored from RAW layer

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| MEETING_TOPIC | VARCHAR(16777216) | Subject or topic of the meeting |
| START_TIME | TIMESTAMP_NTZ(9) | Timestamp when the meeting started |
| END_TIME | TIMESTAMP_NTZ(9) | Timestamp when the meeting ended |
| DURATION_MINUTES | NUMBER(38,0) | Total duration of the meeting in minutes |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the system |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated |

### 2.5 Table: Bz_Participants
**Description:** Tracks individual participants in meetings including join/leave times and user details mirrored from RAW layer

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| JOIN_TIME | TIMESTAMP_NTZ(9) | Timestamp when the participant joined the meeting |
| LEAVE_TIME | TIMESTAMP_NTZ(9) | Timestamp when the participant left the meeting |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the system |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated |

### 2.6 Table: Bz_Support_Tickets
**Description:** Contains customer support ticket information including ticket types, status, and resolution details mirrored from RAW layer

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| TICKET_TYPE | VARCHAR(16777216) | Category or type of the support ticket (technical_issue, billing_inquiry, feature_request, account_access) |
| RESOLUTION_STATUS | VARCHAR(16777216) | Current status of the support ticket resolution (open, in_progress, resolved, closed, escalated) |
| OPEN_DATE | DATE | Date when the support ticket was created |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the system |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated |

### 2.7 Table: Bz_Users
**Description:** Master table containing user account information including personal details and subscription plans mirrored from RAW layer

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| USER_NAME | VARCHAR(16777216) | Display name of the user |
| EMAIL | VARCHAR(16777216) | Email address of the user account |
| COMPANY | VARCHAR(16777216) | Company or organization the user is associated with |
| PLAN_TYPE | VARCHAR(16777216) | Subscription plan type for the user (Basic, Pro, Business, Enterprise, Education) |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the system |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated |

## 3. Audit Table Design

### 3.1 Table: Bz_Audit_Trail
**Description:** Tracks all data processing activities and changes in the Bronze layer for compliance and monitoring purposes

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| record_id | VARCHAR(16777216) | Unique identifier for each audit record |
| source_table | VARCHAR(16777216) | Name of the source table being processed |
| load_timestamp | TIMESTAMP_NTZ(9) | Timestamp when the record was loaded |
| processed_by | VARCHAR(16777216) | Identifier of the process or user performing the operation |
| processing_time | NUMBER(10,2) | Duration in seconds taken to process the record |
| status | VARCHAR(50) | Status of the processing (SUCCESS, FAILED, IN_PROGRESS) |

## 4. Conceptual Data Model Diagram

### 4.1 Block Diagram Format - Table Relationships

```
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│   Bz_Users      │◄──────┤   Bz_Meetings   │◄──────┤ Bz_Participants │
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
│ Bz_Support_     │       │ Bz_Feature_     │
│ Tickets         │       │ Usage           │
│                 │       │                 │
│ - TICKET_TYPE   │       │ - FEATURE_NAME  │
│ - RESOLUTION_   │       │ - USAGE_COUNT   │
│   STATUS        │       │ - USAGE_DATE    │
│ - OPEN_DATE     │       │                 │
└─────────────────┘       └─────────────────┘
         │
         │
         ▼
┌─────────────────┐       ┌─────────────────┐
│ Bz_Billing_     │       │   Bz_Licenses   │
│ Events          │       │                 │
│                 │       │ - LICENSE_TYPE  │
│ - EVENT_TYPE    │       │ - START_DATE    │
│ - AMOUNT        │       │ - END_DATE      │
│ - EVENT_DATE    │       │                 │
└─────────────────┘       └─────────────────┘
```

### 4.2 Relationship Details

| **Source Table** | **Target Table** | **Connection Field** | **Relationship Type** |
|------------------|------------------|----------------------|-----------------------|
| Bz_Users | Bz_Meetings | User Reference | One-to-Many |
| Bz_Meetings | Bz_Participants | Meeting Reference | One-to-Many |
| Bz_Meetings | Bz_Feature_Usage | Meeting Reference | One-to-Many |
| Bz_Users | Bz_Support_Tickets | User Reference | One-to-Many |
| Bz_Users | Bz_Billing_Events | User Reference | One-to-Many |
| Bz_Users | Bz_Licenses | User Reference | One-to-Many |

**Note:** In the Bronze layer, actual foreign key constraints are not implemented as this layer mirrors the raw data structure. Relationships are logical and maintained through common reference fields that would be used in downstream Silver and Gold layers.