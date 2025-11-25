# Snowflake Raw Layer Schema Metadata

## BILLING_EVENTS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| EVENT_ID | Unique identifier for each billing event | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| USER_ID | Reference to the user associated with the billing event | VARCHAR(16777216) | Foreign Key, Not Null | N/A |
| EVENT_TYPE | Type of billing event (charge, refund, etc.) | VARCHAR(16777216) | Not Null | charge, refund, adjustment |
| AMOUNT | Monetary amount of the billing event | VARCHAR(16777216) | Not Null | N/A |
| EVENT_DATE | Date when the billing event occurred | DATE | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Nullable | N/A |
| SOURCE_SYSTEM | System that originated the billing event data | VARCHAR(16777216) | Not Null | N/A |

## FEATURE_USAGE
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| USAGE_ID | Unique identifier for each feature usage record | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| MEETING_ID | Reference to the meeting where the feature was used | VARCHAR(16777216) | Foreign Key, Not Null | N/A |
| FEATURE_NAME | Name of the feature that was used | VARCHAR(16777216) | Not Null | screen_share, recording, chat, breakout_rooms |
| USAGE_COUNT | Number of times the feature was used | NUMBER(38,0) | Not Null | N/A |
| USAGE_DATE | Date when the feature usage occurred | DATE | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Nullable | N/A |
| SOURCE_SYSTEM | System that originated the feature usage data | VARCHAR(16777216) | Not Null | N/A |

## LICENSES
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| LICENSE_ID | Unique identifier for each license | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| LICENSE_TYPE | Type of license (Basic, Pro, Enterprise) | VARCHAR(16777216) | Not Null | Basic, Pro, Enterprise |
| ASSIGNED_TO_USER_ID | User ID to whom the license is assigned | VARCHAR(16777216) | Foreign Key, Nullable | N/A |
| START_DATE | Date when the license becomes active | DATE | Not Null | N/A |
| END_DATE | Date when the license expires | VARCHAR(16777216) | Nullable | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Nullable | N/A |
| SOURCE_SYSTEM | System that originated the license data | VARCHAR(16777216) | Not Null | N/A |

## MEETINGS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| MEETING_ID | Unique identifier for each meeting | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| HOST_ID | User ID of the meeting host | VARCHAR(16777216) | Foreign Key, Not Null | N/A |
| MEETING_TOPIC | Subject or topic of the meeting | VARCHAR(16777216) | Nullable | N/A |
| START_TIME | Timestamp when the meeting started | TIMESTAMP_NTZ(9) | Not Null | N/A |
| END_TIME | Timestamp when the meeting ended | VARCHAR(16777216) | Nullable | N/A |
| DURATION_MINUTES | Duration of the meeting in minutes | VARCHAR(16777216) | Nullable | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Nullable | N/A |
| SOURCE_SYSTEM | System that originated the meeting data | VARCHAR(16777216) | Not Null | N/A |

## PARTICIPANTS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| PARTICIPANT_ID | Unique identifier for each meeting participant | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| MEETING_ID | Reference to the meeting | VARCHAR(16777216) | Foreign Key, Not Null | N/A |
| USER_ID | Reference to the participating user | VARCHAR(16777216) | Foreign Key, Not Null | N/A |
| JOIN_TIME | Timestamp when the participant joined the meeting | VARCHAR(16777216) | Nullable | N/A |
| LEAVE_TIME | Timestamp when the participant left the meeting | TIMESTAMP_NTZ(9) | Nullable | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Nullable | N/A |
| SOURCE_SYSTEM | System that originated the participant data | VARCHAR(16777216) | Not Null | N/A |

## SUPPORT_TICKETS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| TICKET_ID | Unique identifier for each support ticket | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| USER_ID | Reference to the user who created the ticket | VARCHAR(16777216) | Foreign Key, Not Null | N/A |
| TICKET_TYPE | Category of the support ticket | VARCHAR(16777216) | Not Null | technical, billing, general |
| RESOLUTION_STATUS | Current status of the ticket resolution | VARCHAR(16777216) | Not Null | open, in_progress, resolved, closed |
| OPEN_DATE | Date when the ticket was opened | DATE | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Nullable | N/A |
| SOURCE_SYSTEM | System that originated the support ticket data | VARCHAR(16777216) | Not Null | N/A |

## USERS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| USER_ID | Unique identifier for each user account | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| USER_NAME | Display name of the user | VARCHAR(16777216) | Not Null | N/A |
| EMAIL | Email address of the user | VARCHAR(16777216) | Unique, Not Null | N/A |
| COMPANY | Company or organization the user belongs to | VARCHAR(16777216) | Nullable | N/A |
| PLAN_TYPE | Subscription plan type of the user | VARCHAR(16777216) | Not Null | Basic, Pro, Enterprise |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Nullable | N/A |
| SOURCE_SYSTEM | System that originated the user data | VARCHAR(16777216) | Not Null | N/A |

## JSON Metadata Summary

```json
{
  "schema_metadata": {
    "BILLING_EVENTS": {
      "type": "TABLE",
      "columns": [
        {"name": "EVENT_ID", "type": "VARCHAR(16777216)", "description": "Unique identifier for each billing event"},
        {"name": "USER_ID", "type": "VARCHAR(16777216)", "description": "Reference to the user associated with the billing event"},
        {"name": "EVENT_TYPE", "type": "VARCHAR(16777216)", "description": "Type of billing event (charge, refund, etc.)"},
        {"name": "AMOUNT", "type": "VARCHAR(16777216)", "description": "Monetary amount of the billing event"},
        {"name": "EVENT_DATE", "type": "DATE", "description": "Date when the billing event occurred"},
        {"name": "LOAD_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)", "description": "Timestamp when the record was loaded into the system"},
        {"name": "UPDATE_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)", "description": "Timestamp when the record was last updated"},
        {"name": "SOURCE_SYSTEM", "type": "VARCHAR(16777216)", "description": "System that originated the billing event data"}
      ]
    },
    "FEATURE_USAGE": {
      "type": "TABLE",
      "columns": [
        {"name": "USAGE_ID", "type": "VARCHAR(16777216)", "description": "Unique identifier for each feature usage record"},
        {"name": "MEETING_ID", "type": "VARCHAR(16777216)", "description": "Reference to the meeting where the feature was used"},
        {"name": "FEATURE_NAME", "type": "VARCHAR(16777216)", "description": "Name of the feature that was used"},
        {"name": "USAGE_COUNT", "type": "NUMBER(38,0)", "description": "Number of times the feature was used"},
        {"name": "USAGE_DATE", "type": "DATE", "description": "Date when the feature usage occurred"},
        {"name": "LOAD_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)", "description": "Timestamp when the record was loaded into the system"},
        {"name": "UPDATE_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)", "description": "Timestamp when the record was last updated"},
        {"name": "SOURCE_SYSTEM", "type": "VARCHAR(16777216)", "description": "System that originated the feature usage data"}
      ]
    },
    "LICENSES": {
      "type": "TABLE",
      "columns": [
        {"name": "LICENSE_ID", "type": "VARCHAR(16777216)", "description": "Unique identifier for each license"},
        {"name": "LICENSE_TYPE", "type": "VARCHAR(16777216)", "description": "Type of license (Basic, Pro, Enterprise)"},
        {"name": "ASSIGNED_TO_USER_ID", "type": "VARCHAR(16777216)", "description": "User ID to whom the license is assigned"},
        {"name": "START_DATE", "type": "DATE", "description": "Date when the license becomes active"},
        {"name": "END_DATE", "type": "VARCHAR(16777216)", "description": "Date when the license expires"},
        {"name": "LOAD_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)", "description": "Timestamp when the record was loaded into the system"},
        {"name": "UPDATE_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)", "description": "Timestamp when the record was last updated"},
        {"name": "SOURCE_SYSTEM", "type": "VARCHAR(16777216)", "description": "System that originated the license data"}
      ]
    },
    "MEETINGS": {
      "type": "TABLE",
      "columns": [
        {"name": "MEETING_ID", "type": "VARCHAR(16777216)", "description": "Unique identifier for each meeting"},
        {"name": "HOST_ID", "type": "VARCHAR(16777216)", "description": "User ID of the meeting host"},
        {"name": "MEETING_TOPIC", "type": "VARCHAR(16777216)", "description": "Subject or topic of the meeting"},
        {"name": "START_TIME", "type": "TIMESTAMP_NTZ(9)", "description": "Timestamp when the meeting started"},
        {"name": "END_TIME", "type": "VARCHAR(16777216)", "description": "Timestamp when the meeting ended"},
        {"name": "DURATION_MINUTES", "type": "VARCHAR(16777216)", "description": "Duration of the meeting in minutes"},
        {"name": "LOAD_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)", "description": "Timestamp when the record was loaded into the system"},
        {"name": "UPDATE_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)", "description": "Timestamp when the record was last updated"},
        {"name": "SOURCE_SYSTEM", "type": "VARCHAR(16777216)", "description": "System that originated the meeting data"}
      ]
    },
    "PARTICIPANTS": {
      "type": "TABLE",
      "columns": [
        {"name": "PARTICIPANT_ID", "type": "VARCHAR(16777216)", "description": "Unique identifier for each meeting participant"},
        {"name": "MEETING_ID", "type": "VARCHAR(16777216)", "description": "Reference to the meeting"},
        {"name": "USER_ID", "type": "VARCHAR(16777216)", "description": "Reference to the participating user"},
        {"name": "JOIN_TIME", "type": "VARCHAR(16777216)", "description": "Timestamp when the participant joined the meeting"},
        {"name": "LEAVE_TIME", "type": "TIMESTAMP_NTZ(9)", "description": "Timestamp when the participant left the meeting"},
        {"name": "LOAD_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)", "description": "Timestamp when the record was loaded into the system"},
        {"name": "UPDATE_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)", "description": "Timestamp when the record was last updated"},
        {"name": "SOURCE_SYSTEM", "type": "VARCHAR(16777216)", "description": "System that originated the participant data"}
      ]
    },
    "SUPPORT_TICKETS": {
      "type": "TABLE",
      "columns": [
        {"name": "TICKET_ID", "type": "VARCHAR(16777216)", "description": "Unique identifier for each support ticket"},
        {"name": "USER_ID", "type": "VARCHAR(16777216)", "description": "Reference to the user who created the ticket"},
        {"name": "TICKET_TYPE", "type": "VARCHAR(16777216)", "description": "Category of the support ticket"},
        {"name": "RESOLUTION_STATUS", "type": "VARCHAR(16777216)", "description": "Current status of the ticket resolution"},
        {"name": "OPEN_DATE", "type": "DATE", "description": "Date when the ticket was opened"},
        {"name": "LOAD_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)", "description": "Timestamp when the record was loaded into the system"},
        {"name": "UPDATE_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)", "description": "Timestamp when the record was last updated"},
        {"name": "SOURCE_SYSTEM", "type": "VARCHAR(16777216)", "description": "System that originated the support ticket data"}
      ]
    },
    "USERS": {
      "type": "TABLE",
      "columns": [
        {"name": "USER_ID", "type": "VARCHAR(16777216)", "description": "Unique identifier for each user account"},
        {"name": "USER_NAME", "type": "VARCHAR(16777216)", "description": "Display name of the user"},
        {"name": "EMAIL", "type": "VARCHAR(16777216)", "description": "Email address of the user"},
        {"name": "COMPANY", "type": "VARCHAR(16777216)", "description": "Company or organization the user belongs to"},
        {"name": "PLAN_TYPE", "type": "VARCHAR(16777216)", "description": "Subscription plan type of the user"},
        {"name": "LOAD_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)", "description": "Timestamp when the record was loaded into the system"},
        {"name": "UPDATE_TIMESTAMP", "type": "TIMESTAMP_NTZ(9)", "description": "Timestamp when the record was last updated"},
        {"name": "SOURCE_SYSTEM", "type": "VARCHAR(16777216)", "description": "System that originated the user data"}
      ]
    }
  }
}
```

**Pipeline ID:** 8083
**Output URL:** https://github.com/ZoomAscendion/Zoom/tree/Agent_Output/Raw_Schema