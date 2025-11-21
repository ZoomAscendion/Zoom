_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Platform Analytics Bronze layer dbt models in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases - Zoom Platform Analytics Bronze Layer

## Overview

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics Bronze layer implementation. The tests ensure data quality, validate transformations, and verify business rules across all Bronze layer models in the Snowflake environment.

## Test Strategy

### Testing Approach
- **Data Quality Tests**: Validate data integrity, uniqueness, and completeness
- **Business Rule Tests**: Ensure compliance with business logic and constraints
- **Edge Case Tests**: Handle null values, empty datasets, and boundary conditions
- **Performance Tests**: Validate query performance and resource utilization
- **Audit Trail Tests**: Verify comprehensive logging and tracking mechanisms

### Test Coverage
- **7 Bronze Tables**: BZ_USERS, BZ_MEETINGS, BZ_PARTICIPANTS, BZ_FEATURE_USAGE, BZ_SUPPORT_TICKETS, BZ_BILLING_EVENTS, BZ_LICENSES
- **1 Audit Table**: BZ_DATA_AUDIT
- **Sample Data Validation**: Verify generated sample data meets requirements
- **Metadata Validation**: Ensure proper timestamp and source system tracking

## Test Case List

### 1. Data Quality Test Cases

| Test Case ID | Test Case Description | Expected Outcome | Priority |
|--------------|----------------------|------------------|----------|
| DQ_001 | Validate USER_ID uniqueness in BZ_USERS | No duplicate USER_ID values | High |
| DQ_002 | Validate MEETING_ID uniqueness in BZ_MEETINGS | No duplicate MEETING_ID values | High |
| DQ_003 | Validate PARTICIPANT_ID uniqueness in BZ_PARTICIPANTS | No duplicate PARTICIPANT_ID values | High |
| DQ_004 | Validate USAGE_ID uniqueness in BZ_FEATURE_USAGE | No duplicate USAGE_ID values | High |
| DQ_005 | Validate TICKET_ID uniqueness in BZ_SUPPORT_TICKETS | No duplicate TICKET_ID values | High |
| DQ_006 | Validate EVENT_ID uniqueness in BZ_BILLING_EVENTS | No duplicate EVENT_ID values | High |
| DQ_007 | Validate LICENSE_ID uniqueness in BZ_LICENSES | No duplicate LICENSE_ID values | High |
| DQ_008 | Validate RECORD_ID uniqueness in BZ_DATA_AUDIT | No duplicate RECORD_ID values | High |
| DQ_009 | Check for NULL primary keys across all tables | No NULL values in primary key columns | High |
| DQ_010 | Validate LOAD_TIMESTAMP not null across all tables | All records have valid load timestamps | High |

### 2. Business Rule Test Cases

| Test Case ID | Test Case Description | Expected Outcome | Priority |
|--------------|----------------------|------------------|----------|
| BR_001 | Validate PLAN_TYPE values in BZ_USERS | Only accepted values: Basic, Pro, Business, Enterprise | High |
| BR_002 | Validate meeting duration consistency | END_TIME > START_TIME and DURATION_MINUTES matches | High |
| BR_003 | Validate participant session logic | LEAVE_TIME >= JOIN_TIME for all participants | High |
| BR_004 | Validate billing amount format | AMOUNT values are positive numbers with 2 decimal places | Medium |
| BR_005 | Validate license date ranges | END_DATE >= START_DATE for all licenses | Medium |
| BR_006 | Validate audit status values | STATUS in ('STARTED', 'SUCCESS', 'FAILED', 'WARNING') | High |
| BR_007 | Validate email format in BZ_USERS | EMAIL contains '@' symbol and valid format | Medium |
| BR_008 | Validate feature usage counts | USAGE_COUNT >= 0 for all feature usage records | Medium |
| BR_009 | Validate support ticket status values | Valid resolution status values only | Medium |
| BR_010 | Validate source system consistency | SOURCE_SYSTEM not null and consistent format | Low |

### 3. Edge Case Test Cases

| Test Case ID | Test Case Description | Expected Outcome | Priority |
|--------------|----------------------|------------------|----------|
| EC_001 | Handle empty dataset scenarios | Models execute successfully with no source data | Medium |
| EC_002 | Handle NULL values in optional fields | NULL values preserved without errors | Medium |
| EC_003 | Handle maximum VARCHAR length | Long text values truncated or handled gracefully | Low |
| EC_004 | Handle future dates in timestamp fields | Future dates accepted without validation errors | Low |
| EC_005 | Handle zero duration meetings | Zero or negative duration handled appropriately | Medium |
| EC_006 | Handle orphaned participant records | Participants without valid meeting references | Medium |
| EC_007 | Handle duplicate audit entries | Multiple audit entries for same operation | Low |
| EC_008 | Handle invalid email formats | Malformed email addresses processed without errors | Low |
| EC_009 | Handle negative billing amounts | Negative amounts (refunds) processed correctly | Medium |
| EC_010 | Handle expired licenses | Licenses with past end dates handled correctly | Low |

### 4. Performance Test Cases

| Test Case ID | Test Case Description | Expected Outcome | Priority |
|--------------|----------------------|------------------|----------|
| PF_001 | Validate model execution time | All models complete within 30 seconds | Medium |
| PF_002 | Validate memory usage | Models execute within Snowflake warehouse limits | Medium |
| PF_003 | Validate concurrent execution | Multiple models can run simultaneously | Low |
| PF_004 | Validate large dataset handling | Models scale with increased data volume | Medium |
| PF_005 | Validate audit logging performance | Audit operations don't significantly impact performance | Low |

## dbt Test Scripts

### Schema Tests (schema.yml)

```yaml
version: 2

models:
  # BZ_DATA_AUDIT Tests
  - name: bz_data_audit
    description: "Comprehensive audit trail for all Bronze layer data operations"
    tests:
      - dbt_utils.expression_is_true:
          expression: "count(*) >= 0"
          config:
            severity: warn
    columns:
      - name: record_id
        description: "Auto-incrementing unique identifier for each audit record"
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
      - name: source_table
        description: "Name of the Bronze layer table"
        tests:
          - not_null:
              config:
                severity: error
          - accepted_values:
              values: ['BZ_USERS', 'BZ_MEETINGS', 'BZ_PARTICIPANTS', 'BZ_FEATURE_USAGE', 'BZ_SUPPORT_TICKETS', 'BZ_BILLING_EVENTS', 'BZ_LICENSES']
              config:
                severity: warn
      - name: load_timestamp
        description: "When the operation occurred"
        tests:
          - not_null:
              config:
                severity: error
      - name: status
        description: "Status of the operation"
        tests:
          - not_null:
              config:
                severity: error
          - accepted_values:
              values: ['STARTED', 'SUCCESS', 'FAILED', 'WARNING']
              config:
                severity: error

  # BZ_USERS Tests
  - name: bz_users
    description: "Bronze layer table storing user profile and subscription information"
    tests:
      - dbt_utils.expression_is_true:
          expression: "count(*) > 0"
          config:
            severity: warn
      - dbt_expectations.expect_table_row_count_to_be_between:
          min_value: 1
          max_value: 1000000
    columns:
      - name: user_id
        description: "Unique identifier for each user account"
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
          - dbt_utils.not_empty_string:
              config:
                severity: error
      - name: user_name
        description: "Display name of the user (PII)"
        tests:
          - dbt_utils.not_empty_string:
              config:
                severity: warn
      - name: email
        description: "Email address of the user (PII)"
        tests:
          - dbt_utils.not_empty_string:
              config:
                severity: warn
      - name: plan_type
        description: "Subscription plan type"
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise']
              config:
                severity: error
      - name: load_timestamp
        description: "Timestamp when record was loaded into Bronze layer"
        tests:
          - not_null:
              config:
                severity: error
      - name: update_timestamp
        description: "Timestamp when record was last updated"
        tests:
          - not_null:
              config:
                severity: error
      - name: source_system
        description: "Source system from which data originated"
        tests:
          - not_null:
              config:
                severity: warn

  # BZ_MEETINGS Tests
  - name: bz_meetings
    description: "Bronze layer table storing meeting information and session details"
    tests:
      - dbt_utils.expression_is_true:
          expression: "count(*) > 0"
          config:
            severity: warn
    columns:
      - name: meeting_id
        description: "Unique identifier for each meeting"
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
      - name: host_id
        description: "User ID of the meeting host"
        tests:
          - not_null:
              config:
                severity: error
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: warn
      - name: start_time
        description: "Meeting start timestamp"
        tests:
          - not_null:
              config:
                severity: error
      - name: end_time
        description: "Meeting end timestamp"
        tests:
          - not_null:
              config:
                severity: error
      - name: duration_minutes
        description: "Meeting duration in minutes"
        tests:
          - not_null:
              config:
                severity: error
          - dbt_utils.expression_is_true:
              expression: ">= 0"
              config:
                severity: error
      - name: load_timestamp
        description: "Timestamp when record was loaded into Bronze layer"
        tests:
          - not_null:
              config:
                severity: error
      - name: update_timestamp
        description: "Timestamp when record was last updated"
        tests:
          - not_null:
              config:
                severity: error

  # BZ_PARTICIPANTS Tests
  - name: bz_participants
    description: "Bronze layer table tracking meeting participants"
    columns:
      - name: participant_id
        description: "Unique identifier for each meeting participant"
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
      - name: meeting_id
        description: "Reference to meeting"
        tests:
          - not_null:
              config:
                severity: error
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
              config:
                severity: warn
      - name: user_id
        description: "Reference to user who participated"
        tests:
          - not_null:
              config:
                severity: error
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: warn
      - name: join_time
        description: "Timestamp when participant joined meeting"
        tests:
          - not_null:
              config:
                severity: error

  # BZ_FEATURE_USAGE Tests
  - name: bz_feature_usage
    description: "Bronze layer table recording platform feature usage"
    columns:
      - name: usage_id
        description: "Unique identifier for each feature usage record"
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
      - name: meeting_id
        description: "Reference to meeting where feature was used"
        tests:
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
              config:
                severity: warn
      - name: usage_count
        description: "Number of times feature was used"
        tests:
          - dbt_utils.expression_is_true:
              expression: ">= 0"
              config:
                severity: error

  # BZ_SUPPORT_TICKETS Tests
  - name: bz_support_tickets
    description: "Bronze layer table managing customer support requests"
    columns:
      - name: ticket_id
        description: "Unique identifier for each support ticket"
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
      - name: user_id
        description: "Reference to user who created the ticket"
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: warn

  # BZ_BILLING_EVENTS Tests
  - name: bz_billing_events
    description: "Bronze layer table tracking financial transactions"
    columns:
      - name: event_id
        description: "Unique identifier for each billing event"
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
      - name: user_id
        description: "Reference to user associated with billing event"
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: warn
      - name: amount
        description: "Monetary amount for the billing event"
        tests:
          - not_null:
              config:
                severity: error

  # BZ_LICENSES Tests
  - name: bz_licenses
    description: "Bronze layer table managing license assignments"
    columns:
      - name: license_id
        description: "Unique identifier for each license"
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
      - name: assigned_to_user_id
        description: "User ID to whom license is assigned"
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: warn
```

### Custom SQL Tests

#### 1. Meeting Duration Consistency Test
```sql
-- tests/meeting_duration_consistency.sql
-- Test to ensure meeting duration matches calculated time difference

SELECT 
    meeting_id,
    start_time,
    end_time,
    duration_minutes,
    DATEDIFF('minute', start_time, end_time) AS calculated_duration
FROM {{ ref('bz_meetings') }}
WHERE duration_minutes != DATEDIFF('minute', start_time, end_time)
   OR duration_minutes IS NULL
   OR start_time >= end_time
```

#### 2. Participant Session Logic Test
```sql
-- tests/participant_session_logic.sql
-- Test to ensure participant leave time is after join time

SELECT 
    participant_id,
    meeting_id,
    join_time,
    leave_time
FROM {{ ref('bz_participants') }}
WHERE leave_time < join_time
   OR (leave_time IS NOT NULL AND join_time IS NULL)
```

#### 3. Email Format Validation Test
```sql
-- tests/email_format_validation.sql
-- Test to validate email format in users table

SELECT 
    user_id,
    email
FROM {{ ref('bz_users') }}
WHERE email IS NOT NULL 
  AND email NOT LIKE '%@%'
  AND email != ''
```

#### 4. Audit Trail Completeness Test
```sql
-- tests/audit_trail_completeness.sql
-- Test to ensure all Bronze tables have corresponding audit entries

WITH expected_tables AS (
    SELECT table_name
    FROM (
        VALUES 
            ('BZ_USERS'),
            ('BZ_MEETINGS'),
            ('BZ_PARTICIPANTS'),
            ('BZ_FEATURE_USAGE'),
            ('BZ_SUPPORT_TICKETS'),
            ('BZ_BILLING_EVENTS'),
            ('BZ_LICENSES')
    ) AS t(table_name)
),
audited_tables AS (
    SELECT DISTINCT source_table
    FROM {{ ref('bz_data_audit') }}
    WHERE status = 'SUCCESS'
)
SELECT et.table_name
FROM expected_tables et
LEFT JOIN audited_tables at ON et.table_name = at.source_table
WHERE at.source_table IS NULL
```

#### 5. License Date Range Validation Test
```sql
-- tests/license_date_range_validation.sql
-- Test to ensure license end date is after start date

SELECT 
    license_id,
    start_date,
    end_date
FROM {{ ref('bz_licenses') }}
WHERE end_date < start_date
   OR (start_date IS NULL AND end_date IS NOT NULL)
```

#### 6. Billing Amount Validation Test
```sql
-- tests/billing_amount_validation.sql
-- Test to validate billing amounts are properly formatted

SELECT 
    event_id,
    amount,
    event_type
FROM {{ ref('bz_billing_events') }}
WHERE amount IS NULL
   OR (event_type NOT IN ('REFUND', 'ADJUSTMENT') AND amount <= 0)
```

#### 7. Feature Usage Count Validation Test
```sql
-- tests/feature_usage_count_validation.sql
-- Test to ensure usage counts are non-negative

SELECT 
    usage_id,
    feature_name,
    usage_count
FROM {{ ref('bz_feature_usage') }}
WHERE usage_count < 0
   OR usage_count IS NULL
```

#### 8. Timestamp Consistency Test
```sql
-- tests/timestamp_consistency.sql
-- Test to ensure update_timestamp >= load_timestamp

WITH all_timestamps AS (
    SELECT 'BZ_USERS' as table_name, user_id as record_id, load_timestamp, update_timestamp FROM {{ ref('bz_users') }}
    UNION ALL
    SELECT 'BZ_MEETINGS', meeting_id, load_timestamp, update_timestamp FROM {{ ref('bz_meetings') }}
    UNION ALL
    SELECT 'BZ_PARTICIPANTS', participant_id, load_timestamp, update_timestamp FROM {{ ref('bz_participants') }}
    UNION ALL
    SELECT 'BZ_FEATURE_USAGE', usage_id, load_timestamp, update_timestamp FROM {{ ref('bz_feature_usage') }}
    UNION ALL
    SELECT 'BZ_SUPPORT_TICKETS', ticket_id, load_timestamp, update_timestamp FROM {{ ref('bz_support_tickets') }}
    UNION ALL
    SELECT 'BZ_BILLING_EVENTS', event_id, load_timestamp, update_timestamp FROM {{ ref('bz_billing_events') }}
    UNION ALL
    SELECT 'BZ_LICENSES', license_id, load_timestamp, update_timestamp FROM {{ ref('bz_licenses') }}
)
SELECT 
    table_name,
    record_id,
    load_timestamp,
    update_timestamp
FROM all_timestamps
WHERE update_timestamp < load_timestamp
   OR load_timestamp IS NULL
   OR update_timestamp IS NULL
```

### Parameterized Tests

#### Generic Test for Primary Key Validation
```sql
-- macros/test_primary_key_not_null_unique.sql
{% macro test_primary_key_not_null_unique(model, column_name) %}

SELECT {{ column_name }}
FROM {{ model }}
WHERE {{ column_name }} IS NULL
   OR {{ column_name }} = ''
UNION ALL
SELECT {{ column_name }}
FROM {{ model }}
GROUP BY {{ column_name }}
HAVING COUNT(*) > 1

{% endmacro %}
```

#### Generic Test for Referential Integrity
```sql
-- macros/test_referential_integrity.sql
{% macro test_referential_integrity(model, column_name, ref_model, ref_column) %}

SELECT {{ column_name }}
FROM {{ model }}
WHERE {{ column_name }} IS NOT NULL
  AND {{ column_name }} NOT IN (
    SELECT {{ ref_column }}
    FROM {{ ref_model }}
    WHERE {{ ref_column }} IS NOT NULL
  )

{% endmacro %}
```

## Test Execution Strategy

### 1. Pre-deployment Testing
- Run all schema tests before model deployment
- Execute custom SQL tests in development environment
- Validate sample data generation and quality

### 2. Post-deployment Testing
- Verify audit trail completeness
- Check data volume and distribution
- Validate performance metrics

### 3. Continuous Testing
- Schedule daily test runs in production
- Monitor test results in dbt Cloud
- Set up alerts for test failures

### 4. Test Data Management
- Maintain test data sets for edge cases
- Regular refresh of test data
- Version control for test configurations

## Expected Test Results

### Success Criteria
- **All Primary Key Tests**: 100% pass rate
- **Data Quality Tests**: 95% pass rate (allowing for data quality issues)
- **Business Rule Tests**: 100% pass rate
- **Performance Tests**: All models complete within SLA
- **Audit Tests**: Complete audit trail for all operations

### Failure Handling
- **Critical Failures**: Stop pipeline execution
- **Warning Failures**: Log and continue with monitoring
- **Performance Failures**: Scale warehouse or optimize queries

## Monitoring and Alerting

### Test Result Tracking
- dbt Cloud test result dashboard
- Snowflake audit schema monitoring
- Custom alerting for critical test failures

### Performance Monitoring
- Query execution time tracking
- Resource utilization monitoring
- Data volume growth tracking

## Conclusion

This comprehensive test suite ensures the reliability, performance, and data quality of the Zoom Platform Analytics Bronze layer dbt models in Snowflake. The combination of schema tests, custom SQL tests, and parameterized tests provides thorough coverage of all critical aspects of the data pipeline, enabling early detection of issues and maintaining high data quality standards.

The test cases cover:
- **Data Integrity**: Uniqueness, completeness, and format validation
- **Business Logic**: Compliance with business rules and constraints
- **Edge Cases**: Handling of exceptional scenarios and boundary conditions
- **Performance**: Execution time and resource utilization validation
- **Audit Trail**: Comprehensive logging and tracking verification

Regular execution of these tests ensures the Bronze layer maintains its role as a reliable foundation for downstream Silver and Gold layer transformations in the Medallion architecture.