# Snowflake RAW Layer Metadata Documentation

This document contains metadata for all tables and views in the Snowflake RAW layer.

## BILLING_EVENTS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| EVENT_ID | Unique identifier for each billing event | VARCHAR(16777216) | Primary Key | N/A |
| USER_ID | Reference to the user associated with the billing event | VARCHAR(16777216) | Foreign Key | N/A |
| EVENT_TYPE | Type of billing event | VARCHAR(16777216) | Not Null | N/A |
| AMOUNT | Billing amount for the event | VARCHAR(16777216) | Not Null | N/A |
| EVENT_DATE | Date when the billing event occurred | DATE | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | Source system from which the data originated | VARCHAR(16777216) | Not Null | N/A |

## FEATURE_USAGE
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| USAGE_ID | Unique identifier for each feature usage record | VARCHAR(16777216) | Primary Key | N/A |
| MEETING_ID | Reference to the meeting where feature was used | VARCHAR(16777216) | Foreign Key | N/A |
| FEATURE_NAME | Name of the feature being used | VARCHAR(16777216) | Not Null | N/A |
| USAGE_COUNT | Number of times the feature was used | NUMBER(38,0) | Not Null | N/A |
| USAGE_DATE | Date when the feature was used | DATE | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | Source system from which the data originated | VARCHAR(16777216) | Not Null | N/A |

## LICENSES
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| LICENSE_ID | Unique identifier for each license | VARCHAR(16777216) | Primary Key | N/A |
| LICENSE_TYPE | Type of license | VARCHAR(16777216) | Not Null | N/A |
| ASSIGNED_TO_USER_ID | User ID to whom the license is assigned | VARCHAR(16777216) | Foreign Key | N/A |
| START_DATE | Start date of the license validity | DATE | Not Null | N/A |
| END_DATE | End date of the license validity | VARCHAR(16777216) | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | Source system from which the data originated | VARCHAR(16777216) | Not Null | N/A |

## MEETINGS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| MEETING_ID | Unique identifier for each meeting | VARCHAR(16777216) | Primary Key | N/A |
| HOST_ID | User ID of the meeting host | VARCHAR(16777216) | Foreign Key | N/A |
| MEETING_TOPIC | Topic or subject of the meeting | VARCHAR(16777216) | Not Null | N/A |
| START_TIME | Start time of the meeting | TIMESTAMP_NTZ(9) | Not Null | N/A |
| END_TIME | End time of the meeting | VARCHAR(16777216) | Not Null | N/A |
| DURATION_MINUTES | Duration of the meeting in minutes | VARCHAR(16777216) | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | Source system from which the data originated | VARCHAR(16777216) | Not Null | N/A |

## PARTICIPANTS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| PARTICIPANT_ID | Unique identifier for each participant record | VARCHAR(16777216) | Primary Key | N/A |
| MEETING_ID | Reference to the meeting | VARCHAR(16777216) | Foreign Key | N/A |
| USER_ID | Reference to the user who participated | VARCHAR(16777216) | Foreign Key | N/A |
| JOIN_TIME | Time when the participant joined the meeting | VARCHAR(16777216) | Not Null | N/A |
| LEAVE_TIME | Time when the participant left the meeting | TIMESTAMP_NTZ(9) | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | Source system from which the data originated | VARCHAR(16777216) | Not Null | N/A |

## SUPPORT_TICKETS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| TICKET_ID | Unique identifier for each support ticket | VARCHAR(16777216) | Primary Key | N/A |
| USER_ID | Reference to the user who created the ticket | VARCHAR(16777216) | Foreign Key | N/A |
| TICKET_TYPE | Type or category of the support ticket | VARCHAR(16777216) | Not Null | N/A |
| RESOLUTION_STATUS | Current status of the ticket resolution | VARCHAR(16777216) | Not Null | N/A |
| OPEN_DATE | Date when the ticket was opened | DATE | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | Source system from which the data originated | VARCHAR(16777216) | Not Null | N/A |

## USERS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| USER_ID | Unique identifier for each user account | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| USER_NAME | Name of the user | VARCHAR(16777216) | Not Null | N/A |
| EMAIL | Email address of the user | VARCHAR(16777216) | Not Null, Unique | N/A |
| COMPANY | Company or organization the user belongs to | VARCHAR(16777216) | Not Null | N/A |
| PLAN_TYPE | Type of subscription plan the user has | VARCHAR(16777216) | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | Source system from which the data originated | VARCHAR(16777216) | Not Null | N/A |

## JSON Metadata Summary

```json
{
  "raw_layer_metadata": {
    "BILLING_EVENTS": {
      "type": "TABLE",
      "columns": [
        {"name": "EVENT_ID", "type": "VARCHAR(16777216)"},
        {"name": "USER_ID", "type": "VARCHAR(16777216)"},
        {"name": "EVENT_TYPE", "type": "VARCHAR(16777216)"},
        {"name": "AMOUNT", "type": "VARCHAR(16777216)"},
        {"name": "EVENT_DATE", "type": "DATE"},
        {"name": "LOAD_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)"},
        {"name": "UPDATE_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)"},
        {"name": "SOURCE_SYSTEM", "type": "VARCHAR(16777216)"}
      ]
    },
    "FEATURE_USAGE": {
      "type": "TABLE",
      "columns": [
        {"name": "USAGE_ID", "type": "VARCHAR(16777216)"},
        {"name": "MEETING_ID", "type": "VARCHAR(16777216)"},
        {"name": "FEATURE_NAME", "type": "VARCHAR(16777216)"},
        {"name": "USAGE_COUNT", "type": "NUMBER(38,0)"},
        {"name": "USAGE_DATE", "type": "DATE"},
        {"name": "LOAD_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)"},
        {"name": "UPDATE_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)"},
        {"name": "SOURCE_SYSTEM", "type": "VARCHAR(16777216)"}
      ]
    },
    "LICENSES": {
      "type": "TABLE",
      "columns": [
        {"name": "LICENSE_ID", "type": "VARCHAR(16777216)"},
        {"name": "LICENSE_TYPE", "type": "VARCHAR(16777216)"},
        {"name": "ASSIGNED_TO_USER_ID", "type": "VARCHAR(16777216)"},
        {"name": "START_DATE", "type": "DATE"},
        {"name": "END_DATE", "type": "VARCHAR(16777216)"},
        {"name": "LOAD_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)"},
        {"name": "UPDATE_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)"},
        {"name": "SOURCE_SYSTEM", "type": "VARCHAR(16777216)"}
      ]
    },
    "MEETINGS": {
      "type": "TABLE",
      "columns": [
        {"name": "MEETING_ID", "type": "VARCHAR(16777216)"},
        {"name": "HOST_ID", "type": "VARCHAR(16777216)"},
        {"name": "MEETING_TOPIC", "type": "VARCHAR(16777216)"},
        {"name": "START_TIME", "type": "TIMESTAMP_NTZ(9)"},
        {"name": "END_TIME", "type": "VARCHAR(16777216)"},
        {"name": "DURATION_MINUTES", "type": "VARCHAR(16777216)"},
        {"name": "LOAD_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)"},
        {"name": "UPDATE_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)"},
        {"name": "SOURCE_SYSTEM", "type": "VARCHAR(16777216)"}
      ]
    },
    "PARTICIPANTS": {
      "type": "TABLE",
      "columns": [
        {"name": "PARTICIPANT_ID", "type": "VARCHAR(16777216)"},
        {"name": "MEETING_ID", "type": "VARCHAR(16777216)"},
        {"name": "USER_ID", "type": "VARCHAR(16777216)"},
        {"name": "JOIN_TIME", "type": "VARCHAR(16777216)"},
        {"name": "LEAVE_TIME", "type": "TIMESTAMP_NTZ(9)"},
        {"name": "LOAD_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)"},
        {"name": "UPDATE_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)"},
        {"name": "SOURCE_SYSTEM", "type": "VARCHAR(16777216)"}
      ]
    },
    "SUPPORT_TICKETS": {
      "type": "TABLE",
      "columns": [
        {"name": "TICKET_ID", "type": "VARCHAR(16777216)"},
        {"name": "USER_ID", "type": "VARCHAR(16777216)"},
        {"name": "TICKET_TYPE", "type": "VARCHAR(16777216)"},
        {"name": "RESOLUTION_STATUS", "type": "VARCHAR(16777216)"},
        {"name": "OPEN_DATE", "type": "DATE"},
        {"name": "LOAD_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)"},
        {"name": "UPDATE_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)"},
        {"name": "SOURCE_SYSTEM", "type": "VARCHAR(16777216)"}
      ]
    },
    "USERS": {
      "type": "TABLE",
      "columns": [
        {"name": "USER_ID", "type": "VARCHAR(16777216)"},
        {"name": "USER_NAME", "type": "VARCHAR(16777216)"},
        {"name": "EMAIL", "type": "VARCHAR(16777216)"},
        {"name": "COMPANY", "type": "VARCHAR(16777216)"},
        {"name": "PLAN_TYPE", "type": "VARCHAR(16777216)"},
        {"name": "LOAD_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)"},
        {"name": "UPDATE_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)"},
        {"name": "SOURCE_SYSTEM", "type": "VARCHAR(16777216)"}
      ]
    }
  }
}
```