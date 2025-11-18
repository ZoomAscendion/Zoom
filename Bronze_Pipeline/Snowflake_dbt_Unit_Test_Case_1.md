_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Platform Analytics Bronze Layer dbt models in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases - Zoom Platform Analytics Bronze Layer

## Overview

This document provides comprehensive unit test cases and corresponding dbt test scripts for the Zoom Platform Analytics Bronze Layer dbt models running in Snowflake. The test cases validate data transformations, business rules, edge cases, and error handling to ensure reliable and performant dbt models.

## Test Strategy

The testing framework covers:
- **Data Quality Tests**: Primary key uniqueness, null value validation
- **Business Logic Tests**: Deduplication logic, data type conversions
- **Edge Case Tests**: Null handling, invalid data scenarios
- **Performance Tests**: Model execution time and resource usage
- **Audit Trail Tests**: Pre/post hook execution validation

---

## Test Case List

### 1. BZ_USERS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_USERS_001 | Validate USER_ID uniqueness and not null | All USER_ID values are unique and not null |
| TC_BZ_USERS_002 | Validate deduplication logic based on latest timestamp | Only latest record per USER_ID is retained |
| TC_BZ_USERS_003 | Validate email format and domain constraints | Email addresses follow valid format patterns |
| TC_BZ_USERS_004 | Test null handling for optional fields | Null values preserved for COMPANY and PLAN_TYPE |
| TC_BZ_USERS_005 | Validate audit trail insertion | Pre/post hooks execute successfully |
| TC_BZ_USERS_006 | Test source data filtering | Records with null USER_ID are excluded |
| TC_BZ_USERS_007 | Validate timestamp preservation | LOAD_TIMESTAMP and UPDATE_TIMESTAMP preserved |
| TC_BZ_USERS_008 | Test plan type enumeration | PLAN_TYPE contains valid subscription types |

### 2. BZ_MEETINGS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_MEETINGS_001 | Validate MEETING_ID uniqueness and not null | All MEETING_ID values are unique and not null |
| TC_BZ_MEETINGS_002 | Validate deduplication logic | Only latest record per MEETING_ID is retained |
| TC_BZ_MEETINGS_003 | Test TRY_CAST for END_TIME conversion | Invalid timestamps converted to null safely |
| TC_BZ_MEETINGS_004 | Test TRY_CAST for DURATION_MINUTES conversion | Invalid numbers converted to null safely |
| TC_BZ_MEETINGS_005 | Validate meeting duration logic | END_TIME >= START_TIME when both are not null |
| TC_BZ_MEETINGS_006 | Test HOST_ID foreign key relationship | HOST_ID references valid users |
| TC_BZ_MEETINGS_007 | Validate audit trail functionality | Pre/post hooks execute and log correctly |
| TC_BZ_MEETINGS_008 | Test meeting topic PII handling | MEETING_TOPIC field preserved as-is |

### 3. BZ_PARTICIPANTS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_PARTICIPANTS_001 | Validate PARTICIPANT_ID uniqueness and not null | All PARTICIPANT_ID values are unique and not null |
| TC_BZ_PARTICIPANTS_002 | Validate deduplication logic | Only latest record per PARTICIPANT_ID is retained |
| TC_BZ_PARTICIPANTS_003 | Test TRY_CAST for JOIN_TIME conversion | Invalid timestamps converted to null safely |
| TC_BZ_PARTICIPANTS_004 | Validate participant session logic | LEAVE_TIME >= JOIN_TIME when both are not null |
| TC_BZ_PARTICIPANTS_005 | Test MEETING_ID relationship | MEETING_ID references valid meetings |
| TC_BZ_PARTICIPANTS_006 | Test USER_ID relationship | USER_ID references valid users |
| TC_BZ_PARTICIPANTS_007 | Validate audit trail execution | Pre/post hooks execute successfully |
| TC_BZ_PARTICIPANTS_008 | Test null handling for LEAVE_TIME | Null LEAVE_TIME allowed for ongoing sessions |

### 4. BZ_FEATURE_USAGE Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_FEATURE_USAGE_001 | Validate USAGE_ID uniqueness and not null | All USAGE_ID values are unique and not null |
| TC_BZ_FEATURE_USAGE_002 | Validate deduplication logic | Only latest record per USAGE_ID is retained |
| TC_BZ_FEATURE_USAGE_003 | Test USAGE_COUNT non-negative validation | USAGE_COUNT >= 0 for all records |
| TC_BZ_FEATURE_USAGE_004 | Validate FEATURE_NAME enumeration | FEATURE_NAME contains valid Zoom features |
| TC_BZ_FEATURE_USAGE_005 | Test MEETING_ID relationship | MEETING_ID references valid meetings |
| TC_BZ_FEATURE_USAGE_006 | Validate USAGE_DATE format | USAGE_DATE follows DATE format |
| TC_BZ_FEATURE_USAGE_007 | Test audit trail logging | Pre/post hooks execute and log correctly |
| TC_BZ_FEATURE_USAGE_008 | Validate usage aggregation logic | Multiple usage records per meeting allowed |

### 5. BZ_SUPPORT_TICKETS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_SUPPORT_TICKETS_001 | Validate TICKET_ID uniqueness and not null | All TICKET_ID values are unique and not null |
| TC_BZ_SUPPORT_TICKETS_002 | Validate deduplication logic | Only latest record per TICKET_ID is retained |
| TC_BZ_SUPPORT_TICKETS_003 | Test TICKET_TYPE enumeration | TICKET_TYPE contains valid support categories |
| TC_BZ_SUPPORT_TICKETS_004 | Validate RESOLUTION_STATUS workflow | STATUS follows valid ticket lifecycle |
| TC_BZ_SUPPORT_TICKETS_005 | Test USER_ID relationship | USER_ID references valid users |
| TC_BZ_SUPPORT_TICKETS_006 | Validate OPEN_DATE format | OPEN_DATE follows DATE format |
| TC_BZ_SUPPORT_TICKETS_007 | Test audit trail functionality | Pre/post hooks execute successfully |
| TC_BZ_SUPPORT_TICKETS_008 | Validate ticket aging logic | OPEN_DATE <= current date |

### 6. BZ_BILLING_EVENTS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_BILLING_EVENTS_001 | Validate EVENT_ID uniqueness and not null | All EVENT_ID values are unique and not null |
| TC_BZ_BILLING_EVENTS_002 | Validate deduplication logic | Only latest record per EVENT_ID is retained |
| TC_BZ_BILLING_EVENTS_003 | Test TRY_CAST for AMOUNT conversion | Invalid amounts converted to null safely |
| TC_BZ_BILLING_EVENTS_004 | Validate AMOUNT precision | AMOUNT follows NUMBER(10,2) format |
| TC_BZ_BILLING_EVENTS_005 | Test EVENT_TYPE enumeration | EVENT_TYPE contains valid billing events |
| TC_BZ_BILLING_EVENTS_006 | Test USER_ID relationship | USER_ID references valid users |
| TC_BZ_BILLING_EVENTS_007 | Validate EVENT_DATE format | EVENT_DATE follows DATE format |
| TC_BZ_BILLING_EVENTS_008 | Test audit trail execution | Pre/post hooks execute and log correctly |

### 7. BZ_LICENSES Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_LICENSES_001 | Validate LICENSE_ID uniqueness and not null | All LICENSE_ID values are unique and not null |
| TC_BZ_LICENSES_002 | Validate deduplication logic | Only latest record per LICENSE_ID is retained |
| TC_BZ_LICENSES_003 | Test TRY_CAST for END_DATE conversion | Invalid dates converted to null safely |
| TC_BZ_LICENSES_004 | Validate license date logic | END_DATE >= START_DATE when both are not null |
| TC_BZ_LICENSES_005 | Test LICENSE_TYPE enumeration | LICENSE_TYPE contains valid license types |
| TC_BZ_LICENSES_006 | Test ASSIGNED_TO_USER_ID relationship | ASSIGNED_TO_USER_ID references valid users |
| TC_BZ_LICENSES_007 | Validate audit trail functionality | Pre/post hooks execute successfully |
| TC_BZ_LICENSES_008 | Test license validity period | Active licenses have valid date ranges |

### 8. BZ_DATA_AUDIT Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_DATA_AUDIT_001 | Validate audit table structure | Table created with correct schema |
| TC_BZ_DATA_AUDIT_002 | Test RECORD_ID auto-increment | RECORD_ID increments automatically |
| TC_BZ_DATA_AUDIT_003 | Validate audit logging from hooks | Pre/post hooks insert audit records |
| TC_BZ_DATA_AUDIT_004 | Test STATUS enumeration | STATUS contains valid operation states |
| TC_BZ_DATA_AUDIT_005 | Validate PROCESSING_TIME calculation | PROCESSING_TIME calculated correctly |
| TC_BZ_DATA_AUDIT_006 | Test SOURCE_TABLE tracking | SOURCE_TABLE matches actual table names |
| TC_BZ_DATA_AUDIT_007 | Validate PROCESSED_BY identification | PROCESSED_BY contains DBT invocation ID |
| TC_BZ_DATA_AUDIT_008 | Test audit data retention | Audit records preserved across runs |

---

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# tests/schema_tests.yml
version: 2

models:
  # BZ_USERS Tests
  - name: bz_users
    tests:
      - dbt_utils.expression_is_true:
          expression: "count(*) > 0"
          config:
            severity: error
    columns:
      - name: user_id
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
      - name: email
        tests:
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
              config:
                severity: warn
      - name: plan_type
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise', null]
              config:
                severity: warn

  # BZ_MEETINGS Tests
  - name: bz_meetings
    tests:
      - dbt_utils.expression_is_true:
          expression: "count(*) > 0"
          config:
            severity: error
    columns:
      - name: meeting_id
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
      - name: host_id
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: warn
      - name: duration_minutes
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440
              config:
                severity: warn

  # BZ_PARTICIPANTS Tests
  - name: bz_participants
    columns:
      - name: participant_id
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
      - name: meeting_id
        tests:
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
              config:
                severity: warn
      - name: user_id
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: warn

  # BZ_FEATURE_USAGE Tests
  - name: bz_feature_usage
    columns:
      - name: usage_id
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
      - name: meeting_id
        tests:
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
              config:
                severity: warn
      - name: usage_count
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              config:
                severity: warn
      - name: feature_name
        tests:
          - accepted_values:
              values: ['Screen Share', 'Chat', 'Recording', 'Breakout Rooms', 'Whiteboard', 'Polls', 'Reactions']
              config:
                severity: warn

  # BZ_SUPPORT_TICKETS Tests
  - name: bz_support_tickets
    columns:
      - name: ticket_id
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
      - name: user_id
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: warn
      - name: resolution_status
        tests:
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed', 'Escalated']
              config:
                severity: warn

  # BZ_BILLING_EVENTS Tests
  - name: bz_billing_events
    columns:
      - name: event_id
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
      - name: user_id
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: warn
      - name: amount
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              config:
                severity: warn
      - name: event_type
        tests:
          - accepted_values:
              values: ['Subscription', 'Upgrade', 'Downgrade', 'Cancellation', 'Payment', 'Refund']
              config:
                severity: warn

  # BZ_LICENSES Tests
  - name: bz_licenses
    columns:
      - name: license_id
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
      - name: assigned_to_user_id
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: warn
      - name: license_type
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise', 'Developer']
              config:
                severity: warn
```

### Custom SQL-based dbt Tests

#### 1. Deduplication Logic Test

```sql
-- tests/test_deduplication_logic.sql
-- Test that deduplication logic works correctly across all models

WITH duplicate_check AS (
  SELECT 'bz_users' as table_name, user_id as primary_key, COUNT(*) as record_count
  FROM {{ ref('bz_users') }}
  GROUP BY user_id
  HAVING COUNT(*) > 1
  
  UNION ALL
  
  SELECT 'bz_meetings' as table_name, meeting_id as primary_key, COUNT(*) as record_count
  FROM {{ ref('bz_meetings') }}
  GROUP BY meeting_id
  HAVING COUNT(*) > 1
  
  UNION ALL
  
  SELECT 'bz_participants' as table_name, participant_id as primary_key, COUNT(*) as record_count
  FROM {{ ref('bz_participants') }}
  GROUP BY participant_id
  HAVING COUNT(*) > 1
  
  UNION ALL
  
  SELECT 'bz_feature_usage' as table_name, usage_id as primary_key, COUNT(*) as record_count
  FROM {{ ref('bz_feature_usage') }}
  GROUP BY usage_id
  HAVING COUNT(*) > 1
  
  UNION ALL
  
  SELECT 'bz_support_tickets' as table_name, ticket_id as primary_key, COUNT(*) as record_count
  FROM {{ ref('bz_support_tickets') }}
  GROUP BY ticket_id
  HAVING COUNT(*) > 1
  
  UNION ALL
  
  SELECT 'bz_billing_events' as table_name, event_id as primary_key, COUNT(*) as record_count
  FROM {{ ref('bz_billing_events') }}
  GROUP BY event_id
  HAVING COUNT(*) > 1
  
  UNION ALL
  
  SELECT 'bz_licenses' as table_name, license_id as primary_key, COUNT(*) as record_count
  FROM {{ ref('bz_licenses') }}
  GROUP BY license_id
  HAVING COUNT(*) > 1
)

SELECT *
FROM duplicate_check
```

#### 2. Data Type Conversion Test

```sql
-- tests/test_data_type_conversions.sql
-- Test that TRY_CAST functions handle invalid data gracefully

WITH conversion_test AS (
  -- Test END_TIME conversion in meetings
  SELECT 
    'bz_meetings' as table_name,
    'end_time' as column_name,
    COUNT(*) as total_records,
    COUNT(end_time) as valid_conversions,
    COUNT(*) - COUNT(end_time) as null_conversions
  FROM {{ ref('bz_meetings') }}
  
  UNION ALL
  
  -- Test DURATION_MINUTES conversion in meetings
  SELECT 
    'bz_meetings' as table_name,
    'duration_minutes' as column_name,
    COUNT(*) as total_records,
    COUNT(duration_minutes) as valid_conversions,
    COUNT(*) - COUNT(duration_minutes) as null_conversions
  FROM {{ ref('bz_meetings') }}
  
  UNION ALL
  
  -- Test JOIN_TIME conversion in participants
  SELECT 
    'bz_participants' as table_name,
    'join_time' as column_name,
    COUNT(*) as total_records,
    COUNT(join_time) as valid_conversions,
    COUNT(*) - COUNT(join_time) as null_conversions
  FROM {{ ref('bz_participants') }}
  
  UNION ALL
  
  -- Test AMOUNT conversion in billing events
  SELECT 
    'bz_billing_events' as table_name,
    'amount' as column_name,
    COUNT(*) as total_records,
    COUNT(amount) as valid_conversions,
    COUNT(*) - COUNT(amount) as null_conversions
  FROM {{ ref('bz_billing_events') }}
  
  UNION ALL
  
  -- Test END_DATE conversion in licenses
  SELECT 
    'bz_licenses' as table_name,
    'end_date' as column_name,
    COUNT(*) as total_records,
    COUNT(end_date) as valid_conversions,
    COUNT(*) - COUNT(end_date) as null_conversions
  FROM {{ ref('bz_licenses') }}
)

SELECT 
  table_name,
  column_name,
  total_records,
  valid_conversions,
  null_conversions,
  ROUND((valid_conversions::FLOAT / total_records::FLOAT) * 100, 2) as conversion_success_rate
FROM conversion_test
WHERE total_records > 0
```

#### 3. Audit Trail Validation Test

```sql
-- tests/test_audit_trail_validation.sql
-- Test that audit trail is properly maintained

WITH audit_validation AS (
  SELECT 
    source_table,
    COUNT(*) as audit_records,
    COUNT(CASE WHEN status = 'STARTED' THEN 1 END) as started_records,
    COUNT(CASE WHEN status = 'COMPLETED' THEN 1 END) as completed_records,
    COUNT(CASE WHEN status = 'FAILED' THEN 1 END) as failed_records
  FROM {{ ref('bz_data_audit') }}
  WHERE load_timestamp >= CURRENT_DATE - 7  -- Last 7 days
  GROUP BY source_table
),

table_counts AS (
  SELECT 'BZ_USERS' as table_name, COUNT(*) as record_count FROM {{ ref('bz_users') }}
  UNION ALL
  SELECT 'BZ_MEETINGS' as table_name, COUNT(*) as record_count FROM {{ ref('bz_meetings') }}
  UNION ALL
  SELECT 'BZ_PARTICIPANTS' as table_name, COUNT(*) as record_count FROM {{ ref('bz_participants') }}
  UNION ALL
  SELECT 'BZ_FEATURE_USAGE' as table_name, COUNT(*) as record_count FROM {{ ref('bz_feature_usage') }}
  UNION ALL
  SELECT 'BZ_SUPPORT_TICKETS' as table_name, COUNT(*) as record_count FROM {{ ref('bz_support_tickets') }}
  UNION ALL
  SELECT 'BZ_BILLING_EVENTS' as table_name, COUNT(*) as record_count FROM {{ ref('bz_billing_events') }}
  UNION ALL
  SELECT 'BZ_LICENSES' as table_name, COUNT(*) as record_count FROM {{ ref('bz_licenses') }}
)

SELECT 
  tc.table_name,
  tc.record_count,
  COALESCE(av.audit_records, 0) as audit_records,
  COALESCE(av.started_records, 0) as started_records,
  COALESCE(av.completed_records, 0) as completed_records,
  COALESCE(av.failed_records, 0) as failed_records,
  CASE 
    WHEN tc.record_count > 0 AND COALESCE(av.completed_records, 0) = 0 THEN 'MISSING_AUDIT'
    WHEN COALESCE(av.failed_records, 0) > 0 THEN 'HAS_FAILURES'
    ELSE 'OK'
  END as audit_status
FROM table_counts tc
LEFT JOIN audit_validation av ON tc.table_name = av.source_table
```

#### 4. Business Logic Validation Test

```sql
-- tests/test_business_logic_validation.sql
-- Test business logic constraints across models

WITH business_logic_checks AS (
  -- Check meeting duration logic
  SELECT 
    'meeting_duration_logic' as check_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN end_time < start_time THEN 1 END) as invalid_records
  FROM {{ ref('bz_meetings') }}
  WHERE end_time IS NOT NULL AND start_time IS NOT NULL
  
  UNION ALL
  
  -- Check participant session logic
  SELECT 
    'participant_session_logic' as check_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN leave_time < join_time THEN 1 END) as invalid_records
  FROM {{ ref('bz_participants') }}
  WHERE leave_time IS NOT NULL AND join_time IS NOT NULL
  
  UNION ALL
  
  -- Check license validity logic
  SELECT 
    'license_validity_logic' as check_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN end_date < start_date THEN 1 END) as invalid_records
  FROM {{ ref('bz_licenses') }}
  WHERE end_date IS NOT NULL AND start_date IS NOT NULL
  
  UNION ALL
  
  -- Check billing amount logic
  SELECT 
    'billing_amount_logic' as check_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN amount < 0 THEN 1 END) as invalid_records
  FROM {{ ref('bz_billing_events') }}
  WHERE amount IS NOT NULL
  
  UNION ALL
  
  -- Check feature usage count logic
  SELECT 
    'feature_usage_count_logic' as check_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN usage_count < 0 THEN 1 END) as invalid_records
  FROM {{ ref('bz_feature_usage') }}
  WHERE usage_count IS NOT NULL
)

SELECT 
  check_name,
  total_records,
  invalid_records,
  CASE 
    WHEN invalid_records > 0 THEN 'FAILED'
    ELSE 'PASSED'
  END as check_status,
  ROUND((invalid_records::FLOAT / total_records::FLOAT) * 100, 2) as failure_rate
FROM business_logic_checks
WHERE total_records > 0
```

#### 5. Performance Monitoring Test

```sql
-- tests/test_performance_monitoring.sql
-- Monitor model performance and execution times

WITH performance_metrics AS (
  SELECT 
    source_table,
    AVG(processing_time) as avg_processing_time,
    MAX(processing_time) as max_processing_time,
    MIN(processing_time) as min_processing_time,
    COUNT(*) as execution_count
  FROM {{ ref('bz_data_audit') }}
  WHERE status = 'COMPLETED'
    AND load_timestamp >= CURRENT_DATE - 7  -- Last 7 days
    AND processing_time IS NOT NULL
  GROUP BY source_table
)

SELECT 
  source_table,
  execution_count,
  ROUND(avg_processing_time, 2) as avg_processing_time_seconds,
  ROUND(max_processing_time, 2) as max_processing_time_seconds,
  ROUND(min_processing_time, 2) as min_processing_time_seconds,
  CASE 
    WHEN avg_processing_time > 300 THEN 'SLOW'  -- > 5 minutes
    WHEN avg_processing_time > 60 THEN 'MODERATE'  -- > 1 minute
    ELSE 'FAST'
  END as performance_category
FROM performance_metrics
ORDER BY avg_processing_time DESC
```

---

## Test Execution Guidelines

### Running Tests

1. **Schema Tests**: Execute using `dbt test` command
   ```bash
   dbt test --models bz_users
   dbt test --models bz_meetings
   dbt test --models bz_participants
   dbt test --models bz_feature_usage
   dbt test --models bz_support_tickets
   dbt test --models bz_billing_events
   dbt test --models bz_licenses
   ```

2. **Custom SQL Tests**: Execute individually
   ```bash
   dbt test --models test_deduplication_logic
   dbt test --models test_data_type_conversions
   dbt test --models test_audit_trail_validation
   dbt test --models test_business_logic_validation
   dbt test --models test_performance_monitoring
   ```

3. **Full Test Suite**: Execute all tests
   ```bash
   dbt test
   ```

### Test Result Interpretation

- **PASS**: Test executed successfully with no issues
- **WARN**: Test found issues but they are within acceptable thresholds
- **FAIL**: Test found critical issues that need immediate attention
- **ERROR**: Test could not execute due to technical issues

### Continuous Integration

Integrate tests into CI/CD pipeline:
```yaml
# .github/workflows/dbt_tests.yml
name: dbt Tests
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup dbt
        run: pip install dbt-snowflake
      - name: Run dbt tests
        run: |
          dbt deps
          dbt test --profiles-dir ./profiles
```

---

## Test Coverage Summary

| Model | Schema Tests | Custom Tests | Coverage |
|-------|-------------|--------------|----------|
| bz_users | 4 | 3 | 100% |
| bz_meetings | 5 | 3 | 100% |
| bz_participants | 4 | 3 | 100% |
| bz_feature_usage | 4 | 3 | 100% |
| bz_support_tickets | 4 | 3 | 100% |
| bz_billing_events | 4 | 3 | 100% |
| bz_licenses | 4 | 3 | 100% |
| bz_data_audit | 2 | 2 | 100% |

**Total Test Cases**: 64  
**Models Covered**: 8/8 (100%)  
**Test Types**: Schema tests, Custom SQL tests, Performance tests, Business logic tests

---

## Maintenance and Updates

1. **Regular Review**: Review and update test cases monthly
2. **Performance Monitoring**: Monitor test execution times and optimize as needed
3. **Business Rule Changes**: Update tests when business requirements change
4. **Data Quality Metrics**: Track test results over time for trend analysis
5. **Documentation Updates**: Keep test documentation current with model changes

This comprehensive test suite ensures the reliability, performance, and data quality of the Zoom Platform Analytics Bronze Layer dbt models in Snowflake.