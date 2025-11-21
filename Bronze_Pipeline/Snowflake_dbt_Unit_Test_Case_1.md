_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Bronze Layer dbt models in Snowflake
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Zoom Bronze Layer Pipeline

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Bronze Layer dbt models running in Snowflake. The test cases cover data transformations, business rules, edge cases, and error handling scenarios to ensure data quality and pipeline reliability.

## Models Under Test

1. **bz_data_audit** - Audit trail for Bronze layer operations
2. **bz_users** - User profile and subscription information
3. **bz_meetings** - Meeting information and session details
4. **bz_participants** - Meeting participants and session tracking
5. **bz_feature_usage** - Platform feature usage during meetings
6. **bz_support_tickets** - Customer support requests and resolution
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
| TC_BZ_001 | bz_users | Validate USER_ID uniqueness and not null | Data Quality | All USER_ID values are unique and not null |
| TC_BZ_002 | bz_users | Validate email format | Data Quality | All email addresses follow valid format |
| TC_BZ_003 | bz_users | Validate deduplication logic | Business Logic | Only latest record per USER_ID is retained |
| TC_BZ_004 | bz_users | Validate timestamp overwrite | Business Logic | LOAD_TIMESTAMP and UPDATE_TIMESTAMP are current |
| TC_BZ_005 | bz_users | Handle null primary keys | Edge Case | Records with null USER_ID are excluded |
| TC_BZ_006 | bz_meetings | Validate MEETING_ID uniqueness | Data Quality | All MEETING_ID values are unique and not null |
| TC_BZ_007 | bz_meetings | Validate meeting duration logic | Business Logic | DURATION_MINUTES matches END_TIME - START_TIME |
| TC_BZ_008 | bz_meetings | Validate host_id references | Data Quality | All HOST_ID values exist in bz_users |
| TC_BZ_009 | bz_meetings | Handle invalid time ranges | Edge Case | END_TIME should be after START_TIME |
| TC_BZ_010 | bz_meetings | Validate deduplication | Business Logic | Latest meeting record per MEETING_ID |
| TC_BZ_011 | bz_participants | Validate PARTICIPANT_ID uniqueness | Data Quality | All PARTICIPANT_ID values are unique |
| TC_BZ_012 | bz_participants | Validate foreign key relationships | Data Quality | MEETING_ID and USER_ID exist in respective tables |
| TC_BZ_013 | bz_participants | Validate join/leave time logic | Business Logic | LEAVE_TIME should be after JOIN_TIME |
| TC_BZ_014 | bz_participants | Handle orphaned participants | Edge Case | Participants without valid meeting/user references |
| TC_BZ_015 | bz_feature_usage | Validate USAGE_ID uniqueness | Data Quality | All USAGE_ID values are unique |
| TC_BZ_016 | bz_feature_usage | Validate usage count ranges | Business Logic | USAGE_COUNT should be positive integers |
| TC_BZ_017 | bz_feature_usage | Validate feature name values | Data Quality | FEATURE_NAME contains only valid feature types |
| TC_BZ_018 | bz_support_tickets | Validate TICKET_ID uniqueness | Data Quality | All TICKET_ID values are unique |
| TC_BZ_019 | bz_support_tickets | Validate resolution status values | Data Quality | RESOLUTION_STATUS contains only valid statuses |
| TC_BZ_020 | bz_support_tickets | Validate user references | Data Quality | All USER_ID values exist in bz_users |
| TC_BZ_021 | bz_billing_events | Validate EVENT_ID uniqueness | Data Quality | All EVENT_ID values are unique |
| TC_BZ_022 | bz_billing_events | Validate amount precision | Data Quality | AMOUNT has correct decimal precision (10,2) |
| TC_BZ_023 | bz_billing_events | Validate positive amounts | Business Logic | AMOUNT should be positive for charges |
| TC_BZ_024 | bz_licenses | Validate LICENSE_ID uniqueness | Data Quality | All LICENSE_ID values are unique |
| TC_BZ_025 | bz_licenses | Validate date ranges | Business Logic | END_DATE should be after START_DATE |
| TC_BZ_026 | bz_licenses | Validate user assignments | Data Quality | ASSIGNED_TO_USER_ID exists in bz_users |
| TC_BZ_027 | bz_data_audit | Validate audit trail completeness | Integration | All model executions are logged |
| TC_BZ_028 | All Models | Validate source system tracking | Data Quality | SOURCE_SYSTEM is populated for all records |
| TC_BZ_029 | All Models | Validate row count consistency | Performance | Bronze layer has expected row counts |
| TC_BZ_030 | All Models | Validate processing time tracking | Performance | Audit logs show reasonable processing times |

---

## dbt Test Scripts

### Schema Tests (schema.yml)

```yaml
version: 2

models:
  # BZ_USERS Tests
  - name: bz_users
    description: "Bronze layer users with comprehensive data quality tests"
    tests:
      - dbt_utils.row_count:
          above: 0
    columns:
      - name: user_id
        description: "Unique user identifier"
        tests:
          - not_null
          - unique
      - name: email
        description: "User email address"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
      - name: plan_type
        description: "Subscription plan type"
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise', 'Free']
      - name: load_timestamp
        description: "Bronze layer load timestamp"
        tests:
          - not_null
      - name: source_system
        description: "Source system identifier"
        tests:
          - not_null

  # BZ_MEETINGS Tests
  - name: bz_meetings
    description: "Bronze layer meetings with validation tests"
    tests:
      - dbt_utils.row_count:
          above: 0
    columns:
      - name: meeting_id
        description: "Unique meeting identifier"
        tests:
          - not_null
          - unique
      - name: host_id
        description: "Meeting host user ID"
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: start_time
        description: "Meeting start time"
        tests:
          - not_null
      - name: end_time
        description: "Meeting end time"
        tests:
          - not_null
      - name: duration_minutes
        description: "Meeting duration"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440  # 24 hours max

  # BZ_PARTICIPANTS Tests
  - name: bz_participants
    description: "Bronze layer participants with referential integrity"
    columns:
      - name: participant_id
        description: "Unique participant identifier"
        tests:
          - not_null
          - unique
      - name: meeting_id
        description: "Reference to meeting"
        tests:
          - not_null
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
      - name: user_id
        description: "Reference to user"
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: join_time
        description: "Participant join time"
        tests:
          - not_null

  # BZ_FEATURE_USAGE Tests
  - name: bz_feature_usage
    description: "Bronze layer feature usage tracking"
    columns:
      - name: usage_id
        description: "Unique usage identifier"
        tests:
          - not_null
          - unique
      - name: meeting_id
        description: "Reference to meeting"
        tests:
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
      - name: feature_name
        description: "Feature name"
        tests:
          - not_null
          - accepted_values:
              values: ['Screen Share', 'Chat', 'Recording', 'Breakout Rooms', 'Whiteboard', 'Polls', 'Reactions']
      - name: usage_count
        description: "Usage count"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10000

  # BZ_SUPPORT_TICKETS Tests
  - name: bz_support_tickets
    description: "Bronze layer support tickets"
    columns:
      - name: ticket_id
        description: "Unique ticket identifier"
        tests:
          - not_null
          - unique
      - name: user_id
        description: "Reference to user"
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: ticket_type
        description: "Type of support ticket"
        tests:
          - not_null
          - accepted_values:
              values: ['Technical', 'Billing', 'Account', 'Feature Request', 'Bug Report']
      - name: resolution_status
        description: "Ticket resolution status"
        tests:
          - not_null
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed', 'Escalated']

  # BZ_BILLING_EVENTS Tests
  - name: bz_billing_events
    description: "Bronze layer billing events"
    columns:
      - name: event_id
        description: "Unique event identifier"
        tests:
          - not_null
          - unique
      - name: user_id
        description: "Reference to user"
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: event_type
        description: "Type of billing event"
        tests:
          - not_null
          - accepted_values:
              values: ['Charge', 'Refund', 'Credit', 'Subscription', 'Upgrade', 'Downgrade']
      - name: amount
        description: "Billing amount"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: -10000.00
              max_value: 10000.00

  # BZ_LICENSES Tests
  - name: bz_licenses
    description: "Bronze layer license management"
    columns:
      - name: license_id
        description: "Unique license identifier"
        tests:
          - not_null
          - unique
      - name: license_type
        description: "Type of license"
        tests:
          - not_null
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise', 'Trial']
      - name: assigned_to_user_id
        description: "User assigned to license"
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: start_date
        description: "License start date"
        tests:
          - not_null
      - name: end_date
        description: "License end date"
        tests:
          - not_null

  # BZ_DATA_AUDIT Tests
  - name: bz_data_audit
    description: "Bronze layer audit trail"
    columns:
      - name: record_id
        description: "Unique audit record identifier"
        tests:
          - not_null
          - unique
      - name: source_table
        description: "Source table name"
        tests:
          - not_null
      - name: load_timestamp
        description: "Operation timestamp"
        tests:
          - not_null
      - name: status
        description: "Operation status"
        tests:
          - not_null
          - accepted_values:
              values: ['SUCCESS', 'FAILED', 'WARNING', 'STARTED']
```

### Custom SQL Tests

#### Test 1: Validate Meeting Duration Consistency
```sql
-- tests/test_meeting_duration_consistency.sql
SELECT 
    meeting_id,
    duration_minutes,
    DATEDIFF('minute', start_time, end_time) as calculated_duration
FROM {{ ref('bz_meetings') }}
WHERE duration_minutes != DATEDIFF('minute', start_time, end_time)
  AND start_time IS NOT NULL 
  AND end_time IS NOT NULL
```

#### Test 2: Validate Participant Session Logic
```sql
-- tests/test_participant_session_logic.sql
SELECT 
    participant_id,
    join_time,
    leave_time
FROM {{ ref('bz_participants') }}
WHERE leave_time <= join_time
  AND join_time IS NOT NULL 
  AND leave_time IS NOT NULL
```

#### Test 3: Validate License Date Ranges
```sql
-- tests/test_license_date_ranges.sql
SELECT 
    license_id,
    start_date,
    end_date
FROM {{ ref('bz_licenses') }}
WHERE end_date <= start_date
  AND start_date IS NOT NULL 
  AND end_date IS NOT NULL
```

#### Test 4: Validate Deduplication Effectiveness
```sql
-- tests/test_deduplication_effectiveness.sql
WITH duplicate_check AS (
    SELECT 
        user_id,
        COUNT(*) as record_count
    FROM {{ ref('bz_users') }}
    GROUP BY user_id
    HAVING COUNT(*) > 1
)
SELECT * FROM duplicate_check
```

#### Test 5: Validate Audit Trail Completeness
```sql
-- tests/test_audit_trail_completeness.sql
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

#### Test 6: Validate Timestamp Overwrite
```sql
-- tests/test_timestamp_overwrite.sql
SELECT 
    'bz_users' as model_name,
    COUNT(*) as records_with_old_timestamps
FROM {{ ref('bz_users') }}
WHERE DATE(load_timestamp) != CURRENT_DATE()
   OR DATE(update_timestamp) != CURRENT_DATE()

UNION ALL

SELECT 
    'bz_meetings' as model_name,
    COUNT(*) as records_with_old_timestamps
FROM {{ ref('bz_meetings') }}
WHERE DATE(load_timestamp) != CURRENT_DATE()
   OR DATE(update_timestamp) != CURRENT_DATE()
```

#### Test 7: Validate Source System Tracking
```sql
-- tests/test_source_system_tracking.sql
SELECT 
    'Missing source_system in bz_users' as issue,
    COUNT(*) as record_count
FROM {{ ref('bz_users') }}
WHERE source_system IS NULL

UNION ALL

SELECT 
    'Missing source_system in bz_meetings' as issue,
    COUNT(*) as record_count
FROM {{ ref('bz_meetings') }}
WHERE source_system IS NULL
```

#### Test 8: Validate Feature Usage Patterns
```sql
-- tests/test_feature_usage_patterns.sql
SELECT 
    meeting_id,
    feature_name,
    SUM(usage_count) as total_usage
FROM {{ ref('bz_feature_usage') }}
GROUP BY meeting_id, feature_name
HAVING SUM(usage_count) > 1000  -- Flag unusually high usage
```

#### Test 9: Validate Billing Event Amounts
```sql
-- tests/test_billing_event_amounts.sql
SELECT 
    event_id,
    event_type,
    amount
FROM {{ ref('bz_billing_events') }}
WHERE (event_type IN ('Charge', 'Subscription', 'Upgrade') AND amount <= 0)
   OR (event_type = 'Refund' AND amount >= 0)
   OR ABS(amount) > 10000  -- Flag unusually large amounts
```

#### Test 10: Cross-Model Referential Integrity
```sql
-- tests/test_cross_model_integrity.sql
-- Check for orphaned participants
SELECT 
    'Orphaned participants' as issue_type,
    COUNT(*) as issue_count
FROM {{ ref('bz_participants') }} p
LEFT JOIN {{ ref('bz_meetings') }} m ON p.meeting_id = m.meeting_id
LEFT JOIN {{ ref('bz_users') }} u ON p.user_id = u.user_id
WHERE m.meeting_id IS NULL OR u.user_id IS NULL

UNION ALL

-- Check for orphaned feature usage
SELECT 
    'Orphaned feature usage' as issue_type,
    COUNT(*) as issue_count
FROM {{ ref('bz_feature_usage') }} f
LEFT JOIN {{ ref('bz_meetings') }} m ON f.meeting_id = m.meeting_id
WHERE m.meeting_id IS NULL
```

## Performance Test Scripts

#### Test 11: Model Execution Time Validation
```sql
-- tests/test_model_performance.sql
SELECT 
    source_table,
    AVG(processing_time) as avg_processing_time,
    MAX(processing_time) as max_processing_time
FROM {{ ref('bz_data_audit') }}
WHERE status = 'SUCCESS'
  AND load_timestamp >= CURRENT_DATE() - 7  -- Last 7 days
GROUP BY source_table
HAVING MAX(processing_time) > 300  -- Flag models taking > 5 minutes
```

#### Test 12: Row Count Validation
```sql
-- tests/test_row_count_validation.sql
WITH row_counts AS (
    SELECT 'bz_users' as table_name, COUNT(*) as row_count FROM {{ ref('bz_users') }}
    UNION ALL
    SELECT 'bz_meetings' as table_name, COUNT(*) as row_count FROM {{ ref('bz_meetings') }}
    UNION ALL
    SELECT 'bz_participants' as table_name, COUNT(*) as row_count FROM {{ ref('bz_participants') }}
    UNION ALL
    SELECT 'bz_feature_usage' as table_name, COUNT(*) as row_count FROM {{ ref('bz_feature_usage') }}
    UNION ALL
    SELECT 'bz_support_tickets' as table_name, COUNT(*) as row_count FROM {{ ref('bz_support_tickets') }}
    UNION ALL
    SELECT 'bz_billing_events' as table_name, COUNT(*) as row_count FROM {{ ref('bz_billing_events') }}
    UNION ALL
    SELECT 'bz_licenses' as table_name, COUNT(*) as row_count FROM {{ ref('bz_licenses') }}
)
SELECT *
FROM row_counts
WHERE row_count = 0  -- Flag empty tables
```

## Macro for Reusable Tests

```sql
-- macros/test_bronze_layer_quality.sql
{% macro test_bronze_layer_quality(model_name, primary_key) %}
    SELECT 
        '{{ model_name }}' as model_name,
        'Primary Key Validation' as test_type,
        COUNT(*) as total_records,
        COUNT(DISTINCT {{ primary_key }}) as unique_keys,
        COUNT(*) - COUNT(DISTINCT {{ primary_key }}) as duplicate_count,
        COUNT(*) - COUNT({{ primary_key }}) as null_key_count
    FROM {{ ref(model_name) }}
    
    UNION ALL
    
    SELECT 
        '{{ model_name }}' as model_name,
        'Timestamp Validation' as test_type,
        COUNT(*) as total_records,
        COUNT(CASE WHEN load_timestamp IS NULL THEN 1 END) as null_load_timestamps,
        COUNT(CASE WHEN update_timestamp IS NULL THEN 1 END) as null_update_timestamps,
        COUNT(CASE WHEN source_system IS NULL THEN 1 END) as null_source_systems
    FROM {{ ref(model_name) }}
{% endmacro %}
```

## Test Execution Commands

```bash
# Run all tests
dbt test

# Run tests for specific model
dbt test --select bz_users

# Run only data quality tests
dbt test --select tag:data_quality

# Run custom SQL tests
dbt test --select test_type:generic

# Run tests with verbose output
dbt test --verbose

# Generate test documentation
dbt docs generate
dbt docs serve
```

## Expected Test Results

### Success Criteria
- All primary key uniqueness tests pass
- All not_null constraints pass
- All referential integrity tests pass
- All business logic validations pass
- All custom SQL tests return 0 rows (indicating no issues)
- Model execution times are within acceptable limits
- Audit trail captures all model executions

### Failure Scenarios to Monitor
- Duplicate primary keys
- Null values in required fields
- Invalid foreign key references
- Inconsistent business logic (e.g., negative durations)
- Missing audit trail entries
- Performance degradation
- Data type mismatches
- Invalid enum values

## Monitoring and Alerting

### dbt Test Results Tracking
```sql
-- Query to monitor test results
SELECT 
    test_name,
    status,
    execution_time,
    failures,
    run_started_at
FROM {{ target.schema }}.dbt_test_results
WHERE run_started_at >= CURRENT_DATE() - 1
ORDER BY run_started_at DESC;
```

### Automated Test Scheduling
```yaml
# .github/workflows/dbt_tests.yml
name: DBT Tests
on:
  schedule:
    - cron: '0 */6 * * *'  # Run every 6 hours
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup DBT
        run: pip install dbt-snowflake
      - name: Run DBT Tests
        run: |
          dbt deps
          dbt test --profiles-dir ./profiles
```

## Conclusion

This comprehensive test suite ensures the reliability, performance, and data quality of the Zoom Bronze Layer dbt models in Snowflake. The tests cover:

- **Data Quality**: Primary key constraints, data types, format validation
- **Business Logic**: Deduplication, timestamp handling, calculation accuracy
- **Referential Integrity**: Foreign key relationships across models
- **Edge Cases**: Null handling, invalid data scenarios
- **Performance**: Execution time monitoring, row count validation
- **Audit Trail**: Complete tracking of all data operations

Regular execution of these tests will help maintain high data quality standards and catch issues early in the development cycle.