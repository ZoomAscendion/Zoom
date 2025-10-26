_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Bronze Layer dbt models in Snowflake
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Zoom Bronze Layer Pipeline

## Description

This document contains comprehensive unit test cases and dbt test scripts for the Zoom Bronze Layer Pipeline that transforms raw data into bronze layer tables in Snowflake. The tests cover data transformations, business rules, edge cases, and error handling scenarios across all bronze layer models.

## Test Case Overview

The bronze layer pipeline consists of 9 models:
- `bz_audit_log` - Audit logging for data processing activities
- `bz_billing_events` - Billing and payment event data
- `bz_feature_usage` - Feature usage tracking data
- `bz_licenses` - License management data
- `bz_meetings` - Meeting data
- `bz_participants` - Meeting participant data
- `bz_support_tickets` - Support ticket data
- `bz_users` - User account data
- `bz_webinars` - Webinar data

## Test Case List

| Test Case ID | Test Case Description | Expected Outcome | Model |
|--------------|----------------------|------------------|-------|
| TC_BZ_001 | Validate audit log initialization | Audit log table created with initial record | bz_audit_log |
| TC_BZ_002 | Test billing events data transformation | All billing events transformed with correct data types | bz_billing_events |
| TC_BZ_003 | Validate feature usage data cleansing | Feature usage data cleaned and validated | bz_feature_usage |
| TC_BZ_004 | Test license data transformation | License data transformed with proper date handling | bz_licenses |
| TC_BZ_005 | Validate meeting data processing | Meeting data processed with duration calculations | bz_meetings |
| TC_BZ_006 | Test participant data relationships | Participant data maintains referential integrity | bz_participants |
| TC_BZ_007 | Validate support ticket status handling | Support tickets processed with valid statuses | bz_support_tickets |
| TC_BZ_008 | Test user data uniqueness constraints | User data maintains email uniqueness | bz_users |
| TC_BZ_009 | Validate webinar registration data | Webinar data processed with registration counts | bz_webinars |
| TC_BZ_010 | Test null value handling across models | Null values handled according to business rules | All models |
| TC_BZ_011 | Validate data type conversions | All data types converted correctly | All models |
| TC_BZ_012 | Test audit trail functionality | Audit records created for each model execution | All models |
| TC_BZ_013 | Validate timestamp consistency | Load and update timestamps are consistent | All models |
| TC_BZ_014 | Test edge case - empty source tables | Models handle empty source tables gracefully | All models |
| TC_BZ_015 | Validate referential integrity | Foreign key relationships maintained | Related models |

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# tests/schema_tests.yml
version: 2

models:
  # Audit Log Tests
  - name: bz_audit_log
    tests:
      - dbt_utils.row_count:
          operator: '>'
          value: 0
    columns:
      - name: record_id
        tests:
          - unique
          - not_null
      - name: source_table
        tests:
          - not_null
      - name: load_timestamp
        tests:
          - not_null
      - name: status
        tests:
          - accepted_values:
              values: ['STARTED', 'COMPLETED', 'FAILED', 'INITIALIZED']

  # Billing Events Tests
  - name: bz_billing_events
    tests:
      - dbt_utils.row_count:
          operator: '>'
          value: 0
      - dbt_expectations.expect_table_row_count_to_be_between:
          min_value: 1
          max_value: 1000000
    columns:
      - name: user_id
        tests:
          - not_null
          - dbt_utils.not_empty_string
      - name: event_type
        tests:
          - not_null
          - accepted_values:
              values: ['PAYMENT', 'REFUND', 'SUBSCRIPTION', 'UPGRADE', 'DOWNGRADE']
      - name: amount
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10000
      - name: event_date
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: date

  # Feature Usage Tests
  - name: bz_feature_usage
    tests:
      - dbt_utils.row_count:
          operator: '>'
          value: 0
    columns:
      - name: meeting_id
        tests:
          - not_null
          - dbt_utils.not_empty_string
      - name: feature_name
        tests:
          - not_null
          - accepted_values:
              values: ['SCREEN_SHARE', 'RECORDING', 'CHAT', 'BREAKOUT_ROOMS', 'WHITEBOARD']
      - name: usage_count
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1000

  # Licenses Tests
  - name: bz_licenses
    tests:
      - dbt_utils.row_count:
          operator: '>'
          value: 0
    columns:
      - name: license_type
        tests:
          - not_null
          - accepted_values:
              values: ['BASIC', 'PRO', 'BUSINESS', 'ENTERPRISE']
      - name: start_date
        tests:
          - not_null
      - name: end_date
        tests:
          - not_null

  # Meetings Tests
  - name: bz_meetings
    tests:
      - dbt_utils.row_count:
          operator: '>'
          value: 0
    columns:
      - name: host_id
        tests:
          - not_null
          - dbt_utils.not_empty_string
      - name: meeting_topic
        tests:
          - not_null
      - name: start_time
        tests:
          - not_null
      - name: end_time
        tests:
          - not_null
      - name: duration_minutes
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440  # 24 hours max

  # Participants Tests
  - name: bz_participants
    tests:
      - dbt_utils.row_count:
          operator: '>'
          value: 0
    columns:
      - name: meeting_id
        tests:
          - not_null
      - name: user_id
        tests:
          - not_null
      - name: join_time
        tests:
          - not_null
      - name: leave_time
        tests:
          - not_null

  # Support Tickets Tests
  - name: bz_support_tickets
    tests:
      - dbt_utils.row_count:
          operator: '>'
          value: 0
    columns:
      - name: user_id
        tests:
          - not_null
      - name: ticket_type
        tests:
          - not_null
          - accepted_values:
              values: ['TECHNICAL', 'BILLING', 'FEATURE_REQUEST', 'BUG_REPORT']
      - name: resolution_status
        tests:
          - not_null
          - accepted_values:
              values: ['OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED']

  # Users Tests
  - name: bz_users
    tests:
      - dbt_utils.row_count:
          operator: '>'
          value: 0
    columns:
      - name: user_name
        tests:
          - not_null
          - dbt_utils.not_empty_string
      - name: email
        tests:
          - not_null
          - unique
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
      - name: plan_type
        tests:
          - not_null
          - accepted_values:
              values: ['BASIC', 'PRO', 'BUSINESS', 'ENTERPRISE']

  # Webinars Tests
  - name: bz_webinars
    tests:
      - dbt_utils.row_count:
          operator: '>'
          value: 0
    columns:
      - name: host_id
        tests:
          - not_null
      - name: webinar_topic
        tests:
          - not_null
      - name: registrants
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100000
```

### Custom SQL-based dbt Tests

```sql
-- tests/test_audit_log_completeness.sql
-- Test to ensure audit log captures all model executions
SELECT 
    source_table,
    COUNT(*) as execution_count
FROM {{ ref('bz_audit_log') }}
WHERE status IN ('STARTED', 'COMPLETED')
GROUP BY source_table
HAVING COUNT(*) < 2  -- Should have at least STARTED and COMPLETED
```

```sql
-- tests/test_billing_events_amount_validation.sql
-- Test to validate billing event amounts are reasonable
SELECT 
    user_id,
    event_type,
    amount
FROM {{ ref('bz_billing_events') }}
WHERE amount < 0 
   OR amount > 10000
   OR amount IS NULL
```

```sql
-- tests/test_meeting_duration_consistency.sql
-- Test to ensure meeting duration matches start/end times
SELECT 
    host_id,
    meeting_topic,
    start_time,
    end_time,
    duration_minutes,
    DATEDIFF('minute', start_time, end_time) as calculated_duration
FROM {{ ref('bz_meetings') }}
WHERE ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) > 1
```

```sql
-- tests/test_participant_time_logic.sql
-- Test to ensure participant join time is before leave time
SELECT 
    meeting_id,
    user_id,
    join_time,
    leave_time
FROM {{ ref('bz_participants') }}
WHERE join_time >= leave_time
   OR join_time IS NULL
   OR leave_time IS NULL
```

```sql
-- tests/test_license_date_validation.sql
-- Test to ensure license start date is before end date
SELECT 
    license_type,
    assigned_to_user_id,
    start_date,
    end_date
FROM {{ ref('bz_licenses') }}
WHERE start_date >= end_date
   OR start_date IS NULL
   OR end_date IS NULL
```

```sql
-- tests/test_data_freshness.sql
-- Test to ensure data is not too old
SELECT 
    'bz_billing_events' as table_name,
    MAX(load_timestamp) as latest_load
FROM {{ ref('bz_billing_events') }}
WHERE DATEDIFF('day', MAX(load_timestamp), CURRENT_TIMESTAMP()) > 7

UNION ALL

SELECT 
    'bz_users' as table_name,
    MAX(load_timestamp) as latest_load
FROM {{ ref('bz_users') }}
WHERE DATEDIFF('day', MAX(load_timestamp), CURRENT_TIMESTAMP()) > 7
```

```sql
-- tests/test_referential_integrity.sql
-- Test referential integrity between participants and meetings
SELECT 
    p.meeting_id,
    p.user_id
FROM {{ ref('bz_participants') }} p
LEFT JOIN {{ ref('bz_meetings') }} m ON p.meeting_id = m.host_id
WHERE m.host_id IS NULL
```

```sql
-- tests/test_duplicate_records.sql
-- Test for duplicate records across key business entities
SELECT 
    user_id,
    event_type,
    event_date,
    COUNT(*) as duplicate_count
FROM {{ ref('bz_billing_events') }}
GROUP BY user_id, event_type, event_date
HAVING COUNT(*) > 1
```

### Parameterized Tests

```sql
-- macros/test_column_not_null_percentage.sql
{% macro test_column_not_null_percentage(model, column_name, threshold=0.95) %}

SELECT 
    '{{ column_name }}' as column_name,
    COUNT(*) as total_rows,
    COUNT({{ column_name }}) as non_null_rows,
    COUNT({{ column_name }}) * 1.0 / COUNT(*) as non_null_percentage
FROM {{ model }}
HAVING non_null_percentage < {{ threshold }}

{% endmacro %}
```

```sql
-- macros/test_timestamp_sequence.sql
{% macro test_timestamp_sequence(model, timestamp_column) %}

SELECT 
    {{ timestamp_column }}
FROM {{ model }}
WHERE {{ timestamp_column }} > CURRENT_TIMESTAMP()
   OR {{ timestamp_column }} < '2020-01-01'

{% endmacro %}
```

## Test Execution Strategy

### 1. Pre-execution Tests
- Validate source data availability
- Check schema compatibility
- Verify connection to Snowflake

### 2. Transformation Tests
- Data type validation
- Business rule enforcement
- Null value handling

### 3. Post-execution Tests
- Row count validation
- Data quality checks
- Audit trail verification

### 4. Performance Tests
- Query execution time
- Resource utilization
- Scalability validation

## Test Data Scenarios

### Happy Path Scenarios
- Valid data with all required fields
- Proper data types and formats
- Consistent timestamps
- Valid business relationships

### Edge Case Scenarios
- Null values in optional fields
- Boundary value testing
- Empty string handling
- Maximum field length validation

### Exception Scenarios
- Invalid data types
- Missing required fields
- Referential integrity violations
- Duplicate key violations

## Monitoring and Alerting

### dbt Test Results Tracking
- Monitor test pass/fail rates
- Track test execution times
- Alert on critical test failures
- Generate test coverage reports

### Snowflake Audit Schema Integration
- Log test results to audit tables
- Track data lineage and dependencies
- Monitor data quality trends
- Generate compliance reports

## Maintenance Guidelines

### Regular Test Updates
- Review and update test cases quarterly
- Add new tests for new business rules
- Remove obsolete tests
- Update test thresholds based on data patterns

### Performance Optimization
- Optimize test queries for large datasets
- Use sampling for performance-intensive tests
- Implement incremental testing strategies
- Monitor test execution resource usage

## Conclusion

This comprehensive test suite ensures the reliability, accuracy, and performance of the Zoom Bronze Layer Pipeline in Snowflake. The combination of schema tests, custom SQL tests, and parameterized tests provides thorough coverage of data quality, business rules, and edge cases. Regular execution and monitoring of these tests will help maintain high data quality standards and catch issues early in the development cycle.