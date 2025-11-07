# Snowflake RAW Layer Metadata Documentation

## Database: DB_POC_ZOOM
## Schema: RAW

---

## BILLING_EVENTS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| EVENT_ID | Unique identifier for each billing event | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| USER_ID | Reference to user associated with billing event | VARCHAR(16777216) | Foreign Key | N/A |
| EVENT_TYPE | Type of billing event (subscription, usage, etc.) | VARCHAR(16777216) | Not Null | N/A |
| AMOUNT | Monetary amount for the billing event | NUMBER(10,2) | Not Null | N/A |
| EVENT_DATE | Date when the billing event occurred | DATE | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when record was loaded into system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | Source system from which data originated | VARCHAR(16777216) | Not Null | N/A |

---

## FEATURE_USAGE
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| USAGE_ID | Unique identifier for each feature usage record | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| MEETING_ID | Reference to meeting where feature was used | VARCHAR(16777216) | Foreign Key | N/A |
| FEATURE_NAME | Name of the feature being tracked | VARCHAR(16777216) | Not Null | N/A |
| USAGE_COUNT | Number of times feature was used | NUMBER(38,0) | Not Null | N/A |
| USAGE_DATE | Date when feature usage occurred | DATE | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when record was loaded into system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | Source system from which data originated | VARCHAR(16777216) | Not Null | N/A |

---

## LICENSES
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| LICENSE_ID | Unique identifier for each license | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| LICENSE_TYPE | Type of license (Basic, Pro, Enterprise, etc.) | VARCHAR(16777216) | Not Null | N/A |
| ASSIGNED_TO_USER_ID | User ID to whom license is assigned | VARCHAR(16777216) | Foreign Key | N/A |
| START_DATE | License validity start date | DATE | Not Null | N/A |
| END_DATE | License validity end date | DATE | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when record was loaded into system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | Source system from which data originated | VARCHAR(16777216) | Not Null | N/A |

---

## MEETINGS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| MEETING_ID | Unique identifier for each meeting | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| HOST_ID | User ID of the meeting host | VARCHAR(16777216) | Foreign Key, Not Null | N/A |
| MEETING_TOPIC | Topic or title of the meeting | VARCHAR(16777216) | Not Null | N/A |
| START_TIME | Meeting start timestamp | TIMESTAMP_NTZ(9) | Not Null | N/A |
| END_TIME | Meeting end timestamp | TIMESTAMP_NTZ(9) | Not Null | N/A |
| DURATION_MINUTES | Meeting duration in minutes | NUMBER(38,0) | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when record was loaded into system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | Source system from which data originated | VARCHAR(16777216) | Not Null | N/A |

---

## PARTICIPANTS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| PARTICIPANT_ID | Unique identifier for each meeting participant | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| MEETING_ID | Reference to meeting | VARCHAR(16777216) | Foreign Key, Not Null | N/A |
| USER_ID | Reference to user who participated | VARCHAR(16777216) | Foreign Key, Not Null | N/A |
| JOIN_TIME | Timestamp when participant joined meeting | TIMESTAMP_NTZ(9) | Not Null | N/A |
| LEAVE_TIME | Timestamp when participant left meeting | TIMESTAMP_NTZ(9) | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when record was loaded into system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | Source system from which data originated | VARCHAR(16777216) | Not Null | N/A |

---

## SUPPORT_TICKETS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| TICKET_ID | Unique identifier for each support ticket | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| USER_ID | Reference to user who created the ticket | VARCHAR(16777216) | Foreign Key, Not Null | N/A |
| TICKET_TYPE | Type of support ticket (Technical, Billing, etc.) | VARCHAR(16777216) | Not Null | N/A |
| RESOLUTION_STATUS | Current status of ticket resolution | VARCHAR(16777216) | Not Null | Open, In Progress, Resolved, Closed |
| OPEN_DATE | Date when ticket was opened | DATE | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when record was loaded into system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | Source system from which data originated | VARCHAR(16777216) | Not Null | N/A |

---

## USERS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| USER_ID | Unique identifier for each user account | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| USER_NAME | Display name of the user | VARCHAR(16777216) | Not Null | N/A |
| EMAIL | Email address of the user | VARCHAR(16777216) | Not Null, Unique | N/A |
| COMPANY | Company or organization name | VARCHAR(16777216) | Not Null | N/A |
| PLAN_TYPE | Subscription plan type | VARCHAR(16777216) | Not Null | Basic, Pro, Business, Enterprise |
| LOAD_TIMESTAMP | Timestamp when record was loaded into system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | Source system from which data originated | VARCHAR(16777216) | Not Null | N/A |

---

## JSON Metadata Output

```json
{
  "database": "DB_POC_ZOOM",
  "schema": "RAW",
  "extraction_timestamp": "2024-12-19T10:30:00Z",
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
          "business_description": "Reference to user associated with billing event",
          "constraints": "Foreign Key"
        },
        {
          "name": "EVENT_TYPE",
          "type": "VARCHAR(16777216)",
          "business_description": "Type of billing event (subscription, usage, etc.)",
          "constraints": "Not Null"
        },
        {
          "name": "AMOUNT",
          "type": "NUMBER(10,2)",
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
          "business_description": "Timestamp when record was loaded into system",
          "constraints": "Not Null"
        },
        {
          "name": "UPDATE_TIMESTAMP",
          "type": "TIMESTAMP_NTZ(9)",
          "business_description": "Timestamp when record was last updated",
          "constraints": "Not Null"
        },
        {
          "name": "SOURCE_SYSTEM",
          "type": "VARCHAR(16777216)",
          "business_description": "Source system from which data originated",
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
          "business_description": "Reference to meeting where feature was used",
          "constraints": "Foreign Key"
        },
        {
          "name": "FEATURE_NAME",
          "type": "VARCHAR(16777216)",
          "business_description": "Name of the feature being tracked",
          "constraints": "Not Null"
        },
        {
          "name": "USAGE_COUNT",
          "type": "NUMBER(38,0)",
          "business_description": "Number of times feature was used",
          "constraints": "Not Null"
        },
        {
          "name": "USAGE_DATE",
          "type": "DATE",
          "business_description": "Date when feature usage occurred",
          "constraints": "Not Null"
        },
        {
          "name": "LOAD_TIMESTAMP",
          "type": "TIMESTAMP_NTZ(9)",
          "business_description": "Timestamp when record was loaded into system",
          "constraints": "Not Null"
        },
        {
          "name": "UPDATE_TIMESTAMP",
          "type": "TIMESTAMP_NTZ(9)",
          "business_description": "Timestamp when record was last updated",
          "constraints": "Not Null"
        },
        {
          "name": "SOURCE_SYSTEM",
          "type": "VARCHAR(16777216)",
          "business_description": "Source system from which data originated",
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
          "business_description": "Type of license (Basic, Pro, Enterprise, etc.)",
          "constraints": "Not Null"
        },
        {
          "name": "ASSIGNED_TO_USER_ID",
          "type": "VARCHAR(16777216)",
          "business_description": "User ID to whom license is assigned",
          "constraints": "Foreign Key"
        },
        {
          "name": "START_DATE",
          "type": "DATE",
          "business_description": "License validity start date",
          "constraints": "Not Null"
        },
        {
          "name": "END_DATE",
          "type": "DATE",
          "business_description": "License validity end date",
          "constraints": "Not Null"
        },
        {
          "name": "LOAD_TIMESTAMP",
          "type": "TIMESTAMP_NTZ(9)",
          "business_description": "Timestamp when record was loaded into system",
          "constraints": "Not Null"
        },
        {
          "name": "UPDATE_TIMESTAMP",
          "type": "TIMESTAMP_NTZ(9)",
          "business_description": "Timestamp when record was last updated",
          "constraints": "Not Null"
        },
        {
          "name": "SOURCE_SYSTEM",
          "type": "VARCHAR(16777216)",
          "business_description": "Source system from which data originated",
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
          "business_description": "Topic or title of the meeting",
          "constraints": "Not Null"
        },
        {
          "name": "START_TIME",
          "type": "TIMESTAMP_NTZ(9)",
          "business_description": "Meeting start timestamp",
          "constraints": "Not Null"
        },
        {
          "name": "END_TIME",
          "type": "TIMESTAMP_NTZ(9)",
          "business_description": "Meeting end timestamp",
          "constraints": "Not Null"
        },
        {
          "name": "DURATION_MINUTES",
          "type": "NUMBER(38,0)",
          "business_description": "Meeting duration in minutes",
          "constraints": "Not Null"
        },
        {
          "name": "LOAD_TIMESTAMP",
          "type": "TIMESTAMP_NTZ(9)",
          "business_description": "Timestamp when record was loaded into system",
          "constraints": "Not Null"
        },
        {
          "name": "UPDATE_TIMESTAMP",
          "type": "TIMESTAMP_NTZ(9)",
          "business_description": "Timestamp when record was last updated",
          "constraints": "Not Null"
        },
        {
          "name": "SOURCE_SYSTEM",
          "type": "VARCHAR(16777216)",
          "business_description": "Source system from which data originated",
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
          "business_description": "Reference to meeting",
          "constraints": "Foreign Key, Not Null"
        },
        {
          "name": "USER_ID",
          "type": "VARCHAR(16777216)",
          "business_description": "Reference to user who participated",
          "constraints": "Foreign Key, Not Null"
        },
        {
          "name": "JOIN_TIME",
          "type": "TIMESTAMP_NTZ(9)",
          "business_description": "Timestamp when participant joined meeting",
          "constraints": "Not Null"
        },
        {
          "name": "LEAVE_TIME",
          "type": "TIMESTAMP_NTZ(9)",
          "business_description": "Timestamp when participant left meeting",
          "constraints": "Not Null"
        },
        {
          "name": "LOAD_TIMESTAMP",
          "type": "TIMESTAMP_NTZ(9)",
          "business_description": "Timestamp when record was loaded into system",
          "constraints": "Not Null"
        },
        {
          "name": "UPDATE_TIMESTAMP",
          "type": "TIMESTAMP_NTZ(9)",
          "business_description": "Timestamp when record was last updated",
          "constraints": "Not Null"
        },
        {
          "name": "SOURCE_SYSTEM",
          "type": "VARCHAR(16777216)",
          "business_description": "Source system from which data originated",
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
          "business_description": "Reference to user who created the ticket",
          "constraints": "Foreign Key, Not Null"
        },
        {
          "name": "TICKET_TYPE",
          "type": "VARCHAR(16777216)",
          "business_description": "Type of support ticket (Technical, Billing, etc.)",
          "constraints": "Not Null"
        },
        {
          "name": "RESOLUTION_STATUS",
          "type": "VARCHAR(16777216)",
          "business_description": "Current status of ticket resolution",
          "constraints": "Not Null",
          "domain_values": "Open, In Progress, Resolved, Closed"
        },
        {
          "name": "OPEN_DATE",
          "type": "DATE",
          "business_description": "Date when ticket was opened",
          "constraints": "Not Null"
        },
        {
          "name": "LOAD_TIMESTAMP",
          "type": "TIMESTAMP_NTZ(9)",
          "business_description": "Timestamp when record was loaded into system",
          "constraints": "Not Null"
        },
        {
          "name": "UPDATE_TIMESTAMP",
          "type": "TIMESTAMP_NTZ(9)",
          "business_description": "Timestamp when record was last updated",
          "constraints": "Not Null"
        },
        {
          "name": "SOURCE_SYSTEM",
          "type": "VARCHAR(16777216)",
          "business_description": "Source system from which data originated",
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
          "constraints": "Not Null, Unique"
        },
        {
          "name": "COMPANY",
          "type": "VARCHAR(16777216)",
          "business_description": "Company or organization name",
          "constraints": "Not Null"
        },
        {
          "name": "PLAN_TYPE",
          "type": "VARCHAR(16777216)",
          "business_description": "Subscription plan type",
          "constraints": "Not Null",
          "domain_values": "Basic, Pro, Business, Enterprise"
        },
        {
          "name": "LOAD_TIMESTAMP",
          "type": "TIMESTAMP_NTZ(9)",
          "business_description": "Timestamp when record was loaded into system",
          "constraints": "Not Null"
        },
        {
          "name": "UPDATE_TIMESTAMP",
          "type": "TIMESTAMP_NTZ(9)",
          "business_description": "Timestamp when record was last updated",
          "constraints": "Not Null"
        },
        {
          "name": "SOURCE_SYSTEM",
          "type": "VARCHAR(16777216)",
          "business_description": "Source system from which data originated",
          "constraints": "Not Null"
        }
      ]
    }
  }
}
```