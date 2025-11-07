## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Bronze Layer dbt models in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases - Zoom Bronze Layer Pipeline

## Overview

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Bronze Layer dbt models running in Snowflake. The test suite covers data quality validation, business rule enforcement, edge case handling, and error scenarios for all 8 Bronze layer models in the Medallion architecture.

## Test Coverage Summary

| Model | Primary Tests | Edge Case Tests | Custom Tests | Total Tests |
|-------|---------------|-----------------|--------------|-------------|
| bz_data_audit | 5 | 3 | 2 | 10 |
| bz_users | 8 | 4 | 3 | 15 |
| bz_meetings | 9 | 5 | 3 | 17 |
| bz_participants | 8 | 4 | 3 | 15 |
| bz_feature_usage | 8 | 4 | 3 | 15 |
| bz_support_tickets | 8 | 4 | 3 | 15 |
| bz_billing_events | 9 | 5 | 3 | 17 |
| bz_licenses | 9 | 4 | 3 | 16 |
| **TOTAL** | **64** | **33** | **23** | **120** |

---

## Test Case List

### 1. BZ_DATA_AUDIT Model Tests

#### Primary Data Quality Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| BZ_AUDIT_001 | Verify RECORD_ID is unique and not null | All records have unique, non-null RECORD_ID | not_null, unique |
| BZ_AUDIT_002 | Validate SOURCE_TABLE contains valid table names | All SOURCE_TABLE values match Bronze layer table names | accepted_values |
| BZ_AUDIT_003 | Check LOAD_TIMESTAMP is not null and reasonable | All timestamps are not null and within valid range | not_null, custom |
| BZ_AUDIT_004 | Verify PROCESSED_BY is populated | All records have PROCESSED_BY value | not_null |
| BZ_AUDIT_005 | Validate STATUS values are from allowed list | STATUS contains only valid values | accepted_values |

#### Edge Case Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| BZ_AUDIT_E001 | Handle null PROCESSING_TIME values | System handles null processing times gracefully | custom |
| BZ_AUDIT_E002 | Validate extremely long SOURCE_TABLE names | System truncates or handles long table names | custom |
| BZ_AUDIT_E003 | Check future LOAD_TIMESTAMP values | System flags or handles future timestamps | custom |

#### Custom Business Rule Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| BZ_AUDIT_C001 | Verify audit records exist for all Bronze tables | Each Bronze table has corresponding audit entries | custom |
| BZ_AUDIT_C002 | Check processing time is reasonable (< 3600 seconds) | All processing times are within acceptable limits | custom |

### 2. BZ_USERS Model Tests

#### Primary Data Quality Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| BZ_USERS_001 | Verify USER_ID is unique and not null | All records have unique, non-null USER_ID | not_null, unique |
| BZ_USERS_002 | Validate EMAIL format and uniqueness | All emails are valid format and unique | unique, custom |
| BZ_USERS_003 | Check USER_NAME is not null | All records have USER_NAME populated | not_null |
| BZ_USERS_004 | Verify PLAN_TYPE contains valid values | PLAN_TYPE contains only allowed subscription types | accepted_values |
| BZ_USERS_005 | Validate LOAD_TIMESTAMP is not null | All records have LOAD_TIMESTAMP | not_null |
| BZ_USERS_006 | Check UPDATE_TIMESTAMP is not null | All records have UPDATE_TIMESTAMP | not_null |
| BZ_USERS_007 | Verify SOURCE_SYSTEM is populated | All records have SOURCE_SYSTEM value | not_null |
| BZ_USERS_008 | Validate deduplication logic works correctly | No duplicate USER_ID after deduplication | unique |

#### Edge Case Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| BZ_USERS_E001 | Handle null EMAIL values | System handles missing email addresses | custom |
| BZ_USERS_E002 | Validate extremely long USER_NAME | System handles long user names appropriately | custom |
| BZ_USERS_E003 | Check invalid PLAN_TYPE values | System handles unknown plan types | custom |
| BZ_USERS_E004 | Handle null COMPANY values | System processes records with missing company | custom |

#### Custom Business Rule Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| BZ_USERS_C001 | Verify UPDATE_TIMESTAMP >= LOAD_TIMESTAMP | Update timestamp is never before load timestamp | custom |
| BZ_USERS_C002 | Check email domain validation | Email addresses have valid domain format | custom |
| BZ_USERS_C003 | Validate PII data handling compliance | PII fields are properly identified and handled | custom |

### 3. BZ_MEETINGS Model Tests

#### Primary Data Quality Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| BZ_MEETINGS_001 | Verify MEETING_ID is unique and not null | All records have unique, non-null MEETING_ID | not_null, unique |
| BZ_MEETINGS_002 | Validate HOST_ID is not null | All meetings have a host assigned | not_null |
| BZ_MEETINGS_003 | Check START_TIME is not null | All meetings have start time | not_null |
| BZ_MEETINGS_004 | Verify END_TIME is not null | All meetings have end time | not_null |
| BZ_MEETINGS_005 | Validate DURATION_MINUTES is positive | Meeting duration is always positive | custom |
| BZ_MEETINGS_006 | Check MEETING_TOPIC is not null | All meetings have a topic | not_null |
| BZ_MEETINGS_007 | Verify LOAD_TIMESTAMP is not null | All records have LOAD_TIMESTAMP | not_null |
| BZ_MEETINGS_008 | Check UPDATE_TIMESTAMP is not null | All records have UPDATE_TIMESTAMP | not_null |
| BZ_MEETINGS_009 | Verify SOURCE_SYSTEM is populated | All records have SOURCE_SYSTEM value | not_null |

#### Edge Case Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| BZ_MEETINGS_E001 | Handle meetings with zero duration | System processes zero-duration meetings | custom |
| BZ_MEETINGS_E002 | Validate extremely long meetings (>24 hours) | System handles long-duration meetings | custom |
| BZ_MEETINGS_E003 | Check END_TIME before START_TIME | System flags invalid time sequences | custom |
| BZ_MEETINGS_E004 | Handle null MEETING_TOPIC | System processes meetings without topics | custom |
| BZ_MEETINGS_E005 | Validate future meeting dates | System handles future-dated meetings | custom |

#### Custom Business Rule Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| BZ_MEETINGS_C001 | Verify END_TIME > START_TIME | End time is always after start time | custom |
| BZ_MEETINGS_C002 | Check DURATION_MINUTES matches calculated duration | Duration matches time difference | custom |
| BZ_MEETINGS_C003 | Validate HOST_ID exists in users table | All hosts are valid users | relationships |

### 4. BZ_PARTICIPANTS Model Tests

#### Primary Data Quality Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| BZ_PARTICIPANTS_001 | Verify PARTICIPANT_ID is unique and not null | All records have unique, non-null PARTICIPANT_ID | not_null, unique |
| BZ_PARTICIPANTS_002 | Validate MEETING_ID is not null | All participants are linked to meetings | not_null |
| BZ_PARTICIPANTS_003 | Check USER_ID is not null | All participants are linked to users | not_null |
| BZ_PARTICIPANTS_004 | Verify JOIN_TIME is not null | All participants have join time | not_null |
| BZ_PARTICIPANTS_005 | Check LEAVE_TIME is not null | All participants have leave time | not_null |
| BZ_PARTICIPANTS_006 | Verify LOAD_TIMESTAMP is not null | All records have LOAD_TIMESTAMP | not_null |
| BZ_PARTICIPANTS_007 | Check UPDATE_TIMESTAMP is not null | All records have UPDATE_TIMESTAMP | not_null |
| BZ_PARTICIPANTS_008 | Verify SOURCE_SYSTEM is populated | All records have SOURCE_SYSTEM value | not_null |

#### Edge Case Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| BZ_PARTICIPANTS_E001 | Handle LEAVE_TIME before JOIN_TIME | System flags invalid time sequences | custom |
| BZ_PARTICIPANTS_E002 | Validate same user multiple joins | System handles multiple participant records | custom |
| BZ_PARTICIPANTS_E003 | Check participants joining after meeting end | System handles late joiners | custom |
| BZ_PARTICIPANTS_E004 | Handle null LEAVE_TIME (ongoing participation) | System processes ongoing participants | custom |

#### Custom Business Rule Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| BZ_PARTICIPANTS_C001 | Verify LEAVE_TIME >= JOIN_TIME | Leave time is never before join time | custom |
| BZ_PARTICIPANTS_C002 | Check MEETING_ID exists in meetings table | All meetings are valid | relationships |
| BZ_PARTICIPANTS_C003 | Validate USER_ID exists in users table | All users are valid | relationships |

### 5. BZ_FEATURE_USAGE Model Tests

#### Primary Data Quality Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| BZ_FEATURE_USAGE_001 | Verify USAGE_ID is unique and not null | All records have unique, non-null USAGE_ID | not_null, unique |
| BZ_FEATURE_USAGE_002 | Validate MEETING_ID is not null | All usage records are linked to meetings | not_null |
| BZ_FEATURE_USAGE_003 | Check FEATURE_NAME is not null | All records have feature name | not_null |
| BZ_FEATURE_USAGE_004 | Verify USAGE_COUNT is positive | Usage count is always positive | custom |
| BZ_FEATURE_USAGE_005 | Check USAGE_DATE is not null | All records have usage date | not_null |
| BZ_FEATURE_USAGE_006 | Verify LOAD_TIMESTAMP is not null | All records have LOAD_TIMESTAMP | not_null |
| BZ_FEATURE_USAGE_007 | Check UPDATE_TIMESTAMP is not null | All records have UPDATE_TIMESTAMP | not_null |
| BZ_FEATURE_USAGE_008 | Verify SOURCE_SYSTEM is populated | All records have SOURCE_SYSTEM value | not_null |

#### Edge Case Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| BZ_FEATURE_USAGE_E001 | Handle zero USAGE_COUNT | System processes zero usage records | custom |
| BZ_FEATURE_USAGE_E002 | Validate extremely high usage counts | System handles high usage values | custom |
| BZ_FEATURE_USAGE_E003 | Check unknown FEATURE_NAME values | System processes new feature names | custom |
| BZ_FEATURE_USAGE_E004 | Handle future USAGE_DATE | System handles future-dated usage | custom |

#### Custom Business Rule Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| BZ_FEATURE_USAGE_C001 | Verify USAGE_COUNT >= 0 | Usage count is never negative | custom |
| BZ_FEATURE_USAGE_C002 | Check MEETING_ID exists in meetings table | All meetings are valid | relationships |
| BZ_FEATURE_USAGE_C003 | Validate USAGE_DATE within reasonable range | Usage dates are within acceptable range | custom |

### 6. BZ_SUPPORT_TICKETS Model Tests

#### Primary Data Quality Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| BZ_SUPPORT_TICKETS_001 | Verify TICKET_ID is unique and not null | All records have unique, non-null TICKET_ID | not_null, unique |
| BZ_SUPPORT_TICKETS_002 | Validate USER_ID is not null | All tickets are linked to users | not_null |
| BZ_SUPPORT_TICKETS_003 | Check TICKET_TYPE is not null | All tickets have a type | not_null |
| BZ_SUPPORT_TICKETS_004 | Verify RESOLUTION_STATUS contains valid values | Status contains only allowed values | accepted_values |
| BZ_SUPPORT_TICKETS_005 | Check OPEN_DATE is not null | All tickets have open date | not_null |
| BZ_SUPPORT_TICKETS_006 | Verify LOAD_TIMESTAMP is not null | All records have LOAD_TIMESTAMP | not_null |
| BZ_SUPPORT_TICKETS_007 | Check UPDATE_TIMESTAMP is not null | All records have UPDATE_TIMESTAMP | not_null |
| BZ_SUPPORT_TICKETS_008 | Verify SOURCE_SYSTEM is populated | All records have SOURCE_SYSTEM value | not_null |

#### Edge Case Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| BZ_SUPPORT_TICKETS_E001 | Handle unknown TICKET_TYPE values | System processes new ticket types | custom |
| BZ_SUPPORT_TICKETS_E002 | Validate future OPEN_DATE | System handles future-dated tickets | custom |
| BZ_SUPPORT_TICKETS_E003 | Check invalid RESOLUTION_STATUS | System handles unknown status values | custom |
| BZ_SUPPORT_TICKETS_E004 | Handle extremely old tickets | System processes historical tickets | custom |

#### Custom Business Rule Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| BZ_SUPPORT_TICKETS_C001 | Verify USER_ID exists in users table | All users are valid | relationships |
| BZ_SUPPORT_TICKETS_C002 | Check OPEN_DATE is not in future | Open date is not future-dated | custom |
| BZ_SUPPORT_TICKETS_C003 | Validate status transition logic | Status changes follow business rules | custom |

### 7. BZ_BILLING_EVENTS Model Tests

#### Primary Data Quality Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| BZ_BILLING_EVENTS_001 | Verify EVENT_ID is unique and not null | All records have unique, non-null EVENT_ID | not_null, unique |
| BZ_BILLING_EVENTS_002 | Validate USER_ID is not null | All events are linked to users | not_null |
| BZ_BILLING_EVENTS_003 | Check EVENT_TYPE is not null | All events have a type | not_null |
| BZ_BILLING_EVENTS_004 | Verify AMOUNT is not null | All events have amount | not_null |
| BZ_BILLING_EVENTS_005 | Check AMOUNT precision (2 decimal places) | Amount has correct decimal precision | custom |
| BZ_BILLING_EVENTS_006 | Verify EVENT_DATE is not null | All events have event date | not_null |
| BZ_BILLING_EVENTS_007 | Check LOAD_TIMESTAMP is not null | All records have LOAD_TIMESTAMP | not_null |
| BZ_BILLING_EVENTS_008 | Verify UPDATE_TIMESTAMP is not null | All records have UPDATE_TIMESTAMP | not_null |
| BZ_BILLING_EVENTS_009 | Check SOURCE_SYSTEM is populated | All records have SOURCE_SYSTEM value | not_null |

#### Edge Case Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| BZ_BILLING_EVENTS_E001 | Handle negative AMOUNT values | System processes refunds and credits | custom |
| BZ_BILLING_EVENTS_E002 | Validate zero AMOUNT transactions | System handles zero-amount events | custom |
| BZ_BILLING_EVENTS_E003 | Check extremely large amounts | System handles high-value transactions | custom |
| BZ_BILLING_EVENTS_E004 | Handle unknown EVENT_TYPE values | System processes new event types | custom |
| BZ_BILLING_EVENTS_E005 | Validate future EVENT_DATE | System handles future-dated events | custom |

#### Custom Business Rule Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| BZ_BILLING_EVENTS_C001 | Verify USER_ID exists in users table | All users are valid | relationships |
| BZ_BILLING_EVENTS_C002 | Check AMOUNT has valid precision | Amount precision matches business rules | custom |
| BZ_BILLING_EVENTS_C003 | Validate EVENT_DATE within reasonable range | Event dates are within acceptable range | custom |

### 8. BZ_LICENSES Model Tests

#### Primary Data Quality Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| BZ_LICENSES_001 | Verify LICENSE_ID is unique and not null | All records have unique, non-null LICENSE_ID | not_null, unique |
| BZ_LICENSES_002 | Validate LICENSE_TYPE is not null | All licenses have a type | not_null |
| BZ_LICENSES_003 | Check ASSIGNED_TO_USER_ID is not null | All licenses are assigned to users | not_null |
| BZ_LICENSES_004 | Verify START_DATE is not null | All licenses have start date | not_null |
| BZ_LICENSES_005 | Check END_DATE is not null | All licenses have end date | not_null |
| BZ_LICENSES_006 | Verify LOAD_TIMESTAMP is not null | All records have LOAD_TIMESTAMP | not_null |
| BZ_LICENSES_007 | Check UPDATE_TIMESTAMP is not null | All records have UPDATE_TIMESTAMP | not_null |
| BZ_LICENSES_008 | Verify SOURCE_SYSTEM is populated | All records have SOURCE_SYSTEM value | not_null |
| BZ_LICENSES_009 | Validate LICENSE_TYPE contains valid values | License type contains only allowed values | accepted_values |

#### Edge Case Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| BZ_LICENSES_E001 | Handle END_DATE before START_DATE | System flags invalid date ranges | custom |
| BZ_LICENSES_E002 | Validate expired licenses | System processes expired licenses | custom |
| BZ_LICENSES_E003 | Check future START_DATE | System handles future-effective licenses | custom |
| BZ_LICENSES_E004 | Handle unknown LICENSE_TYPE values | System processes new license types | custom |

#### Custom Business Rule Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| BZ_LICENSES_C001 | Verify END_DATE >= START_DATE | End date is never before start date | custom |
| BZ_LICENSES_C002 | Check ASSIGNED_TO_USER_ID exists in users table | All assigned users are valid | relationships |
| BZ_LICENSES_C003 | Validate license duration is reasonable | License duration is within acceptable limits | custom |

---

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# models/bronze/schema.yml
version: 2

sources:
  - name: raw
    description: "Raw data layer containing unprocessed data"
    database: DB_POC_ZOOM
    schema: RAW
    tables:
      - name: users
        columns:
          - name: user_id
            tests: [not_null, unique]
          - name: email
            tests: [not_null, unique]
      - name: meetings
        columns:
          - name: meeting_id
            tests: [not_null, unique]
          - name: host_id
            tests: [not_null]
      - name: participants
        columns:
          - name: participant_id
            tests: [not_null, unique]
          - name: meeting_id
            tests: [not_null]
          - name: user_id
            tests: [not_null]
      - name: feature_usage
        columns:
          - name: usage_id
            tests: [not_null, unique]
          - name: meeting_id
            tests: [not_null]
      - name: support_tickets
        columns:
          - name: ticket_id
            tests: [not_null, unique]
          - name: user_id
            tests: [not_null]
      - name: billing_events
        columns:
          - name: event_id
            tests: [not_null, unique]
          - name: user_id
            tests: [not_null]
      - name: licenses
        columns:
          - name: license_id
            tests: [not_null, unique]
          - name: assigned_to_user_id
            tests: [not_null]

models:
  - name: bz_data_audit
    description: "Comprehensive audit trail for Bronze layer operations"
    columns:
      - name: record_id
        description: "Auto-incrementing unique identifier"
        tests: [not_null, unique]
      - name: source_table
        description: "Name of the Bronze layer table"
        tests: 
          - not_null
          - accepted_values:
              values: ['BZ_USERS', 'BZ_MEETINGS', 'BZ_PARTICIPANTS', 'BZ_FEATURE_USAGE', 'BZ_SUPPORT_TICKETS', 'BZ_BILLING_EVENTS', 'BZ_LICENSES']
      - name: load_timestamp
        description: "When the operation occurred"
        tests: [not_null]
      - name: processed_by
        description: "User or process that performed the operation"
        tests: [not_null]
      - name: status
        description: "Status of the operation"
        tests:
          - not_null
          - accepted_values:
              values: ['INITIALIZED', 'STARTED', 'COMPLETED', 'FAILED', 'WARNING']

  - name: bz_users
    description: "Bronze layer users table with deduplication"
    columns:
      - name: user_id
        description: "Unique identifier for each user"
        tests: [not_null, unique]
      - name: user_name
        description: "Display name of the user"
        tests: [not_null]
      - name: email
        description: "Email address of the user"
        tests: [not_null, unique]
      - name: company
        description: "Company or organization name"
        tests: [not_null]
      - name: plan_type
        description: "Subscription plan type"
        tests:
          - not_null
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise']
      - name: load_timestamp
        tests: [not_null]
      - name: update_timestamp
        tests: [not_null]
      - name: source_system
        tests: [not_null]

  - name: bz_meetings
    description: "Bronze layer meetings table with deduplication"
    columns:
      - name: meeting_id
        description: "Unique identifier for each meeting"
        tests: [not_null, unique]
      - name: host_id
        description: "User ID of the meeting host"
        tests: 
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: meeting_topic
        tests: [not_null]
      - name: start_time
        tests: [not_null]
      - name: end_time
        tests: [not_null]
      - name: duration_minutes
        tests: [not_null]
      - name: load_timestamp
        tests: [not_null]
      - name: update_timestamp
        tests: [not_null]
      - name: source_system
        tests: [not_null]

  - name: bz_participants
    description: "Bronze layer participants table with deduplication"
    columns:
      - name: participant_id
        description: "Unique identifier for each participant"
        tests: [not_null, unique]
      - name: meeting_id
        description: "Reference to meeting"
        tests:
          - not_null
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
      - name: user_id
        description: "Reference to user who participated"
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: join_time
        tests: [not_null]
      - name: leave_time
        tests: [not_null]
      - name: load_timestamp
        tests: [not_null]
      - name: update_timestamp
        tests: [not_null]
      - name: source_system
        tests: [not_null]

  - name: bz_feature_usage
    description: "Bronze layer feature usage table with deduplication"
    columns:
      - name: usage_id
        description: "Unique identifier for each usage record"
        tests: [not_null, unique]
      - name: meeting_id
        description: "Reference to meeting where feature was used"
        tests:
          - not_null
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
      - name: feature_name
        tests: [not_null]
      - name: usage_count
        tests: [not_null]
      - name: usage_date
        tests: [not_null]
      - name: load_timestamp
        tests: [not_null]
      - name: update_timestamp
        tests: [not_null]
      - name: source_system
        tests: [not_null]

  - name: bz_support_tickets
    description: "Bronze layer support tickets table with deduplication"
    columns:
      - name: ticket_id
        description: "Unique identifier for each support ticket"
        tests: [not_null, unique]
      - name: user_id
        description: "Reference to user who created the ticket"
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: ticket_type
        tests: [not_null]
      - name: resolution_status
        tests:
          - not_null
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed']
      - name: open_date
        tests: [not_null]
      - name: load_timestamp
        tests: [not_null]
      - name: update_timestamp
        tests: [not_null]
      - name: source_system
        tests: [not_null]

  - name: bz_billing_events
    description: "Bronze layer billing events table with deduplication"
    columns:
      - name: event_id
        description: "Unique identifier for each billing event"
        tests: [not_null, unique]
      - name: user_id
        description: "Reference to user associated with billing event"
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: event_type
        tests: [not_null]
      - name: amount
        tests: [not_null]
      - name: event_date
        tests: [not_null]
      - name: load_timestamp
        tests: [not_null]
      - name: update_timestamp
        tests: [not_null]
      - name: source_system
        tests: [not_null]

  - name: bz_licenses
    description: "Bronze layer licenses table with deduplication"
    columns:
      - name: license_id
        description: "Unique identifier for each license"
        tests: [not_null, unique]
      - name: license_type
        tests:
          - not_null
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise']
      - name: assigned_to_user_id
        description: "User ID to whom license is assigned"
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: start_date
        tests: [not_null]
      - name: end_date
        tests: [not_null]
      - name: load_timestamp
        tests: [not_null]
      - name: update_timestamp
        tests: [not_null]
      - name: source_system
        tests: [not_null]
```

### Custom SQL-based dbt Tests

#### 1. Test for Valid Email Format

```sql
-- tests/assert_valid_email_format.sql
-- Test to ensure all email addresses have valid format
SELECT 
    user_id,
    email
FROM {{ ref('bz_users') }}
WHERE email IS NOT NULL
  AND NOT REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
```

#### 2. Test for Meeting Duration Consistency

```sql
-- tests/assert_meeting_duration_consistency.sql
-- Test to ensure duration_minutes matches calculated duration
SELECT 
    meeting_id,
    duration_minutes,
    DATEDIFF('minute', start_time, end_time) AS calculated_duration
FROM {{ ref('bz_meetings') }}
WHERE ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) > 1
```

#### 3. Test for Participant Time Logic

```sql
-- tests/assert_participant_time_logic.sql
-- Test to ensure leave_time is after join_time
SELECT 
    participant_id,
    join_time,
    leave_time
FROM {{ ref('bz_participants') }}
WHERE leave_time < join_time
```

#### 4. Test for Positive Usage Count

```sql
-- tests/assert_positive_usage_count.sql
-- Test to ensure usage_count is positive
SELECT 
    usage_id,
    usage_count
FROM {{ ref('bz_feature_usage') }}
WHERE usage_count <= 0
```

#### 5. Test for License Date Logic

```sql
-- tests/assert_license_date_logic.sql
-- Test to ensure end_date is after start_date
SELECT 
    license_id,
    start_date,
    end_date
FROM {{ ref('bz_licenses') }}
WHERE end_date < start_date
```

#### 6. Test for Reasonable Processing Time

```sql
-- tests/assert_reasonable_processing_time.sql
-- Test to ensure processing time is within acceptable limits
SELECT 
    record_id,
    source_table,
    processing_time
FROM {{ ref('bz_data_audit') }}
WHERE processing_time > 3600 -- More than 1 hour
   OR processing_time < 0    -- Negative time
```

#### 7. Test for Update Timestamp Logic

```sql
-- tests/assert_update_timestamp_logic.sql
-- Test to ensure update_timestamp >= load_timestamp across all tables
WITH all_timestamps AS (
    SELECT 'bz_users' as table_name, user_id as record_id, load_timestamp, update_timestamp FROM {{ ref('bz_users') }}
    UNION ALL
    SELECT 'bz_meetings', meeting_id, load_timestamp, update_timestamp FROM {{ ref('bz_meetings') }}
    UNION ALL
    SELECT 'bz_participants', participant_id, load_timestamp, update_timestamp FROM {{ ref('bz_participants') }}
    UNION ALL
    SELECT 'bz_feature_usage', usage_id, load_timestamp, update_timestamp FROM {{ ref('bz_feature_usage') }}
    UNION ALL
    SELECT 'bz_support_tickets', ticket_id, load_timestamp, update_timestamp FROM {{ ref('bz_support_tickets') }}
    UNION ALL
    SELECT 'bz_billing_events', event_id, load_timestamp, update_timestamp FROM {{ ref('bz_billing_events') }}
    UNION ALL
    SELECT 'bz_licenses', license_id, load_timestamp, update_timestamp FROM {{ ref('bz_licenses') }}
)
SELECT 
    table_name,
    record_id,
    load_timestamp,
    update_timestamp
FROM all_timestamps
WHERE update_timestamp < load_timestamp
```

#### 8. Test for Billing Amount Precision

```sql
-- tests/assert_billing_amount_precision.sql
-- Test to ensure billing amounts have correct precision (2 decimal places)
SELECT 
    event_id,
    amount,
    ROUND(amount, 2) as rounded_amount
FROM {{ ref('bz_billing_events') }}
WHERE amount != ROUND(amount, 2)
```

#### 9. Test for Future Date Validation

```sql
-- tests/assert_no_future_dates.sql
-- Test to ensure no business dates are in the future
WITH future_dates AS (
    SELECT 'bz_support_tickets' as table_name, ticket_id as record_id, open_date as business_date FROM {{ ref('bz_support_tickets') }} WHERE open_date > CURRENT_DATE()
    UNION ALL
    SELECT 'bz_billing_events', event_id, event_date FROM {{ ref('bz_billing_events') }} WHERE event_date > CURRENT_DATE()
    UNION ALL
    SELECT 'bz_feature_usage', usage_id, usage_date FROM {{ ref('bz_feature_usage') }} WHERE usage_date > CURRENT_DATE()
)
SELECT * FROM future_dates
```

#### 10. Test for Audit Coverage

```sql
-- tests/assert_audit_coverage.sql
-- Test to ensure all Bronze tables have audit entries
WITH expected_tables AS (
    SELECT 'BZ_USERS' as table_name
    UNION ALL SELECT 'BZ_MEETINGS'
    UNION ALL SELECT 'BZ_PARTICIPANTS'
    UNION ALL SELECT 'BZ_FEATURE_USAGE'
    UNION ALL SELECT 'BZ_SUPPORT_TICKETS'
    UNION ALL SELECT 'BZ_BILLING_EVENTS'
    UNION ALL SELECT 'BZ_LICENSES'
),
audited_tables AS (
    SELECT DISTINCT source_table as table_name
    FROM {{ ref('bz_data_audit') }}
)
SELECT e.table_name
FROM expected_tables e
LEFT JOIN audited_tables a ON e.table_name = a.table_name
WHERE a.table_name IS NULL
```

### Parameterized Tests

#### Generic Test for Timestamp Validation

```sql
-- macros/test_timestamp_not_future.sql
{% macro test_timestamp_not_future(model, column_name) %}
    SELECT *
    FROM {{ model }}
    WHERE {{ column_name }} > CURRENT_TIMESTAMP()
{% endmacro %}
```

#### Generic Test for Positive Numbers

```sql
-- macros/test_positive_number.sql
{% macro test_positive_number(model, column_name) %}
    SELECT *
    FROM {{ model }}
    WHERE {{ column_name }} <= 0
{% endmacro %}
```

#### Generic Test for String Length

```sql
-- macros/test_string_length.sql
{% macro test_string_length(model, column_name, max_length) %}
    SELECT *
    FROM {{ model }}
    WHERE LENGTH({{ column_name }}) > {{ max_length }}
{% endmacro %}
```

---

## Test Execution Strategy

### 1. Test Execution Order

1. **Source Tests**: Validate raw data quality
2. **Model Tests**: Test individual model transformations
3. **Relationship Tests**: Validate cross-model relationships
4. **Custom Business Rule Tests**: Validate complex business logic
5. **Edge Case Tests**: Test boundary conditions
6. **Performance Tests**: Validate query performance

### 2. Test Environment Configuration

```yaml
# dbt_project.yml test configuration
test-paths: ["tests"]
target-path: "target"

vars:
  # Test thresholds
  max_processing_time: 3600
  max_string_length: 1000
  acceptable_null_percentage: 0.05

models:
  zoom_bronze_pipeline:
    bronze:
      +materialized: table
      +on_schema_change: "fail"
      +pre-hook: "{{ log('Starting Bronze layer model execution', info=true) }}"
      +post-hook: "{{ log('Completed Bronze layer model execution', info=true) }}"

tests:
  zoom_bronze_pipeline:
    +severity: error
    +store_failures: true
    +schema: bronze_test_results
```

### 3. Continuous Integration Integration

```yaml
# .github/workflows/dbt_tests.yml
name: dbt Tests
on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup dbt
        run: |
          pip install dbt-snowflake
      - name: Run dbt tests
        run: |
          dbt deps
          dbt seed
          dbt run --models bronze
          dbt test --models bronze
          dbt test --select test_type:generic
          dbt test --select test_type:singular
```

### 4. Test Results Monitoring

```sql
-- models/bronze/test_results_summary.sql
-- Summary of test results for monitoring
WITH test_results AS (
    SELECT 
        test_name,
        model_name,
        status,
        execution_time,
        failures,
        run_started_at
    FROM {{ ref('run_results') }}
    WHERE resource_type = 'test'
),
test_summary AS (
    SELECT 
        DATE(run_started_at) as test_date,
        COUNT(*) as total_tests,
        SUM(CASE WHEN status = 'pass' THEN 1 ELSE 0 END) as passed_tests,
        SUM(CASE WHEN status = 'fail' THEN 1 ELSE 0 END) as failed_tests,
        SUM(CASE WHEN status = 'error' THEN 1 ELSE 0 END) as error_tests,
        AVG(execution_time) as avg_execution_time,
        SUM(failures) as total_failures
    FROM test_results
    GROUP BY DATE(run_started_at)
)
SELECT * FROM test_summary
ORDER BY test_date DESC
```

---

## Performance and Scalability Considerations

### 1. Test Performance Optimization

- **Incremental Testing**: Run tests only on changed models
- **Parallel Execution**: Leverage dbt's parallel test execution
- **Test Sampling**: Use sampling for large datasets in development
- **Index Optimization**: Ensure proper indexing on test columns

### 2. Data Volume Handling

```sql
-- Example of sampling for large datasets in development
{% if target.name == 'dev' %}
    SELECT * FROM {{ ref('bz_users') }} SAMPLE (1000 ROWS)
{% else %}
    SELECT * FROM {{ ref('bz_users') }}
{% endif %}
```

### 3. Test Result Storage

```yaml
# Configure test result storage
tests:
  +store_failures: true
  +store_failures_as: table
  +schema: bronze_test_failures
```

---

## Maintenance and Updates

### 1. Test Case Versioning

- Version control all test cases
- Document test case changes
- Maintain backward compatibility
- Regular test case reviews

### 2. Test Data Management

- Maintain test data fixtures
- Regular test data refresh
- Data privacy compliance
- Test data anonymization

### 3. Monitoring and Alerting

```sql
-- Alert query for critical test failures
SELECT 
    test_name,
    model_name,
    failures,
    run_started_at
FROM {{ ref('run_results') }}
WHERE status = 'fail'
  AND severity = 'error'
  AND run_started_at >= CURRENT_TIMESTAMP() - INTERVAL '1 hour'
```

---

## Summary

This comprehensive unit test suite provides:

- **120 total test cases** covering all Bronze layer models
- **Complete data quality validation** with not_null, unique, and accepted_values tests
- **Business rule enforcement** through custom SQL tests
- **Edge case handling** for boundary conditions and error scenarios
- **Relationship validation** ensuring referential integrity
- **Performance monitoring** and scalability considerations
- **CI/CD integration** for automated testing
- **Comprehensive documentation** for maintenance and updates

The test suite ensures the reliability, performance, and data quality of the Zoom Bronze Layer dbt models in Snowflake, providing early detection of issues and maintaining high standards for the data pipeline.
