_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Bronze Layer Pipeline dbt models in Snowflake
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Zoom Bronze Layer Pipeline

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Bronze Layer Pipeline dbt models running in Snowflake. The test cases cover data transformations, business rules, edge cases, and error handling scenarios to ensure data quality and pipeline reliability.

## Test Coverage Overview

The test suite covers the following bronze layer models:
- `bz_audit_log` - Audit logging functionality
- `bz_billing_events` - Billing and payment events
- `bz_feature_usage` - Feature usage tracking
- `bz_licenses` - License management
- `bz_meetings` - Meeting data
- `bz_participants` - Meeting participants
- `bz_support_tickets` - Support ticket information
- `bz_users` - User account data
- `bz_webinars` - Webinar information

## Test Case List

### 1. Data Quality and Validation Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) |
|--------------|----------------------|------------------|----------|
| TC_DQ_001 | Validate non-null constraints on required fields | All required fields should not contain null values | All models |
| TC_DQ_002 | Validate data type casting and conversion | All fields should be cast to correct data types | All models |
| TC_DQ_003 | Validate row quality status filtering | Only records with 'VALID' status should be included | All models except bz_audit_log |
| TC_DQ_004 | Validate timestamp field formats | All timestamp fields should be in TIMESTAMP_NTZ format | All models |
| TC_DQ_005 | Validate date field formats | All date fields should be in DATE format | bz_billing_events, bz_feature_usage, bz_licenses, bz_support_tickets |

### 2. Business Logic Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) |
|--------------|----------------------|------------------|----------|
| TC_BL_001 | Validate email format in users table | Email field should contain valid email addresses | bz_users |
| TC_BL_002 | Validate positive amounts in billing events | Amount field should be greater than 0 | bz_billing_events |
| TC_BL_003 | Validate positive usage counts | Usage_count should be greater than or equal to 0 | bz_feature_usage |
| TC_BL_004 | Validate license date logic | End_date should be greater than start_date | bz_licenses |
| TC_BL_005 | Validate meeting duration logic | End_time should be greater than start_time | bz_meetings, bz_webinars |
| TC_BL_006 | Validate participant session logic | Leave_time should be greater than join_time | bz_participants |
| TC_BL_007 | Validate positive registrant counts | Registrants should be greater than or equal to 0 | bz_webinars |

### 3. Edge Case Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) |
|--------------|----------------------|------------------|----------|
| TC_EC_001 | Handle records with null required fields | Records should be filtered out during validation | All models |
| TC_EC_002 | Handle empty string values | Empty strings should be treated appropriately | All models |
| TC_EC_003 | Handle future dates | Future dates should be accepted where business appropriate | All models with date fields |
| TC_EC_004 | Handle zero amounts in billing | Zero amounts should be handled based on business rules | bz_billing_events |
| TC_EC_005 | Handle same start and end times | Same timestamps should be handled appropriately | bz_meetings, bz_webinars, bz_participants |

### 4. Error Handling Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) |
|--------------|----------------------|------------------|----------|
| TC_EH_001 | Handle source table unavailability | Model should fail gracefully with appropriate error | All models |
| TC_EH_002 | Handle data type conversion errors | Invalid data should be filtered out | All models |
| TC_EH_003 | Handle duplicate records | Duplicates should be handled based on business rules | All models |

## dbt Test Scripts

### Schema Tests (schema.yml)

```yaml
version: 2

models:
  # BZ_USERS Tests
  - name: bz_users
    description: "Bronze layer user data with comprehensive testing"
    tests:
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - email
            - load_timestamp
    columns:
      - name: user_name
        description: "User display name"
        tests:
          - not_null
          - dbt_utils.not_empty_string
      - name: email
        description: "User email address"
        tests:
          - not_null
          - dbt_utils.not_empty_string
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
      - name: plan_type
        description: "User subscription plan"
        tests:
          - not_null
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise']
      - name: load_timestamp
        description: "Record load timestamp"
        tests:
          - not_null
      - name: source_system
        description: "Source system identifier"
        tests:
          - not_null

  # BZ_BILLING_EVENTS Tests
  - name: bz_billing_events
    description: "Bronze layer billing events with validation"
    tests:
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - user_id
            - event_type
            - event_date
            - load_timestamp
    columns:
      - name: user_id
        description: "User identifier"
        tests:
          - not_null
          - dbt_utils.not_empty_string
      - name: event_type
        description: "Billing event type"
        tests:
          - not_null
          - accepted_values:
              values: ['subscription', 'payment', 'refund', 'upgrade', 'downgrade', 'cancellation']
      - name: amount
        description: "Billing amount"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10000
      - name: event_date
        description: "Event date"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: '2020-01-01'
              max_value: '2030-12-31'

  # BZ_MEETINGS Tests
  - name: bz_meetings
    description: "Bronze layer meeting data"
    tests:
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - host_id
            - start_time
            - meeting_topic
    columns:
      - name: host_id
        description: "Meeting host identifier"
        tests:
          - not_null
          - dbt_utils.not_empty_string
      - name: meeting_topic
        description: "Meeting topic"
        tests:
          - not_null
          - dbt_utils.not_empty_string
      - name: start_time
        description: "Meeting start time"
        tests:
          - not_null
      - name: end_time
        description: "Meeting end time"
        tests:
          - not_null
      - name: duration_minutes
        description: "Meeting duration"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440  # 24 hours max

  # BZ_PARTICIPANTS Tests
  - name: bz_participants
    description: "Bronze layer participant data"
    tests:
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - meeting_id
            - user_id
            - join_time
    columns:
      - name: meeting_id
        description: "Meeting identifier"
        tests:
          - not_null
          - dbt_utils.not_empty_string
      - name: user_id
        description: "Participant user identifier"
        tests:
          - not_null
          - dbt_utils.not_empty_string
      - name: join_time
        description: "Participant join time"
        tests:
          - not_null
      - name: leave_time
        description: "Participant leave time"
        tests:
          - not_null

  # BZ_FEATURE_USAGE Tests
  - name: bz_feature_usage
    description: "Bronze layer feature usage data"
    columns:
      - name: meeting_id
        description: "Meeting identifier"
        tests:
          - not_null
          - dbt_utils.not_empty_string
      - name: feature_name
        description: "Feature name"
        tests:
          - not_null
          - accepted_values:
              values: ['screen_share', 'recording', 'chat', 'breakout_rooms', 'whiteboard', 'polls', 'reactions']
      - name: usage_count
        description: "Usage count"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1000

  # BZ_LICENSES Tests
  - name: bz_licenses
    description: "Bronze layer license data"
    columns:
      - name: license_type
        description: "License type"
        tests:
          - not_null
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise']
      - name: start_date
        description: "License start date"
        tests:
          - not_null
      - name: end_date
        description: "License end date"
        tests:
          - not_null

  # BZ_SUPPORT_TICKETS Tests
  - name: bz_support_tickets
    description: "Bronze layer support ticket data"
    columns:
      - name: user_id
        description: "User identifier"
        tests:
          - not_null
          - dbt_utils.not_empty_string
      - name: ticket_type
        description: "Ticket type"
        tests:
          - not_null
          - accepted_values:
              values: ['technical', 'billing', 'feature_request', 'bug_report', 'account']
      - name: resolution_status
        description: "Resolution status"
        tests:
          - not_null
          - accepted_values:
              values: ['open', 'in_progress', 'resolved', 'closed', 'escalated']

  # BZ_WEBINARS Tests
  - name: bz_webinars
    description: "Bronze layer webinar data"
    columns:
      - name: host_id
        description: "Webinar host identifier"
        tests:
          - not_null
          - dbt_utils.not_empty_string
      - name: webinar_topic
        description: "Webinar topic"
        tests:
          - not_null
          - dbt_utils.not_empty_string
      - name: registrants
        description: "Number of registrants"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10000
```

### Custom SQL-based Tests

#### Test 1: Meeting Duration Consistency
```sql
-- tests/assert_meeting_duration_consistency.sql
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

#### Test 2: Participant Session Validity
```sql
-- tests/assert_participant_session_validity.sql
SELECT 
    meeting_id,
    user_id,
    join_time,
    leave_time
FROM {{ ref('bz_participants') }}
WHERE leave_time <= join_time
```

#### Test 3: License Date Validity
```sql
-- tests/assert_license_date_validity.sql
SELECT 
    license_type,
    assigned_to_user_id,
    start_date,
    end_date
FROM {{ ref('bz_licenses') }}
WHERE end_date <= start_date
```

#### Test 4: Billing Amount Validation
```sql
-- tests/assert_billing_amount_validation.sql
SELECT 
    user_id,
    event_type,
    amount,
    event_date
FROM {{ ref('bz_billing_events') }}
WHERE amount < 0 OR amount > 10000
```

#### Test 5: Email Format Validation
```sql
-- tests/assert_email_format_validation.sql
SELECT 
    user_name,
    email,
    company
FROM {{ ref('bz_users') }}
WHERE NOT REGEXP_LIKE(email, '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$')
```

#### Test 6: Source Data Completeness
```sql
-- tests/assert_source_data_completeness.sql
WITH source_counts AS (
    SELECT 'billing_events' as table_name, COUNT(*) as source_count
    FROM {{ source('raw_zoom', 'billing_events') }}
    UNION ALL
    SELECT 'users' as table_name, COUNT(*) as source_count
    FROM {{ source('raw_zoom', 'users') }}
    UNION ALL
    SELECT 'meetings' as table_name, COUNT(*) as source_count
    FROM {{ source('raw_zoom', 'meetings') }}
),
bronze_counts AS (
    SELECT 'billing_events' as table_name, COUNT(*) as bronze_count
    FROM {{ ref('bz_billing_events') }}
    UNION ALL
    SELECT 'users' as table_name, COUNT(*) as bronze_count
    FROM {{ ref('bz_users') }}
    UNION ALL
    SELECT 'meetings' as table_name, COUNT(*) as bronze_count
    FROM {{ ref('bz_meetings') }}
)
SELECT 
    s.table_name,
    s.source_count,
    b.bronze_count,
    s.source_count - b.bronze_count as records_filtered
FROM source_counts s
JOIN bronze_counts b ON s.table_name = b.table_name
WHERE s.source_count = 0  -- Alert if source tables are empty
```

#### Test 7: Webinar Registrant Logic
```sql
-- tests/assert_webinar_registrant_logic.sql
SELECT 
    host_id,
    webinar_topic,
    registrants,
    start_time,
    end_time
FROM {{ ref('bz_webinars') }}
WHERE registrants < 0 OR registrants > 10000
```

#### Test 8: Feature Usage Validation
```sql
-- tests/assert_feature_usage_validation.sql
SELECT 
    meeting_id,
    feature_name,
    usage_count,
    usage_date
FROM {{ ref('bz_feature_usage') }}
WHERE usage_count < 0 OR usage_count > 1000
```

### Parameterized Tests

#### Generic Test for Timestamp Validation
```sql
-- macros/test_timestamp_range.sql
{% macro test_timestamp_range(model, column_name, start_date, end_date) %}
    SELECT *
    FROM {{ model }}
    WHERE {{ column_name }} < '{{ start_date }}'
       OR {{ column_name }} > '{{ end_date }}'
{% endmacro %}
```

#### Generic Test for String Length Validation
```sql
-- macros/test_string_length.sql
{% macro test_string_length(model, column_name, min_length=1, max_length=255) %}
    SELECT *
    FROM {{ model }}
    WHERE LENGTH({{ column_name }}) < {{ min_length }}
       OR LENGTH({{ column_name }}) > {{ max_length }}
{% endmacro %}
```

## Test Execution Strategy

### 1. Pre-deployment Testing
- Run all schema tests before model deployment
- Execute custom SQL tests to validate business logic
- Verify data quality thresholds are met

### 2. Post-deployment Validation
- Monitor test results in dbt's run_results.json
- Track test execution times and success rates
- Set up alerts for test failures

### 3. Continuous Monitoring
- Schedule regular test execution
- Monitor data quality metrics over time
- Implement data quality dashboards

## Test Results Tracking

### dbt Test Results
Test results are automatically tracked in:
- `target/run_results.json` - Detailed test execution results
- `target/manifest.json` - Test metadata and dependencies
- Snowflake audit schema - Test execution logs

### Key Metrics to Monitor
- Test success rate by model
- Data quality score trends
- Test execution performance
- Failed test patterns and root causes

## Maintenance and Updates

### Regular Review Schedule
- Weekly: Review failed tests and data quality issues
- Monthly: Update test thresholds based on data patterns
- Quarterly: Add new tests for emerging business requirements

### Test Enhancement Guidelines
- Add tests for new business rules
- Update accepted values based on data evolution
- Enhance edge case coverage
- Optimize test performance for large datasets

---

**Note**: This test suite provides comprehensive coverage for the Zoom Bronze Layer Pipeline. Regular maintenance and updates ensure continued data quality and pipeline reliability in the Snowflake environment.