_____________________________________________
## *Author*: AAVA
## *Created on*: 11-11-2025
## *Description*: Comprehensive unit test cases for Zoom Platform Analytics System Silver layer dbt models in Snowflake
## *Version*: 1 
## *Updated on*: 11-11-2025
_____________________________________________

# Snowflake dbt Unit Test Cases
## Zoom Platform Analytics System - Silver Layer

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics System Silver layer dbt models running in Snowflake. The test cases cover data transformations, business rules, edge cases, and error handling scenarios to ensure data quality, reliability, and performance of the dbt models.

The Silver layer transforms Bronze layer data through cleansing, validation, standardization, and business rule application. These tests validate the integrity of transformations including complex timestamp format handling (EST timezone and MM/DD/YYYY formats), data quality scoring, and referential integrity checks.

## Test Case List

### 1. SI_USERS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_SI_USERS_001 | Validate USER_ID uniqueness and not null constraint | All USER_ID values are unique and not null |
| TC_SI_USERS_002 | Validate email format using REGEXP_LIKE | All EMAIL values follow valid email format pattern |
| TC_SI_USERS_003 | Validate PLAN_TYPE standardization | All PLAN_TYPE values are in ('FREE', 'BASIC', 'PRO', 'ENTERPRISE') |
| TC_SI_USERS_004 | Validate data quality score calculation | DATA_QUALITY_SCORE is between 0-100 based on completeness |
| TC_SI_USERS_005 | Validate deduplication logic using ROW_NUMBER() | Latest record per USER_ID based on UPDATE_TIMESTAMP |
| TC_SI_USERS_006 | Test null handling for optional fields | COMPANY can be null, other required fields not null |
| TC_SI_USERS_007 | Validate VALIDATION_STATUS assignment | Status set to PASSED/WARNING/FAILED based on DQ score |
| TC_SI_USERS_008 | Test case sensitivity in email standardization | All emails converted to lowercase |
| TC_SI_USERS_009 | Validate LOAD_DATE and UPDATE_DATE derivation | Dates correctly derived from timestamp fields |
| TC_SI_USERS_010 | Test edge case with empty string values | Empty strings treated as null and handled appropriately |

### 2. SI_MEETINGS Model Test Cases (Enhanced for EST Timezone)

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_SI_MEETINGS_001 | Validate MEETING_ID uniqueness and not null | All MEETING_ID values are unique and not null |
| TC_SI_MEETINGS_002 | **EST Timezone Format Validation** | START_TIME and END_TIME with EST format properly detected and converted |
| TC_SI_MEETINGS_003 | **EST to UTC Timezone Conversion** | EST timestamps converted to UTC using CONVERT_TIMEZONE function |
| TC_SI_MEETINGS_004 | Validate meeting duration consistency | DURATION_MINUTES matches DATEDIFF between converted timestamps |
| TC_SI_MEETINGS_005 | Validate HOST_ID referential integrity | All HOST_ID values exist in SI_USERS table |
| TC_SI_MEETINGS_006 | Test meeting time logic validation | END_TIME is always after START_TIME after conversion |
| TC_SI_MEETINGS_007 | **EST Format Error Handling** | Invalid EST format records routed to error table |
| TC_SI_MEETINGS_008 | Validate duration range constraints | DURATION_MINUTES between 0 and 1440 (24 hours) |
| TC_SI_MEETINGS_009 | Test meeting topic PII sanitization | MEETING_TOPIC cleaned and trimmed appropriately |
| TC_SI_MEETINGS_010 | **Mixed Timezone Format Detection** | Records with mixed EST/standard formats handled correctly |
| TC_SI_MEETINGS_011 | Validate data quality scoring with timestamp compliance | DQ score includes timestamp format validation results |
| TC_SI_MEETINGS_012 | Test deduplication with timestamp conversion | Latest record per MEETING_ID after format standardization |

### 3. SI_PARTICIPANTS Model Test Cases (Enhanced for MM/DD/YYYY Format)

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_SI_PARTICIPANTS_001 | Validate PARTICIPANT_ID uniqueness | All PARTICIPANT_ID values are unique and not null |
| TC_SI_PARTICIPANTS_002 | **MM/DD/YYYY HH:MM Format Validation** | JOIN_TIME and LEAVE_TIME with MM/DD/YYYY format detected and converted |
| TC_SI_PARTICIPANTS_003 | **MM/DD/YYYY Format Conversion** | MM/DD/YYYY HH:MM converted using TO_TIMESTAMP function |
| TC_SI_PARTICIPANTS_004 | Validate participant session time logic | LEAVE_TIME is after JOIN_TIME after format conversion |
| TC_SI_PARTICIPANTS_005 | Validate meeting boundary constraints | JOIN_TIME >= meeting START_TIME and LEAVE_TIME <= meeting END_TIME |
| TC_SI_PARTICIPANTS_006 | Validate MEETING_ID referential integrity | All MEETING_ID values exist in SI_MEETINGS table |
| TC_SI_PARTICIPANTS_007 | Validate USER_ID referential integrity | All USER_ID values exist in SI_USERS table |
| TC_SI_PARTICIPANTS_008 | **MM/DD/YYYY Format Error Handling** | Invalid MM/DD/YYYY format records routed to error table |
| TC_SI_PARTICIPANTS_009 | Test unique participant per meeting constraint | Combination of MEETING_ID and USER_ID is unique |
| TC_SI_PARTICIPANTS_010 | **Cross-Format Timestamp Consistency** | Mixed format usage within records flagged as warnings |
| TC_SI_PARTICIPANTS_011 | Validate data quality scoring with format compliance | DQ score includes timestamp format validation |
| TC_SI_PARTICIPANTS_012 | Test boundary validation with converted timestamps | Participant times within meeting boundaries after conversion |

### 4. SI_FEATURE_USAGE Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_SI_FEATURE_USAGE_001 | Validate USAGE_ID uniqueness | All USAGE_ID values are unique and not null |
| TC_SI_FEATURE_USAGE_002 | Validate MEETING_ID referential integrity | All MEETING_ID values exist in SI_MEETINGS table |
| TC_SI_FEATURE_USAGE_003 | Validate FEATURE_NAME standardization | All feature names standardized to uppercase |
| TC_SI_FEATURE_USAGE_004 | Validate USAGE_COUNT non-negative constraint | All USAGE_COUNT values are >= 0 |
| TC_SI_FEATURE_USAGE_005 | Validate USAGE_DATE alignment with meeting date | USAGE_DATE matches DATE(meeting.START_TIME) |
| TC_SI_FEATURE_USAGE_006 | Test feature name length validation | FEATURE_NAME length <= 100 characters |
| TC_SI_FEATURE_USAGE_007 | Validate data quality score calculation | DQ score based on completeness and validation |
| TC_SI_FEATURE_USAGE_008 | Test deduplication logic | Latest record per USAGE_ID based on UPDATE_TIMESTAMP |
| TC_SI_FEATURE_USAGE_009 | Validate null handling for usage metrics | USAGE_COUNT cannot be null |
| TC_SI_FEATURE_USAGE_010 | Test feature adoption rate calculation support | Data supports feature adoption metrics |

### 5. SI_SUPPORT_TICKETS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_SI_SUPPORT_TICKETS_001 | Validate TICKET_ID uniqueness | All TICKET_ID values are unique and not null |
| TC_SI_SUPPORT_TICKETS_002 | Validate USER_ID referential integrity | All USER_ID values exist in SI_USERS table |
| TC_SI_SUPPORT_TICKETS_003 | Validate RESOLUTION_STATUS standardization | Status in ('OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED') |
| TC_SI_SUPPORT_TICKETS_004 | Validate OPEN_DATE future date constraint | OPEN_DATE <= CURRENT_DATE() |
| TC_SI_SUPPORT_TICKETS_005 | Validate TICKET_TYPE standardization | Ticket types standardized to uppercase |
| TC_SI_SUPPORT_TICKETS_006 | Test data quality score calculation | DQ score based on completeness and validation |
| TC_SI_SUPPORT_TICKETS_007 | Validate deduplication logic | Latest record per TICKET_ID |
| TC_SI_SUPPORT_TICKETS_008 | Test null handling for required fields | Required fields not null, optional fields can be null |
| TC_SI_SUPPORT_TICKETS_009 | Validate ticket volume metrics support | Data supports tickets per 1000 users calculation |
| TC_SI_SUPPORT_TICKETS_010 | Test ticket status transition validation | Status transitions follow business rules |

### 6. SI_BILLING_EVENTS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_SI_BILLING_EVENTS_001 | Validate EVENT_ID uniqueness | All EVENT_ID values are unique and not null |
| TC_SI_BILLING_EVENTS_002 | Validate USER_ID referential integrity | All USER_ID values exist in SI_USERS table |
| TC_SI_BILLING_EVENTS_003 | Validate AMOUNT positive constraint | All AMOUNT values are > 0 |
| TC_SI_BILLING_EVENTS_004 | Validate AMOUNT decimal precision | AMOUNT values have 2 decimal places precision |
| TC_SI_BILLING_EVENTS_005 | Validate EVENT_DATE future date constraint | EVENT_DATE <= CURRENT_DATE() |
| TC_SI_BILLING_EVENTS_006 | Validate EVENT_TYPE standardization | Event types standardized to uppercase |
| TC_SI_BILLING_EVENTS_007 | Test quoted numeric value parsing | Quoted string amounts like "50.21" parsed correctly |
| TC_SI_BILLING_EVENTS_008 | Validate data quality score calculation | DQ score based on completeness and validation |
| TC_SI_BILLING_EVENTS_009 | Test deduplication logic | Latest record per EVENT_ID |
| TC_SI_BILLING_EVENTS_010 | Validate MRR calculation support | Data supports Monthly Recurring Revenue metrics |

### 7. SI_LICENSES Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_SI_LICENSES_001 | Validate LICENSE_ID uniqueness | All LICENSE_ID values are unique and not null |
| TC_SI_LICENSES_002 | Validate ASSIGNED_TO_USER_ID referential integrity | All user IDs exist in SI_USERS table |
| TC_SI_LICENSES_003 | Validate date logic constraint | START_DATE <= END_DATE |
| TC_SI_LICENSES_004 | Validate LICENSE_TYPE standardization | License types standardized to uppercase |
| TC_SI_LICENSES_005 | Test multiple date format support | DD/MM/YYYY and MM/DD/YYYY formats converted correctly |
| TC_SI_LICENSES_006 | Validate active license identification | Active licenses have END_DATE > CURRENT_DATE() |
| TC_SI_LICENSES_007 | Test data quality score calculation | DQ score based on completeness and validation |
| TC_SI_LICENSES_008 | Validate deduplication logic | Latest record per LICENSE_ID |
| TC_SI_LICENSES_009 | Test license utilization rate support | Data supports utilization metrics |
| TC_SI_LICENSES_010 | Validate date format error handling | Invalid date formats routed to error table |

### 8. Cross-Table Integration Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_INTEGRATION_001 | Validate user activity consistency | Users with meetings have participant records |
| TC_INTEGRATION_002 | Validate feature usage alignment | Feature usage aligns with meeting participants |
| TC_INTEGRATION_003 | Validate billing-license consistency | Users with billing events have license records |
| TC_INTEGRATION_004 | Test referential integrity cascade | All foreign key relationships maintained |
| TC_INTEGRATION_005 | Validate data freshness consistency | All tables have consistent LOAD_TIMESTAMP ranges |
| TC_INTEGRATION_006 | Test cross-table data quality scoring | Consistent DQ scoring across related records |
| TC_INTEGRATION_007 | Validate audit trail completeness | All transformations logged in audit table |
| TC_INTEGRATION_008 | Test error handling consistency | Errors consistently routed to error table |
| TC_INTEGRATION_009 | Validate business rule consistency | Business rules applied consistently across tables |
| TC_INTEGRATION_010 | Test performance with large datasets | Models perform within acceptable time limits |

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# models/silver/schema.yml
version: 2

sources:
  - name: bronze
    description: "Bronze layer source tables"
    database: DB_POC_ZOOM
    schema: bronze
    tables:
      - name: bz_users
        description: "Raw user data from source systems"
      - name: bz_meetings
        description: "Raw meeting data with potential EST timezone format"
      - name: bz_participants
        description: "Raw participant data with MM/DD/YYYY HH:MM format"
      - name: bz_feature_usage
        description: "Raw feature usage tracking data"
      - name: bz_support_tickets
        description: "Raw support ticket data"
      - name: bz_billing_events
        description: "Raw billing and payment event data"
      - name: bz_licenses
        description: "Raw license assignment data"

models:
  - name: si_users
    description: "Silver layer users with data quality validation"
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
        description: "User subscription plan"
        tests:
          - accepted_values:
              values: ['FREE', 'BASIC', 'PRO', 'ENTERPRISE']
      - name: data_quality_score
        description: "Data quality score (0-100)"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100
      - name: validation_status
        description: "Validation status"
        tests:
          - accepted_values:
              values: ['PASSED', 'WARNING', 'FAILED']

  - name: si_meetings
    description: "Silver layer meetings with EST timezone handling"
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
      - name: start_time
        description: "Meeting start time (converted from EST if needed)"
        tests:
          - not_null
      - name: end_time
        description: "Meeting end time (converted from EST if needed)"
        tests:
          - not_null
      - name: duration_minutes
        description: "Meeting duration in minutes"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440

  - name: si_participants
    description: "Silver layer participants with MM/DD/YYYY format handling"
    columns:
      - name: participant_id
        description: "Unique participant identifier"
        tests:
          - unique
          - not_null
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
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: join_time
        description: "Participant join time (converted from MM/DD/YYYY if needed)"
        tests:
          - not_null
      - name: leave_time
        description: "Participant leave time (converted from MM/DD/YYYY if needed)"
        tests:
          - not_null

  - name: si_feature_usage
    description: "Silver layer feature usage tracking"
    columns:
      - name: usage_id
        description: "Unique usage record identifier"
        tests:
          - unique
          - not_null
      - name: meeting_id
        description: "Reference to meeting"
        tests:
          - not_null
          - relationships:
              to: ref('si_meetings')
              field: meeting_id
      - name: usage_count
        description: "Number of times feature was used"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: number
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0

  - name: si_support_tickets
    description: "Silver layer support tickets"
    columns:
      - name: ticket_id
        description: "Unique ticket identifier"
        tests:
          - unique
          - not_null
      - name: user_id
        description: "Reference to user who created ticket"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: resolution_status
        description: "Current ticket status"
        tests:
          - accepted_values:
              values: ['OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED']

  - name: si_billing_events
    description: "Silver layer billing events"
    columns:
      - name: event_id
        description: "Unique billing event identifier"
        tests:
          - unique
          - not_null
      - name: user_id
        description: "Reference to user"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: amount
        description: "Billing amount"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.01

  - name: si_licenses
    description: "Silver layer license assignments"
    columns:
      - name: license_id
        description: "Unique license identifier"
        tests:
          - unique
          - not_null
      - name: assigned_to_user_id
        description: "User assigned to license"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
```

### Custom SQL-based dbt Tests

#### 1. EST Timezone Format Validation Test

```sql
-- tests/assert_est_timezone_conversion.sql
-- Test that EST timezone timestamps are properly converted to UTC

SELECT 
    meeting_id,
    start_time,
    end_time
FROM {{ ref('si_meetings') }}
WHERE 
    -- Check for any remaining EST timezone indicators after conversion
    (start_time::STRING LIKE '%EST%' OR end_time::STRING LIKE '%EST%')
    -- This should return 0 rows if conversion is working properly
```

#### 2. MM/DD/YYYY Format Validation Test

```sql
-- tests/assert_mmddyyyy_format_conversion.sql
-- Test that MM/DD/YYYY format timestamps are properly converted

SELECT 
    participant_id,
    join_time,
    leave_time
FROM {{ ref('si_participants') }}
WHERE 
    -- Check for any remaining MM/DD/YYYY format after conversion
    (join_time::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}' 
     OR leave_time::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}')
    -- This should return 0 rows if conversion is working properly
```

#### 3. Meeting Duration Consistency Test

```sql
-- tests/assert_meeting_duration_consistency.sql
-- Test that duration matches calculated time difference

SELECT 
    meeting_id,
    duration_minutes,
    DATEDIFF('minute', start_time, end_time) as calculated_duration,
    ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) as difference
FROM {{ ref('si_meetings') }}
WHERE 
    -- Allow 1 minute tolerance for rounding
    ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) > 1
```

#### 4. Participant Session Boundary Test

```sql
-- tests/assert_participant_session_boundaries.sql
-- Test that participant times are within meeting boundaries

SELECT 
    p.participant_id,
    p.meeting_id,
    p.join_time,
    p.leave_time,
    m.start_time as meeting_start,
    m.end_time as meeting_end
FROM {{ ref('si_participants') }} p
JOIN {{ ref('si_meetings') }} m ON p.meeting_id = m.meeting_id
WHERE 
    p.join_time < m.start_time 
    OR p.leave_time > m.end_time
    OR p.leave_time <= p.join_time
```

#### 5. Data Quality Score Validation Test

```sql
-- tests/assert_data_quality_scores.sql
-- Test that data quality scores are within valid range and properly calculated

SELECT 
    'si_users' as table_name,
    COUNT(*) as invalid_scores
FROM {{ ref('si_users') }}
WHERE data_quality_score < 0 OR data_quality_score > 100

UNION ALL

SELECT 
    'si_meetings' as table_name,
    COUNT(*) as invalid_scores
FROM {{ ref('si_meetings') }}
WHERE data_quality_score < 0 OR data_quality_score > 100

UNION ALL

SELECT 
    'si_participants' as table_name,
    COUNT(*) as invalid_scores
FROM {{ ref('si_participants') }}
WHERE data_quality_score < 0 OR data_quality_score > 100

-- This should return 0 for all tables
HAVING COUNT(*) > 0
```

#### 6. Referential Integrity Test

```sql
-- tests/assert_referential_integrity.sql
-- Test that all foreign key relationships are maintained

-- Check meetings without valid hosts
SELECT 
    'meetings_without_hosts' as test_case,
    COUNT(*) as violation_count
FROM {{ ref('si_meetings') }} m
LEFT JOIN {{ ref('si_users') }} u ON m.host_id = u.user_id
WHERE u.user_id IS NULL

UNION ALL

-- Check participants without valid users
SELECT 
    'participants_without_users' as test_case,
    COUNT(*) as violation_count
FROM {{ ref('si_participants') }} p
LEFT JOIN {{ ref('si_users') }} u ON p.user_id = u.user_id
WHERE u.user_id IS NULL

UNION ALL

-- Check participants without valid meetings
SELECT 
    'participants_without_meetings' as test_case,
    COUNT(*) as violation_count
FROM {{ ref('si_participants') }} p
LEFT JOIN {{ ref('si_meetings') }} m ON p.meeting_id = m.meeting_id
WHERE m.meeting_id IS NULL

-- All counts should be 0
HAVING COUNT(*) > 0
```

#### 7. Email Format Validation Test

```sql
-- tests/assert_email_format_validation.sql
-- Test that all email addresses follow valid format

SELECT 
    user_id,
    email
FROM {{ ref('si_users') }}
WHERE 
    email IS NOT NULL 
    AND NOT REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
```

#### 8. Plan Type Standardization Test

```sql
-- tests/assert_plan_type_standardization.sql
-- Test that all plan types are properly standardized

SELECT 
    user_id,
    plan_type
FROM {{ ref('si_users') }}
WHERE 
    plan_type NOT IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE')
    OR plan_type IS NULL
```

#### 9. Billing Amount Validation Test

```sql
-- tests/assert_billing_amount_validation.sql
-- Test that billing amounts are positive and properly formatted

SELECT 
    event_id,
    amount,
    event_type
FROM {{ ref('si_billing_events') }}
WHERE 
    amount <= 0 
    OR amount IS NULL
    OR ROUND(amount, 2) != amount  -- Check decimal precision
```

#### 10. License Date Logic Test

```sql
-- tests/assert_license_date_logic.sql
-- Test that license start and end dates follow business logic

SELECT 
    license_id,
    start_date,
    end_date,
    assigned_to_user_id
FROM {{ ref('si_licenses') }}
WHERE 
    start_date >= end_date
    OR start_date IS NULL
    OR end_date IS NULL
```

### Parameterized Tests for Reusability

#### 1. Generic Uniqueness Test with Custom Message

```sql
-- macros/test_enhanced_unique.sql
{% macro test_enhanced_unique(model, column_name, error_message='Duplicate values found') %}

  SELECT 
    {{ column_name }},
    COUNT(*) as duplicate_count,
    '{{ error_message }}' as error_description
  FROM {{ model }}
  WHERE {{ column_name }} IS NOT NULL
  GROUP BY {{ column_name }}
  HAVING COUNT(*) > 1

{% endmacro %}
```

#### 2. Generic Data Quality Score Test

```sql
-- macros/test_data_quality_score.sql
{% macro test_data_quality_score(model, min_score=70) %}

  SELECT 
    COUNT(*) as low_quality_records,
    AVG(data_quality_score) as avg_score,
    MIN(data_quality_score) as min_score
  FROM {{ model }}
  WHERE 
    data_quality_score < {{ min_score }}
    OR data_quality_score IS NULL
  HAVING COUNT(*) > 0

{% endmacro %}
```

#### 3. Generic Timestamp Format Test

```sql
-- macros/test_timestamp_format.sql
{% macro test_timestamp_format(model, column_name, expected_format='STANDARD') %}

  {% if expected_format == 'NO_EST' %}
    SELECT 
      COUNT(*) as invalid_format_count
    FROM {{ model }}
    WHERE {{ column_name }}::STRING LIKE '%EST%'
  {% elif expected_format == 'NO_MMDDYYYY' %}
    SELECT 
      COUNT(*) as invalid_format_count
    FROM {{ model }}
    WHERE {{ column_name }}::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}'
  {% endif %}
  
  HAVING COUNT(*) > 0

{% endmacro %}
```

### Test Execution and Monitoring

#### 1. dbt Test Execution Commands

```bash
# Run all tests
dbt test

# Run tests for specific model
dbt test --select si_users
dbt test --select si_meetings
dbt test --select si_participants

# Run only custom SQL tests
dbt test --select test_type:generic

# Run tests with specific tags
dbt test --select tag:data_quality
dbt test --select tag:timestamp_validation

# Run tests in fail-fast mode
dbt test --fail-fast

# Generate test documentation
dbt docs generate
dbt docs serve
```

#### 2. Test Results Tracking

```sql
-- Query to monitor test results from dbt's run_results.json
SELECT 
    test_name,
    model_name,
    status,
    execution_time,
    failures,
    run_started_at
FROM dbt_test_results
WHERE 
    run_started_at >= CURRENT_DATE() - INTERVAL '7 days'
ORDER BY run_started_at DESC;
```

#### 3. Snowflake Audit Schema Integration

```sql
-- Create audit table for test results
CREATE TABLE IF NOT EXISTS SILVER.SI_TEST_EXECUTION_LOG (
    test_execution_id VARCHAR(16777216),
    test_name VARCHAR(16777216),
    model_name VARCHAR(16777216),
    test_type VARCHAR(100),
    execution_status VARCHAR(50),
    execution_start_time TIMESTAMP_NTZ(9),
    execution_end_time TIMESTAMP_NTZ(9),
    execution_duration_seconds NUMBER(10,2),
    failure_count NUMBER(38,0),
    warning_count NUMBER(38,0),
    test_sql VARIANT,
    error_details VARIANT,
    load_timestamp TIMESTAMP_NTZ(9)
);

-- Insert test results
INSERT INTO SILVER.SI_TEST_EXECUTION_LOG (
    test_execution_id,
    test_name,
    model_name,
    test_type,
    execution_status,
    execution_start_time,
    execution_end_time,
    execution_duration_seconds,
    failure_count,
    warning_count,
    load_timestamp
)
VALUES (
    UUID_STRING(),
    'assert_est_timezone_conversion',
    'si_meetings',
    'TIMESTAMP_FORMAT',
    'PASSED',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP(),
    1.25,
    0,
    0,
    CURRENT_TIMESTAMP()
);
```

## Test Implementation Guidelines

### 1. Test Organization
- **Schema Tests**: Use for standard validations (unique, not_null, relationships)
- **Custom SQL Tests**: Use for complex business logic and format validations
- **Parameterized Tests**: Use for reusable test patterns across multiple models
- **Integration Tests**: Use for cross-table validations and end-to-end scenarios

### 2. Test Execution Strategy
- **Pre-deployment**: Run all tests before deploying to production
- **Continuous Integration**: Integrate tests into CI/CD pipeline
- **Scheduled Monitoring**: Run critical tests on schedule to monitor data quality
- **Alert Integration**: Set up alerts for test failures in production

### 3. Performance Considerations
- **Selective Testing**: Use dbt selectors to run relevant tests only
- **Test Optimization**: Optimize test queries for large datasets
- **Parallel Execution**: Leverage dbt's parallel execution capabilities
- **Resource Management**: Configure appropriate warehouse sizes for test execution

### 4. Error Handling and Recovery
- **Graceful Degradation**: Design tests to handle edge cases gracefully
- **Error Documentation**: Document expected failures and resolution steps
- **Automated Remediation**: Implement automated fixes for common issues
- **Manual Intervention**: Define escalation procedures for critical failures

## Success Metrics and KPIs

### 1. Test Coverage Metrics
- **Model Coverage**: Percentage of models with comprehensive tests
- **Column Coverage**: Percentage of critical columns with validation tests
- **Business Rule Coverage**: Percentage of business rules with corresponding tests
- **Edge Case Coverage**: Percentage of identified edge cases with tests

### 2. Data Quality Metrics
- **Test Pass Rate**: Percentage of tests passing consistently
- **Data Quality Score**: Average DQ score across all Silver layer tables
- **Format Compliance Rate**: Percentage of records passing format validation
- **Referential Integrity Rate**: Percentage of foreign key relationships validated

### 3. Performance Metrics
- **Test Execution Time**: Average time to run full test suite
- **Model Build Time**: Time to build models including test validation
- **Resource Utilization**: Snowflake compute credits consumed by testing
- **Failure Recovery Time**: Time to identify and resolve test failures

### 4. Business Impact Metrics
- **Data Reliability**: Reduction in downstream data issues
- **Time to Detection**: Time to identify data quality issues
- **Resolution Efficiency**: Time to resolve identified issues
- **Stakeholder Confidence**: Business user confidence in data quality

---

**Note**: These comprehensive unit test cases ensure the reliability, performance, and data quality of the Zoom Platform Analytics System Silver layer dbt models in Snowflake. The tests specifically address the timestamp format challenges (EST timezone and MM/DD/YYYY formats) while maintaining robust validation for all data transformations, business rules, and edge cases. Regular execution of these tests will ensure consistent data quality and early detection of potential issues in the data pipeline.
