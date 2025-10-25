# Bronze Layer Logical Data Model for Zoom Platform Analytics System

---

## Metadata

- **Author**: AAVA
- **Version**: 1
- **Description**: Comprehensive Bronze Layer Logical Data Model for Zoom Platform Analytics System based on conceptual data model and raw schema.
- **Date**: 2024-06

---

## 1. PII Classification

| Column Name | Table | Reason for PII Classification |
|-------------|-------|-------------------------------|
| USER_NAME | USERS | Identifies individual user by name
| EMAIL | USERS | Personal email address
| COMPANY | USERS | May identify employer or organization
| PARTICIPANT_NAME | PARTICIPANTS (mapped from USER_ID) | Identifies meeting participant
| HOST_NAME | MEETINGS (mapped from HOST_ID) | Identifies meeting host
| ASSIGNED_USER_NAME | LICENSES (mapped from ASSIGNED_TO_USER_ID) | Identifies license assignee
| ASSIGNED_AGENT | SUPPORT_TICKETS (if present) | Identifies support agent handling ticket

*Note*: PII fields are identified based on their ability to directly or indirectly identify an individual.

---

## 2. Bronze Layer Logical Model

### 2.1 Bz_BILLING_EVENTS

| Column Name | Business Description |
|-------------|----------------------|
| EVENT_TYPE | Type of billing event (subscription, payment, refund, etc.) |
| AMOUNT | Monetary amount associated with the billing event |
| EVENT_DATE | Date when the billing event occurred |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated |
| SOURCE_SYSTEM | System from which the data originated |

### 2.2 Bz_FEATURE_USAGE

| Column Name | Business Description |
|-------------|----------------------|
| FEATURE_NAME | Name of the feature that was used |
| USAGE_COUNT | Number of times the feature was used |
| USAGE_DATE | Date when the feature was used |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated |
| SOURCE_SYSTEM | System from which the data originated |

### 2.3 Bz_LICENSES

| Column Name | Business Description |
|-------------|----------------------|
| LICENSE_TYPE | Type of license (Basic, Pro, Business, Enterprise) |
| START_DATE | Date when the license becomes active |
| END_DATE | Date when the license expires |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated |
| SOURCE_SYSTEM | System from which the data originated |

### 2.4 Bz_MEETINGS

| Column Name | Business Description |
|-------------|----------------------|
| MEETING_TOPIC | Topic or title of the meeting |
| START_TIME | Timestamp when the meeting started |
| END_TIME | Timestamp when the meeting ended |
| DURATION_MINUTES | Duration of the meeting in minutes |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated |
| SOURCE_SYSTEM | System from which the data originated |

### 2.5 Bz_PARTICIPANTS

| Column Name | Business Description |
|-------------|----------------------|
| JOIN_TIME | Timestamp when the participant joined the meeting |
| LEAVE_TIME | Timestamp when the participant left the meeting |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated |
| SOURCE_SYSTEM | System from which the data originated |

### 2.6 Bz_SUPPORT_TICKETS

| Column Name | Business Description |
|-------------|----------------------|
| TICKET_TYPE | Type or category of the support ticket |
| RESOLUTION_STATUS | Current status of the ticket resolution |
| OPEN_DATE | Date when the support ticket was opened |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated |
| SOURCE_SYSTEM | System from which the data originated |

### 2.7 Bz_USERS

| Column Name | Business Description |
|-------------|----------------------|
| USER_NAME | Display name of the user |
| EMAIL | Email address of the user |
| COMPANY | Company or organization the user belongs to |
| PLAN_TYPE | Type of subscription plan the user has |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated |
| SOURCE_SYSTEM | System from which the data originated |

### 2.8 Bz_WEBINARS

| Column Name | Business Description |
|-------------|----------------------|
| WEBINAR_TOPIC | Topic or title of the webinar |
| START_TIME | Timestamp when the webinar started |
| END_TIME | Timestamp when the webinar ended |
| REGISTRANTS | Number of users registered for the webinar |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated |
| SOURCE_SYSTEM | System from which the data originated |

---

## 3. Audit Table Design

| Column Name | Business Description |
|-------------|----------------------|
| RECORD_ID | Unique identifier for each audit record |
| SOURCE_TABLE | Name of the source table being processed |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system |
| PROCESSED_BY | Identifier of the process or user who processed the record |
| PROCESSING_TIME | Duration taken to process the record |
| STATUS | Processing status (e.g., Success, Failed) |

---

## 4. Relationships Between Tables

- Users to Meetings: One-to-Many (Users host multiple meetings)
- Meetings to Participants: One-to-Many (Meetings have multiple participants)
- Meetings to Feature Usage: One-to-Many (Meetings have multiple feature usage records)
- Users to Support Tickets: One-to-Many (Users create multiple support tickets)
- Users to Billing Events: One-to-Many (Users have multiple billing events)
- Users to Licenses: One-to-Many (Users assigned multiple licenses)
- Meetings to Webinars: One-to-One or One-to-Many (Webinars are specialized meetings hosted by users)

---

## 5. Conceptual Data Model Diagram

```plaintext
+---------+       +----------+       +-------------+
|  Users  |-------| Meetings |-------| Participants|
+---------+       +----------+       +-------------+
     |                 |                  |
     |                 |                  |
     |                 |                  |
     |                 |                  |
+-------------+   +----------------+   +----------------+
| Support     |   | Feature Usage  |   | Billing Events |
| Tickets     |   +----------------+   +----------------+
+-------------+
     |
+----------+
| Licenses |
+----------+
     |
+----------+
| Webinars |
+----------+
```

---

## 6. Naming Conventions

- Bronze schema name: BRONZE (matching raw schema naming conventions)
- All Bronze tables prefixed with 'Bz_'
- Primary and foreign key fields removed from Bronze layer tables as per requirements

---

*End of Bronze Layer Logical Data Model Document*