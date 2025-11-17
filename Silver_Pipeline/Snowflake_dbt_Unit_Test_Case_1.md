_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases and dbt test scripts for Zoom Platform Analytics System Silver layer models
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases
## Zoom Platform Analytics System - Silver Layer

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Silver layer models in the Zoom Platform Analytics System. The tests are designed to validate data transformations, business rules, edge cases, and error handling scenarios to ensure reliable and high-quality data processing in Snowflake.

The Silver layer consists of 8 main models with critical P1 fixes for numeric field cleaning and date format conversion, plus supporting audit and error tracking tables.

## Instructions

These test cases cover:
- **Happy path scenarios**: Valid transformations, joins, aggregations
- **Edge cases**: Null values, empty datasets, invalid lookups, schema mismatches
- **Exception cases**: Failed relationships, unexpected values, format conversion errors
- **Critical P1 fixes**: Numeric field text unit cleaning ("108 mins" error) and DD/MM/YYYY date format conversion ("27/08/2024" error)

All tests use dbt-compatible testing techniques including built-in tests (unique, not_null, relationships, accepted_values) and custom SQL-based tests for complex business logic validation.

## Test Case List

### 1. SI_USERS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_USR_001 | Validate USER_ID uniqueness and not null | All USER_ID values are unique and not null |
| TC_USR_002 | Validate email format using regex pattern | All EMAIL values follow valid email format |
| TC_USR_003 | Validate PLAN_TYPE standardization | All PLAN_TYPE values are in ('Free', 'Basic', 'Pro', 'Enterprise') |
| TC_USR_004 | Validate data quality score range | All DATA_QUALITY_SCORE values are between 0-100 |
| TC_USR_005 | Validate validation status values | All VALIDATION_STATUS values are in ('PASSED', 'FAILED', 'WARNING') |
| TC_USR_006 | Test deduplication logic | No duplicate records based on USER_ID |
| TC_USR_007 | Test email case standardization | All EMAIL values are lowercase |
| TC_USR_008 | Test null handling for optional fields | COMPANY field can be null without affecting data quality |

### 2. SI_MEETINGS Model Test Cases (Enhanced with Critical P1 Fixes)

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_MTG_001 | Validate MEETING_ID uniqueness and not null | All MEETING_ID values are unique and not null |
| TC_MTG_002 | Validate HOST_ID referential integrity | All HOST_ID values exist in SI_USERS.USER_ID |
| TC_MTG_003 | Validate meeting time logic | All END_TIME values are greater than START_TIME |
| TC_MTG_004 | Validate duration calculation consistency | DURATION_MINUTES matches DATEDIFF('minute', START_TIME, END_TIME) |
| TC_MTG_005 | **CRITICAL P1**: Test numeric field text unit cleaning | "108 mins" format successfully converted to numeric 108 |
| TC_MTG_006 | **CRITICAL P1**: Test numeric cleaning error logging | Failed conversions logged to SI_AUDIT_LOG as 'FORMAT_CONVERSION_FAILURE' |
| TC_MTG_007 | Test EST timezone format validation | EST timezone timestamps properly validated and converted |
| TC_MTG_008 | Test duration range validation | All DURATION_MINUTES values are between 0-1440 |
| TC_MTG_009 | Test meeting classification business rule | Meetings < 5 minutes classified as 'Brief' |
| TC_MTG_010 | Test null handling for meeting topics | MEETING_TOPIC can be null without failing validation |

### 3. SI_PARTICIPANTS Model Test Cases (Enhanced with MM/DD/YYYY Format)

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_PRT_001 | Validate PARTICIPANT_ID uniqueness | All PARTICIPANT_ID values are unique and not null |
| TC_PRT_002 | Validate MEETING_ID referential integrity | All MEETING_ID values exist in SI_MEETINGS.MEETING_ID |
| TC_PRT_003 | Validate USER_ID referential integrity | All USER_ID values exist in SI_USERS.USER_ID |
| TC_PRT_004 | Validate participant session time logic | All LEAVE_TIME values are greater than JOIN_TIME |
| TC_PRT_005 | Test MM/DD/YYYY HH:MM format conversion | "12/25/2024 14:30" format successfully converted to timestamp |
| TC_PRT_006 | Test meeting boundary validation | JOIN_TIME >= meeting START_TIME and LEAVE_TIME <= meeting END_TIME |
| TC_PRT_007 | Test unique participant per meeting | Combination of MEETING_ID and USER_ID is unique |
| TC_PRT_008 | Test cross-format timestamp consistency | Mixed timestamp formats handled correctly |

### 4. SI_FEATURE_USAGE Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_FTR_001 | Validate USAGE_ID uniqueness | All USAGE_ID values are unique and not null |
| TC_FTR_002 | Validate MEETING_ID referential integrity | All MEETING_ID values exist in SI_MEETINGS.MEETING_ID |
| TC_FTR_003 | Validate feature name standardization | All FEATURE_NAME values are uppercase and trimmed |
| TC_FTR_004 | Validate usage count non-negative | All USAGE_COUNT values are >= 0 |
| TC_FTR_005 | Test usage date alignment with meetings | USAGE_DATE matches DATE(meeting.START_TIME) |
| TC_FTR_006 | Test feature adoption rate calculation | Feature adoption metrics calculated correctly |

### 5. SI_SUPPORT_TICKETS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_TKT_001 | Validate TICKET_ID uniqueness | All TICKET_ID values are unique and not null |
| TC_TKT_002 | Validate USER_ID referential integrity | All USER_ID values exist in SI_USERS.USER_ID |
| TC_TKT_003 | Validate resolution status values | All RESOLUTION_STATUS values are in predefined list |
| TC_TKT_004 | Validate open date not in future | All OPEN_DATE values are <= CURRENT_DATE() |
| TC_TKT_005 | Test ticket volume per user calculation | Ticket volume metrics per 1000 users calculated correctly |

### 6. SI_BILLING_EVENTS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BIL_001 | Validate EVENT_ID uniqueness | All EVENT_ID values are unique and not null |
| TC_BIL_002 | Validate USER_ID referential integrity | All USER_ID values exist in SI_USERS.USER_ID |
| TC_BIL_003 | Validate amount positive and precision | All AMOUNT values are > 0 with 2 decimal precision |
| TC_BIL_004 | Validate event date not in future | All EVENT_DATE values are <= CURRENT_DATE() |
| TC_BIL_005 | Test MRR calculation business rule | Monthly Recurring Revenue calculated correctly |

### 7. SI_LICENSES Model Test Cases (Enhanced with Critical P1 Fixes)

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_LIC_001 | Validate LICENSE_ID uniqueness | All LICENSE_ID values are unique and not null |
| TC_LIC_002 | Validate ASSIGNED_TO_USER_ID referential integrity | All user assignments exist in SI_USERS.USER_ID |
| TC_LIC_003 | **CRITICAL P1**: Test DD/MM/YYYY date format conversion | "27/08/2024" format successfully converted to DATE |
| TC_LIC_004 | **CRITICAL P1**: Test date conversion error logging | Failed conversions logged to SI_AUDIT_LOG as 'FORMAT_CONVERSION_FAILURE' |
| TC_LIC_005 | Validate license date logic | All START_DATE values are <= END_DATE |
| TC_LIC_006 | Test license utilization rate calculation | License utilization metrics calculated correctly |
| TC_LIC_007 | Test active license validation | Active licenses have END_DATE > CURRENT_DATE() |

### 8. SI_AUDIT_LOG Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_AUD_001 | Validate AUDIT_ID uniqueness | All AUDIT_ID values are unique and not null |
| TC_AUD_002 | Test format conversion failure logging | All 'FORMAT_CONVERSION_FAILURE' errors properly logged |
| TC_AUD_003 | Validate audit timestamp accuracy | All AUDIT_TIMESTAMP values are accurate and not null |
| TC_AUD_004 | Test error type categorization | All ERROR_TYPE values are properly categorized |

### 9. Cross-Table Integration Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_INT_001 | Test user activity consistency | Users with meetings have corresponding participant records |
| TC_INT_002 | Test feature usage alignment | Feature usage records align with meeting participants |
| TC_INT_003 | Test billing-license consistency | Users with billing events have corresponding licenses |
| TC_INT_004 | Test data freshness across tables | All tables have consistent LOAD_TIMESTAMP ranges |

### 10. Edge Case and Error Handling Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_EDG_001 | Test empty dataset handling | Models handle empty Bronze tables gracefully |
| TC_EDG_002 | Test schema evolution compatibility | Models handle new columns in Bronze layer |
| TC_EDG_003 | Test large dataset performance | Models process large datasets within SLA |
| TC_EDG_004 | Test concurrent execution handling | Models handle concurrent dbt runs safely |
| TC_EDG_005 | Test format conversion edge cases | Unusual format variations handled correctly |

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# models/silver/schema.yml
version: 2

models:
  - name: si_users
    description: "Silver layer users table with cleansed and validated data"
    columns:
      - name: user_id
        description: "Unique identifier for each user"
        tests:
          - unique
          - not_null
      - name: email
        description: "User email address"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
      - name: plan_type
        description: "User subscription plan type"
        tests:
          - accepted_values:
              values: ['Free', 'Basic', 'Pro', 'Enterprise']
      - name: data_quality_score
        description: "Data quality score (0-100)"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100
      - name: validation_status
        description: "Validation status"
        tests:
          - accepted_values:
              values: ['PASSED', 'FAILED', 'WARNING']

  - name: si_meetings
    description: "Silver layer meetings table with enhanced format validation"
    columns:
      - name: meeting_id
        description: "Unique identifier for each meeting"
        tests:
          - unique
          - not_null
      - name: host_id
        description: "Meeting host user ID"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: duration_minutes
        description: "Meeting duration in minutes (cleaned from text units)"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440
      - name: start_time
        description: "Meeting start time (EST timezone converted)"
        tests:
          - not_null
      - name: end_time
        description: "Meeting end time (EST timezone converted)"
        tests:
          - not_null

  - name: si_participants
    description: "Silver layer participants table with MM/DD/YYYY format handling"
    columns:
      - name: participant_id
        description: "Unique identifier for each participant"
        tests:
          - unique
          - not_null
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
        description: "Participant join time (MM/DD/YYYY format converted)"
        tests:
          - not_null
      - name: leave_time
        description: "Participant leave time (MM/DD/YYYY format converted)"
        tests:
          - not_null

  - name: si_feature_usage
    description: "Silver layer feature usage table"
    columns:
      - name: usage_id
        description: "Unique identifier for each usage record"
        tests:
          - unique
          - not_null
      - name: meeting_id
        description: "Reference to meeting"
        tests:
          - not_null
          - relationships:
              to: ref('si_meetings')
              field: meeting_id
      - name: usage_count
        description: "Feature usage count"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: number
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0

  - name: si_support_tickets
    description: "Silver layer support tickets table"
    columns:
      - name: ticket_id
        description: "Unique identifier for each ticket"
        tests:
          - unique
          - not_null
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
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed']

  - name: si_billing_events
    description: "Silver layer billing events table"
    columns:
      - name: event_id
        description: "Unique identifier for each billing event"
        tests:
          - unique
          - not_null
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

  - name: si_licenses
    description: "Silver layer licenses table with DD/MM/YYYY format handling"
    columns:
      - name: license_id
        description: "Unique identifier for each license"
        tests:
          - unique
          - not_null
      - name: assigned_to_user_id
        description: "User assigned to license"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: start_date
        description: "License start date (DD/MM/YYYY format converted)"
        tests:
          - not_null
      - name: end_date
        description: "License end date (DD/MM/YYYY format converted)"
        tests:
          - not_null

  - name: si_audit_log
    description: "Silver layer audit log for format conversion tracking"
    columns:
      - name: audit_id
        description: "Unique identifier for each audit record"
        tests:
          - unique
          - not_null
      - name: table_name
        description: "Table where operation occurred"
        tests:
          - not_null
      - name: error_type
        description: "Type of error or operation"
        tests:
          - not_null
      - name: audit_timestamp
        description: "Timestamp of audit record creation"
        tests:
          - not_null
```

### Custom SQL-based dbt Tests

#### 1. Test Meeting Duration Consistency
```sql
-- tests/test_meeting_duration_consistency.sql
{{ config(severity='error') }}

SELECT 
    meeting_id,
    duration_minutes,
    DATEDIFF('minute', start_time, end_time) as calculated_duration,
    ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) as duration_diff
FROM {{ ref('si_meetings') }}
WHERE ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) > 1
```

#### 2. Test Numeric Field Text Unit Cleaning (Critical P1)
```sql
-- tests/test_numeric_field_cleaning.sql
{{ config(severity='error') }}

-- Test that all duration values are properly cleaned from text units
SELECT 
    meeting_id,
    duration_minutes,
    'Numeric field contains text units' as error_message
FROM {{ ref('si_meetings') }}
WHERE duration_minutes::STRING REGEXP '[^0-9.]'
   OR TRY_TO_NUMBER(duration_minutes::STRING) IS NULL
```

#### 3. Test DD/MM/YYYY Date Format Conversion (Critical P1)
```sql
-- tests/test_date_format_conversion.sql
{{ config(severity='error') }}

-- Test that all dates are properly converted from DD/MM/YYYY format
SELECT 
    license_id,
    start_date,
    end_date,
    'Date format conversion failed' as error_message
FROM {{ ref('si_licenses') }}
WHERE start_date IS NULL 
   OR end_date IS NULL
   OR start_date::STRING REGEXP '^\d{1,2}/\d{1,2}/\d{4}$'
   OR end_date::STRING REGEXP '^\d{1,2}/\d{1,2}/\d{4}$'
```

#### 4. Test License Date Logic
```sql
-- tests/test_license_date_logic.sql
{{ config(severity='error') }}

SELECT 
    license_id,
    start_date,
    end_date,
    'Start date must be before or equal to end date' as error_message
FROM {{ ref('si_licenses') }}
WHERE start_date > end_date
```

#### 5. Test Participant Session Boundaries
```sql
-- tests/test_participant_session_boundaries.sql
{{ config(severity='error') }}

SELECT 
    p.participant_id,
    p.meeting_id,
    p.join_time,
    p.leave_time,
    m.start_time as meeting_start,
    m.end_time as meeting_end,
    'Participant session outside meeting boundaries' as error_message
FROM {{ ref('si_participants') }} p
JOIN {{ ref('si_meetings') }} m ON p.meeting_id = m.meeting_id
WHERE p.join_time < m.start_time 
   OR p.leave_time > m.end_time
   OR p.leave_time <= p.join_time
```

#### 6. Test Format Conversion Error Logging
```sql
-- tests/test_format_conversion_logging.sql
{{ config(severity='warn') }}

-- Verify that format conversion failures are properly logged
SELECT 
    table_name,
    column_name,
    error_type,
    COUNT(*) as error_count
FROM {{ ref('si_audit_log') }}
WHERE error_type = 'FORMAT_CONVERSION_FAILURE'
  AND audit_timestamp >= CURRENT_DATE() - INTERVAL '7 days'
GROUP BY table_name, column_name, error_type
HAVING COUNT(*) > 100  -- Alert if more than 100 conversion failures per week
```

#### 7. Test Cross-Table Referential Integrity
```sql
-- tests/test_cross_table_integrity.sql
{{ config(severity='error') }}

-- Test that all meeting hosts exist as participants in their own meetings
SELECT 
    m.meeting_id,
    m.host_id,
    'Meeting host should be a participant in their own meeting' as error_message
FROM {{ ref('si_meetings') }} m
LEFT JOIN {{ ref('si_participants') }} p 
    ON m.meeting_id = p.meeting_id 
    AND m.host_id = p.user_id
WHERE p.user_id IS NULL
```

#### 8. Test Data Quality Score Calculation
```sql
-- tests/test_data_quality_score.sql
{{ config(severity='warn') }}

-- Test that data quality scores are reasonable based on validation status
SELECT 
    'si_users' as table_name,
    validation_status,
    AVG(data_quality_score) as avg_score,
    COUNT(*) as record_count
FROM {{ ref('si_users') }}
GROUP BY validation_status
HAVING (validation_status = 'PASSED' AND AVG(data_quality_score) < 90)
    OR (validation_status = 'FAILED' AND AVG(data_quality_score) >= 70)
    OR (validation_status = 'WARNING' AND (AVG(data_quality_score) < 70 OR AVG(data_quality_score) >= 90))
```

#### 9. Test Feature Usage Date Alignment
```sql
-- tests/test_feature_usage_date_alignment.sql
{{ config(severity='error') }}

SELECT 
    f.usage_id,
    f.meeting_id,
    f.usage_date,
    DATE(m.start_time) as meeting_date,
    'Feature usage date must match meeting date' as error_message
FROM {{ ref('si_feature_usage') }} f
JOIN {{ ref('si_meetings') }} m ON f.meeting_id = m.meeting_id
WHERE f.usage_date != DATE(m.start_time)
```

#### 10. Test EST Timezone Conversion
```sql
-- tests/test_est_timezone_conversion.sql
{{ config(severity='warn') }}

-- Test that EST timezone timestamps are properly converted
SELECT 
    meeting_id,
    start_time,
    end_time,
    'EST timezone format detected in converted timestamps' as warning_message
FROM {{ ref('si_meetings') }}
WHERE start_time::STRING LIKE '%EST%'
   OR end_time::STRING LIKE '%EST%'
```

### Parameterized Tests for Reusability

#### Generic Test for Format Conversion Validation
```sql
-- macros/test_format_conversion.sql
{% macro test_format_conversion(model, column_name, format_pattern, conversion_function) %}

SELECT 
    {{ model }}.{{ column_name }},
    'Format conversion failed for {{ column_name }}' as error_message
FROM {{ model }}
WHERE {{ column_name }}::STRING REGEXP '{{ format_pattern }}'
   OR {{ conversion_function }}({{ column_name }}::STRING) IS NULL

{% endmacro %}
```

#### Generic Test for Referential Integrity
```sql
-- macros/test_referential_integrity.sql
{% macro test_referential_integrity(model, column_name, ref_model, ref_column) %}

SELECT 
    {{ model }}.{{ column_name }},
    'Referential integrity violation: {{ column_name }} not found in {{ ref_model }}.{{ ref_column }}' as error_message
FROM {{ model }}
LEFT JOIN {{ ref_model }} ON {{ model }}.{{ column_name }} = {{ ref_model }}.{{ ref_column }}
WHERE {{ ref_model }}.{{ ref_column }} IS NULL
  AND {{ model }}.{{ column_name }} IS NOT NULL

{% endmacro %}
```

## Test Execution Strategy

### 1. Pre-deployment Testing
- Run all schema tests before deploying models to production
- Execute custom SQL tests to validate business logic
- Verify format conversion tests pass with 100% success rate
- Validate audit logging functionality

### 2. Continuous Integration Testing
- Integrate tests into CI/CD pipeline
- Set up automated test execution on every commit
- Configure alerts for test failures
- Monitor test performance and execution time

### 3. Production Monitoring
- Schedule daily execution of critical tests
- Monitor format conversion success rates
- Track data quality score trends
- Alert on referential integrity violations

### 4. Performance Testing
- Test model execution time with large datasets
- Validate memory usage during format conversions
- Monitor Snowflake credit consumption
- Test concurrent execution scenarios

## Expected Test Results

### Success Criteria
- **Format Conversion Tests**: 100% success rate for numeric cleaning and date conversion
- **Referential Integrity Tests**: 0 violations across all foreign key relationships
- **Data Quality Tests**: Average data quality score > 85 across all models
- **Business Logic Tests**: All business rules validated with 0 failures
- **Audit Logging Tests**: 100% of format conversion failures properly logged

### Performance Benchmarks
- **Test Execution Time**: < 5 minutes for full test suite
- **Model Build Time**: < 30 minutes for all Silver layer models
- **Memory Usage**: < 2GB per model during execution
- **Credit Consumption**: < 10 credits per full test run

## Maintenance and Updates

### 1. Test Case Maintenance
- Review and update test cases monthly
- Add new tests for schema changes
- Update format conversion tests for new data patterns
- Maintain test documentation

### 2. Performance Optimization
- Optimize slow-running tests
- Implement incremental testing where possible
- Cache test results for unchanged models
- Monitor and tune Snowflake warehouse sizing

### 3. Error Handling Enhancement
- Improve error messages for better debugging
- Add more granular format conversion tests
- Enhance audit logging with additional metadata
- Implement automated remediation for common issues

---

**Note**: These comprehensive unit test cases ensure the reliability and performance of dbt models in Snowflake by validating key data transformations, business rules, edge cases, and error handling scenarios. The tests are specifically designed to validate the critical P1 fixes for numeric field text unit cleaning ("108 mins" error) and DD/MM/YYYY date format conversion ("27/08/2024" error) while maintaining comprehensive coverage of all Silver layer functionality. All test results are tracked in dbt's run_results.json and Snowflake audit schema for complete observability and compliance.