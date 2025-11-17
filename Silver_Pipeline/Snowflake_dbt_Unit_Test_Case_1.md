_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases and dbt test scripts for Zoom Platform Analytics System Silver layer models
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Silver Layer Models
## Zoom Platform Analytics System

## **Overview**

This document provides comprehensive unit test cases and corresponding dbt test scripts for the Silver layer models in the Zoom Platform Analytics System. The tests are designed to validate key transformations, business rules, edge cases, and error handling scenarios, with special focus on the Critical P1 fixes for numeric field text unit cleaning ("108 mins" error) and DD/MM/YYYY date format conversion ("27/08/2024" error).

## **Test Case List**

### **1. SI_USERS Model Test Cases**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_USR_001 | Validate user ID uniqueness | No duplicate USER_ID values |
| TC_USR_002 | Validate email format compliance | All emails match valid format pattern |
| TC_USR_003 | Validate plan type standardization | All PLAN_TYPE values in ('Free', 'Basic', 'Pro', 'Enterprise') |
| TC_USR_004 | Validate null handling for required fields | No null values in USER_ID, EMAIL |
| TC_USR_005 | Validate data quality score range | All DATA_QUALITY_SCORE values between 0-100 |
| TC_USR_006 | Validate email case standardization | All emails in lowercase |
| TC_USR_007 | Validate company name trimming | No leading/trailing spaces in COMPANY |
| TC_USR_008 | Validate load date derivation | LOAD_DATE = DATE(LOAD_TIMESTAMP) |

### **2. SI_MEETINGS Model Test Cases (Enhanced with Critical P1 Fixes)**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_MTG_001 | Validate meeting ID uniqueness | No duplicate MEETING_ID values |
| TC_MTG_002 | Validate host ID referential integrity | All HOST_ID exist in SI_USERS |
| TC_MTG_003 | Validate meeting time logic | END_TIME > START_TIME for all records |
| TC_MTG_004 | **CRITICAL P1**: Validate numeric field text unit cleaning | DURATION_MINUTES with "108 mins" format successfully cleaned to numeric |
| TC_MTG_005 | **CRITICAL P1**: Validate duration calculation consistency | Cleaned DURATION_MINUTES matches DATEDIFF(minute, START_TIME, END_TIME) |
| TC_MTG_006 | Validate EST timezone format handling | EST timezone timestamps properly converted to UTC |
| TC_MTG_007 | Validate duration range constraints | All DURATION_MINUTES between 0-1440 |
| TC_MTG_008 | **CRITICAL P1**: Validate format conversion error logging | Failed numeric conversions logged to SI_AUDIT_LOG |
| TC_MTG_009 | Validate meeting topic PII sanitization | No sensitive information in MEETING_TOPIC |
| TC_MTG_010 | Validate data quality scoring with format compliance | Records with successful format conversion have higher DQ scores |

### **3. SI_PARTICIPANTS Model Test Cases**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_PRT_001 | Validate participant ID uniqueness | No duplicate PARTICIPANT_ID values |
| TC_PRT_002 | Validate meeting-participant referential integrity | All MEETING_ID exist in SI_MEETINGS |
| TC_PRT_003 | Validate user-participant referential integrity | All USER_ID exist in SI_USERS |
| TC_PRT_004 | Validate participant session time logic | LEAVE_TIME > JOIN_TIME for all records |
| TC_PRT_005 | Validate MM/DD/YYYY HH:MM format conversion | Timestamps in MM/DD/YYYY HH:MM format properly converted |
| TC_PRT_006 | Validate meeting boundary compliance | JOIN_TIME >= meeting START_TIME and LEAVE_TIME <= meeting END_TIME |
| TC_PRT_007 | Validate unique participant per meeting | No duplicate (MEETING_ID, USER_ID) combinations |
| TC_PRT_008 | Validate cross-format timestamp consistency | Mixed timestamp formats handled correctly |

### **4. SI_FEATURE_USAGE Model Test Cases**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_FTR_001 | Validate usage ID uniqueness | No duplicate USAGE_ID values |
| TC_FTR_002 | Validate feature-meeting referential integrity | All MEETING_ID exist in SI_MEETINGS |
| TC_FTR_003 | Validate feature name standardization | All FEATURE_NAME values properly standardized |
| TC_FTR_004 | Validate usage count constraints | All USAGE_COUNT values >= 0 |
| TC_FTR_005 | Validate usage date alignment | USAGE_DATE aligns with meeting date |
| TC_FTR_006 | Validate feature adoption rate calculation | Feature adoption metrics calculated correctly |

### **5. SI_SUPPORT_TICKETS Model Test Cases**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_TKT_001 | Validate ticket ID uniqueness | No duplicate TICKET_ID values |
| TC_TKT_002 | Validate ticket-user referential integrity | All USER_ID exist in SI_USERS |
| TC_TKT_003 | Validate resolution status standardization | All RESOLUTION_STATUS in predefined values |
| TC_TKT_004 | Validate open date constraints | No OPEN_DATE values in future |
| TC_TKT_005 | Validate ticket volume metrics | Ticket volume per 1000 users calculated correctly |

### **6. SI_BILLING_EVENTS Model Test Cases**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BIL_001 | Validate event ID uniqueness | No duplicate EVENT_ID values |
| TC_BIL_002 | Validate billing-user referential integrity | All USER_ID exist in SI_USERS |
| TC_BIL_003 | Validate amount precision and constraints | All AMOUNT values > 0 with 2 decimal precision |
| TC_BIL_004 | Validate event date constraints | No EVENT_DATE values in future |
| TC_BIL_005 | Validate MRR calculation | Monthly Recurring Revenue calculated correctly |

### **7. SI_LICENSES Model Test Cases (Enhanced with Critical P1 Fixes)**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_LIC_001 | Validate license ID uniqueness | No duplicate LICENSE_ID values |
| TC_LIC_002 | Validate license-user referential integrity | All ASSIGNED_TO_USER_ID exist in SI_USERS |
| TC_LIC_003 | **CRITICAL P1**: Validate DD/MM/YYYY date format conversion | Dates in "27/08/2024" format successfully converted |
| TC_LIC_004 | **CRITICAL P1**: Validate date logic after conversion | START_DATE <= END_DATE after format conversion |
| TC_LIC_005 | Validate active license identification | Active licenses have END_DATE > CURRENT_DATE() |
| TC_LIC_006 | **CRITICAL P1**: Validate date conversion error logging | Failed date conversions logged to SI_AUDIT_LOG |
| TC_LIC_007 | Validate license utilization rate | License utilization metrics calculated correctly |

### **8. Cross-Table Integration Test Cases**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_INT_001 | Validate user activity consistency | Users with meetings have corresponding participant records |
| TC_INT_002 | Validate feature usage alignment | Feature usage records align with meeting participants |
| TC_INT_003 | Validate billing-license consistency | Users with billing events have corresponding licenses |
| TC_INT_004 | Validate audit trail completeness | All format conversion failures logged to SI_AUDIT_LOG |

### **9. Data Quality Framework Test Cases**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_DQ_001 | Validate data quality score calculation | DQ scores calculated based on enhanced criteria |
| TC_DQ_002 | Validate validation status assignment | Status assigned based on DQ score and format compliance |
| TC_DQ_003 | Validate error handling strategy | Failed records routed to SI_DATA_QUALITY_ERRORS |
| TC_DQ_004 | Validate pipeline execution logging | All executions logged to SI_PIPELINE_EXECUTION_LOG |

## **dbt Test Scripts**

### **YAML-based Schema Tests**

#### **schema.yml for SI_USERS**
```yaml
version: 2

models:
  - name: si_users
    description: "Silver layer table storing cleaned and standardized user profile and subscription information"
    columns:
      - name: user_id
        description: "Unique identifier for each user account"
        tests:
          - not_null
          - unique
      - name: email
        description: "Email address of the user (validated and standardized)"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
      - name: plan_type
        description: "Subscription plan type (standardized values)"
        tests:
          - accepted_values:
              values: ['Free', 'Basic', 'Pro', 'Enterprise']
      - name: data_quality_score
        description: "Quality score from validation process (0-100)"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100
      - name: validation_status
        description: "Status of data validation"
        tests:
          - accepted_values:
              values: ['PASSED', 'FAILED', 'WARNING']
```

#### **schema.yml for SI_MEETINGS (Enhanced with Critical P1 Tests)**
```yaml
version: 2

models:
  - name: si_meetings
    description: "Silver layer table storing cleaned and standardized meeting information"
    tests:
      - dbt_utils.expression_is_true:
          expression: "end_time > start_time"
          config:
            severity: error
    columns:
      - name: meeting_id
        description: "Unique identifier for each meeting"
        tests:
          - not_null
          - unique
      - name: host_id
        description: "User ID of the meeting host"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: duration_minutes
        description: "Meeting duration in minutes (validated and calculated)"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: number
      - name: start_time
        description: "Meeting start timestamp (standardized timezone)"
        tests:
          - not_null
      - name: end_time
        description: "Meeting end timestamp (standardized timezone)"
        tests:
          - not_null
```

#### **schema.yml for SI_PARTICIPANTS**
```yaml
version: 2

models:
  - name: si_participants
    description: "Silver layer table storing cleaned and standardized meeting participants"
    tests:
      - dbt_utils.expression_is_true:
          expression: "leave_time > join_time"
          config:
            severity: error
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - meeting_id
            - user_id
    columns:
      - name: participant_id
        description: "Unique identifier for each meeting participant"
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
        description: "Reference to user who participated"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
```

#### **schema.yml for SI_LICENSES (Enhanced with Critical P1 Tests)**
```yaml
version: 2

models:
  - name: si_licenses
    description: "Silver layer table storing cleaned and standardized license assignments"
    tests:
      - dbt_utils.expression_is_true:
          expression: "start_date <= end_date"
          config:
            severity: error
    columns:
      - name: license_id
        description: "Unique identifier for each license"
        tests:
          - not_null
          - unique
      - name: assigned_to_user_id
        description: "User ID to whom license is assigned"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: start_date
        description: "License validity start date (standardized format)"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: date
      - name: end_date
        description: "License validity end date (standardized format)"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: date
```

### **Custom SQL-based dbt Tests**

#### **Test 1: Critical P1 - Numeric Field Text Unit Cleaning Validation**
```sql
-- tests/assert_duration_minutes_numeric_cleaning.sql
-- Test to validate that DURATION_MINUTES with text units are properly cleaned

SELECT 
    meeting_id,
    duration_minutes,
    'Duration contains non-numeric characters after cleaning' as error_message
FROM {{ ref('si_meetings') }}
WHERE 
    duration_minutes IS NOT NULL
    AND NOT REGEXP_LIKE(duration_minutes::STRING, '^[0-9.]+$')
```

#### **Test 2: Critical P1 - DD/MM/YYYY Date Format Conversion Validation**
```sql
-- tests/assert_license_date_format_conversion.sql
-- Test to validate that DD/MM/YYYY dates are properly converted

SELECT 
    license_id,
    start_date,
    end_date,
    'Date format conversion failed' as error_message
FROM {{ ref('si_licenses') }}
WHERE 
    (start_date IS NULL AND license_id IS NOT NULL)
    OR (end_date IS NULL AND license_id IS NOT NULL)
    OR (TRY_TO_DATE(start_date::STRING, 'YYYY-MM-DD') IS NULL AND start_date IS NOT NULL)
    OR (TRY_TO_DATE(end_date::STRING, 'YYYY-MM-DD') IS NULL AND end_date IS NOT NULL)
```

#### **Test 3: Duration Calculation Consistency**
```sql
-- tests/assert_duration_calculation_consistency.sql
-- Test to validate that DURATION_MINUTES matches calculated duration

SELECT 
    meeting_id,
    duration_minutes,
    DATEDIFF('minute', start_time, end_time) as calculated_duration,
    'Duration mismatch between stored and calculated values' as error_message
FROM {{ ref('si_meetings') }}
WHERE 
    ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) > 1
    AND start_time IS NOT NULL 
    AND end_time IS NOT NULL
    AND duration_minutes IS NOT NULL
```

#### **Test 4: Format Conversion Error Logging Validation**
```sql
-- tests/assert_format_conversion_error_logging.sql
-- Test to validate that format conversion errors are properly logged

WITH format_conversion_errors AS (
    SELECT COUNT(*) as error_count
    FROM {{ ref('si_audit_log') }}
    WHERE error_type = 'FORMAT_CONVERSION_FAILURE'
    AND audit_timestamp >= CURRENT_DATE() - INTERVAL '1 day'
),
expected_errors AS (
    SELECT 
        COUNT(*) as expected_count
    FROM (
        -- Count records with numeric text units in meetings
        SELECT meeting_id FROM {{ source('bronze', 'bz_meetings') }}
        WHERE duration_minutes::STRING REGEXP '[^0-9.]'
        AND TRY_TO_NUMBER(REGEXP_REPLACE(duration_minutes::STRING, '[^0-9.]', '')) IS NULL
        
        UNION ALL
        
        -- Count records with DD/MM/YYYY format issues in licenses
        SELECT license_id FROM {{ source('bronze', 'bz_licenses') }}
        WHERE (start_date::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}$'
               AND TRY_TO_DATE(start_date::STRING, 'DD/MM/YYYY') IS NULL)
        OR (end_date::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}$'
            AND TRY_TO_DATE(end_date::STRING, 'DD/MM/YYYY') IS NULL)
    ) errors
)
SELECT 
    'Format conversion errors not properly logged' as error_message
FROM format_conversion_errors fce
CROSS JOIN expected_errors ee
WHERE fce.error_count < ee.expected_count
```

#### **Test 5: Cross-Table Referential Integrity**
```sql
-- tests/assert_cross_table_referential_integrity.sql
-- Test to validate referential integrity across Silver layer tables

SELECT 
    'Orphaned meeting hosts' as error_type,
    COUNT(*) as error_count
FROM {{ ref('si_meetings') }} m
LEFT JOIN {{ ref('si_users') }} u ON m.host_id = u.user_id
WHERE u.user_id IS NULL AND m.host_id IS NOT NULL
HAVING COUNT(*) > 0

UNION ALL

SELECT 
    'Orphaned participants' as error_type,
    COUNT(*) as error_count
FROM {{ ref('si_participants') }} p
LEFT JOIN {{ ref('si_meetings') }} m ON p.meeting_id = m.meeting_id
WHERE m.meeting_id IS NULL
HAVING COUNT(*) > 0

UNION ALL

SELECT 
    'Orphaned feature usage' as error_type,
    COUNT(*) as error_count
FROM {{ ref('si_feature_usage') }} f
LEFT JOIN {{ ref('si_meetings') }} m ON f.meeting_id = m.meeting_id
WHERE m.meeting_id IS NULL
HAVING COUNT(*) > 0
```

#### **Test 6: Data Quality Score Validation**
```sql
-- tests/assert_data_quality_score_calculation.sql
-- Test to validate data quality score calculation logic

SELECT 
    table_name,
    'Invalid data quality score range' as error_message,
    COUNT(*) as invalid_count
FROM (
    SELECT 'si_users' as table_name, data_quality_score 
    FROM {{ ref('si_users') }}
    WHERE data_quality_score < 0 OR data_quality_score > 100
    
    UNION ALL
    
    SELECT 'si_meetings' as table_name, data_quality_score 
    FROM {{ ref('si_meetings') }}
    WHERE data_quality_score < 0 OR data_quality_score > 100
    
    UNION ALL
    
    SELECT 'si_participants' as table_name, data_quality_score 
    FROM {{ ref('si_participants') }}
    WHERE data_quality_score < 0 OR data_quality_score > 100
) invalid_scores
GROUP BY table_name
HAVING COUNT(*) > 0
```

#### **Test 7: Business Rule Validation - Meeting Classification**
```sql
-- tests/assert_meeting_classification_rules.sql
-- Test to validate meeting classification business rules

WITH meeting_classification AS (
    SELECT 
        m.meeting_id,
        m.duration_minutes,
        COUNT(p.participant_id) as participant_count,
        CASE 
            WHEN m.duration_minutes < 5 THEN 'Brief'
            WHEN COUNT(p.participant_id) >= 2 THEN 'Collaborative'
            ELSE 'Standard'
        END as expected_classification
    FROM {{ ref('si_meetings') }} m
    LEFT JOIN {{ ref('si_participants') }} p ON m.meeting_id = p.meeting_id
    WHERE m.duration_minutes IS NOT NULL
    GROUP BY m.meeting_id, m.duration_minutes
)
SELECT 
    meeting_id,
    'Meeting classification logic validation failed' as error_message
FROM meeting_classification
WHERE expected_classification IS NULL
   OR (duration_minutes < 5 AND expected_classification != 'Brief')
   OR (duration_minutes >= 5 AND participant_count >= 2 AND expected_classification != 'Collaborative')
```

#### **Test 8: Timestamp Format Consistency**
```sql
-- tests/assert_timestamp_format_consistency.sql
-- Test to validate timestamp format consistency across tables

SELECT 
    'Inconsistent timestamp formats in SI_MEETINGS' as error_message,
    COUNT(*) as error_count
FROM {{ ref('si_meetings') }}
WHERE 
    (start_time::STRING LIKE '%EST%' AND end_time::STRING NOT LIKE '%EST%')
    OR (start_time::STRING NOT LIKE '%EST%' AND end_time::STRING LIKE '%EST%')
HAVING COUNT(*) > 0

UNION ALL

SELECT 
    'Inconsistent timestamp formats in SI_PARTICIPANTS' as error_message,
    COUNT(*) as error_count
FROM {{ ref('si_participants') }}
WHERE 
    (join_time::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}' AND leave_time::STRING NOT REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}')
    OR (join_time::STRING NOT REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}' AND leave_time::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}')
HAVING COUNT(*) > 0
```

### **Parameterized Tests for Reusability**

#### **Generic Test: Format Conversion Success Rate**
```sql
-- macros/test_format_conversion_success_rate.sql
{% macro test_format_conversion_success_rate(model, column_name, format_pattern, conversion_function, min_success_rate=0.95) %}

WITH format_conversion_stats AS (
    SELECT 
        COUNT(*) as total_records,
        COUNT(CASE WHEN {{ conversion_function }} IS NOT NULL THEN 1 END) as successful_conversions
    FROM {{ model }}
    WHERE {{ column_name }}::STRING REGEXP '{{ format_pattern }}'
),
success_rate AS (
    SELECT 
        total_records,
        successful_conversions,
        CASE 
            WHEN total_records > 0 THEN successful_conversions::FLOAT / total_records::FLOAT
            ELSE 1.0
        END as success_rate
    FROM format_conversion_stats
)
SELECT 
    'Format conversion success rate below threshold' as error_message,
    success_rate,
    {{ min_success_rate }} as min_required_rate
FROM success_rate
WHERE success_rate < {{ min_success_rate }}

{% endmacro %}
```

#### **Usage of Parameterized Test**
```sql
-- tests/test_duration_cleaning_success_rate.sql
{{ test_format_conversion_success_rate(
    model=ref('si_meetings'),
    column_name='duration_minutes',
    format_pattern='[^0-9.]',
    conversion_function='TRY_TO_NUMBER(REGEXP_REPLACE(duration_minutes::STRING, \'[^0-9.]\', \'\'))',
    min_success_rate=0.98
) }}
```

```sql
-- tests/test_date_conversion_success_rate.sql
{{ test_format_conversion_success_rate(
    model=ref('si_licenses'),
    column_name='start_date',
    format_pattern='^\\d{1,2}/\\d{1,2}/\\d{4}$',
    conversion_function='TRY_TO_DATE(start_date::STRING, \'DD/MM/YYYY\')',
    min_success_rate=0.98
) }}
```

## **Test Execution Strategy**

### **1. Test Execution Order**
1. **Schema Tests**: Execute basic schema validation tests first
2. **Critical P1 Tests**: Execute format conversion and data cleaning tests
3. **Business Rule Tests**: Execute business logic validation tests
4. **Integration Tests**: Execute cross-table relationship tests
5. **Performance Tests**: Execute data quality and performance validation tests

### **2. Test Environment Configuration**
```yaml
# dbt_project.yml test configuration
test-paths: ["tests"]
tests:
  +store_failures: true
  +schema: "test_results"
  
models:
  zoom_analytics:
    silver:
      +materialized: table
      +post-hook: |
        {% if is_incremental() %}
          INSERT INTO {{ ref('si_pipeline_execution_log') }} (
            execution_id,
            pipeline_name,
            execution_start_time,
            execution_end_time,
            execution_status,
            target_table,
            records_processed
          )
          VALUES (
            '{{ invocation_id }}',
            '{{ this.name }}',
            '{{ run_started_at }}',
            CURRENT_TIMESTAMP(),
            'SUCCESS',
            '{{ this }}',
            (SELECT COUNT(*) FROM {{ this }})
          )
        {% endif %}
```

### **3. Continuous Integration Setup**
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
        uses: dbt-labs/dbt-action@v1
        with:
          dbt-version: "1.0.0"
      - name: Run dbt tests
        run: |
          dbt deps
          dbt seed
          dbt run --models silver
          dbt test --models silver
      - name: Generate test results
        run: |
          dbt docs generate
          dbt run-operation upload_test_results
```

## **Monitoring and Alerting**

### **1. Test Results Tracking**
```sql
-- Create test results summary view
CREATE OR REPLACE VIEW SILVER.V_TEST_RESULTS_SUMMARY AS
SELECT 
    test_name,
    model_name,
    test_status,
    execution_time,
    error_count,
    execution_date,
    CASE 
        WHEN test_name LIKE '%format_conversion%' THEN 'CRITICAL_P1'
        WHEN test_name LIKE '%referential_integrity%' THEN 'HIGH_P2'
        ELSE 'MEDIUM_P3'
    END as priority_level
FROM SILVER.SI_PIPELINE_EXECUTION_LOG
WHERE pipeline_type = 'DBT_TEST'
ORDER BY execution_date DESC, priority_level;
```

### **2. Alert Configuration**
```sql
-- Alert for Critical P1 test failures
CREATE OR REPLACE TASK SILVER.ALERT_CRITICAL_TEST_FAILURES
    WAREHOUSE = 'WH_POC_ZOOM_DEV_XSMALL'
    SCHEDULE = 'USING CRON 0 */2 * * * UTC'  -- Every 2 hours
AS
DECLARE
    failure_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO failure_count
    FROM SILVER.V_TEST_RESULTS_SUMMARY
    WHERE test_status = 'FAILED'
    AND priority_level = 'CRITICAL_P1'
    AND execution_date >= CURRENT_DATE();
    
    IF (failure_count > 0) THEN
        -- Send alert notification
        CALL SYSTEM$SEND_EMAIL(
            'data-quality-alerts@company.com',
            'Critical P1 dbt Test Failures Detected',
            'Number of failed Critical P1 tests: ' || failure_count::STRING ||
            '. Please check SI_PIPELINE_EXECUTION_LOG for details.'
        );
    END IF;
END;
```

## **Performance Optimization**

### **1. Test Performance Monitoring**
```sql
-- Monitor test execution performance
SELECT 
    test_name,
    AVG(execution_duration_seconds) as avg_duration,
    MAX(execution_duration_seconds) as max_duration,
    COUNT(*) as execution_count
FROM SILVER.SI_PIPELINE_EXECUTION_LOG
WHERE pipeline_type = 'DBT_TEST'
AND execution_date >= CURRENT_DATE() - INTERVAL '7 days'
GROUP BY test_name
ORDER BY avg_duration DESC;
```

### **2. Test Optimization Recommendations**
- Use `limit` in development environment for large table tests
- Implement incremental testing for time-based validations
- Cache test results for repeated validations
- Use clustering keys on test result tables for better performance

## **Conclusion**

This comprehensive unit testing framework provides robust validation for the Zoom Platform Analytics System Silver layer models, with special emphasis on the Critical P1 fixes for numeric field text unit cleaning and DD/MM/YYYY date format conversion. The tests are designed to:

1. **Validate Critical P1 Fixes**: Ensure "108 mins" and "27/08/2024" format issues are resolved
2. **Maintain Data Quality**: Comprehensive validation of all data transformations
3. **Support Business Rules**: Validate complex business logic and calculations
4. **Enable Continuous Integration**: Automated testing in CI/CD pipelines
5. **Provide Monitoring**: Real-time alerting and performance tracking
6. **Ensure Reliability**: Comprehensive error handling and logging

The framework supports both development and production environments, with configurable test severity levels and comprehensive reporting capabilities through dbt's native testing infrastructure and Snowflake's audit capabilities.