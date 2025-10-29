_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze Logical Data Model for Zoom Platform Analytics System following medallion architecture principles
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Bronze Logical Data Model - Zoom Platform Analytics System

## 1. PII Classification

### 1.1 PII Fields Identification

| Column Name | Table Name | PII Classification | Reason for PII Classification |
|-------------|------------|-------------------|------------------------------|
| USER_NAME | Bz_Users | PII | Contains personal names that directly identify individuals |
| EMAIL | Bz_Users | PII | Email addresses are personally identifiable information under GDPR and other privacy regulations |
| COMPANY | Bz_Users | Sensitive | Company affiliation can be used to identify individuals in smaller organizations |
| MEETING_TOPIC | Bz_Meetings | Potentially Sensitive | Meeting topics may contain confidential business information or personal details |
| WEBINAR_TOPIC | Bz_Webinars | Potentially Sensitive | Webinar topics may contain confidential business information |

## 2. Bronze Layer Logical Model

### 2.1 Bz_Users
**Description**: Bronze layer table containing raw user data from source systems with all user profile information

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| USER_NAME | VARCHAR(16777216) | Full name of the registered user |
| EMAIL | VARCHAR(16777216) | Primary email address for user communication and identification |
| COMPANY | VARCHAR(16777216) | Organization or company affiliation of the user |
| PLAN_TYPE | VARCHAR(16777216) | Subscription tier (Free, Basic, Pro, Enterprise) indicating service level |
| load_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the bronze layer |
| update_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in the bronze layer |
| source_system | VARCHAR(16777216) | Source system from which data originated |

### 2.2 Bz_Meetings
**Description**: Bronze layer table containing raw meeting data with all meeting session details

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| MEETING_TOPIC | VARCHAR(16777216) | Descriptive name or subject of the meeting |
| START_TIME | TIMESTAMP_NTZ(9) | Date and time when the meeting began |
| END_TIME | TIMESTAMP_NTZ(9) | Date and time when the meeting concluded |
| DURATION_MINUTES | NUMBER(38,0) | Total length of the meeting in minutes |
| load_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the bronze layer |
| update_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in the bronze layer |
| source_system | VARCHAR(16777216) | Source system from which data originated |

### 2.3 Bz_Participants
**Description**: Bronze layer table containing raw participant data linking users to meeting attendance

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| JOIN_TIME | TIMESTAMP_NTZ(9) | Date and time when the attendee joined the meeting |
| LEAVE_TIME | TIMESTAMP_NTZ(9) | Date and time when the attendee left the meeting |
| load_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the bronze layer |
| update_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in the bronze layer |
| source_system | VARCHAR(16777216) | Source system from which data originated |

### 2.4 Bz_Feature_Usage
**Description**: Bronze layer table containing raw feature usage data during meetings

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| FEATURE_NAME | VARCHAR(16777216) | Name of the specific platform feature used |
| USAGE_COUNT | NUMBER(38,0) | Number of times the feature was utilized during the meeting |
| USAGE_DATE | DATE | Date when feature usage occurred |
| load_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the bronze layer |
| update_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in the bronze layer |
| source_system | VARCHAR(16777216) | Source system from which data originated |

### 2.5 Bz_Support_Tickets
**Description**: Bronze layer table containing raw customer support ticket data

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| TICKET_TYPE | VARCHAR(16777216) | Category of the support issue (Technical, Billing, Feature Request, Bug Report) |
| RESOLUTION_STATUS | VARCHAR(16777216) | Current status of the ticket (Open, In Progress, Resolved, Closed) |
| OPEN_DATE | DATE | Date when the support ticket was created |
| load_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the bronze layer |
| update_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in the bronze layer |
| source_system | VARCHAR(16777216) | Source system from which data originated |

### 2.6 Bz_Billing_Events
**Description**: Bronze layer table containing raw billing and transaction data

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| EVENT_TYPE | VARCHAR(16777216) | Type of billing transaction (Subscription, Upgrade, Downgrade, Refund) |
| AMOUNT | NUMBER(10,2) | Monetary value of the billing event |
| EVENT_DATE | DATE | Date when the billing event occurred |
| load_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the bronze layer |
| update_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in the bronze layer |
| source_system | VARCHAR(16777216) | Source system from which data originated |

### 2.7 Bz_Licenses
**Description**: Bronze layer table containing raw license assignment and management data

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| LICENSE_TYPE | VARCHAR(16777216) | Category of license (Basic, Pro, Enterprise, Add-on) |
| START_DATE | DATE | Date when the license becomes active |
| END_DATE | DATE | Date when the license expires |
| load_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the bronze layer |
| update_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in the bronze layer |
| source_system | VARCHAR(16777216) | Source system from which data originated |

### 2.8 Bz_Webinars
**Description**: Bronze layer table containing raw webinar data and registration information

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| WEBINAR_TOPIC | VARCHAR(16777216) | Topic or title of the webinar |
| START_TIME | TIMESTAMP_NTZ(9) | Webinar start timestamp |
| END_TIME | TIMESTAMP_NTZ(9) | Webinar end timestamp |
| REGISTRANTS | NUMBER(38,0) | Number of registered participants |
| load_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the bronze layer |
| update_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in the bronze layer |
| source_system | VARCHAR(16777216) | Source system from which data originated |

## 3. Audit Table Design

### 3.1 Bz_Audit_Records
**Description**: Audit table to track data processing and lineage for all bronze layer operations

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| record_id | VARCHAR(16777216) | Unique identifier for each audit record |
| source_table | VARCHAR(16777216) | Name of the source table being processed |
| load_timestamp | TIMESTAMP_NTZ(9) | Timestamp when the data load operation began |
| processed_by | VARCHAR(16777216) | Identifier of the process, job, or user that performed the operation |
| processing_time | NUMBER(38,0) | Duration in seconds taken to complete the processing |
| status | VARCHAR(16777216) | Processing status (SUCCESS, FAILED, IN_PROGRESS, PARTIAL) |

## 4. Conceptual Data Model Diagram

### 4.1 Block Diagram Representation

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Bz_Users      │    │   Bz_Meetings   │    │  Bz_Licenses    │
│                 │    │                 │    │                 │
│ • USER_NAME     │    │ • MEETING_TOPIC │    │ • LICENSE_TYPE  │
│ • EMAIL         │    │ • START_TIME    │    │ • START_DATE    │
│ • COMPANY       │    │ • END_TIME      │    │ • END_DATE      │
│ • PLAN_TYPE     │    │ • DURATION_MIN  │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ Bz_Participants │    │Bz_Feature_Usage │    │Bz_Support_Tickets│
│                 │    │                 │    │                 │
│ • JOIN_TIME     │    │ • FEATURE_NAME  │    │ • TICKET_TYPE   │
│ • LEAVE_TIME    │    │ • USAGE_COUNT   │    │ • RESOLUTION_ST │
│                 │    │ • USAGE_DATE    │    │ • OPEN_DATE     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ Bz_Billing_Events│   │   Bz_Webinars   │    │ Bz_Audit_Records│
│                 │    │                 │    │                 │
│ • EVENT_TYPE    │    │ • WEBINAR_TOPIC │    │ • record_id     │
│ • AMOUNT        │    │ • START_TIME    │    │ • source_table  │
│ • EVENT_DATE    │    │ • END_TIME      │    │ • load_timestamp│
│                 │    │ • REGISTRANTS   │    │ • processed_by  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### 4.2 Table Relationships

| Source Table | Target Table | Connection Method | Description |
|--------------|--------------|-------------------|-------------|
| Bz_Users | Bz_Participants | Business Logic | Users participate in meetings through participant records |
| Bz_Meetings | Bz_Participants | Business Logic | Meetings have multiple participants |
| Bz_Meetings | Bz_Feature_Usage | Business Logic | Features are used during meetings |
| Bz_Users | Bz_Support_Tickets | Business Logic | Users create support tickets |
| Bz_Users | Bz_Billing_Events | Business Logic | Users have billing events |
| Bz_Users | Bz_Licenses | Business Logic | Licenses are assigned to users |
| Bz_Users | Bz_Webinars | Business Logic | Users host webinars |

**Note**: In the Bronze layer, explicit foreign key relationships are not maintained as this layer focuses on raw data ingestion. Relationships are established through business logic and will be formalized in Silver layer transformations.