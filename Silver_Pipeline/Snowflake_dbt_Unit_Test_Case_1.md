_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Platform Analytics Silver Layer dbt models in Snowflake
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases - Zoom Platform Analytics Silver Layer

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics Silver Layer models running in Snowflake. The test suite covers data transformations, business rules, edge cases, and error handling scenarios to ensure data quality and pipeline reliability.

## Models Under Test

The following Silver Layer models are covered in this test suite:

1. **SI_Audit_Log** - Audit table for pipeline execution tracking
2. **SI_USERS** - User profiles with email validation and plan type standardization
3. **SI_FEATURE_USAGE** - Platform feature usage with validation and standardization
4. **SI_SUPPORT_TICKETS** - Support tickets with status standardization
5. **SI_BILLING_EVENTS** - Financial transactions with amount validation
6. **SI_LICENSES** - License assignments with date validation
7. **SI_MEETINGS** - Meeting data transformation (timestamp format issues)
8. **SI_PARTICIPANTS** - Participant data transformation (timestamp format issues)

## Test Case Categories

### 1. Data Quality Tests
### 2. Business Rule Validation Tests
### 3. Edge Case Tests
### 4. Error Handling Tests
### 5. Performance Tests

---

## Test Case List

| Test Case ID | Model | Test Case Description | Expected Outcome | Test Type |
|--------------|-------|----------------------|------------------|----------|
| TC_001 | SI_USERS | Validate email format using regex pattern | All emails follow valid format or are marked as invalid | Data Quality |
| TC_002 | SI_USERS | Verify plan type standardization (FREE, BASIC, PRO, ENTERPRISE) | All plan types are standardized with proper defaults | Business Rule |
| TC_003 | SI_USERS | Test data quality scoring (0-100 scale) | Quality scores calculated based on completeness and validity | Data Quality |
| TC_004 | SI_USERS | Validate null handling for critical fields | No null values in primary key and required fields | Data Quality |
| TC_005 | SI_USERS | Test deduplication logic using ROW_NUMBER() | Only latest valid records retained per user | Data Quality |
| TC_006 | SI_FEATURE_USAGE | Validate usage count non-negative values | All usage counts >= 0 | Business Rule |
| TC_007 | SI_FEATURE_USAGE | Test feature name standardization | Feature names are properly trimmed and standardized | Data Quality |
| TC_008 | SI_FEATURE_USAGE | Validate date range logic | Usage dates within valid business date ranges | Business Rule |
| TC_009 | SI_SUPPORT_TICKETS | Test status standardization (OPEN, IN PROGRESS, RESOLVED, CLOSED) | All ticket statuses follow standard values | Business Rule |
| TC_010 | SI_SUPPORT_TICKETS | Validate ticket priority handling | Priority values are within acceptable range | Business Rule |
| TC_011 | SI_BILLING_EVENTS | Test positive amount validation | All billing amounts are positive with 2 decimal precision | Business Rule |
| TC_012 | SI_BILLING_EVENTS | Validate currency code standardization | Currency codes follow ISO standards | Data Quality |
| TC_013 | SI_BILLING_EVENTS | Test transaction type validation | Transaction types are from approved list | Business Rule |
| TC_014 | SI_LICENSES | Validate date logic (start < end dates) | License start dates are before end dates | Business Rule |
| TC_015 | SI_LICENSES | Test license status validation | License statuses are from approved values | Business Rule |
| TC_016 | SI_MEETINGS | Validate meeting duration (0-1440 minutes) | Meeting durations within valid range | Business Rule |
| TC_017 | SI_MEETINGS | Test timestamp format handling | Timestamps properly formatted or flagged for correction | Data Quality |
| TC_018 | SI_PARTICIPANTS | Validate participant count consistency | Participant counts match meeting records | Data Quality |
| TC_019 | SI_PARTICIPANTS | Test join/leave time logic | Join times before leave times | Business Rule |
| TC_020 | SI_Audit_Log | Validate audit trail completeness | All pipeline executions logged with metadata | Data Quality |
| TC_021 | All Models | Test TRY_TO_* function error handling | Graceful handling of data type conversion errors | Error Handling |
| TC_022 | All Models | Validate load timestamp consistency | Load timestamps properly populated | Data Quality |
| TC_023 | All Models | Test materialized table creation | All models materialize as tables successfully | Performance |
| TC_024 | All Models | Validate source-to-target mapping | All required source fields mapped to target | Data Quality |
| TC_025 | All Models | Test empty dataset handling | Models handle empty source datasets gracefully | Edge Case |

---

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# tests/schema.yml
version: 2

models:
  - name: si_users
    description: "Silver layer user profiles with data quality validations"
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
          - dbt_utils.expression_is_true:
              expression: "email RLIKE '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$' OR email IS NULL"
      - name: plan_type
        description: "Standardized plan type"
        tests:
          - accepted_values:
              values: ['FREE', 'BASIC', 'PRO', 'ENTERPRISE']
      - name: data_quality_score
        description: "Data quality score (0-100)"
        tests:
          - dbt_utils.expression_is_true:
              expression: "data_quality_score BETWEEN 0 AND 100"
      - name: load_date
        description: "Record load date"
        tests:
          - not_null

  - name: si_feature_usage
    description: "Silver layer feature usage with validations"
    columns:
      - name: usage_id
        description: "Unique usage identifier"
        tests:
          - unique
          - not_null
      - name: user_id
        description: "User identifier"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: usage_count
        description: "Feature usage count"
        tests:
          - dbt_utils.expression_is_true:
              expression: "usage_count >= 0"
      - name: feature_name
        description: "Standardized feature name"
        tests:
          - not_null

  - name: si_support_tickets
    description: "Silver layer support tickets with status validation"
    columns:
      - name: ticket_id
        description: "Unique ticket identifier"
        tests:
          - unique
          - not_null
      - name: status
        description: "Standardized ticket status"
        tests:
          - accepted_values:
              values: ['OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED']
      - name: priority
        description: "Ticket priority level"
        tests:
          - accepted_values:
              values: ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL']

  - name: si_billing_events
    description: "Silver layer billing events with amount validation"
    columns:
      - name: billing_id
        description: "Unique billing identifier"
        tests:
          - unique
          - not_null
      - name: amount
        description: "Billing amount"
        tests:
          - dbt_utils.expression_is_true:
              expression: "amount > 0"
      - name: currency_code
        description: "ISO currency code"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "LENGTH(currency_code) = 3"

  - name: si_licenses
    description: "Silver layer licenses with date validation"
    columns:
      - name: license_id
        description: "Unique license identifier"
        tests:
          - unique
          - not_null
      - name: start_date
        description: "License start date"
        tests:
          - not_null
      - name: end_date
        description: "License end date"
        tests:
          - dbt_utils.expression_is_true:
              expression: "end_date >= start_date"

  - name: si_meetings
    description: "Silver layer meetings with duration validation"
    columns:
      - name: meeting_id
        description: "Unique meeting identifier"
        tests:
          - unique
          - not_null
      - name: duration_minutes
        description: "Meeting duration in minutes"
        tests:
          - dbt_utils.expression_is_true:
              expression: "duration_minutes BETWEEN 0 AND 1440"

  - name: si_participants
    description: "Silver layer participants with time validation"
    columns:
      - name: participant_id
        description: "Unique participant identifier"
        tests:
          - unique
          - not_null
      - name: meeting_id
        description: "Meeting identifier"
        tests:
          - not_null
          - relationships:
              to: ref('si_meetings')
              field: meeting_id

  - name: si_audit_log
    description: "Silver layer audit log for pipeline tracking"
    columns:
      - name: audit_id
        description: "Unique audit identifier"
        tests:
          - unique
          - not_null
      - name: pipeline_name
        description: "Pipeline name"
        tests:
          - not_null
      - name: execution_status
        description: "Pipeline execution status"
        tests:
          - accepted_values:
              values: ['SUCCESS', 'FAILED', 'RUNNING', 'CANCELLED']
```

### Custom SQL-based dbt Tests

#### Test 1: Email Format Validation
```sql
-- tests/test_email_format_validation.sql
SELECT 
    user_id,
    email,
    'Invalid email format' as error_message
FROM {{ ref('si_users') }}
WHERE email IS NOT NULL 
  AND NOT REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
```

#### Test 2: Data Quality Score Calculation
```sql
-- tests/test_data_quality_score_calculation.sql
WITH quality_check AS (
    SELECT 
        user_id,
        data_quality_score,
        CASE 
            WHEN email IS NOT NULL AND REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') THEN 25
            ELSE 0
        END +
        CASE WHEN plan_type IS NOT NULL THEN 25 ELSE 0 END +
        CASE WHEN first_name IS NOT NULL THEN 25 ELSE 0 END +
        CASE WHEN last_name IS NOT NULL THEN 25 ELSE 0 END AS calculated_score
    FROM {{ ref('si_users') }}
)
SELECT 
    user_id,
    data_quality_score,
    calculated_score,
    'Data quality score mismatch' as error_message
FROM quality_check
WHERE ABS(data_quality_score - calculated_score) > 0
```

#### Test 3: Deduplication Logic Validation
```sql
-- tests/test_deduplication_logic.sql
SELECT 
    user_id,
    COUNT(*) as duplicate_count,
    'Duplicate records found after deduplication' as error_message
FROM {{ ref('si_users') }}
GROUP BY user_id
HAVING COUNT(*) > 1
```

#### Test 4: Billing Amount Validation
```sql
-- tests/test_billing_amount_validation.sql
SELECT 
    billing_id,
    amount,
    'Invalid billing amount' as error_message
FROM {{ ref('si_billing_events') }}
WHERE amount <= 0 
   OR amount IS NULL
   OR ROUND(amount, 2) != amount
```

#### Test 5: Date Logic Validation
```sql
-- tests/test_date_logic_validation.sql
SELECT 
    license_id,
    start_date,
    end_date,
    'Invalid date logic: end_date before start_date' as error_message
FROM {{ ref('si_licenses') }}
WHERE end_date < start_date
   OR start_date IS NULL
   OR end_date IS NULL
```

#### Test 6: Feature Usage Count Validation
```sql
-- tests/test_feature_usage_count_validation.sql
SELECT 
    usage_id,
    usage_count,
    'Invalid usage count' as error_message
FROM {{ ref('si_feature_usage') }}
WHERE usage_count < 0 
   OR usage_count IS NULL
```

#### Test 7: Meeting Duration Validation
```sql
-- tests/test_meeting_duration_validation.sql
SELECT 
    meeting_id,
    duration_minutes,
    'Invalid meeting duration' as error_message
FROM {{ ref('si_meetings') }}
WHERE duration_minutes < 0 
   OR duration_minutes > 1440
   OR duration_minutes IS NULL
```

#### Test 8: Audit Log Completeness
```sql
-- tests/test_audit_log_completeness.sql
SELECT 
    audit_id,
    pipeline_name,
    execution_status,
    'Incomplete audit log entry' as error_message
FROM {{ ref('si_audit_log') }}
WHERE pipeline_name IS NULL
   OR execution_status IS NULL
   OR start_time IS NULL
```

#### Test 9: Cross-Model Referential Integrity
```sql
-- tests/test_referential_integrity.sql
SELECT 
    fu.usage_id,
    fu.user_id,
    'Orphaned feature usage record' as error_message
FROM {{ ref('si_feature_usage') }} fu
LEFT JOIN {{ ref('si_users') }} u ON fu.user_id = u.user_id
WHERE u.user_id IS NULL
```

#### Test 10: Timestamp Format Validation
```sql
-- tests/test_timestamp_format_validation.sql
SELECT 
    meeting_id,
    start_time,
    'Invalid timestamp format' as error_message
FROM {{ ref('si_meetings') }}
WHERE TRY_TO_TIMESTAMP(start_time) IS NULL
  AND start_time IS NOT NULL
```

### Parameterized Tests

#### Generic Test for Positive Numbers
```sql
-- macros/test_positive_number.sql
{% macro test_positive_number(model, column_name) %}
    SELECT 
        {{ column_name }},
        'Value must be positive' as error_message
    FROM {{ model }}
    WHERE {{ column_name }} <= 0 
       OR {{ column_name }} IS NULL
{% endmacro %}
```

#### Generic Test for String Length
```sql
-- macros/test_string_length.sql
{% macro test_string_length(model, column_name, min_length=1, max_length=255) %}
    SELECT 
        {{ column_name }},
        'String length out of range' as error_message
    FROM {{ model }}
    WHERE LENGTH({{ column_name }}) < {{ min_length }}
       OR LENGTH({{ column_name }}) > {{ max_length }}
{% endmacro %}
```

## Test Execution Strategy

### 1. Pre-deployment Testing
- Run all schema tests before model deployment
- Execute custom SQL tests for business rule validation
- Validate data quality scores and completeness metrics

### 2. Post-deployment Validation
- Verify audit log entries for successful pipeline execution
- Check data quality metrics against established thresholds
- Validate cross-model referential integrity

### 3. Continuous Monitoring
- Schedule regular test execution using dbt Cloud or Airflow
- Set up alerts for test failures
- Monitor data quality trends over time

## Expected Test Results

### Success Criteria
- All unique and not_null tests pass
- Business rule validations return zero failed records
- Data quality scores within acceptable ranges (>= 70)
- No referential integrity violations
- All audit log entries complete and accurate

### Failure Scenarios
- Invalid email formats detected
- Duplicate records after deduplication
- Negative amounts in billing events
- Invalid date logic in licenses
- Missing audit trail entries

## Performance Considerations

### Test Optimization
- Use sampling for large datasets during development
- Implement incremental testing for changed records only
- Optimize test queries with appropriate indexes
- Parallel test execution where possible

### Monitoring
- Track test execution times
- Monitor resource usage during test runs
- Set up automated test result reporting
- Maintain test result history for trend analysis

## Maintenance and Updates

### Test Maintenance
- Regular review and update of test cases
- Addition of new tests for model changes
- Performance optimization of existing tests
- Documentation updates for new business rules

### Version Control
- All test scripts maintained in version control
- Test case documentation updated with model changes
- Change log maintained for test modifications
- Rollback procedures for failed test deployments

---

## Conclusion

This comprehensive test suite ensures the reliability, accuracy, and performance of the Zoom Platform Analytics Silver Layer dbt models in Snowflake. The combination of schema tests, custom SQL tests, and parameterized tests provides thorough coverage of data quality, business rules, and edge cases. Regular execution of these tests will maintain high data quality standards and prevent production issues.

**Test Coverage Summary:**
- 25 comprehensive test cases
- 8 Silver layer models covered
- Data quality, business rules, and edge cases addressed
- Custom SQL and YAML-based tests implemented
- Performance and monitoring considerations included
- Maintenance and update procedures defined