_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Bronze Layer dbt models in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases - Zoom Bronze Layer Pipeline

## Overview

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Bronze Layer Pipeline dbt models running in Snowflake. The tests ensure data quality, validate transformations, and verify business rules across all Bronze layer models following the Medallion architecture.

## Test Strategy

### Testing Approach
- **Data Quality Tests**: Validate primary keys, null constraints, and data integrity
- **Business Rule Tests**: Verify transformations, deduplication, and audit trail functionality
- **Edge Case Tests**: Handle null values, empty datasets, and invalid data scenarios
- **Performance Tests**: Ensure efficient execution and proper indexing
- **Integration Tests**: Validate relationships between models and audit functionality

### Test Coverage Areas
1. **Primary Key Validation**: Uniqueness and non-null constraints
2. **Data Type Validation**: Proper casting and type conversions
3. **Deduplication Logic**: ROW_NUMBER() window function validation
4. **Audit Trail**: Pre/post hook execution and audit table population
5. **Error Handling**: TRY_CAST function validation
6. **Source Data Filtering**: Null primary key filtering
7. **Referential Integrity**: Foreign key relationship validation

## Test Case List

### 1. BZ_DATA_AUDIT Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_AUDIT_001 | Validate record_id uniqueness and auto-increment | All record_id values are unique and sequential |
| TC_AUDIT_002 | Verify source_table field is not null | No null values in source_table column |
| TC_AUDIT_003 | Validate load_timestamp is populated | All records have valid timestamps |
| TC_AUDIT_004 | Check status field accepts only valid values | Only SUCCESS, FAILED, WARNING, STARTED, INITIALIZED allowed |
| TC_AUDIT_005 | Verify processing_time is numeric and non-negative | All processing times are >= 0 |

### 2. BZ_USERS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_USERS_001 | Validate user_id uniqueness | All user_id values are unique |
| TC_USERS_002 | Verify user_id is not null | No null values in user_id column |
| TC_USERS_003 | Check email format validation | Valid email format or null |
| TC_USERS_004 | Validate deduplication logic | Latest record per user_id based on update_timestamp |
| TC_USERS_005 | Verify data type casting | All fields properly cast to target types |
| TC_USERS_006 | Test null primary key filtering | Records with null user_id are excluded |
| TC_USERS_007 | Validate audit trail integration | Audit records created for model execution |

### 3. BZ_MEETINGS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_MEETINGS_001 | Validate meeting_id uniqueness | All meeting_id values are unique |
| TC_MEETINGS_002 | Verify meeting_id is not null | No null values in meeting_id column |
| TC_MEETINGS_003 | Check start_time is not null | All meetings have valid start times |
| TC_MEETINGS_004 | Validate TRY_CAST for end_time | Invalid timestamps converted to null |
| TC_MEETINGS_005 | Verify TRY_CAST for duration_minutes | Invalid numbers converted to null |
| TC_MEETINGS_006 | Test deduplication logic | Latest record per meeting_id |
| TC_MEETINGS_007 | Validate duration calculation logic | Duration matches end_time - start_time |

### 4. BZ_PARTICIPANTS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_PARTICIPANTS_001 | Validate participant_id uniqueness | All participant_id values are unique |
| TC_PARTICIPANTS_002 | Verify participant_id is not null | No null values in participant_id column |
| TC_PARTICIPANTS_003 | Check meeting_id foreign key validity | All meeting_id values exist in BZ_MEETINGS |
| TC_PARTICIPANTS_004 | Validate user_id foreign key validity | All user_id values exist in BZ_USERS |
| TC_PARTICIPANTS_005 | Verify TRY_CAST for join_time | Invalid timestamps converted to null |
| TC_PARTICIPANTS_006 | Test session duration logic | leave_time >= join_time when both not null |
| TC_PARTICIPANTS_007 | Validate deduplication logic | Latest record per participant_id |

### 5. BZ_FEATURE_USAGE Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_FEATURE_001 | Validate usage_id uniqueness | All usage_id values are unique |
| TC_FEATURE_002 | Verify usage_id is not null | No null values in usage_id column |
| TC_FEATURE_003 | Check usage_count is non-negative | All usage_count values >= 0 |
| TC_FEATURE_004 | Validate feature_name is not null | No null values in feature_name column |
| TC_FEATURE_005 | Verify usage_date validity | All dates are valid and not future dates |
| TC_FEATURE_006 | Test meeting_id foreign key | All meeting_id values exist in BZ_MEETINGS |
| TC_FEATURE_007 | Validate deduplication logic | Latest record per usage_id |

### 6. BZ_SUPPORT_TICKETS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_TICKETS_001 | Validate ticket_id uniqueness | All ticket_id values are unique |
| TC_TICKETS_002 | Verify ticket_id is not null | No null values in ticket_id column |
| TC_TICKETS_003 | Check user_id foreign key validity | All user_id values exist in BZ_USERS |
| TC_TICKETS_004 | Validate resolution_status values | Only valid status values allowed |
| TC_TICKETS_005 | Verify open_date is not null | All tickets have valid open dates |
| TC_TICKETS_006 | Test ticket_type validation | Valid ticket types only |
| TC_TICKETS_007 | Validate deduplication logic | Latest record per ticket_id |

### 7. BZ_BILLING_EVENTS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BILLING_001 | Validate event_id uniqueness | All event_id values are unique |
| TC_BILLING_002 | Verify event_id is not null | No null values in event_id column |
| TC_BILLING_003 | Check amount TRY_CAST validation | Invalid amounts converted to null |
| TC_BILLING_004 | Validate amount precision | Amounts have correct decimal precision (10,2) |
| TC_BILLING_005 | Verify user_id foreign key | All user_id values exist in BZ_USERS |
| TC_BILLING_006 | Test event_date validity | All dates are valid |
| TC_BILLING_007 | Validate deduplication logic | Latest record per event_id |

### 8. BZ_LICENSES Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_LICENSES_001 | Validate license_id uniqueness | All license_id values are unique |
| TC_LICENSES_002 | Verify license_id is not null | No null values in license_id column |
| TC_LICENSES_003 | Check assigned_to_user_id foreign key | All user_id values exist in BZ_USERS |
| TC_LICENSES_004 | Validate date range logic | end_date >= start_date when both not null |
| TC_LICENSES_005 | Verify TRY_CAST for end_date | Invalid dates converted to null |
| TC_LICENSES_006 | Test license_type validation | Valid license types only |
| TC_LICENSES_007 | Validate deduplication logic | Latest record per license_id |

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# tests/schema_tests.yml
version: 2

models:
  # BZ_DATA_AUDIT Tests
  - name: bz_data_audit
    tests:
      - dbt_utils.expression_is_true:
          expression: "record_id > 0"
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
      - name: load_timestamp
        tests:
          - not_null
      - name: status
        tests:
          - accepted_values:
              values: ['SUCCESS', 'FAILED', 'WARNING', 'STARTED', 'INITIALIZED']
      - name: processing_time
        tests:
          - dbt_utils.expression_is_true:
              expression: "processing_time >= 0"

  # BZ_USERS Tests
  - name: bz_users
    tests:
      - dbt_utils.expression_is_true:
          expression: "load_timestamp <= current_timestamp()"
          config:
            severity: warn
    columns:
      - name: user_id
        tests:
          - not_null
          - unique
      - name: email
        tests:
          - dbt_utils.expression_is_true:
              expression: "email IS NULL OR email LIKE '%@%'"
              config:
                severity: warn

  # BZ_MEETINGS Tests
  - name: bz_meetings
    tests:
      - dbt_utils.expression_is_true:
          expression: "end_time IS NULL OR end_time >= start_time"
          config:
            severity: error
      - dbt_utils.expression_is_true:
          expression: "duration_minutes IS NULL OR duration_minutes >= 0"
    columns:
      - name: meeting_id
        tests:
          - not_null
          - unique
      - name: start_time
        tests:
          - not_null

  # BZ_PARTICIPANTS Tests
  - name: bz_participants
    tests:
      - dbt_utils.expression_is_true:
          expression: "leave_time IS NULL OR join_time IS NULL OR leave_time >= join_time"
          config:
            severity: error
    columns:
      - name: participant_id
        tests:
          - not_null
          - unique
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
    tests:
      - dbt_utils.expression_is_true:
          expression: "usage_date <= current_date()"
          config:
            severity: warn
    columns:
      - name: usage_id
        tests:
          - not_null
          - unique
      - name: feature_name
        tests:
          - not_null
      - name: usage_count
        tests:
          - dbt_utils.expression_is_true:
              expression: "usage_count >= 0"
      - name: meeting_id
        tests:
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
              config:
                severity: warn

  # BZ_SUPPORT_TICKETS Tests
  - name: bz_support_tickets
    tests:
      - dbt_utils.expression_is_true:
          expression: "open_date <= current_date()"
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
              config:
                severity: warn
      - name: open_date
        tests:
          - not_null

  # BZ_BILLING_EVENTS Tests
  - name: bz_billing_events
    tests:
      - dbt_utils.expression_is_true:
          expression: "event_date <= current_date()"
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
              config:
                severity: warn
      - name: amount
        tests:
          - dbt_utils.expression_is_true:
              expression: "amount IS NULL OR amount >= 0"

  # BZ_LICENSES Tests
  - name: bz_licenses
    tests:
      - dbt_utils.expression_is_true:
          expression: "end_date IS NULL OR start_date IS NULL OR end_date >= start_date"
          config:
            severity: error
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
              config:
                severity: warn
```

### Custom SQL-based dbt Tests

#### 1. Test Deduplication Logic

```sql
-- tests/test_deduplication_users.sql
-- Test that deduplication logic works correctly for BZ_USERS
SELECT 
    user_id,
    COUNT(*) as duplicate_count
FROM {{ ref('bz_users') }}
GROUP BY user_id
HAVING COUNT(*) > 1
```

#### 2. Test Audit Trail Functionality

```sql
-- tests/test_audit_trail_completeness.sql
-- Verify that audit records are created for all model executions
WITH expected_tables AS (
    SELECT table_name FROM (
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
actual_audit_records AS (
    SELECT DISTINCT source_table
    FROM {{ ref('bz_data_audit') }}
    WHERE status IN ('SUCCESS', 'STARTED')
)
SELECT 
    e.table_name
FROM expected_tables e
LEFT JOIN actual_audit_records a ON e.table_name = a.source_table
WHERE a.source_table IS NULL
```

#### 3. Test Data Type Casting

```sql
-- tests/test_data_type_casting.sql
-- Verify TRY_CAST functions handle invalid data properly
SELECT 
    'bz_meetings' as model_name,
    'end_time' as column_name,
    COUNT(*) as invalid_cast_count
FROM {{ source('raw', 'meetings') }}
WHERE end_time IS NOT NULL 
  AND TRY_CAST(end_time AS TIMESTAMP_NTZ(9)) IS NULL

UNION ALL

SELECT 
    'bz_meetings' as model_name,
    'duration_minutes' as column_name,
    COUNT(*) as invalid_cast_count
FROM {{ source('raw', 'meetings') }}
WHERE duration_minutes IS NOT NULL 
  AND TRY_CAST(duration_minutes AS NUMBER(38,0)) IS NULL

UNION ALL

SELECT 
    'bz_billing_events' as model_name,
    'amount' as column_name,
    COUNT(*) as invalid_cast_count
FROM {{ source('raw', 'billing_events') }}
WHERE amount IS NOT NULL 
  AND TRY_CAST(amount AS NUMBER(10,2)) IS NULL
```

#### 4. Test Source Data Quality

```sql
-- tests/test_source_data_quality.sql
-- Identify data quality issues in source tables
SELECT 
    'users' as source_table,
    'null_primary_keys' as issue_type,
    COUNT(*) as issue_count
FROM {{ source('raw', 'users') }}
WHERE user_id IS NULL

UNION ALL

SELECT 
    'meetings' as source_table,
    'null_primary_keys' as issue_type,
    COUNT(*) as issue_count
FROM {{ source('raw', 'meetings') }}
WHERE meeting_id IS NULL

UNION ALL

SELECT 
    'participants' as source_table,
    'null_primary_keys' as issue_type,
    COUNT(*) as issue_count
FROM {{ source('raw', 'participants') }}
WHERE participant_id IS NULL
```

#### 5. Test Business Logic Validation

```sql
-- tests/test_business_logic_validation.sql
-- Validate business rules across models
SELECT 
    'meeting_duration_consistency' as test_name,
    COUNT(*) as violation_count
FROM {{ ref('bz_meetings') }}
WHERE duration_minutes IS NOT NULL 
  AND end_time IS NOT NULL 
  AND start_time IS NOT NULL
  AND ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) > 1

UNION ALL

SELECT 
    'participant_session_logic' as test_name,
    COUNT(*) as violation_count
FROM {{ ref('bz_participants') }}
WHERE join_time IS NOT NULL 
  AND leave_time IS NOT NULL 
  AND leave_time < join_time

UNION ALL

SELECT 
    'license_date_range_logic' as test_name,
    COUNT(*) as violation_count
FROM {{ ref('bz_licenses') }}
WHERE start_date IS NOT NULL 
  AND end_date IS NOT NULL 
  AND end_date < start_date
```

### Parameterized Tests

#### Generic Test for Primary Key Validation

```sql
-- macros/test_primary_key_validation.sql
{% macro test_primary_key_validation(model, column_name) %}

SELECT 
    {{ column_name }},
    COUNT(*) as occurrence_count
FROM {{ model }}
WHERE {{ column_name }} IS NOT NULL
GROUP BY {{ column_name }}
HAVING COUNT(*) > 1

{% endmacro %}
```

#### Generic Test for Audit Trail Validation

```sql
-- macros/test_audit_trail_validation.sql
{% macro test_audit_trail_validation(table_name) %}

SELECT 
    '{{ table_name }}' as table_name,
    CASE 
        WHEN started_count = 0 THEN 'Missing STARTED record'
        WHEN success_count = 0 THEN 'Missing SUCCESS record'
        WHEN started_count != success_count THEN 'Mismatched audit records'
        ELSE 'Valid'
    END as audit_status
FROM (
    SELECT 
        SUM(CASE WHEN status = 'STARTED' THEN 1 ELSE 0 END) as started_count,
        SUM(CASE WHEN status = 'SUCCESS' THEN 1 ELSE 0 END) as success_count
    FROM {{ ref('bz_data_audit') }}
    WHERE source_table = '{{ table_name }}'
      AND load_timestamp >= CURRENT_DATE()
) audit_summary
WHERE audit_status != 'Valid'

{% endmacro %}
```

## Test Execution Strategy

### 1. Pre-deployment Testing
- Run all schema tests before model deployment
- Validate source data quality
- Check audit trail functionality

### 2. Post-deployment Validation
- Execute business logic tests
- Verify data completeness
- Validate performance metrics

### 3. Continuous Monitoring
- Schedule daily data quality checks
- Monitor audit trail completeness
- Track test execution results in dbt's run_results.json

### 4. Error Handling
- Failed tests logged to Snowflake audit schema
- Severity levels configured (error, warn)
- Automated alerts for critical failures

## Performance Considerations

### Test Optimization
- Use sampling for large datasets
- Implement incremental test strategies
- Leverage Snowflake's query optimization

### Resource Management
- Configure appropriate warehouse sizes for testing
- Use separate compute resources for test execution
- Implement test result caching

## Compliance and Governance

### Data Privacy
- PII field validation in BZ_USERS model
- Audit trail for data access tracking
- Compliance with data retention policies

### Data Lineage
- Source system tracking via SOURCE_SYSTEM field
- Complete audit trail in BZ_DATA_AUDIT table
- Integration with dbt documentation

## Summary

This comprehensive test suite ensures the reliability and performance of the Zoom Bronze Layer dbt models in Snowflake by:

- **Validating Data Quality**: Primary keys, constraints, and data types
- **Testing Business Logic**: Deduplication, transformations, and audit trails
- **Handling Edge Cases**: Null values, invalid data, and error scenarios
- **Ensuring Performance**: Optimized queries and resource management
- **Maintaining Compliance**: PII handling and audit requirements

The test cases cover all critical aspects of the Bronze layer pipeline and provide a robust foundation for maintaining data quality and reliability in the Medallion architecture implementation.