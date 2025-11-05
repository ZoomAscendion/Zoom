_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze layer logical data model for Zoom Platform Analytics System supporting medallion architecture
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Bronze Logical Data Model for Zoom Platform Analytics System

## 1. PII Classification

1. **USER_NAME** (from Bz_Users) - Contains personal identifiable information as it reveals the actual name of individuals
2. **EMAIL** (from Bz_Users) - Contains personal email addresses which are direct identifiers under GDPR and privacy regulations
3. **COMPANY** (from Bz_Users) - Contains organization affiliation data that can be used to identify individuals in specific contexts
4. **USER_ID** (relationship field) - Links to personal user data and serves as a unique identifier for individuals across the system
5. **HOST_ID** (relationship field) - Identifies meeting host user and can be traced back to personal user information
6. **ASSIGNED_TO_USER_ID** (relationship field) - Links license assignments to specific users, creating a direct connection to personal data

## 2. Bronze Layer Logical Model

### 2.1 Bz_Billing_Events
**Description:** Contains billing event information for Zoom services including charges, credits, and payment transactions

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| EVENT_TYPE | VARCHAR(16777216) | Type of billing event (charge, credit, refund, adjustment) |
| AMOUNT | NUMBER(10,2) | Monetary amount of the billing event |
| EVENT_DATE | DATE | Date when the billing event occurred |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the system |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated |
| USER_ID | VARCHAR(16777216) | Identifier linking to the user associated with the billing event |

### 2.2 Bz_Feature_Usage
**Description:** Tracks usage of various Zoom features during meetings and sessions

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| FEATURE_NAME | VARCHAR(16777216) | Name of the Zoom feature that was used |
| USAGE_COUNT | NUMBER(38,0) | Number of times the feature was used in the meeting |
| USAGE_DATE | DATE | Date when the feature usage occurred |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the system |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated |
| MEETING_ID | VARCHAR(16777216) | Identifier linking to the meeting where feature was used |

### 2.3 Bz_Licenses
**Description:** Contains information about Zoom licenses assigned to users including license types and validity periods

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| LICENSE_TYPE | VARCHAR(16777216) | Type of Zoom license (Basic, Pro, Business, Enterprise, Education) |
| START_DATE | DATE | Date when the license becomes active |
| END_DATE | DATE | Date when the license expires |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the system |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated |
| ASSIGNED_TO_USER_ID | VARCHAR(16777216) | User ID to whom the license is assigned |

### 2.4 Bz_Meetings
**Description:** Core table containing meeting information including scheduling, duration, and host details

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| MEETING_TOPIC | VARCHAR(16777216) | Subject or topic of the meeting |
| START_TIME | TIMESTAMP_NTZ(9) | Timestamp when the meeting started |
| END_TIME | TIMESTAMP_NTZ(9) | Timestamp when the meeting ended |
| DURATION_MINUTES | NUMBER(38,0) | Total duration of the meeting in minutes |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the system |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated |
| HOST_ID | VARCHAR(16777216) | User ID of the meeting host |

### 2.5 Bz_Participants
**Description:** Tracks individual participants in meetings including join/leave times and user details

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| JOIN_TIME | TIMESTAMP_NTZ(9) | Timestamp when the participant joined the meeting |
| LEAVE_TIME | TIMESTAMP_NTZ(9) | Timestamp when the participant left the meeting |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the system |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated |
| MEETING_ID | VARCHAR(16777216) | Identifier linking to the meeting the participant joined |
| USER_ID | VARCHAR(16777216) | Identifier of the user who participated in the meeting |

### 2.6 Bz_Support_Tickets
**Description:** Contains customer support ticket information including ticket types, status, and resolution details

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| TICKET_TYPE | VARCHAR(16777216) | Category or type of the support ticket |
| RESOLUTION_STATUS | VARCHAR(16777216) | Current status of the support ticket resolution |
| OPEN_DATE | DATE | Date when the support ticket was created |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the system |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated |
| USER_ID | VARCHAR(16777216) | Identifier of the user who created the support ticket |

### 2.7 Bz_Users
**Description:** Master table containing user account information including personal details and subscription plans

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| USER_NAME | VARCHAR(16777216) | Display name of the user |
| EMAIL | VARCHAR(16777216) | Email address of the user account |
| COMPANY | VARCHAR(16777216) | Company or organization the user is associated with |
| PLAN_TYPE | VARCHAR(16777216) | Subscription plan type for the user |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the system |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated |
| USER_ID | VARCHAR(16777216) | Unique identifier for each user account |

## 3. Audit Table Design

### 3.1 Bz_Audit
**Description:** Tracks data processing activities and changes in the Bronze layer for audit and monitoring purposes

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| RECORD_ID | VARCHAR(16777216) | Unique identifier for each audit record |
| SOURCE_TABLE | VARCHAR(16777216) | Name of the source table being processed |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the data processing occurred |
| PROCESSED_BY | VARCHAR(16777216) | Identifier of the process or user who processed the record |
| PROCESSING_TIME | NUMBER(38,0) | Duration taken to process the record in seconds |
| STATUS | VARCHAR(16777216) | Processing status (SUCCESS, FAILED, IN_PROGRESS) |

## 4. Conceptual Data Model Diagram

```
┌─────────────┐
│  Bz_Users   │
│             │
└──────┬──────┘
       │ USER_ID
       │
   ┌───┴────────────────────────────────────┐
   │                                        │
   ▼                                        ▼
┌─────────────┐                    ┌─────────────────┐
│ Bz_Meetings │                    │ Bz_Support_     │
│             │                    │ Tickets         │
└──────┬──────┘                    └─────────────────┘
       │ MEETING_ID                         │ USER_ID
       │                                    │
   ┌───┴──────────────┐                    │
   │                  │                    │
   ▼                  ▼                    │
┌─────────────┐  ┌─────────────┐           │
│Bz_Feature_  │  │Bz_Participants│          │
│Usage        │  │             │           │
└─────────────┘  └─────────────┘           │
                        │ USER_ID          │
                        │                  │
                        └──────────────────┘
                                           │
                    ┌──────────────────────┴──────────────────────┐
                    │                                             │
                    ▼                                             ▼
            ┌─────────────┐                              ┌─────────────┐
            │ Bz_Billing_ │                              │ Bz_Licenses │
            │ Events      │                              │             │
            └─────────────┘                              └─────────────┘
                 │ USER_ID                                    │ ASSIGNED_TO_USER_ID
                 │                                           │
                 └───────────────────────────────────────────┘
```

**Relationship Connections:**
1. **Bz_Users** connects to **Bz_Meetings** via **HOST_ID** field
2. **Bz_Users** connects to **Bz_Participants** via **USER_ID** field
3. **Bz_Users** connects to **Bz_Support_Tickets** via **USER_ID** field
4. **Bz_Users** connects to **Bz_Billing_Events** via **USER_ID** field
5. **Bz_Users** connects to **Bz_Licenses** via **ASSIGNED_TO_USER_ID** field
6. **Bz_Meetings** connects to **Bz_Participants** via **MEETING_ID** field
7. **Bz_Meetings** connects to **Bz_Feature_Usage** via **MEETING_ID** field