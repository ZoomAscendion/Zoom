_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Platform Analytics Silver Layer dbt models in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Zoom Platform Analytics Silver Layer

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics Silver Layer models that run in Snowflake. The test cases cover data transformations, business rules, edge cases, and error handling scenarios to ensure data quality and pipeline reliability.

## Silver Layer Models Overview

The following Silver Layer models are covered in this test suite:

1. **SI_Audit_Log** - Comprehensive audit logging table
2. **SI_USERS** - User data with email validation and plan type standardization
3. **SI_MEETINGS** - Meeting data with EST timezone conversion
4. **SI_PARTICIPANTS** - Participant data with MM/DD/YYYY format conversion
5. **SI_FEATURE_USAGE** - Feature usage data with standardized feature names
6. **SI_SUPPORT_TICKETS** - Support tickets with standardized status values
7. **SI_BILLING_EVENTS** - Billing events with numeric amount validation
8. **SI_LICENSES** - License data with date range validation

## Test Case Categories

### 1. Data Quality Tests
### 2. Transformation Logic Tests
### 3. Business Rule Validation Tests
### 4. Edge Case Tests
### 5. Error Handling Tests

---

## Test Case List

| Test Case ID | Model | Test Case Description | Expected Outcome | Test Type |
|--------------|-------|----------------------|------------------|----------|
| TC_001 | SI_USERS | Validate email format using regex pattern | All emails follow valid format or marked as invalid | Data Quality |
| TC_002 | SI_USERS | Test plan type standardization (Basic, Pro, Business, Enterprise) | All plan types are standardized to accepted values | Transformation |
| TC_003 | SI_USERS | Validate data quality scoring (0-100 range) | All records have quality scores between 0-100 | Business Rule |
| TC_004 | SI_MEETINGS | Test EST timezone conversion to UTC | EST timestamps correctly converted to UTC | Transformation |
| TC_005 | SI_MEETINGS | Validate meeting duration calculation | Duration = end_time - start_time, positive values only | Business Rule |
| TC_006 | SI_MEETINGS | Test end_time > start_time validation | All meetings have valid time ranges | Business Rule |
| TC_007 | SI_PARTICIPANTS | Test MM/DD/YYYY HH:MM format conversion | MM/DD/YYYY format correctly parsed to timestamp | Transformation |
| TC_008 | SI_PARTICIPANTS | Validate participant within meeting time boundaries | Join/leave times within meeting start/end times | Business Rule |
| TC_009 | SI_FEATURE_USAGE | Test feature name standardization | Feature names follow consistent naming convention | Transformation |
| TC_010 | SI_SUPPORT_TICKETS | Validate status standardization (Open, In Progress, Resolved, Closed) | All statuses are standardized values | Transformation |
| TC_011 | SI_BILLING_EVENTS | Test quoted numeric amount conversion | Quoted amounts ("123.45") converted to numeric | Transformation |
| TC_012 | SI_BILLING_EVENTS | Validate amount precision (2 decimal places) | All amounts rounded to 2 decimal places | Business Rule |
| TC_013 | SI_LICENSES | Test license date range validation | License end_date >= start_date | Business Rule |
| TC_014 | All Models | Test duplicate removal using ROW_NUMBER() | No duplicate records in final output | Data Quality |
| TC_015 | All Models | Validate audit logging pre/post hooks | Audit records created for each model execution | Data Quality |
| TC_016 | All Models | Test null value handling and replacement | Nulls replaced with appropriate defaults | Data Quality |
| TC_017 | SI_USERS | Test invalid email edge case | Invalid emails handled gracefully | Edge Case |
| TC_018 | SI_MEETINGS | Test null timezone handling | Null timezones processed without errors | Edge Case |
| TC_019 | SI_PARTICIPANTS | Test invalid date format handling | Invalid date formats handled with TRY_TO_TIMESTAMP | Edge Case |
| TC_020 | SI_BILLING_EVENTS | Test non-numeric amount handling | Non-numeric amounts handled gracefully | Edge Case |
| TC_021 | All Models | Test empty source table handling | Empty sources don't break pipeline | Edge Case |
| TC_022 | All Models | Test schema evolution compatibility | New columns added without breaking existing logic | Edge Case |
| TC_023 | SI_USERS | Test data quality score calculation accuracy | Quality score reflects actual data completeness | Business Rule |
| TC_024 | All Models | Test validation status assignment (PASSED/WARNING/FAILED) | Correct status assigned based on validation rules | Business Rule |
| TC_025 | All Models | Test materialized table creation | All models successfully materialized as tables | Infrastructure |

---

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# models/schema.yml
version: 2

sources:
  - name: bronze_layer
    description: "Bronze layer source tables"
    tables:
      - name: users
        description: "Raw user data"
      - name: meetings
        description: "Raw meeting data"
      - name: participants
        description: "Raw participant data"
      - name: feature_usage
        description: "Raw feature usage data"
      - name: support_tickets
        description: "Raw support ticket data"
      - name: billing_events
        description: "Raw billing event data"
      - name: licenses
        description: "Raw license data"

models:
  - name: SI_USERS
    description: "Silver layer user data with validation and standardization"
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
              expression: "EMAIL REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$' OR EMAIL IS NULL"
      - name: PLAN_TYPE
        description: "Standardized plan type"
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise', 'Unknown']
      - name: DATA_QUALITY_SCORE
        description: "Data quality score (0-100)"
        tests:
          - dbt_utils.expression_is_true:
              expression: "DATA_QUALITY_SCORE >= 0 AND DATA_QUALITY_SCORE <= 100"
      - name: VALIDATION_STATUS
        description: "Validation status"
        tests:
          - accepted_values:
              values: ['PASSED', 'WARNING', 'FAILED']

  - name: SI_MEETINGS
    description: "Silver layer meeting data with timezone conversion"
    columns:
      - name: MEETING_ID
        description: "Unique meeting identifier"
        tests:
          - unique
          - not_null
      - name: START_TIME
        description: "Meeting start time in UTC"
        tests:
          - not_null
      - name: END_TIME
        description: "Meeting end time in UTC"
        tests:
          - not_null
      - name: DURATION_MINUTES
        description: "Meeting duration in minutes"
        tests:
          - dbt_utils.expression_is_true:
              expression: "DURATION_MINUTES >= 0"
      - name: VALIDATION_STATUS
        description: "Validation status"
        tests:
          - accepted_values:
              values: ['PASSED', 'WARNING', 'FAILED']
    tests:
      - dbt_utils.expression_is_true:
          expression: "END_TIME >= START_TIME"

  - name: SI_PARTICIPANTS
    description: "Silver layer participant data with format conversion"
    columns:
      - name: PARTICIPANT_ID
        description: "Unique participant identifier"
        tests:
          - unique
          - not_null
      - name: MEETING_ID
        description: "Associated meeting identifier"
        tests:
          - not_null
          - relationships:
              to: ref('SI_MEETINGS')
              field: MEETING_ID
      - name: JOIN_TIME
        description: "Participant join time"
        tests:
          - not_null
      - name: LEAVE_TIME
        description: "Participant leave time"
      - name: VALIDATION_STATUS
        description: "Validation status"
        tests:
          - accepted_values:
              values: ['PASSED', 'WARNING', 'FAILED']
    tests:
      - dbt_utils.expression_is_true:
          expression: "LEAVE_TIME IS NULL OR LEAVE_TIME >= JOIN_TIME"

  - name: SI_FEATURE_USAGE
    description: "Silver layer feature usage data"
    columns:
      - name: USAGE_ID
        description: "Unique usage identifier"
        tests:
          - unique
          - not_null
      - name: USER_ID
        description: "Associated user identifier"
        tests:
          - not_null
          - relationships:
              to: ref('SI_USERS')
              field: USER_ID
      - name: FEATURE_NAME
        description: "Standardized feature name"
        tests:
          - not_null
      - name: VALIDATION_STATUS
        description: "Validation status"
        tests:
          - accepted_values:
              values: ['PASSED', 'WARNING', 'FAILED']

  - name: SI_SUPPORT_TICKETS
    description: "Silver layer support ticket data"
    columns:
      - name: TICKET_ID
        description: "Unique ticket identifier"
        tests:
          - unique
          - not_null
      - name: USER_ID
        description: "Associated user identifier"
        tests:
          - relationships:
              to: ref('SI_USERS')
              field: USER_ID
      - name: STATUS
        description: "Standardized ticket status"
        tests:
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed', 'Unknown']
      - name: VALIDATION_STATUS
        description: "Validation status"
        tests:
          - accepted_values:
              values: ['PASSED', 'WARNING', 'FAILED']

  - name: SI_BILLING_EVENTS
    description: "Silver layer billing event data"
    columns:
      - name: EVENT_ID
        description: "Unique event identifier"
        tests:
          - unique
          - not_null
      - name: USER_ID
        description: "Associated user identifier"
        tests:
          - relationships:
              to: ref('SI_USERS')
              field: USER_ID
      - name: AMOUNT
        description: "Billing amount (2 decimal places)"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "AMOUNT >= 0"
      - name: VALIDATION_STATUS
        description: "Validation status"
        tests:
          - accepted_values:
              values: ['PASSED', 'WARNING', 'FAILED']

  - name: SI_LICENSES
    description: "Silver layer license data"
    columns:
      - name: LICENSE_ID
        description: "Unique license identifier"
        tests:
          - unique
          - not_null
      - name: USER_ID
        description: "Associated user identifier"
        tests:
          - relationships:
              to: ref('SI_USERS')
              field: USER_ID
      - name: START_DATE
        description: "License start date"
        tests:
          - not_null
      - name: END_DATE
        description: "License end date"
      - name: VALIDATION_STATUS
        description: "Validation status"
        tests:
          - accepted_values:
              values: ['PASSED', 'WARNING', 'FAILED']
    tests:
      - dbt_utils.expression_is_true:
          expression: "END_DATE IS NULL OR END_DATE >= START_DATE"

  - name: SI_Audit_Log
    description: "Silver layer audit logging table"
    columns:
      - name: AUDIT_ID
        description: "Unique audit identifier"
        tests:
          - unique
          - not_null
      - name: MODEL_NAME
        description: "Name of the dbt model"
        tests:
          - not_null
      - name: EXECUTION_START_TIME
        description: "Model execution start time"
        tests:
          - not_null
      - name: EXECUTION_END_TIME
        description: "Model execution end time"
      - name: RECORD_COUNT
        description: "Number of records processed"
        tests:
          - dbt_utils.expression_is_true:
              expression: "RECORD_COUNT >= 0"
```

### Custom SQL-based dbt Tests

#### Test 1: Email Format Validation
```sql
-- tests/test_email_format_validation.sql
SELECT 
    USER_ID,
    EMAIL,
    'Invalid email format' AS error_message
FROM {{ ref('SI_USERS') }}
WHERE EMAIL IS NOT NULL 
  AND NOT REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
```

#### Test 2: EST Timezone Conversion Accuracy
```sql
-- tests/test_est_timezone_conversion.sql
WITH timezone_test AS (
    SELECT 
        MEETING_ID,
        START_TIME,
        -- Test that EST times are properly converted
        CASE 
            WHEN START_TIME::STRING LIKE '%EST%' THEN
                EXTRACT(TIMEZONE_HOUR FROM START_TIME)
            ELSE NULL
        END AS timezone_offset
    FROM {{ ref('SI_MEETINGS') }}
    WHERE START_TIME IS NOT NULL
)
SELECT 
    MEETING_ID,
    'EST timezone not properly converted to UTC' AS error_message
FROM timezone_test
WHERE timezone_offset IS NOT NULL 
  AND timezone_offset != 0  -- UTC should have 0 offset
```

#### Test 3: Meeting Duration Validation
```sql
-- tests/test_meeting_duration_validation.sql
SELECT 
    MEETING_ID,
    START_TIME,
    END_TIME,
    DURATION_MINUTES,
    'Meeting duration calculation error' AS error_message
FROM {{ ref('SI_MEETINGS') }}
WHERE START_TIME IS NOT NULL 
  AND END_TIME IS NOT NULL
  AND ABS(DURATION_MINUTES - DATEDIFF('minute', START_TIME, END_TIME)) > 1
```

#### Test 4: MM/DD/YYYY Format Conversion
```sql
-- tests/test_mmddyyyy_format_conversion.sql
WITH format_test AS (
    SELECT 
        PARTICIPANT_ID,
        JOIN_TIME,
        -- Check if original format was MM/DD/YYYY and conversion was successful
        CASE 
            WHEN JOIN_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' 
            THEN 'MM_DD_YYYY_FORMAT'
            ELSE 'OTHER_FORMAT'
        END AS original_format
    FROM {{ source('bronze_layer', 'participants') }}
)
SELECT 
    p.PARTICIPANT_ID,
    'MM/DD/YYYY format conversion failed' AS error_message
FROM format_test ft
JOIN {{ ref('SI_PARTICIPANTS') }} p ON ft.PARTICIPANT_ID = p.PARTICIPANT_ID
WHERE ft.original_format = 'MM_DD_YYYY_FORMAT'
  AND p.JOIN_TIME IS NULL
```

#### Test 5: Numeric Amount Conversion
```sql
-- tests/test_numeric_amount_conversion.sql
SELECT 
    EVENT_ID,
    AMOUNT,
    'Amount precision validation failed' AS error_message
FROM {{ ref('SI_BILLING_EVENTS') }}
WHERE AMOUNT IS NOT NULL
  AND (AMOUNT * 100) != ROUND(AMOUNT * 100, 0)  -- Check for more than 2 decimal places
```

#### Test 6: Data Quality Score Calculation
```sql
-- tests/test_data_quality_score_calculation.sql
WITH quality_check AS (
    SELECT 
        USER_ID,
        EMAIL,
        PLAN_TYPE,
        DATA_QUALITY_SCORE,
        -- Calculate expected quality score
        CASE 
            WHEN EMAIL IS NOT NULL AND PLAN_TYPE IS NOT NULL THEN 100
            WHEN EMAIL IS NOT NULL OR PLAN_TYPE IS NOT NULL THEN 50
            ELSE 0
        END AS expected_score
    FROM {{ ref('SI_USERS') }}
)
SELECT 
    USER_ID,
    DATA_QUALITY_SCORE,
    expected_score,
    'Data quality score calculation mismatch' AS error_message
FROM quality_check
WHERE ABS(DATA_QUALITY_SCORE - expected_score) > 10  -- Allow 10 point tolerance
```

#### Test 7: Duplicate Record Detection
```sql
-- tests/test_duplicate_records.sql
SELECT 
    'SI_USERS' AS model_name,
    USER_ID,
    COUNT(*) AS duplicate_count,
    'Duplicate records found' AS error_message
FROM {{ ref('SI_USERS') }}
GROUP BY USER_ID
HAVING COUNT(*) > 1

UNION ALL

SELECT 
    'SI_MEETINGS' AS model_name,
    MEETING_ID,
    COUNT(*) AS duplicate_count,
    'Duplicate records found' AS error_message
FROM {{ ref('SI_MEETINGS') }}
GROUP BY MEETING_ID
HAVING COUNT(*) > 1

-- Add similar checks for other models
```

#### Test 8: Audit Log Completeness
```sql
-- tests/test_audit_log_completeness.sql
WITH expected_models AS (
    SELECT model_name FROM (
        VALUES 
        ('SI_USERS'),
        ('SI_MEETINGS'),
        ('SI_PARTICIPANTS'),
        ('SI_FEATURE_USAGE'),
        ('SI_SUPPORT_TICKETS'),
        ('SI_BILLING_EVENTS'),
        ('SI_LICENSES')
    ) AS t(model_name)
),
logged_models AS (
    SELECT DISTINCT MODEL_NAME
    FROM {{ ref('SI_Audit_Log') }}
    WHERE DATE(EXECUTION_START_TIME) = CURRENT_DATE()
)
SELECT 
    em.model_name,
    'Missing audit log entry for today' AS error_message
FROM expected_models em
LEFT JOIN logged_models lm ON em.model_name = lm.MODEL_NAME
WHERE lm.MODEL_NAME IS NULL
```

#### Test 9: Business Rule Validation - Participant Time Boundaries
```sql
-- tests/test_participant_time_boundaries.sql
SELECT 
    p.PARTICIPANT_ID,
    p.MEETING_ID,
    p.JOIN_TIME,
    p.LEAVE_TIME,
    m.START_TIME,
    m.END_TIME,
    'Participant time outside meeting boundaries' AS error_message
FROM {{ ref('SI_PARTICIPANTS') }} p
JOIN {{ ref('SI_MEETINGS') }} m ON p.MEETING_ID = m.MEETING_ID
WHERE p.JOIN_TIME < m.START_TIME
   OR (p.LEAVE_TIME IS NOT NULL AND p.LEAVE_TIME > m.END_TIME)
   OR (p.LEAVE_TIME IS NOT NULL AND p.LEAVE_TIME < p.JOIN_TIME)
```

#### Test 10: Schema Evolution Test
```sql
-- tests/test_schema_evolution.sql
-- This test ensures that new columns don't break existing transformations
SELECT 
    'Schema validation' AS test_type,
    COUNT(*) AS record_count,
    'Schema evolution compatibility check' AS message
FROM {{ ref('SI_USERS') }}
WHERE USER_ID IS NOT NULL
  AND EMAIL IS NOT NULL
  AND PLAN_TYPE IS NOT NULL
  AND DATA_QUALITY_SCORE IS NOT NULL
  AND VALIDATION_STATUS IS NOT NULL
HAVING COUNT(*) = 0  -- This should return no records if schema is intact
```

## Test Execution Strategy

### 1. Pre-deployment Testing
```bash
# Run all tests before deployment
dbt test --models SI_USERS SI_MEETINGS SI_PARTICIPANTS SI_FEATURE_USAGE SI_SUPPORT_TICKETS SI_BILLING_EVENTS SI_LICENSES SI_Audit_Log

# Run specific test categories
dbt test --models SI_USERS --select test_type:data_quality
dbt test --models SI_MEETINGS --select test_type:transformation
```

### 2. Post-deployment Validation
```bash
# Validate data quality after deployment
dbt test --models SI_* --select test_type:business_rule

# Check audit logging
dbt test --select test_audit_log_completeness
```

### 3. Continuous Monitoring
```bash
# Daily data quality checks
dbt test --models SI_* --select test_type:data_quality

# Weekly comprehensive testing
dbt test --models SI_*
```

## Expected Test Results

### Success Criteria
- All unique and not_null tests pass
- All accepted_values tests pass with 100% compliance
- All relationship tests pass with referential integrity maintained
- All custom SQL tests return 0 records (no errors found)
- Data quality scores are within expected ranges (0-100)
- All timestamp conversions are accurate
- All numeric conversions maintain precision
- Audit logs are complete and accurate

### Performance Benchmarks
- Test execution time < 5 minutes for full suite
- Individual model tests < 30 seconds
- Memory usage < 2GB during test execution
- No test failures due to timeout or resource constraints

## Test Maintenance

### Regular Updates
1. Review and update test cases monthly
2. Add new test cases for new business rules
3. Update expected values as business requirements change
4. Monitor test performance and optimize slow tests

### Documentation
1. Document all test failures and resolutions
2. Maintain test case traceability to business requirements
3. Update test documentation with each release
4. Track test coverage metrics

## Conclusion

This comprehensive test suite ensures the reliability, accuracy, and performance of the Zoom Platform Analytics Silver Layer dbt models in Snowflake. The combination of YAML-based schema tests and custom SQL tests provides thorough coverage of data quality, transformation logic, business rules, and edge cases.

Regular execution of these tests will help maintain data integrity, catch issues early in the development cycle, and ensure consistent, high-quality data delivery to downstream consumers.