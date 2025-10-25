_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze Layer Logical Data Model for Zoom Platform Analytics System
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Bronze Layer Logical Data Model for Zoom Platform Analytics System

## 1. PII Classification

| Column Name | Table | Reason for PII Classification |
|-------------|-------|-------------------------------|
| USER_NAME | Bz_USERS | Contains individual's full name which directly identifies a person |
| EMAIL | Bz_USERS | Personal email address that can uniquely identify an individual |
| COMPANY | Bz_USERS | Organization affiliation that may indirectly identify individuals in small companies |
| WEBINAR_TOPIC | Bz_WEBINARS | May contain personal or sensitive business information |
| MEETING_TOPIC | Bz_MEETINGS | May contain personal or sensitive business information |

## 2. Bronze Layer Logical Model

### 2.1 Bz_BILLING_EVENTS
**Description**: Contains billing and payment event data for tracking financial transactions

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| EVENT_TYPE | Type of billing event (subscription, payment, refund, upgrade, downgrade) | VARCHAR(16777216) |
| AMOUNT | Monetary amount associated with the billing event | NUMBER(10,2) |
| EVENT_DATE | Date when the billing event occurred | DATE |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) |

### 2.2 Bz_FEATURE_USAGE
**Description**: Tracks usage of various Zoom features during meetings and webinars

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| FEATURE_NAME | Name of the feature that was used (Screen Share, Recording, Chat, Breakout Rooms) | VARCHAR(16777216) |
| USAGE_COUNT | Number of times the feature was used during the session | NUMBER(38,0) |
| USAGE_DATE | Date when the feature was used | DATE |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) |

### 2.3 Bz_LICENSES
**Description**: Manages license assignments and validity periods for users

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| LICENSE_TYPE | Type of license (Basic, Pro, Business, Enterprise, Add-on) | VARCHAR(16777216) |
| START_DATE | Date when the license becomes active | DATE |
| END_DATE | Date when the license expires | DATE |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) |

### 2.4 Bz_MEETINGS
**Description**: Core meeting information including duration and scheduling data

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| MEETING_TOPIC | Topic or title of the meeting | VARCHAR(16777216) |
| START_TIME | Timestamp when the meeting started | TIMESTAMP_NTZ(9) |
| END_TIME | Timestamp when the meeting ended | TIMESTAMP_NTZ(9) |
| DURATION_MINUTES | Duration of the meeting in minutes | NUMBER(38,0) |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) |

### 2.5 Bz_PARTICIPANTS
**Description**: Tracks participant join/leave times and attendance patterns for meetings

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| JOIN_TIME | Timestamp when the participant joined the meeting | TIMESTAMP_NTZ(9) |
| LEAVE_TIME | Timestamp when the participant left the meeting | TIMESTAMP_NTZ(9) |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) |

### 2.6 Bz_SUPPORT_TICKETS
**Description**: Customer support ticket information for issue tracking and resolution

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| TICKET_TYPE | Type or category of the support ticket (Technical, Billing, Feature Request) | VARCHAR(16777216) |
| RESOLUTION_STATUS | Current status of the ticket resolution (Open, In Progress, Resolved, Closed) | VARCHAR(16777216) |
| OPEN_DATE | Date when the support ticket was opened | DATE |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) |

### 2.7 Bz_USERS
**Description**: User account and profile information for platform users

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| USER_NAME | Display name of the user | VARCHAR(16777216) |
| EMAIL | Email address of the user for communication and identification | VARCHAR(16777216) |
| COMPANY | Company or organization the user belongs to | VARCHAR(16777216) |
| PLAN_TYPE | Type of subscription plan the user has (Free, Basic, Pro, Enterprise) | VARCHAR(16777216) |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) |

### 2.8 Bz_WEBINARS
**Description**: Webinar-specific data including registrant counts and scheduling information

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| WEBINAR_TOPIC | Topic or title of the webinar | VARCHAR(16777216) |
| START_TIME | Timestamp when the webinar started | TIMESTAMP_NTZ(9) |
| END_TIME | Timestamp when the webinar ended | TIMESTAMP_NTZ(9) |
| REGISTRANTS | Number of users registered for the webinar | NUMBER(38,0) |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) |

## 3. Audit Table Design

### Bz_AUDIT_LOG
**Description**: Tracks data processing activities and maintains audit trail for all Bronze layer operations

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| RECORD_ID | Unique identifier for each audit record | VARCHAR(16777216) |
| SOURCE_TABLE | Name of the source table being processed | VARCHAR(16777216) |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) |
| PROCESSED_BY | Identifier of the process or user who processed the record | VARCHAR(16777216) |
| PROCESSING_TIME | Duration taken to process the record in seconds | NUMBER(10,2) |
| STATUS | Processing status (Success, Failed, Warning, Skipped) | VARCHAR(16777216) |

## 4. Conceptual Data Model Diagram

```
┌─────────────┐       ┌─────────────┐       ┌─────────────┐
│  Bz_USERS   │──────▶│ Bz_MEETINGS │──────▶│Bz_PARTICIPANTS│
│             │       │             │       │             │
│ USER_NAME   │       │MEETING_TOPIC│       │ JOIN_TIME   │
│ EMAIL       │       │ START_TIME  │       │ LEAVE_TIME  │
│ COMPANY     │       │ END_TIME    │       │             │
│ PLAN_TYPE   │       │DURATION_MIN │       │             │
└─────────────┘       └─────────────┘       └─────────────┘
       │                      │
       │                      │
       ▼                      ▼
┌─────────────┐       ┌─────────────┐
│Bz_SUPPORT_  │       │Bz_FEATURE_  │
│TICKETS      │       │USAGE        │
│             │       │             │
│TICKET_TYPE  │       │FEATURE_NAME │
│RESOLUTION_  │       │USAGE_COUNT  │
│STATUS       │       │USAGE_DATE   │
│OPEN_DATE    │       │             │
└─────────────┘       └─────────────┘
       │
       ▼
┌─────────────┐       ┌─────────────┐
│Bz_BILLING_  │       │ Bz_LICENSES │
│EVENTS       │       │             │
│             │       │LICENSE_TYPE │
│EVENT_TYPE   │       │START_DATE   │
│AMOUNT       │       │END_DATE     │
│EVENT_DATE   │       │             │
└─────────────┘       └─────────────┘

┌─────────────┐
│ Bz_WEBINARS │
│             │
│WEBINAR_TOPIC│
│START_TIME   │
│END_TIME     │
│REGISTRANTS  │
└─────────────┘
```

**Relationship Connections:**
- Bz_USERS connects to Bz_MEETINGS via USER_NAME → HOST_NAME relationship
- Bz_MEETINGS connects to Bz_PARTICIPANTS via MEETING_TOPIC → Meeting Reference relationship
- Bz_MEETINGS connects to Bz_FEATURE_USAGE via MEETING_TOPIC → Meeting Reference relationship
- Bz_USERS connects to Bz_SUPPORT_TICKETS via USER_NAME → Ticket Requester relationship
- Bz_USERS connects to Bz_BILLING_EVENTS via USER_NAME → Account Holder relationship
- Bz_USERS connects to Bz_LICENSES via USER_NAME → Assigned User relationship
- Bz_WEBINARS connects to Bz_USERS via HOST_NAME → USER_NAME relationship