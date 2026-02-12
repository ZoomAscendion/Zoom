# Snowflake RAW Layer Metadata Documentation

**Pipeline ID:** 8083  
**Extraction Date:** 2024-12-19  
**Total Tables:** 7  
**Total Views:** 0  

## Table Overview

The RAW layer contains 7 tables that store source data from various systems including billing, meetings, user management, and support systems.

---

## BILLING_EVENTS

**Description:** Contains billing event data for user transactions and charges

| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| EVENT_ID | Unique identifier for each billing event | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| USER_ID | Foreign key reference to user who triggered the billing event | VARCHAR(16777216) | Not Null | N/A |
| EVENT_TYPE | Type of billing event (subscription, usage, refund, etc.) | VARCHAR(16777216) | Not Null | subscription, usage, refund, upgrade, downgrade |
| AMOUNT | Monetary amount associated with the billing event | VARCHAR(16777216) | Not Null | N/A |
| EVENT_DATE | Date when the billing event occurred | DATE | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was first loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Nullable | N/A |
| SOURCE_SYSTEM | Source system from which the data originated | VARCHAR(16777216) | Not Null | billing_system, payment_gateway, subscription_service |

---

## FEATURE_USAGE

**Description:** Tracks usage of various features during meetings

| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| USAGE_ID | Unique identifier for each feature usage record | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| MEETING_ID | Foreign key reference to the meeting where feature was used | VARCHAR(16777216) | Not Null | N/A |
| FEATURE_NAME | Name of the feature that was used | VARCHAR(16777216) | Not Null | screen_share, recording, chat, whiteboard, breakout_rooms |
| USAGE_COUNT | Number of times the feature was used in the meeting | NUMBER(38,0) | Not Null | N/A |
| USAGE_DATE | Date when the feature usage occurred | DATE | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was first loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Nullable | N/A |
| SOURCE_SYSTEM | Source system from which the data originated | VARCHAR(16777216) | Not Null | meeting_platform, analytics_service |

---

## LICENSES

**Description:** Contains license information for users and their entitlements

| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| LICENSE_ID | Unique identifier for each license | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| LICENSE_TYPE | Type of license (Basic, Pro, Enterprise, etc.) | VARCHAR(16777216) | Not Null | Basic, Pro, Enterprise, Education |
| ASSIGNED_TO_USER_ID | Foreign key reference to the user assigned this license | VARCHAR(16777216) | Not Null | N/A |
| START_DATE | Date when the license becomes active | DATE | Not Null | N/A |
| END_DATE | Date when the license expires | VARCHAR(16777216) | Nullable | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was first loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Nullable | N/A |
| SOURCE_SYSTEM | Source system from which the data originated | VARCHAR(16777216) | Not Null | license_management, subscription_service |

---

## MEETINGS

**Description:** Contains meeting information including host, topic, and duration

| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| MEETING_ID | Unique identifier for each meeting | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| HOST_ID | Foreign key reference to the user who hosted the meeting | VARCHAR(16777216) | Not Null | N/A |
| MEETING_TOPIC | Topic or title of the meeting | VARCHAR(16777216) | Nullable | N/A |
| START_TIME | Timestamp when the meeting started | TIMESTAMP_NTZ(9) | Not Null | N/A |
| END_TIME | Timestamp when the meeting ended | VARCHAR(16777216) | Nullable | N/A |
| DURATION_MINUTES | Duration of the meeting in minutes | VARCHAR(16777216) | Nullable | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was first loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Nullable | N/A |
| SOURCE_SYSTEM | Source system from which the data originated | VARCHAR(16777216) | Not Null | meeting_platform, video_conferencing_service |

---

## PARTICIPANTS

**Description:** Contains information about meeting participants and their join/leave times

| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| PARTICIPANT_ID | Unique identifier for each participant record | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| MEETING_ID | Foreign key reference to the meeting | VARCHAR(16777216) | Not Null | N/A |
| USER_ID | Foreign key reference to the user who participated | VARCHAR(16777216) | Not Null | N/A |
| JOIN_TIME | Timestamp when the participant joined the meeting | VARCHAR(16777216) | Nullable | N/A |
| LEAVE_TIME | Timestamp when the participant left the meeting | TIMESTAMP_NTZ(9) | Nullable | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was first loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Nullable | N/A |
| SOURCE_SYSTEM | Source system from which the data originated | VARCHAR(16777216) | Not Null | meeting_platform, video_conferencing_service |

---

## SUPPORT_TICKETS

**Description:** Contains support ticket information for customer service tracking

| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| TICKET_ID | Unique identifier for each support ticket | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| USER_ID | Foreign key reference to the user who created the ticket | VARCHAR(16777216) | Not Null | N/A |
| TICKET_TYPE | Category or type of the support ticket | VARCHAR(16777216) | Not Null | technical, billing, feature_request, bug_report |
| RESOLUTION_STATUS | Current status of the ticket resolution | VARCHAR(16777216) | Not Null | open, in_progress, resolved, closed |
| OPEN_DATE | Date when the support ticket was opened | DATE | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was first loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Nullable | N/A |
| SOURCE_SYSTEM | Source system from which the data originated | VARCHAR(16777216) | Not Null | support_system, helpdesk, ticketing_system |

---

## USERS

**Description:** Contains user account information and profile data

| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| USER_ID | Unique identifier for each user account | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| USER_NAME | Display name of the user | VARCHAR(16777216) | Not Null | N/A |
| EMAIL | Email address of the user | VARCHAR(16777216) | Not Null, Unique | N/A |
| COMPANY | Company or organization the user belongs to | VARCHAR(16777216) | Nullable | N/A |
| PLAN_TYPE | Subscription plan type for the user | VARCHAR(16777216) | Not Null | Basic, Pro, Enterprise, Education |
| LOAD_TIMESTAMP | Timestamp when the record was first loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Nullable | N/A |
| SOURCE_SYSTEM | Source system from which the data originated | VARCHAR(16777216) | Not Null | user_management, identity_provider, registration_system |

---

## Data Lineage and Relationships

### Primary Relationships:
- **USERS.USER_ID** → Referenced by BILLING_EVENTS.USER_ID, LICENSES.ASSIGNED_TO_USER_ID, MEETINGS.HOST_ID, PARTICIPANTS.USER_ID, SUPPORT_TICKETS.USER_ID
- **MEETINGS.MEETING_ID** → Referenced by PARTICIPANTS.MEETING_ID, FEATURE_USAGE.MEETING_ID

### Common Audit Fields:
All tables include standard audit fields:
- **LOAD_TIMESTAMP**: When the record was first inserted
- **UPDATE_TIMESTAMP**: When the record was last modified
- **SOURCE_SYSTEM**: Origin system for data lineage tracking

---

**Generated on:** 2024-12-19  
**Pipeline ID:** 8083