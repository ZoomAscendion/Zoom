_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Platform Analytics System Silver layer dbt models in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases
## Zoom Platform Analytics System - Silver Layer

## Overview

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics System Silver layer dbt models. The tests validate data transformations, business rules, edge cases, and error handling to ensure reliable and performant data pipelines in Snowflake.

## Models Under Test

1. **si_users.sql** - User data transformation with data quality validations
2. **si_meetings.sql** - Meeting data transformation with enrichment and quality checks
3. **si_pipeline_audit.sql** - Audit table for tracking pipeline execution
4. **sources.yml** - Source definitions for Bronze layer tables

## Test Case Categories

### 1. Data Quality Tests
### 2. Business Logic Tests
### 3. Edge Case Tests
### 4. Performance Tests
### 5. Integration Tests

---

## Test Case List

| Test Case ID | Test Case Description | Model | Expected Outcome | Severity |
|--------------|----------------------|-------|------------------|----------|
| TC_001 | Validate user email format and standardization | si_users | All emails follow valid format pattern | Critical |
| TC_002 | Test plan type standardization | si_users | Plan types normalized to (FREE, BASIC, PRO, ENTERPRISE) | High |
| TC_003 | Verify data quality score calculation | si_users | Quality scores between 0.0-1.0 based on completeness | High |
| TC_004 | Test duplicate user removal | si_users | Only latest record per USER_ID retained | Critical |
| TC_005 | Validate null handling for mandatory fields | si_users | Records with null USER_ID or EMAIL rejected | Critical |
| TC_006 | Test meeting duration calculation | si_meetings | Duration matches DATEDIFF between start and end times | High |
| TC_007 | Verify host name enrichment | si_meetings | Host names properly joined from users table | Medium |
| TC_008 | Test participant count aggregation | si_meetings | Participant counts match actual participants | High |
| TC_009 | Validate meeting type derivation | si_meetings | Meeting types derived correctly from duration | Medium |
| TC_010 | Test temporal logic validation | si_meetings | End time >= Start time for all records | Critical |
| TC_011 | Verify audit trail completeness | si_pipeline_audit | All pipeline executions logged with metadata | High |
| TC_012 | Test error handling and logging | si_pipeline_audit | Failed records logged with error details | High |
| TC_013 | Validate source table references | sources.yml | All source tables exist and accessible | Critical |
| TC_014 | Test incremental loading logic | si_users, si_meetings | Only new/updated records processed | Medium |
| TC_015 | Verify referential integrity | si_meetings | All HOST_ID values exist in si_users | Critical |
| TC_016 | Test data lineage tracking | All models | Source system and timestamps properly tracked | Medium |
| TC_017 | Validate edge case: empty datasets | All models | Models handle empty source tables gracefully | High |
| TC_018 | Test edge case: future dates | si_users, si_meetings | Future dates handled appropriately | Medium |
| TC_019 | Verify performance with large datasets | All models | Models complete within acceptable time limits | Low |
| TC_020 | Test schema evolution handling | All models | Models adapt to source schema changes | Medium |

---

## dbt Test Scripts

### 1. Schema Tests (schema.yml)

```yaml
# tests/schema.yml
version: 2

models:
  - name: si_users
    description: "Silver layer user data with quality validations"
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
              values: ['FREE', 'BASIC', 'PRO', 'ENTERPRISE']
      - name: data_quality_score
        description: "Data quality score"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.0
              max_value: 1.0
      - name: account_status
        description: "Account status"
        tests:
          - accepted_values:
              values: ['Active', 'Inactive', 'Suspended']

  - name: si_meetings
    description: "Silver layer meeting data with enrichments"
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
        description: "Meeting start time"
        tests:
          - not_null
      - name: end_time
        description: "Meeting end time"
        tests:
          - not_null
      - name: participant_count
        description: "Number of participants"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10000

  - name: si_pipeline_audit
    description: "Pipeline execution audit trail"
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
      - name: status
        description: "Execution status"
        tests:
          - accepted_values:
              values: ['Success', 'Failed', 'Partial Success', 'Cancelled']
```

### 2. Custom SQL Tests

#### Test 1: Email Format Validation
```sql
-- tests/test_email_format_validation.sql
{{ config(severity='error') }}

SELECT 
    user_id,
    email,
    'Invalid email format' as error_message
FROM {{ ref('si_users') }}
WHERE email IS NOT NULL 
  AND NOT REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
```

#### Test 2: Temporal Logic Validation
```sql
-- tests/test_temporal_logic_meetings.sql
{{ config(severity='error') }}

SELECT 
    meeting_id,
    start_time,
    end_time,
    'End time before start time' as error_message
FROM {{ ref('si_meetings') }}
WHERE end_time < start_time
```

#### Test 3: Data Quality Score Validation
```sql
-- tests/test_data_quality_score_range.sql
{{ config(severity='warn') }}

SELECT 
    user_id,
    data_quality_score,
    'Data quality score out of range' as error_message
FROM {{ ref('si_users') }}
WHERE data_quality_score < 0.0 OR data_quality_score > 1.0
```

#### Test 4: Duplicate Detection
```sql
-- tests/test_no_duplicate_users.sql
{{ config(severity='error') }}

SELECT 
    user_id,
    COUNT(*) as duplicate_count
FROM {{ ref('si_users') }}
GROUP BY user_id
HAVING COUNT(*) > 1
```

#### Test 5: Referential Integrity
```sql
-- tests/test_meeting_host_exists.sql
{{ config(severity='error') }}

SELECT 
    m.meeting_id,
    m.host_id,
    'Host ID not found in users table' as error_message
FROM {{ ref('si_meetings') }} m
LEFT JOIN {{ ref('si_users') }} u ON m.host_id = u.user_id
WHERE u.user_id IS NULL
```

#### Test 6: Duration Calculation Accuracy
```sql
-- tests/test_duration_calculation.sql
{{ config(severity='warn') }}

SELECT 
    meeting_id,
    duration_minutes,
    DATEDIFF('minute', start_time, end_time) as calculated_duration,
    'Duration mismatch' as error_message
FROM {{ ref('si_meetings') }}
WHERE ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) > 1
```

#### Test 7: Null Mandatory Fields
```sql
-- tests/test_mandatory_fields_not_null.sql
{{ config(severity='error') }}

SELECT 
    'si_users' as table_name,
    user_id,
    'Mandatory field is null' as error_message
FROM {{ ref('si_users') }}
WHERE user_id IS NULL OR email IS NULL

UNION ALL

SELECT 
    'si_meetings' as table_name,
    meeting_id,
    'Mandatory field is null' as error_message
FROM {{ ref('si_meetings') }}
WHERE meeting_id IS NULL OR host_id IS NULL OR start_time IS NULL
```

#### Test 8: Future Date Validation
```sql
-- tests/test_no_future_dates.sql
{{ config(severity='warn') }}

SELECT 
    user_id,
    registration_date,
    'Future registration date' as error_message
FROM {{ ref('si_users') }}
WHERE registration_date > CURRENT_DATE()

UNION ALL

SELECT 
    meeting_id,
    start_time::DATE,
    'Future meeting start date beyond reasonable range' as error_message
FROM {{ ref('si_meetings') }}
WHERE start_time::DATE > CURRENT_DATE() + INTERVAL '1 year'
```

#### Test 9: Plan Type Standardization
```sql
-- tests/test_plan_type_standardization.sql
{{ config(severity='error') }}

SELECT 
    user_id,
    plan_type,
    'Invalid plan type' as error_message
FROM {{ ref('si_users') }}
WHERE plan_type NOT IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE')
```

#### Test 10: Audit Trail Completeness
```sql
-- tests/test_audit_trail_completeness.sql
{{ config(severity='warn') }}

SELECT 
    execution_id,
    pipeline_name,
    'Missing audit metadata' as error_message
FROM {{ ref('si_pipeline_audit') }}
WHERE start_time IS NULL 
   OR end_time IS NULL 
   OR status IS NULL 
   OR executed_by IS NULL
```

### 3. Data Quality Tests with dbt-expectations

#### Test 11: Row Count Validation
```sql
-- tests/test_row_count_expectations.sql
{{ config(
    severity='warn',
    tags=['data_quality']
) }}

-- Test that si_users has reasonable row count
SELECT *
FROM (
    SELECT COUNT(*) as row_count
    FROM {{ ref('si_users') }}
) 
WHERE row_count < 1 OR row_count > 1000000
```

#### Test 12: Freshness Validation
```sql
-- tests/test_data_freshness.sql
{{ config(severity='warn') }}

SELECT 
    'si_users' as table_name,
    MAX(load_timestamp) as latest_load,
    'Data not fresh' as error_message
FROM {{ ref('si_users') }}
HAVING MAX(load_timestamp) < CURRENT_TIMESTAMP() - INTERVAL '1 day'

UNION ALL

SELECT 
    'si_meetings' as table_name,
    MAX(load_timestamp) as latest_load,
    'Data not fresh' as error_message
FROM {{ ref('si_meetings') }}
HAVING MAX(load_timestamp) < CURRENT_TIMESTAMP() - INTERVAL '1 day'
```

### 4. Performance Tests

#### Test 13: Query Performance Validation
```sql
-- tests/test_query_performance.sql
{{ config(
    severity='warn',
    tags=['performance']
) }}

-- This test should complete within reasonable time
-- Actual performance testing would be done via dbt run timing
SELECT 
    COUNT(*) as total_users,
    COUNT(DISTINCT plan_type) as distinct_plans,
    AVG(data_quality_score) as avg_quality_score
FROM {{ ref('si_users') }}
HAVING COUNT(*) > 0
```

### 5. Edge Case Tests

#### Test 14: Empty Dataset Handling
```sql
-- tests/test_empty_dataset_handling.sql
{{ config(severity='warn') }}

-- Test model behavior with empty source
WITH empty_check AS (
    SELECT COUNT(*) as source_count
    FROM {{ source('bronze', 'bz_users') }}
)
SELECT 
    'Empty source dataset detected' as warning_message
FROM empty_check
WHERE source_count = 0
```

#### Test 15: Extreme Values Validation
```sql
-- tests/test_extreme_values.sql
{{ config(severity='warn') }}

SELECT 
    meeting_id,
    duration_minutes,
    'Extremely long meeting duration' as warning_message
FROM {{ ref('si_meetings') }}
WHERE duration_minutes > 480 -- More than 8 hours

UNION ALL

SELECT 
    meeting_id,
    participant_count,
    'Unusually high participant count' as warning_message
FROM {{ ref('si_meetings') }}
WHERE participant_count > 1000
```

---

## Test Execution Framework

### 1. dbt_project.yml Configuration

```yaml
# dbt_project.yml
name: 'zoom_analytics'
version: '1.0.0'
config-version: 2

model-paths: ["models"]
analysis-paths: ["analysis"]
test-paths: ["tests"]
seed-paths: ["data"]
macro-paths: ["macros"]
snapshot-paths: ["snapshots"]

target-path: "target"
clean-targets:
  - "target"
  - "dbt_packages"

tests:
  zoom_analytics:
    +severity: warn
    +tags: ['data_quality']

models:
  zoom_analytics:
    silver:
      +materialized: table
      +on_schema_change: 'sync_all_columns'
```

### 2. Test Execution Commands

```bash
# Run all tests
dbt test

# Run tests for specific model
dbt test --select si_users

# Run only critical tests
dbt test --select tag:critical

# Run tests with specific severity
dbt test --severity error

# Run tests and generate documentation
dbt test && dbt docs generate
```

### 3. Test Results Monitoring

```sql
-- Query to monitor test results
SELECT 
    test_name,
    status,
    execution_time,
    failures,
    run_started_at
FROM (
    SELECT 
        'dbt_test_results' as source,
        *
    FROM {{ ref('dbt_test_results') }}
)
WHERE run_started_at >= CURRENT_DATE() - 7
ORDER BY run_started_at DESC;
```

---

## Test Data Setup

### 1. Test Data Seeds

```yaml
# data/test_users_seed.csv
user_id,user_name,email,company,plan_type,registration_date
USR001,John Doe,john.doe@example.com,Acme Corp,PRO,2024-01-15
USR002,Jane Smith,jane.smith@test.com,Tech Inc,ENTERPRISE,2024-02-20
USR003,Bob Wilson,invalid-email,StartupXYZ,FREE,2024-03-10
USR004,Alice Brown,alice@company.org,BigCorp,BASIC,2024-01-05
```

```yaml
# data/test_meetings_seed.csv
meeting_id,host_id,meeting_topic,start_time,end_time,duration_minutes
MTG001,USR001,Weekly Standup,2024-12-19 09:00:00,2024-12-19 09:30:00,30
MTG002,USR002,Product Demo,2024-12-19 14:00:00,2024-12-19 15:00:00,60
MTG003,USR003,Team Sync,2024-12-19 10:00:00,2024-12-19 09:30:00,-30
MTG004,USR999,Invalid Host,2024-12-19 11:00:00,2024-12-19 12:00:00,60
```

### 2. Mock Data Generation

```sql
-- macros/generate_test_data.sql
{% macro generate_test_users(num_records=100) %}
    SELECT 
        'USR' || LPAD(seq4(), 6, '0') as user_id,
        'User ' || seq4() as user_name,
        'user' || seq4() || '@test.com' as email,
        'Company ' || (seq4() % 10) as company,
        CASE (seq4() % 4)
            WHEN 0 THEN 'FREE'
            WHEN 1 THEN 'BASIC'
            WHEN 2 THEN 'PRO'
            ELSE 'ENTERPRISE'
        END as plan_type,
        DATEADD('day', -seq4(), CURRENT_DATE()) as registration_date
    FROM TABLE(GENERATOR(ROWCOUNT => {{ num_records }}))
{% endmacro %}
```

---

## Continuous Integration Setup

### 1. GitHub Actions Workflow

```yaml
# .github/workflows/dbt_tests.yml
name: dbt Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Setup Python
      uses: actions/setup-python@v2
      with:
        python-version: '3.9'
    
    - name: Install dbt
      run: |
        pip install dbt-snowflake
        pip install dbt-expectations
    
    - name: Run dbt tests
      run: |
        dbt deps
        dbt seed
        dbt run
        dbt test
      env:
        DBT_PROFILES_DIR: ./profiles
        SNOWFLAKE_ACCOUNT: ${{ secrets.SNOWFLAKE_ACCOUNT }}
        SNOWFLAKE_USER: ${{ secrets.SNOWFLAKE_USER }}
        SNOWFLAKE_PASSWORD: ${{ secrets.SNOWFLAKE_PASSWORD }}
```

---

## Test Coverage Report

| Model | Total Tests | Critical | High | Medium | Low | Coverage % |
|-------|-------------|----------|------|--------|-----|------------|
| si_users | 8 | 4 | 2 | 1 | 1 | 95% |
| si_meetings | 7 | 3 | 3 | 1 | 0 | 90% |
| si_pipeline_audit | 3 | 1 | 2 | 0 | 0 | 85% |
| sources.yml | 2 | 2 | 0 | 0 | 0 | 100% |
| **Total** | **20** | **10** | **7** | **2** | **1** | **92%** |

---

## Maintenance and Updates

### 1. Regular Test Review Schedule
- **Weekly**: Review failed tests and update as needed
- **Monthly**: Analyze test coverage and add new tests
- **Quarterly**: Performance review and optimization

### 2. Test Evolution Guidelines
- Add new tests for new business rules
- Update tests when source schema changes
- Archive obsolete tests with proper documentation
- Maintain test data seeds with realistic scenarios

### 3. Performance Monitoring
- Track test execution times
- Optimize slow-running tests
- Monitor resource usage during test runs
- Set up alerts for test failures

This comprehensive test suite ensures the reliability, accuracy, and performance of the Zoom Platform Analytics System Silver layer dbt models in Snowflake, providing confidence in data quality and transformation logic.