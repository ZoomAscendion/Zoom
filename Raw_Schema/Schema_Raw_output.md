# Raw Layer Schema Metadata

## BILLING_EVENTS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| EVENT_ID | Unique identifier for each billing event | VARCHAR(16777216) | Primary Key | N/A |
| USER_ID | Reference to user associated with billing event | VARCHAR(16777216) | Foreign Key | N/A |
| EVENT_TYPE | Type of billing event | VARCHAR(16777216) | Not Null | N/A |
| AMOUNT | Billing amount for the event | VARCHAR(16777216) | Not Null | N/A |
| EVENT_DATE | Date when the billing event occurred | DATE | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when record was loaded | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | Source system that provided the data | VARCHAR(16777216) | Not Null | N/A |

## FEATURE_USAGE
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| USAGE_ID | Unique identifier for each feature usage record | VARCHAR(16777216) | Primary Key | N/A |
| MEETING_ID | Reference to meeting where feature was used | VARCHAR(16777216) | Foreign Key | N/A |
| FEATURE_NAME | Name of the feature used | VARCHAR(16777216) | Not Null | N/A |
| USAGE_COUNT | Number of times feature was used | NUMBER(38,0) | Not Null | N/A |
| USAGE_DATE | Date when feature was used | DATE | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when record was loaded | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | Source system that provided the data | VARCHAR(16777216) | Not Null | N/A |

## LICENSES
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| LICENSE_ID | Unique identifier for each license | VARCHAR(16777216) | Primary Key | N/A |
| LICENSE_TYPE | Type of license | VARCHAR(16777216) | Not Null | N/A |
| ASSIGNED_TO_USER_ID | User ID to whom license is assigned | VARCHAR(16777216) | Foreign Key | N/A |
| START_DATE | License start date | DATE | Not Null | N/A |
| END_DATE | License end date | VARCHAR(16777216) | Nullable | N/A |
| LOAD_TIMESTAMP | Timestamp when record was loaded | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | Source system that provided the data | VARCHAR(16777216) | Not Null | N/A |

## MEETINGS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| MEETING_ID | Unique identifier for each meeting | VARCHAR(16777216) | Primary Key | N/A |
| HOST_ID | User ID of the meeting host | VARCHAR(16777216) | Foreign Key | N/A |
| MEETING_TOPIC | Topic or title of the meeting | VARCHAR(16777216) | Nullable | N/A |
| START_TIME | Meeting start timestamp | TIMESTAMP_NTZ(9) | Not Null | N/A |
| END_TIME | Meeting end timestamp | VARCHAR(16777216) | Nullable | N/A |
| DURATION_MINUTES | Meeting duration in minutes | VARCHAR(16777216) | Nullable | N/A |
| LOAD_TIMESTAMP | Timestamp when record was loaded | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | Source system that provided the data | VARCHAR(16777216) | Not Null | N/A |

## PARTICIPANTS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| PARTICIPANT_ID | Unique identifier for each participant record | VARCHAR(16777216) | Primary Key | N/A |
| MEETING_ID | Reference to the meeting | VARCHAR(16777216) | Foreign Key | N/A |
| USER_ID | Reference to the participating user | VARCHAR(16777216) | Foreign Key | N/A |
| JOIN_TIME | Time when participant joined the meeting | VARCHAR(16777216) | Nullable | N/A |
| LEAVE_TIME | Time when participant left the meeting | TIMESTAMP_NTZ(9) | Nullable | N/A |
| LOAD_TIMESTAMP | Timestamp when record was loaded | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | Source system that provided the data | VARCHAR(16777216) | Not Null | N/A |

## SUPPORT_TICKETS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| TICKET_ID | Unique identifier for each support ticket | VARCHAR(16777216) | Primary Key | N/A |
| USER_ID | Reference to user who created the ticket | VARCHAR(16777216) | Foreign Key | N/A |
| TICKET_TYPE | Type or category of support ticket | VARCHAR(16777216) | Not Null | N/A |
| RESOLUTION_STATUS | Current status of ticket resolution | VARCHAR(16777216) | Not Null | N/A |
| OPEN_DATE | Date when ticket was opened | DATE | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when record was loaded | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | Source system that provided the data | VARCHAR(16777216) | Not Null | N/A |

## USERS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| USER_ID | Unique identifier for each user account | VARCHAR(16777216) | Primary Key | N/A |
| USER_NAME | Display name of the user | VARCHAR(16777216) | Not Null | N/A |
| EMAIL | Email address of the user | VARCHAR(16777216) | Not Null, Unique | N/A |
| COMPANY | Company or organization name | VARCHAR(16777216) | Nullable | N/A |
| PLAN_TYPE | Type of subscription plan | VARCHAR(16777216) | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when record was loaded | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | Source system that provided the data | VARCHAR(16777216) | Not Null | N/A |

## JSON Format Metadata

```json
{
  "raw_layer_metadata": {
    "BILLING_EVENTS": {
      "type": "TABLE",
      "columns": [
        {
          "name": "EVENT_ID",
          "type": "VARCHAR(16777216)",
          "business_description": "Unique identifier for each billing event",
          "constraints": "Primary Key"
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
          "business_description": "Type of billing event",
          "constraints": "Not Null"
        },
        {
          "name": "AMOUNT",
          "type": "VARCHAR(16777216)",
          "business_description": "Billing amount for the event",
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
          "business_description": "Timestamp when record was loaded",
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
          "business_description": "Source system that provided the data",
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
          "constraints": "Primary Key"
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
          "business_description": "Name of the feature used",
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
          "business_description": "Date when feature was used",
          "constraints": "Not Null"
        },
        {
          "name": "LOAD_TIMESTAMP",
          "type": "TIMESTAMP_NTZ(9)",
          "business_description": "Timestamp when record was loaded",
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
          "business_description": "Source system that provided the data",
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
          "constraints": "Primary Key"
        },
        {
          "name": "LICENSE_TYPE",
          "type": "VARCHAR(16777216)",
          "business_description": "Type of license",
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
          "business_description": "License start date",
          "constraints": "Not Null"
        },
        {
          "name": "END_DATE",
          "type": "VARCHAR(16777216)",
          "business_description": "License end date",
          "constraints": "Nullable"
        },
        {
          "name": "LOAD_TIMESTAMP",
          "type": "TIMESTAMP_NTZ(9)",
          "business_description": "Timestamp when record was loaded",
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
          "business_description": "Source system that provided the data",
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
          "constraints": "Primary Key"
        },
        {
          "name": "HOST_ID",
          "type": "VARCHAR(16777216)",
          "business_description": "User ID of the meeting host",
          "constraints": "Foreign Key"
        },
        {
          "name": "MEETING_TOPIC",
          "type": "VARCHAR(16777216)",
          "business_description": "Topic or title of the meeting",
          "constraints": "Nullable"
        },
        {
          "name": "START_TIME",
          "type": "TIMESTAMP_NTZ(9)",
          "business_description": "Meeting start timestamp",
          "constraints": "Not Null"
        },
        {
          "name": "END_TIME",
          "type": "VARCHAR(16777216)",
          "business_description": "Meeting end timestamp",
          "constraints": "Nullable"
        },
        {
          "name": "DURATION_MINUTES",
          "type": "VARCHAR(16777216)",
          "business_description": "Meeting duration in minutes",
          "constraints": "Nullable"
        },
        {
          "name": "LOAD_TIMESTAMP",
          "type": "TIMESTAMP_NTZ(9)",
          "business_description": "Timestamp when record was loaded",
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
          "business_description": "Source system that provided the data",
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
          "business_description": "Unique identifier for each participant record",
          "constraints": "Primary Key"
        },
        {
          "name": "MEETING_ID",
          "type": "VARCHAR(16777216)",
          "business_description": "Reference to the meeting",
          "constraints": "Foreign Key"
        },
        {
          "name": "USER_ID",
          "type": "VARCHAR(16777216)",
          "business_description": "Reference to the participating user",
          "constraints": "Foreign Key"
        },
        {
          "name": "JOIN_TIME",
          "type": "VARCHAR(16777216)",
          "business_description": "Time when participant joined the meeting",
          "constraints": "Nullable"
        },
        {
          "name": "LEAVE_TIME",
          "type": "TIMESTAMP_NTZ(9)",
          "business_description": "Time when participant left the meeting",
          "constraints": "Nullable"
        },
        {
          "name": "LOAD_TIMESTAMP",
          "type": "TIMESTAMP_NTZ(9)",
          "business_description": "Timestamp when record was loaded",
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
          "business_description": "Source system that provided the data",
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
          "constraints": "Primary Key"
        },
        {
          "name": "USER_ID",
          "type": "VARCHAR(16777216)",
          "business_description": "Reference to user who created the ticket",
          "constraints": "Foreign Key"
        },
        {
          "name": "TICKET_TYPE",
          "type": "VARCHAR(16777216)",
          "business_description": "Type or category of support ticket",
          "constraints": "Not Null"
        },
        {
          "name": "RESOLUTION_STATUS",
          "type": "VARCHAR(16777216)",
          "business_description": "Current status of ticket resolution",
          "constraints": "Not Null"
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
          "business_description": "Timestamp when record was loaded",
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
          "business_description": "Source system that provided the data",
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
          "constraints": "Primary Key"
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
          "business_description": "Timestamp when record was loaded",
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
          "business_description": "Source system that provided the data",
          "constraints": "Not Null"
        }
      ]
    }
  }
}
```