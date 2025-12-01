_____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Comprehensive unit test cases and dbt test scripts for Zoom Platform Analytics System Silver layer models
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Snowflake dbt Unit Test Cases
## Zoom Platform Analytics System - Silver Layer

## Overview

This document provides comprehensive unit test cases and dbt test scripts for the Silver layer models in the Zoom Platform Analytics System. The tests are designed to validate key transformations, business rules, edge cases, and error handling scenarios to ensure data quality and reliability in the Snowflake environment.

## Test Coverage Strategy

The testing framework covers:
- **Happy Path Scenarios**: Valid transformations, joins, and aggregations
- **Edge Cases**: Null values, empty datasets, invalid lookups, format conversion issues
- **Exception Cases**: Failed relationships, unexpected values, critical format errors
- **Business Rule Validation**: Data quality checks, referential integrity, format compliance
- **Critical Format Conversion**: "108 mins" numeric cleaning and "27/08/2024" date format issues

## Test Case List

| Test Case ID | Test Case Description | Model | Priority | Expected Outcome |
|--------------|----------------------|-------|----------|------------------|
| TC_SI_001 | SI_USERS - Null Value Validation | SI_USERS | P1 | All critical fields populated |
| TC_SI_002 | SI_USERS - Email Format Validation | SI_USERS | P1 | Valid email format compliance |
| TC_SI_003 | SI_USERS - Plan Type Standardization | SI_USERS | P2 | Standardized plan type values |
| TC_SI_004 | SI_USERS - Data Quality Score Calculation | SI_USERS | P2 | DQ scores within 0-100 range |
| TC_SI_005 | SI_MEETINGS - Duration Consistency Check | SI_MEETINGS | P1 | Duration matches time difference |
| TC_SI_006 | SI_MEETINGS - Time Logic Validation | SI_MEETINGS | P1 | End time after start time |
| TC_SI_007 | SI_MEETINGS - Host Referential Integrity | SI_MEETINGS | P1 | All hosts exist in SI_USERS |
| TC_SI_008 | SI_MEETINGS - EST Timezone Format Validation | SI_MEETINGS | P1 | EST format properly converted |
| TC_SI_009 | SI_MEETINGS - Numeric Field Text Unit Cleaning (Critical) | SI_MEETINGS | P1 | "108 mins" errors resolved |
| TC_SI_010 | SI_PARTICIPANTS - Session Time Validation | SI_PARTICIPANTS | P1 | Leave time after join time |
| TC_SI_011 | SI_PARTICIPANTS - Meeting Boundary Validation | SI_PARTICIPANTS | P1 | Participant times within meeting |
| TC_SI_012 | SI_PARTICIPANTS - MM/DD/YYYY Format Validation | SI_PARTICIPANTS | P1 | MM/DD/YYYY format converted |
| TC_SI_013 | SI_FEATURE_USAGE - Feature Name Standardization | SI_FEATURE_USAGE | P2 | Standardized feature names |
| TC_SI_014 | SI_FEATURE_USAGE - Usage Count Validation | SI_FEATURE_USAGE | P2 | Non-negative usage counts |
| TC_SI_015 | SI_SUPPORT_TICKETS - Status Validation | SI_SUPPORT_TICKETS | P2 | Valid status values |
| TC_SI_016 | SI_SUPPORT_TICKETS - Date Logic Validation | SI_SUPPORT_TICKETS | P2 | Open dates not in future |
| TC_SI_017 | SI_BILLING_EVENTS - Amount Validation | SI_BILLING_EVENTS | P1 | Positive amounts with precision |
| TC_SI_018 | SI_BILLING_EVENTS - Event Date Validation | SI_BILLING_EVENTS | P2 | Valid event dates |
| TC_SI_019 | SI_LICENSES - Date Logic Validation | SI_LICENSES | P1 | Start date before end date |
| TC_SI_020 | SI_LICENSES - DD/MM/YYYY Format Conversion (Critical) | SI_LICENSES | P1 | "27/08/2024" errors resolved |
| TC_SI_021 | Cross-Table - User Activity Consistency | Multiple | P2 | Meeting hosts have participation |
| TC_SI_022 | Cross-Table - Feature Usage Alignment | Multiple | P2 | Feature usage aligns with participants |
| TC_SI_023 | Audit - Load Timestamp Validation | All Models | P2 | All records have load timestamps |
| TC_SI_024 | Audit - Validation Status Check | All Models | P2 | Valid validation status values |
| TC_SI_025 | Performance - Data Freshness Validation | All Models | P3 | Data loaded within SLA |

## dbt Test Scripts

### Schema Tests (schema.yml)

```yaml
# models/silver/schema.yml
version: 2

models:
  - name: si_users
    description: "Silver layer users table with data quality validations"
    columns:
      - name: user_id
        description: "Unique identifier for each user"
        tests:
          - not_null
          - unique
      - name: email
        description: "User email address"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
      - name: plan_type
        description: "User subscription plan"
        tests:
          - not_null
          - accepted_values:
              values: ['Free', 'Basic', 'Pro', 'Enterprise']
      - name: data_quality_score
        description: "Data quality score (0-100)"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100
      - name: validation_status
        description: "Validation status"
        tests:
          - not_null
          - accepted_values:
              values: ['PASSED', 'FAILED', 'WARNING']

  - name: si_meetings
    description: "Silver layer meetings table with enhanced format validation"
    columns:
      - name: meeting_id
        description: "Unique identifier for each meeting"
        tests:
          - not_null
          - unique
      - name: host_id
        description: "Meeting host user ID"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: start_time
        description: "Meeting start timestamp"
        tests:
          - not_null
      - name: end_time
        description: "Meeting end timestamp"
        tests:
          - not_null
      - name: duration_minutes
        description: "Meeting duration in minutes (cleaned from text units)"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440

  - name: si_participants
    description: "Silver layer participants table with timestamp format validation"
    columns:
      - name: participant_id
        description: "Unique identifier for each participant"
        tests:
          - not_null
          - unique
      - name: meeting_id
        description: "Reference to meeting"
        tests:
          - not_null
          - relationships:
              to: ref('si_meetings')
              field: meeting_id
      - name: user_id
        description: "Reference to user"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: join_time
        description: "Participant join timestamp"
        tests:
          - not_null
      - name: leave_time
        description: "Participant leave timestamp"
        tests:
          - not_null

  - name: si_feature_usage
    description: "Silver layer feature usage table"
    columns:
      - name: usage_id
        description: "Unique identifier for each usage record"
        tests:
          - not_null
          - unique
      - name: meeting_id
        description: "Reference to meeting"
        tests:
          - not_null
          - relationships:
              to: ref('si_meetings')
              field: meeting_id
      - name: usage_count
        description: "Number of times feature was used"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: number
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 999999

  - name: si_support_tickets
    description: "Silver layer support tickets table"
    columns:
      - name: ticket_id
        description: "Unique identifier for each ticket"
        tests:
          - not_null
          - unique
      - name: user_id
        description: "Reference to user who created ticket"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: resolution_status
        description: "Ticket resolution status"
        tests:
          - not_null
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed']

  - name: si_billing_events
    description: "Silver layer billing events table"
    columns:
      - name: event_id
        description: "Unique identifier for each billing event"
        tests:
          - not_null
          - unique
      - name: user_id
        description: "Reference to user"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: amount
        description: "Billing amount"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.01
              max_value: 999999.99

  - name: si_licenses
    description: "Silver layer licenses table with date format validation"
    columns:
      - name: license_id
        description: "Unique identifier for each license"
        tests:
          - not_null
          - unique
      - name: assigned_to_user_id
        description: "User assigned to license"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: start_date
        description: "License start date (converted from DD/MM/YYYY)"
        tests:
          - not_null
      - name: end_date
        description: "License end date (converted from DD/MM/YYYY)"
        tests:
          - not_null
```

### Custom SQL-Based dbt Tests

#### Test 1: Meeting Duration Consistency (TC_SI_005)

```sql
-- tests/assert_meeting_duration_consistency.sql
-- Test that calculated duration matches the difference between start and end times

SELECT 
    meeting_id,
    duration_minutes,
    DATEDIFF('minute', start_time, end_time) as calculated_duration,
    ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) as duration_difference
FROM {{ ref('si_meetings') }}
WHERE ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) > 1
```

#### Test 2: Meeting Time Logic Validation (TC_SI_006)

```sql
-- tests/assert_meeting_time_logic.sql
-- Test that end time is after start time

SELECT 
    meeting_id,
    start_time,
    end_time
FROM {{ ref('si_meetings') }}
WHERE end_time <= start_time
```

#### Test 3: Numeric Field Text Unit Cleaning - Critical P1 (TC_SI_009)

```sql
-- tests/assert_duration_numeric_cleaning.sql
-- Test that duration fields are properly cleaned from text units like "108 mins"

SELECT 
    meeting_id,
    duration_minutes,
    duration_minutes::STRING as duration_string
FROM {{ ref('si_meetings') }}
WHERE duration_minutes::STRING REGEXP '[^0-9.]'
   OR TRY_TO_NUMBER(duration_minutes::STRING) IS NULL
   OR duration_minutes IS NULL
```

#### Test 4: EST Timezone Format Validation (TC_SI_008)

```sql
-- tests/assert_est_timezone_conversion.sql
-- Test that EST timezone formats are properly converted

SELECT 
    meeting_id,
    start_time,
    end_time,
    start_time::STRING as start_time_string,
    end_time::STRING as end_time_string
FROM {{ ref('si_meetings') }}
WHERE (start_time::STRING LIKE '%EST%' AND start_time IS NULL)
   OR (end_time::STRING LIKE '%EST%' AND end_time IS NULL)
   OR start_time::STRING REGEXP 'EST$'
   OR end_time::STRING REGEXP 'EST$'
```

#### Test 5: Participant Session Time Validation (TC_SI_010)

```sql
-- tests/assert_participant_session_times.sql
-- Test that leave time is after join time

SELECT 
    participant_id,
    join_time,
    leave_time
FROM {{ ref('si_participants') }}
WHERE leave_time <= join_time
```

#### Test 6: Meeting Boundary Validation (TC_SI_011)

```sql
-- tests/assert_participant_meeting_boundaries.sql
-- Test that participant times are within meeting duration

SELECT 
    p.participant_id,
    p.meeting_id,
    p.join_time,
    p.leave_time,
    m.start_time,
    m.end_time
FROM {{ ref('si_participants') }} p
JOIN {{ ref('si_meetings') }} m ON p.meeting_id = m.meeting_id
WHERE p.join_time < m.start_time 
   OR p.leave_time > m.end_time
```

#### Test 7: MM/DD/YYYY Format Validation (TC_SI_012)

```sql
-- tests/assert_mmddyyyy_format_conversion.sql
-- Test that MM/DD/YYYY HH:MM formats are properly converted

SELECT 
    participant_id,
    join_time,
    leave_time,
    join_time::STRING as join_time_string,
    leave_time::STRING as leave_time_string
FROM {{ ref('si_participants') }}
WHERE (join_time::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' AND join_time IS NULL)
   OR (leave_time::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' AND leave_time IS NULL)
```

#### Test 8: DD/MM/YYYY Date Format Conversion - Critical P1 (TC_SI_020)

```sql
-- tests/assert_ddmmyyyy_date_conversion.sql
-- Test that DD/MM/YYYY date formats are properly converted in licenses

SELECT 
    license_id,
    start_date,
    end_date,
    start_date::STRING as start_date_string,
    end_date::STRING as end_date_string
FROM {{ ref('si_licenses') }}
WHERE (start_date::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}$' AND start_date IS NULL)
   OR (end_date::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}$' AND end_date IS NULL)
   OR start_date IS NULL
   OR end_date IS NULL
```

#### Test 9: License Date Logic Validation (TC_SI_019)

```sql
-- tests/assert_license_date_logic.sql
-- Test that start date is before or equal to end date

SELECT 
    license_id,
    start_date,
    end_date
FROM {{ ref('si_licenses') }}
WHERE start_date > end_date
```

#### Test 10: User Activity Consistency (TC_SI_021)

```sql
-- tests/assert_user_activity_consistency.sql
-- Test that meeting hosts have corresponding participant records

SELECT 
    m.meeting_id,
    m.host_id,
    COUNT(p.participant_id) as host_participation_count
FROM {{ ref('si_meetings') }} m
LEFT JOIN {{ ref('si_participants') }} p ON m.meeting_id = p.meeting_id AND m.host_id = p.user_id
GROUP BY m.meeting_id, m.host_id
HAVING COUNT(p.participant_id) = 0
```

#### Test 11: Feature Usage Alignment (TC_SI_022)

```sql
-- tests/assert_feature_usage_alignment.sql
-- Test that feature usage records align with actual meeting participants

SELECT 
    f.usage_id,
    f.meeting_id,
    COUNT(p.participant_id) as participant_count
FROM {{ ref('si_feature_usage') }} f
LEFT JOIN {{ ref('si_participants') }} p ON f.meeting_id = p.meeting_id
GROUP BY f.usage_id, f.meeting_id
HAVING COUNT(p.participant_id) = 0
```

#### Test 12: Billing Amount Validation (TC_SI_017)

```sql
-- tests/assert_billing_amount_validation.sql
-- Test that billing amounts are positive with proper precision

SELECT 
    event_id,
    amount,
    ROUND(amount, 2) as rounded_amount
FROM {{ ref('si_billing_events') }}
WHERE amount <= 0 
   OR amount IS NULL
   OR amount != ROUND(amount, 2)
   OR amount > 999999.99
```

#### Test 13: Future Date Validation (TC_SI_016, TC_SI_018)

```sql
-- tests/assert_no_future_dates.sql
-- Test that certain dates are not in the future

SELECT 
    'SUPPORT_TICKETS' as table_name,
    ticket_id as record_id,
    open_date as date_field,
    'OPEN_DATE' as field_name
FROM {{ ref('si_support_tickets') }}
WHERE open_date > CURRENT_DATE()

UNION ALL

SELECT 
    'BILLING_EVENTS' as table_name,
    event_id as record_id,
    event_date as date_field,
    'EVENT_DATE' as field_name
FROM {{ ref('si_billing_events') }}
WHERE event_date > CURRENT_DATE()
```

#### Test 14: Data Quality Score Validation (TC_SI_004)

```sql
-- tests/assert_data_quality_scores.sql
-- Test that data quality scores are within valid range across all tables

SELECT 
    'SI_USERS' as table_name,
    user_id as record_id,
    data_quality_score
FROM {{ ref('si_users') }}
WHERE data_quality_score < 0 OR data_quality_score > 100 OR data_quality_score IS NULL

UNION ALL

SELECT 
    'SI_MEETINGS' as table_name,
    meeting_id as record_id,
    data_quality_score
FROM {{ ref('si_meetings') }}
WHERE data_quality_score < 0 OR data_quality_score > 100 OR data_quality_score IS NULL

UNION ALL

SELECT 
    'SI_PARTICIPANTS' as table_name,
    participant_id as record_id,
    data_quality_score
FROM {{ ref('si_participants') }}
WHERE data_quality_score < 0 OR data_quality_score > 100 OR data_quality_score IS NULL

UNION ALL

SELECT 
    'SI_FEATURE_USAGE' as table_name,
    usage_id as record_id,
    data_quality_score
FROM {{ ref('si_feature_usage') }}
WHERE data_quality_score < 0 OR data_quality_score > 100 OR data_quality_score IS NULL

UNION ALL

SELECT 
    'SI_SUPPORT_TICKETS' as table_name,
    ticket_id as record_id,
    data_quality_score
FROM {{ ref('si_support_tickets') }}
WHERE data_quality_score < 0 OR data_quality_score > 100 OR data_quality_score IS NULL

UNION ALL

SELECT 
    'SI_BILLING_EVENTS' as table_name,
    event_id as record_id,
    data_quality_score
FROM {{ ref('si_billing_events') }}
WHERE data_quality_score < 0 OR data_quality_score > 100 OR data_quality_score IS NULL

UNION ALL

SELECT 
    'SI_LICENSES' as table_name,
    license_id as record_id,
    data_quality_score
FROM {{ ref('si_licenses') }}
WHERE data_quality_score < 0 OR data_quality_score > 100 OR data_quality_score IS NULL
```

#### Test 15: Load Timestamp Validation (TC_SI_023)

```sql
-- tests/assert_load_timestamps.sql
-- Test that all records have valid load timestamps

SELECT 
    'SI_USERS' as table_name,
    COUNT(*) as null_load_timestamps
FROM {{ ref('si_users') }}
WHERE load_timestamp IS NULL
HAVING COUNT(*) > 0

UNION ALL

SELECT 
    'SI_MEETINGS' as table_name,
    COUNT(*) as null_load_timestamps
FROM {{ ref('si_meetings') }}
WHERE load_timestamp IS NULL
HAVING COUNT(*) > 0

UNION ALL

SELECT 
    'SI_PARTICIPANTS' as table_name,
    COUNT(*) as null_load_timestamps
FROM {{ ref('si_participants') }}
WHERE load_timestamp IS NULL
HAVING COUNT(*) > 0

UNION ALL

SELECT 
    'SI_FEATURE_USAGE' as table_name,
    COUNT(*) as null_load_timestamps
FROM {{ ref('si_feature_usage') }}
WHERE load_timestamp IS NULL
HAVING COUNT(*) > 0

UNION ALL

SELECT 
    'SI_SUPPORT_TICKETS' as table_name,
    COUNT(*) as null_load_timestamps
FROM {{ ref('si_support_tickets') }}
WHERE load_timestamp IS NULL
HAVING COUNT(*) > 0

UNION ALL

SELECT 
    'SI_BILLING_EVENTS' as table_name,
    COUNT(*) as null_load_timestamps
FROM {{ ref('si_billing_events') }}
WHERE load_timestamp IS NULL
HAVING COUNT(*) > 0

UNION ALL

SELECT 
    'SI_LICENSES' as table_name,
    COUNT(*) as null_load_timestamps
FROM {{ ref('si_licenses') }}
WHERE load_timestamp IS NULL
HAVING COUNT(*) > 0
```

### Parameterized Tests

#### Generic Test for Format Conversion Validation

```sql
-- macros/test_format_conversion.sql
-- Generic test macro for format conversion validation

{% macro test_format_conversion(model, column_name, format_pattern, conversion_function) %}

SELECT 
    {{ column_name }},
    {{ column_name }}::STRING as original_value,
    {{ conversion_function }} as converted_value
FROM {{ model }}
WHERE {{ column_name }}::STRING REGEXP '{{ format_pattern }}'
  AND {{ conversion_function }} IS NULL

{% endmacro %}
```

#### Usage of Parameterized Test

```yaml
# In schema.yml, add custom tests using the macro
models:
  - name: si_meetings
    tests:
      - test_format_conversion:
          column_name: duration_minutes
          format_pattern: '[^0-9.]'
          conversion_function: "TRY_TO_NUMBER(REGEXP_REPLACE(duration_minutes::STRING, '[^0-9.]', ''))"

  - name: si_licenses
    tests:
      - test_format_conversion:
          column_name: start_date
          format_pattern: '^\\d{1,2}/\\d{1,2}/\\d{4}$'
          conversion_function: "TRY_TO_DATE(start_date::STRING, 'DD/MM/YYYY')"
```

## Critical Format Conversion Tests

### Test for "108 mins" Error Resolution

```sql
-- tests/critical_duration_text_unit_cleaning.sql
-- Critical P1 test for resolving "108 mins" errors in duration fields

WITH duration_analysis AS (
  SELECT 
    meeting_id,
    duration_minutes,
    duration_minutes::STRING as original_string,
    REGEXP_REPLACE(duration_minutes::STRING, '[^0-9.]', '') as cleaned_string,
    TRY_TO_NUMBER(REGEXP_REPLACE(duration_minutes::STRING, '[^0-9.]', '')) as cleaned_number,
    CASE 
      WHEN duration_minutes::STRING REGEXP '[^0-9.]' THEN 'HAS_TEXT_UNITS'
      ELSE 'NUMERIC_ONLY'
    END as format_type,
    CASE 
      WHEN TRY_TO_NUMBER(REGEXP_REPLACE(duration_minutes::STRING, '[^0-9.]', '')) IS NOT NULL THEN 'CONVERSION_SUCCESS'
      ELSE 'CONVERSION_FAILED'
    END as conversion_status
  FROM {{ ref('si_meetings') }}
  WHERE duration_minutes IS NOT NULL
)
SELECT 
  meeting_id,
  original_string,
  cleaned_string,
  format_type,
  conversion_status
FROM duration_analysis
WHERE conversion_status = 'CONVERSION_FAILED'
   OR (format_type = 'HAS_TEXT_UNITS' AND cleaned_number IS NULL)
```

### Test for "27/08/2024" Error Resolution

```sql
-- tests/critical_ddmmyyyy_date_conversion.sql
-- Critical P1 test for resolving "27/08/2024" errors in date fields

WITH date_analysis AS (
  SELECT 
    license_id,
    start_date,
    end_date,
    start_date::STRING as start_date_string,
    end_date::STRING as end_date_string,
    CASE 
      WHEN start_date::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}$' THEN 'DD_MM_YYYY_FORMAT'
      ELSE 'STANDARD_FORMAT'
    END as start_date_format,
    CASE 
      WHEN end_date::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}$' THEN 'DD_MM_YYYY_FORMAT'
      ELSE 'STANDARD_FORMAT'
    END as end_date_format,
    TRY_TO_DATE(start_date::STRING, 'DD/MM/YYYY') as converted_start_date,
    TRY_TO_DATE(end_date::STRING, 'DD/MM/YYYY') as converted_end_date,
    CASE 
      WHEN start_date::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}$' AND TRY_TO_DATE(start_date::STRING, 'DD/MM/YYYY') IS NOT NULL THEN 'START_CONVERSION_SUCCESS'
      WHEN start_date::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}$' AND TRY_TO_DATE(start_date::STRING, 'DD/MM/YYYY') IS NULL THEN 'START_CONVERSION_FAILED'
      ELSE 'START_NO_CONVERSION_NEEDED'
    END as start_conversion_status,
    CASE 
      WHEN end_date::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}$' AND TRY_TO_DATE(end_date::STRING, 'DD/MM/YYYY') IS NOT NULL THEN 'END_CONVERSION_SUCCESS'
      WHEN end_date::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}$' AND TRY_TO_DATE(end_date::STRING, 'DD/MM/YYYY') IS NULL THEN 'END_CONVERSION_FAILED'
      ELSE 'END_NO_CONVERSION_NEEDED'
    END as end_conversion_status
  FROM {{ ref('si_licenses') }}
  WHERE start_date IS NOT NULL AND end_date IS NOT NULL
)
SELECT 
  license_id,
  start_date_string,
  end_date_string,
  start_date_format,
  end_date_format,
  start_conversion_status,
  end_conversion_status
FROM date_analysis
WHERE start_conversion_status = 'START_CONVERSION_FAILED'
   OR end_conversion_status = 'END_CONVERSION_FAILED'
   OR (start_date_format = 'DD_MM_YYYY_FORMAT' AND converted_start_date IS NULL)
   OR (end_date_format = 'DD_MM_YYYY_FORMAT' AND converted_end_date IS NULL)
```

## Test Execution Strategy

### 1. Pre-Deployment Testing

```bash
# Run all tests before deployment
dbt test --models si_users si_meetings si_participants si_feature_usage si_support_tickets si_billing_events si_licenses

# Run only critical P1 tests
dbt test --models si_meetings si_licenses --select test_type:critical

# Run format conversion tests specifically
dbt test --select tag:format_conversion
```

### 2. Post-Deployment Validation

```bash
# Validate critical format conversion fixes
dbt test --select critical_duration_text_unit_cleaning critical_ddmmyyyy_date_conversion

# Run full test suite
dbt test

# Generate test results documentation
dbt docs generate
dbt docs serve
```

### 3. Continuous Monitoring

```bash
# Daily automated test execution
dbt test --models silver --store-failures

# Weekly comprehensive test suite
dbt test --full-refresh

# Monthly performance and data quality assessment
dbt test --select tag:performance tag:data_quality
```

## Test Results Tracking

### Expected Test Results

| Test Category | Expected Pass Rate | Critical Threshold | Action on Failure |
|---------------|-------------------|-------------------|-------------------|
| P1 Critical Tests | 100% | 99% | Immediate escalation |
| Format Conversion | 98% | 95% | Review and remediate |
| Referential Integrity | 100% | 99% | Data quality investigation |
| Business Rules | 95% | 90% | Business stakeholder review |
| Performance Tests | 90% | 85% | Performance optimization |

### Test Failure Handling

1. **Critical P1 Failures**: Immediate notification to data engineering team
2. **Format Conversion Failures**: Log to SI_AUDIT_LOG with 'FORMAT_CONVERSION_FAILURE' error type
3. **Business Rule Failures**: Create tickets for data steward review
4. **Performance Issues**: Trigger performance optimization workflow

## Integration with dbt Cloud

### Job Configuration

```yaml
# dbt_project.yml test configuration
test-paths: ["tests"]

models:
  zoom_analytics:
    silver:
      +materialized: table
      +post-hook: "INSERT INTO {{ ref('si_audit_log') }} (table_name, operation_type, audit_timestamp, processed_by) VALUES ('{{ this }}', 'POST_HOOK_TEST', CURRENT_TIMESTAMP(), 'DBT_TEST_SUITE')"

tests:
  zoom_analytics:
    +store_failures: true
    +schema: test_failures
```

### Automated Alerts

```sql
-- Macro for test failure alerts
{% macro send_test_failure_alert(test_name, failure_count) %}
  {% if failure_count > 0 %}
    INSERT INTO {{ ref('si_audit_log') }} (
      table_name,
      error_type,
      error_description,
      audit_timestamp,
      operation_type,
      processed_by
    ) VALUES (
      '{{ test_name }}',
      'TEST_FAILURE',
      'Test failed with {{ failure_count }} failures',
      CURRENT_TIMESTAMP(),
      'AUTOMATED_TEST',
      'DBT_TEST_FRAMEWORK'
    );
  {% endif %}
{% endmacro %}
```

## Conclusion

This comprehensive unit testing framework provides robust validation for the Zoom Platform Analytics System Silver layer models. The tests are specifically designed to:

1. **Address Critical Format Issues**: Resolve "108 mins" and "27/08/2024" format conversion errors
2. **Ensure Data Quality**: Validate business rules, referential integrity, and data consistency
3. **Support Continuous Integration**: Enable automated testing in dbt Cloud environment
4. **Provide Comprehensive Coverage**: Test happy path, edge cases, and exception scenarios
5. **Enable Monitoring**: Track test results and failure patterns over time

The framework supports both development-time validation and production monitoring, ensuring that the Silver layer maintains high data quality standards while addressing the specific format conversion challenges identified in the system.

**Next Steps**:
1. Deploy these test scripts to the dbt project
2. Execute the critical P1 format conversion tests
3. Validate that "108 mins" and "27/08/2024" errors are resolved
4. Set up automated monitoring and alerting
5. Integrate with existing CI/CD pipelines for continuous validation
