_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Silver Layer dbt models in Snowflake
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Zoom Silver Layer Pipeline

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Silver Layer dbt models running in Snowflake. The test cases cover data transformations, business rules validation, edge cases, and error handling scenarios to ensure data quality and pipeline reliability.

## Test Coverage Overview

The test suite covers 8 Silver Layer models:
- SI_Audit_Log (Audit tracking table)
- SI_USERS (User data transformation)
- SI_MEETINGS (Meeting data transformation)
- SI_PARTICIPANTS (Participant data transformation)
- SI_FEATURE_USAGE (Feature usage transformation)
- SI_SUPPORT_TICKETS (Support ticket transformation)
- SI_BILLING_EVENTS (Billing event transformation)
- SI_LICENSES (License data transformation)

## Test Case Categories

### 1. Data Quality Tests
### 2. Business Rule Validation Tests
### 3. Edge Case Tests
### 4. Referential Integrity Tests
### 5. Performance and Schema Tests

---

## Test Case List

| Test Case ID | Test Case Description | Model | Expected Outcome |
|--------------|----------------------|-------|------------------|
| TC_001 | Validate SI_USERS email format | SI_USERS | All emails follow valid format pattern |
| TC_002 | Validate SI_USERS plan type standardization | SI_USERS | Plan types are standardized to FREE, BASIC, PRO, ENTERPRISE |
| TC_003 | Validate SI_USERS deduplication logic | SI_USERS | Only latest record per user based on UPDATE_TIMESTAMP |
| TC_004 | Validate SI_USERS data quality score calculation | SI_USERS | Quality scores between 0-100 based on completeness |
| TC_005 | Validate SI_MEETINGS duration consistency | SI_MEETINGS | Duration matches calculated end_time - start_time |
| TC_006 | Validate SI_MEETINGS time logic | SI_MEETINGS | End time is greater than start time |
| TC_007 | Validate SI_MEETINGS duration range | SI_MEETINGS | Duration between 0-1440 minutes |
| TC_008 | Validate SI_PARTICIPANTS session time logic | SI_PARTICIPANTS | Leave time is greater than join time |
| TC_009 | Validate SI_PARTICIPANTS meeting boundary validation | SI_PARTICIPANTS | Participant times within meeting start/end boundaries |
| TC_010 | Validate SI_PARTICIPANTS meeting reference integrity | SI_PARTICIPANTS | All meeting IDs exist in SI_MEETINGS |
| TC_011 | Validate SI_FEATURE_USAGE usage count validation | SI_FEATURE_USAGE | Usage counts are non-negative |
| TC_012 | Validate SI_FEATURE_USAGE date consistency | SI_FEATURE_USAGE | Usage date aligns with meeting date |
| TC_013 | Validate SI_FEATURE_USAGE feature name standardization | SI_FEATURE_USAGE | Feature names are in UPPER case |
| TC_014 | Validate SI_SUPPORT_TICKETS status standardization | SI_SUPPORT_TICKETS | Status values are Open, In Progress, Resolved, Closed |
| TC_015 | Validate SI_SUPPORT_TICKETS date validation | SI_SUPPORT_TICKETS | Open date is less than or equal to current date |
| TC_016 | Validate SI_BILLING_EVENTS amount validation | SI_BILLING_EVENTS | All amounts are greater than 0 |
| TC_017 | Validate SI_BILLING_EVENTS date validation | SI_BILLING_EVENTS | Event date is less than or equal to current date |
| TC_018 | Validate SI_BILLING_EVENTS amount precision | SI_BILLING_EVENTS | Amounts rounded to 2 decimal places |
| TC_019 | Validate SI_LICENSES date logic | SI_LICENSES | Start date is less than or equal to end date |
| TC_020 | Validate SI_LICENSES user assignment | SI_LICENSES | All user IDs exist in SI_USERS |
| TC_021 | Validate SI_Audit_Log schema structure | SI_Audit_Log | All required columns exist with correct data types |
| TC_022 | Validate null handling across all models | ALL | Proper handling of null values per business rules |
| TC_023 | Validate record count consistency | ALL | Record counts match expected transformation logic |
| TC_024 | Validate validation status assignment | ALL | Proper PASSED/WARNING/FAILED status assignment |
| TC_025 | Validate cross-model referential integrity | ALL | Foreign key relationships maintained |

---

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# tests/schema.yml
version: 2

models:
  - name: SI_Audit_Log
    description: "Audit log table for Silver layer pipeline execution tracking"
    columns:
      - name: EXECUTION_ID
        description: "Unique identifier for pipeline execution"
        tests:
          - unique
          - not_null
      - name: PIPELINE_NAME
        description: "Name of the executed pipeline"
        tests:
          - not_null
      - name: EXECUTION_STATUS
        description: "Status of pipeline execution"
        tests:
          - accepted_values:
              values: ['SUCCESS', 'FAILED', 'RUNNING', 'CANCELLED']
      - name: RECORDS_PROCESSED
        description: "Total number of records processed"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: ">= 0"

  - name: SI_USERS
    description: "Silver layer table with cleaned and standardized user information"
    tests:
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - USER_ID
            - UPDATE_TIMESTAMP
    columns:
      - name: USER_ID
        description: "Unique user identifier"
        tests:
          - unique
          - not_null
      - name: EMAIL
        description: "User email address"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')"
      - name: PLAN_TYPE
        description: "Standardized plan type"
        tests:
          - accepted_values:
              values: ['FREE', 'BASIC', 'PRO', 'ENTERPRISE']
      - name: DATA_QUALITY_SCORE
        description: "Data quality score (0-100)"
        tests:
          - dbt_utils.expression_is_true:
              expression: ">= 0 AND <= 100"
      - name: VALIDATION_STATUS
        description: "Data validation status"
        tests:
          - accepted_values:
              values: ['PASSED', 'WARNING', 'FAILED']

  - name: SI_MEETINGS
    description: "Silver layer table with cleaned and validated meeting information"
    columns:
      - name: MEETING_ID
        description: "Unique meeting identifier"
        tests:
          - unique
          - not_null
      - name: HOST_USER_ID
        description: "Meeting host user ID"
        tests:
          - not_null
          - relationships:
              to: ref('SI_USERS')
              field: USER_ID
      - name: START_TIME
        description: "Meeting start time"
        tests:
          - not_null
      - name: END_TIME
        description: "Meeting end time"
        tests:
          - not_null
      - name: DURATION_MINUTES
        description: "Meeting duration in minutes"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: ">= 0 AND <= 1440"
      - name: VALIDATION_STATUS
        description: "Data validation status"
        tests:
          - accepted_values:
              values: ['PASSED', 'WARNING', 'FAILED']

  - name: SI_PARTICIPANTS
    description: "Silver layer table with validated meeting participant information"
    columns:
      - name: PARTICIPANT_ID
        description: "Unique participant identifier"
        tests:
          - unique
          - not_null
      - name: MEETING_ID
        description: "Associated meeting ID"
        tests:
          - not_null
          - relationships:
              to: ref('SI_MEETINGS')
              field: MEETING_ID
      - name: USER_ID
        description: "Participant user ID"
        tests:
          - not_null
          - relationships:
              to: ref('SI_USERS')
              field: USER_ID
      - name: JOIN_TIME
        description: "Participant join time"
        tests:
          - not_null
      - name: LEAVE_TIME
        description: "Participant leave time"
        tests:
          - not_null

  - name: SI_FEATURE_USAGE
    description: "Silver layer table with standardized feature usage information"
    columns:
      - name: USAGE_ID
        description: "Unique usage record identifier"
        tests:
          - unique
          - not_null
      - name: MEETING_ID
        description: "Associated meeting ID"
        tests:
          - not_null
          - relationships:
              to: ref('SI_MEETINGS')
              field: MEETING_ID
      - name: FEATURE_NAME
        description: "Standardized feature name"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "FEATURE_NAME = UPPER(FEATURE_NAME)"
      - name: USAGE_COUNT
        description: "Feature usage count"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: ">= 0"

  - name: SI_SUPPORT_TICKETS
    description: "Silver layer table with standardized support ticket information"
    columns:
      - name: TICKET_ID
        description: "Unique ticket identifier"
        tests:
          - unique
          - not_null
      - name: USER_ID
        description: "Ticket creator user ID"
        tests:
          - not_null
          - relationships:
              to: ref('SI_USERS')
              field: USER_ID
      - name: STATUS
        description: "Standardized ticket status"
        tests:
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed']
      - name: CREATED_DATE
        description: "Ticket creation date"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "<= CURRENT_DATE()"

  - name: SI_BILLING_EVENTS
    description: "Silver layer table with validated billing event information"
    columns:
      - name: EVENT_ID
        description: "Unique billing event identifier"
        tests:
          - unique
          - not_null
      - name: USER_ID
        description: "Associated user ID"
        tests:
          - not_null
          - relationships:
              to: ref('SI_USERS')
              field: USER_ID
      - name: AMOUNT
        description: "Billing amount"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "> 0"
      - name: EVENT_DATE
        description: "Billing event date"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "<= CURRENT_DATE()"

  - name: SI_LICENSES
    description: "Silver layer table with validated license information"
    columns:
      - name: LICENSE_ID
        description: "Unique license identifier"
        tests:
          - unique
          - not_null
      - name: USER_ID
        description: "License holder user ID"
        tests:
          - not_null
          - relationships:
              to: ref('SI_USERS')
              field: USER_ID
      - name: START_DATE
        description: "License start date"
        tests:
          - not_null
      - name: END_DATE
        description: "License end date"
        tests:
          - not_null
```

### Custom SQL-based dbt Tests

#### Test 1: Email Format Validation
```sql
-- tests/test_email_format_validation.sql
{{ config(severity = 'error') }}

SELECT 
    USER_ID,
    EMAIL,
    'Invalid email format' AS error_message
FROM {{ ref('SI_USERS') }}
WHERE EMAIL IS NOT NULL 
  AND NOT REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
```

#### Test 2: Meeting Duration Consistency
```sql
-- tests/test_meeting_duration_consistency.sql
{{ config(severity = 'warn') }}

SELECT 
    MEETING_ID,
    START_TIME,
    END_TIME,
    DURATION_MINUTES,
    DATEDIFF('minute', START_TIME, END_TIME) AS calculated_duration,
    'Duration inconsistency detected' AS error_message
FROM {{ ref('SI_MEETINGS') }}
WHERE ABS(DURATION_MINUTES - DATEDIFF('minute', START_TIME, END_TIME)) > 1
```

#### Test 3: Participant Session Time Logic
```sql
-- tests/test_participant_session_time_logic.sql
{{ config(severity = 'error') }}

SELECT 
    p.PARTICIPANT_ID,
    p.MEETING_ID,
    p.JOIN_TIME,
    p.LEAVE_TIME,
    m.START_TIME AS meeting_start,
    m.END_TIME AS meeting_end,
    'Invalid participant session times' AS error_message
FROM {{ ref('SI_PARTICIPANTS') }} p
JOIN {{ ref('SI_MEETINGS') }} m ON p.MEETING_ID = m.MEETING_ID
WHERE p.LEAVE_TIME <= p.JOIN_TIME
   OR p.JOIN_TIME < m.START_TIME
   OR p.LEAVE_TIME > m.END_TIME
```

#### Test 4: Data Quality Score Validation
```sql
-- tests/test_data_quality_score_validation.sql
{{ config(severity = 'error') }}

SELECT 
    USER_ID,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS,
    'Invalid quality score or status combination' AS error_message
FROM {{ ref('SI_USERS') }}
WHERE (DATA_QUALITY_SCORE >= 90 AND VALIDATION_STATUS != 'PASSED')
   OR (DATA_QUALITY_SCORE BETWEEN 70 AND 89 AND VALIDATION_STATUS != 'WARNING')
   OR (DATA_QUALITY_SCORE < 70 AND VALIDATION_STATUS != 'FAILED')
   OR DATA_QUALITY_SCORE < 0 
   OR DATA_QUALITY_SCORE > 100
```

#### Test 5: Feature Usage Date Consistency
```sql
-- tests/test_feature_usage_date_consistency.sql
{{ config(severity = 'warn') }}

SELECT 
    fu.USAGE_ID,
    fu.MEETING_ID,
    fu.USAGE_DATE,
    m.START_TIME::DATE AS meeting_date,
    'Feature usage date does not align with meeting date' AS error_message
FROM {{ ref('SI_FEATURE_USAGE') }} fu
JOIN {{ ref('SI_MEETINGS') }} m ON fu.MEETING_ID = m.MEETING_ID
WHERE fu.USAGE_DATE != m.START_TIME::DATE
```

#### Test 6: Billing Amount Precision Validation
```sql
-- tests/test_billing_amount_precision.sql
{{ config(severity = 'warn') }}

SELECT 
    EVENT_ID,
    AMOUNT,
    'Amount precision exceeds 2 decimal places' AS error_message
FROM {{ ref('SI_BILLING_EVENTS') }}
WHERE AMOUNT != ROUND(AMOUNT, 2)
```

#### Test 7: License Date Logic Validation
```sql
-- tests/test_license_date_logic.sql
{{ config(severity = 'error') }}

SELECT 
    LICENSE_ID,
    USER_ID,
    START_DATE,
    END_DATE,
    'Invalid license date range' AS error_message
FROM {{ ref('SI_LICENSES') }}
WHERE END_DATE < START_DATE
   OR START_DATE > CURRENT_DATE()
```

#### Test 8: Cross-Model Record Count Validation
```sql
-- tests/test_cross_model_record_counts.sql
{{ config(severity = 'warn') }}

WITH source_counts AS (
    SELECT 'BZ_USERS' AS table_name, COUNT(*) AS source_count FROM {{ source('bronze', 'BZ_USERS') }}
    UNION ALL
    SELECT 'BZ_MEETINGS', COUNT(*) FROM {{ source('bronze', 'BZ_MEETINGS') }}
    UNION ALL
    SELECT 'BZ_PARTICIPANTS', COUNT(*) FROM {{ source('bronze', 'BZ_PARTICIPANTS') }}
    UNION ALL
    SELECT 'BZ_FEATURE_USAGE', COUNT(*) FROM {{ source('bronze', 'BZ_FEATURE_USAGE') }}
    UNION ALL
    SELECT 'BZ_SUPPORT_TICKETS', COUNT(*) FROM {{ source('bronze', 'BZ_SUPPORT_TICKETS') }}
    UNION ALL
    SELECT 'BZ_BILLING_EVENTS', COUNT(*) FROM {{ source('bronze', 'BZ_BILLING_EVENTS') }}
    UNION ALL
    SELECT 'BZ_LICENSES', COUNT(*) FROM {{ source('bronze', 'BZ_LICENSES') }}
),
silver_counts AS (
    SELECT 'SI_USERS' AS table_name, COUNT(*) AS silver_count FROM {{ ref('SI_USERS') }}
    UNION ALL
    SELECT 'SI_MEETINGS', COUNT(*) FROM {{ ref('SI_MEETINGS') }}
    UNION ALL
    SELECT 'SI_PARTICIPANTS', COUNT(*) FROM {{ ref('SI_PARTICIPANTS') }}
    UNION ALL
    SELECT 'SI_FEATURE_USAGE', COUNT(*) FROM {{ ref('SI_FEATURE_USAGE') }}
    UNION ALL
    SELECT 'SI_SUPPORT_TICKETS', COUNT(*) FROM {{ ref('SI_SUPPORT_TICKETS') }}
    UNION ALL
    SELECT 'SI_BILLING_EVENTS', COUNT(*) FROM {{ ref('SI_BILLING_EVENTS') }}
    UNION ALL
    SELECT 'SI_LICENSES', COUNT(*) FROM {{ ref('SI_LICENSES') }}
)
SELECT 
    sc.table_name,
    sc.source_count,
    sic.silver_count,
    'Significant record count difference between Bronze and Silver' AS error_message
FROM source_counts sc
JOIN silver_counts sic ON REPLACE(sc.table_name, 'BZ_', 'SI_') = sic.table_name
WHERE ABS(sc.source_count - sic.silver_count) > (sc.source_count * 0.1) -- More than 10% difference
```

#### Test 9: Audit Log Completeness
```sql
-- tests/test_audit_log_completeness.sql
{{ config(severity = 'error') }}

SELECT 
    EXECUTION_ID,
    PIPELINE_NAME,
    'Incomplete audit log entry' AS error_message
FROM {{ ref('SI_Audit_Log') }}
WHERE EXECUTION_ID IS NULL
   OR PIPELINE_NAME IS NULL
   OR EXECUTION_STATUS IS NULL
   OR EXECUTION_START_TIME IS NULL
```

#### Test 10: Deduplication Validation
```sql
-- tests/test_deduplication_validation.sql
{{ config(severity = 'error') }}

WITH duplicate_check AS (
    SELECT 
        USER_ID,
        COUNT(*) as record_count
    FROM {{ ref('SI_USERS') }}
    GROUP BY USER_ID
    HAVING COUNT(*) > 1
)
SELECT 
    USER_ID,
    record_count,
    'Duplicate user records found after deduplication' AS error_message
FROM duplicate_check
```

## Test Execution Strategy

### 1. Pre-deployment Tests
- Schema validation tests
- Data type consistency tests
- Basic null checks

### 2. Post-deployment Tests
- Business rule validation
- Cross-model referential integrity
- Data quality score validation

### 3. Continuous Monitoring Tests
- Record count anomaly detection
- Data freshness validation
- Performance threshold monitoring

## Test Configuration

### dbt_project.yml Test Configuration
```yaml
tests:
  zoom_silver_pipeline:
    +severity: warn
    +store_failures: true
    +schema: dbt_test_audit
    
    # Critical tests that should fail the build
    critical:
      +severity: error
      +store_failures: true
      
    # Warning tests for monitoring
    monitoring:
      +severity: warn
      +store_failures: true
```

### Test Execution Commands

```bash
# Run all tests
dbt test

# Run tests for specific model
dbt test --select SI_USERS

# Run only critical tests
dbt test --select tag:critical

# Run tests and store failures
dbt test --store-failures

# Run tests with specific severity
dbt test --severity error
```

## Expected Test Results

### Success Criteria
- All critical tests (severity: error) must pass
- Warning tests should have < 5% failure rate
- All referential integrity tests must pass
- Data quality scores should average > 85

### Failure Handling
- Critical test failures block deployment
- Warning test failures logged for monitoring
- Failed records stored in audit schema
- Automated alerts for test failures

## Monitoring and Alerting

### Test Result Tracking
- Test results stored in `run_results.json`
- Failed test details in Snowflake audit schema
- Integration with monitoring dashboards
- Automated email alerts for critical failures

### Performance Monitoring
- Test execution time tracking
- Resource utilization monitoring
- Query performance optimization
- Parallel test execution optimization

---

## Conclusion

This comprehensive test suite ensures the reliability, accuracy, and performance of the Zoom Silver Layer dbt models in Snowflake. The combination of YAML-based schema tests and custom SQL tests provides thorough coverage of data quality, business rules, and edge cases, enabling confident deployment and operation of the data pipeline.

Regular execution of these tests will help maintain data integrity, catch issues early in the development cycle, and ensure consistent, high-quality data delivery to downstream consumers.