_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Silver Layer dbt models in Snowflake
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases - Zoom Silver Layer Pipeline

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Silver Layer pipeline models running in Snowflake. The test cases cover data transformations, business rules, edge cases, and error handling scenarios for the following models:

- `audit_log.sql` - Pipeline execution audit tracking
- `si_users.sql` - Silver layer users with data quality validations
- `si_meetings.sql` - Silver layer meetings with enriched data
- `schema.yml` - Schema definitions and built-in tests

## Test Case List

### 1. SI_USERS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_SU_001 | Validate user data cleansing and standardization | User names properly capitalized, emails lowercased, plan types standardized |
| TC_SU_002 | Test duplicate removal logic | Only latest record per USER_ID retained based on UPDATE_TIMESTAMP |
| TC_SU_003 | Validate data quality scoring algorithm | Scores calculated correctly (0.25-1.00) based on completeness and validity |
| TC_SU_004 | Test email format validation | Only valid email formats accepted, invalid emails handled gracefully |
| TC_SU_005 | Validate account status derivation | Status correctly derived based on last login date thresholds |
| TC_SU_006 | Test plan type standardization | Invalid plan types defaulted to 'FREE' |
| TC_SU_007 | Validate null handling in critical fields | Records with null USER_ID filtered out |
| TC_SU_008 | Test data quality threshold filtering | Only records with quality score >= 0.50 included |
| TC_SU_009 | Validate date transformations | LOAD_TIMESTAMP and UPDATE_TIMESTAMP properly converted to dates |
| TC_SU_010 | Test edge case: empty string handling | Empty strings in USER_ID filtered out |

### 2. SI_MEETINGS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_SM_001 | Validate meeting type classification | Meetings correctly classified as Webinar, Instant, Personal, or Scheduled |
| TC_SM_002 | Test duration calculation logic | Duration calculated as maximum of provided duration and time difference |
| TC_SM_003 | Validate meeting status derivation | Status correctly derived based on current time vs start/end times |
| TC_SM_004 | Test host information enrichment | Host names properly joined from users table |
| TC_SM_005 | Validate participant count aggregation | Participant counts correctly aggregated from participants table |
| TC_SM_006 | Test duplicate removal for meetings | Only latest meeting record per MEETING_ID retained |
| TC_SM_007 | Validate time-based filtering | Invalid meetings (end_time < start_time) filtered out |
| TC_SM_008 | Test data quality scoring for meetings | Quality scores calculated based on completeness and validity |
| TC_SM_009 | Validate null handling in required fields | Records with null MEETING_ID, HOST_ID, or time fields filtered out |
| TC_SM_010 | Test edge case: very long meetings | Meetings > 480 minutes classified as Webinars |

### 3. AUDIT_LOG Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_AL_001 | Validate audit log structure creation | Empty audit log table created with proper schema |
| TC_AL_002 | Test execution ID generation | Unique execution IDs generated using surrogate key function |
| TC_AL_003 | Validate audit metadata population | Proper metadata fields populated for tracking |
| TC_AL_004 | Test conditional audit insertion | Audit records only inserted for non-audit_log models |
| TC_AL_005 | Validate timestamp accuracy | Start and end times accurately recorded |

### 4. Schema Validation Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_SV_001 | Validate source table definitions | All bronze sources properly defined with required columns |
| TC_SV_002 | Test model relationships | Foreign key relationships properly defined and validated |
| TC_SV_003 | Validate accepted values constraints | Enumerated fields restricted to valid values |
| TC_SV_004 | Test range validations | Numeric fields validated within acceptable ranges |
| TC_SV_005 | Validate uniqueness constraints | Primary key fields enforced as unique and not null |

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# Enhanced schema.yml with comprehensive tests
version: 2

sources:
  - name: bronze
    description: "Bronze layer tables containing raw data"
    tables:
      - name: bz_users
        description: "Bronze users table"
        columns:
          - name: user_id
            description: "Unique user identifier"
            tests:
              - not_null
              - unique
              - dbt_expectations.expect_column_values_to_match_regex:
                  regex: '^[A-Za-z0-9_-]+$'
          - name: email
            description: "User email address"
            tests:
              - dbt_expectations.expect_column_values_to_match_regex:
                  regex: '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'
          - name: plan_type
            description: "User subscription plan"
            tests:
              - accepted_values:
                  values: ['FREE', 'BASIC', 'PRO', 'ENTERPRISE', 'free', 'basic', 'pro', 'enterprise']
          - name: load_timestamp
            description: "Record load timestamp"
            tests:
              - not_null
              - dbt_expectations.expect_column_values_to_be_of_type:
                  column_type: timestamp

      - name: bz_meetings
        description: "Bronze meetings table"
        columns:
          - name: meeting_id
            description: "Unique meeting identifier"
            tests:
              - not_null
              - unique
          - name: host_id
            description: "Meeting host user ID"
            tests:
              - not_null
              - relationships:
                  to: source('bronze', 'bz_users')
                  field: user_id
          - name: start_time
            description: "Meeting start time"
            tests:
              - not_null
              - dbt_expectations.expect_column_values_to_be_of_type:
                  column_type: timestamp
          - name: end_time
            description: "Meeting end time"
            tests:
              - not_null
              - dbt_expectations.expect_column_values_to_be_of_type:
                  column_type: timestamp
          - name: duration_minutes
            description: "Meeting duration in minutes"
            tests:
              - dbt_expectations.expect_column_values_to_be_between:
                  min_value: 0
                  max_value: 1440
                  strictly: false

models:
  - name: audit_log
    description: "Audit log for Silver layer pipeline execution"
    columns:
      - name: execution_id
        description: "Unique execution identifier"
        tests:
          - not_null
          - unique
      - name: pipeline_name
        description: "Name of the pipeline"
        tests:
          - not_null
          - accepted_values:
              values: ['SILVER_PIPELINE', 'SI_USERS_TRANSFORM', 'SI_MEETINGS_TRANSFORM']
      - name: status
        description: "Pipeline execution status"
        tests:
          - accepted_values:
              values: ['STARTED', 'RUNNING', 'COMPLETED', 'FAILED']
      - name: start_time
        description: "Pipeline start time"
        tests:
          - not_null
      - name: execution_duration_seconds
        description: "Execution duration in seconds"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 86400
              strictly: false

  - name: si_users
    description: "Silver layer users with data quality validations"
    tests:
      - dbt_expectations.expect_table_row_count_to_be_between:
          min_value: 1
          max_value: 1000000
    columns:
      - name: user_id
        description: "Unique user identifier"
        tests:
          - not_null
          - unique
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: '^[A-Za-z0-9_-]+$'
      - name: user_name
        description: "Cleaned user name"
        tests:
          - not_null
          - dbt_expectations.expect_column_value_lengths_to_be_between:
              min_value: 1
              max_value: 100
      - name: email
        description: "Validated email address"
        tests:
          - not_null
          - unique
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'
      - name: plan_type
        description: "Standardized plan type"
        tests:
          - not_null
          - accepted_values:
              values: ['FREE', 'BASIC', 'PRO', 'ENTERPRISE']
      - name: account_status
        description: "Account status"
        tests:
          - not_null
          - accepted_values:
              values: ['Active', 'Inactive', 'Suspended']
      - name: registration_date
        description: "User registration date"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: '2020-01-01'
              max_value: '2030-12-31'
      - name: data_quality_score
        description: "Data quality score (0-1)"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.50
              max_value: 1.00
              strictly: false

  - name: si_meetings
    description: "Silver layer meetings with enriched data"
    tests:
      - dbt_expectations.expect_table_row_count_to_be_between:
          min_value: 1
          max_value: 10000000
    columns:
      - name: meeting_id
        description: "Unique meeting identifier"
        tests:
          - not_null
          - unique
      - name: host_id
        description: "Meeting host user ID"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: meeting_topic
        description: "Meeting topic/title"
        tests:
          - dbt_expectations.expect_column_value_lengths_to_be_between:
              min_value: 1
              max_value: 500
      - name: meeting_type
        description: "Type of meeting"
        tests:
          - not_null
          - accepted_values:
              values: ['Webinar', 'Instant', 'Personal', 'Scheduled']
      - name: start_time
        description: "Meeting start time"
        tests:
          - not_null
      - name: end_time
        description: "Meeting end time"
        tests:
          - not_null
      - name: duration_minutes
        description: "Meeting duration in minutes"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440
              strictly: false
      - name: meeting_status
        description: "Meeting status"
        tests:
          - not_null
          - accepted_values:
              values: ['Completed', 'In Progress', 'Scheduled', 'Cancelled']
      - name: participant_count
        description: "Number of participants"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10000
              strictly: false
      - name: data_quality_score
        description: "Data quality score (0-1)"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.50
              max_value: 1.00
              strictly: false
```

### Custom SQL-based dbt Tests

#### 1. Test for Data Quality Score Calculation (si_users)

```sql
-- tests/test_si_users_quality_score.sql
{{ config(severity = 'error') }}

WITH quality_check AS (
    SELECT 
        user_id,
        email,
        user_name,
        plan_type,
        data_quality_score,
        CASE 
            WHEN email IS NOT NULL AND REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') 
                 AND user_name IS NOT NULL AND TRIM(user_name) != ''
                 AND plan_type IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE')
            THEN 1.00
            WHEN email IS NOT NULL AND user_name IS NOT NULL
            THEN 0.75
            WHEN user_id IS NOT NULL
            THEN 0.50
            ELSE 0.25
        END AS expected_score
    FROM {{ ref('si_users') }}
)

SELECT 
    user_id,
    data_quality_score,
    expected_score
FROM quality_check
WHERE ABS(data_quality_score - expected_score) > 0.01
```

#### 2. Test for Meeting Duration Consistency

```sql
-- tests/test_si_meetings_duration_consistency.sql
{{ config(severity = 'error') }}

SELECT 
    meeting_id,
    start_time,
    end_time,
    duration_minutes,
    DATEDIFF('minute', start_time, end_time) AS calculated_duration
FROM {{ ref('si_meetings') }}
WHERE duration_minutes < DATEDIFF('minute', start_time, end_time)
   OR end_time < start_time
```

#### 3. Test for Account Status Logic

```sql
-- tests/test_si_users_account_status.sql
{{ config(severity = 'error') }}

WITH status_check AS (
    SELECT 
        user_id,
        last_login_date,
        account_status,
        CASE 
            WHEN last_login_date >= DATEADD('day', -30, CURRENT_DATE()) THEN 'Active'
            WHEN last_login_date >= DATEADD('day', -90, CURRENT_DATE()) THEN 'Inactive'
            ELSE 'Suspended'
        END AS expected_status
    FROM {{ ref('si_users') }}
)

SELECT 
    user_id,
    account_status,
    expected_status,
    last_login_date
FROM status_check
WHERE account_status != expected_status
```

#### 4. Test for Meeting Type Classification

```sql
-- tests/test_si_meetings_type_classification.sql
{{ config(severity = 'error') }}

WITH type_check AS (
    SELECT 
        meeting_id,
        meeting_topic,
        duration_minutes,
        meeting_type,
        CASE 
            WHEN duration_minutes > 480 THEN 'Webinar'
            WHEN meeting_topic ILIKE '%instant%' THEN 'Instant'
            WHEN meeting_topic ILIKE '%personal%' THEN 'Personal'
            ELSE 'Scheduled'
        END AS expected_type
    FROM {{ ref('si_meetings') }}
)

SELECT 
    meeting_id,
    meeting_type,
    expected_type,
    meeting_topic,
    duration_minutes
FROM type_check
WHERE meeting_type != expected_type
```

#### 5. Test for Referential Integrity

```sql
-- tests/test_referential_integrity_meetings_users.sql
{{ config(severity = 'error') }}

SELECT 
    m.meeting_id,
    m.host_id
FROM {{ ref('si_meetings') }} m
LEFT JOIN {{ ref('si_users') }} u ON m.host_id = u.user_id
WHERE u.user_id IS NULL
```

#### 6. Test for Duplicate Prevention

```sql
-- tests/test_si_users_no_duplicates.sql
{{ config(severity = 'error') }}

SELECT 
    user_id,
    COUNT(*) as duplicate_count
FROM {{ ref('si_users') }}
GROUP BY user_id
HAVING COUNT(*) > 1
```

#### 7. Test for Data Quality Threshold Enforcement

```sql
-- tests/test_data_quality_threshold.sql
{{ config(severity = 'error') }}

SELECT 
    'si_users' as model_name,
    user_id as record_id,
    data_quality_score
FROM {{ ref('si_users') }}
WHERE data_quality_score < 0.50

UNION ALL

SELECT 
    'si_meetings' as model_name,
    meeting_id as record_id,
    data_quality_score
FROM {{ ref('si_meetings') }}
WHERE data_quality_score < 0.50
```

#### 8. Test for Email Format Validation

```sql
-- tests/test_email_format_validation.sql
{{ config(severity = 'error') }}

SELECT 
    user_id,
    email
FROM {{ ref('si_users') }}
WHERE email IS NOT NULL 
  AND NOT REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
```

#### 9. Test for Audit Log Completeness

```sql
-- tests/test_audit_log_completeness.sql
{{ config(severity = 'warn') }}

SELECT 
    execution_id,
    pipeline_name,
    start_time,
    end_time,
    status
FROM {{ ref('audit_log') }}
WHERE (status = 'COMPLETED' AND end_time IS NULL)
   OR (status = 'FAILED' AND error_message IS NULL)
   OR (start_time IS NULL)
```

#### 10. Test for Business Rule Validation

```sql
-- tests/test_business_rules_validation.sql
{{ config(severity = 'error') }}

-- Test 1: Users must have valid plan types
SELECT 
    'Invalid Plan Type' as rule_violation,
    user_id,
    plan_type
FROM {{ ref('si_users') }}
WHERE plan_type NOT IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE')

UNION ALL

-- Test 2: Meetings cannot have negative duration
SELECT 
    'Negative Duration' as rule_violation,
    meeting_id,
    CAST(duration_minutes AS STRING) as plan_type
FROM {{ ref('si_meetings') }}
WHERE duration_minutes < 0

UNION ALL

-- Test 3: Registration date cannot be in the future
SELECT 
    'Future Registration Date' as rule_violation,
    user_id,
    CAST(registration_date AS STRING) as plan_type
FROM {{ ref('si_users') }}
WHERE registration_date > CURRENT_DATE()
```

## Test Execution Strategy

### 1. Pre-deployment Testing
```bash
# Run all tests before deployment
dbt test --models si_users si_meetings audit_log

# Run specific test categories
dbt test --models si_users --select test_type:generic
dbt test --models si_meetings --select test_type:singular
```

### 2. Data Quality Monitoring
```bash
# Run data quality tests daily
dbt test --models si_users si_meetings --select test_name:*quality*

# Run referential integrity tests
dbt test --select test_name:*referential*
```

### 3. Performance Testing
```bash
# Test with large datasets
dbt run --models si_users --vars '{"test_mode": "performance"}'

# Monitor execution times
dbt run --models si_meetings --log-level debug
```

## Expected Test Results

### Success Criteria
- All `not_null` and `unique` tests pass with 0 failures
- Data quality scores are between 0.50-1.00 for all records
- All referential integrity constraints are satisfied
- Business rule validations pass with 0 violations
- Audit logs are properly populated for all pipeline executions

### Performance Benchmarks
- `si_users` model execution: < 30 seconds for 100K records
- `si_meetings` model execution: < 60 seconds for 1M records
- All tests combined execution: < 5 minutes

### Data Quality Thresholds
- Minimum data quality score: 0.50
- Maximum acceptable duplicate rate: 0%
- Email format validation accuracy: 100%
- Plan type standardization accuracy: 100%

## Maintenance and Updates

### Regular Review Schedule
- Weekly: Review test execution results and failure patterns
- Monthly: Update test thresholds based on data quality trends
- Quarterly: Add new test cases for emerging business requirements

### Test Case Evolution
- Add new tests when new business rules are introduced
- Update existing tests when data sources change
- Archive obsolete tests when models are deprecated

### Documentation Updates
- Keep test descriptions current with business requirements
- Update expected outcomes when business logic changes
- Maintain version history of test case modifications

This comprehensive test suite ensures the reliability, accuracy, and performance of the Zoom Silver Layer dbt models in Snowflake, providing robust data quality validation and error detection capabilities.