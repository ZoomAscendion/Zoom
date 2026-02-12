# Snowflake RAW Layer Metadata Documentation

## Overview
This document contains the complete metadata for all tables and views in the Snowflake RAW layer (YIELD_HUNTER schema).

---

## BILLING_EVENTS Table
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| EVENT_ID | Unique identifier for each billing event | VARCHAR(16777216) | N/A | N/A |
| USER_ID | Reference to user associated with billing event | VARCHAR(16777216) | N/A | N/A |
| EVENT_TYPE | Type of billing event | VARCHAR(16777216) | N/A | N/A |
| AMOUNT | Billing amount for the event | VARCHAR(16777216) | N/A | N/A |
| EVENT_DATE | Date when the billing event occurred | DATE | N/A | N/A |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the system | TIMESTAMP_NTZ(9) | N/A | N/A |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | N/A | N/A |
| SOURCE_SYSTEM | Source system from which data originated | VARCHAR(16777216) | N/A | N/A |

---

## FEATURE_USAGE Table
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| USAGE_ID | Unique identifier for each feature usage record | VARCHAR(16777216) | N/A | N/A |
| MEETING_ID | Reference to meeting where feature was used | VARCHAR(16777216) | N/A | N/A |
| FEATURE_NAME | Name of the feature used | VARCHAR(16777216) | N/A | N/A |
| USAGE_COUNT | Number of times feature was used | NUMBER(38,0) | N/A | N/A |
| USAGE_DATE | Date when feature was used | DATE | N/A | N/A |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the system | TIMESTAMP_NTZ(9) | N/A | N/A |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | N/A | N/A |
| SOURCE_SYSTEM | Source system from which data originated | VARCHAR(16777216) | N/A | N/A |

---

## LICENSES Table
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| LICENSE_ID | Unique identifier for each license | VARCHAR(16777216) | N/A | N/A |
| LICENSE_TYPE | Type of license | VARCHAR(16777216) | N/A | N/A |
| ASSIGNED_TO_USER_ID | User ID to whom license is assigned | VARCHAR(16777216) | N/A | N/A |
| START_DATE | License start date | DATE | N/A | N/A |
| END_DATE | License end date | VARCHAR(16777216) | N/A | N/A |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the system | TIMESTAMP_NTZ(9) | N/A | N/A |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | N/A | N/A |
| SOURCE_SYSTEM | Source system from which data originated | VARCHAR(16777216) | N/A | N/A |

---

## MEETINGS Table
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| MEETING_ID | Unique identifier for each meeting | VARCHAR(16777216) | N/A | N/A |
| HOST_ID | User ID of the meeting host | VARCHAR(16777216) | N/A | N/A |
| MEETING_TOPIC | Topic or title of the meeting | VARCHAR(16777216) | N/A | N/A |
| START_TIME | Meeting start timestamp | TIMESTAMP_NTZ(9) | N/A | N/A |
| END_TIME | Meeting end timestamp | VARCHAR(16777216) | N/A | N/A |
| DURATION_MINUTES | Meeting duration in minutes | VARCHAR(16777216) | N/A | N/A |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the system | TIMESTAMP_NTZ(9) | N/A | N/A |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | N/A | N/A |
| SOURCE_SYSTEM | Source system from which data originated | VARCHAR(16777216) | N/A | N/A |

---

## PARTICIPANTS Table
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| PARTICIPANT_ID | Unique identifier for each participant record | VARCHAR(16777216) | N/A | N/A |
| MEETING_ID | Reference to meeting | VARCHAR(16777216) | N/A | N/A |
| USER_ID | Reference to user who participated | VARCHAR(16777216) | N/A | N/A |
| JOIN_TIME | Time when participant joined the meeting | VARCHAR(16777216) | N/A | N/A |
| LEAVE_TIME | Time when participant left the meeting | TIMESTAMP_NTZ(9) | N/A | N/A |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the system | TIMESTAMP_NTZ(9) | N/A | N/A |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | N/A | N/A |
| SOURCE_SYSTEM | Source system from which data originated | VARCHAR(16777216) | N/A | N/A |

---

## SUPPORT_TICKETS Table
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| TICKET_ID | Unique identifier for each support ticket | VARCHAR(16777216) | N/A | N/A |
| USER_ID | Reference to user who created the ticket | VARCHAR(16777216) | N/A | N/A |
| TICKET_TYPE | Type or category of support ticket | VARCHAR(16777216) | N/A | N/A |
| RESOLUTION_STATUS | Current status of ticket resolution | VARCHAR(16777216) | N/A | N/A |
| OPEN_DATE | Date when ticket was opened | DATE | N/A | N/A |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the system | TIMESTAMP_NTZ(9) | N/A | N/A |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | N/A | N/A |
| SOURCE_SYSTEM | Source system from which data originated | VARCHAR(16777216) | N/A | N/A |

---

## USERS Table
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| USER_ID | Unique identifier for each user account | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| USER_NAME | Display name of the user | VARCHAR(16777216) | N/A | N/A |
| EMAIL | Email address of the user | VARCHAR(16777216) | N/A | N/A |
| COMPANY | Company or organization the user belongs to | VARCHAR(16777216) | N/A | N/A |
| PLAN_TYPE | Type of subscription plan | VARCHAR(16777216) | N/A | N/A |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the system | TIMESTAMP_NTZ(9) | N/A | N/A |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | N/A | N/A |
| SOURCE_SYSTEM | Source system from which data originated | VARCHAR(16777216) | N/A | N/A |

---

## Summary
- **Total Tables**: 7
- **Total Views**: 0
- **Database**: DB_POC_ZOOM
- **Schema**: YIELD_HUNTER
- **Generated On**: $(date)

## JSON Metadata
```json
{
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
```