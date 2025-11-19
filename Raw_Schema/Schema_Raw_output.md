# Raw Layer Schema Metadata

## BILLING_EVENTS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| EVENT_ID | Unique identifier for each billing event | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| USER_ID | Reference to the user associated with the billing event | VARCHAR(16777216) | Foreign Key, Not Null | N/A |
| EVENT_TYPE | Type of billing event (charge, refund, etc.) | VARCHAR(16777216) | Not Null | charge, refund, adjustment |
| AMOUNT | Monetary amount for the billing event | VARCHAR(16777216) | Not Null | N/A |
| EVENT_DATE | Date when the billing event occurred | DATE | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | Nullable | N/A |
| SOURCE_SYSTEM | System that originated the billing event data | VARCHAR(16777216) | Not Null | N/A |

## FEATURE_USAGE
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| USAGE_ID | Unique identifier for each feature usage record | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| MEETING_ID | Reference to the meeting where feature was used | VARCHAR(16777216) | Foreign Key, Not Null | N/A |
| FEATURE_NAME | Name of the feature that was used | VARCHAR(16777216) | Not Null | screen_share, recording, chat, breakout_rooms |
| USAGE_COUNT | Number of times the feature was used | NUMBER(38,0) | Not Null | N/A |
| USAGE_DATE | Date when the feature usage occurred | DATE | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | Nullable | N/A |
| SOURCE_SYSTEM | System that originated the feature usage data | VARCHAR(16777216) | Not Null | N/A |

## LICENSES
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| LICENSE_ID | Unique identifier for each license | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| LICENSE_TYPE | Type of license (Basic, Pro, Enterprise) | VARCHAR(16777216) | Not Null | Basic, Pro, Enterprise |
| ASSIGNED_TO_USER_ID | User ID to whom the license is assigned | VARCHAR(16777216) | Foreign Key, Nullable | N/A |
| START_DATE | Date when the license becomes active | DATE | Not Null | N/A |
| END_DATE | Date when the license expires | VARCHAR(16777216) | Nullable | N/A |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | Nullable | N/A |
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
| LOAD_TIMESTAMP | Timestamp when record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | Nullable | N/A |
| SOURCE_SYSTEM | System that originated the meeting data | VARCHAR(16777216) | Not Null | N/A |

## PARTICIPANTS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| PARTICIPANT_ID | Unique identifier for each meeting participant | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| MEETING_ID | Reference to the meeting | VARCHAR(16777216) | Foreign Key, Not Null | N/A |
| USER_ID | Reference to the participating user | VARCHAR(16777216) | Foreign Key, Not Null | N/A |
| JOIN_TIME | Timestamp when participant joined the meeting | VARCHAR(16777216) | Nullable | N/A |
| LEAVE_TIME | Timestamp when participant left the meeting | TIMESTAMP_NTZ(9) | Nullable | N/A |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | Nullable | N/A |
| SOURCE_SYSTEM | System that originated the participant data | VARCHAR(16777216) | Not Null | N/A |

## SUPPORT_TICKETS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| TICKET_ID | Unique identifier for each support ticket | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| USER_ID | Reference to the user who created the ticket | VARCHAR(16777216) | Foreign Key, Not Null | N/A |
| TICKET_TYPE | Category of the support ticket | VARCHAR(16777216) | Not Null | technical, billing, general |
| RESOLUTION_STATUS | Current status of the ticket resolution | VARCHAR(16777216) | Not Null | open, in_progress, resolved, closed |
| OPEN_DATE | Date when the ticket was opened | DATE | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | Nullable | N/A |
| SOURCE_SYSTEM | System that originated the support ticket data | VARCHAR(16777216) | Not Null | N/A |

## USERS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| USER_ID | Unique identifier for each user account | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| USER_NAME | Display name of the user | VARCHAR(16777216) | Not Null | N/A |
| EMAIL | Email address of the user | VARCHAR(16777216) | Unique, Not Null | N/A |
| COMPANY | Company or organization the user belongs to | VARCHAR(16777216) | Nullable | N/A |
| PLAN_TYPE | Type of subscription plan | VARCHAR(16777216) | Not Null | Basic, Pro, Enterprise |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | Nullable | N/A |
| SOURCE_SYSTEM | System that originated the user data | VARCHAR(16777216) | Not Null | N/A |

## JSON Format Metadata

```json
{
  "raw_layer_metadata": {
    "extraction_timestamp": "2024-12-19T10:30:00Z",
    "pipeline_id": 8083,
    "tables": {
      "BILLING_EVENTS": {
        "type": "TABLE",
        "columns": [
          {
            "name": "EVENT_ID",
            "type": "VARCHAR(16777216)",
            "business_description": "Unique identifier for each billing event",
            "constraints": "Primary Key, Not Null"
          },
          {
            "name": "USER_ID",
            "type": "VARCHAR(16777216)",
            "business_description": "Reference to the user associated with the billing event",
            "constraints": "Foreign Key, Not Null"
          },
          {
            "name": "EVENT_TYPE",
            "type": "VARCHAR(16777216)",
            "business_description": "Type of billing event (charge, refund, etc.)",
            "constraints": "Not Null"
          },
          {
            "name": "AMOUNT",
            "type": "VARCHAR(16777216)",
            "business_description": "Monetary amount for the billing event",
            "constraints": "Not Null"
          },
          {
            "name": "EVENT_DATE",
            "type": "DATE",
            "business_description": "Date when the billing event occurred",
            "constraints": "Not Null"
          },
          {
            "name": "LOAD_TIMESTAMP",
            "type": "TIMESTAMP_NTZ(9)",
            "business_description": "Timestamp when record was loaded into the system",
            "constraints": "Not Null"
          },
          {
            "name": "UPDATE_TIMESTAMP",
            "type": "TIMESTAMP_NTZ(9)",
            "business_description": "Timestamp when record was last updated",
            "constraints": "Nullable"
          },
          {
            "name": "SOURCE_SYSTEM",
            "type": "VARCHAR(16777216)",
            "business_description": "System that originated the billing event data",
            "constraints": "Not Null"
          }
        ]
      },
      "FEATURE_USAGE": {
        "type": "TABLE",
        "columns": [
          {
            "name": "USAGE_ID",
            "type": "VARCHAR(16777216)",
            "business_description": "Unique identifier for each feature usage record",
            "constraints": "Primary Key, Not Null"
          },
          {
            "name": "MEETING_ID",
            "type": "VARCHAR(16777216)",
            "business_description": "Reference to the meeting where feature was used",
            "constraints": "Foreign Key, Not Null"
          },
          {
            "name": "FEATURE_NAME",
            "type": "VARCHAR(16777216)",
            "business_description": "Name of the feature that was used",
            "constraints": "Not Null"
          },
          {
            "name": "USAGE_COUNT",
            "type": "NUMBER(38,0)",
            "business_description": "Number of times the feature was used",
            "constraints": "Not Null"
          },
          {
            "name": "USAGE_DATE",
            "type": "DATE",
            "business_description": "Date when the feature usage occurred",
            "constraints": "Not Null"
          },
          {
            "name": "LOAD_TIMESTAMP",
            "type": "TIMESTAMP_NTZ(9)",
            "business_description": "Timestamp when record was loaded into the system",
            "constraints": "Not Null"
          },
          {
            "name": "UPDATE_TIMESTAMP",
            "type": "TIMESTAMP_NTZ(9)",
            "business_description": "Timestamp when record was last updated",
            "constraints": "Nullable"
          },
          {
            "name": "SOURCE_SYSTEM",
            "type": "VARCHAR(16777216)",
            "business_description": "System that originated the feature usage data",
            "constraints": "Not Null"
          }
        ]
      },
      "LICENSES": {
        "type": "TABLE",
        "columns": [
          {
            "name": "LICENSE_ID",
            "type": "VARCHAR(16777216)",
            "business_description": "Unique identifier for each license",
            "constraints": "Primary Key, Not Null"
          },
          {
            "name": "LICENSE_TYPE",
            "type": "VARCHAR(16777216)",
            "business_description": "Type of license (Basic, Pro, Enterprise)",
            "constraints": "Not Null"
          },
          {
            "name": "ASSIGNED_TO_USER_ID",
            "type": "VARCHAR(16777216)",
            "business_description": "User ID to whom the license is assigned",
            "constraints": "Foreign Key, Nullable"
          },
          {
            "name": "START_DATE",
            "type": "DATE",
            "business_description": "Date when the license becomes active",
            "constraints": "Not Null"
          },
          {
            "name": "END_DATE",
            "type": "VARCHAR(16777216)",
            "business_description": "Date when the license expires",
            "constraints": "Nullable"
          },
          {
            "name": "LOAD_TIMESTAMP",
            "type": "TIMESTAMP_NTZ(9)",
            "business_description": "Timestamp when record was loaded into the system",
            "constraints": "Not Null"
          },
          {
            "name": "UPDATE_TIMESTAMP",
            "type": "TIMESTAMP_NTZ(9)",
            "business_description": "Timestamp when record was last updated",
            "constraints": "Nullable"
          },
          {
            "name": "SOURCE_SYSTEM",
            "type": "VARCHAR(16777216)",
            "business_description": "System that originated the license data",
            "constraints": "Not Null"
          }
        ]
      },
      "MEETINGS": {
        "type": "TABLE",
        "columns": [
          {
            "name": "MEETING_ID",
            "type": "VARCHAR(16777216)",
            "business_description": "Unique identifier for each meeting",
            "constraints": "Primary Key, Not Null"
          },
          {
            "name": "HOST_ID",
            "type": "VARCHAR(16777216)",
            "business_description": "User ID of the meeting host",
            "constraints": "Foreign Key, Not Null"
          },
          {
            "name": "MEETING_TOPIC",
            "type": "VARCHAR(16777216)",
            "business_description": "Subject or topic of the meeting",
            "constraints": "Nullable"
          },
          {
            "name": "START_TIME",
            "type": "TIMESTAMP_NTZ(9)",
            "business_description": "Timestamp when the meeting started",
            "constraints": "Not Null"
          },
          {
            "name": "END_TIME",
            "type": "VARCHAR(16777216)",
            "business_description": "Timestamp when the meeting ended",
            "constraints": "Nullable"
          },
          {
            "name": "DURATION_MINUTES",
            "type": "VARCHAR(16777216)",
            "business_description": "Duration of the meeting in minutes",
            "constraints": "Nullable"
          },
          {
            "name": "LOAD_TIMESTAMP",
            "type": "TIMESTAMP_NTZ(9)",
            "business_description": "Timestamp when record was loaded into the system",
            "constraints": "Not Null"
          },
          {
            "name": "UPDATE_TIMESTAMP",
            "type": "TIMESTAMP_NTZ(9)",
            "business_description": "Timestamp when record was last updated",
            "constraints": "Nullable"
          },
          {
            "name": "SOURCE_SYSTEM",
            "type": "VARCHAR(16777216)",
            "business_description": "System that originated the meeting data",
            "constraints": "Not Null"
          }
        ]
      },
      "PARTICIPANTS": {
        "type": "TABLE",
        "columns": [
          {
            "name": "PARTICIPANT_ID",
            "type": "VARCHAR(16777216)",
            "business_description": "Unique identifier for each meeting participant",
            "constraints": "Primary Key, Not Null"
          },
          {
            "name": "MEETING_ID",
            "type": "VARCHAR(16777216)",
            "business_description": "Reference to the meeting",
            "constraints": "Foreign Key, Not Null"
          },
          {
            "name": "USER_ID",
            "type": "VARCHAR(16777216)",
            "business_description": "Reference to the participating user",
            "constraints": "Foreign Key, Not Null"
          },
          {
            "name": "JOIN_TIME",
            "type": "VARCHAR(16777216)",
            "business_description": "Timestamp when participant joined the meeting",
            "constraints": "Nullable"
          },
          {
            "name": "LEAVE_TIME",
            "type": "TIMESTAMP_NTZ(9)",
            "business_description": "Timestamp when participant left the meeting",
            "constraints": "Nullable"
          },
          {
            "name": "LOAD_TIMESTAMP",
            "type": "TIMESTAMP_NTZ(9)",
            "business_description": "Timestamp when record was loaded into the system",
            "constraints": "Not Null"
          },
          {
            "name": "UPDATE_TIMESTAMP",
            "type": "TIMESTAMP_NTZ(9)",
            "business_description": "Timestamp when record was last updated",
            "constraints": "Nullable"
          },
          {
            "name": "SOURCE_SYSTEM",
            "type": "VARCHAR(16777216)",
            "business_description": "System that originated the participant data",
            "constraints": "Not Null"
          }
        ]
      },
      "SUPPORT_TICKETS": {
        "type": "TABLE",
        "columns": [
          {
            "name": "TICKET_ID",
            "type": "VARCHAR(16777216)",
            "business_description": "Unique identifier for each support ticket",
            "constraints": "Primary Key, Not Null"
          },
          {
            "name": "USER_ID",
            "type": "VARCHAR(16777216)",
            "business_description": "Reference to the user who created the ticket",
            "constraints": "Foreign Key, Not Null"
          },
          {
            "name": "TICKET_TYPE",
            "type": "VARCHAR(16777216)",
            "business_description": "Category of the support ticket",
            "constraints": "Not Null"
          },
          {
            "name": "RESOLUTION_STATUS",
            "type": "VARCHAR(16777216)",
            "business_description": "Current status of the ticket resolution",
            "constraints": "Not Null"
          },
          {
            "name": "OPEN_DATE",
            "type": "DATE",
            "business_description": "Date when the ticket was opened",
            "constraints": "Not Null"
          },
          {
            "name": "LOAD_TIMESTAMP",
            "type": "TIMESTAMP_NTZ(9)",
            "business_description": "Timestamp when record was loaded into the system",
            "constraints": "Not Null"
          },
          {
            "name": "UPDATE_TIMESTAMP",
            "type": "TIMESTAMP_NTZ(9)",
            "business_description": "Timestamp when record was last updated",
            "constraints": "Nullable"
          },
          {
            "name": "SOURCE_SYSTEM",
            "type": "VARCHAR(16777216)",
            "business_description": "System that originated the support ticket data",
            "constraints": "Not Null"
          }
        ]
      },
      "USERS": {
        "type": "TABLE",
        "columns": [
          {
            "name": "USER_ID",
            "type": "VARCHAR(16777216)",
            "business_description": "Unique identifier for each user account",
            "constraints": "Primary Key, Not Null"
          },
          {
            "name": "USER_NAME",
            "type": "VARCHAR(16777216)",
            "business_description": "Display name of the user",
            "constraints": "Not Null"
          },
          {
            "name": "EMAIL",
            "type": "VARCHAR(16777216)",
            "business_description": "Email address of the user",
            "constraints": "Unique, Not Null"
          },
          {
            "name": "COMPANY",
            "type": "VARCHAR(16777216)",
            "business_description": "Company or organization the user belongs to",
            "constraints": "Nullable"
          },
          {
            "name": "PLAN_TYPE",
            "type": "VARCHAR(16777216)",
            "business_description": "Type of subscription plan",
            "constraints": "Not Null"
          },
          {
            "name": "LOAD_TIMESTAMP",
            "type": "TIMESTAMP_NTZ(9)",
            "business_description": "Timestamp when record was loaded into the system",
            "constraints": "Not Null"
          },
          {
            "name": "UPDATE_TIMESTAMP",
            "type": "TIMESTAMP_NTZ(9)",
            "business_description": "Timestamp when record was last updated",
            "constraints": "Nullable"
          },
          {
            "name": "SOURCE_SYSTEM",
            "type": "VARCHAR(16777216)",
            "business_description": "System that originated the user data",
            "constraints": "Not Null"
          }
        ]
      }
    }
  }
}
```