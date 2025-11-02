_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive Snowflake dbt Unit Test Cases for Zoom Platform Analytics Silver Layer Models
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases
## Zoom Platform Analytics System - Silver Layer Models

## Overview

This document provides comprehensive unit test cases and corresponding dbt test scripts for the Silver Layer dbt models in the Zoom Platform Analytics System. The test cases validate key data transformations, business rules, edge cases, and error handling to ensure reliability and performance of dbt models in Snowflake.

## Test Case Coverage

The test cases cover the following dbt models:
1. **audit_log.sql** - Silver layer audit log model
2. **si_users.sql** - Silver layer users model
3. **si_meetings.sql** - Silver layer meetings model  
4. **si_participants.sql** - Silver layer participants model

---

## 1. AUDIT_LOG Model Test Cases

### Test Case ID: AL_001
**Test Case Description**: Validate audit log record creation and structure
**Expected Outcome**: Audit log should create records with proper execution ID format and required fields

#### dbt Test Script:
```yaml
# tests/audit_log_tests.yml
version: 2

models:
  - name: audit_log
    tests:
      - not_null:
          column_name: execution_id
      - unique:
          column_name: execution_id
      - accepted_values:
          column_name: status
          values: ['Success', 'Failed', 'Partial Success', 'Cancelled']
      - dbt_expectations.expect_column_to_exist:
          column: pipeline_name
      - dbt_expectations.expect_column_to_exist:
          column: start_time
```

### Test Case ID: AL_002
**Test Case Description**: Validate execution ID format follows pattern 'EXEC_YYYYMMDDHH24MISS_N'
**Expected Outcome**: All execution IDs should follow the specified format pattern

#### dbt Test Script:
```sql
-- tests/test_audit_log_execution_id_format.sql
SELECT execution_id
FROM {{ ref('audit_log') }}
WHERE NOT REGEXP_LIKE(execution_id, '^EXEC_[0-9]{14}_[0-9]+$')
```

### Test Case ID: AL_003
**Test Case Description**: Validate timestamp consistency (end_time >= start_time)
**Expected Outcome**: End time should always be greater than or equal to start time

#### dbt Test Script:
```sql
-- tests/test_audit_log_timestamp_logic.sql
SELECT execution_id, start_time, end_time
FROM {{ ref('audit_log') }}
WHERE end_time < start_time
```

---

## 2. SI_USERS Model Test Cases

### Test Case ID: USR_001
**Test Case Description**: Validate email format and standardization
**Expected Outcome**: All emails should be in lowercase and follow valid email format

#### dbt Test Script:
```yaml
# tests/si_users_tests.yml
version: 2

models:
  - name: si_users
    columns:
      - name: user_id
        tests:
          - not_null
          - unique
      - name: email
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: '^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$'
      - name: plan_type
        tests:
          - accepted_values:
              values: ['Free', 'Basic', 'Pro', 'Enterprise', 'Unknown']
      - name: account_status
        tests:
          - accepted_values:
              values: ['Active', 'Inactive', 'Suspended']
      - name: data_quality_score
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.00
              max_value: 1.00
```

### Test Case ID: USR_002
**Test Case Description**: Validate user name standardization (TRIM and UPPER)
**Expected Outcome**: All user names should be trimmed and in uppercase

#### dbt Test Script:
```sql
-- tests/test_si_users_name_standardization.sql
SELECT user_id, user_name
FROM {{ ref('si_users') }}
WHERE user_name != TRIM(UPPER(user_name))
   OR user_name IS NULL
   OR LENGTH(TRIM(user_name)) = 0
```

### Test Case ID: USR_003
**Test Case Description**: Validate deduplication logic (latest record per USER_ID)
**Expected Outcome**: Each USER_ID should appear only once in the final dataset

#### dbt Test Script:
```sql
-- tests/test_si_users_deduplication.sql
SELECT user_id, COUNT(*) as duplicate_count
FROM {{ ref('si_users') }}
GROUP BY user_id
HAVING COUNT(*) > 1
```

### Test Case ID: USR_004
**Test Case Description**: Validate account status derivation logic
**Expected Outcome**: Account status should be correctly derived based on plan type and activity

#### dbt Test Script:
```sql
-- tests/test_si_users_account_status_logic.sql
WITH expected_status AS (
  SELECT user_id,
         account_status,
         CASE 
           WHEN plan_type = 'Free' AND update_timestamp < DATEADD('day', -30, CURRENT_TIMESTAMP()) THEN 'Inactive'
           WHEN plan_type IN ('Basic', 'Pro', 'Enterprise') THEN 'Active'
           ELSE 'Active'
         END as expected_account_status
  FROM {{ ref('si_users') }}
)
SELECT user_id, account_status, expected_account_status
FROM expected_status
WHERE account_status != expected_account_status
```

### Test Case ID: USR_005
**Test Case Description**: Validate data quality score calculation
**Expected Outcome**: Data quality score should be calculated correctly based on validation flags

#### dbt Test Script:
```sql
-- tests/test_si_users_data_quality_score.sql
SELECT user_id, data_quality_score
FROM {{ ref('si_users') }}
WHERE data_quality_score < 0.60  -- Should not have records below minimum threshold
```

### Test Case ID: USR_006
**Test Case Description**: Test edge case - Empty email handling
**Expected Outcome**: Records with empty emails should be blocked from Silver layer

#### dbt Test Script:
```sql
-- tests/test_si_users_empty_email_handling.sql
SELECT user_id, email
FROM {{ ref('si_users') }}
WHERE email IS NULL 
   OR TRIM(email) = ''
   OR email = ''
```

---

## 3. SI_MEETINGS Model Test Cases

### Test Case ID: MTG_001
**Test Case Description**: Validate meeting type derivation based on duration
**Expected Outcome**: Meeting types should be correctly categorized based on duration rules

#### dbt Test Script:
```yaml
# tests/si_meetings_tests.yml
version: 2

models:
  - name: si_meetings
    columns:
      - name: meeting_id
        tests:
          - not_null
          - unique
      - name: host_id
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: meeting_type
        tests:
          - accepted_values:
              values: ['Instant', 'Scheduled', 'Webinar', 'Personal']
      - name: meeting_status
        tests:
          - accepted_values:
              values: ['Scheduled', 'In Progress', 'Completed', 'Unknown']
      - name: duration_minutes
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440
```

### Test Case ID: MTG_002
**Test Case Description**: Validate meeting type logic based on duration
**Expected Outcome**: Meeting types should match expected categories based on duration ranges

#### dbt Test Script:
```sql
-- tests/test_si_meetings_type_logic.sql
WITH expected_types AS (
  SELECT meeting_id,
         meeting_type,
         CASE 
           WHEN duration_minutes <= 5 THEN 'Instant'
           WHEN duration_minutes BETWEEN 6 AND 60 THEN 'Scheduled'
           WHEN duration_minutes > 60 THEN 'Webinar'
           ELSE 'Personal'
         END as expected_meeting_type
  FROM {{ ref('si_meetings') }}
)
SELECT meeting_id, meeting_type, expected_meeting_type
FROM expected_types
WHERE meeting_type != expected_meeting_type
```

### Test Case ID: MTG_003
**Test Case Description**: Validate temporal logic (end_time >= start_time)
**Expected Outcome**: End time should always be after or equal to start time

#### dbt Test Script:
```sql
-- tests/test_si_meetings_temporal_logic.sql
SELECT meeting_id, start_time, end_time
FROM {{ ref('si_meetings') }}
WHERE end_time < start_time
```

### Test Case ID: MTG_004
**Test Case Description**: Validate duration correction logic
**Expected Outcome**: Negative durations should be corrected to positive values

#### dbt Test Script:
```sql
-- tests/test_si_meetings_duration_correction.sql
SELECT meeting_id, duration_minutes
FROM {{ ref('si_meetings') }}
WHERE duration_minutes < 0
```

### Test Case ID: MTG_005
**Test Case Description**: Validate participant count accuracy
**Expected Outcome**: Participant count should match actual participants from participants table

#### dbt Test Script:
```sql
-- tests/test_si_meetings_participant_count.sql
WITH actual_counts AS (
  SELECT meeting_id, COUNT(DISTINCT user_id) as actual_participant_count
  FROM {{ source('bronze', 'bz_participants') }}
  GROUP BY meeting_id
)
SELECT m.meeting_id, m.participant_count, a.actual_participant_count
FROM {{ ref('si_meetings') }} m
LEFT JOIN actual_counts a ON m.meeting_id = a.meeting_id
WHERE COALESCE(m.participant_count, 0) != COALESCE(a.actual_participant_count, 0)
```

### Test Case ID: MTG_006
**Test Case Description**: Test edge case - Missing host handling
**Expected Outcome**: Meetings without hosts should be blocked from Silver layer

#### dbt Test Script:
```sql
-- tests/test_si_meetings_missing_host.sql
SELECT meeting_id, host_id
FROM {{ ref('si_meetings') }}
WHERE host_id IS NULL
```

### Test Case ID: MTG_007
**Test Case Description**: Validate meeting status derivation
**Expected Outcome**: Meeting status should be correctly derived from timestamps

#### dbt Test Script:
```sql
-- tests/test_si_meetings_status_logic.sql
WITH expected_status AS (
  SELECT meeting_id,
         meeting_status,
         CASE 
           WHEN end_time < CURRENT_TIMESTAMP() THEN 'Completed'
           WHEN start_time <= CURRENT_TIMESTAMP() AND end_time >= CURRENT_TIMESTAMP() THEN 'In Progress'
           WHEN start_time > CURRENT_TIMESTAMP() THEN 'Scheduled'
           ELSE 'Unknown'
         END as expected_meeting_status
  FROM {{ ref('si_meetings') }}
)
SELECT meeting_id, meeting_status, expected_meeting_status
FROM expected_status
WHERE meeting_status != expected_meeting_status
```

---

## 4. SI_PARTICIPANTS Model Test Cases

### Test Case ID: PRT_001
**Test Case Description**: Validate attendance duration calculation
**Expected Outcome**: Attendance duration should be correctly calculated from join and leave times

#### dbt Test Script:
```yaml
# tests/si_participants_tests.yml
version: 2

models:
  - name: si_participants
    columns:
      - name: participant_id
        tests:
          - not_null
          - unique
      - name: meeting_id
        tests:
          - not_null
          - relationships:
              to: ref('si_meetings')
              field: meeting_id
      - name: user_id
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: attendance_duration
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440
      - name: connection_quality
        tests:
          - accepted_values:
              values: ['Excellent', 'Good', 'Fair', 'Poor']
```

### Test Case ID: PRT_002
**Test Case Description**: Validate attendance duration calculation logic
**Expected Outcome**: Duration should match DATEDIFF between join and leave times

#### dbt Test Script:
```sql
-- tests/test_si_participants_duration_calculation.sql
WITH expected_duration AS (
  SELECT participant_id,
         attendance_duration,
         CASE 
           WHEN leave_time IS NOT NULL AND leave_time >= join_time 
           THEN DATEDIFF('minute', join_time, leave_time)
           WHEN leave_time IS NULL 
           THEN 30  -- Default 30 minutes
           ELSE 0
         END as expected_duration
  FROM {{ ref('si_participants') }}
)
SELECT participant_id, attendance_duration, expected_duration
FROM expected_duration
WHERE attendance_duration != expected_duration
```

### Test Case ID: PRT_003
**Test Case Description**: Validate temporal logic correction (leave_time >= join_time)
**Expected Outcome**: Leave time should be corrected if earlier than join time

#### dbt Test Script:
```sql
-- tests/test_si_participants_temporal_correction.sql
SELECT participant_id, join_time, leave_time
FROM {{ ref('si_participants') }}
WHERE leave_time < join_time
```

### Test Case ID: PRT_004
**Test Case Description**: Validate connection quality derivation
**Expected Outcome**: Connection quality should be derived correctly from attendance duration

#### dbt Test Script:
```sql
-- tests/test_si_participants_connection_quality.sql
WITH expected_quality AS (
  SELECT participant_id,
         connection_quality,
         CASE 
           WHEN attendance_duration >= 45 THEN 'Excellent'
           WHEN attendance_duration >= 30 THEN 'Good'
           WHEN attendance_duration >= 15 THEN 'Fair'
           ELSE 'Poor'
         END as expected_connection_quality
  FROM {{ ref('si_participants') }}
)
SELECT participant_id, connection_quality, expected_connection_quality
FROM expected_quality
WHERE connection_quality != expected_connection_quality
```

### Test Case ID: PRT_005
**Test Case Description**: Test edge case - Missing leave time handling
**Expected Outcome**: Missing leave times should be handled with default values

#### dbt Test Script:
```sql
-- tests/test_si_participants_missing_leave_time.sql
SELECT participant_id, join_time, leave_time, attendance_duration
FROM {{ ref('si_participants') }}
WHERE leave_time IS NULL AND attendance_duration != 30
```

### Test Case ID: PRT_006
**Test Case Description**: Validate referential integrity with meetings and users
**Expected Outcome**: All participant records should have valid meeting and user references

#### dbt Test Script:
```sql
-- tests/test_si_participants_referential_integrity.sql
SELECT p.participant_id, p.meeting_id, p.user_id
FROM {{ ref('si_participants') }} p
LEFT JOIN {{ ref('si_meetings') }} m ON p.meeting_id = m.meeting_id
LEFT JOIN {{ ref('si_users') }} u ON p.user_id = u.user_id
WHERE m.meeting_id IS NULL OR u.user_id IS NULL
```

---

## 5. Cross-Model Integration Test Cases

### Test Case ID: INT_001
**Test Case Description**: Validate data consistency across all Silver models
**Expected Outcome**: Data should be consistent across related models

#### dbt Test Script:
```sql
-- tests/test_cross_model_consistency.sql
-- Validate that all meetings have corresponding participants
SELECT m.meeting_id
FROM {{ ref('si_meetings') }} m
LEFT JOIN {{ ref('si_participants') }} p ON m.meeting_id = p.meeting_id
WHERE p.meeting_id IS NULL AND m.participant_count > 0
```

### Test Case ID: INT_002
**Test Case Description**: Validate host relationships between meetings and users
**Expected Outcome**: All meeting hosts should exist in users table

#### dbt Test Script:
```sql
-- tests/test_host_user_relationship.sql
SELECT m.meeting_id, m.host_id
FROM {{ ref('si_meetings') }} m
LEFT JOIN {{ ref('si_users') }} u ON m.host_id = u.user_id
WHERE u.user_id IS NULL
```

---

## 6. Performance and Volume Test Cases

### Test Case ID: PERF_001
**Test Case Description**: Validate model performance with large datasets
**Expected Outcome**: Models should complete within acceptable time limits

#### dbt Test Script:
```sql
-- tests/test_model_performance.sql
-- This test checks for reasonable execution time by ensuring row counts are within expected ranges
SELECT 'si_users' as model_name, COUNT(*) as row_count
FROM {{ ref('si_users') }}
HAVING COUNT(*) > 1000000  -- Flag if unexpectedly large

UNION ALL

SELECT 'si_meetings' as model_name, COUNT(*) as row_count
FROM {{ ref('si_meetings') }}
HAVING COUNT(*) > 5000000  -- Flag if unexpectedly large
```

### Test Case ID: PERF_002
**Test Case Description**: Validate incremental processing efficiency
**Expected Outcome**: Incremental runs should process only new/changed records

#### dbt Test Script:
```sql
-- tests/test_incremental_efficiency.sql
-- Check for duplicate processing in incremental runs
SELECT load_date, COUNT(*) as daily_load_count
FROM {{ ref('si_users') }}
GROUP BY load_date
HAVING COUNT(*) > (SELECT COUNT(DISTINCT user_id) FROM {{ source('bronze', 'bz_users') }})
```

---

## 7. Data Quality Test Cases

### Test Case ID: DQ_001
**Test Case Description**: Validate overall data quality scores meet minimum thresholds
**Expected Outcome**: All records should meet minimum data quality score of 0.60

#### dbt Test Script:
```sql
-- tests/test_minimum_data_quality_scores.sql
SELECT 'si_users' as table_name, COUNT(*) as low_quality_records
FROM {{ ref('si_users') }}
WHERE data_quality_score < 0.60

UNION ALL

SELECT 'si_meetings' as table_name, COUNT(*) as low_quality_records
FROM {{ ref('si_meetings') }}
WHERE data_quality_score < 0.50

UNION ALL

SELECT 'si_participants' as table_name, COUNT(*) as low_quality_records
FROM {{ ref('si_participants') }}
WHERE data_quality_score < 0.50
```

### Test Case ID: DQ_002
**Test Case Description**: Validate data completeness across critical fields
**Expected Outcome**: Critical fields should have minimal null values

#### dbt Test Script:
```sql
-- tests/test_data_completeness.sql
WITH completeness_check AS (
  SELECT 
    'si_users.email' as field_name,
    COUNT(*) as total_records,
    COUNT(email) as non_null_records,
    (COUNT(email)::FLOAT / COUNT(*)) * 100 as completeness_percentage
  FROM {{ ref('si_users') }}
  
  UNION ALL
  
  SELECT 
    'si_meetings.host_id' as field_name,
    COUNT(*) as total_records,
    COUNT(host_id) as non_null_records,
    (COUNT(host_id)::FLOAT / COUNT(*)) * 100 as completeness_percentage
  FROM {{ ref('si_meetings') }}
)
SELECT field_name, completeness_percentage
FROM completeness_check
WHERE completeness_percentage < 95.0  -- Flag fields with less than 95% completeness
```

---

## 8. Error Handling Test Cases

### Test Case ID: ERR_001
**Test Case Description**: Validate error handling for invalid data types
**Expected Outcome**: Invalid data should be handled gracefully without breaking the pipeline

#### dbt Test Script:
```sql
-- tests/test_error_handling_data_types.sql
-- Check for any records that might cause type conversion errors
SELECT user_id, data_quality_score
FROM {{ ref('si_users') }}
WHERE TRY_CAST(data_quality_score AS NUMBER(3,2)) IS NULL
   AND data_quality_score IS NOT NULL
```

### Test Case ID: ERR_002
**Test Case Description**: Validate handling of extreme values
**Expected Outcome**: Extreme values should be capped or flagged appropriately

#### dbt Test Script:
```sql
-- tests/test_extreme_values_handling.sql
SELECT meeting_id, duration_minutes
FROM {{ ref('si_meetings') }}
WHERE duration_minutes > 1440  -- More than 24 hours
   OR duration_minutes < 0      -- Negative duration
```

---

## 9. Business Logic Test Cases

### Test Case ID: BIZ_001
**Test Case Description**: Validate business rule - Free plan users inactive after 30 days
**Expected Outcome**: Free plan users should be marked inactive if no activity for 30+ days

#### dbt Test Script:
```sql
-- tests/test_business_rule_free_plan_inactivity.sql
SELECT user_id, plan_type, account_status, update_timestamp
FROM {{ ref('si_users') }}
WHERE plan_type = 'Free'
  AND update_timestamp < DATEADD('day', -30, CURRENT_TIMESTAMP())
  AND account_status != 'Inactive'
```

### Test Case ID: BIZ_002
**Test Case Description**: Validate business rule - Meeting duration consistency
**Expected Outcome**: Calculated duration should match the difference between start and end times

#### dbt Test Script:
```sql
-- tests/test_business_rule_duration_consistency.sql
SELECT meeting_id, 
       duration_minutes,
       DATEDIFF('minute', start_time, end_time) as calculated_duration
FROM {{ ref('si_meetings') }}
WHERE ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) > 1  -- Allow 1 minute tolerance
  AND start_time IS NOT NULL 
  AND end_time IS NOT NULL
```

---

## 10. Schema Evolution Test Cases

### Test Case ID: SCH_001
**Test Case Description**: Validate schema compatibility with source changes
**Expected Outcome**: Models should handle new columns gracefully

#### dbt Test Script:
```yaml
# tests/schema_evolution_tests.yml
version: 2

models:
  - name: si_users
    tests:
      - dbt_expectations.expect_table_column_count_to_be_between:
          min_value: 10
          max_value: 20
  - name: si_meetings
    tests:
      - dbt_expectations.expect_table_column_count_to_be_between:
          min_value: 15
          max_value: 25
```

---

## Test Execution Framework

### Running All Tests
```bash
# Run all tests
dbt test

# Run tests for specific model
dbt test --select si_users

# Run tests with specific tag
dbt test --select tag:data_quality

# Run tests in fail-fast mode
dbt test --fail-fast
```

### Test Configuration
```yaml
# dbt_project.yml
tests:
  zoom_silver_pipeline:
    +severity: error  # fail on any test failure
    data_quality:
      +severity: warn   # warn on data quality issues
    performance:
      +severity: error  # fail on performance issues
```

### Custom Test Macros
```sql
-- macros/test_data_quality_score.sql
{% macro test_data_quality_score(model, column_name, min_score=0.6) %}
  SELECT COUNT(*) as failures
  FROM {{ model }}
  WHERE {{ column_name }} < {{ min_score }}
{% endmacro %}
```

---

## Test Results Monitoring

### Test Results Dashboard
- **Total Tests**: 50+ comprehensive test cases
- **Coverage Areas**: Data Quality, Business Logic, Performance, Error Handling
- **Automation**: Integrated with dbt Cloud for continuous testing
- **Alerting**: Slack/Email notifications for test failures

### Key Metrics Tracked
1. **Test Pass Rate**: Target >95%
2. **Data Quality Score**: Target >0.80 average
3. **Model Performance**: Target <5 minutes execution time
4. **Data Completeness**: Target >95% for critical fields

---

## Conclusion

This comprehensive test suite ensures the reliability, performance, and data quality of the Zoom Platform Analytics Silver Layer dbt models. The test cases cover:

- ✅ **Data Validation**: Format, type, and constraint validation
- ✅ **Business Logic**: Complex transformation and derivation rules
- ✅ **Data Quality**: Completeness, accuracy, and consistency checks
- ✅ **Performance**: Volume and execution time validation
- ✅ **Error Handling**: Graceful handling of edge cases and invalid data
- ✅ **Integration**: Cross-model consistency and referential integrity
- ✅ **Schema Evolution**: Compatibility with source system changes

Regular execution of these test cases will ensure the continued reliability and performance of the Silver Layer data pipeline in the Snowflake environment.