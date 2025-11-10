_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Platform Bronze Layer dbt models in Snowflake
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Zoom Platform Bronze Layer

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Bronze Layer dbt models running in Snowflake. The test cases cover data transformations, business rules, edge cases, and error handling scenarios to ensure reliable and performant data pipelines.

## Test Strategy Overview

The testing framework validates:
- **Data Quality**: Primary key constraints, null value handling, data type validation
- **Business Rules**: Referential integrity, data transformation logic, audit trail functionality
- **Edge Cases**: Empty datasets, invalid lookups, schema mismatches
- **Performance**: Query optimization, materialization strategies
- **Error Handling**: Failed relationships, unexpected values, data validation failures

---

## Test Case List

### 1. Data Quality Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) Tested |
|--------------|----------------------|------------------|------------------|
| TC_DQ_001 | Validate USER_ID is unique and not null in bz_users | All USER_ID values are unique and non-null | bz_users |
| TC_DQ_002 | Validate MEETING_ID is unique and not null in bz_meetings | All MEETING_ID values are unique and non-null | bz_meetings |
| TC_DQ_003 | Validate PARTICIPANT_ID is unique and not null in bz_participants | All PARTICIPANT_ID values are unique and non-null | bz_participants |
| TC_DQ_004 | Validate USAGE_ID is unique and not null in bz_feature_usage | All USAGE_ID values are unique and non-null | bz_feature_usage |
| TC_DQ_005 | Validate TICKET_ID is unique and not null in bz_support_tickets | All TICKET_ID values are unique and non-null | bz_support_tickets |
| TC_DQ_006 | Validate EVENT_ID is unique and not null in bz_billing_events | All EVENT_ID values are unique and non-null | bz_billing_events |
| TC_DQ_007 | Validate LICENSE_ID is unique and not null in bz_licenses | All LICENSE_ID values are unique and non-null | bz_licenses |
| TC_DQ_008 | Validate email format in bz_users | All email addresses follow valid format pattern | bz_users |
| TC_DQ_009 | Validate date fields are properly formatted | All timestamp and date fields are valid | All models |
| TC_DQ_010 | Validate numeric fields contain valid values | All numeric fields contain non-negative values where applicable | bz_meetings, bz_feature_usage, bz_billing_events |

### 2. Referential Integrity Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) Tested |
|--------------|----------------------|------------------|------------------|
| TC_RI_001 | Validate HOST_ID in bz_meetings exists in bz_users | All HOST_ID values have corresponding USER_ID in bz_users | bz_meetings, bz_users |
| TC_RI_002 | Validate USER_ID in bz_participants exists in bz_users | All USER_ID values have corresponding records in bz_users | bz_participants, bz_users |
| TC_RI_003 | Validate MEETING_ID in bz_participants exists in bz_meetings | All MEETING_ID values have corresponding records in bz_meetings | bz_participants, bz_meetings |
| TC_RI_004 | Validate MEETING_ID in bz_feature_usage exists in bz_meetings | All MEETING_ID values have corresponding records in bz_meetings | bz_feature_usage, bz_meetings |
| TC_RI_005 | Validate USER_ID in bz_support_tickets exists in bz_users | All USER_ID values have corresponding records in bz_users | bz_support_tickets, bz_users |
| TC_RI_006 | Validate USER_ID in bz_billing_events exists in bz_users | All USER_ID values have corresponding records in bz_users | bz_billing_events, bz_users |
| TC_RI_007 | Validate ASSIGNED_TO_USER_ID in bz_licenses exists in bz_users | All ASSIGNED_TO_USER_ID values have corresponding records in bz_users | bz_licenses, bz_users |

### 3. Business Logic Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) Tested |
|--------------|----------------------|------------------|------------------|
| TC_BL_001 | Validate meeting duration calculation | DURATION_MINUTES = DATEDIFF(minutes, START_TIME, END_TIME) | bz_meetings |
| TC_BL_002 | Validate participant session duration | LEAVE_TIME >= JOIN_TIME for all participants | bz_participants |
| TC_BL_003 | Validate license validity period | END_DATE >= START_DATE for all licenses | bz_licenses |
| TC_BL_004 | Validate plan type values | PLAN_TYPE contains only valid values (Basic, Pro, Business, Enterprise) | bz_users |
| TC_BL_005 | Validate feature usage count | USAGE_COUNT >= 0 for all feature usage records | bz_feature_usage |
| TC_BL_006 | Validate billing event amounts | AMOUNT >= 0 for all billing events | bz_billing_events |
| TC_BL_007 | Validate support ticket status values | RESOLUTION_STATUS contains only valid status values | bz_support_tickets |

### 4. Audit Trail Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) Tested |
|--------------|----------------------|------------------|------------------|
| TC_AT_001 | Validate audit records are created for each model execution | Audit records exist for each Bronze model execution | bz_data_audit |
| TC_AT_002 | Validate audit timestamps are sequential | LOAD_TIMESTAMP follows chronological order | bz_data_audit |
| TC_AT_003 | Validate audit status values | STATUS contains only valid values (STARTED, COMPLETED, FAILED) | bz_data_audit |
| TC_AT_004 | Validate source system tracking | SOURCE_SYSTEM is populated for all records | All models |

### 5. Edge Case Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) Tested |
|--------------|----------------------|------------------|------------------|
| TC_EC_001 | Handle empty source tables | Models execute successfully with empty result sets | All models |
| TC_EC_002 | Handle null values in non-required fields | Null values are preserved in non-critical fields | All models |
| TC_EC_003 | Handle duplicate source records | Duplicates are handled according to business rules | All models |
| TC_EC_004 | Handle invalid date formats | Invalid dates are handled gracefully | All models |
| TC_EC_005 | Handle extremely long text fields | Text truncation follows defined limits | bz_users, bz_meetings |

---

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# tests/schema_tests.yml
version: 2

models:
  - name: bz_users
    tests:
      - dbt_utils.row_count:
          above: 0
    columns:
      - name: user_id
        tests:
          - unique
          - not_null
      - name: email
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
      - name: plan_type
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise']
      - name: load_timestamp
        tests:
          - not_null
      - name: source_system
        tests:
          - not_null

  - name: bz_meetings
    tests:
      - dbt_utils.row_count:
          above: 0
    columns:
      - name: meeting_id
        tests:
          - unique
          - not_null
      - name: host_id
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: start_time
        tests:
          - not_null
      - name: end_time
        tests:
          - not_null
      - name: duration_minutes
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440  # 24 hours max

  - name: bz_participants
    columns:
      - name: participant_id
        tests:
          - unique
          - not_null
      - name: meeting_id
        tests:
          - not_null
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
      - name: user_id
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: join_time
        tests:
          - not_null

  - name: bz_feature_usage
    columns:
      - name: usage_id
        tests:
          - unique
          - not_null
      - name: meeting_id
        tests:
          - not_null
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
      - name: usage_count
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0

  - name: bz_support_tickets
    columns:
      - name: ticket_id
        tests:
          - unique
          - not_null
      - name: user_id
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: resolution_status
        tests:
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed', 'Cancelled']

  - name: bz_billing_events
    columns:
      - name: event_id
        tests:
          - unique
          - not_null
      - name: user_id
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: amount
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0

  - name: bz_licenses
    columns:
      - name: license_id
        tests:
          - unique
          - not_null
      - name: assigned_to_user_id
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: start_date
        tests:
          - not_null
      - name: end_date
        tests:
          - not_null

  - name: bz_data_audit
    columns:
      - name: source_table
        tests:
          - not_null
      - name: load_timestamp
        tests:
          - not_null
      - name: status
        tests:
          - accepted_values:
              values: ['STARTED', 'COMPLETED', 'FAILED', 'WARNING']
```

### Custom SQL-based dbt Tests

#### Test 1: Meeting Duration Validation
```sql
-- tests/test_meeting_duration_logic.sql
-- Test that meeting duration matches the calculated difference between start and end times

SELECT 
    meeting_id,
    start_time,
    end_time,
    duration_minutes,
    DATEDIFF('minute', start_time, end_time) AS calculated_duration
FROM {{ ref('bz_meetings') }}
WHERE duration_minutes != DATEDIFF('minute', start_time, end_time)
   OR start_time >= end_time
```

#### Test 2: Participant Session Logic
```sql
-- tests/test_participant_session_logic.sql
-- Test that participant leave time is after join time

SELECT 
    participant_id,
    meeting_id,
    join_time,
    leave_time
FROM {{ ref('bz_participants') }}
WHERE leave_time IS NOT NULL 
  AND leave_time <= join_time
```

#### Test 3: License Validity Period
```sql
-- tests/test_license_validity_period.sql
-- Test that license end date is after start date

SELECT 
    license_id,
    start_date,
    end_date
FROM {{ ref('bz_licenses') }}
WHERE end_date <= start_date
```

#### Test 4: Audit Trail Completeness
```sql
-- tests/test_audit_trail_completeness.sql
-- Test that audit records exist for each model execution

WITH expected_tables AS (
    SELECT table_name FROM (
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
actual_audit_records AS (
    SELECT DISTINCT source_table
    FROM {{ ref('bz_data_audit') }}
    WHERE DATE(load_timestamp) = CURRENT_DATE()
)
SELECT et.table_name
FROM expected_tables et
LEFT JOIN actual_audit_records aar ON et.table_name = aar.source_table
WHERE aar.source_table IS NULL
```

#### Test 5: Data Freshness Validation
```sql
-- tests/test_data_freshness.sql
-- Test that data is loaded within acceptable time windows

SELECT 
    source_table,
    MAX(load_timestamp) AS latest_load,
    DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP()) AS hours_since_load
FROM {{ ref('bz_data_audit') }}
WHERE status = 'COMPLETED'
GROUP BY source_table
HAVING hours_since_load > 24  -- Alert if data is older than 24 hours
```

#### Test 6: Cross-Model Consistency
```sql
-- tests/test_cross_model_consistency.sql
-- Test consistency between related models

WITH meeting_participants AS (
    SELECT 
        m.meeting_id,
        m.host_id,
        COUNT(p.participant_id) AS participant_count
    FROM {{ ref('bz_meetings') }} m
    LEFT JOIN {{ ref('bz_participants') }} p ON m.meeting_id = p.meeting_id
    GROUP BY m.meeting_id, m.host_id
),
feature_usage_meetings AS (
    SELECT DISTINCT meeting_id
    FROM {{ ref('bz_feature_usage') }}
)
SELECT 
    fu.meeting_id
FROM feature_usage_meetings fu
LEFT JOIN meeting_participants mp ON fu.meeting_id = mp.meeting_id
WHERE mp.meeting_id IS NULL  -- Feature usage without corresponding meeting
```

#### Test 7: Data Volume Validation
```sql
-- tests/test_data_volume_validation.sql
-- Test for unexpected data volume changes

WITH daily_counts AS (
    SELECT 
        'bz_users' AS table_name,
        DATE(load_timestamp) AS load_date,
        COUNT(*) AS record_count
    FROM {{ ref('bz_users') }}
    GROUP BY DATE(load_timestamp)
    
    UNION ALL
    
    SELECT 
        'bz_meetings' AS table_name,
        DATE(load_timestamp) AS load_date,
        COUNT(*) AS record_count
    FROM {{ ref('bz_meetings') }}
    GROUP BY DATE(load_timestamp)
),
volume_changes AS (
    SELECT 
        table_name,
        load_date,
        record_count,
        LAG(record_count) OVER (PARTITION BY table_name ORDER BY load_date) AS prev_count,
        CASE 
            WHEN LAG(record_count) OVER (PARTITION BY table_name ORDER BY load_date) > 0
            THEN ABS(record_count - LAG(record_count) OVER (PARTITION BY table_name ORDER BY load_date)) * 100.0 / LAG(record_count) OVER (PARTITION BY table_name ORDER BY load_date)
            ELSE 0
        END AS percent_change
    FROM daily_counts
)
SELECT 
    table_name,
    load_date,
    record_count,
    prev_count,
    percent_change
FROM volume_changes
WHERE percent_change > 50  -- Alert if volume changes by more than 50%
  AND prev_count IS NOT NULL
```

### Parameterized Test Macros

#### Macro 1: Generic Primary Key Test
```sql
-- macros/test_primary_key_integrity.sql
{% macro test_primary_key_integrity(model, column_name) %}
    SELECT 
        {{ column_name }},
        COUNT(*) as duplicate_count
    FROM {{ model }}
    WHERE {{ column_name }} IS NOT NULL
    GROUP BY {{ column_name }}
    HAVING COUNT(*) > 1
{% endmacro %}
```

#### Macro 2: Generic Referential Integrity Test
```sql
-- macros/test_referential_integrity.sql
{% macro test_referential_integrity(child_model, child_column, parent_model, parent_column) %}
    SELECT 
        c.{{ child_column }}
    FROM {{ child_model }} c
    LEFT JOIN {{ parent_model }} p ON c.{{ child_column }} = p.{{ parent_column }}
    WHERE c.{{ child_column }} IS NOT NULL
      AND p.{{ parent_column }} IS NULL
{% endmacro %}
```

## Test Execution Strategy

### 1. Continuous Integration Tests
- Run on every dbt model change
- Execute basic data quality tests (unique, not_null)
- Validate referential integrity
- Check audit trail functionality

### 2. Daily Validation Tests
- Execute comprehensive business logic tests
- Validate data freshness and volume
- Check cross-model consistency
- Generate data quality reports

### 3. Weekly Deep Validation
- Execute performance benchmarks
- Validate historical data consistency
- Check for data drift and anomalies
- Review and update test thresholds

## Test Results Tracking

All test results are automatically tracked in:
- **dbt run_results.json**: Detailed execution logs and test outcomes
- **Snowflake audit schema**: Persistent storage of test results and metrics
- **Data quality dashboard**: Real-time monitoring of test status and trends

## Maintenance and Updates

- **Monthly Review**: Assess test coverage and effectiveness
- **Quarterly Updates**: Update test thresholds based on data patterns
- **Annual Audit**: Comprehensive review of testing strategy and framework

---

*This document serves as the comprehensive testing framework for the Zoom Platform Bronze Layer dbt models, ensuring data quality, reliability, and performance in the Snowflake environment.*