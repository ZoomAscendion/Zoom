# Snowflake RAW Layer Schema Metadata

This document contains the complete metadata for all tables and views in the Snowflake RAW layer.

## BILLING_EVENTS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| EVENT_ID | Unique identifier for each billing event | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| USER_ID | Foreign key reference to user who generated the billing event | VARCHAR(16777216) | Foreign Key, Not Null | N/A |
| EVENT_TYPE | Type of billing event that occurred | VARCHAR(16777216) | Not Null | N/A |
| AMOUNT | Monetary amount associated with the billing event | VARCHAR(16777216) | Not Null | N/A |
| EVENT_DATE | Date when the billing event occurred | DATE | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Nullable | N/A |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) | Not Null | N/A |

## FEATURE_USAGE
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| USAGE_ID | Unique identifier for each feature usage record | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| MEETING_ID | Foreign key reference to the meeting where feature was used | VARCHAR(16777216) | Foreign Key, Not Null | N/A |
| FEATURE_NAME | Name of the feature that was used | VARCHAR(16777216) | Not Null | N/A |
| USAGE_COUNT | Number of times the feature was used | NUMBER(38,0) | Not Null | N/A |
| USAGE_DATE | Date when the feature usage occurred | DATE | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Nullable | N/A |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) | Not Null | N/A |

## LICENSES
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| LICENSE_ID | Unique identifier for each license | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| LICENSE_TYPE | Type or category of the license | VARCHAR(16777216) | Not Null | N/A |
| ASSIGNED_TO_USER_ID | Foreign key reference to user assigned to this license | VARCHAR(16777216) | Foreign Key, Nullable | N/A |
| START_DATE | Date when the license becomes active | DATE | Not Null | N/A |
| END_DATE | Date when the license expires | VARCHAR(16777216) | Nullable | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Nullable | N/A |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) | Not Null | N/A |

## MEETINGS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| MEETING_ID | Unique identifier for each meeting | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| HOST_ID | Foreign key reference to user who hosted the meeting | VARCHAR(16777216) | Foreign Key, Not Null | N/A |
| MEETING_TOPIC | Subject or topic of the meeting | VARCHAR(16777216) | Nullable | N/A |
| START_TIME | Timestamp when the meeting started | TIMESTAMP_NTZ(9) | Not Null | N/A |
| END_TIME | Timestamp when the meeting ended | VARCHAR(16777216) | Nullable | N/A |
| DURATION_MINUTES | Duration of the meeting in minutes | VARCHAR(16777216) | Nullable | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Nullable | N/A |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) | Not Null | N/A |

## PARTICIPANTS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| PARTICIPANT_ID | Unique identifier for each meeting participant record | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| MEETING_ID | Foreign key reference to the meeting | VARCHAR(16777216) | Foreign Key, Not Null | N/A |
| USER_ID | Foreign key reference to the participating user | VARCHAR(16777216) | Foreign Key, Not Null | N/A |
| JOIN_TIME | Timestamp when the participant joined the meeting | VARCHAR(16777216) | Nullable | N/A |
| LEAVE_TIME | Timestamp when the participant left the meeting | TIMESTAMP_NTZ(9) | Nullable | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Nullable | N/A |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) | Not Null | N/A |

## SUPPORT_TICKETS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| TICKET_ID | Unique identifier for each support ticket | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| USER_ID | Foreign key reference to user who created the ticket | VARCHAR(16777216) | Foreign Key, Not Null | N/A |
| TICKET_TYPE | Category or type of the support ticket | VARCHAR(16777216) | Not Null | N/A |
| RESOLUTION_STATUS | Current status of the ticket resolution | VARCHAR(16777216) | Not Null | N/A |
| OPEN_DATE | Date when the support ticket was opened | DATE | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Nullable | N/A |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) | Not Null | N/A |

## USERS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| USER_ID | Unique identifier for each user account | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| USER_NAME | Display name of the user | VARCHAR(16777216) | Not Null | N/A |
| EMAIL | Email address of the user | VARCHAR(16777216) | Unique, Not Null | N/A |
| COMPANY | Company or organization the user belongs to | VARCHAR(16777216) | Nullable | N/A |
| PLAN_TYPE | Type of subscription plan the user has | VARCHAR(16777216) | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Nullable | N/A |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) | Not Null | N/A |

## Summary

The RAW layer contains 7 tables:
1. **BILLING_EVENTS** - Contains billing event data
2. **FEATURE_USAGE** - Tracks feature usage in meetings
3. **LICENSES** - Manages license information
4. **MEETINGS** - Stores meeting details
5. **PARTICIPANTS** - Records meeting participation
6. **SUPPORT_TICKETS** - Manages support ticket data
7. **USERS** - Contains user account information

All tables include standard audit fields (LOAD_TIMESTAMP, UPDATE_TIMESTAMP, SOURCE_SYSTEM) for data lineage and tracking purposes.

**JSON Format of Complete Metadata:**

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