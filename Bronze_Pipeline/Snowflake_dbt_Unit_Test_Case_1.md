_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Bronze Layer dbt models in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases - Zoom Bronze Layer Pipeline

## Overview

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics Bronze Layer dbt models running in Snowflake. The test suite covers data transformations, business rules, edge cases, and error handling scenarios to ensure reliable and performant dbt models.

## Test Strategy

The testing approach follows dbt best practices and covers:
- **Data Quality Tests**: Primary key uniqueness, null value validation
- **Business Logic Tests**: Data type conversions, deduplication logic
- **Edge Case Tests**: Null handling, empty datasets, invalid data
- **Audit Trail Tests**: Pre/post hook validation, audit logging
- **Performance Tests**: Large dataset handling, query optimization

## Models Under Test

1. **bz_data_audit** - Audit trail table
2. **bz_users** - User profile and subscription data
3. **bz_meetings** - Meeting information and session details
4. **bz_participants** - Meeting participants tracking
5. **bz_feature_usage** - Platform feature usage records
6. **bz_support_tickets** - Customer support requests
7. **bz_billing_events** - Financial transactions and billing
8. **bz_licenses** - License assignments and entitlements

---

## Test Case List

### 1. Data Quality and Integrity Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) Tested |
|--------------|----------------------|------------------|----------------|
| TC_DQ_001 | Validate primary key uniqueness for all Bronze tables | All primary keys should be unique with no duplicates | All models |
| TC_DQ_002 | Validate primary key not null constraint | No null values in primary key columns | All models |
| TC_DQ_003 | Validate data type consistency between source and target | All data types match schema definitions | All models |
| TC_DQ_004 | Validate timestamp format consistency | All timestamps in TIMESTAMP_NTZ(9) format | All models |
| TC_DQ_005 | Validate metadata column population | LOAD_TIMESTAMP, UPDATE_TIMESTAMP, SOURCE_SYSTEM populated | All models |

### 2. Business Logic and Transformation Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) Tested |
|--------------|----------------------|------------------|----------------|
| TC_BL_001 | Validate deduplication logic based on primary key and timestamps | Only latest record per primary key retained | All models |
| TC_BL_002 | Validate TRY_CAST functions for data type conversions | Invalid data converted to NULL without errors | bz_meetings, bz_participants, bz_billing_events, bz_licenses |
| TC_BL_003 | Validate NULL primary key filtering | Records with NULL primary keys excluded | All models |
| TC_BL_004 | Validate ROW_NUMBER() deduplication logic | Correct ranking based on LOAD_TIMESTAMP DESC | All models |
| TC_BL_005 | Validate 1-1 mapping from RAW to BRONZE | All source columns mapped correctly | All models |

### 3. Edge Case and Error Handling Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) Tested |
|--------------|----------------------|------------------|----------------|
| TC_EC_001 | Handle empty source tables | Models execute successfully with empty result sets | All models |
| TC_EC_002 | Handle invalid date/timestamp formats | TRY_CAST returns NULL for invalid formats | bz_meetings, bz_participants, bz_licenses |
| TC_EC_003 | Handle invalid numeric formats | TRY_CAST returns NULL for invalid numbers | bz_meetings, bz_billing_events |
| TC_EC_004 | Handle extremely large VARCHAR values | Values truncated or handled gracefully | All models |
| TC_EC_005 | Handle special characters and Unicode | Special characters preserved correctly | All models |

### 4. Audit Trail and Logging Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) Tested |
|--------------|----------------------|------------------|----------------|
| TC_AT_001 | Validate audit table initialization | bz_data_audit table created with initial record | bz_data_audit |
| TC_AT_002 | Validate pre-hook audit logging | START status logged before model execution | All models except bz_data_audit |
| TC_AT_003 | Validate post-hook audit logging | SUCCESS status logged after model execution | All models except bz_data_audit |
| TC_AT_004 | Validate processing time calculation | Accurate processing time recorded in seconds | All models except bz_data_audit |
| TC_AT_005 | Validate auto-incrementing RECORD_ID | Sequential RECORD_ID values generated | bz_data_audit |

### 5. Performance and Scalability Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) Tested |
|--------------|----------------------|------------------|----------------|
| TC_PS_001 | Validate performance with large datasets (1M+ records) | Models complete within acceptable time limits | All models |
| TC_PS_002 | Validate memory usage during processing | No memory overflow or timeout errors | All models |
| TC_PS_003 | Validate concurrent execution handling | Models handle concurrent runs without conflicts | All models |
| TC_PS_004 | Validate incremental processing capability | Only new/changed records processed efficiently | All models |
| TC_PS_005 | Validate Snowflake warehouse scaling | Models utilize warehouse resources effectively | All models |

---

## dbt Test Scripts

### YAML-based Schema Tests

#### 1. Enhanced Schema Tests (models/bronze/schema.yml)

```yaml
version: 2

sources:
  - name: raw
    description: "Raw data layer containing unprocessed data from various source systems"
    database: DB_POC_ZOOM
    schema: RAW
    tables:
      - name: users
        description: "Raw user profile and subscription information"
        columns:
          - name: user_id
            description: "Unique identifier for each user account"
            tests:
              - not_null:
                  severity: error
              - unique:
                  severity: error
          - name: email
            description: "Email address of the user"
            tests:
              - not_null:
                  severity: warn
      
      - name: meetings
        description: "Raw meeting information and session details"
        columns:
          - name: meeting_id
            description: "Unique identifier for each meeting"
            tests:
              - not_null:
                  severity: error
              - unique:
                  severity: error
          - name: duration_minutes
            description: "Meeting duration in minutes"
            tests:
              - dbt_expectations.expect_column_values_to_be_of_type:
                  column_type: number

models:
  - name: bz_data_audit
    description: "Comprehensive audit trail for all Bronze layer data operations"
    tests:
      - dbt_utils.expression_is_true:
          expression: "record_id > 0"
          config:
            severity: error
    columns:
      - name: record_id
        description: "Auto-incrementing unique identifier for each audit record"
        tests:
          - not_null:
              severity: error
          - unique:
              severity: error
      - name: source_table
        description: "Name of the Bronze layer table"
        tests:
          - not_null:
              severity: error
          - accepted_values:
              values: ['BZ_USERS', 'BZ_MEETINGS', 'BZ_PARTICIPANTS', 'BZ_FEATURE_USAGE', 'BZ_SUPPORT_TICKETS', 'BZ_BILLING_EVENTS', 'BZ_LICENSES', 'BZ_DATA_AUDIT', 'AUDIT_INIT']
              severity: warn
      - name: status
        description: "Status of the operation"
        tests:
          - not_null:
              severity: error
          - accepted_values:
              values: ['STARTED', 'SUCCESS', 'FAILED', 'WARNING', 'CREATED', 'INITIALIZED']
              severity: error

  - name: bz_users
    description: "Bronze layer table storing user profile and subscription information"
    tests:
      - dbt_utils.expression_is_true:
          expression: "load_timestamp <= current_timestamp()"
          config:
            severity: error
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - user_id
            - load_timestamp
          config:
            severity: warn
    columns:
      - name: user_id
        description: "Unique identifier for each user account"
        tests:
          - not_null:
              severity: error
          - unique:
              severity: error
      - name: email
        description: "Email address of the user"
        tests:
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
              config:
                severity: warn
      - name: plan_type
        description: "Subscription plan type"
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise']
              config:
                severity: warn
      - name: load_timestamp
        description: "Timestamp when record was loaded into Bronze layer"
        tests:
          - not_null:
              severity: error
      - name: source_system
        description: "Source system from which data originated"
        tests:
          - not_null:
              severity: error

  - name: bz_meetings
    description: "Bronze layer table storing meeting information and session details"
    tests:
      - dbt_utils.expression_is_true:
          expression: "start_time <= coalesce(end_time, current_timestamp())"
          config:
            severity: warn
      - dbt_utils.expression_is_true:
          expression: "duration_minutes >= 0 OR duration_minutes IS NULL"
          config:
            severity: error
    columns:
      - name: meeting_id
        description: "Unique identifier for each meeting"
        tests:
          - not_null:
              severity: error
          - unique:
              severity: error
      - name: host_id
        description: "User ID of the meeting host"
        tests:
          - not_null:
              severity: warn
      - name: duration_minutes
        description: "Meeting duration in minutes"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440  # 24 hours
              config:
                severity: warn

  - name: bz_participants
    description: "Bronze layer table tracking meeting participants and their session details"
    tests:
      - dbt_utils.expression_is_true:
          expression: "join_time <= coalesce(leave_time, current_timestamp())"
          config:
            severity: warn
    columns:
      - name: participant_id
        description: "Unique identifier for each meeting participant"
        tests:
          - not_null:
              severity: error
          - unique:
              severity: error
      - name: meeting_id
        description: "Reference to meeting"
        tests:
          - not_null:
              severity: error
      - name: user_id
        description: "Reference to user who participated"
        tests:
          - not_null:
              severity: warn

  - name: bz_feature_usage
    description: "Bronze layer table recording usage of platform features during meetings"
    tests:
      - dbt_utils.expression_is_true:
          expression: "usage_count >= 0 OR usage_count IS NULL"
          config:
            severity: error
    columns:
      - name: usage_id
        description: "Unique identifier for each feature usage record"
        tests:
          - not_null:
              severity: error
          - unique:
              severity: error
      - name: usage_count
        description: "Number of times feature was used"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10000
              config:
                severity: warn

  - name: bz_support_tickets
    description: "Bronze layer table managing customer support requests and resolution tracking"
    columns:
      - name: ticket_id
        description: "Unique identifier for each support ticket"
        tests:
          - not_null:
              severity: error
          - unique:
              severity: error
      - name: resolution_status
        description: "Current status of ticket resolution"
        tests:
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed', 'Pending']
              config:
                severity: warn

  - name: bz_billing_events
    description: "Bronze layer table tracking financial transactions and billing activities"
    tests:
      - dbt_utils.expression_is_true:
          expression: "amount >= 0 OR amount IS NULL"
          config:
            severity: warn
    columns:
      - name: event_id
        description: "Unique identifier for each billing event"
        tests:
          - not_null:
              severity: error
          - unique:
              severity: error
      - name: amount
        description: "Monetary amount for the billing event"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100000
              config:
                severity: warn

  - name: bz_licenses
    description: "Bronze layer table managing license assignments and entitlements"
    tests:
      - dbt_utils.expression_is_true:
          expression: "start_date <= coalesce(end_date, current_date())"
          config:
            severity: warn
    columns:
      - name: license_id
        description: "Unique identifier for each license"
        tests:
          - not_null:
              severity: error
          - unique:
              severity: error
      - name: assigned_to_user_id
        description: "User ID to whom license is assigned"
        tests:
          - not_null:
              severity: warn
```

### Custom SQL-based dbt Tests

#### 2. Data Consistency Tests (tests/data_consistency/)

##### test_bronze_row_counts.sql
```sql
-- Test: Validate that Bronze layer has expected row counts compared to RAW layer
-- Expected: Bronze row count should be <= RAW row count (due to deduplication)

WITH raw_counts AS (
    SELECT 
        'users' as table_name,
        COUNT(*) as raw_count
    FROM {{ source('raw', 'users') }}
    
    UNION ALL
    
    SELECT 
        'meetings' as table_name,
        COUNT(*) as raw_count
    FROM {{ source('raw', 'meetings') }}
    
    UNION ALL
    
    SELECT 
        'participants' as table_name,
        COUNT(*) as raw_count
    FROM {{ source('raw', 'participants') }}
    
    UNION ALL
    
    SELECT 
        'feature_usage' as table_name,
        COUNT(*) as raw_count
    FROM {{ source('raw', 'feature_usage') }}
    
    UNION ALL
    
    SELECT 
        'support_tickets' as table_name,
        COUNT(*) as raw_count
    FROM {{ source('raw', 'support_tickets') }}
    
    UNION ALL
    
    SELECT 
        'billing_events' as table_name,
        COUNT(*) as raw_count
    FROM {{ source('raw', 'billing_events') }}
    
    UNION ALL
    
    SELECT 
        'licenses' as table_name,
        COUNT(*) as raw_count
    FROM {{ source('raw', 'licenses') }}
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
    r.table_name,
    r.raw_count,
    b.bronze_count,
    CASE 
        WHEN b.bronze_count > r.raw_count THEN 'FAIL: Bronze count exceeds RAW count'
        ELSE 'PASS'
    END as test_result
FROM raw_counts r
JOIN bronze_counts b ON r.table_name = b.table_name
WHERE b.bronze_count > r.raw_count
```

##### test_deduplication_logic.sql
```sql
-- Test: Validate deduplication logic works correctly
-- Expected: No duplicate primary keys in Bronze tables

WITH duplicate_check AS (
    SELECT 
        'bz_users' as table_name,
        user_id as primary_key,
        COUNT(*) as duplicate_count
    FROM {{ ref('bz_users') }}
    GROUP BY user_id
    HAVING COUNT(*) > 1
    
    UNION ALL
    
    SELECT 
        'bz_meetings' as table_name,
        meeting_id as primary_key,
        COUNT(*) as duplicate_count
    FROM {{ ref('bz_meetings') }}
    GROUP BY meeting_id
    HAVING COUNT(*) > 1
    
    UNION ALL
    
    SELECT 
        'bz_participants' as table_name,
        participant_id as primary_key,
        COUNT(*) as duplicate_count
    FROM {{ ref('bz_participants') }}
    GROUP BY participant_id
    HAVING COUNT(*) > 1
    
    UNION ALL
    
    SELECT 
        'bz_feature_usage' as table_name,
        usage_id as primary_key,
        COUNT(*) as duplicate_count
    FROM {{ ref('bz_feature_usage') }}
    GROUP BY usage_id
    HAVING COUNT(*) > 1
    
    UNION ALL
    
    SELECT 
        'bz_support_tickets' as table_name,
        ticket_id as primary_key,
        COUNT(*) as duplicate_count
    FROM {{ ref('bz_support_tickets') }}
    GROUP BY ticket_id
    HAVING COUNT(*) > 1
    
    UNION ALL
    
    SELECT 
        'bz_billing_events' as table_name,
        event_id as primary_key,
        COUNT(*) as duplicate_count
    FROM {{ ref('bz_billing_events') }}
    GROUP BY event_id
    HAVING COUNT(*) > 1
    
    UNION ALL
    
    SELECT 
        'bz_licenses' as table_name,
        license_id as primary_key,
        COUNT(*) as duplicate_count
    FROM {{ ref('bz_licenses') }}
    GROUP BY license_id
    HAVING COUNT(*) > 1
)

SELECT *
FROM duplicate_check
```

##### test_audit_trail_completeness.sql
```sql
-- Test: Validate audit trail completeness
-- Expected: Each Bronze table should have corresponding audit entries

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

audit_tables AS (
    SELECT DISTINCT source_table
    FROM {{ ref('bz_data_audit') }}
    WHERE source_table != 'BZ_DATA_AUDIT'
      AND source_table != 'AUDIT_INIT'
)

SELECT 
    e.table_name,
    CASE 
        WHEN a.source_table IS NULL THEN 'FAIL: Missing audit entries'
        ELSE 'PASS'
    END as test_result
FROM expected_tables e
LEFT JOIN audit_tables a ON e.table_name = a.source_table
WHERE a.source_table IS NULL
```

#### 3. Data Type Conversion Tests (tests/data_types/)

##### test_try_cast_functions.sql
```sql
-- Test: Validate TRY_CAST functions handle invalid data gracefully
-- Expected: Invalid data should convert to NULL without causing errors

WITH test_data AS (
    SELECT 
        'bz_meetings' as table_name,
        'end_time' as column_name,
        COUNT(*) as total_records,
        COUNT(end_time) as valid_records,
        COUNT(*) - COUNT(end_time) as null_records
    FROM {{ ref('bz_meetings') }}
    
    UNION ALL
    
    SELECT 
        'bz_meetings' as table_name,
        'duration_minutes' as column_name,
        COUNT(*) as total_records,
        COUNT(duration_minutes) as valid_records,
        COUNT(*) - COUNT(duration_minutes) as null_records
    FROM {{ ref('bz_meetings') }}
    
    UNION ALL
    
    SELECT 
        'bz_participants' as table_name,
        'join_time' as column_name,
        COUNT(*) as total_records,
        COUNT(join_time) as valid_records,
        COUNT(*) - COUNT(join_time) as null_records
    FROM {{ ref('bz_participants') }}
    
    UNION ALL
    
    SELECT 
        'bz_billing_events' as table_name,
        'amount' as column_name,
        COUNT(*) as total_records,
        COUNT(amount) as valid_records,
        COUNT(*) - COUNT(amount) as null_records
    FROM {{ ref('bz_billing_events') }}
    
    UNION ALL
    
    SELECT 
        'bz_licenses' as table_name,
        'end_date' as column_name,
        COUNT(*) as total_records,
        COUNT(end_date) as valid_records,
        COUNT(*) - COUNT(end_date) as null_records
    FROM {{ ref('bz_licenses') }}
)

SELECT 
    table_name,
    column_name,
    total_records,
    valid_records,
    null_records,
    ROUND((valid_records::FLOAT / total_records::FLOAT) * 100, 2) as conversion_success_rate
FROM test_data
WHERE total_records > 0
ORDER BY table_name, column_name
```

#### 4. Performance Tests (tests/performance/)

##### test_model_execution_time.sql
```sql
-- Test: Monitor model execution times
-- Expected: Models should complete within acceptable time limits

SELECT 
    source_table,
    AVG(processing_time) as avg_processing_time,
    MAX(processing_time) as max_processing_time,
    MIN(processing_time) as min_processing_time,
    COUNT(*) as execution_count,
    CASE 
        WHEN MAX(processing_time) > 300 THEN 'WARN: Execution time exceeds 5 minutes'
        WHEN MAX(processing_time) > 600 THEN 'FAIL: Execution time exceeds 10 minutes'
        ELSE 'PASS'
    END as performance_status
FROM {{ ref('bz_data_audit') }}
WHERE status = 'SUCCESS'
  AND processing_time IS NOT NULL
  AND processing_time > 0
GROUP BY source_table
HAVING MAX(processing_time) > 300
ORDER BY max_processing_time DESC
```

### Parameterized Tests

#### 5. Generic Test Macros (macros/)

##### test_bronze_table_structure.sql
```sql
-- Macro: Test Bronze table structure consistency
{% macro test_bronze_table_structure(model_name, expected_columns) %}

    SELECT 
        '{{ model_name }}' as table_name,
        column_name,
        data_type,
        is_nullable
    FROM information_schema.columns
    WHERE table_schema = 'BRONZE'
      AND table_name = UPPER('{{ model_name }}')
      AND column_name NOT IN ({{ expected_columns | join("', '") | upper }})

{% endmacro %}
```

##### test_metadata_columns.sql
```sql
-- Macro: Test metadata columns presence and population
{% macro test_metadata_columns(model_name) %}

    SELECT 
        '{{ model_name }}' as table_name,
        COUNT(*) as total_records,
        COUNT(load_timestamp) as load_timestamp_populated,
        COUNT(source_system) as source_system_populated,
        CASE 
            WHEN COUNT(load_timestamp) != COUNT(*) THEN 'FAIL: Missing load_timestamp'
            WHEN COUNT(source_system) != COUNT(*) THEN 'FAIL: Missing source_system'
            ELSE 'PASS'
        END as metadata_status
    FROM {{ ref(model_name) }}
    HAVING COUNT(load_timestamp) != COUNT(*) 
        OR COUNT(source_system) != COUNT(*)

{% endmacro %}
```

## Test Execution Strategy

### 1. Continuous Integration Tests
```bash
# Run all tests
dbt test

# Run specific test types
dbt test --select tag:data_quality
dbt test --select tag:business_logic
dbt test --select tag:edge_cases

# Run tests for specific models
dbt test --select bz_users
dbt test --select bz_meetings+
```

### 2. Test Severity Configuration
```yaml
# dbt_project.yml
tests:
  zoom_bronze_pipeline:
    +store_failures: true
    +severity: error
    data_quality:
      +severity: error
    business_logic:
      +severity: warn
    performance:
      +severity: warn
```

### 3. Test Documentation
```yaml
# Generate test documentation
dbt docs generate
dbt docs serve
```

## Expected Test Results

### Success Criteria
- ✅ All primary key uniqueness tests pass
- ✅ All not_null tests pass for critical columns
- ✅ Data type conversion tests show >95% success rate
- ✅ Deduplication logic eliminates all duplicates
- ✅ Audit trail captures all model executions
- ✅ Performance tests complete within time limits

### Warning Criteria
- ⚠️ Email format validation shows <90% compliance
- ⚠️ Business rule violations in accepted_values tests
- ⚠️ Performance degradation beyond baseline

### Failure Criteria
- ❌ Any primary key constraint violations
- ❌ Critical column null value violations
- ❌ Model execution failures or timeouts
- ❌ Data type conversion errors causing job failures

## Monitoring and Alerting

### 1. Test Results Tracking
```sql
-- Query to monitor test results over time
SELECT 
    test_name,
    status,
    execution_time,
    failures,
    run_started_at
FROM dbt_test_results
WHERE run_started_at >= CURRENT_DATE - 7
ORDER BY run_started_at DESC;
```

### 2. Automated Alerts
- Slack notifications for test failures
- Email alerts for critical data quality issues
- Dashboard monitoring for performance metrics

## Maintenance and Updates

### 1. Test Review Schedule
- **Weekly**: Review test results and performance metrics
- **Monthly**: Update test thresholds and add new test cases
- **Quarterly**: Comprehensive test suite review and optimization

### 2. Test Evolution
- Add new tests as business requirements change
- Update test parameters based on data patterns
- Retire obsolete tests to maintain efficiency

---

## Summary

This comprehensive test suite ensures the reliability, performance, and data quality of the Zoom Bronze Layer dbt models in Snowflake. The tests cover:

- **35+ individual test cases** across 5 categories
- **YAML-based schema tests** for standard validations
- **Custom SQL tests** for complex business logic
- **Parameterized macros** for reusable test patterns
- **Performance monitoring** and alerting capabilities

The test framework provides:
- Early detection of data quality issues
- Validation of business rules and transformations
- Performance monitoring and optimization insights
- Comprehensive audit trail validation
- Automated failure detection and alerting

Regular execution of these tests ensures the Bronze layer maintains high data quality standards and supports reliable downstream Silver and Gold layer processing in the Medallion architecture.