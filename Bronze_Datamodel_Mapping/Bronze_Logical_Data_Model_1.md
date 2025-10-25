_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze Layer Logical Data Model for Zoom Platform Analytics System
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Bronze Layer Logical Data Model for Zoom Platform Analytics System

## 1. PII Classification

| Column Name          | Table Name       | PII Classification | Reason                                                                                  |
|----------------------|------------------|--------------------|-----------------------------------------------------------------------------------------|
| USER_NAME            | Bz_Users         | Yes                | Identifies individual users directly and is considered personally identifiable information. |
| EMAIL                | Bz_Users         | Yes                | Email address is personally identifiable information that can be used to contact individuals. |
| COMPANY              | Bz_Users         | Potentially        | May identify employer or organization, considered sensitive in some contexts and could indirectly identify individuals. |
| PARTICIPANT_NAME     | Bz_Participants  | Yes                | Identifies meeting participants directly and is considered personally identifiable information. |
| HOST_NAME            | Bz_Meetings      | Yes                | Identifies the host user, which is personally identifiable information. |
| ASSIGNED_AGENT       | Bz_Support_Tickets| Yes               | Identifies support personnel by name, which is personally identifiable information. |
| ASSIGNED_USER_NAME   | Bz_Licenses      | Yes                | Identifies user assigned to license and is considered personally identifiable information. |

## 2. Bronze Layer Logical Model

### 2.1 Bz_Users
**Description:** Central entity representing all users of the Zoom platform with their profile and subscription information.

| Column Name       | Data Type    | Description                                                    |
|-------------------|--------------|----------------------------------------------------------------|
| USER_NAME         | VARCHAR      | Display name of the user as registered in the system          |
| EMAIL             | VARCHAR      | Primary email address used for user communication and login   |
| COMPANY           | VARCHAR      | Company or organization name associated with the user account  |
| PLAN_TYPE         | VARCHAR      | Subscription plan type (Free, Basic, Pro, Enterprise)         |
| load_timestamp    | TIMESTAMP    | Timestamp when the record was loaded into the Bronze layer    |
| update_timestamp  | TIMESTAMP    | Timestamp when the record was last updated in the Bronze layer|
| source_system     | VARCHAR      | Source system identifier from which the data originated       |

### 2.2 Bz_Meetings
**Description:** Core entity capturing all meeting sessions and their basic attributes.

| Column Name       | Data Type    | Description                                                    |
|-------------------|--------------|----------------------------------------------------------------|
| MEETING_TOPIC     | VARCHAR      | Title or subject of the meeting as set by the host           |
| START_TIME        | TIMESTAMP    | Timestamp when the meeting session began                     |
| END_TIME          | TIMESTAMP    | Timestamp when the meeting session concluded                 |
| DURATION_MINUTES  | NUMBER       | Total duration of the meeting measured in minutes            |
| load_timestamp    | TIMESTAMP    | Timestamp when the record was loaded into the Bronze layer   |
| update_timestamp  | TIMESTAMP    | Timestamp when the record was last updated in the Bronze layer|
| source_system     | VARCHAR      | Source system identifier from which the data originated      |

### 2.3 Bz_Participants
**Description:** Entity tracking all participants who joined meetings, including their attendance patterns.

| Column Name       | Data Type    | Description                                                    |
|-------------------|--------------|----------------------------------------------------------------|
| JOIN_TIME         | TIMESTAMP    | Timestamp when the participant entered the meeting           |
| LEAVE_TIME        | TIMESTAMP    | Timestamp when the participant exited the meeting            |
| load_timestamp    | TIMESTAMP    | Timestamp when the record was loaded into the Bronze layer   |
| update_timestamp  | TIMESTAMP    | Timestamp when the record was last updated in the Bronze layer|
| source_system     | VARCHAR      | Source system identifier from which the data originated      |

### 2.4 Bz_Feature_Usage
**Description:** Entity capturing utilization of specific platform features during meetings and sessions.

| Column Name       | Data Type    | Description                                                    |
|-------------------|--------------|----------------------------------------------------------------|
| FEATURE_NAME      | VARCHAR      | Name of the specific platform feature that was utilized      |
| USAGE_COUNT       | NUMBER       | Number of times the feature was activated or used            |
| USAGE_DATE        | DATE         | Date when the feature usage occurred                         |
| load_timestamp    | TIMESTAMP    | Timestamp when the record was loaded into the Bronze layer   |
| update_timestamp  | TIMESTAMP    | Timestamp when the record was last updated in the Bronze layer|
| source_system     | VARCHAR      | Source system identifier from which the data originated      |

### 2.5 Bz_Support_Tickets
**Description:** Entity managing all customer service requests and support interactions.

| Column Name       | Data Type    | Description                                                    |
|-------------------|--------------|----------------------------------------------------------------|
| TICKET_TYPE       | VARCHAR      | Category or type of the support request                       |
| RESOLUTION_STATUS | VARCHAR      | Current status of the ticket (Open, In Progress, Resolved, Closed)|
| OPEN_DATE         | DATE         | Date when the support ticket was initially created           |
| load_timestamp    | TIMESTAMP    | Timestamp when the record was loaded into the Bronze layer   |
| update_timestamp  | TIMESTAMP    | Timestamp when the record was last updated in the Bronze layer|
| source_system     | VARCHAR      | Source system identifier from which the data originated      |

### 2.6 Bz_Billing_Events
**Description:** Entity capturing all financial transactions and billing activities related to user accounts.

| Column Name       | Data Type    | Description                                                    |
|-------------------|--------------|----------------------------------------------------------------|
| EVENT_TYPE        | VARCHAR      | Type of billing transaction (Subscription, Payment, Refund, Upgrade)|
| AMOUNT            | NUMBER(10,2) | Monetary value of the transaction                             |
| EVENT_DATE        | DATE         | Date when the billing event was processed                    |
| load_timestamp    | TIMESTAMP    | Timestamp when the record was loaded into the Bronze layer   |
| update_timestamp  | TIMESTAMP    | Timestamp when the record was last updated in the Bronze layer|
| source_system     | VARCHAR      | Source system identifier from which the data originated      |

### 2.7 Bz_Licenses
**Description:** Entity managing software licenses assigned to users and their validity periods.

| Column Name       | Data Type    | Description                                                    |
|-------------------|--------------|----------------------------------------------------------------|
| LICENSE_TYPE      | VARCHAR      | Category of software license (Basic, Pro, Enterprise, Add-on) |
| START_DATE        | DATE         | Date when the license becomes active and usable              |
| END_DATE          | DATE         | Date when the license expires and becomes inactive           |
| load_timestamp    | TIMESTAMP    | Timestamp when the record was loaded into the Bronze layer   |
| update_timestamp  | TIMESTAMP    | Timestamp when the record was last updated in the Bronze layer|
| source_system     | VARCHAR      | Source system identifier from which the data originated      |

### 2.8 Bz_Webinars
**Description:** Entity capturing webinar-specific data including registration and attendance information.

| Column Name       | Data Type    | Description                                                    |
|-------------------|--------------|----------------------------------------------------------------|
| WEBINAR_TOPIC     | VARCHAR      | Title or subject of the webinar session                      |
| START_TIME        | TIMESTAMP    | Timestamp when the webinar session began                     |
| END_TIME          | TIMESTAMP    | Timestamp when the webinar session concluded                 |
| REGISTRANTS       | NUMBER       | Total number of users who registered for the webinar         |
| load_timestamp    | TIMESTAMP    | Timestamp when the record was loaded into the Bronze layer   |
| update_timestamp  | TIMESTAMP    | Timestamp when the record was last updated in the Bronze layer|
| source_system     | VARCHAR      | Source system identifier from which the data originated      |

## 3. Audit Table Design

### Bz_Audit_Records
**Description:** Comprehensive audit trail for tracking data processing activities across all Bronze layer tables.

| Column Name      | Data Type    | Description                                                    |
|------------------|--------------|----------------------------------------------------------------|
| record_id        | VARCHAR      | Unique identifier for each audit record entry                |
| source_table     | VARCHAR      | Name of the Bronze layer table being audited                 |
| load_timestamp   | TIMESTAMP    | Timestamp when the data processing operation began           |
| processed_by     | VARCHAR      | Identifier of the process, job, or user performing the operation|
| processing_time  | NUMBER       | Duration of the processing operation measured in seconds     |
| status           | VARCHAR      | Final status of the processing operation (Success, Failed, Warning)|

## 4. Conceptual Data Model Diagram

**Block Diagram Format - Table Relationships:**

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Bz_Users      │────│  Bz_Meetings    │────│ Bz_Participants │
│ (USER_NAME)     │    │ (MEETING_TOPIC) │    │ (JOIN_TIME)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ Bz_Billing_     │    │ Bz_Feature_     │    │ Bz_Support_     │
│ Events          │    │ Usage           │    │ Tickets         │
│ (EVENT_TYPE)    │    │ (FEATURE_NAME)  │    │ (TICKET_TYPE)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                                             │
         │                                             │
         ▼                                             ▼
┌─────────────────┐                        ┌─────────────────┐
│  Bz_Licenses    │                        │  Bz_Webinars    │
│ (LICENSE_TYPE)  │                        │ (WEBINAR_TOPIC) │
└─────────────────┘                        └─────────────────┘
```

**Key Relationship Connections:**
1. **Bz_Users** connects to **Bz_Meetings** via USER_NAME (logical relationship)
2. **Bz_Meetings** connects to **Bz_Participants** via meeting context
3. **Bz_Users** connects to **Bz_Billing_Events** via user account context
4. **Bz_Meetings** connects to **Bz_Feature_Usage** via meeting session context
5. **Bz_Users** connects to **Bz_Support_Tickets** via user account context
6. **Bz_Users** connects to **Bz_Licenses** via user assignment context
7. **Bz_Users** connects to **Bz_Webinars** via host and participant context