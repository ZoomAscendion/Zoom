_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze Layer Logical Data Model for Zoom Platform Analytics System
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Bronze Layer Logical Data Model - Zoom Platform Analytics System

## 1. PII Classification

| Column Name | Table Name | Reason for PII Classification |
|-------------|------------|-------------------------------|
| USER_NAME | Bz_USERS | Contains personal name information that can directly identify an individual user |
| EMAIL | Bz_USERS | Email address is personally identifiable information that can be used to contact and identify individuals |
| COMPANY | Bz_USERS | Company affiliation can indirectly identify individuals, especially in smaller organizations |
| MEETING_TOPIC | Bz_MEETINGS | Meeting topics may contain sensitive business information or personal details |
| WEBINAR_TOPIC | Bz_WEBINARS | Webinar topics may contain sensitive business information or personal details |

## 2. Bronze Layer Logical Model

### 2.1 Table: Bz_BILLING_EVENTS
**Description**: Contains all billing and payment event data from the source system, mirroring the raw structure without key fields

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| EVENT_TYPE | VARCHAR(16777216) | Type of billing event (subscription, payment, refund, upgrade, downgrade) |
| AMOUNT | NUMBER(10,2) | Monetary amount associated with the billing event in the specified currency |
| EVENT_DATE | DATE | Date when the billing event occurred in the source system |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated |

### 2.2 Table: Bz_FEATURE_USAGE
**Description**: Tracks utilization of specific platform features during meetings and sessions

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| FEATURE_NAME | VARCHAR(16777216) | Name of the Zoom feature that was utilized (Screen Share, Recording, Chat, Breakout Rooms, etc.) |
| USAGE_COUNT | NUMBER(38,0) | Number of times the specific feature was activated or used during the session |
| USAGE_DATE | DATE | Date when the feature usage occurred |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated |

### 2.3 Table: Bz_LICENSES
**Description**: Manages software license assignments and validity periods for platform users

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| LICENSE_TYPE | VARCHAR(16777216) | Category of license assigned (Basic, Pro, Business, Enterprise, Add-on) |
| START_DATE | DATE | Date when the license becomes active and available for use |
| END_DATE | DATE | Date when the license expires and is no longer valid |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated |

### 2.4 Table: Bz_MEETINGS
**Description**: Core meeting information capturing video conference sessions and related activities

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| MEETING_TOPIC | VARCHAR(16777216) | Subject or title of the meeting as specified by the host |
| START_TIME | TIMESTAMP_NTZ(9) | Timestamp when the meeting session began |
| END_TIME | TIMESTAMP_NTZ(9) | Timestamp when the meeting session concluded |
| DURATION_MINUTES | NUMBER(38,0) | Total duration of the meeting measured in minutes |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated |

### 2.5 Table: Bz_PARTICIPANTS
**Description**: Tracks participant join and leave times for meetings, representing attendees beyond the host

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| JOIN_TIME | TIMESTAMP_NTZ(9) | Timestamp when the participant entered the meeting session |
| LEAVE_TIME | TIMESTAMP_NTZ(9) | Timestamp when the participant exited the meeting session |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated |

### 2.6 Table: Bz_SUPPORT_TICKETS
**Description**: Customer service requests and issue tracking for platform support management

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| TICKET_TYPE | VARCHAR(16777216) | Category of the support request (Technical, Billing, Feature Request, Account Issue) |
| RESOLUTION_STATUS | VARCHAR(16777216) | Current state of the ticket (Open, In Progress, Resolved, Closed, Escalated) |
| OPEN_DATE | DATE | Date when the support ticket was created in the system |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated |

### 2.7 Table: Bz_USERS
**Description**: Core user entity representing individuals who use the Zoom platform

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| USER_NAME | VARCHAR(16777216) | Display name of the platform user as registered in the system |
| EMAIL | VARCHAR(16777216) | Primary email address for user communication and unique identification |
| COMPANY | VARCHAR(16777216) | Organization or business entity associated with the user account |
| PLAN_TYPE | VARCHAR(16777216) | Subscription tier indicating service level (Free, Basic, Pro, Business, Enterprise) |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated |

### 2.8 Table: Bz_WEBINARS
**Description**: Webinar-specific data including registration and attendance information

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| WEBINAR_TOPIC | VARCHAR(16777216) | Subject or title of the webinar as specified by the host |
| START_TIME | TIMESTAMP_NTZ(9) | Timestamp when the webinar session began |
| END_TIME | TIMESTAMP_NTZ(9) | Timestamp when the webinar session concluded |
| REGISTRANTS | NUMBER(38,0) | Total number of users who registered for the webinar |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated |

## 3. Audit Table Design

### 3.1 Table: Bz_AUDIT
**Description**: Comprehensive audit trail for tracking data processing activities across all Bronze layer tables

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| RECORD_ID | VARCHAR(16777216) | Unique identifier for each audit record entry |
| SOURCE_TABLE | VARCHAR(16777216) | Name of the Bronze layer table being audited |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the data processing operation began |
| PROCESSED_BY | VARCHAR(16777216) | Identifier of the ETL process, job, or user who performed the operation |
| PROCESSING_TIME | NUMBER(38,0) | Total time taken to process the record measured in seconds |
| STATUS | VARCHAR(16777216) | Outcome of the processing operation (SUCCESS, FAILED, PARTIAL, RETRY) |

## 4. Conceptual Data Model Diagram

### 4.1 Block Diagram Format - Table Relationships

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Bz_USERS      │────│   Bz_MEETINGS   │────│ Bz_PARTICIPANTS │
│                 │    │                 │    │                 │
│ - USER_NAME     │    │ - MEETING_TOPIC │    │ - JOIN_TIME     │
│ - EMAIL         │    │ - START_TIME    │    │ - LEAVE_TIME    │
│ - COMPANY       │    │ - END_TIME      │    │                 │
│ - PLAN_TYPE     │    │ - DURATION_MIN  │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │
         │                       │
         ▼                       ▼
┌─────────────────┐    ┌─────────────────┐
│  Bz_LICENSES    │    │ Bz_FEATURE_USAGE│
│                 │    │                 │
│ - LICENSE_TYPE  │    │ - FEATURE_NAME  │
│ - START_DATE    │    │ - USAGE_COUNT   │
│ - END_DATE      │    │ - USAGE_DATE    │
└─────────────────┘    └─────────────────┘
         │
         │
         ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│Bz_BILLING_EVENTS│    │Bz_SUPPORT_TICKETS│   │   Bz_WEBINARS   │
│                 │    │                 │    │                 │
│ - EVENT_TYPE    │    │ - TICKET_TYPE   │    │ - WEBINAR_TOPIC │
│ - AMOUNT        │    │ - RESOLUTION_ST │    │ - START_TIME    │
│ - EVENT_DATE    │    │ - OPEN_DATE     │    │ - END_TIME      │
└─────────────────┘    └─────────────────┘    │ - REGISTRANTS   │
                                              └─────────────────┘
```

### 4.2 Relationship Descriptions

1. **Bz_USERS ↔ Bz_MEETINGS**: Users host meetings (One-to-Many relationship via USER_NAME → HOST reference)
2. **Bz_MEETINGS ↔ Bz_PARTICIPANTS**: Meetings have multiple participants (One-to-Many relationship via MEETING reference)
3. **Bz_MEETINGS ↔ Bz_FEATURE_USAGE**: Features are used within meetings (One-to-Many relationship via MEETING reference)
4. **Bz_USERS ↔ Bz_LICENSES**: Users are assigned licenses (One-to-Many relationship via USER reference)
5. **Bz_USERS ↔ Bz_BILLING_EVENTS**: Users generate billing events (One-to-Many relationship via USER reference)
6. **Bz_USERS ↔ Bz_SUPPORT_TICKETS**: Users create support tickets (One-to-Many relationship via USER reference)
7. **Bz_USERS ↔ Bz_WEBINARS**: Users host webinars (One-to-Many relationship via USER reference)

---

**Note**: This Bronze layer logical data model follows the medallion architecture principles by preserving the raw data structure while removing primary and foreign key constraints. All tables include standard metadata columns for data lineage and governance. The naming convention uses 'Bz_' prefix to clearly identify Bronze layer tables, and the schema follows the pattern where raw_schema becomes bronze_schema as specified in the requirements.