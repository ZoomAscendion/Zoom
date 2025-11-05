_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze Layer Logical Data Model for Zoom Platform Analytics System supporting medallion architecture data processing
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Bronze Layer Logical Data Model - Zoom Platform Analytics System

## 1. PII Classification

### 1.1 Column Names with PII Classification

| **Column Name** | **Table** | **PII Classification** | **Reason for PII Classification** |
|-----------------|-----------|------------------------|------------------------------------|
| USER_NAME | Bz_Users | Sensitive PII | Contains personal names that directly identify individuals |
| EMAIL | Bz_Users | Sensitive PII | Email addresses are unique personal identifiers that can be used to contact and identify individuals |
| COMPANY | Bz_Users | Sensitive PII | Company affiliation can be used to profile and identify individuals, especially in smaller organizations |
| MEETING_TOPIC | Bz_Meetings | Potentially Sensitive | Meeting topics may contain confidential business information or personal details |

## 2. Bronze Layer Logical Model

### 2.1 Table: Bz_Users
**Description:** Master table containing user account information including personal details and subscription plans, mirroring the source USERS table structure.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| USER_NAME | VARCHAR(16777216) | Display name of the user account |
| EMAIL | VARCHAR(16777216) | Email address associated with the user account (Unique identifier) |
| COMPANY | VARCHAR(16777216) | Company or organization the user is affiliated with |
| PLAN_TYPE | VARCHAR(16777216) | Subscription plan type for the user (Basic, Pro, Business, Enterprise, Education) |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the system |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated |

### 2.2 Table: Bz_Meetings
**Description:** Core table containing meeting information including scheduling, duration, and host details, mirroring the source MEETINGS table structure.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| MEETING_TOPIC | VARCHAR(16777216) | Subject or topic of the meeting |
| START_TIME | TIMESTAMP_NTZ(9) | Timestamp when the meeting started |
| END_TIME | TIMESTAMP_NTZ(9) | Timestamp when the meeting ended |
| DURATION_MINUTES | NUMBER(38,0) | Total duration of the meeting in minutes |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the system |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated |

### 2.3 Table: Bz_Participants
**Description:** Tracks individual participants in meetings including join/leave times and user details, mirroring the source PARTICIPANTS table structure.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| JOIN_TIME | TIMESTAMP_NTZ(9) | Timestamp when the participant joined the meeting |
| LEAVE_TIME | TIMESTAMP_NTZ(9) | Timestamp when the participant left the meeting |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the system |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated |

### 2.4 Table: Bz_Feature_Usage
**Description:** Tracks usage of various Zoom features during meetings and sessions, mirroring the source FEATURE_USAGE table structure.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| FEATURE_NAME | VARCHAR(16777216) | Name of the Zoom feature that was used (screen_share, recording, chat, breakout_rooms, whiteboard) |
| USAGE_COUNT | NUMBER(38,0) | Number of times the feature was used in the meeting |
| USAGE_DATE | DATE | Date when the feature usage occurred |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the system |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated |

### 2.5 Table: Bz_Support_Tickets
**Description:** Contains customer support ticket information including ticket types, status, and resolution details, mirroring the source SUPPORT_TICKETS table structure.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| TICKET_TYPE | VARCHAR(16777216) | Category or type of the support ticket (technical_issue, billing_inquiry, feature_request, account_access) |
| RESOLUTION_STATUS | VARCHAR(16777216) | Current status of the support ticket resolution (open, in_progress, resolved, closed, escalated) |
| OPEN_DATE | DATE | Date when the support ticket was created |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the system |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated |

### 2.6 Table: Bz_Billing_Events
**Description:** Contains billing event information for Zoom services including charges, credits, and payment transactions, mirroring the source BILLING_EVENTS table structure.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| EVENT_TYPE | VARCHAR(16777216) | Type of billing event (charge, credit, refund, adjustment) |
| AMOUNT | NUMBER(10,2) | Monetary amount of the billing event |
| EVENT_DATE | DATE | Date when the billing event occurred |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the system |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated |

### 2.7 Table: Bz_Licenses
**Description:** Contains information about Zoom licenses assigned to users including license types and validity periods, mirroring the source LICENSES table structure.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| LICENSE_TYPE | VARCHAR(16777216) | Type of Zoom license (Basic, Pro, Business, Enterprise, Education) |
| START_DATE | DATE | Date when the license becomes active |
| END_DATE | DATE | Date when the license expires |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the system |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated |

## 3. Audit Table Design

### 3.1 Table: Bz_Audit_Log
**Description:** Tracks data ingestion and processing activities across all Bronze layer tables.

| **Field Name** | **Data Type** | **Description** |
|----------------|---------------|------------------|
| record_id | VARCHAR(50) | Unique identifier for each audit record |
| source_table | VARCHAR(100) | Name of the source table being processed |
| load_timestamp | TIMESTAMP_NTZ(9) | Timestamp when the data loading process started |
| processed_by | VARCHAR(100) | Identifier of the process, job, or user performing the data processing |
| processing_time | NUMBER(10,2) | Duration taken to process the data in seconds |
| status | VARCHAR(50) | Status of the processing operation (SUCCESS, FAILED, IN_PROGRESS, WARNING) |

## 4. Conceptual Data Model Diagram

### 4.1 Block Diagram Format - Table Relationships

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Bz_Users      │    │   Bz_Meetings   │    │  Bz_Licenses    │
│                 │    │                 │    │                 │
│ • USER_NAME     │◄───┤ • MEETING_TOPIC │    │ • LICENSE_TYPE  │
│ • EMAIL         │    │ • START_TIME    │    │ • START_DATE    │
│ • COMPANY       │    │ • END_TIME      │    │ • END_DATE      │
│ • PLAN_TYPE     │    │ • DURATION_MIN  │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         │              ┌─────────────────┐              │
         │              │ Bz_Participants │              │
         └──────────────┤                 │              │
                        │ • JOIN_TIME     │              │
                        │ • LEAVE_TIME    │              │
                        └─────────────────┘              │
                                 │                       │
                                 │                       │
         ┌─────────────────┐    │    ┌─────────────────┐ │
         │Bz_Feature_Usage │    │    │Bz_Support_Tickets│ │
         │                 │    │    │                 │ │
         │ • FEATURE_NAME  │◄───┘    │ • TICKET_TYPE   │◄┘
         │ • USAGE_COUNT   │         │ • RESOLUTION_ST │
         │ • USAGE_DATE    │         │ • OPEN_DATE     │
         └─────────────────┘         └─────────────────┘
                                              │
                                              │
                                    ┌─────────────────┐
                                    │ Bz_Billing_Events│
                                    │                 │
                                    │ • EVENT_TYPE    │
                                    │ • AMOUNT        │
                                    │ • EVENT_DATE    │
                                    └─────────────────┘
```

### 4.2 Relationship Descriptions

1. **Bz_Users ↔ Bz_Meetings**: Users host meetings (One-to-Many relationship via conceptual HOST_ID reference)
2. **Bz_Meetings ↔ Bz_Participants**: Meetings have multiple participants (One-to-Many relationship via conceptual MEETING_ID reference)
3. **Bz_Users ↔ Bz_Participants**: Users participate in meetings (One-to-Many relationship via conceptual USER_ID reference)
4. **Bz_Meetings ↔ Bz_Feature_Usage**: Features are used during meetings (One-to-Many relationship via conceptual MEETING_ID reference)
5. **Bz_Users ↔ Bz_Support_Tickets**: Users create support tickets (One-to-Many relationship via conceptual USER_ID reference)
6. **Bz_Users ↔ Bz_Billing_Events**: Users have billing events (One-to-Many relationship via conceptual USER_ID reference)
7. **Bz_Users ↔ Bz_Licenses**: Users are assigned licenses (One-to-Many relationship via conceptual ASSIGNED_TO_USER_ID reference)

**Note:** In the Bronze layer, primary and foreign key fields are removed as per medallion architecture principles, but logical relationships are maintained through the conceptual model for downstream Silver and Gold layer processing.