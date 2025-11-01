_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Platform Analytics Silver Layer dbt models in Snowflake
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Zoom Platform Analytics Silver Layer

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics Silver Layer dbt models running in Snowflake. The test cases cover data transformations, business rules, edge cases, and error handling scenarios to ensure data quality and pipeline reliability.

## Test Coverage Overview

The test suite covers the following Silver Layer models:
- `audit_log` - Pipeline execution tracking
- `si_users` - User account management
- `si_meetings` - Meeting session data
- `si_participants` - Meeting participation tracking
- `si_feature_usage` - Feature utilization analytics
- `si_support_tickets` - Customer support tracking
- `si_billing_events` - Financial transaction data
- `si_licenses` - License management
- `si_webinars` - Webinar session analytics

## Test Case List

### 1. Data Quality and Validation Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) Tested |
|--------------|----------------------|------------------|------------------|
| TC_DQ_001 | Validate primary key uniqueness across all models | All primary keys should be unique and not null | All models |
| TC_DQ_002 | Validate foreign key relationships | All foreign keys should reference valid primary keys | si_meetings, si_participants, si_feature_usage |
| TC_DQ_003 | Validate data quality scores are within range [0.0, 1.0] | All data_quality_score values should be between 0.0 and 1.0 | All models |
| TC_DQ_004 | Validate email format in users table | All email addresses should follow valid email format | si_users |
| TC_DQ_005 | Validate date consistency (load_date <= update_date) | Load dates should not be after update dates | All models |

### 2. Business Logic Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) Tested |
|--------------|----------------------|------------------|------------------|
| TC_BL_001 | Validate meeting duration calculations | Duration should match difference between start_time and end_time | si_meetings |
| TC_BL_002 | Validate attendance duration does not exceed meeting duration | Participant attendance should not exceed meeting duration | si_participants |
| TC_BL_003 | Validate account status logic based on last login | Account status should reflect activity within defined periods | si_users |
| TC_BL_004 | Validate webinar attendance rate calculations | Attendance rate should be (attendees/registrants) * 100 | si_webinars |
| TC_BL_005 | Validate license cost assignment by type | License costs should match predefined rates by license type | si_licenses |

### 3. Edge Case Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) Tested |
|--------------|----------------------|------------------|------------------|
| TC_EC_001 | Handle null values in optional fields | Null values should be handled gracefully with defaults | All models |
| TC_EC_002 | Handle zero registrants in webinars | Attendance rate should be 0% when no registrants | si_webinars |
| TC_EC_003 | Handle meetings with zero participants | Participant count should be 0, not null | si_meetings |
| TC_EC_004 | Handle support tickets without resolution | Open tickets should have null close_date and resolution_time | si_support_tickets |
| TC_EC_005 | Handle expired licenses | License status should be 'Expired' when end_date < current_date | si_licenses |

### 4. Data Transformation Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) Tested |
|--------------|----------------------|------------------|------------------|
| TC_DT_001 | Validate email standardization (lowercase) | All emails should be converted to lowercase | si_users |
| TC_DT_002 | Validate name standardization (proper case) | User names should be in proper case format | si_users |
| TC_DT_003 | Validate plan type standardization | Plan types should be uppercase and from accepted values | si_users |
| TC_DT_004 | Validate feature categorization logic | Features should be categorized correctly based on name patterns | si_feature_usage |
| TC_DT_005 | Validate ticket type standardization | Ticket types should be standardized to accepted values | si_support_tickets |

### 5. Performance and Volume Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) Tested |
|--------------|----------------------|------------------|------------------|
| TC_PV_001 | Validate deduplication logic performance | Duplicate records should be removed efficiently | All models |
| TC_PV_002 | Validate large dataset processing | Models should handle datasets with 1M+ records | All models |
| TC_PV_003 | Validate incremental load performance | Incremental updates should complete within SLA | All models |

## dbt Test Scripts

### Schema Tests (schema.yml)

```yaml
version: 2

models:
  # Audit Log Tests
  - name: audit_log
    description: "Pipeline execution audit trail"
    tests:
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - execution_id
            - pipeline_name
    columns:
      - name: execution_id
        tests:
          - not_null
      - name: pipeline_name
        tests:
          - not_null
      - name: status
        tests:
          - not_null
          - accepted_values:
              values: ['STARTED', 'SUCCESS', 'FAILED', 'PARTIAL SUCCESS', 'CANCELLED']
      - name: execution_duration_seconds
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 86400  # Max 24 hours

  # Users Tests
  - name: si_users
    description: "Silver layer user data with quality validations"
    tests:
      - dbt_utils.expression_is_true:
          expression: "registration_date <= last_login_date OR last_login_date IS NULL"
    columns:
      - name: user_id
        tests:
          - not_null
          - unique
      - name: email
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
      - name: plan_type
        tests:
          - not_null
          - accepted_values:
              values: ['FREE', 'BASIC', 'PRO', 'ENTERPRISE']
      - name: account_status
        tests:
          - not_null
          - accepted_values:
              values: ['Active', 'Inactive', 'Suspended']
      - name: data_quality_score
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.0
              max_value: 1.0

  # Meetings Tests
  - name: si_meetings
    description: "Silver layer meeting data with host and participant information"
    tests:
      - dbt_utils.expression_is_true:
          expression: "start_time <= end_time"
      - dbt_utils.expression_is_true:
          expression: "participant_count >= 0"
    columns:
      - name: meeting_id
        tests:
          - not_null
          - unique
      - name: host_id
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: duration_minutes
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 1
              max_value: 1440  # Max 24 hours
      - name: meeting_type
        tests:
          - not_null
          - accepted_values:
              values: ['Scheduled', 'Instant', 'Webinar', 'Personal']
      - name: meeting_status
        tests:
          - not_null
          - accepted_values:
              values: ['Completed', 'In Progress', 'Scheduled', 'Cancelled']
      - name: data_quality_score
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.0
              max_value: 1.0

  # Participants Tests
  - name: si_participants
    description: "Silver layer participant attendance data"
    tests:
      - dbt_utils.expression_is_true:
          expression: "join_time <= leave_time OR leave_time IS NULL"
      - dbt_utils.expression_is_true:
          expression: "attendance_duration >= 0"
    columns:
      - name: participant_id
        tests:
          - not_null
          - unique
      - name: meeting_id
        tests:
          - not_null
          - relationships:
              to: ref('si_meetings')
              field: meeting_id
      - name: user_id
        tests:
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: attendance_duration
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440
      - name: participant_role
        tests:
          - not_null
          - accepted_values:
              values: ['Host', 'Participant']
      - name: data_quality_score
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.0
              max_value: 1.0

  # Feature Usage Tests
  - name: si_feature_usage
    description: "Silver layer feature usage analytics"
    tests:
      - dbt_utils.expression_is_true:
          expression: "usage_count >= 0"
      - dbt_utils.expression_is_true:
          expression: "usage_duration >= 0"
    columns:
      - name: usage_id
        tests:
          - not_null
          - unique
      - name: meeting_id
        tests:
          - not_null
          - relationships:
              to: ref('si_meetings')
              field: meeting_id
      - name: feature_category
        tests:
          - not_null
          - accepted_values:
              values: ['Audio', 'Video', 'Collaboration', 'Security']
      - name: usage_count
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
      - name: data_quality_score
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.0
              max_value: 1.0

  # Support Tickets Tests
  - name: si_support_tickets
    description: "Silver layer support ticket data"
    tests:
      - dbt_utils.expression_is_true:
          expression: "open_date <= close_date OR close_date IS NULL"
      - dbt_utils.expression_is_true:
          expression: "resolution_time_hours >= 0 OR resolution_time_hours IS NULL"
    columns:
      - name: ticket_id
        tests:
          - not_null
          - unique
      - name: user_id
        tests:
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: ticket_type
        tests:
          - not_null
          - accepted_values:
              values: ['TECHNICAL', 'BILLING', 'FEATURE REQUEST', 'BUG REPORT']
      - name: priority_level
        tests:
          - not_null
          - accepted_values:
              values: ['Critical', 'High', 'Medium', 'Low']
      - name: resolution_status
        tests:
          - not_null
          - accepted_values:
              values: ['OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED']
      - name: data_quality_score
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.0
              max_value: 1.0

  # Billing Events Tests
  - name: si_billing_events
    description: "Silver layer billing and financial data"
    tests:
      - dbt_utils.expression_is_true:
          expression: "transaction_amount > 0"
    columns:
      - name: event_id
        tests:
          - not_null
          - unique
      - name: user_id
        tests:
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: event_type
        tests:
          - not_null
          - accepted_values:
              values: ['SUBSCRIPTION', 'UPGRADE', 'DOWNGRADE', 'REFUND']
      - name: transaction_amount
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.01
              max_value: 10000.00
      - name: currency_code
        tests:
          - not_null
          - accepted_values:
              values: ['USD', 'EUR', 'GBP', 'CAD']
      - name: transaction_status
        tests:
          - not_null
          - accepted_values:
              values: ['Completed', 'Pending', 'Failed', 'Refunded']
      - name: data_quality_score
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.0
              max_value: 1.0

  # Licenses Tests
  - name: si_licenses
    description: "Silver layer license management data"
    tests:
      - dbt_utils.expression_is_true:
          expression: "start_date <= end_date"
      - dbt_utils.expression_is_true:
          expression: "utilization_percentage >= 0 AND utilization_percentage <= 100"
    columns:
      - name: license_id
        tests:
          - not_null
          - unique
      - name: assigned_to_user_id
        tests:
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: license_type
        tests:
          - not_null
          - accepted_values:
              values: ['BASIC', 'PRO', 'ENTERPRISE', 'ADD-ON']
      - name: license_status
        tests:
          - not_null
          - accepted_values:
              values: ['Active', 'Expired', 'Suspended']
      - name: license_cost
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.00
              max_value: 1000.00
      - name: utilization_percentage
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100
      - name: data_quality_score
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.0
              max_value: 1.0

  # Webinars Tests
  - name: si_webinars
    description: "Silver layer webinar analytics data"
    tests:
      - dbt_utils.expression_is_true:
          expression: "start_time <= end_time"
      - dbt_utils.expression_is_true:
          expression: "attendees <= registrants"
      - dbt_utils.expression_is_true:
          expression: "attendance_rate >= 0 AND attendance_rate <= 100"
    columns:
      - name: webinar_id
        tests:
          - not_null
          - unique
      - name: host_id
        tests:
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: duration_minutes
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 1
              max_value: 1440
      - name: registrants
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
      - name: attendees
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
      - name: attendance_rate
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.00
              max_value: 100.00
      - name: data_quality_score
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.0
              max_value: 1.0
```

### Custom SQL-Based Tests

#### Test 1: Validate Meeting Duration Consistency
```sql
-- tests/assert_meeting_duration_consistency.sql
SELECT 
    meeting_id,
    duration_minutes,
    DATEDIFF('minute', start_time, end_time) AS calculated_duration
FROM {{ ref('si_meetings') }}
WHERE duration_minutes != DATEDIFF('minute', start_time, end_time)
```

#### Test 2: Validate Participant Attendance Logic
```sql
-- tests/assert_participant_attendance_logic.sql
WITH meeting_durations AS (
    SELECT meeting_id, duration_minutes
    FROM {{ ref('si_meetings') }}
),
participant_attendance AS (
    SELECT 
        p.participant_id,
        p.meeting_id,
        p.attendance_duration,
        m.duration_minutes AS meeting_duration
    FROM {{ ref('si_participants') }} p
    JOIN meeting_durations m ON p.meeting_id = m.meeting_id
)
SELECT *
FROM participant_attendance
WHERE attendance_duration > meeting_duration
```

#### Test 3: Validate Data Quality Score Calculation
```sql
-- tests/assert_data_quality_score_logic.sql
SELECT 
    user_id,
    user_name,
    email,
    company,
    data_quality_score,
    CASE 
        WHEN user_name IS NOT NULL AND email IS NOT NULL AND company IS NOT NULL THEN 1.00
        WHEN user_name IS NOT NULL AND email IS NOT NULL THEN 0.85
        WHEN email IS NOT NULL THEN 0.70
        ELSE 0.50
    END AS expected_score
FROM {{ ref('si_users') }}
WHERE data_quality_score != expected_score
```

#### Test 4: Validate Webinar Attendance Rate Calculation
```sql
-- tests/assert_webinar_attendance_rate.sql
SELECT 
    webinar_id,
    registrants,
    attendees,
    attendance_rate,
    CASE 
        WHEN registrants > 0 THEN ROUND((attendees::FLOAT / registrants * 100), 2)
        ELSE 0.00
    END AS expected_rate
FROM {{ ref('si_webinars') }}
WHERE attendance_rate != expected_rate
```

#### Test 5: Validate License Status Logic
```sql
-- tests/assert_license_status_logic.sql
SELECT 
    license_id,
    start_date,
    end_date,
    license_status,
    CASE 
        WHEN end_date < CURRENT_DATE() THEN 'Expired'
        WHEN start_date > CURRENT_DATE() THEN 'Suspended'
        ELSE 'Active'
    END AS expected_status
FROM {{ ref('si_licenses') }}
WHERE license_status != expected_status
```

### Parameterized Tests

#### Test 6: Generic Data Freshness Test
```sql
-- tests/generic/test_data_freshness.sql
{% test data_freshness(model, column_name, max_days_old=7) %}
    SELECT *
    FROM {{ model }}
    WHERE {{ column_name }} < DATEADD('day', -{{ max_days_old }}, CURRENT_DATE())
{% endtest %}
```

#### Test 7: Generic Referential Integrity Test
```sql
-- tests/generic/test_referential_integrity.sql
{% test referential_integrity(model, column_name, parent_model, parent_column) %}
    SELECT {{ column_name }}
    FROM {{ model }}
    WHERE {{ column_name }} IS NOT NULL
    AND {{ column_name }} NOT IN (
        SELECT {{ parent_column }}
        FROM {{ parent_model }}
        WHERE {{ parent_column }} IS NOT NULL
    )
{% endtest %}
```

## Test Execution Strategy

### 1. Pre-deployment Testing
- Run all schema tests before model deployment
- Execute custom SQL tests to validate business logic
- Perform data quality checks on sample datasets

### 2. Post-deployment Validation
- Run full test suite after successful deployment
- Monitor test results in dbt Cloud or local environment
- Generate test reports for stakeholder review

### 3. Continuous Monitoring
- Schedule daily test runs for critical models
- Set up alerts for test failures
- Track test performance metrics over time

## Test Results Tracking

### dbt Test Results
Test results are automatically tracked in:
- `run_results.json` - Local dbt execution results
- Snowflake audit schema - Custom audit logging
- dbt Cloud dashboard - Centralized monitoring

### Key Metrics to Monitor
- Test pass/fail rates by model
- Data quality score trends
- Pipeline execution duration
- Error frequency and patterns

## Maintenance and Updates

### Regular Review Schedule
- Weekly: Review failed tests and data quality issues
- Monthly: Update test thresholds based on data patterns
- Quarterly: Add new test cases for enhanced coverage

### Test Case Evolution
- Add tests for new business requirements
- Update acceptance criteria based on stakeholder feedback
- Enhance edge case coverage based on production issues

## Conclusion

This comprehensive test suite ensures the reliability, accuracy, and performance of the Zoom Platform Analytics Silver Layer dbt models in Snowflake. Regular execution and maintenance of these tests will help maintain high data quality standards and prevent production issues.

---

**Note**: This test suite should be executed in a development environment before deploying to production. All test cases should pass before promoting code changes to higher environments.