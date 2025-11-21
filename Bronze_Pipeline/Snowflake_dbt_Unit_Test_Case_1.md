_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Bronze Layer dbt models in Snowflake
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Zoom Bronze Layer Models

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Bronze Layer dbt models that run in Snowflake. The test cases cover key transformations, business rules, edge cases, and error handling scenarios to ensure data quality and pipeline reliability.

## Test Case Overview

The Bronze Layer consists of 8 main models:
1. **bz_data_audit** - Audit trail for Bronze layer operations
2. **bz_users** - User profile and subscription information
3. **bz_meetings** - Meeting information and session details
4. **bz_participants** - Meeting participants and session details
5. **bz_feature_usage** - Platform feature usage during meetings
6. **bz_support_tickets** - Customer support requests and resolution tracking
7. **bz_billing_events** - Financial transactions and billing activities
8. **bz_licenses** - License assignments and entitlements

---

## Test Case List

### 1. BZ_DATA_AUDIT Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_AUDIT_001 | Verify audit table structure creation | Table created with correct schema (record_id, source_table, load_timestamp, processed_by, processing_time, status) |
| TC_AUDIT_002 | Test record_id uniqueness and not_null constraints | All record_id values are unique and not null |
| TC_AUDIT_003 | Validate audit trail insertion via pre/post hooks | Audit records created for each Bronze model execution |
| TC_AUDIT_004 | Test status values validation | Status field contains only valid values (STARTED, SUCCESS, FAILED, WARNING) |
| TC_AUDIT_005 | Verify processing time calculation | Processing time is calculated correctly in seconds |

### 2. BZ_USERS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_USERS_001 | Test primary key uniqueness and not_null | user_id is unique and not null across all records |
| TC_USERS_002 | Validate deduplication logic | Only latest record per user_id based on update_timestamp |
| TC_USERS_003 | Test null primary key filtering | Records with null user_id are excluded from Bronze layer |
| TC_USERS_004 | Verify timestamp overwrite functionality | load_timestamp and update_timestamp reflect current DBT run time |
| TC_USERS_005 | Test email format validation | Email addresses follow valid format patterns |
| TC_USERS_006 | Validate plan_type accepted values | plan_type contains only valid subscription types |
| TC_USERS_007 | Test source system tracking | source_system field is populated for all records |
| TC_USERS_008 | Handle duplicate user_id with different timestamps | Most recent record is retained based on update_timestamp |

### 3. BZ_MEETINGS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_MEETINGS_001 | Test primary key uniqueness and not_null | meeting_id is unique and not null across all records |
| TC_MEETINGS_002 | Validate data type conversions | end_time converted from VARCHAR to TIMESTAMP_NTZ(9) |
| TC_MEETINGS_003 | Test duration_minutes conversion | duration_minutes converted from VARCHAR to NUMBER(38,0) |
| TC_MEETINGS_004 | Verify deduplication logic | Only latest record per meeting_id based on update_timestamp |
| TC_MEETINGS_005 | Test null primary key filtering | Records with null meeting_id are excluded |
| TC_MEETINGS_006 | Validate meeting duration logic | Duration is positive and reasonable (0-1440 minutes) |
| TC_MEETINGS_007 | Test start_time vs end_time validation | end_time is after start_time when both are present |
| TC_MEETINGS_008 | Handle invalid date conversions | TRY_CAST handles invalid date formats gracefully |
| TC_MEETINGS_009 | Test host_id relationship | host_id references valid users in the system |

### 4. BZ_PARTICIPANTS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_PARTICIPANTS_001 | Test primary key uniqueness and not_null | participant_id is unique and not null |
| TC_PARTICIPANTS_002 | Validate join_time data type conversion | join_time converted from VARCHAR to TIMESTAMP_NTZ(9) |
| TC_PARTICIPANTS_003 | Test meeting_id foreign key relationship | meeting_id references existing meetings |
| TC_PARTICIPANTS_004 | Validate user_id foreign key relationship | user_id references existing users |
| TC_PARTICIPANTS_005 | Test join_time vs leave_time logic | leave_time is after join_time when both are present |
| TC_PARTICIPANTS_006 | Verify deduplication logic | Only latest record per participant_id |
| TC_PARTICIPANTS_007 | Test null primary key filtering | Records with null participant_id are excluded |
| TC_PARTICIPANTS_008 | Handle invalid timestamp conversions | TRY_CAST handles invalid timestamp formats |
| TC_PARTICIPANTS_009 | Test participant session duration | Session duration is reasonable and positive |

### 5. BZ_FEATURE_USAGE Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_FEATURE_001 | Test primary key uniqueness and not_null | usage_id is unique and not null |
| TC_FEATURE_002 | Validate meeting_id foreign key relationship | meeting_id references existing meetings |
| TC_FEATURE_003 | Test feature_name standardization | feature_name values are standardized and valid |
| TC_FEATURE_004 | Validate usage_count data quality | usage_count is positive integer |
| TC_FEATURE_005 | Test usage_date validation | usage_date is valid date format |
| TC_FEATURE_006 | Verify deduplication logic | Only latest record per usage_id |
| TC_FEATURE_007 | Test null primary key filtering | Records with null usage_id are excluded |
| TC_FEATURE_008 | Validate feature usage patterns | Usage counts are within reasonable ranges |

### 6. BZ_SUPPORT_TICKETS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_SUPPORT_001 | Test primary key uniqueness and not_null | ticket_id is unique and not null |
| TC_SUPPORT_002 | Validate user_id foreign key relationship | user_id references existing users |
| TC_SUPPORT_003 | Test ticket_type accepted values | ticket_type contains valid categories |
| TC_SUPPORT_004 | Validate resolution_status values | resolution_status contains valid status values |
| TC_SUPPORT_005 | Test open_date validation | open_date is valid date format |
| TC_SUPPORT_006 | Verify deduplication logic | Only latest record per ticket_id |
| TC_SUPPORT_007 | Test null primary key filtering | Records with null ticket_id are excluded |
| TC_SUPPORT_008 | Validate ticket lifecycle | Tickets follow proper status progression |

### 7. BZ_BILLING_EVENTS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BILLING_001 | Test primary key uniqueness and not_null | event_id is unique and not null |
| TC_BILLING_002 | Validate amount data type conversion | amount converted from VARCHAR to NUMBER(10,2) |
| TC_BILLING_003 | Test user_id foreign key relationship | user_id references existing users |
| TC_BILLING_004 | Validate event_type accepted values | event_type contains valid billing event types |
| TC_BILLING_005 | Test amount validation | amount is positive for charges, negative for refunds |
| TC_BILLING_006 | Verify deduplication logic | Only latest record per event_id |
| TC_BILLING_007 | Test null primary key filtering | Records with null event_id are excluded |
| TC_BILLING_008 | Handle invalid amount conversions | TRY_CAST handles invalid amount formats |
| TC_BILLING_009 | Validate event_date format | event_date is valid date format |

### 8. BZ_LICENSES Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_LICENSES_001 | Test primary key uniqueness and not_null | license_id is unique and not null |
| TC_LICENSES_002 | Validate end_date data type conversion | end_date converted from VARCHAR to DATE |
| TC_LICENSES_003 | Test assigned_to_user_id foreign key | assigned_to_user_id references existing users |
| TC_LICENSES_004 | Validate license_type accepted values | license_type contains valid license types |
| TC_LICENSES_005 | Test date range validation | end_date is after start_date when both are present |
| TC_LICENSES_006 | Verify deduplication logic | Only latest record per license_id |
| TC_LICENSES_007 | Test null primary key filtering | Records with null license_id are excluded |
| TC_LICENSES_008 | Handle invalid date conversions | TRY_CAST handles invalid date formats |
| TC_LICENSES_009 | Validate license expiration logic | Active licenses have end_date in future |

---

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# tests/schema_tests.yml
version: 2

models:
  # BZ_DATA_AUDIT Tests
  - name: bz_data_audit
    tests:
      - dbt_utils.table_columns_to_contain_substring:
          column_list: ['record_id', 'source_table', 'load_timestamp']
    columns:
      - name: record_id
        tests:
          - not_null
          - unique
      - name: source_table
        tests:
          - not_null
          - accepted_values:
              values: ['BZ_USERS', 'BZ_MEETINGS', 'BZ_PARTICIPANTS', 'BZ_FEATURE_USAGE', 'BZ_SUPPORT_TICKETS', 'BZ_BILLING_EVENTS', 'BZ_LICENSES']
      - name: status
        tests:
          - accepted_values:
              values: ['STARTED', 'SUCCESS', 'FAILED', 'WARNING']
      - name: processing_time
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: number

  # BZ_USERS Tests
  - name: bz_users
    tests:
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - user_id
      - dbt_expectations.expect_table_row_count_to_be_between:
          min_value: 1
    columns:
      - name: user_id
        tests:
          - not_null
          - unique
      - name: email
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
      - name: plan_type
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise']
      - name: load_timestamp
        tests:
          - not_null
      - name: source_system
        tests:
          - not_null

  # BZ_MEETINGS Tests
  - name: bz_meetings
    tests:
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - meeting_id
    columns:
      - name: meeting_id
        tests:
          - not_null
          - unique
      - name: host_id
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: duration_minutes
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440
      - name: start_time
        tests:
          - not_null
      - name: end_time
        tests:
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: timestamp_ntz

  # BZ_PARTICIPANTS Tests
  - name: bz_participants
    columns:
      - name: participant_id
        tests:
          - not_null
          - unique
      - name: meeting_id
        tests:
          - not_null
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
      - name: user_id
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: join_time
        tests:
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: timestamp_ntz

  # BZ_FEATURE_USAGE Tests
  - name: bz_feature_usage
    columns:
      - name: usage_id
        tests:
          - not_null
          - unique
      - name: meeting_id
        tests:
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
      - name: feature_name
        tests:
          - not_null
          - accepted_values:
              values: ['screen_share', 'chat', 'recording', 'breakout_rooms', 'whiteboard', 'polls']
      - name: usage_count
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1000

  # BZ_SUPPORT_TICKETS Tests
  - name: bz_support_tickets
    columns:
      - name: ticket_id
        tests:
          - not_null
          - unique
      - name: user_id
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: ticket_type
        tests:
          - accepted_values:
              values: ['Technical', 'Billing', 'Account', 'Feature Request', 'Bug Report']
      - name: resolution_status
        tests:
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed', 'Escalated']

  # BZ_BILLING_EVENTS Tests
  - name: bz_billing_events
    columns:
      - name: event_id
        tests:
          - not_null
          - unique
      - name: user_id
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: event_type
        tests:
          - accepted_values:
              values: ['Charge', 'Refund', 'Credit', 'Adjustment']
      - name: amount
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: number

  # BZ_LICENSES Tests
  - name: bz_licenses
    columns:
      - name: license_id
        tests:
          - not_null
          - unique
      - name: assigned_to_user_id
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: license_type
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise', 'Developer']
      - name: end_date
        tests:
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: date
```

### Custom SQL-based dbt Tests

```sql
-- tests/test_meeting_duration_consistency.sql
-- Test that meeting duration matches calculated duration from start/end times
SELECT 
    meeting_id,
    duration_minutes,
    DATEDIFF('minute', start_time, end_time) AS calculated_duration
FROM {{ ref('bz_meetings') }}
WHERE 
    start_time IS NOT NULL 
    AND end_time IS NOT NULL
    AND ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) > 1
```

```sql
-- tests/test_participant_session_validity.sql
-- Test that participant join/leave times are within meeting duration
SELECT 
    p.participant_id,
    p.meeting_id,
    p.join_time,
    p.leave_time,
    m.start_time,
    m.end_time
FROM {{ ref('bz_participants') }} p
JOIN {{ ref('bz_meetings') }} m ON p.meeting_id = m.meeting_id
WHERE 
    p.join_time < m.start_time 
    OR (p.leave_time IS NOT NULL AND p.leave_time > m.end_time)
    OR (p.join_time IS NOT NULL AND p.leave_time IS NOT NULL AND p.join_time >= p.leave_time)
```

```sql
-- tests/test_billing_amount_validation.sql
-- Test that billing amounts are reasonable and follow business rules
SELECT 
    event_id,
    event_type,
    amount
FROM {{ ref('bz_billing_events') }}
WHERE 
    (event_type = 'Charge' AND amount <= 0)
    OR (event_type = 'Refund' AND amount >= 0)
    OR ABS(amount) > 10000  -- Assuming max charge is $10,000
```

```sql
-- tests/test_license_date_validity.sql
-- Test that license start and end dates are logical
SELECT 
    license_id,
    start_date,
    end_date
FROM {{ ref('bz_licenses') }}
WHERE 
    end_date IS NOT NULL 
    AND start_date >= end_date
```

```sql
-- tests/test_deduplication_effectiveness.sql
-- Test that deduplication is working correctly across all models
WITH duplicate_check AS (
    SELECT 'bz_users' as table_name, COUNT(*) as total_records, COUNT(DISTINCT user_id) as unique_records FROM {{ ref('bz_users') }}
    UNION ALL
    SELECT 'bz_meetings', COUNT(*), COUNT(DISTINCT meeting_id) FROM {{ ref('bz_meetings') }}
    UNION ALL
    SELECT 'bz_participants', COUNT(*), COUNT(DISTINCT participant_id) FROM {{ ref('bz_participants') }}
    UNION ALL
    SELECT 'bz_feature_usage', COUNT(*), COUNT(DISTINCT usage_id) FROM {{ ref('bz_feature_usage') }}
    UNION ALL
    SELECT 'bz_support_tickets', COUNT(*), COUNT(DISTINCT ticket_id) FROM {{ ref('bz_support_tickets') }}
    UNION ALL
    SELECT 'bz_billing_events', COUNT(*), COUNT(DISTINCT event_id) FROM {{ ref('bz_billing_events') }}
    UNION ALL
    SELECT 'bz_licenses', COUNT(*), COUNT(DISTINCT license_id) FROM {{ ref('bz_licenses') }}
)
SELECT 
    table_name,
    total_records,
    unique_records,
    total_records - unique_records as duplicate_count
FROM duplicate_check
WHERE total_records != unique_records
```

```sql
-- tests/test_timestamp_consistency.sql
-- Test that all Bronze models have consistent load_timestamp values
WITH timestamp_check AS (
    SELECT 'bz_users' as table_name, MIN(load_timestamp) as min_ts, MAX(load_timestamp) as max_ts FROM {{ ref('bz_users') }}
    UNION ALL
    SELECT 'bz_meetings', MIN(load_timestamp), MAX(load_timestamp) FROM {{ ref('bz_meetings') }}
    UNION ALL
    SELECT 'bz_participants', MIN(load_timestamp), MAX(load_timestamp) FROM {{ ref('bz_participants') }}
    UNION ALL
    SELECT 'bz_feature_usage', MIN(load_timestamp), MAX(load_timestamp) FROM {{ ref('bz_feature_usage') }}
    UNION ALL
    SELECT 'bz_support_tickets', MIN(load_timestamp), MAX(load_timestamp) FROM {{ ref('bz_support_tickets') }}
    UNION ALL
    SELECT 'bz_billing_events', MIN(load_timestamp), MAX(load_timestamp) FROM {{ ref('bz_billing_events') }}
    UNION ALL
    SELECT 'bz_licenses', MIN(load_timestamp), MAX(load_timestamp) FROM {{ ref('bz_licenses') }}
)
SELECT 
    table_name,
    min_ts,
    max_ts,
    DATEDIFF('second', min_ts, max_ts) as timestamp_diff_seconds
FROM timestamp_check
WHERE DATEDIFF('second', min_ts, max_ts) > 300  -- Flag if timestamps differ by more than 5 minutes
```

```sql
-- tests/test_audit_trail_completeness.sql
-- Test that audit trail captures all Bronze model executions
WITH expected_tables AS (
    SELECT table_name FROM (
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
actual_audit AS (
    SELECT DISTINCT source_table
    FROM {{ ref('bz_data_audit') }}
    WHERE status = 'SUCCESS'
)
SELECT 
    e.table_name
FROM expected_tables e
LEFT JOIN actual_audit a ON e.table_name = a.source_table
WHERE a.source_table IS NULL
```

### Parameterized Tests

```sql
-- macros/test_primary_key_quality.sql
{% macro test_primary_key_quality(model, primary_key_column) %}
    SELECT 
        '{{ primary_key_column }}' as column_name,
        COUNT(*) as total_records,
        COUNT({{ primary_key_column }}) as non_null_records,
        COUNT(DISTINCT {{ primary_key_column }}) as unique_records,
        COUNT(*) - COUNT({{ primary_key_column }}) as null_count,
        COUNT({{ primary_key_column }}) - COUNT(DISTINCT {{ primary_key_column }}) as duplicate_count
    FROM {{ model }}
    HAVING 
        null_count > 0 
        OR duplicate_count > 0
{% endmacro %}
```

```sql
-- macros/test_foreign_key_integrity.sql
{% macro test_foreign_key_integrity(child_model, child_column, parent_model, parent_column) %}
    SELECT 
        c.{{ child_column }} as orphaned_key,
        COUNT(*) as orphan_count
    FROM {{ child_model }} c
    LEFT JOIN {{ parent_model }} p ON c.{{ child_column }} = p.{{ parent_column }}
    WHERE 
        c.{{ child_column }} IS NOT NULL 
        AND p.{{ parent_column }} IS NULL
    GROUP BY c.{{ child_column }}
    HAVING COUNT(*) > 0
{% endmacro %}
```

### Test Execution Commands

```bash
# Run all tests
dbt test

# Run tests for specific model
dbt test --select bz_users

# Run only schema tests
dbt test --select test_type:schema

# Run only custom SQL tests
dbt test --select test_type:data

# Run tests with specific tags
dbt test --select tag:bronze

# Generate test documentation
dbt docs generate
dbt docs serve
```

## Test Results Tracking

All test results are automatically tracked in:
- **dbt's run_results.json**: Contains detailed test execution results
- **Snowflake audit schema**: Custom audit tables for Bronze layer operations
- **dbt Cloud/Airflow logs**: Integration with orchestration platforms

## Maintenance Guidelines

1. **Regular Test Review**: Review and update test cases monthly
2. **Performance Monitoring**: Monitor test execution times and optimize slow tests
3. **Coverage Analysis**: Ensure new models include comprehensive test coverage
4. **Documentation Updates**: Keep test documentation synchronized with model changes
5. **Failure Investigation**: Establish procedures for investigating and resolving test failures

## Conclusion

These comprehensive unit test cases ensure the reliability, performance, and data quality of the Zoom Bronze Layer dbt models in Snowflake. The combination of schema tests, custom SQL tests, and parameterized tests provides robust coverage for all transformation logic, business rules, and edge cases.