# Snowflake Raw Layer Schema Metadata

## BILLING_EVENTS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| EVENT_ID | Unique identifier for each billing event | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| USER_ID | Foreign key reference to user account | VARCHAR(16777216) | Not Null | N/A |
| EVENT_TYPE | Type of billing event | VARCHAR(16777216) | Not Null | N/A |
| AMOUNT | Billing amount for the event | VARCHAR(16777216) | Not Null | N/A |
| EVENT_DATE | Date when the billing event occurred | DATE | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when record was loaded | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | Nullable | N/A |
| SOURCE_SYSTEM | Source system that provided the data | VARCHAR(16777216) | Not Null | N/A |

## FEATURE_USAGE
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| USAGE_ID | Unique identifier for each feature usage record | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| MEETING_ID | Foreign key reference to meeting | VARCHAR(16777216) | Not Null | N/A |
| FEATURE_NAME | Name of the feature used | VARCHAR(16777216) | Not Null | N/A |
| USAGE_COUNT | Number of times feature was used | NUMBER(38,0) | Not Null | N/A |
| USAGE_DATE | Date when feature was used | DATE | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when record was loaded | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | Nullable | N/A |
| SOURCE_SYSTEM | Source system that provided the data | VARCHAR(16777216) | Not Null | N/A |

## LICENSES
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| LICENSE_ID | Unique identifier for each license | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| LICENSE_TYPE | Type of license | VARCHAR(16777216) | Not Null | N/A |
| ASSIGNED_TO_USER_ID | User ID to whom license is assigned | VARCHAR(16777216) | Not Null | N/A |
| START_DATE | License start date | DATE | Not Null | N/A |
| END_DATE | License end date | VARCHAR(16777216) | Nullable | N/A |
| LOAD_TIMESTAMP | Timestamp when record was loaded | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | Nullable | N/A |
| SOURCE_SYSTEM | Source system that provided the data | VARCHAR(16777216) | Not Null | N/A |

## MEETINGS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| MEETING_ID | Unique identifier for each meeting | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| HOST_ID | User ID of the meeting host | VARCHAR(16777216) | Not Null | N/A |
| MEETING_TOPIC | Topic or title of the meeting | VARCHAR(16777216) | Nullable | N/A |
| START_TIME | Meeting start timestamp | TIMESTAMP_NTZ(9) | Not Null | N/A |
| END_TIME | Meeting end timestamp | VARCHAR(16777216) | Nullable | N/A |
| DURATION_MINUTES | Meeting duration in minutes | VARCHAR(16777216) | Nullable | N/A |
| LOAD_TIMESTAMP | Timestamp when record was loaded | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | Nullable | N/A |
| SOURCE_SYSTEM | Source system that provided the data | VARCHAR(16777216) | Not Null | N/A |

## PARTICIPANTS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| PARTICIPANT_ID | Unique identifier for each participant record | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| MEETING_ID | Foreign key reference to meeting | VARCHAR(16777216) | Not Null | N/A |
| USER_ID | Foreign key reference to user | VARCHAR(16777216) | Not Null | N/A |
| JOIN_TIME | Time when participant joined meeting | VARCHAR(16777216) | Nullable | N/A |
| LEAVE_TIME | Time when participant left meeting | TIMESTAMP_NTZ(9) | Nullable | N/A |
| LOAD_TIMESTAMP | Timestamp when record was loaded | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | Nullable | N/A |
| SOURCE_SYSTEM | Source system that provided the data | VARCHAR(16777216) | Not Null | N/A |

## SUPPORT_TICKETS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| TICKET_ID | Unique identifier for each support ticket | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| USER_ID | Foreign key reference to user who created ticket | VARCHAR(16777216) | Not Null | N/A |
| TICKET_TYPE | Type or category of support ticket | VARCHAR(16777216) | Not Null | N/A |
| RESOLUTION_STATUS | Current status of ticket resolution | VARCHAR(16777216) | Not Null | N/A |
| OPEN_DATE | Date when ticket was opened | DATE | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when record was loaded | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | Nullable | N/A |
| SOURCE_SYSTEM | Source system that provided the data | VARCHAR(16777216) | Not Null | N/A |

## USERS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| USER_ID | Unique identifier for each user account | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| USER_NAME | Display name of the user | VARCHAR(16777216) | Not Null | N/A |
| EMAIL | Email address of the user | VARCHAR(16777216) | Not Null, Unique | N/A |
| COMPANY | Company or organization name | VARCHAR(16777216) | Nullable | N/A |
| PLAN_TYPE | Type of subscription plan | VARCHAR(16777216) | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when record was loaded | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | Nullable | N/A |
| SOURCE_SYSTEM | Source system that provided the data | VARCHAR(16777216) | Not Null | N/A |

---

## JSON Format Metadata

```json
{
  "BILLING_EVENTS": {
    "type": "TABLE",
    "columns": [
      {
        "name": "EVENT_ID",
        "type": "VARCHAR(16777216)"
      },
      {
        "name": "USER_ID",
        "type": "VARCHAR(16777216)"
      },
      {
        "name": "EVENT_TYPE",
        "type": "VARCHAR(16777216)"
      },
      {
        "name": "AMOUNT",
        "type": "VARCHAR(16777216)"
      },
      {
        "name": "EVENT_DATE",
        "type": "DATE"
      },
      {
        "name": "LOAD_TIMESTAMP",
        "type": "TIMESTAMP_NTZ(9)"
      },
      {
        "name": "UPDATE_TIMESTAMP",
        "type": "TIMESTAMP_NTZ(9)"
      },
      {
        "name": "SOURCE_SYSTEM",
        "type": "VARCHAR(16777216)"
      }
    ]
  },
  "FEATURE_USAGE": {
    "type": "TABLE",
    "columns": [
      {
        "name": "USAGE_ID",
        "type": "VARCHAR(16777216)"
      },
      {
        "name": "MEETING_ID",
        "type": "VARCHAR(16777216)"
      },
      {
        "name": "FEATURE_NAME",
        "type": "VARCHAR(16777216)"
      },
      {
        "name": "USAGE_COUNT",
        "type": "NUMBER(38,0)"
      },
      {
        "name": "USAGE_DATE",
        "type": "DATE"
      },
      {
        "name": "LOAD_TIMESTAMP",
        "type": "TIMESTAMP_NTZ(9)"
      },
      {
        "name": "UPDATE_TIMESTAMP",
        "type": "TIMESTAMP_NTZ(9)"
      },
      {
        "name": "SOURCE_SYSTEM",
        "type": "VARCHAR(16777216)"
      }
    ]
  },
  "LICENSES": {
    "type": "TABLE",
    "columns": [
      {
        "name": "LICENSE_ID",
        "type": "VARCHAR(16777216)"
      },
      {
        "name": "LICENSE_TYPE",
        "type": "VARCHAR(16777216)"
      },
      {
        "name": "ASSIGNED_TO_USER_ID",
        "type": "VARCHAR(16777216)"
      },
      {
        "name": "START_DATE",
        "type": "DATE"
      },
      {
        "name": "END_DATE",
        "type": "VARCHAR(16777216)"
      },
      {
        "name": "LOAD_TIMESTAMP",
        "type": "TIMESTAMP_NTZ(9)"
      },
      {
        "name": "UPDATE_TIMESTAMP",
        "type": "TIMESTAMP_NTZ(9)"
      },
      {
        "name": "SOURCE_SYSTEM",
        "type": "VARCHAR(16777216)"
      }
    ]
  },
  "MEETINGS": {
    "type": "TABLE",
    "columns": [
      {
        "name": "MEETING_ID",
        "type": "VARCHAR(16777216)"
      },
      {
        "name": "HOST_ID",
        "type": "VARCHAR(16777216)"
      },
      {
        "name": "MEETING_TOPIC",
        "type": "VARCHAR(16777216)"
      },
      {
        "name": "START_TIME",
        "type": "TIMESTAMP_NTZ(9)"
      },
      {
        "name": "END_TIME",
        "type": "VARCHAR(16777216)"
      },
      {
        "name": "DURATION_MINUTES",
        "type": "VARCHAR(16777216)"
      },
      {
        "name": "LOAD_TIMESTAMP",
        "type": "TIMESTAMP_NTZ(9)"
      },
      {
        "name": "UPDATE_TIMESTAMP",
        "type": "TIMESTAMP_NTZ(9)"
      },
      {
        "name": "SOURCE_SYSTEM",
        "type": "VARCHAR(16777216)"
      }
    ]
  },
  "PARTICIPANTS": {
    "type": "TABLE",
    "columns": [
      {
        "name": "PARTICIPANT_ID",
        "type": "VARCHAR(16777216)"
      },
      {
        "name": "MEETING_ID",
        "type": "VARCHAR(16777216)"
      },
      {
        "name": "USER_ID",
        "type": "VARCHAR(16777216)"
      },
      {
        "name": "JOIN_TIME",
        "type": "VARCHAR(16777216)"
      },
      {
        "name": "LEAVE_TIME",
        "type": "TIMESTAMP_NTZ(9)"
      },
      {
        "name": "LOAD_TIMESTAMP",
        "type": "TIMESTAMP_NTZ(9)"
      },
      {
        "name": "UPDATE_TIMESTAMP",
        "type": "TIMESTAMP_NTZ(9)"
      },
      {
        "name": "SOURCE_SYSTEM",
        "type": "VARCHAR(16777216)"
      }
    ]
  },
  "SUPPORT_TICKETS": {
    "type": "TABLE",
    "columns": [
      {
        "name": "TICKET_ID",
        "type": "VARCHAR(16777216)"
      },
      {
        "name": "USER_ID",
        "type": "VARCHAR(16777216)"
      },
      {
        "name": "TICKET_TYPE",
        "type": "VARCHAR(16777216)"
      },
      {
        "name": "RESOLUTION_STATUS",
        "type": "VARCHAR(16777216)"
      },
      {
        "name": "OPEN_DATE",
        "type": "DATE"
      },
      {
        "name": "LOAD_TIMESTAMP",
        "type": "TIMESTAMP_NTZ(9)"
      },
      {
        "name": "UPDATE_TIMESTAMP",
        "type": "TIMESTAMP_NTZ(9)"
      },
      {
        "name": "SOURCE_SYSTEM",
        "type": "VARCHAR(16777216)"
      }
    ]
  },
  "USERS": {
    "type": "TABLE",
    "columns": [
      {
        "name": "USER_ID",
        "type": "VARCHAR(16777216)"
      },
      {
        "name": "USER_NAME",
        "type": "VARCHAR(16777216)"
      },
      {
        "name": "EMAIL",
        "type": "VARCHAR(16777216)"
      },
      {
        "name": "COMPANY",
        "type": "VARCHAR(16777216)"
      },
      {
        "name": "PLAN_TYPE",
        "type": "VARCHAR(16777216)"
      },
      {
        "name": "LOAD_TIMESTAMP",
        "type": "TIMESTAMP_NTZ(9)"
      },
      {
        "name": "UPDATE_TIMESTAMP",
        "type": "TIMESTAMP_NTZ(9)"
      },
      {
        "name": "SOURCE_SYSTEM",
        "type": "VARCHAR(16777216)"
      }
    ]
  }
}
```