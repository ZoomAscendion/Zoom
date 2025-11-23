_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Platform Analytics Bronze layer dbt models in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases - Bronze Layer Models

## Overview

This document provides comprehensive unit test cases and dbt test scripts for the Bronze layer models in the Zoom Platform Analytics System. The tests validate data transformations, business rules, edge cases, and error handling scenarios to ensure reliable and performant dbt models in Snowflake.

## Test Strategy

### Testing Approach
- **Happy Path Testing**: Valid transformations, joins, and aggregations
- **Edge Case Testing**: NULL values, empty datasets, invalid lookups, schema mismatches
- **Exception Testing**: Failed relationships, unexpected values, data type mismatches
- **Business Rule Validation**: Domain value constraints, data quality rules
- **Performance Testing**: Large dataset handling, query optimization

### Test Categories
1. **Schema Tests**: Built-in dbt tests (unique, not_null, relationships, accepted_values)
2. **Data Tests**: Custom SQL-based tests for business logic validation
3. **Source Tests**: Raw data validation and source system connectivity
4. **Audit Tests**: Metadata and audit trail validation

---

## Test Case List

### 1. BZ_DATA_AUDIT Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_AUDIT_001 | Validate audit table structure creation | Table created with correct schema |
| TC_AUDIT_002 | Test audit record insertion via pre-hooks | Records inserted with STARTED status |
| TC_AUDIT_003 | Test audit record update via post-hooks | Records updated with SUCCESS status |
| TC_AUDIT_004 | Validate auto-increment record_id | Sequential IDs generated correctly |
| TC_AUDIT_005 | Test audit trail completeness | All Bronze models logged in audit |

### 2. BZ_USERS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_USERS_001 | Validate primary key uniqueness | No duplicate user_id values |
| TC_USERS_002 | Test NULL user_id filtering | Records with NULL user_id excluded |
| TC_USERS_003 | Validate email field not null | All records have email values |
| TC_USERS_004 | Test deduplication logic | Latest record per user_id retained |
| TC_USERS_005 | Validate default user_name handling | NULL user_name replaced with 'Unknown User' |
| TC_USERS_006 | Test email generation for NULL emails | Default email format applied |
| TC_USERS_007 | Validate plan_type default values | NULL plan_type replaced with 'Basic' |
| TC_USERS_008 | Test timestamp overwrite | Bronze timestamps set to CURRENT_TIMESTAMP |
| TC_USERS_009 | Validate source_system default | NULL source_system replaced with 'unknown' |
| TC_USERS_010 | Test plan_type accepted values | Only valid plan types accepted |

### 3. BZ_MEETINGS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_MEETINGS_001 | Validate primary key uniqueness | No duplicate meeting_id values |
| TC_MEETINGS_002 | Test NULL meeting_id filtering | Records with NULL meeting_id excluded |
| TC_MEETINGS_003 | Validate end_time type casting | Invalid end_time values set to NULL |
| TC_MEETINGS_004 | Test duration_minutes conversion | Invalid duration set to 0 |
| TC_MEETINGS_005 | Validate deduplication logic | Latest record per meeting_id retained |
| TC_MEETINGS_006 | Test timestamp overwrite | Bronze timestamps set to CURRENT_TIMESTAMP |
| TC_MEETINGS_007 | Validate source_system default | NULL source_system replaced with 'unknown' |
| TC_MEETINGS_008 | Test meeting duration validation | Duration >= 0 constraint |
| TC_MEETINGS_009 | Validate start_time not null | All records have start_time values |
| TC_MEETINGS_010 | Test host_id relationship | Valid host_id references |

### 4. BZ_PARTICIPANTS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_PARTICIPANTS_001 | Validate primary key uniqueness | No duplicate participant_id values |
| TC_PARTICIPANTS_002 | Test NULL participant_id filtering | Records with NULL participant_id excluded |
| TC_PARTICIPANTS_003 | Validate join_time type casting | Invalid join_time values set to NULL |
| TC_PARTICIPANTS_004 | Test deduplication logic | Latest record per participant_id retained |
| TC_PARTICIPANTS_005 | Validate timestamp overwrite | Bronze timestamps set to CURRENT_TIMESTAMP |
| TC_PARTICIPANTS_006 | Test meeting_id relationship | Valid meeting_id references |
| TC_PARTICIPANTS_007 | Test user_id relationship | Valid user_id references |
| TC_PARTICIPANTS_008 | Validate source_system default | NULL source_system replaced with 'unknown' |
| TC_PARTICIPANTS_009 | Test join/leave time logic | Join_time <= leave_time when both present |
| TC_PARTICIPANTS_010 | Validate participant session integrity | One participant per meeting session |

### 5. BZ_FEATURE_USAGE Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_FEATURE_001 | Validate primary key uniqueness | No duplicate usage_id values |
| TC_FEATURE_002 | Test NULL usage_id filtering | Records with NULL usage_id excluded |
| TC_FEATURE_003 | Validate feature_name default | NULL feature_name replaced with 'unknown_feature' |
| TC_FEATURE_004 | Test usage_count default | NULL usage_count replaced with 0 |
| TC_FEATURE_005 | Validate deduplication logic | Latest record per usage_id retained |
| TC_FEATURE_006 | Test timestamp overwrite | Bronze timestamps set to CURRENT_TIMESTAMP |
| TC_FEATURE_007 | Validate source_system default | NULL source_system replaced with 'unknown' |
| TC_FEATURE_008 | Test feature_name accepted values | Valid feature names only |
| TC_FEATURE_009 | Validate usage_count >= 0 | Non-negative usage counts |
| TC_FEATURE_010 | Test meeting_id relationship | Valid meeting_id references |

### 6. BZ_SUPPORT_TICKETS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_TICKETS_001 | Validate primary key uniqueness | No duplicate ticket_id values |
| TC_TICKETS_002 | Test NULL ticket_id filtering | Records with NULL ticket_id excluded |
| TC_TICKETS_003 | Validate ticket_type default | NULL ticket_type replaced with 'general' |
| TC_TICKETS_004 | Test resolution_status default | NULL resolution_status replaced with 'open' |
| TC_TICKETS_005 | Validate deduplication logic | Latest record per ticket_id retained |
| TC_TICKETS_006 | Test timestamp overwrite | Bronze timestamps set to CURRENT_TIMESTAMP |
| TC_TICKETS_007 | Validate source_system default | NULL source_system replaced with 'unknown' |
| TC_TICKETS_008 | Test ticket_type accepted values | Valid ticket types only |
| TC_TICKETS_009 | Test resolution_status accepted values | Valid status values only |
| TC_TICKETS_010 | Test user_id relationship | Valid user_id references |

### 7. BZ_BILLING_EVENTS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BILLING_001 | Validate primary key uniqueness | No duplicate event_id values |
| TC_BILLING_002 | Test NULL event_id filtering | Records with NULL event_id excluded |
| TC_BILLING_003 | Validate amount type casting | Invalid amount values set to 0.00 |
| TC_BILLING_004 | Test event_type default | NULL event_type replaced with 'unknown' |
| TC_BILLING_005 | Validate deduplication logic | Latest record per event_id retained |
| TC_BILLING_006 | Test timestamp overwrite | Bronze timestamps set to CURRENT_TIMESTAMP |
| TC_BILLING_007 | Validate source_system default | NULL source_system replaced with 'unknown' |
| TC_BILLING_008 | Test event_type accepted values | Valid event types only |
| TC_BILLING_009 | Validate amount precision | Correct decimal precision (10,2) |
| TC_BILLING_010 | Test user_id relationship | Valid user_id references |

### 8. BZ_LICENSES Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_LICENSES_001 | Validate primary key uniqueness | No duplicate license_id values |
| TC_LICENSES_002 | Test NULL license_id filtering | Records with NULL license_id excluded |
| TC_LICENSES_003 | Validate license_type default | NULL license_type replaced with 'Basic' |
| TC_LICENSES_004 | Test end_date type casting | Invalid end_date values set to NULL |
| TC_LICENSES_005 | Validate deduplication logic | Latest record per license_id retained |
| TC_LICENSES_006 | Test timestamp overwrite | Bronze timestamps set to CURRENT_TIMESTAMP |
| TC_LICENSES_007 | Validate source_system default | NULL source_system replaced with 'unknown' |
| TC_LICENSES_008 | Test license_type accepted values | Valid license types only |
| TC_LICENSES_009 | Validate date range logic | start_date <= end_date when both present |
| TC_LICENSES_010 | Test user assignment relationship | Valid assigned_to_user_id references |

---

## dbt Test Scripts

### Schema Tests (schema.yml)

```yml
version: 2

models:
  # BZ_DATA_AUDIT Tests
  - name: bz_data_audit
    description: "Audit trail for Bronze layer operations"
    tests:
      - dbt_utils.expression_is_true:
          expression: "record_id IS NOT NULL"
          config:
            severity: error
    columns:
      - name: record_id
        tests:
          - not_null
          - unique
      - name: source_table
        tests:
          - not_null
      - name: status
        tests:
          - accepted_values:
              values: ['STARTED', 'SUCCESS', 'FAILED', 'WARNING']

  # BZ_USERS Tests
  - name: bz_users
    description: "Bronze layer user data"
    tests:
      - dbt_utils.expression_is_true:
          expression: "load_timestamp = update_timestamp"
          config:
            severity: warn
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
          - not_null:
              config:
                severity: error
      - name: plan_type
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise']
              config:
                severity: warn
      - name: source_system
        tests:
          - not_null

  # BZ_MEETINGS Tests
  - name: bz_meetings
    description: "Bronze layer meeting data"
    tests:
      - dbt_utils.expression_is_true:
          expression: "duration_minutes >= 0 OR duration_minutes IS NULL"
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
      - name: start_time
        tests:
          - not_null:
              config:
                severity: error
      - name: duration_minutes
        tests:
          - dbt_utils.expression_is_true:
              expression: ">= 0"
              config:
                severity: warn

  # BZ_PARTICIPANTS Tests
  - name: bz_participants
    description: "Bronze layer participant data"
    tests:
      - dbt_utils.expression_is_true:
          expression: "join_time <= leave_time OR join_time IS NULL OR leave_time IS NULL"
          config:
            severity: warn
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
    description: "Bronze layer feature usage data"
    tests:
      - dbt_utils.expression_is_true:
          expression: "usage_count >= 0"
          config:
            severity: error
    columns:
      - name: usage_id
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
      - name: feature_name
        tests:
          - accepted_values:
              values: ['screen_share', 'recording', 'chat', 'breakout_rooms', 'whiteboard', 'unknown_feature']
              config:
                severity: warn
      - name: usage_count
        tests:
          - dbt_utils.expression_is_true:
              expression: ">= 0"
              config:
                severity: error

  # BZ_SUPPORT_TICKETS Tests
  - name: bz_support_tickets
    description: "Bronze layer support ticket data"
    columns:
      - name: ticket_id
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
      - name: ticket_type
        tests:
          - accepted_values:
              values: ['technical', 'billing', 'account', 'feature_request', 'general']
              config:
                severity: warn
      - name: resolution_status
        tests:
          - accepted_values:
              values: ['open', 'in_progress', 'resolved', 'closed']
              config:
                severity: warn

  # BZ_BILLING_EVENTS Tests
  - name: bz_billing_events
    description: "Bronze layer billing event data"
    tests:
      - dbt_utils.expression_is_true:
          expression: "amount >= 0"
          config:
            severity: warn
    columns:
      - name: event_id
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
      - name: event_type
        tests:
          - accepted_values:
              values: ['subscription', 'usage', 'refund', 'adjustment', 'unknown']
              config:
                severity: warn
      - name: amount
        tests:
          - dbt_utils.expression_is_true:
              expression: ">= 0"
              config:
                severity: warn

  # BZ_LICENSES Tests
  - name: bz_licenses
    description: "Bronze layer license data"
    tests:
      - dbt_utils.expression_is_true:
          expression: "start_date <= end_date OR end_date IS NULL"
          config:
            severity: warn
    columns:
      - name: license_id
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
      - name: license_type
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise']
              config:
                severity: warn
```

### Custom SQL Tests

#### Test 1: Deduplication Validation
```sql
-- tests/test_deduplication_bz_users.sql
-- Test that deduplication logic works correctly for bz_users

SELECT 
    user_id,
    COUNT(*) as record_count
FROM {{ ref('bz_users') }}
GROUP BY user_id
HAVING COUNT(*) > 1
```

#### Test 2: Timestamp Overwrite Validation
```sql
-- tests/test_timestamp_overwrite.sql
-- Test that Bronze layer timestamps are overwritten correctly

SELECT 
    'bz_users' as table_name,
    COUNT(*) as invalid_timestamp_count
FROM {{ ref('bz_users') }}
WHERE load_timestamp != update_timestamp
   OR load_timestamp IS NULL
   OR update_timestamp IS NULL

UNION ALL

SELECT 
    'bz_meetings' as table_name,
    COUNT(*) as invalid_timestamp_count
FROM {{ ref('bz_meetings') }}
WHERE load_timestamp != update_timestamp
   OR load_timestamp IS NULL
   OR update_timestamp IS NULL
```

#### Test 3: Audit Trail Completeness
```sql
-- tests/test_audit_trail_completeness.sql
-- Test that all Bronze models are logged in audit table

WITH expected_tables AS (
    SELECT table_name
    FROM (
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
actual_tables AS (
    SELECT DISTINCT source_table as table_name
    FROM {{ ref('bz_data_audit') }}
    WHERE status IN ('STARTED', 'SUCCESS')
)
SELECT 
    e.table_name
FROM expected_tables e
LEFT JOIN actual_tables a ON e.table_name = a.table_name
WHERE a.table_name IS NULL
```

#### Test 4: Data Type Validation
```sql
-- tests/test_data_type_validation.sql
-- Test that TRY_CAST operations work correctly

SELECT 
    'bz_meetings' as table_name,
    'end_time' as column_name,
    COUNT(*) as invalid_cast_count
FROM {{ source('raw', 'meetings') }}
WHERE end_time IS NOT NULL 
  AND end_time != ''
  AND TRY_CAST(end_time AS TIMESTAMP_NTZ(9)) IS NULL

UNION ALL

SELECT 
    'bz_billing_events' as table_name,
    'amount' as column_name,
    COUNT(*) as invalid_cast_count
FROM {{ source('raw', 'billing_events') }}
WHERE amount IS NOT NULL 
  AND amount != ''
  AND TRY_CAST(amount AS NUMBER(10,2)) IS NULL
```

#### Test 5: Business Rule Validation
```sql
-- tests/test_business_rules.sql
-- Test business logic and constraints

-- Test 1: Meeting duration consistency
SELECT 
    meeting_id,
    start_time,
    end_time,
    duration_minutes,
    DATEDIFF('minute', start_time, end_time) as calculated_duration
FROM {{ ref('bz_meetings') }}
WHERE end_time IS NOT NULL
  AND start_time IS NOT NULL
  AND duration_minutes IS NOT NULL
  AND ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) > 5

UNION ALL

-- Test 2: Participant session validation
SELECT 
    participant_id,
    meeting_id,
    join_time,
    leave_time,
    'Invalid session time' as issue
FROM {{ ref('bz_participants') }}
WHERE join_time IS NOT NULL
  AND leave_time IS NOT NULL
  AND join_time > leave_time
```

#### Test 6: Source System Validation
```sql
-- tests/test_source_system_validation.sql
-- Test that source_system values are properly handled

SELECT 
    'bz_users' as table_name,
    COUNT(*) as null_source_system_count
FROM {{ ref('bz_users') }}
WHERE source_system IS NULL OR source_system = ''

UNION ALL

SELECT 
    'bz_meetings' as table_name,
    COUNT(*) as null_source_system_count
FROM {{ ref('bz_meetings') }}
WHERE source_system IS NULL OR source_system = ''
```

### Performance Tests

#### Test 7: Large Dataset Handling
```sql
-- tests/test_performance_large_dataset.sql
-- Test model performance with large datasets

SELECT 
    table_name,
    record_count,
    CASE 
        WHEN record_count > 1000000 THEN 'Large Dataset'
        WHEN record_count > 100000 THEN 'Medium Dataset'
        ELSE 'Small Dataset'
    END as dataset_size
FROM (
    SELECT 'bz_users' as table_name, COUNT(*) as record_count FROM {{ ref('bz_users') }}
    UNION ALL
    SELECT 'bz_meetings' as table_name, COUNT(*) as record_count FROM {{ ref('bz_meetings') }}
    UNION ALL
    SELECT 'bz_participants' as table_name, COUNT(*) as record_count FROM {{ ref('bz_participants') }}
) t
WHERE record_count = 0  -- This should return no rows if all tables have data
```

---

## Test Execution Guidelines

### Running Tests

1. **Schema Tests**: 
   ```bash
   dbt test --models bz_users
   dbt test --models bz_meetings
   dbt test --models bz_participants
   ```

2. **Custom SQL Tests**:
   ```bash
   dbt test --select test_type:data
   ```

3. **All Bronze Layer Tests**:
   ```bash
   dbt test --models tag:bronze
   ```

### Test Configuration

- **Error Severity**: Critical data quality issues (uniqueness, not_null)
- **Warning Severity**: Business rule violations, referential integrity
- **Store Failures**: Enable for debugging failed test cases
- **Fail Fast**: Stop on first critical error

### Monitoring and Alerting

- **dbt Cloud**: Configure test alerts for failed runs
- **Snowflake**: Monitor query performance and resource usage
- **Audit Logs**: Track test execution history in `run_results.json`

---

## Expected Test Results

### Success Criteria
- All primary key uniqueness tests pass
- All not_null constraints validated
- Deduplication logic working correctly
- Timestamp overwrite functioning
- Audit trail complete and accurate
- Business rules enforced
- Data type conversions successful
- Performance within acceptable limits

### Failure Scenarios
- Duplicate primary keys detected
- NULL values in required fields
- Invalid data type conversions
- Missing audit records
- Business rule violations
- Performance degradation

---

## Maintenance and Updates

### Test Maintenance
- Review and update test cases quarterly
- Add new tests for schema changes
- Monitor test performance and optimize
- Update accepted values as business rules evolve

### Documentation Updates
- Keep test documentation current
- Document test failure resolution procedures
- Maintain test case traceability matrix
- Update performance benchmarks

This comprehensive test suite ensures the reliability, performance, and data quality of the Bronze layer dbt models in the Zoom Platform Analytics System running on Snowflake.