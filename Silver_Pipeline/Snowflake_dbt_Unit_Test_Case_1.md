_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Platform Silver Layer dbt models in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Zoom Platform Silver Layer

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics System Silver Layer models running in Snowflake. The tests cover data transformations, business rules, edge cases, and error handling scenarios to ensure data quality and pipeline reliability.

## Silver Layer Models Overview

The Silver layer consists of 8 core models with enhanced data quality features:
- **SI_Audit_Log** - Audit table for pipeline tracking
- **SI_USERS** - User profile and subscription data
- **SI_MEETINGS** - Meeting data with EST timezone handling
- **SI_PARTICIPANTS** - Participant data with MM/DD/YYYY format handling
- **SI_FEATURE_USAGE** - Feature usage analytics
- **SI_SUPPORT_TICKETS** - Support ticket management
- **SI_BILLING_EVENTS** - Financial transactions
- **SI_LICENSES** - License management

## Test Case Categories

### 1. Data Quality Tests
### 2. Business Rule Validation Tests
### 3. Timestamp Format Handling Tests
### 4. Edge Case Tests
### 5. Error Handling Tests
### 6. Performance Tests

---

## Test Case List

| Test Case ID | Test Case Description | Expected Outcome | Priority | Model |
|--------------|----------------------|------------------|----------|-------|
| TC_001 | Validate SI_USERS email format | All emails follow valid format | High | SI_USERS |
| TC_002 | Check SI_USERS plan type standardization | Plan types are standardized (Basic, Pro, Business, Enterprise) | High | SI_USERS |
| TC_003 | Verify SI_MEETINGS EST timezone conversion | All timestamps properly converted from EST | Critical | SI_MEETINGS |
| TC_004 | Test SI_PARTICIPANTS MM/DD/YYYY format handling | All date formats properly parsed | Critical | SI_PARTICIPANTS |
| TC_005 | Validate data quality score calculation | Scores between 0-100 for all records | High | All Models |
| TC_006 | Check duplicate record elimination | No duplicate records in final output | Critical | All Models |
| TC_007 | Verify audit log creation | Audit records created for all pipeline runs | High | SI_Audit_Log |
| TC_008 | Test null value handling | No null values propagated to Silver layer | High | All Models |
| TC_009 | Validate referential integrity | Valid foreign key relationships maintained | Medium | All Models |
| TC_010 | Check data completeness scoring | Completeness metrics accurately calculated | Medium | All Models |
| TC_011 | Test error data capture | Invalid records captured in error tables | High | All Models |
| TC_012 | Verify timestamp standardization | All timestamps in consistent format | High | All Models |
| TC_013 | Validate business rule compliance | All business rules properly implemented | High | All Models |
| TC_014 | Test schema evolution handling | Schema changes handled gracefully | Medium | All Models |
| TC_015 | Check performance optimization | Queries execute within acceptable time limits | Medium | All Models |

---

## dbt Test Scripts

### Schema Tests (schema.yml)

```yaml
version: 2

sources:
  - name: bronze
    description: "Bronze layer source tables"
    schema: bronze
    tables:
      - name: br_users
        description: "Raw user data from source systems"
      - name: br_meetings
        description: "Raw meeting data from source systems"
      - name: br_participants
        description: "Raw participant data from source systems"
      - name: br_feature_usage
        description: "Raw feature usage data from source systems"
      - name: br_support_tickets
        description: "Raw support ticket data from source systems"
      - name: br_billing_events
        description: "Raw billing event data from source systems"
      - name: br_licenses
        description: "Raw license data from source systems"

models:
  - name: si_users
    description: "Silver layer user profile and subscription data"
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
              regex: '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
      - name: plan_type
        description: "Subscription plan type"
        tests:
          - not_null
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise']
      - name: data_quality_score
        description: "Data quality score (0-100)"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100
      - name: validation_status
        description: "Data validation status"
        tests:
          - not_null
          - accepted_values:
              values: ['PASSED', 'WARNING', 'FAILED']

  - name: si_meetings
    description: "Silver layer meeting data with timezone handling"
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
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440  # 24 hours max
      - name: data_quality_score
        description: "Data quality score (0-100)"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100

  - name: si_participants
    description: "Silver layer participant data with date format handling"
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
        description: "Participant join timestamp"
        tests:
          - not_null
      - name: leave_time
        description: "Participant leave timestamp"
        tests:
          - not_null

  - name: si_feature_usage
    description: "Silver layer feature usage analytics"
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
        description: "Number of times feature was used"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10000

  - name: si_support_tickets
    description: "Silver layer support ticket management"
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
          - not_null
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed']

  - name: si_billing_events
    description: "Silver layer billing events"
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
              min_value: 0
              max_value: 100000

  - name: si_licenses
    description: "Silver layer license management"
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
        description: "License start date"
        tests:
          - not_null
      - name: end_date
        description: "License end date"
        tests:
          - not_null

  - name: si_audit_log
    description: "Silver layer audit logging"
    columns:
      - name: execution_id
        description: "Unique execution identifier"
        tests:
          - unique
          - not_null
      - name: pipeline_name
        description: "Name of executed pipeline"
        tests:
          - not_null
      - name: execution_status
        description: "Pipeline execution status"
        tests:
          - not_null
          - accepted_values:
              values: ['SUCCESS', 'FAILED', 'RUNNING', 'CANCELLED']
```

### Custom SQL Tests

#### Test 1: Email Format Validation
```sql
-- tests/test_email_format_validation.sql
SELECT 
    user_id,
    email
FROM {{ ref('si_users') }}
WHERE email IS NOT NULL 
  AND NOT REGEXP_LIKE(email, '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$')
```

#### Test 2: Timestamp Format Consistency
```sql
-- tests/test_timestamp_format_consistency.sql
SELECT 
    meeting_id,
    start_time,
    end_time
FROM {{ ref('si_meetings') }}
WHERE start_time IS NOT NULL 
  AND end_time IS NOT NULL
  AND start_time >= end_time  -- Invalid: start after end
```

#### Test 3: Data Quality Score Range
```sql
-- tests/test_data_quality_score_range.sql
SELECT 
    'si_users' as table_name,
    user_id as record_id,
    data_quality_score
FROM {{ ref('si_users') }}
WHERE data_quality_score < 0 OR data_quality_score > 100

UNION ALL

SELECT 
    'si_meetings' as table_name,
    meeting_id as record_id,
    data_quality_score
FROM {{ ref('si_meetings') }}
WHERE data_quality_score < 0 OR data_quality_score > 100

UNION ALL

SELECT 
    'si_participants' as table_name,
    participant_id as record_id,
    data_quality_score
FROM {{ ref('si_participants') }}
WHERE data_quality_score < 0 OR data_quality_score > 100
```

#### Test 4: Duplicate Record Detection
```sql
-- tests/test_duplicate_records.sql
SELECT 
    user_id,
    COUNT(*) as duplicate_count
FROM {{ ref('si_users') }}
GROUP BY user_id
HAVING COUNT(*) > 1

UNION ALL

SELECT 
    meeting_id,
    COUNT(*) as duplicate_count
FROM {{ ref('si_meetings') }}
GROUP BY meeting_id
HAVING COUNT(*) > 1
```

#### Test 5: Referential Integrity Check
```sql
-- tests/test_referential_integrity.sql
-- Check if all meeting hosts exist in users table
SELECT 
    m.meeting_id,
    m.host_id
FROM {{ ref('si_meetings') }} m
LEFT JOIN {{ ref('si_users') }} u ON m.host_id = u.user_id
WHERE u.user_id IS NULL
  AND m.host_id IS NOT NULL

UNION ALL

-- Check if all participants exist in users table
SELECT 
    p.participant_id,
    p.user_id
FROM {{ ref('si_participants') }} p
LEFT JOIN {{ ref('si_users') }} u ON p.user_id = u.user_id
WHERE u.user_id IS NULL
  AND p.user_id IS NOT NULL
```

#### Test 6: EST Timezone Conversion Validation
```sql
-- tests/test_est_timezone_conversion.sql
SELECT 
    meeting_id,
    start_time,
    end_time
FROM {{ ref('si_meetings') }}
WHERE start_time IS NULL 
   OR end_time IS NULL
   OR TRY_TO_TIMESTAMP(start_time::STRING) IS NULL
   OR TRY_TO_TIMESTAMP(end_time::STRING) IS NULL
```

#### Test 7: MM/DD/YYYY Format Handling Validation
```sql
-- tests/test_mmddyyyy_format_handling.sql
SELECT 
    participant_id,
    join_time,
    leave_time
FROM {{ ref('si_participants') }}
WHERE join_time IS NULL 
   OR leave_time IS NULL
   OR TRY_TO_TIMESTAMP(join_time::STRING) IS NULL
   OR TRY_TO_TIMESTAMP(leave_time::STRING) IS NULL
```

#### Test 8: Business Rule Validation - Plan Type Standardization
```sql
-- tests/test_plan_type_standardization.sql
SELECT 
    user_id,
    plan_type
FROM {{ ref('si_users') }}
WHERE plan_type NOT IN ('Basic', 'Pro', 'Business', 'Enterprise')
  AND plan_type IS NOT NULL
```

#### Test 9: Audit Log Completeness
```sql
-- tests/test_audit_log_completeness.sql
SELECT 
    execution_id,
    pipeline_name,
    execution_status
FROM {{ ref('si_audit_log') }}
WHERE execution_id IS NULL 
   OR pipeline_name IS NULL 
   OR execution_status IS NULL
   OR execution_start_time IS NULL
```

#### Test 10: Data Freshness Validation
```sql
-- tests/test_data_freshness.sql
SELECT 
    'si_users' as table_name,
    MAX(load_timestamp) as latest_load,
    DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP()) as hours_since_load
FROM {{ ref('si_users') }}
HAVING hours_since_load > 24  -- Alert if data is older than 24 hours

UNION ALL

SELECT 
    'si_meetings' as table_name,
    MAX(load_timestamp) as latest_load,
    DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP()) as hours_since_load
FROM {{ ref('si_meetings') }}
HAVING hours_since_load > 24
```

### Macro Tests

#### Data Quality Score Calculation Test
```sql
-- macros/test_data_quality_score.sql
{% macro test_data_quality_score(model_name) %}
  SELECT 
    {{ model_name }}_id as record_id,
    data_quality_score,
    validation_status,
    CASE 
      WHEN data_quality_score >= 90 AND validation_status != 'PASSED' THEN 'INCONSISTENT_HIGH_SCORE'
      WHEN data_quality_score < 70 AND validation_status = 'PASSED' THEN 'INCONSISTENT_LOW_SCORE'
      WHEN data_quality_score BETWEEN 70 AND 89 AND validation_status NOT IN ('PASSED', 'WARNING') THEN 'INCONSISTENT_MID_SCORE'
      ELSE 'CONSISTENT'
    END as consistency_check
  FROM {{ ref('si_' + model_name) }}
  WHERE consistency_check != 'CONSISTENT'
{% endmacro %}
```

### Performance Tests

#### Test 11: Query Performance Validation
```sql
-- tests/test_query_performance.sql
-- This test should be run manually to check performance
SELECT 
    'si_users_performance' as test_name,
    COUNT(*) as record_count,
    CURRENT_TIMESTAMP() as test_start_time
FROM {{ ref('si_users') }}
WHERE load_date >= DATEADD('day', -7, CURRENT_DATE())
```

### Edge Case Tests

#### Test 12: Null Value Propagation Check
```sql
-- tests/test_null_value_propagation.sql
SELECT 
    'si_users' as table_name,
    'user_id' as column_name,
    COUNT(*) as null_count
FROM {{ ref('si_users') }}
WHERE user_id IS NULL

UNION ALL

SELECT 
    'si_meetings' as table_name,
    'meeting_id' as column_name,
    COUNT(*) as null_count
FROM {{ ref('si_meetings') }}
WHERE meeting_id IS NULL

UNION ALL

SELECT 
    'si_participants' as table_name,
    'participant_id' as column_name,
    COUNT(*) as null_count
FROM {{ ref('si_participants') }}
WHERE participant_id IS NULL
```

#### Test 13: Empty Dataset Handling
```sql
-- tests/test_empty_dataset_handling.sql
SELECT 
    table_name,
    record_count
FROM (
    SELECT 'si_users' as table_name, COUNT(*) as record_count FROM {{ ref('si_users') }}
    UNION ALL
    SELECT 'si_meetings' as table_name, COUNT(*) as record_count FROM {{ ref('si_meetings') }}
    UNION ALL
    SELECT 'si_participants' as table_name, COUNT(*) as record_count FROM {{ ref('si_participants') }}
    UNION ALL
    SELECT 'si_feature_usage' as table_name, COUNT(*) as record_count FROM {{ ref('si_feature_usage') }}
    UNION ALL
    SELECT 'si_support_tickets' as table_name, COUNT(*) as record_count FROM {{ ref('si_support_tickets') }}
    UNION ALL
    SELECT 'si_billing_events' as table_name, COUNT(*) as record_count FROM {{ ref('si_billing_events') }}
    UNION ALL
    SELECT 'si_licenses' as table_name, COUNT(*) as record_count FROM {{ ref('si_licenses') }}
)
WHERE record_count = 0
```

## Test Execution Strategy

### 1. Pre-deployment Testing
- Run all schema tests using `dbt test`
- Execute custom SQL tests
- Validate data quality scores
- Check referential integrity

### 2. Post-deployment Validation
- Monitor audit logs
- Validate data freshness
- Check performance metrics
- Review error tables

### 3. Continuous Monitoring
- Daily data quality score monitoring
- Weekly performance benchmarking
- Monthly schema evolution testing
- Quarterly comprehensive test review

## Test Configuration

### dbt_project.yml Test Configuration
```yaml
test-paths: ["tests"]

vars:
  # Test thresholds
  data_quality_threshold: 70
  performance_threshold_seconds: 300
  freshness_threshold_hours: 24
  
  # Test execution settings
  test_severity: 'error'  # Options: error, warn
  store_failures: true
  
models:
  zoom_silver:
    +materialized: table
    +on_schema_change: 'sync_all_columns'
    +pre-hook: "INSERT INTO {{ ref('si_audit_log') }} ..."
    +post-hook: "UPDATE {{ ref('si_audit_log') }} ..."

tests:
  zoom_silver:
    +severity: error
    +store_failures: true
    +schema: silver_test_results
```

## Expected Test Results

### Success Criteria
- All unique and not_null tests pass
- Email format validation: 100% compliance
- Plan type standardization: 100% compliance
- Timestamp format handling: 100% success rate
- Data quality scores: All between 0-100
- No duplicate records in any table
- Referential integrity: 100% compliance
- Audit logs: Complete for all pipeline runs

### Warning Thresholds
- Data quality score < 70: Investigation required
- Query performance > 5 minutes: Optimization needed
- Data freshness > 24 hours: Pipeline issue

### Failure Conditions
- Any null values in primary key columns
- Invalid email formats
- Timestamp conversion failures
- Referential integrity violations
- Missing audit log entries

## Troubleshooting Guide

### Common Issues and Solutions

1. **Timestamp Format Errors**
   - Check source data format consistency
   - Verify TRY_TO_TIMESTAMP function usage
   - Review multi-format fallback logic

2. **Data Quality Score Anomalies**
   - Validate scoring algorithm
   - Check input data completeness
   - Review business rule implementation

3. **Referential Integrity Failures**
   - Verify source data relationships
   - Check data loading sequence
   - Review foreign key mappings

4. **Performance Issues**
   - Analyze query execution plans
   - Check clustering keys
   - Review materialization strategy

## Maintenance and Updates

### Monthly Tasks
- Review test results and trends
- Update test thresholds based on data patterns
- Add new tests for schema changes
- Performance benchmark updates

### Quarterly Tasks
- Comprehensive test suite review
- Test coverage analysis
- Performance optimization review
- Documentation updates

---

**Note**: This test suite is designed to work with Snowflake's native functions and dbt's testing framework. All tests should be executed in a development environment before deployment to production.

**Test Execution Command**: `dbt test --models tag:silver_layer`

**Performance Monitoring**: Monitor test execution times and adjust thresholds as needed.

**Data Quality Monitoring**: Set up alerts for data quality scores below 70 and validation status failures.
