_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Bronze Layer dbt models in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases - Zoom Bronze Layer Pipeline

## Overview

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics Bronze Layer Pipeline. The tests validate data transformations, business rules, edge cases, and error handling across 8 Bronze layer models in Snowflake.

## Test Coverage Summary

| Model | Primary Tests | Edge Case Tests | Error Handling Tests | Total Test Cases |
|-------|---------------|-----------------|---------------------|------------------|
| bz_users | 8 | 6 | 4 | 18 |
| bz_meetings | 9 | 7 | 5 | 21 |
| bz_participants | 8 | 6 | 4 | 18 |
| bz_feature_usage | 8 | 6 | 4 | 18 |
| bz_support_tickets | 8 | 6 | 4 | 18 |
| bz_billing_events | 8 | 6 | 4 | 18 |
| bz_licenses | 9 | 7 | 5 | 21 |
| bz_data_audit | 6 | 4 | 3 | 13 |
| **TOTAL** | **64** | **48** | **33** | **145** |

---

## Test Case List

### 1. BZ_USERS Model Test Cases

#### Primary Functionality Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_USERS_001 | Validate unique USER_ID constraint | All USER_ID values are unique after deduplication |
| BZ_USERS_002 | Verify NOT NULL validation for required fields | USER_ID, USER_NAME, EMAIL, COMPANY, PLAN_TYPE are not null |
| BZ_USERS_003 | Test deduplication logic based on UPDATE_TIMESTAMP | Latest record per USER_ID is retained |
| BZ_USERS_004 | Validate EMAIL format and uniqueness | All emails follow valid format and are unique |
| BZ_USERS_005 | Test PLAN_TYPE domain values | Only valid values: Basic, Pro, Business, Enterprise |
| BZ_USERS_006 | Verify timestamp consistency | LOAD_TIMESTAMP <= UPDATE_TIMESTAMP |
| BZ_USERS_007 | Test SOURCE_SYSTEM population | All records have valid SOURCE_SYSTEM values |
| BZ_USERS_008 | Validate row count preservation | Source row count matches target after deduplication |

#### Edge Case Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_USERS_E001 | Handle duplicate USER_ID with same UPDATE_TIMESTAMP | First record by LOAD_TIMESTAMP is retained |
| BZ_USERS_E002 | Process records with maximum VARCHAR length | Long text values are preserved without truncation |
| BZ_USERS_E003 | Handle special characters in USER_NAME and EMAIL | Special characters are preserved correctly |
| BZ_USERS_E004 | Test case sensitivity in EMAIL field | Email case is preserved as-is |
| BZ_USERS_E005 | Handle empty string vs NULL values | Empty strings are treated differently from NULL |
| BZ_USERS_E006 | Process records with future timestamps | Future timestamps are accepted without error |

#### Error Handling Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_USERS_ERR001 | Handle NULL USER_ID records | Records with NULL USER_ID are excluded |
| BZ_USERS_ERR002 | Process invalid PLAN_TYPE values | Invalid PLAN_TYPE values are flagged but preserved |
| BZ_USERS_ERR003 | Handle malformed email addresses | Malformed emails are preserved for downstream validation |
| BZ_USERS_ERR004 | Test extremely large datasets | Performance remains acceptable with large volumes |

### 2. BZ_MEETINGS Model Test Cases

#### Primary Functionality Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_MEETINGS_001 | Validate unique MEETING_ID constraint | All MEETING_ID values are unique after deduplication |
| BZ_MEETINGS_002 | Verify NOT NULL validation for required fields | MEETING_ID, HOST_ID are not null |
| BZ_MEETINGS_003 | Test deduplication logic based on UPDATE_TIMESTAMP | Latest record per MEETING_ID is retained |
| BZ_MEETINGS_004 | Validate START_TIME < END_TIME relationship | END_TIME is always after START_TIME |
| BZ_MEETINGS_005 | Test DURATION_MINUTES calculation consistency | DURATION_MINUTES matches time difference |
| BZ_MEETINGS_006 | Verify HOST_ID references valid users | HOST_ID exists in user data (referential check) |
| BZ_MEETINGS_007 | Test timestamp data type preservation | All timestamp fields maintain precision |
| BZ_MEETINGS_008 | Validate MEETING_TOPIC text handling | Meeting topics are preserved with special characters |
| BZ_MEETINGS_009 | Test SOURCE_SYSTEM population | All records have valid SOURCE_SYSTEM values |

#### Edge Case Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_MEETINGS_E001 | Handle zero-duration meetings | START_TIME = END_TIME results in 0 DURATION_MINUTES |
| BZ_MEETINGS_E002 | Process very long meeting durations | Meetings over 24 hours are handled correctly |
| BZ_MEETINGS_E003 | Handle NULL MEETING_TOPIC | NULL topics are preserved without error |
| BZ_MEETINGS_E004 | Test timezone-naive timestamp handling | All timestamps stored as TIMESTAMP_NTZ |
| BZ_MEETINGS_E005 | Handle duplicate MEETING_ID with same timestamp | Consistent deduplication behavior |
| BZ_MEETINGS_E006 | Process meetings spanning midnight | Cross-day meetings calculated correctly |
| BZ_MEETINGS_E007 | Handle extremely long meeting topics | Long topics preserved without truncation |

#### Error Handling Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_MEETINGS_ERR001 | Handle NULL MEETING_ID records | Records excluded from final dataset |
| BZ_MEETINGS_ERR002 | Handle NULL HOST_ID records | Records excluded from final dataset |
| BZ_MEETINGS_ERR003 | Process END_TIME before START_TIME | Records preserved for downstream validation |
| BZ_MEETINGS_ERR004 | Handle invalid timestamp formats | Error handling preserves data integrity |
| BZ_MEETINGS_ERR005 | Test negative DURATION_MINUTES | Negative durations flagged but preserved |

### 3. BZ_PARTICIPANTS Model Test Cases

#### Primary Functionality Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_PARTICIPANTS_001 | Validate unique PARTICIPANT_ID constraint | All PARTICIPANT_ID values are unique |
| BZ_PARTICIPANTS_002 | Verify NOT NULL validation for required fields | PARTICIPANT_ID, MEETING_ID, USER_ID not null |
| BZ_PARTICIPANTS_003 | Test deduplication logic | Latest record per PARTICIPANT_ID retained |
| BZ_PARTICIPANTS_004 | Validate JOIN_TIME <= LEAVE_TIME | Leave time is after or equal to join time |
| BZ_PARTICIPANTS_005 | Test foreign key relationships | MEETING_ID and USER_ID reference valid records |
| BZ_PARTICIPANTS_006 | Verify timestamp precision | All timestamps maintain nanosecond precision |
| BZ_PARTICIPANTS_007 | Test participant session duration | Duration calculations are accurate |
| BZ_PARTICIPANTS_008 | Validate SOURCE_SYSTEM population | All records have SOURCE_SYSTEM values |

#### Edge Case Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_PARTICIPANTS_E001 | Handle same JOIN_TIME and LEAVE_TIME | Zero-duration participation handled correctly |
| BZ_PARTICIPANTS_E002 | Process multiple participants per meeting | All participants preserved correctly |
| BZ_PARTICIPANTS_E003 | Handle participants joining after meeting end | Late joins preserved for analysis |
| BZ_PARTICIPANTS_E004 | Test participant rejoining same meeting | Multiple participation records handled |
| BZ_PARTICIPANTS_E005 | Handle very short participation durations | Sub-second durations preserved |
| BZ_PARTICIPANTS_E006 | Process participants with NULL LEAVE_TIME | Ongoing sessions handled appropriately |

#### Error Handling Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_PARTICIPANTS_ERR001 | Handle NULL PARTICIPANT_ID | Records excluded from dataset |
| BZ_PARTICIPANTS_ERR002 | Handle NULL MEETING_ID | Records excluded from dataset |
| BZ_PARTICIPANTS_ERR003 | Handle NULL USER_ID | Records excluded from dataset |
| BZ_PARTICIPANTS_ERR004 | Process LEAVE_TIME before JOIN_TIME | Records preserved for validation |

### 4. BZ_FEATURE_USAGE Model Test Cases

#### Primary Functionality Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_FEATURE_USAGE_001 | Validate unique USAGE_ID constraint | All USAGE_ID values are unique |
| BZ_FEATURE_USAGE_002 | Verify NOT NULL validation | USAGE_ID not null |
| BZ_FEATURE_USAGE_003 | Test deduplication logic | Latest record per USAGE_ID retained |
| BZ_FEATURE_USAGE_004 | Validate USAGE_COUNT is non-negative | All usage counts >= 0 |
| BZ_FEATURE_USAGE_005 | Test FEATURE_NAME standardization | Feature names are consistent |
| BZ_FEATURE_USAGE_006 | Verify MEETING_ID relationships | Valid meeting references |
| BZ_FEATURE_USAGE_007 | Test USAGE_DATE consistency | Dates align with meeting dates |
| BZ_FEATURE_USAGE_008 | Validate SOURCE_SYSTEM population | All records have SOURCE_SYSTEM |

#### Edge Case Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_FEATURE_USAGE_E001 | Handle zero usage counts | Zero counts preserved correctly |
| BZ_FEATURE_USAGE_E002 | Process very high usage counts | Large numbers handled without overflow |
| BZ_FEATURE_USAGE_E003 | Handle unknown feature names | New features preserved for analysis |
| BZ_FEATURE_USAGE_E004 | Test case sensitivity in feature names | Case preserved as-is |
| BZ_FEATURE_USAGE_E005 | Handle NULL MEETING_ID | Orphaned usage records preserved |
| BZ_FEATURE_USAGE_E006 | Process future usage dates | Future dates accepted |

#### Error Handling Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_FEATURE_USAGE_ERR001 | Handle NULL USAGE_ID | Records excluded |
| BZ_FEATURE_USAGE_ERR002 | Process negative usage counts | Preserved for validation |
| BZ_FEATURE_USAGE_ERR003 | Handle invalid date formats | Error handling maintains integrity |
| BZ_FEATURE_USAGE_ERR004 | Test extremely long feature names | Long names preserved |

### 5. BZ_SUPPORT_TICKETS Model Test Cases

#### Primary Functionality Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_SUPPORT_TICKETS_001 | Validate unique TICKET_ID constraint | All TICKET_ID values unique |
| BZ_SUPPORT_TICKETS_002 | Verify NOT NULL validation | TICKET_ID, USER_ID not null |
| BZ_SUPPORT_TICKETS_003 | Test deduplication logic | Latest record per TICKET_ID retained |
| BZ_SUPPORT_TICKETS_004 | Validate RESOLUTION_STATUS domain | Valid status values only |
| BZ_SUPPORT_TICKETS_005 | Test TICKET_TYPE categorization | Proper ticket type handling |
| BZ_SUPPORT_TICKETS_006 | Verify USER_ID relationships | Valid user references |
| BZ_SUPPORT_TICKETS_007 | Test OPEN_DATE consistency | Dates are reasonable |
| BZ_SUPPORT_TICKETS_008 | Validate SOURCE_SYSTEM population | All records have SOURCE_SYSTEM |

#### Edge Case Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_SUPPORT_TICKETS_E001 | Handle tickets with future OPEN_DATE | Future dates preserved |
| BZ_SUPPORT_TICKETS_E002 | Process unknown TICKET_TYPE values | New types preserved |
| BZ_SUPPORT_TICKETS_E003 | Handle case variations in status | Case preserved as-is |
| BZ_SUPPORT_TICKETS_E004 | Test very old ticket dates | Historical dates handled |
| BZ_SUPPORT_TICKETS_E005 | Handle NULL RESOLUTION_STATUS | NULL status preserved |
| BZ_SUPPORT_TICKETS_E006 | Process duplicate ticket numbers | Deduplication works correctly |

#### Error Handling Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_SUPPORT_TICKETS_ERR001 | Handle NULL TICKET_ID | Records excluded |
| BZ_SUPPORT_TICKETS_ERR002 | Handle NULL USER_ID | Records excluded |
| BZ_SUPPORT_TICKETS_ERR003 | Process invalid date formats | Error handling preserves integrity |
| BZ_SUPPORT_TICKETS_ERR004 | Test orphaned tickets | Tickets without valid users preserved |

### 6. BZ_BILLING_EVENTS Model Test Cases

#### Primary Functionality Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_BILLING_EVENTS_001 | Validate unique EVENT_ID constraint | All EVENT_ID values unique |
| BZ_BILLING_EVENTS_002 | Verify NOT NULL validation | EVENT_ID not null |
| BZ_BILLING_EVENTS_003 | Test deduplication logic | Latest record per EVENT_ID retained |
| BZ_BILLING_EVENTS_004 | Validate AMOUNT precision | Decimal precision maintained |
| BZ_BILLING_EVENTS_005 | Test EVENT_TYPE categorization | Proper event type handling |
| BZ_BILLING_EVENTS_006 | Verify USER_ID relationships | Valid user references |
| BZ_BILLING_EVENTS_007 | Test EVENT_DATE consistency | Dates are reasonable |
| BZ_BILLING_EVENTS_008 | Validate SOURCE_SYSTEM population | All records have SOURCE_SYSTEM |

#### Edge Case Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_BILLING_EVENTS_E001 | Handle zero and negative amounts | All amounts preserved |
| BZ_BILLING_EVENTS_E002 | Process very large amounts | Large numbers handled correctly |
| BZ_BILLING_EVENTS_E003 | Handle unknown EVENT_TYPE values | New types preserved |
| BZ_BILLING_EVENTS_E004 | Test decimal precision edge cases | Precision maintained |
| BZ_BILLING_EVENTS_E005 | Handle future EVENT_DATE | Future dates preserved |
| BZ_BILLING_EVENTS_E006 | Process NULL USER_ID | Orphaned events preserved |

#### Error Handling Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_BILLING_EVENTS_ERR001 | Handle NULL EVENT_ID | Records excluded |
| BZ_BILLING_EVENTS_ERR002 | Process invalid amount formats | Error handling preserves integrity |
| BZ_BILLING_EVENTS_ERR003 | Handle invalid date formats | Error handling maintains integrity |
| BZ_BILLING_EVENTS_ERR004 | Test currency overflow scenarios | Large amounts handled safely |

### 7. BZ_LICENSES Model Test Cases

#### Primary Functionality Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_LICENSES_001 | Validate unique LICENSE_ID constraint | All LICENSE_ID values unique |
| BZ_LICENSES_002 | Verify NOT NULL validation | LICENSE_ID not null |
| BZ_LICENSES_003 | Test deduplication logic | Latest record per LICENSE_ID retained |
| BZ_LICENSES_004 | Validate START_DATE <= END_DATE | End date after start date |
| BZ_LICENSES_005 | Test LICENSE_TYPE standardization | Proper license type handling |
| BZ_LICENSES_006 | Verify ASSIGNED_TO_USER_ID relationships | Valid user references |
| BZ_LICENSES_007 | Test date range validity | Date ranges are logical |
| BZ_LICENSES_008 | Validate SOURCE_SYSTEM population | All records have SOURCE_SYSTEM |
| BZ_LICENSES_009 | Test license duration calculations | Duration logic is correct |

#### Edge Case Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_LICENSES_E001 | Handle same START_DATE and END_DATE | Single-day licenses handled |
| BZ_LICENSES_E002 | Process very long license periods | Long-term licenses handled |
| BZ_LICENSES_E003 | Handle unknown LICENSE_TYPE values | New types preserved |
| BZ_LICENSES_E004 | Test NULL ASSIGNED_TO_USER_ID | Unassigned licenses preserved |
| BZ_LICENSES_E005 | Handle future license dates | Future licenses preserved |
| BZ_LICENSES_E006 | Process expired licenses | Historical licenses handled |
| BZ_LICENSES_E007 | Handle overlapping license periods | Overlaps preserved for analysis |

#### Error Handling Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_LICENSES_ERR001 | Handle NULL LICENSE_ID | Records excluded |
| BZ_LICENSES_ERR002 | Process END_DATE before START_DATE | Records preserved for validation |
| BZ_LICENSES_ERR003 | Handle invalid date formats | Error handling preserves integrity |
| BZ_LICENSES_ERR004 | Test orphaned license assignments | Licenses without valid users preserved |
| BZ_LICENSES_ERR005 | Handle extremely old license dates | Historical dates handled |

### 8. BZ_DATA_AUDIT Model Test Cases

#### Primary Functionality Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_AUDIT_001 | Validate RECORD_ID auto-increment | Sequential ID generation |
| BZ_AUDIT_002 | Test SOURCE_TABLE population | All operations logged |
| BZ_AUDIT_003 | Verify LOAD_TIMESTAMP accuracy | Timestamps reflect actual load time |
| BZ_AUDIT_004 | Test PROCESSED_BY tracking | User/process identification |
| BZ_AUDIT_005 | Validate PROCESSING_TIME calculation | Accurate timing metrics |
| BZ_AUDIT_006 | Test STATUS value consistency | Valid status values only |

#### Edge Case Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_AUDIT_E001 | Handle very fast processing times | Sub-second times recorded |
| BZ_AUDIT_E002 | Process very long operation times | Long durations handled |
| BZ_AUDIT_E003 | Handle concurrent audit entries | Concurrent operations logged |
| BZ_AUDIT_E004 | Test audit table growth | Large audit volumes handled |

#### Error Handling Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_AUDIT_ERR001 | Handle failed operations | Failures properly logged |
| BZ_AUDIT_ERR002 | Test audit table corruption | Recovery mechanisms work |
| BZ_AUDIT_ERR003 | Handle missing audit data | Gaps identified and handled |

---

## dbt Test Scripts

### YAML-Based Schema Tests

#### File: models/bronze/schema.yml

```yaml
version: 2

sources:
  - name: raw
    description: "Raw data layer containing unprocessed data from source systems"
    tables:
      - name: users
        description: "Raw user profile and subscription information"
      - name: meetings
        description: "Raw meeting information and session details"
      - name: participants
        description: "Raw meeting participants and their session details"
      - name: feature_usage
        description: "Raw usage of platform features during meetings"
      - name: support_tickets
        description: "Raw customer support requests and resolution tracking"
      - name: billing_events
        description: "Raw financial transactions and billing activities"
      - name: licenses
        description: "Raw license assignments and entitlements"

models:
  - name: bz_users
    description: "Bronze layer table storing cleaned and deduplicated user data"
    columns:
      - name: user_id
        description: "Unique identifier for each user account"
        tests:
          - not_null
          - unique
      - name: user_name
        description: "Display name of the user (PII)"
        tests:
          - not_null
      - name: email
        description: "Email address of the user (PII)"
        tests:
          - not_null
          - unique
      - name: company
        description: "Company or organization name"
        tests:
          - not_null
      - name: plan_type
        description: "Subscription plan type"
        tests:
          - not_null
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise']
      - name: load_timestamp
        description: "Timestamp when record was loaded"
        tests:
          - not_null
      - name: update_timestamp
        description: "Timestamp when record was last updated"
        tests:
          - not_null
      - name: source_system
        description: "Source system from which data originated"
        tests:
          - not_null
    tests:
      - dbt_utils.expression_is_true:
          expression: "load_timestamp <= update_timestamp"
          config:
            severity: warn

  - name: bz_meetings
    description: "Bronze layer table storing cleaned and deduplicated meeting data"
    columns:
      - name: meeting_id
        description: "Unique identifier for each meeting"
        tests:
          - not_null
          - unique
      - name: host_id
        description: "User ID of the meeting host"
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: warn
      - name: meeting_topic
        description: "Topic or title of the meeting"
      - name: start_time
        description: "Meeting start timestamp"
        tests:
          - not_null
      - name: end_time
        description: "Meeting end timestamp"
        tests:
          - not_null
      - name: duration_minutes
        description: "Meeting duration in minutes"
        tests:
          - not_null
      - name: load_timestamp
        tests:
          - not_null
      - name: update_timestamp
        tests:
          - not_null
      - name: source_system
        tests:
          - not_null
    tests:
      - dbt_utils.expression_is_true:
          expression: "start_time <= end_time"
          config:
            severity: warn
      - dbt_utils.expression_is_true:
          expression: "duration_minutes >= 0"
          config:
            severity: warn

  - name: bz_participants
    description: "Bronze layer table storing cleaned and deduplicated participant data"
    columns:
      - name: participant_id
        description: "Unique identifier for each meeting participant"
        tests:
          - not_null
          - unique
      - name: meeting_id
        description: "Reference to meeting"
        tests:
          - not_null
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
              config:
                severity: warn
      - name: user_id
        description: "Reference to user who participated"
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: warn
      - name: join_time
        tests:
          - not_null
      - name: leave_time
        tests:
          - not_null
      - name: load_timestamp
        tests:
          - not_null
      - name: update_timestamp
        tests:
          - not_null
      - name: source_system
        tests:
          - not_null
    tests:
      - dbt_utils.expression_is_true:
          expression: "join_time <= leave_time"
          config:
            severity: warn

  - name: bz_feature_usage
    description: "Bronze layer table storing cleaned and deduplicated feature usage data"
    columns:
      - name: usage_id
        description: "Unique identifier for each feature usage record"
        tests:
          - not_null
          - unique
      - name: meeting_id
        description: "Reference to meeting where feature was used"
        tests:
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
              config:
                severity: warn
      - name: feature_name
        tests:
          - not_null
      - name: usage_count
        tests:
          - not_null
      - name: usage_date
        tests:
          - not_null
      - name: load_timestamp
        tests:
          - not_null
      - name: update_timestamp
        tests:
          - not_null
      - name: source_system
        tests:
          - not_null
    tests:
      - dbt_utils.expression_is_true:
          expression: "usage_count >= 0"
          config:
            severity: warn

  - name: bz_support_tickets
    description: "Bronze layer table storing cleaned and deduplicated support ticket data"
    columns:
      - name: ticket_id
        description: "Unique identifier for each support ticket"
        tests:
          - not_null
          - unique
      - name: user_id
        description: "Reference to user who created the ticket"
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: warn
      - name: ticket_type
        tests:
          - not_null
      - name: resolution_status
        tests:
          - not_null
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed']
              config:
                severity: warn
      - name: open_date
        tests:
          - not_null
      - name: load_timestamp
        tests:
          - not_null
      - name: update_timestamp
        tests:
          - not_null
      - name: source_system
        tests:
          - not_null

  - name: bz_billing_events
    description: "Bronze layer table storing cleaned and deduplicated billing event data"
    columns:
      - name: event_id
        description: "Unique identifier for each billing event"
        tests:
          - not_null
          - unique
      - name: user_id
        description: "Reference to user associated with billing event"
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: warn
      - name: event_type
        tests:
          - not_null
      - name: amount
        tests:
          - not_null
      - name: event_date
        tests:
          - not_null
      - name: load_timestamp
        tests:
          - not_null
      - name: update_timestamp
        tests:
          - not_null
      - name: source_system
        tests:
          - not_null

  - name: bz_licenses
    description: "Bronze layer table storing cleaned and deduplicated license data"
    columns:
      - name: license_id
        description: "Unique identifier for each license"
        tests:
          - not_null
          - unique
      - name: license_type
        tests:
          - not_null
      - name: assigned_to_user_id
        description: "User ID to whom license is assigned"
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: warn
      - name: start_date
        tests:
          - not_null
      - name: end_date
        tests:
          - not_null
      - name: load_timestamp
        tests:
          - not_null
      - name: update_timestamp
        tests:
          - not_null
      - name: source_system
        tests:
          - not_null
    tests:
      - dbt_utils.expression_is_true:
          expression: "start_date <= end_date"
          config:
            severity: warn

  - name: bz_data_audit
    description: "Comprehensive audit trail for all Bronze layer data operations"
    columns:
      - name: record_id
        description: "Auto-incrementing unique identifier"
        tests:
          - not_null
          - unique
      - name: source_table
        tests:
          - not_null
      - name: load_timestamp
        tests:
          - not_null
      - name: processed_by
        tests:
          - not_null
      - name: processing_time
        tests:
          - not_null
      - name: status
        tests:
          - not_null
          - accepted_values:
              values: ['SUCCESS', 'FAILED', 'WARNING', 'INITIALIZED']
```

### Custom SQL-Based dbt Tests

#### File: tests/bronze/test_bz_users_deduplication.sql

```sql
-- Test: Verify deduplication logic works correctly for bz_users
-- Expected: No duplicate USER_ID values in final result

WITH duplicate_check AS (
    SELECT 
        user_id,
        COUNT(*) as record_count
    FROM {{ ref('bz_users') }}
    GROUP BY user_id
    HAVING COUNT(*) > 1
)

SELECT *
FROM duplicate_check
```

#### File: tests/bronze/test_bz_meetings_duration_consistency.sql

```sql
-- Test: Verify meeting duration consistency
-- Expected: DURATION_MINUTES should match calculated time difference

WITH duration_check AS (
    SELECT 
        meeting_id,
        duration_minutes,
        DATEDIFF('minute', start_time, end_time) as calculated_duration,
        ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) as duration_diff
    FROM {{ ref('bz_meetings') }}
    WHERE start_time IS NOT NULL 
      AND end_time IS NOT NULL
      AND duration_minutes IS NOT NULL
)

SELECT *
FROM duration_check
WHERE duration_diff > 1  -- Allow 1 minute tolerance for rounding
```

#### File: tests/bronze/test_bz_participants_session_logic.sql

```sql
-- Test: Verify participant session logic
-- Expected: JOIN_TIME should be <= LEAVE_TIME for all participants

SELECT 
    participant_id,
    meeting_id,
    user_id,
    join_time,
    leave_time,
    DATEDIFF('second', join_time, leave_time) as session_duration_seconds
FROM {{ ref('bz_participants') }}
WHERE join_time > leave_time
   OR join_time IS NULL
   OR leave_time IS NULL
```

#### File: tests/bronze/test_bz_feature_usage_data_quality.sql

```sql
-- Test: Verify feature usage data quality
-- Expected: All usage counts should be non-negative

SELECT 
    usage_id,
    meeting_id,
    feature_name,
    usage_count,
    usage_date
FROM {{ ref('bz_feature_usage') }}
WHERE usage_count < 0
   OR usage_count IS NULL
   OR feature_name IS NULL
   OR usage_date IS NULL
```

#### File: tests/bronze/test_bz_billing_events_amount_validation.sql

```sql
-- Test: Verify billing event amount validation
-- Expected: Identify potentially problematic amounts

SELECT 
    event_id,
    user_id,
    event_type,
    amount,
    event_date,
    CASE 
        WHEN amount IS NULL THEN 'NULL_AMOUNT'
        WHEN amount < 0 THEN 'NEGATIVE_AMOUNT'
        WHEN amount > 999999.99 THEN 'EXCESSIVE_AMOUNT'
        ELSE 'VALID'
    END as amount_status
FROM {{ ref('bz_billing_events') }}
WHERE amount IS NULL
   OR amount < 0
   OR amount > 999999.99
```

#### File: tests/bronze/test_bz_licenses_date_validation.sql

```sql
-- Test: Verify license date validation
-- Expected: START_DATE should be <= END_DATE

SELECT 
    license_id,
    license_type,
    assigned_to_user_id,
    start_date,
    end_date,
    DATEDIFF('day', start_date, end_date) as license_duration_days
FROM {{ ref('bz_licenses') }}
WHERE start_date > end_date
   OR start_date IS NULL
   OR end_date IS NULL
```

#### File: tests/bronze/test_cross_table_referential_integrity.sql

```sql
-- Test: Cross-table referential integrity checks
-- Expected: Identify orphaned records across tables

WITH orphaned_meetings AS (
    SELECT 'MEETINGS' as table_name, meeting_id as record_id, host_id as reference_id
    FROM {{ ref('bz_meetings') }} m
    LEFT JOIN {{ ref('bz_users') }} u ON m.host_id = u.user_id
    WHERE u.user_id IS NULL AND m.host_id IS NOT NULL
),

orphaned_participants AS (
    SELECT 'PARTICIPANTS' as table_name, participant_id as record_id, user_id as reference_id
    FROM {{ ref('bz_participants') }} p
    LEFT JOIN {{ ref('bz_users') }} u ON p.user_id = u.user_id
    WHERE u.user_id IS NULL AND p.user_id IS NOT NULL
    
    UNION ALL
    
    SELECT 'PARTICIPANTS' as table_name, participant_id as record_id, meeting_id as reference_id
    FROM {{ ref('bz_participants') }} p
    LEFT JOIN {{ ref('bz_meetings') }} m ON p.meeting_id = m.meeting_id
    WHERE m.meeting_id IS NULL AND p.meeting_id IS NOT NULL
),

orphaned_support_tickets AS (
    SELECT 'SUPPORT_TICKETS' as table_name, ticket_id as record_id, user_id as reference_id
    FROM {{ ref('bz_support_tickets') }} st
    LEFT JOIN {{ ref('bz_users') }} u ON st.user_id = u.user_id
    WHERE u.user_id IS NULL AND st.user_id IS NOT NULL
),

orphaned_licenses AS (
    SELECT 'LICENSES' as table_name, license_id as record_id, assigned_to_user_id as reference_id
    FROM {{ ref('bz_licenses') }} l
    LEFT JOIN {{ ref('bz_users') }} u ON l.assigned_to_user_id = u.user_id
    WHERE u.user_id IS NULL AND l.assigned_to_user_id IS NOT NULL
)

SELECT * FROM orphaned_meetings
UNION ALL
SELECT * FROM orphaned_participants
UNION ALL
SELECT * FROM orphaned_support_tickets
UNION ALL
SELECT * FROM orphaned_licenses
```

#### File: tests/bronze/test_audit_trail_completeness.sql

```sql
-- Test: Verify audit trail completeness
-- Expected: All Bronze layer operations should be logged

WITH expected_tables AS (
    SELECT table_name
    FROM (
        VALUES 
            ('BZ_USERS'),
            ('BZ_MEETINGS'),
            ('BZ_PARTICIPANTS'),
            ('BZ_FEATURE_USAGE'),
            ('BZ_SUPPORT_TICKETS'),
            ('BZ_BILLING_EVENTS'),
            ('BZ_LICENSES')
    ) AS t(table_name)
),

logged_tables AS (
    SELECT DISTINCT UPPER(source_table) as table_name
    FROM {{ ref('bz_data_audit') }}
    WHERE source_table IS NOT NULL
)

SELECT et.table_name as missing_table
FROM expected_tables et
LEFT JOIN logged_tables lt ON et.table_name = lt.table_name
WHERE lt.table_name IS NULL
```

### Parameterized Tests for Reusability

#### File: macros/test_data_freshness.sql

```sql
-- Macro: Test data freshness across Bronze layer tables
-- Usage: {{ test_data_freshness('bz_users', 24) }}

{% macro test_data_freshness(table_name, max_hours_old=24) %}
    SELECT 
        '{{ table_name }}' as table_name,
        MAX(load_timestamp) as latest_load,
        DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP()) as hours_since_last_load
    FROM {{ ref(table_name) }}
    HAVING DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP()) > {{ max_hours_old }}
{% endmacro %}
```

#### File: macros/test_record_count_validation.sql

```sql
-- Macro: Validate record counts between source and target
-- Usage: {{ test_record_count_validation('raw', 'users', 'bronze', 'bz_users') }}

{% macro test_record_count_validation(source_schema, source_table, target_schema, target_table) %}
    WITH source_count AS (
        SELECT COUNT(*) as source_records
        FROM {{ source_schema }}.{{ source_table }}
    ),
    
    target_count AS (
        SELECT COUNT(*) as target_records
        FROM {{ ref(target_table) }}
    )
    
    SELECT 
        '{{ source_table }}' as table_name,
        source_records,
        target_records,
        source_records - target_records as record_difference,
        CASE 
            WHEN target_records = 0 THEN 'NO_TARGET_DATA'
            WHEN source_records = 0 THEN 'NO_SOURCE_DATA'
            WHEN ABS(source_records - target_records) / source_records::FLOAT > 0.05 THEN 'SIGNIFICANT_DIFFERENCE'
            ELSE 'ACCEPTABLE'
        END as validation_status
    FROM source_count
    CROSS JOIN target_count
    WHERE ABS(source_records - target_records) / GREATEST(source_records, 1)::FLOAT > 0.05
{% endmacro %}
```

### Performance and Volume Tests

#### File: tests/bronze/test_performance_benchmarks.sql

```sql
-- Test: Performance benchmarks for Bronze layer models
-- Expected: Query execution times within acceptable limits

WITH performance_metrics AS (
    SELECT 
        'bz_users' as model_name,
        COUNT(*) as record_count,
        CURRENT_TIMESTAMP() as test_start_time
    FROM {{ ref('bz_users') }}
    
    UNION ALL
    
    SELECT 
        'bz_meetings' as model_name,
        COUNT(*) as record_count,
        CURRENT_TIMESTAMP() as test_start_time
    FROM {{ ref('bz_meetings') }}
    
    UNION ALL
    
    SELECT 
        'bz_participants' as model_name,
        COUNT(*) as record_count,
        CURRENT_TIMESTAMP() as test_start_time
    FROM {{ ref('bz_participants') }}
)

SELECT 
    model_name,
    record_count,
    test_start_time,
    CASE 
        WHEN record_count > 10000000 THEN 'LARGE_DATASET'
        WHEN record_count > 1000000 THEN 'MEDIUM_DATASET'
        WHEN record_count > 100000 THEN 'SMALL_DATASET'
        ELSE 'MINIMAL_DATASET'
    END as dataset_size_category
FROM performance_metrics
```

---

## Test Execution Strategy

### 1. Test Execution Order

1. **Schema Tests** - Run basic data type and constraint validations
2. **Custom SQL Tests** - Execute business logic and data quality tests
3. **Cross-Table Tests** - Validate referential integrity across models
4. **Performance Tests** - Benchmark query execution and data volumes
5. **Audit Tests** - Verify audit trail completeness and accuracy

### 2. Test Environment Configuration

```yaml
# profiles.yml configuration for testing
zoom_bronze_pipeline:
  target: test
  outputs:
    test:
      type: snowflake
      account: "{{ env_var('SNOWFLAKE_ACCOUNT') }}"
      user: "{{ env_var('SNOWFLAKE_USER') }}"
      private_key_path: "{{ env_var('SNOWFLAKE_PRIVATE_KEY_PATH') }}"
      role: "{{ env_var('SNOWFLAKE_ROLE') }}"
      database: DB_POC_ZOOM_TEST
      warehouse: WH_POC_ZOOM_TEST_XSMALL
      schema: BRONZE_TEST
      threads: 4
      keepalives_idle: 240
      search_path: 'DB_POC_ZOOM_TEST.BRONZE_TEST'
```

### 3. Continuous Integration Integration

```bash
#!/bin/bash
# CI/CD Test Execution Script

echo "Starting Bronze Layer dbt Tests..."

# Install dependencies
dbt deps

# Run schema tests
echo "Running schema tests..."
dbt test --select "models/bronze" --exclude "tag:performance"

# Run custom SQL tests
echo "Running custom SQL tests..."
dbt test --select "tests/bronze"

# Run performance tests (if enabled)
if [ "$RUN_PERFORMANCE_TESTS" = "true" ]; then
    echo "Running performance tests..."
    dbt test --select "tag:performance"
fi

# Generate test results report
dbt docs generate

echo "Bronze Layer dbt Tests completed."
```

### 4. Test Results Monitoring

```sql
-- Query to monitor test results in Snowflake
SELECT 
    test_name,
    model_name,
    status,
    execution_time,
    failures,
    run_started_at,
    run_completed_at
FROM (
    SELECT 
        node_id as test_name,
        SPLIT_PART(node_id, '.', -1) as model_name,
        status,
        execution_time,
        failures,
        run_started_at,
        run_completed_at
    FROM DBT_TEST_RESULTS
    WHERE run_started_at >= CURRENT_DATE - 7
)
ORDER BY run_started_at DESC;
```

---

## Expected Outcomes and Success Criteria

### Data Quality Metrics

| Metric | Target | Measurement |
|--------|--------|--------------|
| Test Pass Rate | ≥ 95% | (Passed Tests / Total Tests) × 100 |
| Data Completeness | ≥ 99% | (Non-null Records / Total Records) × 100 |
| Referential Integrity | ≥ 98% | (Valid References / Total References) × 100 |
| Deduplication Accuracy | 100% | No duplicate primary keys |
| Schema Compliance | 100% | All columns match expected data types |

### Performance Benchmarks

| Model | Expected Execution Time | Record Volume Capacity |
|-------|------------------------|------------------------|
| bz_users | < 30 seconds | Up to 10M records |
| bz_meetings | < 45 seconds | Up to 50M records |
| bz_participants | < 60 seconds | Up to 100M records |
| bz_feature_usage | < 30 seconds | Up to 25M records |
| bz_support_tickets | < 20 seconds | Up to 5M records |
| bz_billing_events | < 25 seconds | Up to 10M records |
| bz_licenses | < 15 seconds | Up to 1M records |
| bz_data_audit | < 10 seconds | Up to 1M records |

### Error Handling Validation

- **Null Handling**: All null values preserved appropriately
- **Data Type Mismatches**: Graceful handling with warning logs
- **Constraint Violations**: Violations flagged but data preserved
- **Performance Degradation**: Automatic alerts for slow queries
- **Audit Trail**: 100% operation logging coverage

---

## Maintenance and Updates

### Test Maintenance Schedule

- **Daily**: Automated test execution in CI/CD pipeline
- **Weekly**: Test results review and performance analysis
- **Monthly**: Test case updates based on new requirements
- **Quarterly**: Comprehensive test suite review and optimization

### Version Control

- All test scripts maintained in Git repository
- Test results tracked in dbt's run_results.json
- Performance metrics logged to Snowflake audit schema
- Test documentation updated with each release

This comprehensive unit test suite ensures the reliability, performance, and data quality of the Zoom Bronze Layer Pipeline, providing robust validation for all data transformations and business rules implemented in the dbt models.