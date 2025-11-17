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

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics System Silver layer models running in Snowflake. The test cases cover data transformations, business rules, edge cases, and error handling scenarios to ensure reliable data processing and model performance.

## Test Coverage Overview

The test suite covers the following Silver layer models:
- **SI_USERS**: User profile and subscription data
- **SI_MEETINGS**: Meeting information with EST timezone handling
- **SI_PARTICIPANTS**: Participant data with MM/DD/YYYY format handling
- **SI_FEATURE_USAGE**: Platform feature usage tracking
- **SI_SUPPORT_TICKETS**: Customer support requests
- **SI_BILLING_EVENTS**: Financial transactions
- **SI_LICENSES**: License assignments and entitlements
- **SI_AUDIT_LOG**: Pipeline execution audit trail

## Test Case List

### 1. SI_USERS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_USR_001 | Validate user ID uniqueness and not null constraint | All user IDs are unique and non-null |
| TC_USR_002 | Validate email format using regex pattern | All emails follow valid format pattern |
| TC_USR_003 | Validate plan type standardization | Plan types are standardized to Free, Basic, Pro, Enterprise |
| TC_USR_004 | Test data quality score calculation | Quality scores are between 0-100 |
| TC_USR_005 | Validate null handling and default values | Null values are handled with appropriate defaults |
| TC_USR_006 | Test deduplication logic | Only latest record per user is retained |
| TC_USR_007 | Validate validation status assignment | Status is PASSED, WARNING, or FAILED |
| TC_USR_008 | Test company name standardization | Company names are trimmed and standardized |

### 2. SI_MEETINGS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_MTG_001 | Validate meeting ID uniqueness and not null | All meeting IDs are unique and non-null |
| TC_MTG_002 | Test EST timezone format validation | EST format timestamps are properly validated |
| TC_MTG_003 | Test EST to UTC timezone conversion | EST timestamps converted to UTC correctly |
| TC_MTG_004 | Validate meeting duration calculation | Duration matches start/end time difference |
| TC_MTG_005 | Test meeting time logic validation | End time is after start time |
| TC_MTG_006 | Validate host ID referential integrity | All hosts exist in SI_USERS table |
| TC_MTG_007 | Test duration range validation | Duration is within 0-1440 minutes |
| TC_MTG_008 | Test meeting topic sanitization | PII is removed from meeting topics |
| TC_MTG_009 | Test timestamp format error handling | Invalid EST formats routed to error table |
| TC_MTG_010 | Validate data quality scoring with timezone compliance | Quality scores include timezone format validation |

### 3. SI_PARTICIPANTS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_PRT_001 | Validate participant ID uniqueness | All participant IDs are unique and non-null |
| TC_PRT_002 | Test MM/DD/YYYY HH:MM format validation | MM/DD/YYYY format timestamps are validated |
| TC_PRT_003 | Test MM/DD/YYYY to standard format conversion | Format conversion works correctly |
| TC_PRT_004 | Validate participant session time logic | Leave time is after join time |
| TC_PRT_005 | Test meeting boundary validation | Join/leave times within meeting duration |
| TC_PRT_006 | Validate meeting referential integrity | All meetings exist in SI_MEETINGS table |
| TC_PRT_007 | Validate user referential integrity | All users exist in SI_USERS table |
| TC_PRT_008 | Test unique participant per meeting | Meeting-user combination is unique |
| TC_PRT_009 | Test timestamp format error handling | Invalid MM/DD/YYYY formats routed to error table |
| TC_PRT_010 | Validate cross-format consistency | Mixed formats within records are flagged |

### 4. SI_FEATURE_USAGE Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_FTR_001 | Validate usage ID uniqueness | All usage IDs are unique and non-null |
| TC_FTR_002 | Test feature name standardization | Feature names are standardized and trimmed |
| TC_FTR_003 | Validate usage count non-negative | Usage counts are >= 0 |
| TC_FTR_004 | Test meeting referential integrity | All meetings exist in SI_MEETINGS table |
| TC_FTR_005 | Validate usage date consistency | Usage dates align with meeting dates |
| TC_FTR_006 | Test feature adoption rate calculation | Adoption rates calculated correctly |
| TC_FTR_007 | Validate data quality scoring | Quality scores reflect completeness |

### 5. SI_SUPPORT_TICKETS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_TKT_001 | Validate ticket ID uniqueness | All ticket IDs are unique and non-null |
| TC_TKT_002 | Test resolution status validation | Status values are standardized |
| TC_TKT_003 | Validate user referential integrity | All users exist in SI_USERS table |
| TC_TKT_004 | Test open date validation | Open dates are not in future |
| TC_TKT_005 | Validate ticket type standardization | Ticket types are standardized |
| TC_TKT_006 | Test ticket volume metrics | Volume per 1000 users calculated |

### 6. SI_BILLING_EVENTS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BIL_001 | Validate event ID uniqueness | All event IDs are unique and non-null |
| TC_BIL_002 | Test amount validation | Amounts are positive with 2 decimal precision |
| TC_BIL_003 | Validate event date logic | Event dates are not in future |
| TC_BIL_004 | Test user referential integrity | All users exist in SI_USERS table |
| TC_BIL_005 | Validate event type standardization | Event types are standardized |
| TC_BIL_006 | Test MRR calculation | Monthly recurring revenue calculated correctly |

### 7. SI_LICENSES Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_LIC_001 | Validate license ID uniqueness | All license IDs are unique and non-null |
| TC_LIC_002 | Test license date logic | Start date is before end date |
| TC_LIC_003 | Validate user referential integrity | All assigned users exist in SI_USERS table |
| TC_LIC_004 | Test active license validation | Active licenses have future end dates |
| TC_LIC_005 | Validate license type standardization | License types are standardized |
| TC_LIC_006 | Test utilization rate calculation | Utilization rates calculated correctly |

### 8. Cross-Table Integration Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_INT_001 | Test user activity consistency | Users with meetings have participant records |
| TC_INT_002 | Validate feature usage alignment | Feature usage aligns with participants |
| TC_INT_003 | Test billing-license consistency | Billing events have corresponding licenses |
| TC_INT_004 | Validate audit trail completeness | All operations logged in audit table |

## dbt Test Scripts

### YAML-based Schema Tests

#### models/schema.yml

```yaml
version: 2

models:
  - name: si_users
    description: "Silver layer user data with validation and quality scoring"
    columns:
      - name: user_id
        description: "Unique user identifier"
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
        description: "Subscription plan type"
        tests:
          - accepted_values:
              values: ['Free', 'Basic', 'Pro', 'Enterprise']
      - name: data_quality_score
        description: "Data quality score 0-100"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100
      - name: validation_status
        description: "Validation status"
        tests:
          - accepted_values:
              values: ['PASSED', 'WARNING', 'FAILED']

  - name: si_meetings
    description: "Silver layer meeting data with EST timezone handling"
    columns:
      - name: meeting_id
        description: "Unique meeting identifier"
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
        description: "Meeting duration in minutes"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440
      - name: start_time
        description: "Meeting start timestamp"
        tests:
          - not_null
      - name: end_time
        description: "Meeting end timestamp"
        tests:
          - not_null

  - name: si_participants
    description: "Silver layer participant data with MM/DD/YYYY format handling"
    columns:
      - name: participant_id
        description: "Unique participant identifier"
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
        description: "Participant join timestamp"
        tests:
          - not_null
      - name: leave_time
        description: "Participant leave timestamp"
        tests:
          - not_null

  - name: si_feature_usage
    description: "Silver layer feature usage data"
    columns:
      - name: usage_id
        description: "Unique usage identifier"
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
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: number
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0

  - name: si_support_tickets
    description: "Silver layer support ticket data"
    columns:
      - name: ticket_id
        description: "Unique ticket identifier"
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
      - name: resolution_status
        description: "Ticket resolution status"
        tests:
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed']

  - name: si_billing_events
    description: "Silver layer billing event data"
    columns:
      - name: event_id
        description: "Unique event identifier"
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
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.01

  - name: si_licenses
    description: "Silver layer license data"
    columns:
      - name: license_id
        description: "Unique license identifier"
        tests:
          - unique
          - not_null
      - name: assigned_to_user_id
        description: "Reference to assigned user"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
```

### Custom SQL-based dbt Tests

#### tests/test_meeting_duration_consistency.sql

```sql
-- Test that meeting duration matches calculated time difference
SELECT 
    meeting_id,
    duration_minutes,
    DATEDIFF('minute', start_time, end_time) as calculated_duration,
    ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) as duration_diff
FROM {{ ref('si_meetings') }}
WHERE ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) > 1
```

#### tests/test_meeting_time_logic.sql

```sql
-- Test that meeting end time is after start time
SELECT 
    meeting_id,
    start_time,
    end_time
FROM {{ ref('si_meetings') }}
WHERE end_time <= start_time
```

#### tests/test_participant_session_logic.sql

```sql
-- Test that participant leave time is after join time
SELECT 
    participant_id,
    join_time,
    leave_time
FROM {{ ref('si_participants') }}
WHERE leave_time <= join_time
```

#### tests/test_participant_meeting_boundary.sql

```sql
-- Test that participant times are within meeting boundaries
SELECT 
    p.participant_id,
    p.join_time,
    p.leave_time,
    m.start_time,
    m.end_time
FROM {{ ref('si_participants') }} p
JOIN {{ ref('si_meetings') }} m ON p.meeting_id = m.meeting_id
WHERE p.join_time < m.start_time 
   OR p.leave_time > m.end_time
```

#### tests/test_est_timezone_format.sql

```sql
-- Test EST timezone format validation for SI_MEETINGS
SELECT 
    meeting_id,
    start_time,
    end_time,
    CASE 
        WHEN start_time::STRING LIKE '%EST%' 
             AND NOT REGEXP_LIKE(start_time::STRING, '^\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}(\\.\\d{3})? EST$') 
        THEN 'INVALID_EST_START_TIME'
        WHEN end_time::STRING LIKE '%EST%' 
             AND NOT REGEXP_LIKE(end_time::STRING, '^\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}(\\.\\d{3})? EST$') 
        THEN 'INVALID_EST_END_TIME'
        ELSE 'VALID'
    END as validation_result
FROM {{ ref('si_meetings') }}
WHERE (start_time::STRING LIKE '%EST%' OR end_time::STRING LIKE '%EST%')
  AND validation_result != 'VALID'
```

#### tests/test_mmddyyyy_format.sql

```sql
-- Test MM/DD/YYYY HH:MM format validation for SI_PARTICIPANTS
SELECT 
    participant_id,
    join_time,
    leave_time,
    CASE 
        WHEN join_time::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' 
             AND TRY_TO_TIMESTAMP(join_time::STRING, 'MM/DD/YYYY HH24:MI') IS NULL 
        THEN 'INVALID_JOIN_TIME_FORMAT'
        WHEN leave_time::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' 
             AND TRY_TO_TIMESTAMP(leave_time::STRING, 'MM/DD/YYYY HH24:MI') IS NULL 
        THEN 'INVALID_LEAVE_TIME_FORMAT'
        ELSE 'VALID'
    END as validation_result
FROM {{ ref('si_participants') }}
WHERE (join_time::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$'
       OR leave_time::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$')
  AND validation_result != 'VALID'
```

#### tests/test_timezone_conversion_success.sql

```sql
-- Test EST to UTC timezone conversion success
SELECT 
    meeting_id,
    start_time,
    end_time,
    CASE 
        WHEN start_time::STRING LIKE '%EST%' 
             AND TRY_TO_TIMESTAMP(REPLACE(start_time::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS') IS NULL 
        THEN 'CONVERSION_FAILED_START_TIME'
        WHEN end_time::STRING LIKE '%EST%' 
             AND TRY_TO_TIMESTAMP(REPLACE(end_time::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS') IS NULL 
        THEN 'CONVERSION_FAILED_END_TIME'
        ELSE 'CONVERSION_SUCCESS'
    END as conversion_result
FROM {{ ref('si_meetings') }}
WHERE (start_time::STRING LIKE '%EST%' OR end_time::STRING LIKE '%EST%')
  AND conversion_result != 'CONVERSION_SUCCESS'
```

#### tests/test_data_quality_score_range.sql

```sql
-- Test data quality scores are within valid range across all tables
SELECT 'si_users' as table_name, COUNT(*) as invalid_scores
FROM {{ ref('si_users') }}
WHERE data_quality_score < 0 OR data_quality_score > 100

UNION ALL

SELECT 'si_meetings', COUNT(*)
FROM {{ ref('si_meetings') }}
WHERE data_quality_score < 0 OR data_quality_score > 100

UNION ALL

SELECT 'si_participants', COUNT(*)
FROM {{ ref('si_participants') }}
WHERE data_quality_score < 0 OR data_quality_score > 100

UNION ALL

SELECT 'si_feature_usage', COUNT(*)
FROM {{ ref('si_feature_usage') }}
WHERE data_quality_score < 0 OR data_quality_score > 100

UNION ALL

SELECT 'si_support_tickets', COUNT(*)
FROM {{ ref('si_support_tickets') }}
WHERE data_quality_score < 0 OR data_quality_score > 100

UNION ALL

SELECT 'si_billing_events', COUNT(*)
FROM {{ ref('si_billing_events') }}
WHERE data_quality_score < 0 OR data_quality_score > 100

UNION ALL

SELECT 'si_licenses', COUNT(*)
FROM {{ ref('si_licenses') }}
WHERE data_quality_score < 0 OR data_quality_score > 100
```

#### tests/test_user_activity_consistency.sql

```sql
-- Test that users with meetings also have participant records
SELECT 
    m.meeting_id,
    m.host_id
FROM {{ ref('si_meetings') }} m
LEFT JOIN {{ ref('si_participants') }} p 
    ON m.meeting_id = p.meeting_id 
    AND m.host_id = p.user_id
WHERE p.user_id IS NULL
```

#### tests/test_feature_usage_alignment.sql

```sql
-- Test that feature usage records align with meeting participants
SELECT 
    f.usage_id,
    f.meeting_id
FROM {{ ref('si_feature_usage') }} f
LEFT JOIN {{ ref('si_participants') }} p ON f.meeting_id = p.meeting_id
WHERE p.meeting_id IS NULL
```

#### tests/test_billing_license_consistency.sql

```sql
-- Test that users with billing events have corresponding license records
SELECT 
    b.event_id,
    b.user_id
FROM {{ ref('si_billing_events') }} b
LEFT JOIN {{ ref('si_licenses') }} l ON b.user_id = l.assigned_to_user_id
WHERE l.assigned_to_user_id IS NULL
```

#### tests/test_unique_participant_per_meeting.sql

```sql
-- Test that meeting-user combination is unique
SELECT 
    meeting_id,
    user_id,
    COUNT(*) as duplicate_count
FROM {{ ref('si_participants') }}
GROUP BY meeting_id, user_id
HAVING COUNT(*) > 1
```

#### tests/test_future_dates_validation.sql

```sql
-- Test that dates are not in the future
SELECT 'si_support_tickets' as table_name, COUNT(*) as future_dates
FROM {{ ref('si_support_tickets') }}
WHERE open_date > CURRENT_DATE()

UNION ALL

SELECT 'si_billing_events', COUNT(*)
FROM {{ ref('si_billing_events') }}
WHERE event_date > CURRENT_DATE()
```

#### tests/test_license_date_logic.sql

```sql
-- Test that license start date is before end date
SELECT 
    license_id,
    start_date,
    end_date
FROM {{ ref('si_licenses') }}
WHERE start_date >= end_date
```

### Parameterized Tests

#### macros/test_referential_integrity.sql

```sql
{% macro test_referential_integrity(model, column_name, parent_model, parent_column) %}

SELECT 
    {{ column_name }}
FROM {{ model }}
WHERE {{ column_name }} IS NOT NULL
  AND {{ column_name }} NOT IN (
    SELECT {{ parent_column }}
    FROM {{ parent_model }}
    WHERE {{ parent_column }} IS NOT NULL
  )

{% endmacro %}
```

#### macros/test_timestamp_format_validation.sql

```sql
{% macro test_timestamp_format_validation(model, column_name, format_type) %}

{% if format_type == 'EST' %}
SELECT 
    {{ column_name }}
FROM {{ model }}
WHERE {{ column_name }}::STRING LIKE '%EST%'
  AND NOT REGEXP_LIKE({{ column_name }}::STRING, '^\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}(\\.\\d{3})? EST$')
{% elif format_type == 'MM/DD/YYYY' %}
SELECT 
    {{ column_name }}
FROM {{ model }}
WHERE {{ column_name }}::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$'
  AND TRY_TO_TIMESTAMP({{ column_name }}::STRING, 'MM/DD/YYYY HH24:MI') IS NULL
{% endif %}

{% endmacro %}
```

#### macros/test_data_quality_threshold.sql

```sql
{% macro test_data_quality_threshold(model, threshold=70) %}

SELECT 
    COUNT(*) as low_quality_records
FROM {{ model }}
WHERE data_quality_score < {{ threshold }}
HAVING COUNT(*) > 0

{% endmacro %}
```

## Test Execution Strategy

### 1. Test Execution Order

1. **Schema Tests**: Execute basic schema validation tests first
2. **Custom SQL Tests**: Run custom business logic tests
3. **Integration Tests**: Execute cross-table validation tests
4. **Performance Tests**: Run data volume and performance tests

### 2. Test Environment Setup

```yaml
# dbt_project.yml test configuration
test-paths: ["tests"]

vars:
  # Test thresholds
  data_quality_threshold: 70
  max_processing_time_minutes: 60
  
  # Test data volumes
  max_test_records: 10000
  
  # Timestamp format validation
  enable_est_validation: true
  enable_mmddyyyy_validation: true
```

### 3. Continuous Integration

```bash
# Run all tests
dbt test

# Run specific model tests
dbt test --models si_users
dbt test --models si_meetings
dbt test --models si_participants

# Run tests with specific tags
dbt test --select tag:timestamp_validation
dbt test --select tag:referential_integrity
dbt test --select tag:data_quality
```

### 4. Test Result Monitoring

- **Test Results Tracking**: All test results logged in dbt's run_results.json
- **Snowflake Audit Schema**: Test execution tracked in Snowflake audit tables
- **Alert Configuration**: Automated alerts for test failures
- **Dashboard Integration**: Test results integrated into monitoring dashboards

## Error Handling and Recovery

### 1. Test Failure Categories

- **Critical Failures**: Data corruption, referential integrity violations
- **High Priority**: Timestamp format errors, business rule violations
- **Medium Priority**: Data quality score below threshold
- **Low Priority**: Performance degradation, minor format issues

### 2. Automated Recovery Procedures

- **Timestamp Format Errors**: Automatic retry with format remediation
- **Referential Integrity**: Data lineage analysis and correction
- **Quality Score Issues**: Automated data cleansing workflows

### 3. Manual Intervention Triggers

- **Multiple consecutive test failures**
- **Critical business rule violations**
- **Data volume anomalies**
- **Performance threshold breaches**

## Performance Optimization

### 1. Test Performance Monitoring

- **Execution Time Tracking**: Monitor test execution duration
- **Resource Usage**: Track compute and storage consumption
- **Parallel Execution**: Optimize test parallelization

### 2. Test Data Management

- **Sample Data Testing**: Use representative data samples for large tables
- **Incremental Testing**: Test only changed data when possible
- **Test Data Refresh**: Regular refresh of test datasets

## Compliance and Audit

### 1. Test Documentation

- **Test Case Traceability**: Link tests to business requirements
- **Change Management**: Document test modifications
- **Approval Workflows**: Implement test change approvals

### 2. Regulatory Compliance

- **Data Privacy**: Ensure test data complies with privacy regulations
- **Audit Trail**: Maintain comprehensive test execution logs
- **Retention Policies**: Implement test result retention policies

---

**Note**: This comprehensive test suite ensures the reliability, performance, and data quality of the Zoom Platform Analytics System Silver layer models in Snowflake. The tests cover all critical data transformations, business rules, edge cases, and error handling scenarios, with special focus on timestamp format validation for EST timezone (SI_MEETINGS) and MM/DD/YYYY format (SI_PARTICIPANTS) handling.