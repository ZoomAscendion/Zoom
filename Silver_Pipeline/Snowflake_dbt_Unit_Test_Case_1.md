_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases and dbt test scripts for Zoom Platform Analytics Silver Layer Pipeline
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases
## Zoom Platform Analytics Silver Layer Pipeline

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics Silver Layer Pipeline that transforms data from Bronze to Silver layer following the Medallion architecture. The tests ensure data quality, referential integrity, business rule compliance, and error handling across all Silver layer models.

## Test Coverage Overview

The test suite covers the following dbt models:
- **audit_log**: Pipeline execution tracking
- **si_users**: User account data with cleansing and validation
- **si_meetings**: Meeting session data with calculated metrics
- **si_participants**: Participant attendance data with duration calculations
- **si_feature_usage**: Feature usage tracking with categorization
- **si_support_tickets**: Support ticket data with resolution metrics
- **si_billing_events**: Billing and financial transaction data
- **si_licenses**: License management data with utilization metrics
- **si_webinars**: Webinar data with engagement metrics

## Test Case Categories

### 1. Data Quality Tests
### 2. Business Logic Tests
### 3. Referential Integrity Tests
### 4. Edge Case Tests
### 5. Error Handling Tests
### 6. Performance Tests

---

## Test Case List

| Test Case ID | Test Case Description | Model | Expected Outcome |
|--------------|----------------------|-------|------------------|
| TC_001 | Validate user_id uniqueness and not null | si_users | All user_id values are unique and not null |
| TC_002 | Validate email format compliance | si_users | All email addresses follow valid format pattern |
| TC_003 | Validate plan_type enumeration | si_users | All plan_type values are from predefined list |
| TC_004 | Validate account_status derivation logic | si_users | Account status correctly derived from login activity |
| TC_005 | Validate data quality score calculation | si_users | Data quality scores are between 0.0 and 1.0 |
| TC_006 | Validate meeting_id uniqueness | si_meetings | All meeting_id values are unique and not null |
| TC_007 | Validate meeting duration logic | si_meetings | Duration matches calculated time difference |
| TC_008 | Validate meeting type classification | si_meetings | Meeting types correctly classified based on criteria |
| TC_009 | Validate host referential integrity | si_meetings | All host_id values exist in si_users table |
| TC_010 | Validate participant count accuracy | si_meetings | Participant counts match actual participant records |
| TC_011 | Validate participant referential integrity | si_participants | All meeting_id and user_id references are valid |
| TC_012 | Validate attendance duration calculation | si_participants | Attendance duration correctly calculated from join/leave times |
| TC_013 | Validate participant role assignment | si_participants | Participant roles correctly assigned based on host status |
| TC_014 | Validate connection quality derivation | si_participants | Connection quality derived from attendance duration |
| TC_015 | Validate feature usage referential integrity | si_feature_usage | All meeting_id references exist in si_meetings |
| TC_016 | Validate feature categorization logic | si_feature_usage | Features correctly categorized by type |
| TC_017 | Validate usage count non-negative | si_feature_usage | All usage counts are non-negative integers |
| TC_018 | Validate support ticket referential integrity | si_support_tickets | All user_id references exist in si_users |
| TC_019 | Validate ticket type enumeration | si_support_tickets | All ticket types from predefined list |
| TC_020 | Validate resolution time calculation | si_support_tickets | Resolution times correctly calculated |
| TC_021 | Validate priority level assignment | si_support_tickets | Priority levels correctly assigned |
| TC_022 | Validate billing event referential integrity | si_billing_events | All user_id references exist in si_users |
| TC_023 | Validate transaction amount positivity | si_billing_events | All transaction amounts are positive |
| TC_024 | Validate currency code format | si_billing_events | All currency codes are valid 3-character ISO codes |
| TC_025 | Validate invoice number uniqueness | si_billing_events | All invoice numbers are unique when not null |
| TC_026 | Validate license referential integrity | si_licenses | All assigned_to_user_id references exist in si_users |
| TC_027 | Validate license status derivation | si_licenses | License status correctly derived from dates |
| TC_028 | Validate license cost assignment | si_licenses | License costs correctly assigned by type |
| TC_029 | Validate utilization percentage range | si_licenses | Utilization percentages are between 0 and 100 |
| TC_030 | Validate webinar referential integrity | si_webinars | All host_id references exist in si_users |
| TC_031 | Validate attendance rate calculation | si_webinars | Attendance rates correctly calculated |
| TC_032 | Validate webinar duration logic | si_webinars | Duration matches time difference calculation |
| TC_033 | Validate duplicate record handling | All models | No duplicate records based on primary keys |
| TC_034 | Validate null value handling | All models | Required fields are not null |
| TC_035 | Validate date logic consistency | All models | End dates/times are after start dates/times |
| TC_036 | Validate audit trail completeness | audit_log | All pipeline executions are logged |
| TC_037 | Validate error logging functionality | All models | Data quality errors are properly logged |
| TC_038 | Validate incremental processing | All models | Only changed records are processed |
| TC_039 | Validate cross-table consistency | Multiple models | Related data is consistent across tables |
| TC_040 | Validate performance thresholds | All models | Models execute within acceptable time limits |

---

## dbt Test Scripts

### 1. Schema Tests (schema.yml)

```yaml
version: 2

models:
  # SI_USERS Model Tests
  - name: si_users
    description: "Silver layer users table with cleaned and standardized data"
    tests:
      - dbt_expectations.expect_table_row_count_to_be_between:
          min_value: 1
          max_value: 1000000
    columns:
      - name: user_id
        description: "Unique identifier for each user account"
        tests:
          - not_null
          - unique
      - name: user_name
        description: "Standardized full name of the registered user"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_not_be_null
      - name: email
        description: "Validated and standardized email address"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
      - name: plan_type
        description: "Standardized subscription tier"
        tests:
          - not_null
          - accepted_values:
              values: ['Free', 'Basic', 'Pro', 'Enterprise']
      - name: account_status
        description: "Current status of user account"
        tests:
          - not_null
          - accepted_values:
              values: ['Active', 'Inactive', 'Suspended']
      - name: data_quality_score
        description: "Overall data quality score for the record"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.0
              max_value: 1.0
      - name: registration_date
        description: "Date when the user first registered"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: date
      - name: last_login_date
        description: "Most recent date the user accessed the platform"
        tests:
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: date

  # SI_MEETINGS Model Tests
  - name: si_meetings
    description: "Silver layer meetings table with enriched data and calculated metrics"
    tests:
      - dbt_expectations.expect_table_row_count_to_be_between:
          min_value: 1
          max_value: 10000000
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
              to: ref('si_users')
              field: user_id
      - name: meeting_type
        description: "Standardized meeting category"
        tests:
          - not_null
          - accepted_values:
              values: ['Scheduled', 'Instant', 'Webinar', 'Personal']
      - name: duration_minutes
        description: "Calculated and validated meeting duration"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 1
              max_value: 1440
      - name: meeting_status
        description: "Current state of the meeting"
        tests:
          - not_null
          - accepted_values:
              values: ['Scheduled', 'In Progress', 'Completed', 'Cancelled']
      - name: participant_count
        description: "Total number of participants"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10000
      - name: data_quality_score
        description: "Overall data quality score for the record"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.0
              max_value: 1.0

  # SI_PARTICIPANTS Model Tests
  - name: si_participants
    description: "Silver layer participants table with calculated attendance metrics"
    columns:
      - name: participant_id
        description: "Unique identifier for each participant record"
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
        description: "Reference to user who participated"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: attendance_duration
        description: "Calculated time participant spent in meeting"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440
      - name: participant_role
        description: "Role of attendee"
        tests:
          - accepted_values:
              values: ['Host', 'Co-host', 'Participant', 'Observer']
      - name: connection_quality
        description: "Network connection quality during participation"
        tests:
          - accepted_values:
              values: ['Excellent', 'Good', 'Fair', 'Poor']

  # SI_FEATURE_USAGE Model Tests
  - name: si_feature_usage
    description: "Silver layer feature usage table with categorization"
    columns:
      - name: usage_id
        description: "Unique identifier for each feature usage record"
        tests:
          - not_null
          - unique
      - name: meeting_id
        description: "Reference to meeting where feature was used"
        tests:
          - not_null
          - relationships:
              to: ref('si_meetings')
              field: meeting_id
      - name: feature_category
        description: "Classification of feature type"
        tests:
          - not_null
          - accepted_values:
              values: ['Audio', 'Video', 'Collaboration', 'Security', 'Other']
      - name: usage_count
        description: "Number of times feature was used"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10000

  # SI_SUPPORT_TICKETS Model Tests
  - name: si_support_tickets
    description: "Silver layer support tickets table with resolution metrics"
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
              to: ref('si_users')
              field: user_id
      - name: ticket_type
        description: "Standardized category of support ticket"
        tests:
          - not_null
          - accepted_values:
              values: ['Technical', 'Billing', 'Feature Request', 'Bug Report']
      - name: priority_level
        description: "Urgency level of ticket"
        tests:
          - not_null
          - accepted_values:
              values: ['Low', 'Medium', 'High', 'Critical']
      - name: resolution_status
        description: "Current status of ticket"
        tests:
          - not_null
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed']

  # SI_BILLING_EVENTS Model Tests
  - name: si_billing_events
    description: "Silver layer billing events table with validated financial data"
    columns:
      - name: event_id
        description: "Unique identifier for each billing event"
        tests:
          - not_null
          - unique
      - name: user_id
        description: "Reference to user associated with billing event"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: transaction_amount
        description: "Validated monetary value of the billing event"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.01
              max_value: 100000.00
      - name: currency_code
        description: "ISO currency code for the transaction"
        tests:
          - not_null
          - dbt_expectations.expect_column_value_lengths_to_equal:
              value: 3
      - name: event_type
        description: "Type of billing event"
        tests:
          - not_null
          - accepted_values:
              values: ['Subscription', 'Upgrade', 'Downgrade', 'Refund']

  # SI_LICENSES Model Tests
  - name: si_licenses
    description: "Silver layer licenses table with validated assignment data"
    columns:
      - name: license_id
        description: "Unique identifier for each license"
        tests:
          - not_null
          - unique
      - name: assigned_to_user_id
        description: "User ID to whom license is assigned"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: license_type
        description: "Standardized category of license"
        tests:
          - not_null
          - accepted_values:
              values: ['Basic', 'Pro', 'Enterprise', 'Add-On']
      - name: license_status
        description: "Current state of license"
        tests:
          - not_null
          - accepted_values:
              values: ['Active', 'Expired', 'Suspended']
      - name: utilization_percentage
        description: "Percentage of license features being utilized"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.0
              max_value: 100.0

  # SI_WEBINARS Model Tests
  - name: si_webinars
    description: "Silver layer webinars table with engagement metrics"
    columns:
      - name: webinar_id
        description: "Unique identifier for each webinar"
        tests:
          - not_null
          - unique
      - name: host_id
        description: "User ID of the webinar host"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: attendance_rate
        description: "Percentage of registrants who attended"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.0
              max_value: 100.0
      - name: registrants
        description: "Number of registered participants"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100000
      - name: attendees
        description: "Number of actual attendees"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100000
```

### 2. Custom SQL-based dbt Tests

#### Test 1: Meeting Duration Consistency Check
```sql
-- tests/meeting_duration_consistency.sql
-- Validates that calculated duration matches the difference between start and end times

SELECT 
    meeting_id,
    duration_minutes,
    DATEDIFF('minute', start_time, end_time) as calculated_duration
FROM {{ ref('si_meetings') }}
WHERE duration_minutes != DATEDIFF('minute', start_time, end_time)
   OR duration_minutes IS NULL
   OR start_time IS NULL
   OR end_time IS NULL
```

#### Test 2: Participant Attendance Duration Logic Check
```sql
-- tests/participant_attendance_logic.sql
-- Validates that participant attendance duration doesn't exceed meeting duration

SELECT 
    p.participant_id,
    p.attendance_duration,
    m.duration_minutes as meeting_duration
FROM {{ ref('si_participants') }} p
JOIN {{ ref('si_meetings') }} m ON p.meeting_id = m.meeting_id
WHERE p.attendance_duration > m.duration_minutes
   OR p.attendance_duration < 0
   OR p.attendance_duration IS NULL
```

#### Test 3: Data Quality Score Validation
```sql
-- tests/data_quality_score_validation.sql
-- Validates that all data quality scores are within acceptable range

SELECT 'si_users' as table_name, user_id as record_id, data_quality_score
FROM {{ ref('si_users') }}
WHERE data_quality_score < 0.0 OR data_quality_score > 1.0 OR data_quality_score IS NULL

UNION ALL

SELECT 'si_meetings', meeting_id, data_quality_score
FROM {{ ref('si_meetings') }}
WHERE data_quality_score < 0.0 OR data_quality_score > 1.0 OR data_quality_score IS NULL

UNION ALL

SELECT 'si_participants', participant_id, data_quality_score
FROM {{ ref('si_participants') }}
WHERE data_quality_score < 0.0 OR data_quality_score > 1.0 OR data_quality_score IS NULL
```

#### Test 4: Cross-Table Referential Integrity Check
```sql
-- tests/cross_table_referential_integrity.sql
-- Validates referential integrity across all Silver layer tables

-- Check for orphaned meetings (host not in users)
SELECT 'orphaned_meetings' as error_type, meeting_id as record_id
FROM {{ ref('si_meetings') }} m
LEFT JOIN {{ ref('si_users') }} u ON m.host_id = u.user_id
WHERE u.user_id IS NULL

UNION ALL

-- Check for orphaned participants (user not in users)
SELECT 'orphaned_participants', participant_id
FROM {{ ref('si_participants') }} p
LEFT JOIN {{ ref('si_users') }} u ON p.user_id = u.user_id
WHERE u.user_id IS NULL

UNION ALL

-- Check for orphaned feature usage (meeting not in meetings)
SELECT 'orphaned_feature_usage', usage_id
FROM {{ ref('si_feature_usage') }} f
LEFT JOIN {{ ref('si_meetings') }} m ON f.meeting_id = m.meeting_id
WHERE m.meeting_id IS NULL
```

#### Test 5: Business Logic Validation
```sql
-- tests/business_logic_validation.sql
-- Validates business rules and logic across models

-- Check for webinars where attendees exceed registrants
SELECT 'invalid_webinar_attendance' as error_type, webinar_id as record_id
FROM {{ ref('si_webinars') }}
WHERE attendees > registrants

UNION ALL

-- Check for support tickets with invalid resolution times
SELECT 'invalid_resolution_time', ticket_id
FROM {{ ref('si_support_tickets') }}
WHERE close_date < open_date
   OR (resolution_status IN ('Resolved', 'Closed') AND close_date IS NULL)

UNION ALL

-- Check for licenses with invalid date ranges
SELECT 'invalid_license_dates', license_id
FROM {{ ref('si_licenses') }}
WHERE end_date < start_date
   OR start_date IS NULL
   OR end_date IS NULL
```

#### Test 6: Account Status Derivation Logic
```sql
-- tests/account_status_logic.sql
-- Validates that account status is correctly derived from user activity

SELECT 
    user_id,
    account_status,
    last_login_date,
    CASE 
        WHEN last_login_date >= DATEADD('day', -30, CURRENT_DATE()) THEN 'Active'
        WHEN last_login_date >= DATEADD('day', -90, CURRENT_DATE()) THEN 'Inactive'
        ELSE 'Suspended'
    END as expected_status
FROM {{ ref('si_users') }}
WHERE account_status != CASE 
    WHEN last_login_date >= DATEADD('day', -30, CURRENT_DATE()) THEN 'Active'
    WHEN last_login_date >= DATEADD('day', -90, CURRENT_DATE()) THEN 'Inactive'
    ELSE 'Suspended'
END
```

#### Test 7: Feature Categorization Logic
```sql
-- tests/feature_categorization_logic.sql
-- Validates that features are correctly categorized

SELECT 
    usage_id,
    feature_name,
    feature_category,
    CASE 
        WHEN LOWER(feature_name) LIKE '%audio%' OR LOWER(feature_name) LIKE '%microphone%' THEN 'Audio'
        WHEN LOWER(feature_name) LIKE '%video%' OR LOWER(feature_name) LIKE '%camera%' THEN 'Video'
        WHEN LOWER(feature_name) LIKE '%chat%' OR LOWER(feature_name) LIKE '%share%' THEN 'Collaboration'
        WHEN LOWER(feature_name) LIKE '%security%' OR LOWER(feature_name) LIKE '%password%' THEN 'Security'
        ELSE 'Other'
    END as expected_category
FROM {{ ref('si_feature_usage') }}
WHERE feature_category != CASE 
    WHEN LOWER(feature_name) LIKE '%audio%' OR LOWER(feature_name) LIKE '%microphone%' THEN 'Audio'
    WHEN LOWER(feature_name) LIKE '%video%' OR LOWER(feature_name) LIKE '%camera%' THEN 'Video'
    WHEN LOWER(feature_name) LIKE '%chat%' OR LOWER(feature_name) LIKE '%share%' THEN 'Collaboration'
    WHEN LOWER(feature_name) LIKE '%security%' OR LOWER(feature_name) LIKE '%password%' THEN 'Security'
    ELSE 'Other'
END
```

#### Test 8: Duplicate Record Detection
```sql
-- tests/duplicate_record_detection.sql
-- Identifies duplicate records across all Silver layer tables

SELECT 'si_users' as table_name, user_id, COUNT(*) as duplicate_count
FROM {{ ref('si_users') }}
GROUP BY user_id
HAVING COUNT(*) > 1

UNION ALL

SELECT 'si_meetings', meeting_id, COUNT(*)
FROM {{ ref('si_meetings') }}
GROUP BY meeting_id
HAVING COUNT(*) > 1

UNION ALL

SELECT 'si_participants', participant_id, COUNT(*)
FROM {{ ref('si_participants') }}
GROUP BY participant_id
HAVING COUNT(*) > 1
```

#### Test 9: Data Freshness Validation
```sql
-- tests/data_freshness_validation.sql
-- Validates that data is fresh and within acceptable time windows

SELECT 
    'stale_meeting_data' as error_type,
    meeting_id as record_id,
    end_time,
    load_timestamp
FROM {{ ref('si_meetings') }}
WHERE end_time < DATEADD('day', -1, CURRENT_TIMESTAMP())
  AND load_timestamp < DATEADD('hour', -2, end_time)

UNION ALL

SELECT 
    'stale_user_data',
    user_id,
    last_login_date,
    update_timestamp
FROM {{ ref('si_users') }}
WHERE last_login_date IS NOT NULL
  AND update_timestamp < DATEADD('hour', -1, CURRENT_TIMESTAMP())
```

#### Test 10: Audit Trail Completeness
```sql
-- tests/audit_trail_completeness.sql
-- Validates that audit trail is complete and consistent

SELECT 
    execution_id,
    pipeline_name,
    start_time,
    end_time,
    status
FROM {{ ref('audit_log') }}
WHERE start_time IS NULL
   OR pipeline_name IS NULL
   OR status NOT IN ('Success', 'Failed', 'Partial Success', 'Cancelled', 'In Progress')
   OR (status = 'Success' AND end_time IS NULL)
   OR (end_time IS NOT NULL AND end_time < start_time)
```

### 3. Parameterized Tests

#### Generic Test: Range Validation
```sql
-- macros/test_column_range.sql
{% macro test_column_range(model, column_name, min_value, max_value) %}

SELECT *
FROM {{ model }}
WHERE {{ column_name }} < {{ min_value }}
   OR {{ column_name }} > {{ max_value }}
   OR {{ column_name }} IS NULL

{% endmacro %}
```

#### Generic Test: Date Logic Validation
```sql
-- macros/test_date_logic.sql
{% macro test_date_logic(model, start_date_column, end_date_column) %}

SELECT *
FROM {{ model }}
WHERE {{ end_date_column }} < {{ start_date_column }}
   OR {{ start_date_column }} IS NULL
   OR {{ end_date_column }} IS NULL

{% endmacro %}
```

#### Generic Test: Referential Integrity
```sql
-- macros/test_referential_integrity.sql
{% macro test_referential_integrity(model, column_name, ref_model, ref_column) %}

SELECT *
FROM {{ model }} m
LEFT JOIN {{ ref_model }} r ON m.{{ column_name }} = r.{{ ref_column }}
WHERE r.{{ ref_column }} IS NULL
  AND m.{{ column_name }} IS NOT NULL

{% endmacro %}
```

### 4. Performance Tests

#### Test: Model Execution Time
```sql
-- tests/performance_execution_time.sql
-- Monitors model execution times to ensure they meet performance thresholds

{% set start_time = modules.datetime.datetime.now() %}

SELECT COUNT(*) as record_count
FROM {{ ref('si_users') }}

{% set end_time = modules.datetime.datetime.now() %}
{% set execution_time = (end_time - start_time).total_seconds() %}

-- Fail test if execution time exceeds 60 seconds
{% if execution_time > 60 %}
    SELECT 'Execution time exceeded threshold: ' || {{ execution_time }} || ' seconds' as error_message
{% else %}
    SELECT NULL as error_message WHERE FALSE
{% endif %}
```

### 5. Edge Case Tests

#### Test: Null Value Handling
```sql
-- tests/null_value_handling.sql
-- Tests how models handle various null value scenarios

-- Test users with minimal data
SELECT user_id
FROM {{ ref('si_users') }}
WHERE user_name IS NULL
   OR email IS NULL
   OR plan_type IS NULL

-- Test meetings with edge case durations
UNION ALL

SELECT meeting_id
FROM {{ ref('si_meetings') }}
WHERE duration_minutes = 0
   OR duration_minutes > 1440
```

#### Test: Boundary Value Testing
```sql
-- tests/boundary_value_testing.sql
-- Tests boundary conditions for numeric and date fields

-- Test minimum and maximum values
SELECT 'invalid_duration' as test_case, meeting_id as record_id
FROM {{ ref('si_meetings') }}
WHERE duration_minutes <= 0 OR duration_minutes > 1440

UNION ALL

SELECT 'invalid_utilization', license_id
FROM {{ ref('si_licenses') }}
WHERE utilization_percentage < 0 OR utilization_percentage > 100

UNION ALL

SELECT 'invalid_quality_score', user_id
FROM {{ ref('si_users') }}
WHERE data_quality_score < 0.0 OR data_quality_score > 1.0
```

### 6. Error Handling Tests

#### Test: Data Type Validation
```sql
-- tests/data_type_validation.sql
-- Validates that data types are correctly handled and converted

SELECT 
    'invalid_email_format' as error_type,
    user_id as record_id,
    email
FROM {{ ref('si_users') }}
WHERE email IS NOT NULL
  AND NOT REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')

UNION ALL

SELECT 
    'invalid_currency_code',
    event_id,
    currency_code
FROM {{ ref('si_billing_events') }}
WHERE currency_code IS NOT NULL
  AND (LENGTH(currency_code) != 3 OR NOT REGEXP_LIKE(currency_code, '^[A-Z]{3}$'))
```

## Test Execution Guidelines

### 1. Test Execution Order
1. **Schema Tests**: Run basic schema validation tests first
2. **Referential Integrity Tests**: Validate relationships between tables
3. **Business Logic Tests**: Verify business rule compliance
4. **Data Quality Tests**: Check data quality scores and validation
5. **Performance Tests**: Monitor execution times and resource usage
6. **Edge Case Tests**: Test boundary conditions and error scenarios

### 2. Test Environment Setup
```bash
# Install required dbt packages
dbt deps

# Run all tests
dbt test

# Run tests for specific model
dbt test --select si_users

# Run tests with specific tag
dbt test --select tag:data_quality

# Run tests in fail-fast mode
dbt test --fail-fast
```

### 3. Test Result Monitoring
- Set up automated test execution in CI/CD pipeline
- Configure alerts for test failures
- Monitor test execution times and performance
- Track data quality metrics over time
- Generate test result reports for stakeholders

### 4. Test Maintenance
- Review and update tests regularly as business requirements change
- Add new tests for new features and edge cases
- Optimize test performance for large datasets
- Document test failures and resolution procedures
- Maintain test data for consistent testing

## Expected Outcomes

### Success Criteria
- All schema tests pass with 100% success rate
- Referential integrity maintained across all tables
- Data quality scores meet minimum thresholds (>= 0.8)
- Business logic validation passes for all records
- Performance tests complete within acceptable time limits
- No critical data quality errors in production

### Failure Scenarios
- Test failures trigger immediate alerts
- Failed records logged in SI_DATA_QUALITY_ERRORS table
- Pipeline execution halted for critical failures
- Detailed error reports generated for investigation
- Rollback procedures activated for data corruption

### Monitoring and Alerting
- Real-time test result dashboards
- Automated email notifications for test failures
- Integration with monitoring tools (DataDog, New Relic)
- Weekly data quality reports
- Monthly test coverage analysis

This comprehensive test suite ensures the reliability, accuracy, and performance of the Zoom Platform Analytics Silver Layer Pipeline, providing confidence in data quality and business rule compliance across all transformations and models.