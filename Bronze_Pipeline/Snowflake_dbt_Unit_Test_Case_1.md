_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Bronze Layer dbt models in Snowflake
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Zoom Bronze Layer Pipeline

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Bronze Layer pipeline running in Snowflake. The test cases cover all Bronze layer models including data transformations, business rules, edge cases, and error handling scenarios to ensure data quality and pipeline reliability.

## Test Coverage Overview

The Bronze layer consists of 8 main models:
- `bz_data_audit` - Audit trail for data operations
- `bz_users` - User profile and subscription information
- `bz_meetings` - Meeting information and session details
- `bz_participants` - Meeting participants and session details
- `bz_feature_usage` - Platform feature usage during meetings
- `bz_support_tickets` - Customer support requests and resolution tracking
- `bz_billing_events` - Financial transactions and billing activities
- `bz_licenses` - License assignments and entitlements

---

## Test Case List

### 1. Data Quality and Integrity Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) |
|--------------|----------------------|------------------|----------|
| TC_DQ_001 | Validate primary key uniqueness across all Bronze models | All primary keys should be unique with no duplicates | All models |
| TC_DQ_002 | Validate primary key not null constraint | No NULL values in primary key columns | All models |
| TC_DQ_003 | Validate deduplication logic effectiveness | Only latest records retained based on load_timestamp | All models |
| TC_DQ_004 | Validate data type conversions using TRY_CAST | Invalid data gracefully converted to NULL without errors | bz_meetings, bz_participants, bz_billing_events, bz_licenses |
| TC_DQ_005 | Validate source system tracking | All records have valid source_system values | All models except bz_data_audit |

### 2. Business Logic and Transformation Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) |
|--------------|----------------------|------------------|----------|
| TC_BL_001 | Validate 1-to-1 mapping from raw to bronze | Record counts match between source and target | All models |
| TC_BL_002 | Validate audit trail creation | Audit records created for each model execution | bz_data_audit |
| TC_BL_003 | Validate processing time calculation | Processing times calculated correctly in seconds | bz_data_audit |
| TC_BL_004 | Validate status tracking (STARTED/SUCCESS) | Proper status progression in audit records | bz_data_audit |
| TC_BL_005 | Validate timestamp preservation | Load and update timestamps preserved from source | All models |

### 3. Edge Case and Error Handling Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) |
|--------------|----------------------|------------------|----------|
| TC_EC_001 | Handle NULL primary keys | Records with NULL primary keys filtered out | All models |
| TC_EC_002 | Handle duplicate records with same timestamp | Consistent deduplication using row_number logic | All models |
| TC_EC_003 | Handle invalid date/timestamp formats | TRY_CAST converts invalid formats to NULL | bz_meetings, bz_participants, bz_licenses |
| TC_EC_004 | Handle invalid numeric formats | TRY_CAST converts invalid numbers to NULL | bz_meetings, bz_billing_events |
| TC_EC_005 | Handle empty source tables | Models execute successfully with zero records | All models |
| TC_EC_006 | Handle schema evolution | Models adapt to new columns in source | All models |

### 4. Performance and Scalability Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) |
|--------------|----------------------|------------------|----------|
| TC_PS_001 | Validate execution time for large datasets | Models complete within acceptable time limits | All models |
| TC_PS_002 | Validate memory usage during deduplication | ROW_NUMBER operations complete without memory errors | All models |
| TC_PS_003 | Validate concurrent execution | Multiple models can run simultaneously | All models |

### 5. Data Lineage and Audit Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) |
|--------------|----------------------|------------------|----------|
| TC_DL_001 | Validate pre-hook audit insertion | STARTED status recorded before model execution | All models except bz_data_audit |
| TC_DL_002 | Validate post-hook audit completion | SUCCESS status recorded after model execution | All models except bz_data_audit |
| TC_DL_003 | Validate audit record completeness | All required audit fields populated | bz_data_audit |

---

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# tests/bronze_layer_tests.yml
version: 2

models:
  # BZ_DATA_AUDIT Tests
  - name: bz_data_audit
    tests:
      - dbt_utils.expression_is_true:
          expression: "record_id IS NOT NULL"
          config:
            severity: error
      - dbt_utils.expression_is_true:
          expression: "source_table IS NOT NULL"
          config:
            severity: error
      - dbt_utils.accepted_values:
          column_name: status
          values: ['STARTED', 'SUCCESS', 'FAILED', 'WARNING']
          config:
            severity: warn

  # BZ_USERS Tests
  - name: bz_users
    tests:
      - dbt_utils.expression_is_true:
          expression: "user_id IS NOT NULL"
          config:
            severity: error
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - user_id
          config:
            severity: error
      - dbt_utils.accepted_values:
          column_name: plan_type
          values: ['Basic', 'Pro', 'Business', 'Enterprise']
          config:
            severity: warn
      - dbt_utils.expression_is_true:
          expression: "load_timestamp IS NOT NULL"
          config:
            severity: error

  # BZ_MEETINGS Tests
  - name: bz_meetings
    tests:
      - dbt_utils.expression_is_true:
          expression: "meeting_id IS NOT NULL"
          config:
            severity: error
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - meeting_id
          config:
            severity: error
      - dbt_utils.expression_is_true:
          expression: "start_time IS NOT NULL"
          config:
            severity: error
      - dbt_utils.expression_is_true:
          expression: "end_time >= start_time OR end_time IS NULL"
          config:
            severity: warn
      - dbt_utils.expression_is_true:
          expression: "duration_minutes >= 0 OR duration_minutes IS NULL"
          config:
            severity: warn

  # BZ_PARTICIPANTS Tests
  - name: bz_participants
    tests:
      - dbt_utils.expression_is_true:
          expression: "participant_id IS NOT NULL"
          config:
            severity: error
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - participant_id
          config:
            severity: error
      - dbt_utils.expression_is_true:
          expression: "meeting_id IS NOT NULL"
          config:
            severity: error
      - dbt_utils.expression_is_true:
          expression: "leave_time >= join_time OR leave_time IS NULL"
          config:
            severity: warn

  # BZ_FEATURE_USAGE Tests
  - name: bz_feature_usage
    tests:
      - dbt_utils.expression_is_true:
          expression: "usage_id IS NOT NULL"
          config:
            severity: error
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - usage_id
          config:
            severity: error
      - dbt_utils.expression_is_true:
          expression: "usage_count >= 0 OR usage_count IS NULL"
          config:
            severity: warn
      - dbt_utils.expression_is_true:
          expression: "feature_name IS NOT NULL"
          config:
            severity: error

  # BZ_SUPPORT_TICKETS Tests
  - name: bz_support_tickets
    tests:
      - dbt_utils.expression_is_true:
          expression: "ticket_id IS NOT NULL"
          config:
            severity: error
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - ticket_id
          config:
            severity: error
      - dbt_utils.accepted_values:
          column_name: resolution_status
          values: ['Open', 'In Progress', 'Resolved', 'Closed']
          config:
            severity: warn

  # BZ_BILLING_EVENTS Tests
  - name: bz_billing_events
    tests:
      - dbt_utils.expression_is_true:
          expression: "event_id IS NOT NULL"
          config:
            severity: error
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - event_id
          config:
            severity: error
      - dbt_utils.expression_is_true:
          expression: "amount >= 0 OR amount IS NULL"
          config:
            severity: warn
      - dbt_utils.accepted_values:
          column_name: event_type
          values: ['charge', 'refund', 'credit', 'adjustment']
          config:
            severity: warn

  # BZ_LICENSES Tests
  - name: bz_licenses
    tests:
      - dbt_utils.expression_is_true:
          expression: "license_id IS NOT NULL"
          config:
            severity: error
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - license_id
          config:
            severity: error
      - dbt_utils.accepted_values:
          column_name: license_type
          values: ['Basic', 'Pro', 'Business', 'Enterprise']
          config:
            severity: warn
      - dbt_utils.expression_is_true:
          expression: "end_date >= start_date OR end_date IS NULL"
          config:
            severity: warn
```

### Custom SQL-based dbt Tests

#### Test 1: Deduplication Effectiveness
```sql
-- tests/test_deduplication_effectiveness.sql
-- Test to ensure deduplication logic works correctly

SELECT 
    'bz_users' as model_name,
    COUNT(*) as duplicate_count
FROM (
    SELECT 
        user_id,
        COUNT(*) as cnt
    FROM {{ ref('bz_users') }}
    GROUP BY user_id
    HAVING COUNT(*) > 1
)

UNION ALL

SELECT 
    'bz_meetings' as model_name,
    COUNT(*) as duplicate_count
FROM (
    SELECT 
        meeting_id,
        COUNT(*) as cnt
    FROM {{ ref('bz_meetings') }}
    GROUP BY meeting_id
    HAVING COUNT(*) > 1
)

UNION ALL

SELECT 
    'bz_participants' as model_name,
    COUNT(*) as duplicate_count
FROM (
    SELECT 
        participant_id,
        COUNT(*) as cnt
    FROM {{ ref('bz_participants') }}
    GROUP BY participant_id
    HAVING COUNT(*) > 1
)

UNION ALL

SELECT 
    'bz_feature_usage' as model_name,
    COUNT(*) as duplicate_count
FROM (
    SELECT 
        usage_id,
        COUNT(*) as cnt
    FROM {{ ref('bz_feature_usage') }}
    GROUP BY usage_id
    HAVING COUNT(*) > 1
)

UNION ALL

SELECT 
    'bz_support_tickets' as model_name,
    COUNT(*) as duplicate_count
FROM (
    SELECT 
        ticket_id,
        COUNT(*) as cnt
    FROM {{ ref('bz_support_tickets') }}
    GROUP BY ticket_id
    HAVING COUNT(*) > 1
)

UNION ALL

SELECT 
    'bz_billing_events' as model_name,
    COUNT(*) as duplicate_count
FROM (
    SELECT 
        event_id,
        COUNT(*) as cnt
    FROM {{ ref('bz_billing_events') }}
    GROUP BY event_id
    HAVING COUNT(*) > 1
)

UNION ALL

SELECT 
    'bz_licenses' as model_name,
    COUNT(*) as duplicate_count
FROM (
    SELECT 
        license_id,
        COUNT(*) as cnt
    FROM {{ ref('bz_licenses') }}
    GROUP BY license_id
    HAVING COUNT(*) > 1
)

HAVING duplicate_count > 0
```

#### Test 2: Audit Trail Completeness
```sql
-- tests/test_audit_trail_completeness.sql
-- Test to ensure audit records are created for all model executions

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
    WHERE load_timestamp >= CURRENT_DATE - 1
)

SELECT 
    e.table_name as missing_audit_table
FROM expected_tables e
LEFT JOIN actual_audit_records a ON e.table_name = a.source_table
WHERE a.source_table IS NULL
```

#### Test 3: Data Type Conversion Validation
```sql
-- tests/test_data_type_conversions.sql
-- Test to validate TRY_CAST operations work correctly

SELECT 
    'bz_meetings' as model_name,
    'end_time' as column_name,
    COUNT(*) as conversion_failures
FROM {{ ref('bz_meetings') }}
WHERE end_time IS NULL 
  AND EXISTS (
      SELECT 1 FROM {{ source('raw', 'meetings') }} s 
      WHERE s.meeting_id = bz_meetings.meeting_id 
        AND s.end_time IS NOT NULL
        AND s.end_time != ''
  )

UNION ALL

SELECT 
    'bz_meetings' as model_name,
    'duration_minutes' as column_name,
    COUNT(*) as conversion_failures
FROM {{ ref('bz_meetings') }}
WHERE duration_minutes IS NULL 
  AND EXISTS (
      SELECT 1 FROM {{ source('raw', 'meetings') }} s 
      WHERE s.meeting_id = bz_meetings.meeting_id 
        AND s.duration_minutes IS NOT NULL
        AND s.duration_minutes != ''
  )

UNION ALL

SELECT 
    'bz_billing_events' as model_name,
    'amount' as column_name,
    COUNT(*) as conversion_failures
FROM {{ ref('bz_billing_events') }}
WHERE amount IS NULL 
  AND EXISTS (
      SELECT 1 FROM {{ source('raw', 'billing_events') }} s 
      WHERE s.event_id = bz_billing_events.event_id 
        AND s.amount IS NOT NULL
        AND s.amount != ''
  )

HAVING conversion_failures > 0
```

#### Test 4: Source-to-Bronze Record Count Validation
```sql
-- tests/test_source_to_bronze_counts.sql
-- Test to ensure 1-to-1 mapping from source to bronze (after deduplication)

WITH source_counts AS (
    SELECT 
        'users' as table_name,
        COUNT(DISTINCT user_id) as source_count
    FROM {{ source('raw', 'users') }}
    WHERE user_id IS NOT NULL
    
    UNION ALL
    
    SELECT 
        'meetings' as table_name,
        COUNT(DISTINCT meeting_id) as source_count
    FROM {{ source('raw', 'meetings') }}
    WHERE meeting_id IS NOT NULL
    
    UNION ALL
    
    SELECT 
        'participants' as table_name,
        COUNT(DISTINCT participant_id) as source_count
    FROM {{ source('raw', 'participants') }}
    WHERE participant_id IS NOT NULL
    
    UNION ALL
    
    SELECT 
        'feature_usage' as table_name,
        COUNT(DISTINCT usage_id) as source_count
    FROM {{ source('raw', 'feature_usage') }}
    WHERE usage_id IS NOT NULL
    
    UNION ALL
    
    SELECT 
        'support_tickets' as table_name,
        COUNT(DISTINCT ticket_id) as source_count
    FROM {{ source('raw', 'support_tickets') }}
    WHERE ticket_id IS NOT NULL
    
    UNION ALL
    
    SELECT 
        'billing_events' as table_name,
        COUNT(DISTINCT event_id) as source_count
    FROM {{ source('raw', 'billing_events') }}
    WHERE event_id IS NOT NULL
    
    UNION ALL
    
    SELECT 
        'licenses' as table_name,
        COUNT(DISTINCT license_id) as source_count
    FROM {{ source('raw', 'licenses') }}
    WHERE license_id IS NOT NULL
),
bronze_counts AS (
    SELECT 
        'users' as table_name,
        COUNT(*) as bronze_count
    FROM {{ ref('bz_users') }}
    
    UNION ALL
    
    SELECT 
        'meetings' as table_name,
        COUNT(*) as bronze_count
    FROM {{ ref('bz_meetings') }}
    
    UNION ALL
    
    SELECT 
        'participants' as table_name,
        COUNT(*) as bronze_count
    FROM {{ ref('bz_participants') }}
    
    UNION ALL
    
    SELECT 
        'feature_usage' as table_name,
        COUNT(*) as bronze_count
    FROM {{ ref('bz_feature_usage') }}
    
    UNION ALL
    
    SELECT 
        'support_tickets' as table_name,
        COUNT(*) as bronze_count
    FROM {{ ref('bz_support_tickets') }}
    
    UNION ALL
    
    SELECT 
        'billing_events' as table_name,
        COUNT(*) as bronze_count
    FROM {{ ref('bz_billing_events') }}
    
    UNION ALL
    
    SELECT 
        'licenses' as table_name,
        COUNT(*) as bronze_count
    FROM {{ ref('bz_licenses') }}
)

SELECT 
    s.table_name,
    s.source_count,
    b.bronze_count,
    ABS(s.source_count - b.bronze_count) as count_difference
FROM source_counts s
JOIN bronze_counts b ON s.table_name = b.table_name
WHERE s.source_count != b.bronze_count
```

#### Test 5: Referential Integrity Validation
```sql
-- tests/test_referential_integrity.sql
-- Test to validate foreign key relationships

-- Check meetings.host_id references users.user_id
SELECT 
    'meetings_host_id' as relationship_name,
    COUNT(*) as orphaned_records
FROM {{ ref('bz_meetings') }} m
LEFT JOIN {{ ref('bz_users') }} u ON m.host_id = u.user_id
WHERE m.host_id IS NOT NULL 
  AND u.user_id IS NULL

UNION ALL

-- Check participants.meeting_id references meetings.meeting_id
SELECT 
    'participants_meeting_id' as relationship_name,
    COUNT(*) as orphaned_records
FROM {{ ref('bz_participants') }} p
LEFT JOIN {{ ref('bz_meetings') }} m ON p.meeting_id = m.meeting_id
WHERE p.meeting_id IS NOT NULL 
  AND m.meeting_id IS NULL

UNION ALL

-- Check participants.user_id references users.user_id
SELECT 
    'participants_user_id' as relationship_name,
    COUNT(*) as orphaned_records
FROM {{ ref('bz_participants') }} p
LEFT JOIN {{ ref('bz_users') }} u ON p.user_id = u.user_id
WHERE p.user_id IS NOT NULL 
  AND u.user_id IS NULL

UNION ALL

-- Check feature_usage.meeting_id references meetings.meeting_id
SELECT 
    'feature_usage_meeting_id' as relationship_name,
    COUNT(*) as orphaned_records
FROM {{ ref('bz_feature_usage') }} f
LEFT JOIN {{ ref('bz_meetings') }} m ON f.meeting_id = m.meeting_id
WHERE f.meeting_id IS NOT NULL 
  AND m.meeting_id IS NULL

UNION ALL

-- Check support_tickets.user_id references users.user_id
SELECT 
    'support_tickets_user_id' as relationship_name,
    COUNT(*) as orphaned_records
FROM {{ ref('bz_support_tickets') }} s
LEFT JOIN {{ ref('bz_users') }} u ON s.user_id = u.user_id
WHERE s.user_id IS NOT NULL 
  AND u.user_id IS NULL

UNION ALL

-- Check billing_events.user_id references users.user_id
SELECT 
    'billing_events_user_id' as relationship_name,
    COUNT(*) as orphaned_records
FROM {{ ref('bz_billing_events') }} b
LEFT JOIN {{ ref('bz_users') }} u ON b.user_id = u.user_id
WHERE b.user_id IS NOT NULL 
  AND u.user_id IS NULL

UNION ALL

-- Check licenses.assigned_to_user_id references users.user_id
SELECT 
    'licenses_assigned_to_user_id' as relationship_name,
    COUNT(*) as orphaned_records
FROM {{ ref('bz_licenses') }} l
LEFT JOIN {{ ref('bz_users') }} u ON l.assigned_to_user_id = u.user_id
WHERE l.assigned_to_user_id IS NOT NULL 
  AND u.user_id IS NULL

HAVING orphaned_records > 0
```

### Parameterized Tests for Reusability

#### Macro for Primary Key Validation
```sql
-- macros/test_primary_key_validation.sql
{% macro test_primary_key_validation(model_name, primary_key_column) %}

SELECT 
    '{{ model_name }}' as model_name,
    '{{ primary_key_column }}' as primary_key_column,
    COUNT(*) as null_pk_count
FROM {{ ref(model_name) }}
WHERE {{ primary_key_column }} IS NULL

UNION ALL

SELECT 
    '{{ model_name }}' as model_name,
    '{{ primary_key_column }}' as primary_key_column,
    COUNT(*) - COUNT(DISTINCT {{ primary_key_column }}) as duplicate_pk_count
FROM {{ ref(model_name) }}

HAVING null_pk_count > 0 OR duplicate_pk_count > 0

{% endmacro %}
```

#### Usage of Parameterized Test
```sql
-- tests/test_all_primary_keys.sql
{{ test_primary_key_validation('bz_users', 'user_id') }}
UNION ALL
{{ test_primary_key_validation('bz_meetings', 'meeting_id') }}
UNION ALL
{{ test_primary_key_validation('bz_participants', 'participant_id') }}
UNION ALL
{{ test_primary_key_validation('bz_feature_usage', 'usage_id') }}
UNION ALL
{{ test_primary_key_validation('bz_support_tickets', 'ticket_id') }}
UNION ALL
{{ test_primary_key_validation('bz_billing_events', 'event_id') }}
UNION ALL
{{ test_primary_key_validation('bz_licenses', 'license_id') }}
```

---

## Test Execution Strategy

### 1. Pre-deployment Testing
```bash
# Run all tests
dbt test

# Run tests for specific models
dbt test --models bz_users
dbt test --models tag:bronze

# Run only custom tests
dbt test --models test_type:custom
```

### 2. Continuous Integration Testing
```bash
# Run tests with store failures
dbt test --store-failures

# Run tests with specific severity
dbt test --severity error
```

### 3. Performance Testing
```bash
# Run with performance profiling
dbt run --profiles-dir ./profiles --profile zoom_bronze_pipeline
dbt test --profiles-dir ./profiles --profile zoom_bronze_pipeline
```

---

## Expected Test Results

### Success Criteria
- All primary key tests pass (0 NULL values, 0 duplicates)
- All deduplication tests pass (no duplicate records)
- All data type conversion tests pass (graceful handling of invalid data)
- All audit trail tests pass (complete audit records)
- All referential integrity tests pass (valid foreign key relationships)
- All business rule tests pass (valid data ranges and formats)

### Failure Handling
- **Error Severity**: Pipeline stops, requires immediate attention
- **Warning Severity**: Pipeline continues, logged for review
- **Store Failures**: Failed test results stored in Snowflake for analysis

### Monitoring and Alerting
- Test results tracked in dbt's `run_results.json`
- Failed tests logged to Snowflake audit schema
- Automated alerts for critical test failures
- Daily test summary reports

---

## Maintenance and Updates

### Regular Review Schedule
- **Weekly**: Review test results and failure patterns
- **Monthly**: Update test cases based on new requirements
- **Quarterly**: Performance review and optimization

### Test Case Evolution
- Add new tests for schema changes
- Update acceptance criteria for business rule changes
- Enhance edge case coverage based on production issues
- Optimize test performance for large datasets

This comprehensive test suite ensures the reliability, performance, and data quality of the Zoom Bronze Layer pipeline in Snowflake, providing confidence in the data transformations and enabling early detection of potential issues.