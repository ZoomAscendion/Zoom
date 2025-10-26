_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Bronze Pipeline dbt models in Snowflake
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Zoom Bronze Pipeline

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Bronze Pipeline dbt models running in Snowflake. The test coverage includes data transformations, business rules validation, edge cases, and error handling scenarios across all 8 bronze layer models and the audit log system.

## Test Strategy Overview

### Models Under Test
1. **bz_audit_log** - Audit tracking for all bronze layer processing
2. **bz_billing_events** - Billing and payment event data
3. **bz_feature_usage** - Feature usage tracking data
4. **bz_licenses** - License management data
5. **bz_meetings** - Core meeting information
6. **bz_participants** - Meeting participant tracking
7. **bz_support_tickets** - Customer support ticket data
8. **bz_users** - User account and profile information
9. **bz_webinars** - Webinar-specific data

### Test Categories
- **Data Quality Tests**: Null checks, uniqueness, referential integrity
- **Business Rule Tests**: Date validations, logical constraints, value ranges
- **Transformation Tests**: Data type casting, field mapping validation
- **Edge Case Tests**: Empty datasets, invalid data, boundary conditions
- **Performance Tests**: Large dataset handling, query optimization

## Test Case List

| Test Case ID | Test Case Description | Model | Expected Outcome |
|--------------|----------------------|-------|------------------|
| TC_AUDIT_001 | Validate audit log record uniqueness | bz_audit_log | All record_id values are unique |
| TC_AUDIT_002 | Validate audit log status values | bz_audit_log | Status only contains STARTED, COMPLETED, FAILED |
| TC_AUDIT_003 | Validate audit log timestamp consistency | bz_audit_log | load_timestamp is not null and valid |
| TC_BILLING_001 | Validate billing events data completeness | bz_billing_events | No null values in required fields |
| TC_BILLING_002 | Validate positive billing amounts | bz_billing_events | All amounts are >= 0 |
| TC_BILLING_003 | Validate billing event date logic | bz_billing_events | event_date <= current_date |
| TC_BILLING_004 | Validate billing event type values | bz_billing_events | event_type contains valid values |
| TC_FEATURE_001 | Validate feature usage data completeness | bz_feature_usage | No null values in required fields |
| TC_FEATURE_002 | Validate positive usage counts | bz_feature_usage | usage_count >= 0 |
| TC_FEATURE_003 | Validate feature usage date logic | bz_feature_usage | usage_date <= current_date |
| TC_FEATURE_004 | Validate meeting_id relationships | bz_feature_usage | All meeting_ids exist in meetings table |
| TC_LICENSE_001 | Validate license data completeness | bz_licenses | No null values in required fields |
| TC_LICENSE_002 | Validate license date ranges | bz_licenses | start_date <= end_date |
| TC_LICENSE_003 | Validate license type values | bz_licenses | license_type contains valid values |
| TC_LICENSE_004 | Validate user assignments | bz_licenses | assigned_to_user_id references valid users |
| TC_MEETING_001 | Validate meeting data completeness | bz_meetings | No null values in required fields |
| TC_MEETING_002 | Validate meeting time logic | bz_meetings | start_time < end_time |
| TC_MEETING_003 | Validate meeting duration consistency | bz_meetings | duration_minutes matches time difference |
| TC_MEETING_004 | Validate host relationships | bz_meetings | host_id references valid users |
| TC_PARTICIPANT_001 | Validate participant data completeness | bz_participants | No null values in required fields |
| TC_PARTICIPANT_002 | Validate participant time logic | bz_participants | join_time <= leave_time |
| TC_PARTICIPANT_003 | Validate meeting relationships | bz_participants | meeting_id references valid meetings |
| TC_PARTICIPANT_004 | Validate user relationships | bz_participants | user_id references valid users |
| TC_SUPPORT_001 | Validate support ticket completeness | bz_support_tickets | No null values in required fields |
| TC_SUPPORT_002 | Validate ticket date logic | bz_support_tickets | open_date <= current_date |
| TC_SUPPORT_003 | Validate ticket status values | bz_support_tickets | resolution_status contains valid values |
| TC_SUPPORT_004 | Validate user relationships | bz_support_tickets | user_id references valid users |
| TC_USER_001 | Validate user data completeness | bz_users | No null values in required fields |
| TC_USER_002 | Validate email format | bz_users | email contains @ symbol |
| TC_USER_003 | Validate plan type values | bz_users | plan_type contains valid values |
| TC_USER_004 | Validate user name format | bz_users | user_name is not empty |
| TC_WEBINAR_001 | Validate webinar data completeness | bz_webinars | No null values in required fields |
| TC_WEBINAR_002 | Validate webinar time logic | bz_webinars | start_time < end_time |
| TC_WEBINAR_003 | Validate registrant counts | bz_webinars | registrants >= 0 |
| TC_WEBINAR_004 | Validate host relationships | bz_webinars | host_id references valid users |
| TC_EDGE_001 | Handle empty source datasets | All models | Models execute without errors |
| TC_EDGE_002 | Handle duplicate source records | All models | Duplicates are handled appropriately |
| TC_EDGE_003 | Handle invalid data types | All models | Invalid records are filtered out |
| TC_PERF_001 | Large dataset processing | All models | Models complete within SLA |

## dbt Test Scripts

### YAML-based Schema Tests

#### File: tests/schema_tests.yml
```yaml
version: 2

models:
  # Audit Log Tests
  - name: bz_audit_log
    tests:
      - dbt_utils.expression_is_true:
          expression: "record_id IS NOT NULL"
          config:
            severity: error
      - dbt_utils.expression_is_true:
          expression: "status IN ('STARTED', 'COMPLETED', 'FAILED')"
          config:
            severity: error
    columns:
      - name: record_id
        tests:
          - unique
          - not_null
      - name: source_table
        tests:
          - not_null
      - name: load_timestamp
        tests:
          - not_null
      - name: processed_by
        tests:
          - not_null
      - name: status
        tests:
          - accepted_values:
              values: ['STARTED', 'COMPLETED', 'FAILED']

  # Billing Events Tests
  - name: bz_billing_events
    tests:
      - dbt_utils.expression_is_true:
          expression: "amount >= 0"
          config:
            severity: error
      - dbt_utils.expression_is_true:
          expression: "event_date <= CURRENT_DATE()"
          config:
            severity: warn
    columns:
      - name: user_id
        tests:
          - not_null
      - name: event_type
        tests:
          - not_null
          - accepted_values:
              values: ['payment', 'refund', 'subscription', 'upgrade', 'downgrade']
      - name: amount
        tests:
          - not_null
      - name: event_date
        tests:
          - not_null

  # Feature Usage Tests
  - name: bz_feature_usage
    tests:
      - dbt_utils.expression_is_true:
          expression: "usage_count >= 0"
          config:
            severity: error
      - dbt_utils.expression_is_true:
          expression: "usage_date <= CURRENT_DATE()"
          config:
            severity: warn
    columns:
      - name: meeting_id
        tests:
          - not_null
      - name: feature_name
        tests:
          - not_null
          - accepted_values:
              values: ['screen_share', 'recording', 'chat', 'breakout_rooms', 'whiteboard', 'polls']
      - name: usage_count
        tests:
          - not_null
      - name: usage_date
        tests:
          - not_null

  # License Tests
  - name: bz_licenses
    tests:
      - dbt_utils.expression_is_true:
          expression: "start_date <= end_date"
          config:
            severity: error
    columns:
      - name: license_type
        tests:
          - not_null
          - accepted_values:
              values: ['basic', 'pro', 'business', 'enterprise']
      - name: start_date
        tests:
          - not_null
      - name: end_date
        tests:
          - not_null

  # Meeting Tests
  - name: bz_meetings
    tests:
      - dbt_utils.expression_is_true:
          expression: "start_time < end_time"
          config:
            severity: error
      - dbt_utils.expression_is_true:
          expression: "duration_minutes >= 0"
          config:
            severity: error
    columns:
      - name: host_id
        tests:
          - not_null
      - name: meeting_topic
        tests:
          - not_null
      - name: start_time
        tests:
          - not_null
      - name: end_time
        tests:
          - not_null
      - name: duration_minutes
        tests:
          - not_null

  # Participant Tests
  - name: bz_participants
    tests:
      - dbt_utils.expression_is_true:
          expression: "join_time <= leave_time"
          config:
            severity: error
    columns:
      - name: meeting_id
        tests:
          - not_null
      - name: user_id
        tests:
          - not_null
      - name: join_time
        tests:
          - not_null
      - name: leave_time
        tests:
          - not_null

  # Support Ticket Tests
  - name: bz_support_tickets
    tests:
      - dbt_utils.expression_is_true:
          expression: "open_date <= CURRENT_DATE()"
          config:
            severity: warn
    columns:
      - name: user_id
        tests:
          - not_null
      - name: ticket_type
        tests:
          - not_null
          - accepted_values:
              values: ['technical', 'billing', 'feature_request', 'bug_report', 'general']
      - name: resolution_status
        tests:
          - not_null
          - accepted_values:
              values: ['open', 'in_progress', 'resolved', 'closed']
      - name: open_date
        tests:
          - not_null

  # User Tests
  - name: bz_users
    tests:
      - dbt_utils.expression_is_true:
          expression: "email LIKE '%@%'"
          config:
            severity: error
      - dbt_utils.expression_is_true:
          expression: "LENGTH(TRIM(user_name)) > 0"
          config:
            severity: error
    columns:
      - name: user_name
        tests:
          - not_null
      - name: email
        tests:
          - not_null
          - unique
      - name: plan_type
        tests:
          - not_null
          - accepted_values:
              values: ['basic', 'pro', 'business', 'enterprise']

  # Webinar Tests
  - name: bz_webinars
    tests:
      - dbt_utils.expression_is_true:
          expression: "start_time < end_time"
          config:
            severity: error
      - dbt_utils.expression_is_true:
          expression: "registrants >= 0"
          config:
            severity: error
    columns:
      - name: host_id
        tests:
          - not_null
      - name: webinar_topic
        tests:
          - not_null
      - name: start_time
        tests:
          - not_null
      - name: end_time
        tests:
          - not_null
      - name: registrants
        tests:
          - not_null
```

### Custom SQL-based dbt Tests

#### File: tests/test_meeting_duration_consistency.sql
```sql
-- Test: Validate meeting duration matches calculated time difference
SELECT 
    meeting_id,
    host_id,
    start_time,
    end_time,
    duration_minutes,
    DATEDIFF('minute', start_time, end_time) AS calculated_duration
FROM {{ ref('bz_meetings') }}
WHERE ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) > 1
```

#### File: tests/test_participant_meeting_overlap.sql
```sql
-- Test: Validate participants join/leave times are within meeting duration
SELECT 
    p.participant_id,
    p.meeting_id,
    p.user_id,
    p.join_time,
    p.leave_time,
    m.start_time,
    m.end_time
FROM {{ ref('bz_participants') }} p
JOIN {{ ref('bz_meetings') }} m ON p.meeting_id = m.meeting_id
WHERE p.join_time < m.start_time 
   OR p.leave_time > m.end_time
   OR p.join_time > p.leave_time
```

#### File: tests/test_license_user_relationships.sql
```sql
-- Test: Validate license assignments reference valid users
SELECT 
    l.license_id,
    l.license_type,
    l.assigned_to_user_id
FROM {{ ref('bz_licenses') }} l
LEFT JOIN {{ ref('bz_users') }} u ON l.assigned_to_user_id = u.user_id
WHERE l.assigned_to_user_id IS NOT NULL 
  AND u.user_id IS NULL
```

#### File: tests/test_feature_usage_meeting_relationships.sql
```sql
-- Test: Validate feature usage references valid meetings
SELECT 
    f.usage_id,
    f.meeting_id,
    f.feature_name,
    f.usage_date
FROM {{ ref('bz_feature_usage') }} f
LEFT JOIN {{ ref('bz_meetings') }} m ON f.meeting_id = m.meeting_id
WHERE m.meeting_id IS NULL
```

#### File: tests/test_billing_events_user_relationships.sql
```sql
-- Test: Validate billing events reference valid users
SELECT 
    b.event_id,
    b.user_id,
    b.event_type,
    b.amount
FROM {{ ref('bz_billing_events') }} b
LEFT JOIN {{ ref('bz_users') }} u ON b.user_id = u.user_id
WHERE u.user_id IS NULL
```

#### File: tests/test_data_quality_flags.sql
```sql
-- Test: Monitor data quality across all bronze models
WITH quality_summary AS (
    SELECT 'bz_billing_events' as table_name, COUNT(*) as total_records FROM {{ ref('bz_billing_events') }}
    UNION ALL
    SELECT 'bz_feature_usage' as table_name, COUNT(*) as total_records FROM {{ ref('bz_feature_usage') }}
    UNION ALL
    SELECT 'bz_licenses' as table_name, COUNT(*) as total_records FROM {{ ref('bz_licenses') }}
    UNION ALL
    SELECT 'bz_meetings' as table_name, COUNT(*) as total_records FROM {{ ref('bz_meetings') }}
    UNION ALL
    SELECT 'bz_participants' as table_name, COUNT(*) as total_records FROM {{ ref('bz_participants') }}
    UNION ALL
    SELECT 'bz_support_tickets' as table_name, COUNT(*) as total_records FROM {{ ref('bz_support_tickets') }}
    UNION ALL
    SELECT 'bz_users' as table_name, COUNT(*) as total_records FROM {{ ref('bz_users') }}
    UNION ALL
    SELECT 'bz_webinars' as table_name, COUNT(*) as total_records FROM {{ ref('bz_webinars') }}
)
SELECT 
    table_name,
    total_records
FROM quality_summary
WHERE total_records = 0
```

#### File: tests/test_audit_log_completeness.sql
```sql
-- Test: Validate audit log captures all model executions
WITH expected_models AS (
    SELECT 'bz_billing_events' as model_name
    UNION ALL SELECT 'bz_feature_usage'
    UNION ALL SELECT 'bz_licenses'
    UNION ALL SELECT 'bz_meetings'
    UNION ALL SELECT 'bz_participants'
    UNION ALL SELECT 'bz_support_tickets'
    UNION ALL SELECT 'bz_users'
    UNION ALL SELECT 'bz_webinars'
),
audit_models AS (
    SELECT DISTINCT source_table as model_name
    FROM {{ ref('bz_audit_log') }}
    WHERE status = 'COMPLETED'
)
SELECT 
    e.model_name
FROM expected_models e
LEFT JOIN audit_models a ON e.model_name = a.model_name
WHERE a.model_name IS NULL
```

### Edge Case Tests

#### File: tests/test_empty_datasets.sql
```sql
-- Test: Handle empty source datasets gracefully
{{ config(severity='warn') }}

WITH source_counts AS (
    SELECT 'billing_events' as source_name, COUNT(*) as record_count FROM {{ source('raw_zoom', 'billing_events') }}
    UNION ALL
    SELECT 'feature_usage' as source_name, COUNT(*) as record_count FROM {{ source('raw_zoom', 'feature_usage') }}
    UNION ALL
    SELECT 'licenses' as source_name, COUNT(*) as record_count FROM {{ source('raw_zoom', 'licenses') }}
    UNION ALL
    SELECT 'meetings' as source_name, COUNT(*) as record_count FROM {{ source('raw_zoom', 'meetings') }}
    UNION ALL
    SELECT 'participants' as source_name, COUNT(*) as record_count FROM {{ source('raw_zoom', 'participants') }}
    UNION ALL
    SELECT 'support_tickets' as source_name, COUNT(*) as record_count FROM {{ source('raw_zoom', 'support_tickets') }}
    UNION ALL
    SELECT 'users' as source_name, COUNT(*) as record_count FROM {{ source('raw_zoom', 'users') }}
    UNION ALL
    SELECT 'webinars' as source_name, COUNT(*) as record_count FROM {{ source('raw_zoom', 'webinars') }}
)
SELECT 
    source_name,
    record_count
FROM source_counts
WHERE record_count = 0
```

#### File: tests/test_future_dates.sql
```sql
-- Test: Identify records with future dates
{{ config(severity='warn') }}

WITH future_date_records AS (
    SELECT 'bz_billing_events' as table_name, user_id as record_id, event_date as date_field
    FROM {{ ref('bz_billing_events') }}
    WHERE event_date > CURRENT_DATE()
    
    UNION ALL
    
    SELECT 'bz_feature_usage' as table_name, meeting_id as record_id, usage_date as date_field
    FROM {{ ref('bz_feature_usage') }}
    WHERE usage_date > CURRENT_DATE()
    
    UNION ALL
    
    SELECT 'bz_support_tickets' as table_name, user_id as record_id, open_date as date_field
    FROM {{ ref('bz_support_tickets') }}
    WHERE open_date > CURRENT_DATE()
)
SELECT *
FROM future_date_records
```

### Performance Tests

#### File: tests/test_model_performance.sql
```sql
-- Test: Monitor model execution performance
{{ config(severity='warn') }}

SELECT 
    source_table,
    AVG(processing_time) as avg_processing_time_seconds,
    MAX(processing_time) as max_processing_time_seconds,
    COUNT(*) as execution_count
FROM {{ ref('bz_audit_log') }}
WHERE status = 'COMPLETED'
  AND load_timestamp >= CURRENT_DATE() - 7
GROUP BY source_table
HAVING AVG(processing_time) > 300 -- Alert if average processing time > 5 minutes
```

## Test Execution Strategy

### 1. Pre-deployment Testing
```bash
# Run all tests
dbt test

# Run tests for specific model
dbt test --select bz_billing_events

# Run only data quality tests
dbt test --select tag:data_quality

# Run tests with specific severity
dbt test --severity error
```

### 2. Continuous Integration Testing
```yaml
# .github/workflows/dbt_test.yml
name: dbt Test Pipeline
on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup dbt
        run: |
          pip install dbt-snowflake
      - name: Run dbt tests
        run: |
          dbt deps
          dbt test --profiles-dir ./profiles
```

### 3. Production Monitoring
```sql
-- Daily test execution monitoring
SELECT 
    test_name,
    status,
    execution_time,
    failures,
    run_started_at
FROM dbt_test_results
WHERE DATE(run_started_at) = CURRENT_DATE()
  AND status = 'fail'
ORDER BY run_started_at DESC;
```

## Test Results Tracking

### Snowflake Audit Schema Setup
```sql
-- Create test results tracking table
CREATE OR REPLACE TABLE BRONZE.TEST_RESULTS (
    test_execution_id STRING,
    test_name STRING,
    model_name STRING,
    test_type STRING,
    status STRING,
    failure_count NUMBER,
    execution_time_seconds NUMBER,
    run_started_at TIMESTAMP_NTZ,
    run_completed_at TIMESTAMP_NTZ,
    error_message STRING
);
```

### Test Results Dashboard Queries
```sql
-- Test success rate by model
SELECT 
    model_name,
    COUNT(*) as total_tests,
    SUM(CASE WHEN status = 'pass' THEN 1 ELSE 0 END) as passed_tests,
    ROUND((passed_tests / total_tests) * 100, 2) as success_rate_percent
FROM BRONZE.TEST_RESULTS
WHERE DATE(run_started_at) >= CURRENT_DATE() - 30
GROUP BY model_name
ORDER BY success_rate_percent DESC;

-- Failed tests summary
SELECT 
    test_name,
    model_name,
    COUNT(*) as failure_count,
    MAX(run_started_at) as last_failure
FROM BRONZE.TEST_RESULTS
WHERE status = 'fail'
  AND DATE(run_started_at) >= CURRENT_DATE() - 7
GROUP BY test_name, model_name
ORDER BY failure_count DESC;
```

## Maintenance and Updates

### 1. Regular Test Review
- **Weekly**: Review test failure patterns and update thresholds
- **Monthly**: Add new test cases based on data quality issues
- **Quarterly**: Performance test review and optimization

### 2. Test Case Evolution
- Monitor business rule changes and update accepted values
- Add new relationship tests as models evolve
- Update performance benchmarks based on data growth

### 3. Documentation Updates
- Keep test descriptions current with business requirements
- Update expected outcomes based on system changes
- Maintain test execution procedures

## Conclusion

This comprehensive test suite ensures the reliability and performance of the Zoom Bronze Pipeline dbt models in Snowflake. The combination of schema tests, custom SQL tests, and monitoring provides robust coverage for data quality, business rules, and system performance. Regular execution and monitoring of these tests will help maintain high data quality standards and catch issues early in the development cycle.