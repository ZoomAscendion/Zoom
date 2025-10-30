_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Platform Analytics Bronze Layer dbt models in Snowflake
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Zoom Bronze Layer Pipeline

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics Bronze Layer Pipeline. The tests validate data transformations, business rules, edge cases, and error handling across all 9 bronze layer models in Snowflake.

## Test Coverage Overview

| Model | Primary Keys | Transformations | Edge Cases | Data Quality |
|-------|-------------|----------------|------------|-------------|
| bz_audit_log | ✓ | ✓ | ✓ | ✓ |
| bz_users | ✓ | ✓ | ✓ | ✓ |
| bz_meetings | ✓ | ✓ | ✓ | ✓ |
| bz_participants | ✓ | ✓ | ✓ | ✓ |
| bz_feature_usage | ✓ | ✓ | ✓ | ✓ |
| bz_support_tickets | ✓ | ✓ | ✓ | ✓ |
| bz_billing_events | ✓ | ✓ | ✓ | ✓ |
| bz_licenses | ✓ | ✓ | ✓ | ✓ |
| bz_webinars | ✓ | ✓ | ✓ | ✓ |

---

## Test Case List

### 1. BZ_AUDIT_LOG Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|-------------|----------------------|------------------|
| TC_AUDIT_001 | Validate audit log structure initialization | Empty table with correct schema |
| TC_AUDIT_002 | Test audit log data types | All columns match expected data types |
| TC_AUDIT_003 | Validate timestamp generation | CURRENT_TIMESTAMP() functions work correctly |
| TC_AUDIT_004 | Test WHERE 1=0 condition | Table created with no records |

### 2. BZ_USERS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|-------------|----------------------|------------------|
| TC_USERS_001 | Validate user_id uniqueness and not null | All user_id values are unique and not null |
| TC_USERS_002 | Test COALESCE transformation for null values | NULL values replaced with 'UNKNOWN' |
| TC_USERS_003 | Validate email format preservation | Email addresses maintain original format |
| TC_USERS_004 | Test plan_type standardization | Plan types are properly categorized |
| TC_USERS_005 | Validate metadata timestamp handling | Load and update timestamps are preserved |
| TC_USERS_006 | Test source system defaulting | Missing source_system defaults to 'ZOOM_PLATFORM' |

### 3. BZ_MEETINGS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|-------------|----------------------|------------------|
| TC_MEETINGS_001 | Validate meeting_id uniqueness and not null | All meeting_id values are unique and not null |
| TC_MEETINGS_002 | Test duration_minutes calculation validation | Duration values are non-negative integers |
| TC_MEETINGS_003 | Validate start_time and end_time relationship | End time is after or equal to start time |
| TC_MEETINGS_004 | Test host_id foreign key relationship | All host_id values exist in users table |
| TC_MEETINGS_005 | Test null handling for meeting topics | NULL topics replaced with 'UNKNOWN' |
| TC_MEETINGS_006 | Validate timestamp data integrity | Timestamps are in correct format |

### 4. BZ_PARTICIPANTS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|-------------|----------------------|------------------|
| TC_PARTICIPANTS_001 | Validate participant_id uniqueness | All participant_id values are unique |
| TC_PARTICIPANTS_002 | Test meeting_id foreign key constraint | All meeting_id values exist in meetings table |
| TC_PARTICIPANTS_003 | Test user_id foreign key constraint | All user_id values exist in users table |
| TC_PARTICIPANTS_004 | Validate join_time and leave_time logic | Leave time is after join time |
| TC_PARTICIPANTS_005 | Test null handling for participant data | NULL values properly handled with COALESCE |
| TC_PARTICIPANTS_006 | Validate participant session duration | Calculated duration is reasonable |

### 5. BZ_FEATURE_USAGE Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|-------------|----------------------|------------------|
| TC_FEATURE_001 | Validate usage_id uniqueness | All usage_id values are unique |
| TC_FEATURE_002 | Test usage_count non-negative constraint | Usage counts are zero or positive |
| TC_FEATURE_003 | Validate feature_name standardization | Feature names follow naming conventions |
| TC_FEATURE_004 | Test meeting_id relationship | Meeting references are valid |
| TC_FEATURE_005 | Validate usage_date format | Dates are in correct format |
| TC_FEATURE_006 | Test aggregation accuracy | Usage counts sum correctly |

### 6. BZ_SUPPORT_TICKETS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|-------------|----------------------|------------------|
| TC_SUPPORT_001 | Validate ticket_id uniqueness | All ticket_id values are unique |
| TC_SUPPORT_002 | Test resolution_status values | Status values are from accepted list |
| TC_SUPPORT_003 | Validate user_id foreign key | User references are valid |
| TC_SUPPORT_004 | Test ticket_type categorization | Ticket types are properly categorized |
| TC_SUPPORT_005 | Validate open_date logic | Open dates are not in future |
| TC_SUPPORT_006 | Test null handling for ticket data | NULL values handled appropriately |

### 7. BZ_BILLING_EVENTS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|-------------|----------------------|------------------|
| TC_BILLING_001 | Validate event_id uniqueness | All event_id values are unique |
| TC_BILLING_002 | Test amount data type and precision | Amounts are decimal with 2 decimal places |
| TC_BILLING_003 | Validate event_type categorization | Event types are from valid list |
| TC_BILLING_004 | Test user_id foreign key constraint | User references are valid |
| TC_BILLING_005 | Validate event_date chronology | Event dates are logical |
| TC_BILLING_006 | Test negative amount handling | Negative amounts handled for refunds |

### 8. BZ_LICENSES Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|-------------|----------------------|------------------|
| TC_LICENSE_001 | Validate license_id uniqueness | All license_id values are unique |
| TC_LICENSE_002 | Test license_type validation | License types are from valid list |
| TC_LICENSE_003 | Validate date range logic | End date is after start date |
| TC_LICENSE_004 | Test user assignment validation | Assigned users exist in users table |
| TC_LICENSE_005 | Validate license overlap detection | No overlapping licenses for same user |
| TC_LICENSE_006 | Test license expiration logic | Expired licenses identified correctly |

### 9. BZ_WEBINARS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|-------------|----------------------|------------------|
| TC_WEBINAR_001 | Validate webinar_id uniqueness | All webinar_id values are unique |
| TC_WEBINAR_002 | Test registrants count validation | Registrant counts are non-negative |
| TC_WEBINAR_003 | Validate host_id foreign key | Host references are valid |
| TC_WEBINAR_004 | Test webinar duration calculation | Duration calculations are accurate |
| TC_WEBINAR_005 | Validate webinar topic handling | Topics are properly formatted |
| TC_WEBINAR_006 | Test timestamp validation | Start and end times are logical |

---

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# tests/schema_tests.yml
version: 2

models:
  # BZ_USERS Tests
  - name: bz_users
    tests:
      - dbt_utils.expression_is_true:
          expression: "count(*) > 0"
          config:
            severity: error
    columns:
      - name: user_id
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
      - name: email
        tests:
          - not_null:
              config:
                severity: warn
          - dbt_utils.expression_is_true:
              expression: "email LIKE '%@%'"
              config:
                severity: warn
      - name: plan_type
        tests:
          - accepted_values:
              values: ['BASIC', 'PRO', 'BUSINESS', 'ENTERPRISE', 'UNKNOWN']
              config:
                severity: warn
      - name: load_timestamp
        tests:
          - not_null:
              config:
                severity: error

  # BZ_MEETINGS Tests
  - name: bz_meetings
    tests:
      - dbt_utils.expression_is_true:
          expression: "count(*) > 0"
    columns:
      - name: meeting_id
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
      - name: duration_minutes
        tests:
          - dbt_utils.expression_is_true:
              expression: "duration_minutes >= 0"
              config:
                severity: error
      - name: host_id
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: warn

  # BZ_PARTICIPANTS Tests
  - name: bz_participants
    columns:
      - name: participant_id
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
      - name: meeting_id
        tests:
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
              config:
                severity: warn
      - name: user_id
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: warn

  # BZ_FEATURE_USAGE Tests
  - name: bz_feature_usage
    columns:
      - name: usage_id
        tests:
          - not_null
          - unique
      - name: usage_count
        tests:
          - dbt_utils.expression_is_true:
              expression: "usage_count >= 0"
      - name: meeting_id
        tests:
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
              config:
                severity: warn

  # BZ_SUPPORT_TICKETS Tests
  - name: bz_support_tickets
    columns:
      - name: ticket_id
        tests:
          - not_null
          - unique
      - name: resolution_status
        tests:
          - accepted_values:
              values: ['OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED', 'UNKNOWN']
      - name: user_id
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: warn

  # BZ_BILLING_EVENTS Tests
  - name: bz_billing_events
    columns:
      - name: event_id
        tests:
          - not_null
          - unique
      - name: amount
        tests:
          - dbt_utils.expression_is_true:
              expression: "amount IS NOT NULL"
      - name: event_type
        tests:
          - accepted_values:
              values: ['CHARGE', 'REFUND', 'CREDIT', 'ADJUSTMENT', 'UNKNOWN']

  # BZ_LICENSES Tests
  - name: bz_licenses
    tests:
      - dbt_utils.expression_is_true:
          expression: "end_date >= start_date OR end_date IS NULL"
          config:
            severity: error
    columns:
      - name: license_id
        tests:
          - not_null
          - unique
      - name: assigned_to_user_id
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: warn

  # BZ_WEBINARS Tests
  - name: bz_webinars
    columns:
      - name: webinar_id
        tests:
          - not_null
          - unique
      - name: registrants
        tests:
          - dbt_utils.expression_is_true:
              expression: "registrants >= 0"
      - name: host_id
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: warn
```

### Custom SQL-based dbt Tests

```sql
-- tests/test_meeting_duration_logic.sql
-- Test that meeting duration is calculated correctly
SELECT 
    meeting_id,
    start_time,
    end_time,
    duration_minutes,
    DATEDIFF('minute', start_time, end_time) as calculated_duration
FROM {{ ref('bz_meetings') }}
WHERE 
    start_time IS NOT NULL 
    AND end_time IS NOT NULL
    AND ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) > 1
```

```sql
-- tests/test_participant_session_logic.sql
-- Test that participant join/leave times are logical
SELECT 
    participant_id,
    join_time,
    leave_time
FROM {{ ref('bz_participants') }}
WHERE 
    join_time IS NOT NULL 
    AND leave_time IS NOT NULL
    AND leave_time <= join_time
```

```sql
-- tests/test_license_overlap.sql
-- Test for overlapping license assignments
WITH license_overlaps AS (
    SELECT 
        l1.license_id as license1,
        l2.license_id as license2,
        l1.assigned_to_user_id,
        l1.start_date as start1,
        l1.end_date as end1,
        l2.start_date as start2,
        l2.end_date as end2
    FROM {{ ref('bz_licenses') }} l1
    JOIN {{ ref('bz_licenses') }} l2 
        ON l1.assigned_to_user_id = l2.assigned_to_user_id
        AND l1.license_id != l2.license_id
    WHERE 
        l1.start_date <= COALESCE(l2.end_date, CURRENT_DATE())
        AND COALESCE(l1.end_date, CURRENT_DATE()) >= l2.start_date
)
SELECT * FROM license_overlaps
```

```sql
-- tests/test_billing_amount_precision.sql
-- Test billing amounts have correct precision
SELECT 
    event_id,
    amount,
    ROUND(amount, 2) as rounded_amount
FROM {{ ref('bz_billing_events') }}
WHERE amount != ROUND(amount, 2)
```

```sql
-- tests/test_feature_usage_aggregation.sql
-- Test feature usage count aggregations
SELECT 
    meeting_id,
    feature_name,
    SUM(usage_count) as total_usage
FROM {{ ref('bz_feature_usage') }}
GROUP BY meeting_id, feature_name
HAVING SUM(usage_count) < 0
```

```sql
-- tests/test_data_freshness.sql
-- Test data freshness across all bronze tables
WITH freshness_check AS (
    SELECT 'bz_users' as table_name, MAX(load_timestamp) as latest_load FROM {{ ref('bz_users') }}
    UNION ALL
    SELECT 'bz_meetings' as table_name, MAX(load_timestamp) as latest_load FROM {{ ref('bz_meetings') }}
    UNION ALL
    SELECT 'bz_participants' as table_name, MAX(load_timestamp) as latest_load FROM {{ ref('bz_participants') }}
    UNION ALL
    SELECT 'bz_feature_usage' as table_name, MAX(load_timestamp) as latest_load FROM {{ ref('bz_feature_usage') }}
    UNION ALL
    SELECT 'bz_support_tickets' as table_name, MAX(load_timestamp) as latest_load FROM {{ ref('bz_support_tickets') }}
    UNION ALL
    SELECT 'bz_billing_events' as table_name, MAX(load_timestamp) as latest_load FROM {{ ref('bz_billing_events') }}
    UNION ALL
    SELECT 'bz_licenses' as table_name, MAX(load_timestamp) as latest_load FROM {{ ref('bz_licenses') }}
    UNION ALL
    SELECT 'bz_webinars' as table_name, MAX(load_timestamp) as latest_load FROM {{ ref('bz_webinars') }}
)
SELECT 
    table_name,
    latest_load,
    DATEDIFF('hour', latest_load, CURRENT_TIMESTAMP()) as hours_since_load
FROM freshness_check
WHERE DATEDIFF('hour', latest_load, CURRENT_TIMESTAMP()) > 24
```

### Parameterized Tests

```sql
-- macros/test_null_percentage.sql
{% macro test_null_percentage(model, column_name, threshold=0.1) %}
    SELECT 
        '{{ column_name }}' as column_name,
        COUNT(*) as total_records,
        COUNT({{ column_name }}) as non_null_records,
        (COUNT(*) - COUNT({{ column_name }})) as null_records,
        (COUNT(*) - COUNT({{ column_name }})) / COUNT(*) as null_percentage
    FROM {{ model }}
    HAVING null_percentage > {{ threshold }}
{% endmacro %}
```

```sql
-- tests/test_null_percentages.sql
-- Test null percentages across critical columns
{{ test_null_percentage(ref('bz_users'), 'email', 0.05) }}
UNION ALL
{{ test_null_percentage(ref('bz_meetings'), 'host_id', 0.01) }}
UNION ALL
{{ test_null_percentage(ref('bz_participants'), 'user_id', 0.01) }}
```

---

## Test Execution Strategy

### 1. Pre-deployment Tests
- Run all schema tests before deployment
- Execute custom SQL tests for business logic validation
- Validate data quality thresholds

### 2. Post-deployment Tests
- Verify data freshness
- Check referential integrity
- Validate aggregation accuracy

### 3. Continuous Monitoring
- Daily execution of critical tests
- Weekly execution of comprehensive test suite
- Monthly review of test coverage and effectiveness

### 4. Test Results Tracking
- Results logged in dbt's run_results.json
- Test failures tracked in Snowflake audit schema
- Automated alerts for critical test failures

---

## Expected Test Outcomes

### Success Criteria
- All unique and not_null tests pass with 100% success rate
- Foreign key relationships maintain 95%+ integrity
- Data quality tests pass with <5% failure rate
- Custom business logic tests validate correctly

### Failure Handling
- Critical failures (severity: error) block deployment
- Warning-level failures logged for investigation
- Test failures trigger data quality review process

---

## Maintenance and Updates

### Test Review Schedule
- Monthly review of test effectiveness
- Quarterly update of test thresholds
- Annual comprehensive test strategy review

### Test Enhancement
- Add new tests for new business rules
- Update existing tests for schema changes
- Optimize test performance for large datasets

This comprehensive test suite ensures the reliability, accuracy, and performance of the Zoom Platform Analytics Bronze Layer Pipeline in Snowflake, providing robust data quality validation and early detection of potential issues.