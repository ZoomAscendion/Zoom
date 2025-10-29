_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze Layer Logical Data Model for Zoom Platform Analytics System supporting medallion architecture
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Bronze Layer Logical Data Model for Zoom Platform Analytics System

## 1. PII Classification

| Column Name | Table Name | PII Classification | Reason |
|-------------|------------|-------------------|--------|
| USER_NAME | Bz_Users | PII | Contains the full name of the user which directly identifies an individual person |
| EMAIL | Bz_Users | PII | Email address is personally identifiable information that can be used to contact and identify an individual |
| COMPANY | Bz_Users | Potential PII | Company name may indirectly identify an individual, especially in small organizations |
| USER_ID | Multiple Tables | PII | User identifier that links to personal information and can be used to track individual behavior |
| HOST_ID | Bz_Meetings, Bz_Webinars | PII | References a user hosting meetings/webinars, linking to user identity |
| ASSIGNED_TO_USER_ID | Bz_Licenses | PII | Links license assignment to a specific user, enabling identification |
| PARTICIPANT_ID | Bz_Participants | PII | Identifies a participant in meetings, linked to user identity |

## 2. Bronze Layer Logical Model

### 2.1 Table: Bz_Billing_Events
**Description:** Stores billing and financial transaction events for user accounts in the bronze layer

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| EVENT_TYPE | VARCHAR(16777216) | Type of billing event (Subscription, Upgrade, Downgrade, Refund, Payment) |
| AMOUNT | NUMBER(10,2) | Monetary amount associated with the billing event |
| EVENT_DATE | DATE | Date when the billing event occurred |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which data originated |

### 2.2 Table: Bz_Feature_Usage
**Description:** Tracks utilization of specific platform features during meetings in the bronze layer

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| FEATURE_NAME | VARCHAR(16777216) | Name of the feature being tracked (Screen Share, Recording, Chat, Breakout Rooms) |
| USAGE_COUNT | NUMBER(38,0) | Number of times the feature was utilized during the meeting |
| USAGE_DATE | DATE | Date when the feature usage was recorded |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which data originated |

### 2.3 Table: Bz_Licenses
**Description:** Contains software license information assigned to users in the bronze layer

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| LICENSE_TYPE | VARCHAR(16777216) | Category of license (Basic, Pro, Business, Enterprise, Add-on) |
| START_DATE | DATE | Date when the license becomes active |
| END_DATE | DATE | Date when the license expires |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which data originated |

### 2.4 Table: Bz_Meetings
**Description:** Stores meeting session information and details in the bronze layer

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| MEETING_TOPIC | VARCHAR(16777216) | Topic or title assigned to the meeting session |
| START_TIME | TIMESTAMP_NTZ(9) | Date and time when the meeting began |
| END_TIME | TIMESTAMP_NTZ(9) | Date and time when the meeting concluded |
| DURATION_MINUTES | NUMBER(38,0) | Total length of the meeting measured in minutes |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which data originated |

### 2.5 Table: Bz_Participants
**Description:** Records participant information for meeting attendees in the bronze layer

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| JOIN_TIME | TIMESTAMP_NTZ(9) | Timestamp when the participant joined the meeting |
| LEAVE_TIME | TIMESTAMP_NTZ(9) | Timestamp when the participant left the meeting |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which data originated |

### 2.6 Table: Bz_Support_Tickets
**Description:** Contains customer service requests and support issues in the bronze layer

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| TICKET_TYPE | VARCHAR(16777216) | Category of the support request (Technical, Billing, Account, Feature Request) |
| RESOLUTION_STATUS | VARCHAR(16777216) | Current state of the ticket (Open, In Progress, Resolved, Closed) |
| OPEN_DATE | DATE | Date when the support ticket was created |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which data originated |

### 2.7 Table: Bz_Users
**Description:** Stores user account information and subscription details in the bronze layer

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| USER_NAME | VARCHAR(16777216) | Display name or full name of the user account |
| EMAIL | VARCHAR(16777216) | Primary email address associated with the user account |
| COMPANY | VARCHAR(16777216) | Organization or company name associated with the user account |
| PLAN_TYPE | VARCHAR(16777216) | Subscription tier (Free, Basic, Pro, Business, Enterprise) assigned to the user |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which data originated |

### 2.8 Table: Bz_Webinars
**Description:** Contains webinar session information and registration details in the bronze layer

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| WEBINAR_TOPIC | VARCHAR(16777216) | Topic or title assigned to the webinar session |
| START_TIME | TIMESTAMP_NTZ(9) | Date and time when the webinar began |
| END_TIME | TIMESTAMP_NTZ(9) | Date and time when the webinar concluded |
| REGISTRANTS | NUMBER(38,0) | Number of registered participants for the webinar |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which data originated |

## 3. Audit Table Design

### Table: Bz_Audit_Log
**Description:** Tracks data processing activities and maintains audit trail for bronze layer operations

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| RECORD_ID | VARCHAR(16777216) | Unique identifier for each audit record |
| SOURCE_TABLE | VARCHAR(16777216) | Name of the source table being audited |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was loaded |
| PROCESSED_BY | VARCHAR(16777216) | Identifier of the process or user that processed the record |
| PROCESSING_TIME | NUMBER(38,0) | Duration taken to process the record in milliseconds |
| STATUS | VARCHAR(16777216) | Processing status (Success, Failed, In Progress, Skipped) |

## 4. Conceptual Data Model Diagram

### Block Diagram Format:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Bz_Users      │◄──►│ Bz_Billing_Events│    │ Bz_Support_Tickets│
│                 │    │                 │    │                 │
│ Connected by:   │    │ Connected by:   │    │ Connected by:   │
│ USER_NAME       │    │ USER_ID         │    │ USER_ID         │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                                              │
         │                                              │
         ▼                                              │
┌─────────────────┐    ┌─────────────────┐             │
│   Bz_Licenses   │    │   Bz_Meetings   │             │
│                 │    │                 │             │
│ Connected by:   │    │ Connected by:   │             │
│ ASSIGNED_TO_    │    │ HOST_ID         │             │
│ USER_ID         │    │                 │             │
└─────────────────┘    └─────────────────┘             │
                                │                       │
                                ▼                       │
                       ┌─────────────────┐             │
                       │ Bz_Participants │◄────────────┘
                       │                 │
                       │ Connected by:   │
                       │ MEETING_ID &    │
                       │ USER_ID         │
                       └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │ Bz_Feature_Usage│
                       │                 │
                       │ Connected by:   │
                       │ MEETING_ID      │
                       └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │   Bz_Webinars   │
                       │                 │
                       │ Connected by:   │
                       │ HOST_ID         │
                       └─────────────────┘
```

### Relationship Descriptions:

1. **Bz_Users** connects to **Bz_Billing_Events** via USER_ID field
2. **Bz_Users** connects to **Bz_Support_Tickets** via USER_ID field  
3. **Bz_Users** connects to **Bz_Licenses** via ASSIGNED_TO_USER_ID field
4. **Bz_Users** connects to **Bz_Meetings** via HOST_ID field
5. **Bz_Users** connects to **Bz_Webinars** via HOST_ID field
6. **Bz_Meetings** connects to **Bz_Participants** via MEETING_ID field
7. **Bz_Meetings** connects to **Bz_Feature_Usage** via MEETING_ID field
8. **Bz_Participants** connects to **Bz_Users** via USER_ID field