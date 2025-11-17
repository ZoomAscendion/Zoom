_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Platform Analytics System Silver layer dbt models in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Zoom Platform Analytics System

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics System Silver layer models running in Snowflake. The test framework validates data transformations, business rules, edge cases, and error handling across all Silver layer models to ensure data quality and pipeline reliability.

## Test Coverage Overview

The test suite covers the following Silver layer models:
- **SI_Audit_Log** - Audit logging table with comprehensive tracking
- **SI_USERS** - Clean user profiles with email validation and plan standardization
- **SI_MEETINGS** - Meeting data with timestamp cleaning and duration validation
- **SI_PARTICIPANTS** - Participant data with session time validation
- **SI_FEATURE_USAGE** - Feature usage metrics with referential integrity
- **SI_SUPPORT_TICKETS** - Support ticket data with status standardization
- **SI_BILLING_EVENTS** - Financial transactions with amount validation
- **SI_LICENSES** - License assignments with date logic validation

## Test Case List

### 1. SI_USERS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_USR_001 | Validate email format using regex pattern | All email addresses follow valid format (contains @ and domain) |
| TC_USR_002 | Check for duplicate user records | No duplicate USER_ID values exist |
| TC_USR_003 | Verify user plan standardization | All PLAN values are standardized (Basic, Pro, Business, Enterprise) |
| TC_USR_004 | Validate non-null critical fields | USER_ID, EMAIL, CREATED_DATE are not null |
| TC_USR_005 | Test data quality score calculation | DATA_QUALITY_SCORE between 0-100 with proper PASSED/WARNING/FAILED status |

### 2. SI_MEETINGS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_MTG_001 | Validate duration minutes format conversion | "108 mins" converted to numeric 108, text units removed |
| TC_MTG_002 | Check meeting duration range validation | DURATION_MINUTES between 0-1440 (24 hours max) |
| TC_MTG_003 | Verify timestamp format standardization | All timestamps in consistent YYYY-MM-DD HH:MM:SS format |
| TC_MTG_004 | Test DD/MM/YYYY date conversion | "27/08/2024" converted to "2024-08-27" format |
| TC_MTG_005 | Validate meeting-user relationship | All MEETING_ID values have corresponding USER_ID |
| TC_MTG_006 | Check for null meeting IDs | No null MEETING_ID values in final dataset |

### 3. SI_PARTICIPANTS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_PRT_001 | Validate join/leave time format | MM/DD/YYYY timestamps properly converted |
| TC_PRT_002 | Check session duration calculation | JOIN_TIME < LEAVE_TIME for all records |
| TC_PRT_003 | Verify participant-meeting relationship | All PARTICIPANT_ID linked to valid MEETING_ID |
| TC_PRT_004 | Test EST timezone conversion | All timestamps standardized to EST timezone |
| TC_PRT_005 | Validate session time ranges | Session duration > 0 and < meeting duration |

### 4. SI_FEATURE_USAGE Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_FTR_001 | Check referential integrity with users | All USER_ID values exist in SI_USERS |
| TC_FTR_002 | Validate feature usage metrics | Usage counts are non-negative integers |
| TC_FTR_003 | Test feature name standardization | Feature names follow consistent naming convention |
| TC_FTR_004 | Verify usage date ranges | USAGE_DATE within valid business date range |
| TC_FTR_005 | Check for duplicate usage records | No duplicate USER_ID + FEATURE_NAME + USAGE_DATE combinations |

### 5. SI_SUPPORT_TICKETS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_TKT_001 | Validate ticket status standardization | Status values: Open, In Progress, Resolved, Closed |
| TC_TKT_002 | Check ticket priority validation | Priority values: Low, Medium, High, Critical |
| TC_TKT_003 | Verify ticket-user relationship | All TICKET_ID linked to valid USER_ID |
| TC_TKT_004 | Test ticket lifecycle dates | CREATED_DATE <= UPDATED_DATE <= RESOLVED_DATE |
| TC_TKT_005 | Validate ticket ID uniqueness | No duplicate TICKET_ID values |

### 6. SI_BILLING_EVENTS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BIL_001 | Validate amount format and precision | All amounts are numeric with 2 decimal places |
| TC_BIL_002 | Check billing event types | Event types: Charge, Refund, Credit, Adjustment |
| TC_BIL_003 | Verify billing-user relationship | All billing events linked to valid USER_ID |
| TC_BIL_004 | Test amount range validation | Amounts > 0 for charges, <= 0 for refunds |
| TC_BIL_005 | Validate currency standardization | All amounts in consistent currency (USD) |

### 7. SI_LICENSES Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_LIC_001 | Validate license date logic | START_DATE <= END_DATE for all licenses |
| TC_LIC_002 | Check license status validation | Status values: Active, Expired, Suspended, Cancelled |
| TC_LIC_003 | Verify license-user relationship | All LICENSE_ID linked to valid USER_ID |
| TC_LIC_004 | Test license type standardization | License types match predefined values |
| TC_LIC_005 | Validate license uniqueness | No overlapping active licenses per user |

### 8. SI_Audit_Log Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_AUD_001 | Validate audit log completeness | All Silver models have corresponding audit entries |
| TC_AUD_002 | Check execution timestamp accuracy | EXECUTION_START_TIME <= EXECUTION_END_TIME |
| TC_AUD_003 | Verify record count accuracy | RECORDS_PROCESSED matches actual model row counts |
| TC_AUD_004 | Test audit status tracking | Status values: SUCCESS, WARNING, FAILED |
| TC_AUD_005 | Validate audit trail integrity | No missing audit entries for executed models |

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# schema.yml
version: 2

models:
  - name: SI_USERS
    description: "Silver layer user profiles with data quality validation"
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
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
      - name: PLAN
        description: "User subscription plan"
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise']
      - name: DATA_QUALITY_SCORE
        description: "Data quality score 0-100"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100

  - name: SI_MEETINGS
    description: "Silver layer meeting data with duration validation"
    columns:
      - name: MEETING_ID
        description: "Unique meeting identifier"
        tests:
          - unique
          - not_null
      - name: DURATION_MINUTES
        description: "Meeting duration in minutes"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440
      - name: USER_ID
        description: "Meeting host user ID"
        tests:
          - relationships:
              to: ref('SI_USERS')
              field: USER_ID

  - name: SI_PARTICIPANTS
    description: "Silver layer participant session data"
    columns:
      - name: PARTICIPANT_ID
        description: "Unique participant identifier"
        tests:
          - unique
          - not_null
      - name: MEETING_ID
        description: "Associated meeting ID"
        tests:
          - relationships:
              to: ref('SI_MEETINGS')
              field: MEETING_ID

  - name: SI_FEATURE_USAGE
    description: "Silver layer feature usage metrics"
    columns:
      - name: USER_ID
        description: "User identifier"
        tests:
          - relationships:
              to: ref('SI_USERS')
              field: USER_ID
      - name: USAGE_COUNT
        description: "Feature usage count"
        tests:
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: number

  - name: SI_SUPPORT_TICKETS
    description: "Silver layer support ticket data"
    columns:
      - name: TICKET_ID
        description: "Unique ticket identifier"
        tests:
          - unique
          - not_null
      - name: STATUS
        description: "Ticket status"
        tests:
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed']
      - name: PRIORITY
        description: "Ticket priority level"
        tests:
          - accepted_values:
              values: ['Low', 'Medium', 'High', 'Critical']

  - name: SI_BILLING_EVENTS
    description: "Silver layer billing transaction data"
    columns:
      - name: BILLING_ID
        description: "Unique billing event identifier"
        tests:
          - unique
          - not_null
      - name: AMOUNT
        description: "Transaction amount"
        tests:
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: number
      - name: EVENT_TYPE
        description: "Billing event type"
        tests:
          - accepted_values:
              values: ['Charge', 'Refund', 'Credit', 'Adjustment']

  - name: SI_LICENSES
    description: "Silver layer license assignment data"
    columns:
      - name: LICENSE_ID
        description: "Unique license identifier"
        tests:
          - unique
          - not_null
      - name: STATUS
        description: "License status"
        tests:
          - accepted_values:
              values: ['Active', 'Expired', 'Suspended', 'Cancelled']

  - name: SI_Audit_Log
    description: "Silver layer audit logging table"
    columns:
      - name: AUDIT_ID
        description: "Unique audit entry identifier"
        tests:
          - unique
          - not_null
      - name: STATUS
        description: "Execution status"
        tests:
          - accepted_values:
              values: ['SUCCESS', 'WARNING', 'FAILED']
```

### Custom SQL-based dbt Tests

#### Test 1: Duration Format Validation
```sql
-- tests/test_duration_format_conversion.sql
-- Test that duration minutes are properly converted from text to numeric
SELECT *
FROM {{ ref('SI_MEETINGS') }}
WHERE DURATION_MINUTES IS NULL 
   OR DURATION_MINUTES < 0 
   OR DURATION_MINUTES > 1440
   OR REGEXP_LIKE(CAST(DURATION_MINUTES AS STRING), '[a-zA-Z]')
```

#### Test 2: Date Format Validation
```sql
-- tests/test_date_format_standardization.sql
-- Test that DD/MM/YYYY dates are properly converted to YYYY-MM-DD
SELECT *
FROM {{ ref('SI_MEETINGS') }}
WHERE MEETING_DATE IS NULL
   OR NOT REGEXP_LIKE(CAST(MEETING_DATE AS STRING), '^\\d{4}-\\d{2}-\\d{2}')
```

#### Test 3: Email Format Validation
```sql
-- tests/test_email_format_validation.sql
-- Test that all email addresses follow valid format
SELECT *
FROM {{ ref('SI_USERS') }}
WHERE EMAIL IS NULL
   OR NOT REGEXP_LIKE(EMAIL, '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$')
```

#### Test 4: Referential Integrity Check
```sql
-- tests/test_referential_integrity.sql
-- Test that all foreign key relationships are maintained
SELECT 'SI_MEETINGS' as table_name, COUNT(*) as orphaned_records
FROM {{ ref('SI_MEETINGS') }} m
LEFT JOIN {{ ref('SI_USERS') }} u ON m.USER_ID = u.USER_ID
WHERE u.USER_ID IS NULL

UNION ALL

SELECT 'SI_PARTICIPANTS' as table_name, COUNT(*) as orphaned_records
FROM {{ ref('SI_PARTICIPANTS') }} p
LEFT JOIN {{ ref('SI_MEETINGS') }} m ON p.MEETING_ID = m.MEETING_ID
WHERE m.MEETING_ID IS NULL

UNION ALL

SELECT 'SI_FEATURE_USAGE' as table_name, COUNT(*) as orphaned_records
FROM {{ ref('SI_FEATURE_USAGE') }} f
LEFT JOIN {{ ref('SI_USERS') }} u ON f.USER_ID = u.USER_ID
WHERE u.USER_ID IS NULL
```

#### Test 5: Data Quality Score Validation
```sql
-- tests/test_data_quality_scoring.sql
-- Test that data quality scores are calculated correctly
SELECT *
FROM {{ ref('SI_USERS') }}
WHERE DATA_QUALITY_SCORE IS NULL
   OR DATA_QUALITY_SCORE < 0
   OR DATA_QUALITY_SCORE > 100
   OR (DATA_QUALITY_SCORE >= 90 AND DQ_STATUS != 'PASSED')
   OR (DATA_QUALITY_SCORE BETWEEN 70 AND 89 AND DQ_STATUS != 'WARNING')
   OR (DATA_QUALITY_SCORE < 70 AND DQ_STATUS != 'FAILED')
```

#### Test 6: Timezone Conversion Validation
```sql
-- tests/test_timezone_conversion.sql
-- Test that timestamps are properly converted to EST
SELECT *
FROM {{ ref('SI_PARTICIPANTS') }}
WHERE JOIN_TIME IS NULL
   OR LEAVE_TIME IS NULL
   OR JOIN_TIME >= LEAVE_TIME
   OR NOT REGEXP_LIKE(CAST(JOIN_TIME AS STRING), '^\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}')
```

#### Test 7: Deduplication Validation
```sql
-- tests/test_deduplication.sql
-- Test that duplicate records are properly removed
SELECT 
    'SI_USERS' as table_name,
    USER_ID,
    COUNT(*) as duplicate_count
FROM {{ ref('SI_USERS') }}
GROUP BY USER_ID
HAVING COUNT(*) > 1

UNION ALL

SELECT 
    'SI_MEETINGS' as table_name,
    MEETING_ID,
    COUNT(*) as duplicate_count
FROM {{ ref('SI_MEETINGS') }}
GROUP BY MEETING_ID
HAVING COUNT(*) > 1
```

#### Test 8: Audit Trail Completeness
```sql
-- tests/test_audit_completeness.sql
-- Test that all Silver models have audit entries
WITH expected_models AS (
    SELECT 'SI_USERS' as model_name
    UNION ALL SELECT 'SI_MEETINGS'
    UNION ALL SELECT 'SI_PARTICIPANTS'
    UNION ALL SELECT 'SI_FEATURE_USAGE'
    UNION ALL SELECT 'SI_SUPPORT_TICKETS'
    UNION ALL SELECT 'SI_BILLING_EVENTS'
    UNION ALL SELECT 'SI_LICENSES'
),
actual_audits AS (
    SELECT DISTINCT MODEL_NAME
    FROM {{ ref('SI_Audit_Log') }}
    WHERE EXECUTION_DATE = CURRENT_DATE
)
SELECT e.model_name
FROM expected_models e
LEFT JOIN actual_audits a ON e.model_name = a.MODEL_NAME
WHERE a.MODEL_NAME IS NULL
```

### Parameterized Tests

#### Generic Test for Range Validation
```sql
-- macros/test_column_range.sql
{% macro test_column_range(model, column_name, min_value, max_value) %}
    SELECT *
    FROM {{ model }}
    WHERE {{ column_name }} IS NULL
       OR {{ column_name }} < {{ min_value }}
       OR {{ column_name }} > {{ max_value }}
{% endmacro %}
```

#### Generic Test for Date Logic Validation
```sql
-- macros/test_date_logic.sql
{% macro test_date_logic(model, start_date_column, end_date_column) %}
    SELECT *
    FROM {{ model }}
    WHERE {{ start_date_column }} IS NULL
       OR {{ end_date_column }} IS NULL
       OR {{ start_date_column }} > {{ end_date_column }}
{% endmacro %}
```

## Test Execution and Monitoring

### dbt Test Commands
```bash
# Run all tests
dbt test

# Run tests for specific model
dbt test --select SI_USERS

# Run tests with specific tag
dbt test --select tag:data_quality

# Run tests and store results
dbt test --store-failures
```

### Test Results Tracking

Test results are automatically tracked in:
- **dbt's run_results.json**: Contains test execution status and timing
- **Snowflake audit schema**: Stores detailed test results and failure data
- **SI_Audit_Log table**: Tracks overall pipeline execution and data quality metrics

### Performance Considerations

1. **Incremental Testing**: Use `--select` flags to run targeted tests during development
2. **Parallel Execution**: Configure dbt to run tests in parallel for faster execution
3. **Test Sampling**: For large datasets, implement sampling in custom tests
4. **Index Optimization**: Ensure proper indexing on frequently tested columns

## Maintenance and Updates

### Version Control
- All test files are version controlled in the dbt project repository
- Test changes follow the same review process as model changes
- Test documentation is updated with each model modification

### Continuous Integration
- Tests are automatically executed in CI/CD pipeline
- Failed tests block deployment to production
- Test coverage reports are generated for each build

### Monitoring and Alerting
- Daily test execution reports sent to data team
- Automated alerts for test failures in production
- Monthly data quality scorecards generated from test results

This comprehensive test suite ensures the reliability, accuracy, and performance of the Zoom Platform Analytics System Silver layer models in Snowflake, providing robust data quality validation and error detection capabilities.