# Snowflake RAW Layer Metadata Documentation

This document contains the complete metadata for all tables and views in the Snowflake RAW layer.

## BILLING_EVENTS Table

| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| EVENT_ID | Unique identifier for each billing event | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| USER_ID | Reference to the user associated with the billing event | VARCHAR(16777216) | Foreign Key, Not Null | N/A |
| EVENT_TYPE | Type of billing event (charge, refund, etc.) | VARCHAR(16777216) | Not Null | N/A |
| AMOUNT | Monetary amount for the billing event | VARCHAR(16777216) | Not Null | N/A |
| EVENT_DATE | Date when the billing event occurred | DATE | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | System that originated the data | VARCHAR(16777216) | Not Null | N/A |

## FEATURE_USAGE Table

| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| USAGE_ID | Unique identifier for each feature usage record | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| MEETING_ID | Reference to the meeting where feature was used | VARCHAR(16777216) | Foreign Key, Not Null | N/A |
| FEATURE_NAME | Name of the feature that was used | VARCHAR(16777216) | Not Null | N/A |
| USAGE_COUNT | Number of times the feature was used | NUMBER(38,0) | Not Null | N/A |
| USAGE_DATE | Date when the feature was used | DATE | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | System that originated the data | VARCHAR(16777216) | Not Null | N/A |

## LICENSES Table

| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| LICENSE_ID | Unique identifier for each license | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| LICENSE_TYPE | Type of license (Basic, Pro, Enterprise, etc.) | VARCHAR(16777216) | Not Null | N/A |
| ASSIGNED_TO_USER_ID | User ID to whom the license is assigned | VARCHAR(16777216) | Foreign Key, Not Null | N/A |
| START_DATE | Date when the license becomes active | DATE | Not Null | N/A |
| END_DATE | Date when the license expires | VARCHAR(16777216) | Nullable | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | System that originated the data | VARCHAR(16777216) | Not Null | N/A |

## MEETINGS Table

| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| MEETING_ID | Unique identifier for each meeting | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| HOST_ID | User ID of the meeting host | VARCHAR(16777216) | Foreign Key, Not Null | N/A |
| MEETING_TOPIC | Topic or title of the meeting | VARCHAR(16777216) | Not Null | N/A |
| START_TIME | Timestamp when the meeting started | TIMESTAMP_NTZ(9) | Not Null | N/A |
| END_TIME | Timestamp when the meeting ended | VARCHAR(16777216) | Nullable | N/A |
| DURATION_MINUTES | Duration of the meeting in minutes | VARCHAR(16777216) | Nullable | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | System that originated the data | VARCHAR(16777216) | Not Null | N/A |

## PARTICIPANTS Table

| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| PARTICIPANT_ID | Unique identifier for each meeting participant | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| MEETING_ID | Reference to the meeting | VARCHAR(16777216) | Foreign Key, Not Null | N/A |
| USER_ID | Reference to the user who participated | VARCHAR(16777216) | Foreign Key, Not Null | N/A |
| JOIN_TIME | Timestamp when the participant joined the meeting | VARCHAR(16777216) | Nullable | N/A |
| LEAVE_TIME | Timestamp when the participant left the meeting | TIMESTAMP_NTZ(9) | Nullable | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | System that originated the data | VARCHAR(16777216) | Not Null | N/A |

## SUPPORT_TICKETS Table

| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| TICKET_ID | Unique identifier for each support ticket | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| USER_ID | Reference to the user who created the ticket | VARCHAR(16777216) | Foreign Key, Not Null | N/A |
| TICKET_TYPE | Type of support ticket (Technical, Billing, etc.) | VARCHAR(16777216) | Not Null | N/A |
| RESOLUTION_STATUS | Current status of the ticket resolution | VARCHAR(16777216) | Not Null | N/A |
| OPEN_DATE | Date when the ticket was opened | DATE | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | System that originated the data | VARCHAR(16777216) | Not Null | N/A |

## USERS Table

| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| USER_ID | Unique identifier for each user account | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| USER_NAME | Display name of the user | VARCHAR(16777216) | Not Null | N/A |
| EMAIL | Email address of the user | VARCHAR(16777216) | Not Null, Unique | N/A |
| COMPANY | Company or organization the user belongs to | VARCHAR(16777216) | Nullable | N/A |
| PLAN_TYPE | Type of subscription plan (Basic, Pro, Enterprise) | VARCHAR(16777216) | Not Null | N/A |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | N/A |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) | Not Null | N/A |
| SOURCE_SYSTEM | System that originated the data | VARCHAR(16777216) | Not Null | N/A |

## Summary

The RAW layer contains 7 tables:
1. **BILLING_EVENTS** - Contains billing and payment event data
2. **FEATURE_USAGE** - Tracks usage of various platform features
3. **LICENSES** - Manages license assignments and validity periods
4. **MEETINGS** - Stores meeting information and metadata
5. **PARTICIPANTS** - Records meeting participation details
6. **SUPPORT_TICKETS** - Manages customer support requests
7. **USERS** - Contains user account information and profiles

All tables include standard audit fields (LOAD_TIMESTAMP, UPDATE_TIMESTAMP, SOURCE_SYSTEM) for data lineage and tracking purposes.

**Pipeline ID:** 8083
**Generated on:** $(date)
**Instance ID:** 0000292yu2ujj