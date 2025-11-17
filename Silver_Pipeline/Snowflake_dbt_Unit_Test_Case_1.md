_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases and dbt test scripts for Zoom Platform Analytics System Silver layer models in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases
## Zoom Platform Analytics System - Silver Layer

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics System Silver layer models running in Snowflake. The test cases cover key transformations, business rules, edge cases, and error handling scenarios to ensure data quality, reliability, and performance of the dbt models.

## Test Coverage Overview

The test suite covers the following Silver layer models:
1. **SI_AUDIT_LOG** - Audit logging for all Silver layer operations
2. **SI_USERS** - User data with email validation and plan standardization
3. **SI_MEETINGS** - Meeting data with critical duration and timezone fixes
4. **SI_PARTICIPANTS** - Participant data with timestamp format conversion
5. **SI_LICENSES** - License data with DD/MM/YYYY date format fixes
6. **SI_FEATURE_USAGE** - Feature usage tracking and validation
7. **SI_SUPPORT_TICKETS** - Support ticket management and status tracking
8. **SI_BILLING_EVENTS** - Billing event processing and validation

---

## Test Case List

### **Test Case ID: TC_001**
**Test Case Description**: SI_AUDIT_LOG Model - Basic Audit Trail Creation
**Expected Outcome**: Audit records are created for all Silver layer model executions with proper timestamps and status tracking

### **Test Case ID: TC_002**
**Test Case Description**: SI_USERS Model - Email Validation and Plan Type Standardization
**Expected Outcome**: Invalid emails are filtered out, plan types are standardized to (FREE, BASIC, PRO, ENTERPRISE), and data quality scores are calculated

### **Test Case ID: TC_003**
**Test Case Description**: SI_MEETINGS Model - Duration Text Unit Cleaning (Critical P1)
**Expected Outcome**: Duration values with text units like "108 mins" are cleaned and converted to numeric values successfully

### **Test Case ID: TC_004**
**Test Case Description**: SI_MEETINGS Model - EST Timezone Standardization
**Expected Outcome**: EST timezone timestamps are converted to standard format without conversion failures

### **Test Case ID: TC_005**
**Test Case Description**: SI_PARTICIPANTS Model - MM/DD/YYYY Timestamp Format Conversion
**Expected Outcome**: Timestamps in MM/DD/YYYY HH:MM format are converted to standard Snowflake timestamp format

### **Test Case ID: TC_006**
**Test Case Description**: SI_LICENSES Model - DD/MM/YYYY Date Format Conversion (Critical P1)
**Expected Outcome**: Date values in DD/MM/YYYY format like "27/08/2024" are converted to standard date format successfully

### **Test Case ID: TC_007**
**Test Case Description**: SI_FEATURE_USAGE Model - Feature Name Standardization and Usage Count Validation
**Expected Outcome**: Feature names are standardized and usage counts are validated as non-negative integers

### **Test Case ID: TC_008**
**Test Case Description**: SI_SUPPORT_TICKETS Model - Status Validation and Date Logic
**Expected Outcome**: Resolution status follows predefined values and open dates are not in the future

### **Test Case ID: TC_009**
**Test Case Description**: SI_BILLING_EVENTS Model - Amount Validation and Event Type Standardization
**Expected Outcome**: Billing amounts are positive values and event types are standardized

### **Test Case ID: TC_010**
**Test Case Description**: Cross-Model Referential Integrity Validation
**Expected Outcome**: All foreign key relationships are maintained across Silver layer models

### **Test Case ID: TC_011**
**Test Case Description**: Data Quality Score Calculation and Validation Status
**Expected Outcome**: All records have data quality scores (0-100) and validation status (PASSED/FAILED/WARNING)

### **Test Case ID: TC_012**
**Test Case Description**: Null Value Handling and Data Completeness
**Expected Outcome**: Critical null values are filtered out and data completeness metrics are tracked

### **Test Case ID: TC_013**
**Test Case Description**: Duplicate Record Handling and Deduplication Logic
**Expected Outcome**: Duplicate records are identified and latest records are kept based on update timestamps

### **Test Case ID: TC_014**
**Test Case Description**: Business Rule Validation - Meeting Duration Logic
**Expected Outcome**: Meeting duration matches the difference between start and end times within acceptable tolerance

### **Test Case ID: TC_015**
**Test Case Description**: Edge Case Handling - Empty Datasets and Schema Mismatches
**Expected Outcome**: Models handle empty source datasets gracefully and schema mismatches are logged

---

## dbt Test Scripts

### **YAML-based Schema Tests**

#### **models/silver/schema.yml**

```yaml
version: 2

models:
  - name: si_audit_log
    description: "Audit table for Silver layer operations"
    columns:
      - name: audit_id
        description: "Unique audit record identifier"
        tests:
          - not_null
          - unique
      - name: table_name
        description: "Name of the Silver layer table"
        tests:
          - not_null
          - accepted_values:
              values: ['SI_USERS', 'SI_MEETINGS', 'SI_PARTICIPANTS', 'SI_LICENSES', 'SI_FEATURE_USAGE', 'SI_SUPPORT_TICKETS', 'SI_BILLING_EVENTS']
      - name: process_status
        description: "Processing status"
        tests:
          - not_null
          - accepted_values:
              values: ['SUCCESS', 'FAILED', 'WARNING', 'IN_PROGRESS']
      - name: process_timestamp
        description: "When the process occurred"
        tests:
          - not_null

  - name: si_users
    description: "Silver layer user data with validation and standardization"
    columns:
      - name: user_id
        description: "Unique user identifier"
        tests:
          - not_null
          - unique
      - name: email
        description: "Validated email address"
        tests:
          - not_null
      - name: plan_type
        description: "Standardized plan type"
        tests:
          - not_null
          - accepted_values:
              values: ['FREE', 'BASIC', 'PRO', 'ENTERPRISE']
      - name: data_quality_score
        description: "Data quality score (0-100)"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 100
      - name: validation_status
        description: "Validation status"
        tests:
          - not_null
          - accepted_values:
              values: ['PASSED', 'FAILED', 'WARNING']

  - name: si_meetings
    description: "Silver layer meeting data with duration and timezone fixes"
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
      - name: duration_minutes
        description: "Meeting duration in minutes (cleaned from text units)"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 1440
      - name: start_time
        description: "Meeting start time (timezone standardized)"
        tests:
          - not_null
      - name: end_time
        description: "Meeting end time (timezone standardized)"
        tests:
          - not_null

  - name: si_participants
    description: "Silver layer participant data with timestamp format conversion"
    columns:
      - name: participant_id
        description: "Unique participant identifier"
        tests:
          - not_null
          - unique
      - name: meeting_id
        description: "Reference to meeting"
        tests:
          - not_null
          - relationships:
              to: ref('si_meetings')
              field: meeting_id
      - name: user_id
        description: "Reference to user"
        tests:
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: join_time
        description: "Participant join time (format converted)"
        tests:
          - not_null
      - name: leave_time
        description: "Participant leave time (format converted)"
        tests:
          - not_null

  - name: si_licenses
    description: "Silver layer license data with DD/MM/YYYY date format fixes"
    columns:
      - name: license_id
        description: "Unique license identifier"
        tests:
          - not_null
          - unique
      - name: assigned_to_user_id
        description: "User assigned to license"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: start_date
        description: "License start date (format converted)"
        tests:
          - not_null
      - name: end_date
        description: "License end date (format converted)"
        tests:
          - not_null

  - name: si_feature_usage
    description: "Silver layer feature usage data"
    columns:
      - name: usage_id
        description: "Unique usage record identifier"
        tests:
          - not_null
          - unique
      - name: meeting_id
        description: "Reference to meeting"
        tests:
          - not_null
          - relationships:
              to: ref('si_meetings')
              field: meeting_id
      - name: usage_count
        description: "Feature usage count"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 9999

  - name: si_support_tickets
    description: "Silver layer support ticket data"
    columns:
      - name: ticket_id
        description: "Unique ticket identifier"
        tests:
          - not_null
          - unique
      - name: user_id
        description: "User who created the ticket"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: resolution_status
        description: "Ticket resolution status"
        tests:
          - not_null
          - accepted_values:
              values: ['OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED']

  - name: si_billing_events
    description: "Silver layer billing event data"
    columns:
      - name: event_id
        description: "Unique billing event identifier"
        tests:
          - not_null
          - unique
      - name: user_id
        description: "User associated with billing event"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: amount
        description: "Billing amount"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0.01
              max_value: 99999.99
```

### **Custom SQL-based dbt Tests**

#### **tests/test_duration_text_cleaning.sql**
```sql
-- Test Case TC_003: Duration Text Unit Cleaning (Critical P1)
-- Validates that duration values with text units are properly cleaned
SELECT 
    meeting_id,
    duration_minutes,
    'Duration contains text units that should be cleaned' as error_message
FROM {{ ref('si_meetings') }}
WHERE duration_minutes::STRING REGEXP '[a-zA-Z]'
   OR TRY_TO_NUMBER(duration_minutes::STRING) IS NULL
   OR duration_minutes IS NULL
```

#### **tests/test_est_timezone_conversion.sql**
```sql
-- Test Case TC_004: EST Timezone Standardization
-- Validates that EST timezone timestamps are properly converted
SELECT 
    meeting_id,
    start_time,
    end_time,
    'EST timezone format not properly converted' as error_message
FROM {{ ref('si_meetings') }}
WHERE (start_time::STRING LIKE '%EST%' OR end_time::STRING LIKE '%EST%')
   OR start_time IS NULL
   OR end_time IS NULL
```

#### **tests/test_mmddyyyy_timestamp_conversion.sql**
```sql
-- Test Case TC_005: MM/DD/YYYY Timestamp Format Conversion
-- Validates that MM/DD/YYYY HH:MM timestamps are properly converted
SELECT 
    participant_id,
    join_time,
    leave_time,
    'MM/DD/YYYY timestamp format not properly converted' as error_message
FROM {{ ref('si_participants') }}
WHERE (join_time::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$'
       OR leave_time::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$')
   OR join_time IS NULL
   OR leave_time IS NULL
```

#### **tests/test_ddmmyyyy_date_conversion.sql**
```sql
-- Test Case TC_006: DD/MM/YYYY Date Format Conversion (Critical P1)
-- Validates that DD/MM/YYYY dates are properly converted
SELECT 
    license_id,
    start_date,
    end_date,
    'DD/MM/YYYY date format not properly converted' as error_message
FROM {{ ref('si_licenses') }}
WHERE (start_date::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}$'
       OR end_date::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}$')
   OR start_date IS NULL
   OR end_date IS NULL
   OR start_date >= end_date
```

#### **tests/test_email_validation.sql**
```sql
-- Test Case TC_002: Email Validation
-- Validates that email addresses follow proper format
SELECT 
    user_id,
    email,
    'Invalid email format detected' as error_message
FROM {{ ref('si_users') }}
WHERE email IS NOT NULL 
  AND NOT REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
```

#### **tests/test_meeting_duration_logic.sql**
```sql
-- Test Case TC_014: Meeting Duration Logic Validation
-- Validates that duration matches time difference within tolerance
SELECT 
    meeting_id,
    duration_minutes,
    DATEDIFF('minute', start_time, end_time) as calculated_duration,
    'Duration mismatch exceeds tolerance' as error_message
FROM {{ ref('si_meetings') }}
WHERE ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) > 1
   OR end_time <= start_time
```

#### **tests/test_data_quality_scores.sql**
```sql
-- Test Case TC_011: Data Quality Score Validation
-- Validates that all records have proper data quality scores
SELECT 
    'si_users' as table_name,
    user_id as record_id,
    data_quality_score,
    validation_status,
    'Invalid data quality score or validation status' as error_message
FROM {{ ref('si_users') }}
WHERE data_quality_score < 0 
   OR data_quality_score > 100 
   OR validation_status NOT IN ('PASSED', 'FAILED', 'WARNING')
   OR data_quality_score IS NULL
   OR validation_status IS NULL

UNION ALL

SELECT 
    'si_meetings' as table_name,
    meeting_id as record_id,
    data_quality_score,
    validation_status,
    'Invalid data quality score or validation status' as error_message
FROM {{ ref('si_meetings') }}
WHERE data_quality_score < 0 
   OR data_quality_score > 100 
   OR validation_status NOT IN ('PASSED', 'FAILED', 'WARNING')
   OR data_quality_score IS NULL
   OR validation_status IS NULL
```

#### **tests/test_referential_integrity.sql**
```sql
-- Test Case TC_010: Cross-Model Referential Integrity
-- Validates foreign key relationships across Silver layer models
SELECT 
    'si_meetings' as source_table,
    'si_users' as target_table,
    meeting_id as source_id,
    host_id as foreign_key,
    'Orphaned meeting host reference' as error_message
FROM {{ ref('si_meetings') }} m
LEFT JOIN {{ ref('si_users') }} u ON m.host_id = u.user_id
WHERE u.user_id IS NULL AND m.host_id IS NOT NULL

UNION ALL

SELECT 
    'si_participants' as source_table,
    'si_meetings' as target_table,
    participant_id as source_id,
    meeting_id as foreign_key,
    'Orphaned participant meeting reference' as error_message
FROM {{ ref('si_participants') }} p
LEFT JOIN {{ ref('si_meetings') }} m ON p.meeting_id = m.meeting_id
WHERE m.meeting_id IS NULL AND p.meeting_id IS NOT NULL

UNION ALL

SELECT 
    'si_licenses' as source_table,
    'si_users' as target_table,
    license_id as source_id,
    assigned_to_user_id as foreign_key,
    'Orphaned license user reference' as error_message
FROM {{ ref('si_licenses') }} l
LEFT JOIN {{ ref('si_users') }} u ON l.assigned_to_user_id = u.user_id
WHERE u.user_id IS NULL AND l.assigned_to_user_id IS NOT NULL
```

#### **tests/test_participant_session_logic.sql**
```sql
-- Test Case TC_005: Participant Session Time Validation
-- Validates that leave time is after join time and within meeting bounds
SELECT 
    p.participant_id,
    p.join_time,
    p.leave_time,
    m.start_time as meeting_start,
    m.end_time as meeting_end,
    'Invalid participant session times' as error_message
FROM {{ ref('si_participants') }} p
JOIN {{ ref('si_meetings') }} m ON p.meeting_id = m.meeting_id
WHERE p.leave_time <= p.join_time
   OR p.join_time < m.start_time
   OR p.leave_time > m.end_time
```

#### **tests/test_billing_amount_validation.sql**
```sql
-- Test Case TC_009: Billing Amount Validation
-- Validates that billing amounts are positive and within reasonable ranges
SELECT 
    event_id,
    amount,
    event_type,
    'Invalid billing amount detected' as error_message
FROM {{ ref('si_billing_events') }}
WHERE amount <= 0 
   OR amount > 99999.99
   OR amount IS NULL
```

#### **tests/test_future_date_validation.sql**
```sql
-- Test Case TC_008: Future Date Validation
-- Validates that dates are not in the future where business rules apply
SELECT 
    'si_support_tickets' as table_name,
    ticket_id as record_id,
    open_date,
    'Future open date detected' as error_message
FROM {{ ref('si_support_tickets') }}
WHERE open_date > CURRENT_DATE()

UNION ALL

SELECT 
    'si_billing_events' as table_name,
    event_id as record_id,
    event_date,
    'Future event date detected' as error_message
FROM {{ ref('si_billing_events') }}
WHERE event_date > CURRENT_DATE()
```

### **Parameterized Tests for Reusability**

#### **macros/test_data_freshness.sql**
```sql
{% macro test_data_freshness(model_name, timestamp_column, max_hours=24) %}
  SELECT 
    '{{ model_name }}' as table_name,
    MAX({{ timestamp_column }}) as latest_timestamp,
    DATEDIFF('hour', MAX({{ timestamp_column }}), CURRENT_TIMESTAMP()) as hours_since_update,
    'Data freshness exceeds {{ max_hours }} hours' as error_message
  FROM {{ ref(model_name) }}
  WHERE DATEDIFF('hour', MAX({{ timestamp_column }}), CURRENT_TIMESTAMP()) > {{ max_hours }}
  GROUP BY 1
  HAVING COUNT(*) > 0
{% endmacro %}
```

#### **tests/test_all_models_freshness.sql**
```sql
-- Test Case TC_015: Data Freshness Validation
-- Validates that all models have been updated within acceptable timeframes
{{ test_data_freshness('si_users', 'load_timestamp', 24) }}
UNION ALL
{{ test_data_freshness('si_meetings', 'load_timestamp', 24) }}
UNION ALL
{{ test_data_freshness('si_participants', 'load_timestamp', 24) }}
UNION ALL
{{ test_data_freshness('si_licenses', 'load_timestamp', 24) }}
UNION ALL
{{ test_data_freshness('si_feature_usage', 'load_timestamp', 24) }}
UNION ALL
{{ test_data_freshness('si_support_tickets', 'load_timestamp', 24) }}
UNION ALL
{{ test_data_freshness('si_billing_events', 'load_timestamp', 24) }}
```

---

## Test Execution Strategy

### **Priority Levels**

1. **Critical (P1)**: 
   - Duration text cleaning (TC_003)
   - DD/MM/YYYY date conversion (TC_006)
   - Referential integrity (TC_010)
   - Data quality scores (TC_011)

2. **High (P2)**:
   - Email validation (TC_002)
   - EST timezone conversion (TC_004)
   - MM/DD/YYYY timestamp conversion (TC_005)
   - Meeting duration logic (TC_014)

3. **Medium (P3)**:
   - Feature usage validation (TC_007)
   - Support ticket validation (TC_008)
   - Billing event validation (TC_009)
   - Participant session logic (TC_005)

4. **Low (P4)**:
   - Data freshness (TC_015)
   - Future date validation (TC_008)
   - Null value handling (TC_012)

### **Execution Commands**

```bash
# Run all tests
dbt test

# Run tests for specific model
dbt test --select si_meetings

# Run only critical P1 tests
dbt test --select tag:critical

# Run tests with specific severity
dbt test --select test_type:generic
dbt test --select test_type:singular

# Generate test documentation
dbt docs generate
dbt docs serve
```

### **Test Results Tracking**

Test results are automatically tracked in:
- **dbt's run_results.json**: Contains detailed test execution results
- **Snowflake audit schema**: SI_AUDIT_LOG table tracks all model executions
- **SI_DATA_QUALITY_ERRORS table**: Stores detailed error information for failed tests

### **Continuous Integration Integration**

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
      - name: Setup dbt
        run: |
          pip install dbt-snowflake
      - name: Run dbt tests
        run: |
          dbt deps
          dbt test --fail-fast
      - name: Generate test report
        run: |
          dbt docs generate
```

---

## Error Handling and Monitoring

### **Test Failure Handling**

1. **Immediate Actions**:
   - Log failure details to SI_AUDIT_LOG
   - Send alerts to data engineering team
   - Quarantine failed records in error tables

2. **Escalation Procedures**:
   - P1 failures: Immediate escalation to senior data engineer
   - P2 failures: Escalation within 2 hours
   - P3/P4 failures: Daily review and resolution

3. **Recovery Procedures**:
   - Implement data fixes based on test failure analysis
   - Re-run affected models after fixes
   - Validate fix effectiveness through test re-execution

### **Performance Monitoring**

```sql
-- Monitor test execution performance
SELECT 
    test_name,
    execution_time_seconds,
    status,
    error_count
FROM dbt_test_results
WHERE execution_date >= CURRENT_DATE() - 7
ORDER BY execution_time_seconds DESC;
```

---

## Maintenance and Updates

### **Regular Maintenance Tasks**

1. **Weekly**:
   - Review test failure trends
   - Update test thresholds based on data patterns
   - Clean up old test result data

2. **Monthly**:
   - Review and update test coverage
   - Add new tests for new business rules
   - Performance optimization of slow tests

3. **Quarterly**:
   - Comprehensive test suite review
   - Update test documentation
   - Stakeholder review of test effectiveness

### **Version Control**

All test scripts are version controlled with:
- Clear commit messages describing test changes
- Code review process for test modifications
- Rollback procedures for problematic test updates

---

## Conclusion

This comprehensive test suite ensures the reliability, accuracy, and performance of the Zoom Platform Analytics System Silver layer models in Snowflake. The tests cover critical data transformations, business rules, edge cases, and error handling scenarios, with particular focus on resolving the critical P1 issues:

- **Duration text cleaning** ("108 mins" error resolution)
- **DD/MM/YYYY date format conversion** ("27/08/2024" error resolution)
- **EST timezone standardization**
- **MM/DD/YYYY timestamp format conversion**

Regular execution of these tests will help maintain data quality, catch issues early in the development cycle, and ensure consistent, reliable analytics for business stakeholders.

**Next Steps**: Execute `dbt test` to run the complete test suite and validate all Silver layer transformations are working correctly.