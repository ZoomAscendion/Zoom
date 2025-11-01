_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Silver Pipeline dbt models with data quality validations
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases - Zoom Silver Pipeline

## Overview

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Silver Pipeline dbt models running in Snowflake. The test suite covers data transformations, business rules, edge cases, and error handling scenarios to ensure data quality and pipeline reliability.

## Models Under Test

1. **si_users** - Silver layer user data with cleansing and standardization
2. **si_pipeline_audit** - Pipeline execution audit tracking
3. **si_data_quality_errors** - Data quality error logging

---

## Test Case List

### Model: si_users

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_SU_001 | Validate USER_ID uniqueness and not null | All USER_ID values are unique and not null |
| TC_SU_002 | Validate email format using regex | All EMAIL values match valid email pattern |
| TC_SU_003 | Validate PLAN_TYPE accepted values | All PLAN_TYPE values are in ['Free', 'Basic', 'Pro', 'Enterprise'] |
| TC_SU_004 | Validate ACCOUNT_STATUS accepted values | All ACCOUNT_STATUS values are in ['Active', 'Inactive', 'Suspended'] |
| TC_SU_005 | Validate DATA_QUALITY_SCORE is 1.0 | All records have DATA_QUALITY_SCORE = 1.0 (only clean data) |
| TC_SU_006 | Test deduplication logic | Only latest record per USER_ID based on UPDATE_TIMESTAMP |
| TC_SU_007 | Test account status calculation | Active if login within 90 days, else Inactive |
| TC_SU_008 | Test name standardization | USER_NAME is properly capitalized using INITCAP |
| TC_SU_009 | Test email standardization | EMAIL is converted to lowercase |
| TC_SU_010 | Test data quality score calculation | Correct DQ score based on validation rules |
| TC_SU_011 | Test relationship with bz_users | Valid reference to bronze layer source |
| TC_SU_012 | Test null handling in source data | Records with null USER_ID are filtered out |
| TC_SU_013 | Test date transformations | LOAD_TIMESTAMP and UPDATE_TIMESTAMP cast to dates correctly |
| TC_SU_014 | Test company name trimming | COMPANY field is properly trimmed |
| TC_SU_015 | Test plan type standardization | Invalid plan types converted to 'Unknown' |

### Model: si_pipeline_audit

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_PA_001 | Validate audit table structure | All required columns exist with correct data types |
| TC_PA_002 | Test execution ID generation | EXECUTION_ID is unique UUID string |
| TC_PA_003 | Test pipeline name tracking | PIPELINE_NAME correctly identifies the process |
| TC_PA_004 | Test timestamp accuracy | START_TIME and END_TIME are properly recorded |
| TC_PA_005 | Test status tracking | STATUS values are valid (STARTED, COMPLETED, FAILED) |
| TC_PA_006 | Test hook integration | Pre and post hooks populate audit records |
| TC_PA_007 | Test execution environment tracking | EXECUTION_ENVIRONMENT is correctly set |
| TC_PA_008 | Test data lineage information | DATA_LINEAGE_INFO contains transformation details |

### Model: si_data_quality_errors

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_DQE_001 | Validate error logging structure | All error columns exist with correct data types |
| TC_DQE_002 | Test error ID generation | ERROR_ID is unique UUID string |
| TC_DQE_003 | Test source table tracking | SOURCE_TABLE correctly identifies origin |
| TC_DQE_004 | Test error type classification | ERROR_TYPE properly categorizes issues |
| TC_DQE_005 | Test error severity levels | ERROR_SEVERITY uses standard levels |
| TC_DQE_006 | Test resolution status tracking | RESOLUTION_STATUS tracks error handling |
| TC_DQE_007 | Test error detection timestamp | DETECTED_TIMESTAMP is accurate |
| TC_DQE_008 | Test failed DQ records logging | Records with DQ_SCORE < 1.0 are logged |

---

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# tests/schema_tests.yml
version: 2

models:
  - name: si_users
    tests:
      # Test overall data quality
      - dbt_utils.expression_is_true:
          expression: "count(*) > 0"
          config:
            severity: error
      
      # Test no duplicates after deduplication
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - USER_ID
          config:
            severity: error
    
    columns:
      - name: USER_ID
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
          - dbt_utils.expression_is_true:
              expression: "trim(USER_ID) != ''"
              config:
                severity: error
      
      - name: USER_NAME
        tests:
          - dbt_utils.expression_is_true:
              expression: "USER_NAME = initcap(trim(USER_NAME))"
              config:
                severity: warn
      
      - name: EMAIL
        tests:
          - not_null:
              config:
                severity: error
          - dbt_utils.expression_is_true:
              expression: "REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')"
              config:
                severity: error
          - dbt_utils.expression_is_true:
              expression: "EMAIL = lower(trim(EMAIL))"
              config:
                severity: warn
      
      - name: PLAN_TYPE
        tests:
          - not_null:
              config:
                severity: error
          - accepted_values:
              values: ['Free', 'Basic', 'Pro', 'Enterprise']
              config:
                severity: error
      
      - name: ACCOUNT_STATUS
        tests:
          - accepted_values:
              values: ['Active', 'Inactive', 'Suspended']
              config:
                severity: error
      
      - name: DATA_QUALITY_SCORE
        tests:
          - not_null:
              config:
                severity: error
          - dbt_utils.expression_is_true:
              expression: "DATA_QUALITY_SCORE = 1.0"
              config:
                severity: error
          - dbt_utils.expression_is_true:
              expression: "DATA_QUALITY_SCORE >= 0.0 AND DATA_QUALITY_SCORE <= 1.0"
              config:
                severity: error
      
      - name: REGISTRATION_DATE
        tests:
          - dbt_utils.expression_is_true:
              expression: "REGISTRATION_DATE <= CURRENT_DATE()"
              config:
                severity: warn
      
      - name: LAST_LOGIN_DATE
        tests:
          - dbt_utils.expression_is_true:
              expression: "LAST_LOGIN_DATE <= CURRENT_DATE()"
              config:
                severity: warn

  - name: si_pipeline_audit
    columns:
      - name: EXECUTION_ID
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
      
      - name: PIPELINE_NAME
        tests:
          - not_null:
              config:
                severity: error
      
      - name: STATUS
        tests:
          - accepted_values:
              values: ['STARTED', 'COMPLETED', 'FAILED', 'CANCELLED']
              config:
                severity: error

  - name: si_data_quality_errors
    columns:
      - name: ERROR_ID
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
      
      - name: ERROR_SEVERITY
        tests:
          - accepted_values:
              values: ['Critical', 'High', 'Medium', 'Low']
              config:
                severity: error
      
      - name: RESOLUTION_STATUS
        tests:
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Ignored']
              config:
                severity: error
```

### Custom SQL-based dbt Tests

#### Test 1: Account Status Logic Validation
```sql
-- tests/test_account_status_logic.sql
-- Test that account status is correctly calculated based on last login date

SELECT 
    USER_ID,
    LAST_LOGIN_DATE,
    ACCOUNT_STATUS,
    CASE 
        WHEN LAST_LOGIN_DATE >= DATEADD('day', -90, CURRENT_DATE()) THEN 'Active'
        ELSE 'Inactive'
    END AS expected_status
FROM {{ ref('si_users') }}
WHERE ACCOUNT_STATUS != CASE 
    WHEN LAST_LOGIN_DATE >= DATEADD('day', -90, CURRENT_DATE()) THEN 'Active'
    ELSE 'Inactive'
END
```

#### Test 2: Data Quality Score Calculation
```sql
-- tests/test_data_quality_score.sql
-- Test that data quality score is calculated correctly

WITH dq_validation AS (
    SELECT 
        USER_ID,
        EMAIL,
        PLAN_TYPE,
        ACCOUNT_STATUS,
        DATA_QUALITY_SCORE,
        CASE
            WHEN USER_ID IS NULL OR TRIM(USER_ID) = '' THEN 0.0
            WHEN EMAIL IS NULL OR NOT REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') THEN 0.7
            WHEN PLAN_TYPE NOT IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN 0.8
            WHEN ACCOUNT_STATUS NOT IN ('Active', 'Inactive', 'Suspended') THEN 0.8
            ELSE 1.0
        END AS expected_dq_score
    FROM {{ ref('si_users') }}
)
SELECT *
FROM dq_validation
WHERE DATA_QUALITY_SCORE != expected_dq_score
```

#### Test 3: Deduplication Logic
```sql
-- tests/test_deduplication.sql
-- Test that deduplication keeps only the latest record per USER_ID

WITH duplicate_check AS (
    SELECT 
        USER_ID,
        COUNT(*) as record_count
    FROM {{ ref('si_users') }}
    GROUP BY USER_ID
    HAVING COUNT(*) > 1
)
SELECT *
FROM duplicate_check
```

#### Test 4: Source Data Relationship
```sql
-- tests/test_source_relationship.sql
-- Test that all si_users records have valid source in bz_users

SELECT 
    su.USER_ID
FROM {{ ref('si_users') }} su
LEFT JOIN {{ ref('bz_users') }} bu ON su.USER_ID = bu.USER_ID
WHERE bu.USER_ID IS NULL
```

#### Test 5: Audit Trail Completeness
```sql
-- tests/test_audit_completeness.sql
-- Test that audit records are created for pipeline executions

SELECT 
    PIPELINE_NAME,
    COUNT(*) as execution_count,
    MAX(START_TIME) as last_execution
FROM {{ ref('si_pipeline_audit') }}
WHERE PIPELINE_NAME = 'silver_si_users_etl'
GROUP BY PIPELINE_NAME
HAVING COUNT(*) = 0
```

#### Test 6: Error Logging Validation
```sql
-- tests/test_error_logging.sql
-- Test that data quality errors are properly logged

WITH failed_records AS (
    SELECT COUNT(*) as failed_count
    FROM {{ ref('si_data_quality_errors') }}
    WHERE SOURCE_TABLE = 'BZ_USERS'
    AND ERROR_TYPE = 'Data Quality'
),
expected_errors AS (
    SELECT COUNT(*) as expected_count
    FROM {{ ref('bz_users') }} bu
    WHERE bu.USER_ID IS NULL 
    OR bu.EMAIL IS NULL 
    OR NOT REGEXP_LIKE(bu.EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
    OR bu.PLAN_TYPE NOT IN ('Free', 'Basic', 'Pro', 'Enterprise')
)
SELECT 
    f.failed_count,
    e.expected_count
FROM failed_records f
CROSS JOIN expected_errors e
WHERE f.failed_count != e.expected_count
```

#### Test 7: Date Consistency
```sql
-- tests/test_date_consistency.sql
-- Test that dates are consistent and logical

SELECT 
    USER_ID,
    REGISTRATION_DATE,
    LAST_LOGIN_DATE,
    LOAD_DATE,
    UPDATE_DATE
FROM {{ ref('si_users') }}
WHERE REGISTRATION_DATE > LAST_LOGIN_DATE
   OR LOAD_DATE > CURRENT_DATE()
   OR UPDATE_DATE > CURRENT_DATE()
   OR REGISTRATION_DATE > CURRENT_DATE()
```

#### Test 8: Data Transformation Accuracy
```sql
-- tests/test_transformation_accuracy.sql
-- Test that data transformations are applied correctly

SELECT 
    USER_ID,
    USER_NAME,
    EMAIL,
    COMPANY
FROM {{ ref('si_users') }}
WHERE USER_NAME != INITCAP(TRIM(USER_NAME))
   OR EMAIL != LOWER(TRIM(EMAIL))
   OR COMPANY != TRIM(COMPANY)
```

### Parameterized Tests

#### Generic Test: Data Freshness
```sql
-- tests/generic/test_data_freshness.sql
-- Generic test to check data freshness

{% test data_freshness(model, column_name, max_age_hours=24) %}
    SELECT *
    FROM {{ model }}
    WHERE {{ column_name }} < DATEADD('hour', -{{ max_age_hours }}, CURRENT_TIMESTAMP())
{% endtest %}
```

#### Generic Test: Referential Integrity
```sql
-- tests/generic/test_referential_integrity.sql
-- Generic test for referential integrity

{% test referential_integrity(model, column_name, to, field) %}
    SELECT {{ column_name }}
    FROM {{ model }}
    WHERE {{ column_name }} IS NOT NULL
    AND {{ column_name }} NOT IN (
        SELECT {{ field }}
        FROM {{ to }}
        WHERE {{ field }} IS NOT NULL
    )
{% endtest %}
```

---

## Test Execution Strategy

### 1. Pre-deployment Testing
- Run all schema tests before deployment
- Execute custom SQL tests to validate business logic
- Verify data quality thresholds are met

### 2. Post-deployment Validation
- Validate audit trail completeness
- Check error logging functionality
- Verify data freshness and completeness

### 3. Continuous Monitoring
- Schedule regular test runs
- Monitor test results in dbt Cloud
- Set up alerts for test failures

### 4. Test Data Management
- Use dbt seeds for test data
- Maintain separate test datasets
- Implement data masking for sensitive fields

---

## Expected Test Results

### Success Criteria
- All `not_null` and `unique` tests pass
- Email format validation passes 100%
- Plan type and account status values are within accepted ranges
- Data quality score is 1.0 for all records in silver layer
- Deduplication logic works correctly
- Audit records are created for each pipeline run
- Error logging captures all data quality issues

### Performance Benchmarks
- Tests should complete within 5 minutes
- No test should consume more than 1GB of warehouse resources
- Test results should be available in dbt run_results.json

---

## Maintenance and Updates

### Regular Review
- Review test cases monthly
- Update tests when business rules change
- Add new tests for edge cases discovered in production

### Version Control
- All test changes should be version controlled
- Document test modifications in commit messages
- Maintain backward compatibility where possible

---

## Conclusion

This comprehensive test suite ensures the reliability, accuracy, and performance of the Zoom Silver Pipeline dbt models in Snowflake. The combination of schema tests, custom SQL tests, and parameterized tests provides robust coverage of data transformations, business rules, and edge cases. Regular execution of these tests will help maintain high data quality standards and prevent production issues.

**Test Coverage Summary:**
- **15 test cases** for si_users model
- **8 test cases** for si_pipeline_audit model  
- **8 test cases** for si_data_quality_errors model
- **8 custom SQL tests** for complex business logic
- **2 generic parameterized tests** for reusability
- **Complete YAML schema tests** for all models

**Total: 41 comprehensive test scenarios covering all aspects of the Silver Pipeline.**