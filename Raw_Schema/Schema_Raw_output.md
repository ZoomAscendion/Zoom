# Snowflake RAW Layer Metadata Documentation

## Database: DB_POC_ZOOM
## Schema: RAW
## Generated: 2024

---

## Table: BILLING_EVENTS

| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| EVENT_ID | Unique identifier for each billing event | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| USER_ID | Reference to the user associated with the billing event | VARCHAR(16777216) | Foreign Key, Not Null | N/A |
| EVENT_TYPE | Type of billing event (subscription, payment, refund, etc.) | VARCHAR(16777216) | Not Null | N/A |
| AMOUNT | Monetary amount associated with the billing event | NUMBER(10,2) | Not Null | N/A |
| EVENT_DATE | Date when the billing event occurred | DATE | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) | Not Null | N/A |

---

## Table: FEATURE_USAGE

| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| USAGE_ID | Unique identifier for each feature usage record | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| MEETING_ID | Reference to the meeting where the feature was used | VARCHAR(16777216) | Foreign Key, Not Null | N/A |
| FEATURE_NAME | Name of the feature that was used | VARCHAR(16777216) | Not Null | N/A |
| USAGE_COUNT | Number of times the feature was used | NUMBER(38,0) | Not Null | N/A |
| USAGE_DATE | Date when the feature was used | DATE | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) | Not Null | N/A |

---

## Table: LICENSES

| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| LICENSE_ID | Unique identifier for each license | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| LICENSE_TYPE | Type of license (Basic, Pro, Business, Enterprise) | VARCHAR(16777216) | Not Null | N/A |
| ASSIGNED_TO_USER_ID | User ID to whom the license is assigned | VARCHAR(16777216) | Foreign Key | N/A |
| START_DATE | Date when the license becomes active | DATE | Not Null | N/A |
| END_DATE | Date when the license expires | DATE | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) | Not Null | N/A |

---

## Table: MEETINGS

| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| MEETING_ID | Unique identifier for each meeting | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| HOST_ID | User ID of the meeting host | VARCHAR(16777216) | Foreign Key, Not Null | N/A |
| MEETING_TOPIC | Topic or title of the meeting | VARCHAR(16777216) | Not Null | N/A |
| START_TIME | Timestamp when the meeting started | TIMESTAMP_NTZ(9) | Not Null | N/A |
| END_TIME | Timestamp when the meeting ended | TIMESTAMP_NTZ(9) | Not Null | N/A |
| DURATION_MINUTES | Duration of the meeting in minutes | NUMBER(38,0) | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) | Not Null | N/A |

---

## Table: PARTICIPANTS

| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| PARTICIPANT_ID | Unique identifier for each participant record | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| MEETING_ID | Reference to the meeting the participant joined | VARCHAR(16777216) | Foreign Key, Not Null | N/A |
| USER_ID | User ID of the participant | VARCHAR(16777216) | Foreign Key, Not Null | N/A |
| JOIN_TIME | Timestamp when the participant joined the meeting | TIMESTAMP_NTZ(9) | Not Null | N/A |
| LEAVE_TIME | Timestamp when the participant left the meeting | TIMESTAMP_NTZ(9) | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) | Not Null | N/A |

---

## Table: SUPPORT_TICKETS

| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| TICKET_ID | Unique identifier for each support ticket | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| USER_ID | User ID who created the support ticket | VARCHAR(16777216) | Foreign Key, Not Null | N/A |
| TICKET_TYPE | Type or category of the support ticket | VARCHAR(16777216) | Not Null | N/A |
| RESOLUTION_STATUS | Current status of the ticket resolution | VARCHAR(16777216) | Not Null | N/A |
| OPEN_DATE | Date when the support ticket was opened | DATE | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) | Not Null | N/A |

---

## Table: USERS

| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| USER_ID | Unique identifier for each user account | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| USER_NAME | Display name of the user | VARCHAR(16777216) | Not Null | N/A |
| EMAIL | Email address of the user | VARCHAR(16777216) | Not Null, Unique | N/A |
| COMPANY | Company or organization the user belongs to | VARCHAR(16777216) | Nullable | N/A |
| PLAN_TYPE | Type of subscription plan the user has | VARCHAR(16777216) | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) | Not Null | N/A |

---

## Table: WEBINARS

| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| WEBINAR_ID | Unique identifier for each webinar | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| HOST_ID | User ID of the webinar host | VARCHAR(16777216) | Foreign Key, Not Null | N/A |
| WEBINAR_TOPIC | Topic or title of the webinar | VARCHAR(16777216) | Not Null | N/A |
| START_TIME | Timestamp when the webinar started | TIMESTAMP_NTZ(9) | Not Null | N/A |
| END_TIME | Timestamp when the webinar ended | TIMESTAMP_NTZ(9) | Not Null | N/A |
| REGISTRANTS | Number of users registered for the webinar | NUMBER(38,0) | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) | Not Null | N/A |

---

## JSON Format Metadata

```json
{
  "database": "DB_POC_ZOOM",
  "schema": "RAW",
  "tables": {
    "BILLING_EVENTS": {
      "type": "TABLE",
      "columns": [
        {"name": "EVENT_ID", "type": "VARCHAR(16777216)", "description": "Unique identifier for each billing event"},
        {"name": "USER_ID", "type": "VARCHAR(16777216)", "description": "Reference to the user associated with the billing event"},
        {"name": "EVENT_TYPE", "type": "VARCHAR(16777216)", "description": "Type of billing event"},
        {"name": "AMOUNT", "type": "NUMBER(10,2)", "description": "Monetary amount associated with the billing event"},
        {"name": "EVENT_DATE", "type": "DATE", "description": "Date when the billing event occurred"},
        {"name": "LOAD_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)", "description": "Timestamp when the record was loaded"},
        {"name": "UPDATE_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)", "description": "Timestamp when the record was last updated"},
        {"name": "SOURCE_SYSTEM", "type": "VARCHAR(16777216)", "description": "System from which the data originated"}
      ]
    },
    "FEATURE_USAGE": {
      "type": "TABLE",
      "columns": [
        {"name": "USAGE_ID", "type": "VARCHAR(16777216)", "description": "Unique identifier for each feature usage record"},
        {"name": "MEETING_ID", "type": "VARCHAR(16777216)", "description": "Reference to the meeting where the feature was used"},
        {"name": "FEATURE_NAME", "type": "VARCHAR(16777216)", "description": "Name of the feature that was used"},
        {"name": "USAGE_COUNT", "type": "NUMBER(38,0)", "description": "Number of times the feature was used"},
        {"name": "USAGE_DATE", "type": "DATE", "description": "Date when the feature was used"},
        {"name": "LOAD_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)", "description": "Timestamp when the record was loaded"},
        {"name": "UPDATE_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)", "description": "Timestamp when the record was last updated"},
        {"name": "SOURCE_SYSTEM", "type": "VARCHAR(16777216)", "description": "System from which the data originated"}
      ]
    },
    "LICENSES": {
      "type": "TABLE",
      "columns": [
        {"name": "LICENSE_ID", "type": "VARCHAR(16777216)", "description": "Unique identifier for each license"},
        {"name": "LICENSE_TYPE", "type": "VARCHAR(16777216)", "description": "Type of license"},
        {"name": "ASSIGNED_TO_USER_ID", "type": "VARCHAR(16777216)", "description": "User ID to whom the license is assigned"},
        {"name": "START_DATE", "type": "DATE", "description": "Date when the license becomes active"},
        {"name": "END_DATE", "type": "DATE", "description": "Date when the license expires"},
        {"name": "LOAD_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)", "description": "Timestamp when the record was loaded"},
        {"name": "UPDATE_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)", "description": "Timestamp when the record was last updated"},
        {"name": "SOURCE_SYSTEM", "type": "VARCHAR(16777216)", "description": "System from which the data originated"}
      ]
    },
    "MEETINGS": {
      "type": "TABLE",
      "columns": [
        {"name": "MEETING_ID", "type": "VARCHAR(16777216)", "description": "Unique identifier for each meeting"},
        {"name": "HOST_ID", "type": "VARCHAR(16777216)", "description": "User ID of the meeting host"},
        {"name": "MEETING_TOPIC", "type": "VARCHAR(16777216)", "description": "Topic or title of the meeting"},
        {"name": "START_TIME", "type": "TIMESTAMP_NTZ(9)", "description": "Timestamp when the meeting started"},
        {"name": "END_TIME", "type": "TIMESTAMP_NTZ(9)", "description": "Timestamp when the meeting ended"},
        {"name": "DURATION_MINUTES", "type": "NUMBER(38,0)", "description": "Duration of the meeting in minutes"},
        {"name": "LOAD_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)", "description": "Timestamp when the record was loaded"},
        {"name": "UPDATE_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)", "description": "Timestamp when the record was last updated"},
        {"name": "SOURCE_SYSTEM", "type": "VARCHAR(16777216)", "description": "System from which the data originated"}
      ]
    },
    "PARTICIPANTS": {
      "type": "TABLE",
      "columns": [
        {"name": "PARTICIPANT_ID", "type": "VARCHAR(16777216)", "description": "Unique identifier for each participant record"},
        {"name": "MEETING_ID", "type": "VARCHAR(16777216)", "description": "Reference to the meeting the participant joined"},
        {"name": "USER_ID", "type": "VARCHAR(16777216)", "description": "User ID of the participant"},
        {"name": "JOIN_TIME", "type": "TIMESTAMP_NTZ(9)", "description": "Timestamp when the participant joined the meeting"},
        {"name": "LEAVE_TIME", "type": "TIMESTAMP_NTZ(9)", "description": "Timestamp when the participant left the meeting"},
        {"name": "LOAD_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)", "description": "Timestamp when the record was loaded"},
        {"name": "UPDATE_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)", "description": "Timestamp when the record was last updated"},
        {"name": "SOURCE_SYSTEM", "type": "VARCHAR(16777216)", "description": "System from which the data originated"}
      ]
    },
    "SUPPORT_TICKETS": {
      "type": "TABLE",
      "columns": [
        {"name": "TICKET_ID", "type": "VARCHAR(16777216)", "description": "Unique identifier for each support ticket"},
        {"name": "USER_ID", "type": "VARCHAR(16777216)", "description": "User ID who created the support ticket"},
        {"name": "TICKET_TYPE", "type": "VARCHAR(16777216)", "description": "Type or category of the support ticket"},
        {"name": "RESOLUTION_STATUS", "type": "VARCHAR(16777216)", "description": "Current status of the ticket resolution"},
        {"name": "OPEN_DATE", "type": "DATE", "description": "Date when the support ticket was opened"},
        {"name": "LOAD_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)", "description": "Timestamp when the record was loaded"},
        {"name": "UPDATE_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)", "description": "Timestamp when the record was last updated"},
        {"name": "SOURCE_SYSTEM", "type": "VARCHAR(16777216)", "description": "System from which the data originated"}
      ]
    },
    "USERS": {
      "type": "TABLE",
      "columns": [
        {"name": "USER_ID", "type": "VARCHAR(16777216)", "description": "Unique identifier for each user account"},
        {"name": "USER_NAME", "type": "VARCHAR(16777216)", "description": "Display name of the user"},
        {"name": "EMAIL", "type": "VARCHAR(16777216)", "description": "Email address of the user"},
        {"name": "COMPANY", "type": "VARCHAR(16777216)", "description": "Company or organization the user belongs to"},
        {"name": "PLAN_TYPE", "type": "VARCHAR(16777216)", "description": "Type of subscription plan the user has"},
        {"name": "LOAD_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)", "description": "Timestamp when the record was loaded"},
        {"name": "UPDATE_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)", "description": "Timestamp when the record was last updated"},
        {"name": "SOURCE_SYSTEM", "type": "VARCHAR(16777216)", "description": "System from which the data originated"}
      ]
    },
    "WEBINARS": {
      "type": "TABLE",
      "columns": [
        {"name": "WEBINAR_ID", "type": "VARCHAR(16777216)", "description": "Unique identifier for each webinar"},
        {"name": "HOST_ID", "type": "VARCHAR(16777216)", "description": "User ID of the webinar host"},
        {"name": "WEBINAR_TOPIC", "type": "VARCHAR(16777216)", "description": "Topic or title of the webinar"},
        {"name": "START_TIME", "type": "TIMESTAMP_NTZ(9)", "description": "Timestamp when the webinar started"},
        {"name": "END_TIME", "type": "TIMESTAMP_NTZ(9)", "description": "Timestamp when the webinar ended"},
        {"name": "REGISTRANTS", "type": "NUMBER(38,0)", "description": "Number of users registered for the webinar"},
        {"name": "LOAD_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)", "description": "Timestamp when the record was loaded"},
        {"name": "UPDATE_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)", "description": "Timestamp when the record was last updated"},
        {"name": "SOURCE_SYSTEM", "type": "VARCHAR(16777216)", "description": "System from which the data originated"}
      ]
    }
  }
}
```

---

## Summary

This document contains the complete metadata for all 8 tables in the Snowflake RAW layer:

1. **BILLING_EVENTS** - Contains billing and payment event data
2. **FEATURE_USAGE** - Tracks usage of various Zoom features during meetings
3. **LICENSES** - Manages license assignments and validity periods
4. **MEETINGS** - Core meeting information and duration data
5. **PARTICIPANTS** - Tracks participant join/leave times for meetings
6. **SUPPORT_TICKETS** - Customer support ticket information
7. **USERS** - User account and profile information
8. **WEBINARS** - Webinar-specific data including registrant counts

All tables include standard audit fields (LOAD_TIMESTAMP, UPDATE_TIMESTAMP, SOURCE_SYSTEM) for data lineage and governance purposes.