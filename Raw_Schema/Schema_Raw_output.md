# Snowflake RAW Layer Schema Metadata

This document contains metadata for all tables and views in the Snowflake RAW layer.

## BILLING_EVENTS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| EVENT_ID | Unique identifier for each billing event | VARCHAR(16777216) | N/A | N/A |
| USER_ID | Identifier linking to the user who generated the billing event | VARCHAR(16777216) | N/A | N/A |
| EVENT_TYPE | Type or category of the billing event | VARCHAR(16777216) | N/A | N/A |
| AMOUNT | Monetary amount associated with the billing event | VARCHAR(16777216) | N/A | N/A |
| EVENT_DATE | Date when the billing event occurred | DATE | N/A | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | N/A | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | N/A | N/A |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) | N/A | N/A |

## FEATURE_USAGE
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| USAGE_ID | Unique identifier for each feature usage record | VARCHAR(16777216) | N/A | N/A |
| MEETING_ID | Identifier linking to the meeting where feature was used | VARCHAR(16777216) | N/A | N/A |
| FEATURE_NAME | Name of the feature that was used | VARCHAR(16777216) | N/A | N/A |
| USAGE_COUNT | Number of times the feature was used | NUMBER(38,0) | N/A | N/A |
| USAGE_DATE | Date when the feature was used | DATE | N/A | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | N/A | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | N/A | N/A |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) | N/A | N/A |

## LICENSES
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| LICENSE_ID | Unique identifier for each license | VARCHAR(16777216) | N/A | N/A |
| LICENSE_TYPE | Type or category of the license | VARCHAR(16777216) | N/A | N/A |
| ASSIGNED_TO_USER_ID | User ID to whom the license is assigned | VARCHAR(16777216) | N/A | N/A |
| START_DATE | Date when the license becomes active | DATE | N/A | N/A |
| END_DATE | Date when the license expires | VARCHAR(16777216) | N/A | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | N/A | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | N/A | N/A |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) | N/A | N/A |

## MEETINGS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| MEETING_ID | Unique identifier for each meeting | VARCHAR(16777216) | N/A | N/A |
| HOST_ID | User ID of the meeting host | VARCHAR(16777216) | N/A | N/A |
| MEETING_TOPIC | Subject or topic of the meeting | VARCHAR(16777216) | N/A | N/A |
| START_TIME | Timestamp when the meeting started | TIMESTAMP_NTZ(9) | N/A | N/A |
| END_TIME | Timestamp when the meeting ended | VARCHAR(16777216) | N/A | N/A |
| DURATION_MINUTES | Duration of the meeting in minutes | VARCHAR(16777216) | N/A | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | N/A | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | N/A | N/A |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) | N/A | N/A |

## PARTICIPANTS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| PARTICIPANT_ID | Unique identifier for each meeting participant | VARCHAR(16777216) | N/A | N/A |
| MEETING_ID | Identifier linking to the meeting | VARCHAR(16777216) | N/A | N/A |
| USER_ID | Identifier of the user who participated in the meeting | VARCHAR(16777216) | N/A | N/A |
| JOIN_TIME | Time when the participant joined the meeting | VARCHAR(16777216) | N/A | N/A |
| LEAVE_TIME | Time when the participant left the meeting | TIMESTAMP_NTZ(9) | N/A | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | N/A | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | N/A | N/A |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) | N/A | N/A |

## SUPPORT_TICKETS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| TICKET_ID | Unique identifier for each support ticket | VARCHAR(16777216) | N/A | N/A |
| USER_ID | Identifier of the user who created the support ticket | VARCHAR(16777216) | N/A | N/A |
| TICKET_TYPE | Type or category of the support ticket | VARCHAR(16777216) | N/A | N/A |
| RESOLUTION_STATUS | Current status of the ticket resolution | VARCHAR(16777216) | N/A | N/A |
| OPEN_DATE | Date when the support ticket was opened | DATE | N/A | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | N/A | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | N/A | N/A |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) | N/A | N/A |

## USERS
| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| USER_ID | Unique identifier for each user account | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| USER_NAME | Display name of the user | VARCHAR(16777216) | N/A | N/A |
| EMAIL | Email address of the user | VARCHAR(16777216) | N/A | N/A |
| COMPANY | Company or organization the user belongs to | VARCHAR(16777216) | N/A | N/A |
| PLAN_TYPE | Type of subscription plan the user has | VARCHAR(16777216) | N/A | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | N/A | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | N/A | N/A |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) | N/A | N/A |

## Summary

The RAW layer contains 7 tables:
1. **BILLING_EVENTS** - Contains billing event information
2. **FEATURE_USAGE** - Tracks feature usage in meetings
3. **LICENSES** - Manages license assignments and validity
4. **MEETINGS** - Stores meeting details and metadata
5. **PARTICIPANTS** - Records meeting participation data
6. **SUPPORT_TICKETS** - Manages customer support requests
7. **USERS** - Contains user account information

All tables include standard audit fields (LOAD_TIMESTAMP, UPDATE_TIMESTAMP, SOURCE_SYSTEM) for data lineage and tracking purposes.

**Pipeline ID:** 8083
**Output URL:** https://github.com/DIAscendion/Ascendion/tree/Agent_Output/Raw_Schema/