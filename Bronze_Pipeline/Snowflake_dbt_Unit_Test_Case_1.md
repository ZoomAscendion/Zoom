_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Bronze Pipeline dbt models in Snowflake
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Zoom Bronze Pipeline

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Bronze Pipeline dbt models that run in Snowflake. The test cases cover key transformations, business rules, edge cases, and error handling scenarios to ensure data quality and pipeline reliability.

## Models Under Test

1. **bz_data_audit** - Audit table for tracking Bronze layer operations
2. **bz_users** - User profile and subscription information
3. **bz_meetings** - Meeting information and session details
4. **bz_participants** - Meeting participants and session tracking
5. **bz_feature_usage** - Platform feature usage during meetings
6. **bz_support_tickets** - Customer support requests and resolution tracking
7. **bz_billing_events** - Financial transactions and billing activities
8. **bz_licenses** - License assignments and entitlements

## Test Case Categories

### 1. Data Quality Tests
### 2. Business Logic Tests
### 3. Edge Case Tests
### 4. Performance Tests
### 5. Integration Tests

---

## Test Case List

| Test Case ID | Model | Test Case Description | Test Type | Expected Outcome |
|--------------|-------|----------------------|-----------|------------------|
| TC_BZ_001 | bz_users | Validate user_id uniqueness and not null | Data Quality | All user_id values are unique and not null |
| TC_BZ_002 | bz_users | Validate email format | Data Quality | All email addresses follow valid format |
| TC_BZ_003 | bz_users | Validate deduplication logic | Business Logic | Only latest record per user_id is retained |
| TC_BZ_004 | bz_users | Handle null primary keys | Edge Case | Records with null user_id are filtered out |
| TC_BZ_005 | bz_users | Validate plan_type values | Data Quality | Plan types are within accepted values |
| TC_BZ_006 | bz_meetings | Validate meeting_id uniqueness | Data Quality | All meeting_id values are unique and not null |
| TC_BZ_007 | bz_meetings | Validate meeting duration calculation | Business Logic | Duration matches end_time - start_time |
| TC_BZ_008 | bz_meetings | Validate host_id references | Integration | All host_id values exist in bz_users |
| TC_BZ_009 | bz_meetings | Handle invalid time ranges | Edge Case | End_time should be after start_time |
| TC_BZ_010 | bz_meetings | Validate deduplication by update_timestamp | Business Logic | Latest meeting record is retained |
| TC_BZ_011 | bz_participants | Validate participant_id uniqueness | Data Quality | All participant_id values are unique |
| TC_BZ_012 | bz_participants | Validate meeting and user references | Integration | meeting_id and user_id exist in respective tables |
| TC_BZ_013 | bz_participants | Validate join/leave time logic | Business Logic | Leave_time should be after join_time |
| TC_BZ_014 | bz_participants | Handle orphaned participant records | Edge Case | Participants without valid meeting_id |
| TC_BZ_015 | bz_feature_usage | Validate usage_id uniqueness | Data Quality | All usage_id values are unique |
| TC_BZ_016 | bz_feature_usage | Validate usage_count is positive | Business Logic | Usage count should be greater than 0 |
| TC_BZ_017 | bz_feature_usage | Validate feature_name standardization | Data Quality | Feature names follow naming conventions |
| TC_BZ_018 | bz_feature_usage | Validate meeting_id references | Integration | All meeting_id values exist in bz_meetings |
| TC_BZ_019 | bz_support_tickets | Validate ticket_id uniqueness | Data Quality | All ticket_id values are unique |
| TC_BZ_020 | bz_support_tickets | Validate resolution_status values | Data Quality | Status values are within accepted list |
| TC_BZ_021 | bz_support_tickets | Validate user_id references | Integration | All user_id values exist in bz_users |
| TC_BZ_022 | bz_support_tickets | Validate ticket_type categorization | Business Logic | Ticket types are properly categorized |
| TC_BZ_023 | bz_billing_events | Validate event_id uniqueness | Data Quality | All event_id values are unique |
| TC_BZ_024 | bz_billing_events | Validate amount is non-negative | Business Logic | Amount values are >= 0 |
| TC_BZ_025 | bz_billing_events | Validate event_type values | Data Quality | Event types are within accepted values |
| TC_BZ_026 | bz_billing_events | Validate user_id references | Integration | All user_id values exist in bz_users |
| TC_BZ_027 | bz_licenses | Validate license_id uniqueness | Data Quality | All license_id values are unique |
| TC_BZ_028 | bz_licenses | Validate date range logic | Business Logic | End_date should be after start_date |
| TC_BZ_029 | bz_licenses | Validate user assignment | Integration | assigned_to_user_id exists in bz_users |
| TC_BZ_030 | bz_licenses | Handle expired licenses | Edge Case | Licenses with end_date in past |
| TC_BZ_031 | bz_data_audit | Validate audit trail completeness | Business Logic | All operations are logged |
| TC_BZ_032 | bz_data_audit | Validate processing time calculation | Business Logic | Processing time is calculated correctly |
| TC_BZ_033 | All Models | Validate source_system consistency | Data Quality | Source system values are consistent |
| TC_BZ_034 | All Models | Validate load_timestamp format | Data Quality | Timestamps are in correct format |
| TC_BZ_035 | All Models | Performance test for large datasets | Performance | Models process 1M+ records efficiently |

---

## dbt Test Scripts

### Schema Tests (schema.yml)

```yaml
# tests/schema.yml
version: 2

models:
  - name: bz_users
    description: "Bronze layer users table"
    columns:
      - name: user_id
        description: "Unique user identifier"
        tests:
          - not_null:
              severity: error
          - unique:
              severity: error
      - name: email
        description: "User email address"
        tests:
          - not_null:
              severity: warn
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
              severity: error
      - name: plan_type
        description: "Subscription plan type"
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise']
              severity: error
      - name: load_timestamp
        description: "Record load timestamp"
        tests:
          - not_null:
              severity: error

  - name: bz_meetings
    description: "Bronze layer meetings table"
    columns:
      - name: meeting_id
        description: "Unique meeting identifier"
        tests:
          - not_null:
              severity: error
          - unique:
              severity: error
      - name: host_id
        description: "Meeting host user ID"
        tests:
          - not_null:
              severity: error
          - relationships:
              to: ref('bz_users')
              field: user_id
              severity: error
      - name: duration_minutes
        description: "Meeting duration in minutes"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440  # 24 hours
              severity: warn
      - name: start_time
        description: "Meeting start time"
        tests:
          - not_null:
              severity: error

  - name: bz_participants
    description: "Bronze layer participants table"
    columns:
      - name: participant_id
        description: "Unique participant identifier"
        tests:
          - not_null:
              severity: error
          - unique:
              severity: error
      - name: meeting_id
        description: "Reference to meeting"
        tests:
          - not_null:
              severity: error
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
              severity: error
      - name: user_id
        description: "Reference to user"
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
              severity: warn
      - name: join_time
        description: "Participant join time"
        tests:
          - not_null:
              severity: error

  - name: bz_feature_usage
    description: "Bronze layer feature usage table"
    columns:
      - name: usage_id
        description: "Unique usage identifier"
        tests:
          - not_null:
              severity: error
          - unique:
              severity: error
      - name: meeting_id
        description: "Reference to meeting"
        tests:
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
              severity: error
      - name: usage_count
        description: "Feature usage count"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 1
              severity: error
      - name: feature_name
        description: "Name of the feature"
        tests:
          - not_null:
              severity: error
          - accepted_values:
              values: ['screen_share', 'chat', 'recording', 'breakout_rooms', 'whiteboard', 'polls']
              severity: warn

  - name: bz_support_tickets
    description: "Bronze layer support tickets table"
    columns:
      - name: ticket_id
        description: "Unique ticket identifier"
        tests:
          - not_null:
              severity: error
          - unique:
              severity: error
      - name: user_id
        description: "Reference to user"
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
              severity: error
      - name: resolution_status
        description: "Ticket resolution status"
        tests:
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed', 'Escalated']
              severity: error
      - name: ticket_type
        description: "Type of support ticket"
        tests:
          - accepted_values:
              values: ['Technical', 'Billing', 'Account', 'Feature Request', 'Bug Report']
              severity: error

  - name: bz_billing_events
    description: "Bronze layer billing events table"
    columns:
      - name: event_id
        description: "Unique event identifier"
        tests:
          - not_null:
              severity: error
          - unique:
              severity: error
      - name: user_id
        description: "Reference to user"
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
              severity: error
      - name: amount
        description: "Billing amount"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              severity: error
      - name: event_type
        description: "Type of billing event"
        tests:
          - accepted_values:
              values: ['Payment', 'Refund', 'Subscription', 'Upgrade', 'Downgrade', 'Cancellation']
              severity: error

  - name: bz_licenses
    description: "Bronze layer licenses table"
    columns:
      - name: license_id
        description: "Unique license identifier"
        tests:
          - not_null:
              severity: error
          - unique:
              severity: error
      - name: assigned_to_user_id
        description: "User assigned to license"
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
              severity: error
      - name: license_type
        description: "Type of license"
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise', 'Developer']
              severity: error
      - name: start_date
        description: "License start date"
        tests:
          - not_null:
              severity: error

  - name: bz_data_audit
    description: "Bronze layer audit table"
    columns:
      - name: source_table
        description: "Source table name"
        tests:
          - not_null:
              severity: error
      - name: load_timestamp
        description: "Load timestamp"
        tests:
          - not_null:
              severity: error
      - name: status
        description: "Operation status"
        tests:
          - accepted_values:
              values: ['STARTED', 'SUCCESS', 'FAILED', 'WARNING']
              severity: error
```

### Custom SQL Tests

#### 1. Meeting Duration Validation Test

```sql
-- tests/assert_meeting_duration_consistency.sql
-- Test to ensure meeting duration matches calculated time difference

SELECT 
    meeting_id,
    duration_minutes,
    DATEDIFF('minutes', start_time, end_time) as calculated_duration
FROM {{ ref('bz_meetings') }}
WHERE 
    start_time IS NOT NULL 
    AND end_time IS NOT NULL
    AND ABS(duration_minutes - DATEDIFF('minutes', start_time, end_time)) > 1
```

#### 2. Participant Session Validation Test

```sql
-- tests/assert_participant_session_logic.sql
-- Test to ensure participant leave time is after join time

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

#### 3. License Date Range Validation Test

```sql
-- tests/assert_license_date_range.sql
-- Test to ensure license end date is after start date

SELECT 
    license_id,
    start_date,
    end_date
FROM {{ ref('bz_licenses') }}
WHERE 
    start_date IS NOT NULL 
    AND end_date IS NOT NULL
    AND end_date <= start_date
```

#### 4. Deduplication Effectiveness Test

```sql
-- tests/assert_no_duplicates_users.sql
-- Test to ensure no duplicate user records exist

SELECT 
    user_id,
    COUNT(*) as record_count
FROM {{ ref('bz_users') }}
GROUP BY user_id
HAVING COUNT(*) > 1
```

#### 5. Audit Trail Completeness Test

```sql
-- tests/assert_audit_trail_completeness.sql
-- Test to ensure all Bronze operations are logged in audit table

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
logged_tables AS (
    SELECT DISTINCT source_table
    FROM {{ ref('bz_data_audit') }}
    WHERE status = 'SUCCESS'
)
SELECT 
    e.table_name
FROM expected_tables e
LEFT JOIN logged_tables l ON e.table_name = l.source_table
WHERE l.source_table IS NULL
```

#### 6. Data Freshness Test

```sql
-- tests/assert_data_freshness.sql
-- Test to ensure data is loaded within acceptable timeframe

SELECT 
    source_table,
    MAX(load_timestamp) as latest_load,
    DATEDIFF('hours', MAX(load_timestamp), CURRENT_TIMESTAMP()) as hours_since_load
FROM {{ ref('bz_data_audit') }}
WHERE status = 'SUCCESS'
GROUP BY source_table
HAVING DATEDIFF('hours', MAX(load_timestamp), CURRENT_TIMESTAMP()) > 24
```

#### 7. Source System Consistency Test

```sql
-- tests/assert_source_system_consistency.sql
-- Test to ensure source_system values are consistent across all tables

WITH source_systems AS (
    SELECT DISTINCT source_system FROM {{ ref('bz_users') }}
    UNION
    SELECT DISTINCT source_system FROM {{ ref('bz_meetings') }}
    UNION
    SELECT DISTINCT source_system FROM {{ ref('bz_participants') }}
    UNION
    SELECT DISTINCT source_system FROM {{ ref('bz_feature_usage') }}
    UNION
    SELECT DISTINCT source_system FROM {{ ref('bz_support_tickets') }}
    UNION
    SELECT DISTINCT source_system FROM {{ ref('bz_billing_events') }}
    UNION
    SELECT DISTINCT source_system FROM {{ ref('bz_licenses') }}
)
SELECT 
    source_system,
    COUNT(*) as occurrence_count
FROM source_systems
WHERE source_system NOT IN ('ZOOM_API', 'ZOOM_WEBHOOK', 'ZOOM_BATCH')
GROUP BY source_system
```

#### 8. Performance Test for Large Datasets

```sql
-- tests/assert_performance_large_dataset.sql
-- Test to ensure models can handle large datasets efficiently

SELECT 
    'bz_users' as model_name,
    COUNT(*) as record_count
FROM {{ ref('bz_users') }}
WHERE COUNT(*) > 10000000  -- Alert if more than 10M records

UNION ALL

SELECT 
    'bz_meetings' as model_name,
    COUNT(*) as record_count
FROM {{ ref('bz_meetings') }}
WHERE COUNT(*) > 50000000  -- Alert if more than 50M records
```

### Macro for Reusable Tests

```sql
-- macros/test_column_not_empty_string.sql
-- Macro to test that string columns are not empty

{% macro test_column_not_empty_string(model, column_name) %}

SELECT *
FROM {{ model }}
WHERE {{ column_name }} IS NOT NULL 
  AND TRIM({{ column_name }}) = ''

{% endmacro %}
```

### Test Configuration in dbt_project.yml

```yaml
# dbt_project.yml - Test configurations
tests:
  zoom_bronze_pipeline:
    +severity: error
    +store_failures: true
    +schema: test_results
    
    # Custom test configurations
    assert_meeting_duration_consistency:
      +severity: error
      +tags: ["business_logic", "meetings"]
    
    assert_participant_session_logic:
      +severity: error
      +tags: ["business_logic", "participants"]
    
    assert_license_date_range:
      +severity: warn
      +tags: ["business_logic", "licenses"]
    
    assert_data_freshness:
      +severity: warn
      +tags: ["data_quality", "monitoring"]
```

## Test Execution Strategy

### 1. Pre-deployment Tests
- Run all data quality tests (uniqueness, not_null, accepted_values)
- Execute business logic validation tests
- Verify referential integrity tests

### 2. Post-deployment Tests
- Run audit trail completeness tests
- Execute data freshness tests
- Perform performance validation tests

### 3. Continuous Monitoring Tests
- Schedule daily data quality checks
- Monitor audit trail for failed operations
- Track processing times and performance metrics

### 4. Test Commands

```bash
# Run all tests
dbt test

# Run tests for specific model
dbt test --models bz_users

# Run tests by tag
dbt test --select tag:business_logic

# Run tests with specific severity
dbt test --severity error

# Run tests and store failures
dbt test --store-failures
```

## Expected Test Results

### Success Criteria
- All uniqueness and not_null tests pass with 100% success rate
- Business logic tests pass with 95%+ success rate
- Referential integrity tests pass with 98%+ success rate
- Performance tests complete within acceptable time limits

### Failure Handling
- **Error Severity**: Stop pipeline execution, alert data engineering team
- **Warn Severity**: Log warning, continue execution, notify stakeholders
- **Store Failures**: Capture failed records for analysis and remediation

### Monitoring and Alerting
- Set up automated alerts for test failures
- Create dashboards for test result monitoring
- Implement escalation procedures for critical failures

## Maintenance and Updates

### Regular Review Schedule
- Weekly review of test results and failure patterns
- Monthly assessment of test coverage and effectiveness
- Quarterly update of test cases based on business requirements

### Test Case Evolution
- Add new tests for emerging data quality issues
- Update accepted values based on business changes
- Enhance performance tests as data volume grows

---

**Note**: This comprehensive test suite ensures the reliability, performance, and data quality of the Zoom Bronze Pipeline dbt models in Snowflake. Regular execution and monitoring of these tests will help maintain high-quality data transformations and catch issues early in the development cycle.