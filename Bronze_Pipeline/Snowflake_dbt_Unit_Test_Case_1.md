_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Bronze Layer dbt models in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases - Zoom Bronze Layer Pipeline

## Overview

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics Bronze layer dbt models running in Snowflake. The test cases validate data transformations, business rules, edge cases, and error handling scenarios to ensure reliable and performant dbt models.

## Test Strategy

The testing approach covers:
- **Data Quality Tests**: Validate data integrity and completeness
- **Business Rule Tests**: Ensure transformations meet business requirements
- **Edge Case Tests**: Handle null values, empty datasets, and boundary conditions
- **Performance Tests**: Validate model execution efficiency
- **Audit Trail Tests**: Verify comprehensive logging and tracking

---

## Test Case List

### 1. BZ_USERS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_USERS_001 | Validate USER_ID uniqueness after deduplication | No duplicate USER_IDs in final output |
| TC_BZ_USERS_002 | Test null USER_ID handling | Records with null USER_ID are excluded |
| TC_BZ_USERS_003 | Verify deduplication logic based on UPDATE_TIMESTAMP | Latest record per USER_ID is retained |
| TC_BZ_USERS_004 | Validate email format consistency | All email addresses maintain original format |
| TC_BZ_USERS_005 | Test empty source table handling | Model executes successfully with empty source |
| TC_BZ_USERS_006 | Verify audit trail creation | Pre-hook and post-hook audit records are created |
| TC_BZ_USERS_007 | Test PII data preservation | USER_NAME and EMAIL fields are preserved as-is |
| TC_BZ_USERS_008 | Validate PLAN_TYPE accepted values | Only valid plan types are processed |

### 2. BZ_MEETINGS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_MEETINGS_001 | Validate MEETING_ID uniqueness after deduplication | No duplicate MEETING_IDs in final output |
| TC_BZ_MEETINGS_002 | Test null MEETING_ID handling | Records with null MEETING_ID are excluded |
| TC_BZ_MEETINGS_003 | Verify START_TIME and END_TIME relationship | END_TIME >= START_TIME for all records |
| TC_BZ_MEETINGS_004 | Validate DURATION_MINUTES calculation consistency | Duration matches time difference where available |
| TC_BZ_MEETINGS_005 | Test HOST_ID foreign key relationship | All HOST_IDs exist in BZ_USERS (informational) |
| TC_BZ_MEETINGS_006 | Verify deduplication logic | Latest record per MEETING_ID is retained |
| TC_BZ_MEETINGS_007 | Test negative duration handling | Negative durations are flagged but preserved |
| TC_BZ_MEETINGS_008 | Validate audit trail creation | Pre-hook and post-hook audit records are created |

### 3. BZ_PARTICIPANTS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_PARTICIPANTS_001 | Validate PARTICIPANT_ID uniqueness | No duplicate PARTICIPANT_IDs in final output |
| TC_BZ_PARTICIPANTS_002 | Test null PARTICIPANT_ID handling | Records with null PARTICIPANT_ID are excluded |
| TC_BZ_PARTICIPANTS_003 | Verify JOIN_TIME and LEAVE_TIME relationship | LEAVE_TIME >= JOIN_TIME for all records |
| TC_BZ_PARTICIPANTS_004 | Test MEETING_ID referential integrity | All MEETING_IDs exist in BZ_MEETINGS (informational) |
| TC_BZ_PARTICIPANTS_005 | Test USER_ID referential integrity | All USER_IDs exist in BZ_USERS (informational) |
| TC_BZ_PARTICIPANTS_006 | Verify deduplication logic | Latest record per PARTICIPANT_ID is retained |
| TC_BZ_PARTICIPANTS_007 | Test null LEAVE_TIME handling | Records with null LEAVE_TIME are preserved |
| TC_BZ_PARTICIPANTS_008 | Validate audit trail creation | Pre-hook and post-hook audit records are created |

### 4. BZ_FEATURE_USAGE Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_FEATURE_USAGE_001 | Validate USAGE_ID uniqueness | No duplicate USAGE_IDs in final output |
| TC_BZ_FEATURE_USAGE_002 | Test null USAGE_ID handling | Records with null USAGE_ID are excluded |
| TC_BZ_FEATURE_USAGE_003 | Verify USAGE_COUNT non-negative values | All usage counts are >= 0 |
| TC_BZ_FEATURE_USAGE_004 | Test MEETING_ID referential integrity | All MEETING_IDs exist in BZ_MEETINGS (informational) |
| TC_BZ_FEATURE_USAGE_005 | Validate FEATURE_NAME standardization | Feature names are preserved as-is from source |
| TC_BZ_FEATURE_USAGE_006 | Verify deduplication logic | Latest record per USAGE_ID is retained |
| TC_BZ_FEATURE_USAGE_007 | Test USAGE_DATE validity | All dates are valid and not future dates |
| TC_BZ_FEATURE_USAGE_008 | Validate audit trail creation | Pre-hook and post-hook audit records are created |

### 5. BZ_SUPPORT_TICKETS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_SUPPORT_TICKETS_001 | Validate TICKET_ID uniqueness | No duplicate TICKET_IDs in final output |
| TC_BZ_SUPPORT_TICKETS_002 | Test null TICKET_ID handling | Records with null TICKET_ID are excluded |
| TC_BZ_SUPPORT_TICKETS_003 | Verify RESOLUTION_STATUS accepted values | Only valid status values are processed |
| TC_BZ_SUPPORT_TICKETS_004 | Test USER_ID referential integrity | All USER_IDs exist in BZ_USERS (informational) |
| TC_BZ_SUPPORT_TICKETS_005 | Validate OPEN_DATE consistency | All open dates are valid and not future dates |
| TC_BZ_SUPPORT_TICKETS_006 | Verify deduplication logic | Latest record per TICKET_ID is retained |
| TC_BZ_SUPPORT_TICKETS_007 | Test TICKET_TYPE standardization | Ticket types are preserved as-is from source |
| TC_BZ_SUPPORT_TICKETS_008 | Validate audit trail creation | Pre-hook and post-hook audit records are created |

### 6. BZ_BILLING_EVENTS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_BILLING_EVENTS_001 | Validate EVENT_ID uniqueness | No duplicate EVENT_IDs in final output |
| TC_BZ_BILLING_EVENTS_002 | Test null EVENT_ID handling | Records with null EVENT_ID are excluded |
| TC_BZ_BILLING_EVENTS_003 | Verify AMOUNT precision and scale | All amounts maintain 2 decimal precision |
| TC_BZ_BILLING_EVENTS_004 | Test negative amount handling | Negative amounts are preserved (refunds) |
| TC_BZ_BILLING_EVENTS_005 | Test USER_ID referential integrity | All USER_IDs exist in BZ_USERS (informational) |
| TC_BZ_BILLING_EVENTS_006 | Verify deduplication logic | Latest record per EVENT_ID is retained |
| TC_BZ_BILLING_EVENTS_007 | Validate EVENT_DATE consistency | All event dates are valid |
| TC_BZ_BILLING_EVENTS_008 | Validate audit trail creation | Pre-hook and post-hook audit records are created |

### 7. BZ_LICENSES Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_LICENSES_001 | Validate LICENSE_ID uniqueness | No duplicate LICENSE_IDs in final output |
| TC_BZ_LICENSES_002 | Test null LICENSE_ID handling | Records with null LICENSE_ID are excluded |
| TC_BZ_LICENSES_003 | Verify START_DATE and END_DATE relationship | END_DATE >= START_DATE for all records |
| TC_BZ_LICENSES_004 | Test ASSIGNED_TO_USER_ID referential integrity | All USER_IDs exist in BZ_USERS (informational) |
| TC_BZ_LICENSES_005 | Validate LICENSE_TYPE accepted values | Only valid license types are processed |
| TC_BZ_LICENSES_006 | Verify deduplication logic | Latest record per LICENSE_ID is retained |
| TC_BZ_LICENSES_007 | Test null END_DATE handling | Records with null END_DATE are preserved |
| TC_BZ_LICENSES_008 | Validate audit trail creation | Pre-hook and post-hook audit records are created |

### 8. BZ_DATA_AUDIT Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_DATA_AUDIT_001 | Validate audit table structure creation | Table created with correct schema |
| TC_BZ_DATA_AUDIT_002 | Test RECORD_ID auto-increment | Sequential IDs are generated |
| TC_BZ_DATA_AUDIT_003 | Verify audit record insertion | Records are inserted by pre/post hooks |
| TC_BZ_DATA_AUDIT_004 | Test STATUS value validation | Only valid status values are recorded |
| TC_BZ_DATA_AUDIT_005 | Validate LOAD_TIMESTAMP accuracy | Timestamps reflect actual execution time |
| TC_BZ_DATA_AUDIT_006 | Test PROCESSED_BY user tracking | Correct user/process is recorded |
| TC_BZ_DATA_AUDIT_007 | Verify SOURCE_TABLE name accuracy | Correct table names are recorded |
| TC_BZ_DATA_AUDIT_008 | Test audit trail completeness | All model executions are logged |

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
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - user_id
      - dbt_expectations.expect_table_row_count_to_be_between:
          min_value: 0
          max_value: 10000000
    columns:
      - name: user_id
        tests:
          - not_null
          - unique
      - name: email
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
      - name: plan_type
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise']
      - name: load_timestamp
        tests:
          - not_null
      - name: update_timestamp
        tests:
          - not_null

  # BZ_MEETINGS Tests
  - name: bz_meetings
    tests:
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - meeting_id
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
              severity: warn
      - name: start_time
        tests:
          - not_null
      - name: end_time
        tests:
          - dbt_expectations.expect_column_pair_values_A_to_be_smaller_than_B:
              column_A: start_time
              column_B: end_time
              or_equal: true
      - name: duration_minutes
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440  # 24 hours

  # BZ_PARTICIPANTS Tests
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
              severity: warn
      - name: user_id
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
              severity: warn
      - name: join_time
        tests:
          - not_null
      - name: leave_time
        tests:
          - dbt_expectations.expect_column_pair_values_A_to_be_smaller_than_B:
              column_A: join_time
              column_B: leave_time
              or_equal: true

  # BZ_FEATURE_USAGE Tests
  - name: bz_feature_usage
    columns:
      - name: usage_id
        tests:
          - not_null
          - unique
      - name: meeting_id
        tests:
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
              severity: warn
      - name: usage_count
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10000
      - name: usage_date
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: date

  # BZ_SUPPORT_TICKETS Tests
  - name: bz_support_tickets
    columns:
      - name: ticket_id
        tests:
          - not_null
          - unique
      - name: user_id
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
              severity: warn
      - name: resolution_status
        tests:
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed', 'Cancelled']
      - name: open_date
        tests:
          - not_null

  # BZ_BILLING_EVENTS Tests
  - name: bz_billing_events
    columns:
      - name: event_id
        tests:
          - not_null
          - unique
      - name: user_id
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
              severity: warn
      - name: amount
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: -10000.00
              max_value: 10000.00
      - name: event_type
        tests:
          - accepted_values:
              values: ['Payment', 'Refund', 'Adjustment', 'Credit']

  # BZ_LICENSES Tests
  - name: bz_licenses
    columns:
      - name: license_id
        tests:
          - not_null
          - unique
      - name: assigned_to_user_id
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
              severity: warn
      - name: start_date
        tests:
          - not_null
      - name: end_date
        tests:
          - dbt_expectations.expect_column_pair_values_A_to_be_smaller_than_B:
              column_A: start_date
              column_B: end_date
              or_equal: true

  # BZ_DATA_AUDIT Tests
  - name: bz_data_audit
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
              values: ['STARTED', 'COMPLETED', 'FAILED']
```

### Custom SQL-based dbt Tests

#### 1. Deduplication Logic Test

```sql
-- tests/test_deduplication_logic.sql
-- Test that deduplication logic works correctly across all Bronze models

{{ config(severity = 'error') }}

WITH duplicate_check AS (
  -- Check BZ_USERS for duplicates
  SELECT 'bz_users' as table_name, COUNT(*) as duplicate_count
  FROM (
    SELECT user_id, COUNT(*) as cnt
    FROM {{ ref('bz_users') }}
    GROUP BY user_id
    HAVING COUNT(*) > 1
  )
  
  UNION ALL
  
  -- Check BZ_MEETINGS for duplicates
  SELECT 'bz_meetings' as table_name, COUNT(*) as duplicate_count
  FROM (
    SELECT meeting_id, COUNT(*) as cnt
    FROM {{ ref('bz_meetings') }}
    GROUP BY meeting_id
    HAVING COUNT(*) > 1
  )
  
  UNION ALL
  
  -- Check BZ_PARTICIPANTS for duplicates
  SELECT 'bz_participants' as table_name, COUNT(*) as duplicate_count
  FROM (
    SELECT participant_id, COUNT(*) as cnt
    FROM {{ ref('bz_participants') }}
    GROUP BY participant_id
    HAVING COUNT(*) > 1
  )
)

SELECT *
FROM duplicate_check
WHERE duplicate_count > 0
```

#### 2. Audit Trail Completeness Test

```sql
-- tests/test_audit_trail_completeness.sql
-- Verify that audit records are created for all model executions

{{ config(severity = 'warn') }}

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

audit_records AS (
  SELECT DISTINCT source_table
  FROM {{ ref('bz_data_audit') }}
  WHERE load_timestamp >= CURRENT_DATE - 1
),

missing_audit AS (
  SELECT e.table_name
  FROM expected_tables e
  LEFT JOIN audit_records a ON e.table_name = a.source_table
  WHERE a.source_table IS NULL
)

SELECT *
FROM missing_audit
```

#### 3. Data Freshness Test

```sql
-- tests/test_data_freshness.sql
-- Verify that data is being loaded within acceptable time windows

{{ config(severity = 'warn') }}

WITH freshness_check AS (
  SELECT 
    'bz_users' as table_name,
    MAX(load_timestamp) as last_load,
    DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP()) as hours_since_load
  FROM {{ ref('bz_users') }}
  
  UNION ALL
  
  SELECT 
    'bz_meetings' as table_name,
    MAX(load_timestamp) as last_load,
    DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP()) as hours_since_load
  FROM {{ ref('bz_meetings') }}
  
  UNION ALL
  
  SELECT 
    'bz_participants' as table_name,
    MAX(load_timestamp) as last_load,
    DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP()) as hours_since_load
  FROM {{ ref('bz_participants') }}
)

SELECT *
FROM freshness_check
WHERE hours_since_load > 24  -- Alert if data is older than 24 hours
```

#### 4. Referential Integrity Test

```sql
-- tests/test_referential_integrity.sql
-- Check referential integrity across Bronze layer tables

{{ config(severity = 'warn') }}

WITH integrity_violations AS (
  -- Check meetings with invalid host_id
  SELECT 
    'meetings_invalid_host' as violation_type,
    COUNT(*) as violation_count
  FROM {{ ref('bz_meetings') }} m
  LEFT JOIN {{ ref('bz_users') }} u ON m.host_id = u.user_id
  WHERE m.host_id IS NOT NULL AND u.user_id IS NULL
  
  UNION ALL
  
  -- Check participants with invalid meeting_id
  SELECT 
    'participants_invalid_meeting' as violation_type,
    COUNT(*) as violation_count
  FROM {{ ref('bz_participants') }} p
  LEFT JOIN {{ ref('bz_meetings') }} m ON p.meeting_id = m.meeting_id
  WHERE p.meeting_id IS NOT NULL AND m.meeting_id IS NULL
  
  UNION ALL
  
  -- Check participants with invalid user_id
  SELECT 
    'participants_invalid_user' as violation_type,
    COUNT(*) as violation_count
  FROM {{ ref('bz_participants') }} p
  LEFT JOIN {{ ref('bz_users') }} u ON p.user_id = u.user_id
  WHERE p.user_id IS NOT NULL AND u.user_id IS NULL
)

SELECT *
FROM integrity_violations
WHERE violation_count > 0
```

#### 5. Data Quality Metrics Test

```sql
-- tests/test_data_quality_metrics.sql
-- Calculate and validate data quality metrics

{{ config(severity = 'warn') }}

WITH quality_metrics AS (
  SELECT 
    'bz_users' as table_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN user_id IS NULL THEN 1 END) as null_user_ids,
    COUNT(CASE WHEN email IS NULL THEN 1 END) as null_emails,
    COUNT(CASE WHEN email NOT LIKE '%@%' THEN 1 END) as invalid_emails
  FROM {{ ref('bz_users') }}
  
  UNION ALL
  
  SELECT 
    'bz_meetings' as table_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN meeting_id IS NULL THEN 1 END) as null_meeting_ids,
    COUNT(CASE WHEN start_time IS NULL THEN 1 END) as null_start_times,
    COUNT(CASE WHEN end_time < start_time THEN 1 END) as invalid_time_ranges
  FROM {{ ref('bz_meetings') }}
)

SELECT *
FROM quality_metrics
WHERE 
  (null_user_ids > 0 OR null_emails > 0 OR invalid_emails > 0)
  OR (null_meeting_ids > 0 OR null_start_times > 0 OR invalid_time_ranges > 0)
```

### Parameterized Tests

#### Generic Test for Primary Key Validation

```sql
-- macros/test_primary_key_not_null_unique.sql
-- Generic test macro for primary key validation

{% macro test_primary_key_not_null_unique(model, column_name) %}

  SELECT COUNT(*)
  FROM (
    SELECT {{ column_name }}
    FROM {{ model }}
    WHERE {{ column_name }} IS NULL
    
    UNION ALL
    
    SELECT {{ column_name }}
    FROM (
      SELECT 
        {{ column_name }},
        COUNT(*) as cnt
      FROM {{ model }}
      GROUP BY {{ column_name }}
      HAVING COUNT(*) > 1
    )
  )

{% endmacro %}
```

#### Generic Test for Timestamp Validation

```sql
-- macros/test_timestamp_range_validation.sql
-- Generic test macro for timestamp range validation

{% macro test_timestamp_range_validation(model, start_column, end_column) %}

  SELECT COUNT(*)
  FROM {{ model }}
  WHERE {{ start_column }} IS NOT NULL 
    AND {{ end_column }} IS NOT NULL
    AND {{ end_column }} < {{ start_column }}

{% endmacro %}
```

---

## Test Execution Strategy

### 1. Continuous Integration Tests
- Run on every dbt model change
- Include critical data quality tests
- Fast execution (< 5 minutes)

### 2. Daily Data Quality Tests
- Comprehensive data validation
- Referential integrity checks
- Data freshness validation

### 3. Weekly Performance Tests
- Model execution time monitoring
- Resource utilization analysis
- Scalability validation

### 4. Monthly Audit Tests
- Complete audit trail validation
- Historical data consistency
- Compliance verification

---

## Test Results Tracking

### dbt Test Results
- Results stored in `run_results.json`
- Test failures logged to Snowflake audit schema
- Automated alerting for critical failures

### Snowflake Audit Schema
- Test execution history
- Performance metrics
- Data quality trends
- Compliance reporting

---

## Maintenance and Updates

### Test Case Versioning
- Version control for all test scripts
- Change impact analysis
- Regression testing protocols

### Performance Optimization
- Regular review of test execution times
- Optimization of complex test queries
- Resource allocation monitoring

### Documentation Updates
- Keep test documentation current
- Update test cases for model changes
- Maintain test coverage metrics

---

## Conclusion

This comprehensive unit test suite ensures the reliability, performance, and data quality of the Zoom Bronze Layer dbt models in Snowflake. The combination of YAML-based schema tests, custom SQL tests, and parameterized macros provides thorough coverage of:

- **Data Integrity**: Primary key uniqueness, null value handling
- **Business Rules**: Timestamp relationships, value ranges
- **Edge Cases**: Empty datasets, invalid data scenarios
- **Performance**: Execution time monitoring, resource utilization
- **Audit Compliance**: Complete audit trail validation

Regular execution of these test cases will help maintain high data quality standards and catch potential issues early in the development cycle, ensuring reliable data pipelines for downstream Silver and Gold layer processing.