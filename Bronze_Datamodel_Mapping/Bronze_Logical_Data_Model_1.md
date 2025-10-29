_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze Layer Logical Data Model for Zoom Platform Analytics System supporting medallion architecture data processing
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Bronze Layer Logical Data Model for Zoom Platform Analytics System

## 1. PII Classification

| Column Name | Table Name | PII Classification | Reason |
|-------------|------------|-------------------|--------|
| USER_NAME | Bz_USERS | PII | Personal name of the user, directly identifies an individual |
| EMAIL | Bz_USERS | PII | Email address is personally identifiable information that can be used to contact and identify an individual |
| COMPANY | Bz_USERS | Potential PII | Company name may indirectly identify an individual, especially in small organizations |

## 2. Bronze Layer Logical Model

### 2.1 Table: Bz_BILLING_EVENTS
**Description:** Contains billing transaction records and financial events for user accounts in the bronze layer

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| EVENT_TYPE | VARCHAR(16777216) | Type of billing event such as subscription, upgrade, downgrade, refund, or payment |
| AMOUNT | NUMBER(10,2) | Monetary amount associated with the billing event in the specified currency |
| EVENT_DATE | DATE | Date when the billing event occurred in the system |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the billing data was ingested |

### 2.2 Table: Bz_FEATURE_USAGE
**Description:** Tracks usage of platform features during meetings and sessions in the bronze layer

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| FEATURE_NAME | VARCHAR(16777216) | Name of the platform feature used such as screen share, recording, chat, or breakout rooms |
| USAGE_COUNT | NUMBER(38,0) | Number of times the specific feature was utilized during the session |
| USAGE_DATE | DATE | Date when the feature usage was recorded in the system |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the feature usage data was ingested |

### 2.3 Table: Bz_LICENSES
**Description:** Manages software license assignments and their terms in the bronze layer

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| LICENSE_TYPE | VARCHAR(16777216) | Type of license assigned such as Basic, Pro, Business, Enterprise, or Add-on |
| START_DATE | DATE | Date when the license becomes active and available for use |
| END_DATE | DATE | Date when the license expires and is no longer valid |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the license data was ingested |

### 2.4 Table: Bz_MEETINGS
**Description:** Contains meeting session information and metadata in the bronze layer

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| MEETING_TOPIC | VARCHAR(16777216) | Topic or title assigned to the meeting session |
| START_TIME | TIMESTAMP_NTZ(9) | Date and time when the meeting session began |
| END_TIME | TIMESTAMP_NTZ(9) | Date and time when the meeting session concluded |
| DURATION_MINUTES | NUMBER(38,0) | Total duration of the meeting measured in minutes |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the meeting data was ingested |

### 2.5 Table: Bz_PARTICIPANTS
**Description:** Tracks participant attendance and engagement in meetings in the bronze layer

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| JOIN_TIME | TIMESTAMP_NTZ(9) | Timestamp when the participant joined the meeting session |
| LEAVE_TIME | TIMESTAMP_NTZ(9) | Timestamp when the participant left the meeting session |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the participant data was ingested |

### 2.6 Table: Bz_SUPPORT_TICKETS
**Description:** Manages customer service requests and issue tracking in the bronze layer

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| TICKET_TYPE | VARCHAR(16777216) | Category of support request such as Technical, Billing, Account, or Feature Request |
| RESOLUTION_STATUS | VARCHAR(16777216) | Current status of ticket resolution such as Open, In Progress, Resolved, or Closed |
| OPEN_DATE | DATE | Date when the support ticket was created in the system |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the support ticket data was ingested |

### 2.7 Table: Bz_USERS
**Description:** Contains user account information and profile data in the bronze layer

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| USER_NAME | VARCHAR(16777216) | Display name or full name of the user account |
| EMAIL | VARCHAR(16777216) | Primary email address associated with the user account |
| COMPANY | VARCHAR(16777216) | Organization or company name associated with the user account |
| PLAN_TYPE | VARCHAR(16777216) | Subscription tier assigned to the user such as Free, Basic, Pro, Business, or Enterprise |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the user data was ingested |

### 2.8 Table: Bz_WEBINARS
**Description:** Manages webinar sessions and registration information in the bronze layer

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| WEBINAR_TOPIC | VARCHAR(16777216) | Topic or title assigned to the webinar session |
| START_TIME | TIMESTAMP_NTZ(9) | Date and time when the webinar session began |
| END_TIME | TIMESTAMP_NTZ(9) | Date and time when the webinar session concluded |
| REGISTRANTS | NUMBER(38,0) | Number of participants registered for the webinar |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the webinar data was ingested |

## 3. Audit Table Design

### 3.1 Table: Bz_Audit_Log
**Description:** Tracks data processing activities and maintains audit trail for bronze layer operations

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| record_id | VARCHAR(16777216) | Unique identifier for each audit record |
| source_table | VARCHAR(16777216) | Name of the source table being processed |
| load_timestamp | TIMESTAMP_NTZ(9) | Timestamp when the record was loaded into the system |
| processed_by | VARCHAR(16777216) | Identifier of the process or user who processed the record |
| processing_time | NUMBER(38,0) | Time taken to process the record measured in milliseconds |
| status | VARCHAR(16777216) | Processing status such as Success, Failed, or In Progress |

## 4. Conceptual Data Model Diagram

### 4.1 Block Diagram Format

```
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│   Bz_USERS      │       │   Bz_MEETINGS   │       │   Bz_WEBINARS   │
│                 │       │                 │       │                 │
│ USER_NAME       │◄──────┤ Connected via   │       │ WEBINAR_TOPIC   │
│ EMAIL           │       │ business logic  │       │ START_TIME      │
│ COMPANY         │       │ MEETING_TOPIC   │       │ END_TIME        │
│ PLAN_TYPE       │       │ START_TIME      │       │ REGISTRANTS     │
└─────────────────┘       │ END_TIME        │       └─────────────────┘
         │                │ DURATION_MIN    │                │
         │                └─────────────────┘                │
         │                         │                         │
         │                         │                         │
         ▼                         ▼                         ▼
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│ Bz_PARTICIPANTS │       │ Bz_FEATURE_USAGE│       │ Bz_BILLING_EVENTS│
│                 │       │                 │       │                 │
│ JOIN_TIME       │       │ FEATURE_NAME    │       │ EVENT_TYPE      │
│ LEAVE_TIME      │       │ USAGE_COUNT     │       │ AMOUNT          │
└─────────────────┘       │ USAGE_DATE      │       │ EVENT_DATE      │
         │                └─────────────────┘       └─────────────────┘
         │                                                   │
         │                                                   │
         ▼                                                   ▼
┌─────────────────┐                               ┌─────────────────┐
│Bz_SUPPORT_TICKETS│                               │   Bz_LICENSES   │
│                 │                               │                 │
│ TICKET_TYPE     │                               │ LICENSE_TYPE    │
│ RESOLUTION_STATUS│                               │ START_DATE      │
│ OPEN_DATE       │                               │ END_DATE        │
└─────────────────┘                               └─────────────────┘
```

### 4.2 Table Relationships

1. **Bz_USERS** connects to **Bz_MEETINGS** via business logic linking user accounts to hosted meetings
2. **Bz_MEETINGS** connects to **Bz_PARTICIPANTS** via meeting sessions and attendee records
3. **Bz_MEETINGS** connects to **Bz_FEATURE_USAGE** via feature utilization during meeting sessions
4. **Bz_USERS** connects to **Bz_BILLING_EVENTS** via user account billing activities
5. **Bz_USERS** connects to **Bz_LICENSES** via license assignments to user accounts
6. **Bz_USERS** connects to **Bz_SUPPORT_TICKETS** via customer service requests
7. **Bz_USERS** connects to **Bz_WEBINARS** via webinar hosting and participation
8. **Bz_USERS** connects to **Bz_PARTICIPANTS** via meeting attendance records