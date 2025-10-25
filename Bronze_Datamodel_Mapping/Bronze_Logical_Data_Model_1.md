_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze Layer Logical Data Model for Zoom Platform Analytics System following medallion architecture
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Bronze Layer Logical Data Model for Zoom Platform Analytics System

## 1. PII Classification

| Column Name | Table Name | Reason for PII Classification |
|-------------|------------|-------------------------------|
| USER_NAME | Bz_USERS | Contains personal names that directly identify individuals, classified as PII under GDPR and other privacy regulations |
| EMAIL | Bz_USERS | Email addresses are personal contact information that can uniquely identify individuals and are considered sensitive PII |
| COMPANY | Bz_USERS | While not directly identifying, company information combined with other data can lead to individual identification |

## 2. Bronze Layer Logical Model

### 2.1 Bz_BILLING_EVENTS
**Description**: Stores all billing and payment events from the Zoom platform for financial tracking and analysis

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| EVENT_TYPE | VARCHAR(16777216) | Type of billing event such as subscription, payment, refund, upgrade, or downgrade |
| AMOUNT | NUMBER(10,2) | Monetary amount associated with the billing event in the specified currency |
| EVENT_DATE | DATE | Date when the billing event occurred in the source system |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was loaded into the Bronze layer for audit purposes |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the billing data originated |

### 2.2 Bz_FEATURE_USAGE
**Description**: Tracks usage of various Zoom platform features during meetings and sessions

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| FEATURE_NAME | VARCHAR(16777216) | Name of the Zoom feature used such as screen sharing, recording, chat, breakout rooms |
| USAGE_COUNT | NUMBER(38,0) | Number of times the specific feature was utilized during the session |
| USAGE_DATE | DATE | Date when the feature usage was recorded |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was loaded into the Bronze layer for audit purposes |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the feature usage data originated |

### 2.3 Bz_LICENSES
**Description**: Manages software license assignments and validity periods for Zoom platform users

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| LICENSE_TYPE | VARCHAR(16777216) | Type of Zoom license such as Basic, Pro, Business, Enterprise, or add-on licenses |
| START_DATE | DATE | Date when the license becomes active and available for use |
| END_DATE | DATE | Date when the license expires and is no longer valid |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was loaded into the Bronze layer for audit purposes |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the license data originated |

### 2.4 Bz_MEETINGS
**Description**: Core meeting information including duration, timing, and basic meeting metadata

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| MEETING_TOPIC | VARCHAR(16777216) | Subject or title of the meeting as specified by the host |
| START_TIME | TIMESTAMP_NTZ(9) | Timestamp when the meeting session began |
| END_TIME | TIMESTAMP_NTZ(9) | Timestamp when the meeting session concluded |
| DURATION_MINUTES | NUMBER(38,0) | Total duration of the meeting calculated in minutes |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was loaded into the Bronze layer for audit purposes |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the meeting data originated |

### 2.5 Bz_PARTICIPANTS
**Description**: Tracks participant join and leave times for meetings and attendance analysis

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| JOIN_TIME | TIMESTAMP_NTZ(9) | Timestamp when the participant joined the meeting session |
| LEAVE_TIME | TIMESTAMP_NTZ(9) | Timestamp when the participant left the meeting session |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was loaded into the Bronze layer for audit purposes |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the participant data originated |

### 2.6 Bz_SUPPORT_TICKETS
**Description**: Customer support ticket information for tracking service requests and issue resolution

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| TICKET_TYPE | VARCHAR(16777216) | Category of the support ticket such as Technical, Billing, Feature Request, or Account Issues |
| RESOLUTION_STATUS | VARCHAR(16777216) | Current status of the ticket such as Open, In Progress, Resolved, or Closed |
| OPEN_DATE | DATE | Date when the support ticket was initially created or opened |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was loaded into the Bronze layer for audit purposes |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the support ticket data originated |

### 2.7 Bz_USERS
**Description**: User account and profile information for Zoom platform users

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| USER_NAME | VARCHAR(16777216) | Display name of the user as shown in the Zoom platform |
| EMAIL | VARCHAR(16777216) | Primary email address associated with the user account for communication and identification |
| COMPANY | VARCHAR(16777216) | Organization or business entity that the user is associated with |
| PLAN_TYPE | VARCHAR(16777216) | Subscription plan type such as Free, Basic, Pro, Business, or Enterprise |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was loaded into the Bronze layer for audit purposes |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the user data originated |

### 2.8 Bz_WEBINARS
**Description**: Webinar-specific data including registrant information and webinar metadata

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| WEBINAR_TOPIC | VARCHAR(16777216) | Subject or title of the webinar as specified by the host |
| START_TIME | TIMESTAMP_NTZ(9) | Timestamp when the webinar session began |
| END_TIME | TIMESTAMP_NTZ(9) | Timestamp when the webinar session concluded |
| REGISTRANTS | NUMBER(38,0) | Total number of users who registered for the webinar |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was loaded into the Bronze layer for audit purposes |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the webinar data originated |

## 3. Audit Table Design

### 3.1 Bz_AUDIT_TABLE
**Description**: Comprehensive audit trail for tracking data processing activities across all Bronze layer tables

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| record_id | VARCHAR(16777216) | Unique identifier for each audit record entry |
| source_table | VARCHAR(16777216) | Name of the Bronze layer table being processed or audited |
| load_timestamp | TIMESTAMP_NTZ(9) | Timestamp when the data processing operation was initiated |
| processed_by | VARCHAR(16777216) | Identifier of the ETL process, job, or user who performed the data processing |
| processing_time | NUMBER(10,2) | Total time taken to process the record measured in seconds |
| status | VARCHAR(50) | Processing status indicator such as SUCCESS, FAILED, IN_PROGRESS, or SKIPPED |

## 4. Conceptual Data Model Diagram

**Block Diagram Format - Table Relationships:**

```
┌─────────────────┐         ┌─────────────────┐         ┌─────────────────┐
│   Bz_USERS      │         │   Bz_MEETINGS   │         │   Bz_WEBINARS   │
│                 │◄────────┤                 │         │                 │
│ USER_NAME       │  HOST   │ MEETING_TOPIC   │         │ WEBINAR_TOPIC   │
│ EMAIL           │   ID    │ START_TIME      │◄────────┤ START_TIME      │
│ COMPANY         │         │ END_TIME        │  HOST   │ END_TIME        │
│ PLAN_TYPE       │         │ DURATION_MIN    │   ID    │ REGISTRANTS     │
└─────────────────┘         └─────────────────┘         └─────────────────┘
         │                           │
         │                           │
         │                           ▼
         │                  ┌─────────────────┐
         │                  │ Bz_PARTICIPANTS │
         │                  │                 │
         │                  │ JOIN_TIME       │
         │                  │ LEAVE_TIME      │
         │                  └─────────────────┘
         │                           │
         │                           │
         │                           ▼
         │                  ┌─────────────────┐
         │                  │ Bz_FEATURE_USAGE│
         │                  │                 │
         │                  │ FEATURE_NAME    │
         │                  │ USAGE_COUNT     │
         │                  │ USAGE_DATE      │
         │                  └─────────────────┘
         │
         ├─────────────────────────────────────────────────────────┐
         │                                                         │
         ▼                                                         ▼
┌─────────────────┐         ┌─────────────────┐         ┌─────────────────┐
│ Bz_BILLING_EVENTS│         │   Bz_LICENSES   │         │Bz_SUPPORT_TICKETS│
│                 │         │                 │         │                 │
│ EVENT_TYPE      │         │ LICENSE_TYPE    │         │ TICKET_TYPE     │
│ AMOUNT          │         │ START_DATE      │         │ RESOLUTION_STATUS│
│ EVENT_DATE      │         │ END_DATE        │         │ OPEN_DATE       │
└─────────────────┘         └─────────────────┘         └─────────────────┘
```

**Key Relationships:**
1. **Bz_USERS** connects to **Bz_MEETINGS** via HOST_ID field
2. **Bz_USERS** connects to **Bz_WEBINARS** via HOST_ID field  
3. **Bz_MEETINGS** connects to **Bz_PARTICIPANTS** via MEETING_ID field
4. **Bz_MEETINGS** connects to **Bz_FEATURE_USAGE** via MEETING_ID field
5. **Bz_USERS** connects to **Bz_BILLING_EVENTS** via USER_ID field
6. **Bz_USERS** connects to **Bz_LICENSES** via ASSIGNED_TO_USER_ID field
7. **Bz_USERS** connects to **Bz_SUPPORT_TICKETS** via USER_ID field

**Note**: In the Bronze layer, primary key and foreign key fields have been removed as per medallion architecture principles, but logical relationships are maintained through the conceptual model for downstream Silver and Gold layer processing.