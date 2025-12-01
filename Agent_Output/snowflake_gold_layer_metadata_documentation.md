# Snowflake Gold Layer Metadata Documentation

**Pipeline ID:** 8083  
**Extraction Date:** 2024-12-19  
**Layer:** GOLD  
**Total Tables:** 7  
**Total Views:** 0  

---

## BILLING_EVENTS
**Description:** Contains billing event records for user transactions and charges

| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| EVENT_ID | Unique identifier for each billing event | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| USER_ID | Foreign key reference to user account | VARCHAR(16777216) | Foreign Key, Not Null | N/A |
| EVENT_TYPE | Type of billing event (charge, refund, credit) | VARCHAR(16777216) | Not Null | charge, refund, credit, adjustment |
| AMOUNT | Monetary amount of the billing event | VARCHAR(16777216) | Not Null | Positive decimal values |
| EVENT_DATE | Date when the billing event occurred | DATE | Not Null | Valid date format YYYY-MM-DD |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | System generated timestamp |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | Nullable | System generated timestamp |
| SOURCE_SYSTEM | Source system that provided the data | VARCHAR(16777216) | Not Null | billing_system, payment_gateway, manual_entry |

---

## FEATURE_USAGE
**Description:** Tracks usage of various features during meetings

| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| USAGE_ID | Unique identifier for each feature usage record | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| MEETING_ID | Foreign key reference to meeting | VARCHAR(16777216) | Foreign Key, Not Null | N/A |
| FEATURE_NAME | Name of the feature being used | VARCHAR(16777216) | Not Null | screen_share, chat, recording, breakout_rooms, whiteboard |
| USAGE_COUNT | Number of times the feature was used | NUMBER(38,0) | Not Null, >= 0 | Non-negative integers |
| USAGE_DATE | Date when the feature usage occurred | DATE | Not Null | Valid date format YYYY-MM-DD |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | System generated timestamp |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | Nullable | System generated timestamp |
| SOURCE_SYSTEM | Source system that provided the data | VARCHAR(16777216) | Not Null | meeting_platform, analytics_system |

---

## LICENSES
**Description:** Manages software licenses assigned to users

| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| LICENSE_ID | Unique identifier for each license | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| LICENSE_TYPE | Type of license (basic, pro, enterprise) | VARCHAR(16777216) | Not Null | basic, pro, enterprise, trial |
| ASSIGNED_TO_USER_ID | User ID to whom the license is assigned | VARCHAR(16777216) | Foreign Key, Nullable | N/A |
| START_DATE | Date when the license becomes active | DATE | Not Null | Valid date format YYYY-MM-DD |
| END_DATE | Date when the license expires | VARCHAR(16777216) | Nullable | Valid date format YYYY-MM-DD or NULL for perpetual |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | System generated timestamp |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | Nullable | System generated timestamp |
| SOURCE_SYSTEM | Source system that provided the data | VARCHAR(16777216) | Not Null | license_management, billing_system |

---

## MEETINGS
**Description:** Contains meeting session information and details

| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| MEETING_ID | Unique identifier for each meeting session | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| HOST_ID | User ID of the meeting host | VARCHAR(16777216) | Foreign Key, Not Null | N/A |
| MEETING_TOPIC | Subject or topic of the meeting | VARCHAR(16777216) | Nullable | Free text up to character limit |
| START_TIME | Timestamp when the meeting started | TIMESTAMP_NTZ(9) | Not Null | Valid timestamp format |
| END_TIME | Timestamp when the meeting ended | VARCHAR(16777216) | Nullable | Valid timestamp format or NULL for ongoing |
| DURATION_MINUTES | Duration of the meeting in minutes | VARCHAR(16777216) | Nullable | Positive integer values |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | System generated timestamp |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | Nullable | System generated timestamp |
| SOURCE_SYSTEM | Source system that provided the data | VARCHAR(16777216) | Not Null | meeting_platform, calendar_system |

---

## PARTICIPANTS
**Description:** Tracks participants in meeting sessions

| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| PARTICIPANT_ID | Unique identifier for each participant record | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| MEETING_ID | Foreign key reference to meeting | VARCHAR(16777216) | Foreign Key, Not Null | N/A |
| USER_ID | Foreign key reference to user account | VARCHAR(16777216) | Foreign Key, Not Null | N/A |
| JOIN_TIME | Timestamp when participant joined the meeting | VARCHAR(16777216) | Nullable | Valid timestamp format |
| LEAVE_TIME | Timestamp when participant left the meeting | TIMESTAMP_NTZ(9) | Nullable | Valid timestamp format or NULL for still in meeting |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | System generated timestamp |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | Nullable | System generated timestamp |
| SOURCE_SYSTEM | Source system that provided the data | VARCHAR(16777216) | Not Null | meeting_platform, attendance_tracker |

---

## SUPPORT_TICKETS
**Description:** Manages customer support tickets and issues

| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| TICKET_ID | Unique identifier for each support ticket | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| USER_ID | Foreign key reference to user who created ticket | VARCHAR(16777216) | Foreign Key, Not Null | N/A |
| TICKET_TYPE | Category of the support ticket | VARCHAR(16777216) | Not Null | technical, billing, feature_request, bug_report, general |
| RESOLUTION_STATUS | Current status of ticket resolution | VARCHAR(16777216) | Not Null | open, in_progress, resolved, closed, escalated |
| OPEN_DATE | Date when the ticket was opened | DATE | Not Null | Valid date format YYYY-MM-DD |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | System generated timestamp |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | Nullable | System generated timestamp |
| SOURCE_SYSTEM | Source system that provided the data | VARCHAR(16777216) | Not Null | support_system, helpdesk, email_integration |

---

## USERS
**Description:** Master table containing user account information

| Column Name | Business Description | Data Type | Constraints | Domain Values |
|-------------|---------------------|-----------|-------------|---------------|
| USER_ID | Unique identifier for each user account | VARCHAR(16777216) | Primary Key, Not Null | N/A |
| USER_NAME | Display name of the user | VARCHAR(16777216) | Not Null | Alphanumeric characters and spaces |
| EMAIL | Email address of the user | VARCHAR(16777216) | Unique, Not Null | Valid email format |
| COMPANY | Company or organization the user belongs to | VARCHAR(16777216) | Nullable | Free text company names |
| PLAN_TYPE | Subscription plan type for the user | VARCHAR(16777216) | Not Null | free, basic, pro, enterprise, trial |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the system | TIMESTAMP_NTZ(9) | Not Null | System generated timestamp |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | Nullable | System generated timestamp |
| SOURCE_SYSTEM | Source system that provided the data | VARCHAR(16777216) | Not Null | user_management, registration_system, crm |

---

## Summary

This documentation provides comprehensive metadata for all 7 tables in the Snowflake Gold layer. Each table includes detailed column information with business descriptions, data types, constraints, and domain values to support data governance, analytics, and reporting requirements.

**Key Relationships:**
- USERS table serves as the master user reference
- MEETINGS table connects to USERS via HOST_ID
- PARTICIPANTS table links USERS and MEETINGS
- FEATURE_USAGE tracks meeting feature utilization
- LICENSES manages user license assignments
- BILLING_EVENTS tracks financial transactions
- SUPPORT_TICKETS manages customer service interactions

**Data Quality Notes:**
- All tables include LOAD_TIMESTAMP and UPDATE_TIMESTAMP for audit trails
- SOURCE_SYSTEM column tracks data lineage
- Primary keys ensure unique record identification
- Foreign key relationships maintain referential integrity