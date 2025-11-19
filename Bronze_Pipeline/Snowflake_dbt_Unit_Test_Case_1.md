_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Bronze Layer dbt models in Snowflake
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Zoom Bronze Layer Pipeline

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Bronze Layer dbt models running in Snowflake. The test coverage includes data quality validation, business rule verification, edge case handling, and error scenarios across all Bronze layer models including bz_users, bz_meetings, bz_participants, bz_feature_usage, bz_support_tickets, bz_billing_events, bz_licenses, and bz_data_audit.

## Test Strategy Overview

The testing approach covers:
- **Data Quality Tests**: Primary key uniqueness, null value validation, data type integrity
- **Business Logic Tests**: Deduplication logic, audit trail functionality, data transformations
- **Edge Case Tests**: Empty datasets, invalid data types, boundary conditions
- **Integration Tests**: Cross-model relationships and referential integrity
- **Performance Tests**: Model execution time and resource utilization

---

## Test Case List

### 1. BZ_USERS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_USERS_001 | Validate USER_ID uniqueness and not null | All USER_ID values are unique and not null |
| TC_BZ_USERS_002 | Validate EMAIL not null constraint | All EMAIL values are not null |
| TC_BZ_USERS_003 | Test deduplication logic with multiple records | Only latest record per USER_ID based on LOAD_TIMESTAMP |
| TC_BZ_USERS_004 | Validate data type casting and transformations | All data types match target schema specifications |
| TC_BZ_USERS_005 | Test handling of null primary keys in source | Records with null USER_ID are filtered out |
| TC_BZ_USERS_006 | Validate PLAN_TYPE accepted values | Only valid plan types are present |
| TC_BZ_USERS_007 | Test audit trail integration | Pre and post hooks execute successfully |

### 2. BZ_MEETINGS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_MEETINGS_001 | Validate MEETING_ID uniqueness and not null | All MEETING_ID values are unique and not null |
| TC_BZ_MEETINGS_002 | Validate HOST_ID not null constraint | All HOST_ID values are not null |
| TC_BZ_MEETINGS_003 | Test END_TIME data type casting with TRY_CAST | Invalid timestamps converted to null without errors |
| TC_BZ_MEETINGS_004 | Test DURATION_MINUTES numeric conversion | Invalid numeric values converted to null |
| TC_BZ_MEETINGS_005 | Validate meeting duration logic | END_TIME >= START_TIME when both are not null |
| TC_BZ_MEETINGS_006 | Test deduplication with same MEETING_ID | Latest record retained based on LOAD_TIMESTAMP |
| TC_BZ_MEETINGS_007 | Validate referential integrity with participants | All HOST_ID values exist in bz_users |

### 3. BZ_PARTICIPANTS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_PARTICIPANTS_001 | Validate PARTICIPANT_ID uniqueness | All PARTICIPANT_ID values are unique and not null |
| TC_BZ_PARTICIPANTS_002 | Validate MEETING_ID and USER_ID not null | All foreign key values are not null |
| TC_BZ_PARTICIPANTS_003 | Test JOIN_TIME timestamp casting | Invalid timestamps handled gracefully |
| TC_BZ_PARTICIPANTS_004 | Validate participant session logic | LEAVE_TIME >= JOIN_TIME when both are not null |
| TC_BZ_PARTICIPANTS_005 | Test referential integrity with meetings | All MEETING_ID values exist in bz_meetings |
| TC_BZ_PARTICIPANTS_006 | Test referential integrity with users | All USER_ID values exist in bz_users |
| TC_BZ_PARTICIPANTS_007 | Validate deduplication logic | Latest participant record per PARTICIPANT_ID |

### 4. BZ_FEATURE_USAGE Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_FEATURE_USAGE_001 | Validate USAGE_ID uniqueness | All USAGE_ID values are unique and not null |
| TC_BZ_FEATURE_USAGE_002 | Validate MEETING_ID not null | All MEETING_ID values are not null |
| TC_BZ_FEATURE_USAGE_003 | Test USAGE_COUNT data validation | USAGE_COUNT values are non-negative integers |
| TC_BZ_FEATURE_USAGE_004 | Validate FEATURE_NAME standardization | Feature names follow consistent naming convention |
| TC_BZ_FEATURE_USAGE_005 | Test date range validation | USAGE_DATE is within reasonable business range |
| TC_BZ_FEATURE_USAGE_006 | Validate meeting relationship | All MEETING_ID values exist in bz_meetings |
| TC_BZ_FEATURE_USAGE_007 | Test aggregation accuracy | Usage counts aggregate correctly per meeting |

### 5. BZ_SUPPORT_TICKETS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_SUPPORT_TICKETS_001 | Validate TICKET_ID uniqueness | All TICKET_ID values are unique and not null |
| TC_BZ_SUPPORT_TICKETS_002 | Validate USER_ID not null | All USER_ID values are not null |
| TC_BZ_SUPPORT_TICKETS_003 | Test TICKET_TYPE accepted values | Only valid ticket types are present |
| TC_BZ_SUPPORT_TICKETS_004 | Validate RESOLUTION_STATUS values | Only valid status values are present |
| TC_BZ_SUPPORT_TICKETS_005 | Test date validation | OPEN_DATE is not in future |
| TC_BZ_SUPPORT_TICKETS_006 | Validate user relationship | All USER_ID values exist in bz_users |
| TC_BZ_SUPPORT_TICKETS_007 | Test ticket lifecycle logic | Status transitions follow business rules |

### 6. BZ_BILLING_EVENTS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_BILLING_EVENTS_001 | Validate EVENT_ID uniqueness | All EVENT_ID values are unique and not null |
| TC_BZ_BILLING_EVENTS_002 | Validate USER_ID not null | All USER_ID values are not null |
| TC_BZ_BILLING_EVENTS_003 | Test AMOUNT numeric conversion | AMOUNT values cast to NUMBER(10,2) correctly |
| TC_BZ_BILLING_EVENTS_004 | Validate EVENT_TYPE accepted values | Only valid event types are present |
| TC_BZ_BILLING_EVENTS_005 | Test amount validation | AMOUNT values are within reasonable range |
| TC_BZ_BILLING_EVENTS_006 | Validate user relationship | All USER_ID values exist in bz_users |
| TC_BZ_BILLING_EVENTS_007 | Test financial data accuracy | Sum of amounts matches expected totals |

### 7. BZ_LICENSES Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_LICENSES_001 | Validate LICENSE_ID uniqueness | All LICENSE_ID values are unique and not null |
| TC_BZ_LICENSES_002 | Validate LICENSE_TYPE not null | All LICENSE_TYPE values are not null |
| TC_BZ_LICENSES_003 | Test END_DATE casting with TRY_CAST | Invalid dates converted to null without errors |
| TC_BZ_LICENSES_004 | Validate license period logic | END_DATE >= START_DATE when both are not null |
| TC_BZ_LICENSES_005 | Test LICENSE_TYPE accepted values | Only valid license types are present |
| TC_BZ_LICENSES_006 | Validate user assignment | ASSIGNED_TO_USER_ID exists in bz_users when not null |
| TC_BZ_LICENSES_007 | Test license overlap detection | No overlapping active licenses per user |

### 8. BZ_DATA_AUDIT Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_AUDIT_001 | Validate audit record creation | Audit records created for each model execution |
| TC_BZ_AUDIT_002 | Test RECORD_ID auto-increment | RECORD_ID values are unique and sequential |
| TC_BZ_AUDIT_003 | Validate STATUS values | Only valid status values (STARTED, COMPLETED, FAILED) |
| TC_BZ_AUDIT_004 | Test processing time calculation | PROCESSING_TIME calculated correctly |
| TC_BZ_AUDIT_005 | Validate timestamp accuracy | LOAD_TIMESTAMP reflects actual execution time |
| TC_BZ_AUDIT_006 | Test audit trail completeness | All model executions have corresponding audit records |
| TC_BZ_AUDIT_007 | Validate error handling | Failed executions properly logged |

---

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# tests/schema_tests.yml
version: 2

models:
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
          - not_null:
              config:
                severity: error
          - dbt_utils.expression_is_true:
              expression: "email LIKE '%@%'"
              config:
                severity: warn
      - name: plan_type
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise']
              config:
                severity: warn

  - name: bz_meetings
    tests:
      - dbt_utils.expression_is_true:
          expression: "count(*) > 0"
    columns:
      - name: meeting_id
        tests:
          - not_null
          - unique
      - name: host_id
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: error
      - name: duration_minutes
        tests:
          - dbt_utils.expression_is_true:
              expression: "duration_minutes >= 0 OR duration_minutes IS NULL"

  - name: bz_participants
    columns:
      - name: participant_id
        tests:
          - not_null
          - unique
      - name: meeting_id
        tests:
          - not_null
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
      - name: user_id
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id

  - name: bz_feature_usage
    columns:
      - name: usage_id
        tests:
          - not_null
          - unique
      - name: meeting_id
        tests:
          - not_null
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
      - name: usage_count
        tests:
          - dbt_utils.expression_is_true:
              expression: "usage_count >= 0"

  - name: bz_support_tickets
    columns:
      - name: ticket_id
        tests:
          - not_null
          - unique
      - name: user_id
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: resolution_status
        tests:
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed']

  - name: bz_billing_events
    columns:
      - name: event_id
        tests:
          - not_null
          - unique
      - name: user_id
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: amount
        tests:
          - dbt_utils.expression_is_true:
              expression: "amount >= 0 OR amount IS NULL"

  - name: bz_licenses
    columns:
      - name: license_id
        tests:
          - not_null
          - unique
      - name: license_type
        tests:
          - not_null
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise']
      - name: assigned_to_user_id
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                where: "assigned_to_user_id IS NOT NULL"

  - name: bz_data_audit
    columns:
      - name: record_id
        tests:
          - not_null
          - unique
      - name: status
        tests:
          - accepted_values:
              values: ['STARTED', 'COMPLETED', 'FAILED', 'INITIALIZED']
```

### Custom SQL-based dbt Tests

#### Test 1: Deduplication Logic Validation
```sql
-- tests/test_deduplication_logic.sql
-- Test that deduplication logic works correctly across all models

WITH duplicate_check AS (
  SELECT 'bz_users' as model_name, user_id as primary_key, COUNT(*) as record_count
  FROM {{ ref('bz_users') }}
  GROUP BY user_id
  HAVING COUNT(*) > 1
  
  UNION ALL
  
  SELECT 'bz_meetings' as model_name, meeting_id as primary_key, COUNT(*) as record_count
  FROM {{ ref('bz_meetings') }}
  GROUP BY meeting_id
  HAVING COUNT(*) > 1
  
  UNION ALL
  
  SELECT 'bz_participants' as model_name, participant_id as primary_key, COUNT(*) as record_count
  FROM {{ ref('bz_participants') }}
  GROUP BY participant_id
  HAVING COUNT(*) > 1
)

SELECT *
FROM duplicate_check
```

#### Test 2: Audit Trail Completeness
```sql
-- tests/test_audit_trail_completeness.sql
-- Verify that audit records exist for all model executions

WITH expected_models AS (
  SELECT 'BZ_USERS' as model_name
  UNION ALL SELECT 'BZ_MEETINGS'
  UNION ALL SELECT 'BZ_PARTICIPANTS'
  UNION ALL SELECT 'BZ_FEATURE_USAGE'
  UNION ALL SELECT 'BZ_SUPPORT_TICKETS'
  UNION ALL SELECT 'BZ_BILLING_EVENTS'
  UNION ALL SELECT 'BZ_LICENSES'
),

audit_records AS (
  SELECT DISTINCT source_table as model_name
  FROM {{ ref('bz_data_audit') }}
  WHERE status IN ('STARTED', 'COMPLETED')
    AND load_timestamp >= CURRENT_DATE - 1
)

SELECT em.model_name
FROM expected_models em
LEFT JOIN audit_records ar ON em.model_name = ar.model_name
WHERE ar.model_name IS NULL
```

#### Test 3: Data Freshness Validation
```sql
-- tests/test_data_freshness.sql
-- Ensure data is not stale (loaded within last 24 hours)

WITH freshness_check AS (
  SELECT 'bz_users' as model_name, MAX(load_timestamp) as latest_load
  FROM {{ ref('bz_users') }}
  
  UNION ALL
  
  SELECT 'bz_meetings' as model_name, MAX(load_timestamp) as latest_load
  FROM {{ ref('bz_meetings') }}
  
  UNION ALL
  
  SELECT 'bz_participants' as model_name, MAX(load_timestamp) as latest_load
  FROM {{ ref('bz_participants') }}
)

SELECT model_name, latest_load
FROM freshness_check
WHERE latest_load < CURRENT_TIMESTAMP - INTERVAL '24 HOURS'
   OR latest_load IS NULL
```

#### Test 4: Cross-Model Referential Integrity
```sql
-- tests/test_referential_integrity.sql
-- Validate foreign key relationships across models

WITH integrity_violations AS (
  -- Check meetings.host_id -> users.user_id
  SELECT 'meetings_to_users' as violation_type, m.host_id as orphan_key
  FROM {{ ref('bz_meetings') }} m
  LEFT JOIN {{ ref('bz_users') }} u ON m.host_id = u.user_id
  WHERE u.user_id IS NULL AND m.host_id IS NOT NULL
  
  UNION ALL
  
  -- Check participants.meeting_id -> meetings.meeting_id
  SELECT 'participants_to_meetings' as violation_type, p.meeting_id as orphan_key
  FROM {{ ref('bz_participants') }} p
  LEFT JOIN {{ ref('bz_meetings') }} m ON p.meeting_id = m.meeting_id
  WHERE m.meeting_id IS NULL AND p.meeting_id IS NOT NULL
  
  UNION ALL
  
  -- Check participants.user_id -> users.user_id
  SELECT 'participants_to_users' as violation_type, p.user_id as orphan_key
  FROM {{ ref('bz_participants') }} p
  LEFT JOIN {{ ref('bz_users') }} u ON p.user_id = u.user_id
  WHERE u.user_id IS NULL AND p.user_id IS NOT NULL
)

SELECT *
FROM integrity_violations
```

#### Test 5: Business Logic Validation
```sql
-- tests/test_business_logic.sql
-- Validate business rules and logic constraints

WITH business_rule_violations AS (
  -- Meeting duration should be positive
  SELECT 'negative_meeting_duration' as violation_type, meeting_id as record_id
  FROM {{ ref('bz_meetings') }}
  WHERE duration_minutes < 0
  
  UNION ALL
  
  -- Participant leave time should be after join time
  SELECT 'invalid_participant_session' as violation_type, participant_id as record_id
  FROM {{ ref('bz_participants') }}
  WHERE leave_time < join_time
    AND leave_time IS NOT NULL 
    AND join_time IS NOT NULL
  
  UNION ALL
  
  -- License end date should be after start date
  SELECT 'invalid_license_period' as violation_type, license_id as record_id
  FROM {{ ref('bz_licenses') }}
  WHERE end_date < start_date
    AND end_date IS NOT NULL
    AND start_date IS NOT NULL
  
  UNION ALL
  
  -- Billing amounts should not be negative for charges
  SELECT 'negative_billing_amount' as violation_type, event_id as record_id
  FROM {{ ref('bz_billing_events') }}
  WHERE amount < 0 AND event_type = 'charge'
)

SELECT *
FROM business_rule_violations
```

#### Test 6: Data Type and Format Validation
```sql
-- tests/test_data_formats.sql
-- Validate data formats and types

WITH format_violations AS (
  -- Email format validation
  SELECT 'invalid_email_format' as violation_type, user_id as record_id, email as invalid_value
  FROM {{ ref('bz_users') }}
  WHERE email IS NOT NULL 
    AND email NOT LIKE '%@%.%'
  
  UNION ALL
  
  -- Future dates validation
  SELECT 'future_open_date' as violation_type, ticket_id as record_id, open_date as invalid_value
  FROM {{ ref('bz_support_tickets') }}
  WHERE open_date > CURRENT_DATE
)

SELECT *
FROM format_violations
```

### Parameterized Test Macros

#### Macro 1: Generic Deduplication Test
```sql
-- macros/test_deduplication.sql
{% macro test_deduplication(model, primary_key_column) %}
  SELECT {{ primary_key_column }}, COUNT(*) as duplicate_count
  FROM {{ model }}
  GROUP BY {{ primary_key_column }}
  HAVING COUNT(*) > 1
{% endmacro %}
```

#### Macro 2: Generic Audit Trail Test
```sql
-- macros/test_audit_trail.sql
{% macro test_audit_trail(model_name) %}
  SELECT COUNT(*) as missing_audit_records
  FROM (
    SELECT 1
    WHERE NOT EXISTS (
      SELECT 1 
      FROM {{ ref('bz_data_audit') }}
      WHERE source_table = '{{ model_name.upper() }}'
        AND status = 'COMPLETED'
        AND load_timestamp >= CURRENT_DATE
    )
  )
{% endmacro %}
```

### Performance and Monitoring Tests

#### Test 7: Model Performance Monitoring
```sql
-- tests/test_model_performance.sql
-- Monitor model execution performance

WITH performance_metrics AS (
  SELECT 
    source_table,
    AVG(processing_time) as avg_processing_time,
    MAX(processing_time) as max_processing_time,
    COUNT(*) as execution_count
  FROM {{ ref('bz_data_audit') }}
  WHERE status = 'COMPLETED'
    AND load_timestamp >= CURRENT_DATE - 7
  GROUP BY source_table
)

SELECT source_table, avg_processing_time, max_processing_time
FROM performance_metrics
WHERE avg_processing_time > 300  -- Alert if average processing time > 5 minutes
   OR max_processing_time > 600   -- Alert if max processing time > 10 minutes
```

## Test Execution Strategy

### 1. Pre-deployment Testing
- Run all schema tests using `dbt test`
- Execute custom SQL tests individually
- Validate test coverage across all models
- Performance baseline establishment

### 2. Continuous Integration Testing
- Automated test execution on every commit
- Test result reporting and alerting
- Performance regression detection
- Data quality scorecards

### 3. Production Monitoring
- Daily execution of critical tests
- Real-time audit trail monitoring
- Data freshness alerts
- Business rule violation tracking

## Test Results Tracking

All test results are automatically tracked in:
- **dbt's run_results.json**: Standard dbt test execution results
- **Snowflake audit schema**: Custom audit tables for detailed tracking
- **bz_data_audit table**: Bronze layer specific audit trail
- **External monitoring systems**: Integration with data observability platforms

## Maintenance and Updates

- **Weekly Review**: Test coverage and effectiveness assessment
- **Monthly Updates**: New test cases based on data issues discovered
- **Quarterly Optimization**: Performance tuning and test consolidation
- **Annual Review**: Complete testing strategy evaluation and enhancement

---

*This document serves as the comprehensive testing framework for the Zoom Bronze Layer dbt pipeline, ensuring data quality, reliability, and performance in the Snowflake environment.*