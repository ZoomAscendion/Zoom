# Snowflake Raw Layer Schema Metadata

## BILLING_EVENTS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| EVENT_ID | Unique identifier for each billing event | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| USER_ID | Foreign key reference to user who generated the billing event | VARCHAR(16777216) | Not Null | N/A |
| EVENT_TYPE | Type of billing event (subscription, usage, etc.) | VARCHAR(16777216) | Not Null | N/A |
| AMOUNT | Monetary amount associated with the billing event | VARCHAR(16777216) | Not Null | N/A |
| EVENT_DATE | Date when the billing event occurred | DATE | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) | Not Null | N/A |

## FEATURE_USAGE
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| USAGE_ID | Unique identifier for each feature usage record | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| MEETING_ID | Foreign key reference to the meeting where feature was used | VARCHAR(16777216) | Not Null | N/A |
| FEATURE_NAME | Name of the feature that was used | VARCHAR(16777216) | Not Null | N/A |
| USAGE_COUNT | Number of times the feature was used | NUMBER(38,0) | Not Null | N/A |
| USAGE_DATE | Date when the feature usage occurred | DATE | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) | Not Null | N/A |

## LICENSES
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| LICENSE_ID | Unique identifier for each license | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| LICENSE_TYPE | Type of license (Basic, Pro, Enterprise, etc.) | VARCHAR(16777216) | Not Null | N/A |
| ASSIGNED_TO_USER_ID | Foreign key reference to user assigned to this license | VARCHAR(16777216) | Not Null | N/A |
| START_DATE | Date when the license becomes active | DATE | Not Null | N/A |
| END_DATE | Date when the license expires | VARCHAR(16777216) | Nullable | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) | Not Null | N/A |

## MEETINGS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| MEETING_ID | Unique identifier for each meeting | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| HOST_ID | Foreign key reference to user who hosted the meeting | VARCHAR(16777216) | Not Null | N/A |
| MEETING_TOPIC | Subject or topic of the meeting | VARCHAR(16777216) | Not Null | N/A |
| START_TIME | Timestamp when the meeting started | TIMESTAMP_NTZ(9) | Not Null | N/A |
| END_TIME | Timestamp when the meeting ended | VARCHAR(16777216) | Nullable | N/A |
| DURATION_MINUTES | Duration of the meeting in minutes | VARCHAR(16777216) | Nullable | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) | Not Null | N/A |

## PARTICIPANTS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| PARTICIPANT_ID | Unique identifier for each meeting participant | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| MEETING_ID | Foreign key reference to the meeting | VARCHAR(16777216) | Not Null | N/A |
| USER_ID | Foreign key reference to the participating user | VARCHAR(16777216) | Not Null | N/A |
| JOIN_TIME | Timestamp when the participant joined the meeting | VARCHAR(16777216) | Nullable | N/A |
| LEAVE_TIME | Timestamp when the participant left the meeting | TIMESTAMP_NTZ(9) | Nullable | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) | Not Null | N/A |

## SUPPORT_TICKETS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| TICKET_ID | Unique identifier for each support ticket | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| USER_ID | Foreign key reference to user who created the ticket | VARCHAR(16777216) | Not Null | N/A |
| TICKET_TYPE | Category or type of support ticket | VARCHAR(16777216) | Not Null | N/A |
| RESOLUTION_STATUS | Current status of the ticket resolution | VARCHAR(16777216) | Not Null | N/A |
| OPEN_DATE | Date when the support ticket was opened | DATE | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) | Not Null | N/A |

## USERS
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

**Pipeline ID:** 8083
**Generated on:** $(date)
**Total Tables:** 7
**Schema Layer:** RAW