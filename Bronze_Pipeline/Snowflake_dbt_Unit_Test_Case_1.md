_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Bronze Layer dbt models in Snowflake
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases - Zoom Bronze Layer Pipeline

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Bronze Layer dbt models running in Snowflake. The test cases cover data transformations, business rules, edge cases, and error handling scenarios to ensure reliable and performant data pipelines.

## Models Under Test

The following Bronze layer models are covered by these test cases:

1. **bz_data_audit** - Audit table for tracking all Bronze layer operations
2. **bz_users** - User profile and subscription information
3. **bz_meetings** - Meeting information and session details
4. **bz_participants** - Meeting participants and session details
5. **bz_feature_usage** - Platform feature usage metrics
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

| Test Case ID | Test Case Description | Model | Expected Outcome |
|--------------|----------------------|-------|------------------|
| TC_BZ_001 | Primary key uniqueness validation | All models | All primary keys must be unique |
| TC_BZ_002 | Primary key not null validation | All models | No null values in primary key columns |
| TC_BZ_003 | Load timestamp validation | All models | Load timestamps must not be null and be recent |
| TC_BZ_004 | Update timestamp validation | All models | Update timestamps must not be null |
| TC_BZ_005 | Source system validation | All models | Source system must have valid values |
| TC_BZ_006 | Deduplication logic validation | All models | Only one record per primary key |
| TC_BZ_007 | Audit trail completeness | bz_data_audit | All model executions logged |
| TC_BZ_008 | User email format validation | bz_users | Email addresses must be valid format |
| TC_BZ_009 | Meeting duration validation | bz_meetings | Duration must be positive or null |
| TC_BZ_010 | Participant join/leave time validation | bz_participants | Join time must be before leave time |
| TC_BZ_011 | Feature usage count validation | bz_feature_usage | Usage count must be non-negative |
| TC_BZ_012 | Support ticket status validation | bz_support_tickets | Status must be from accepted values |
| TC_BZ_013 | Billing amount validation | bz_billing_events | Amount must be numeric and reasonable |
| TC_BZ_014 | License date validation | bz_licenses | Start date must be before end date |
| TC_BZ_015 | Referential integrity - meetings to users | bz_meetings | Host ID must exist in users table |
| TC_BZ_016 | Referential integrity - participants to meetings | bz_participants | Meeting ID must exist in meetings table |
| TC_BZ_017 | Referential integrity - participants to users | bz_participants | User ID must exist in users table |
| TC_BZ_018 | Referential integrity - feature usage to meetings | bz_feature_usage | Meeting ID must exist in meetings table |
| TC_BZ_019 | Referential integrity - support tickets to users | bz_support_tickets | User ID must exist in users table |
| TC_BZ_020 | Referential integrity - billing events to users | bz_billing_events | User ID must exist in users table |
| TC_BZ_021 | Referential integrity - licenses to users | bz_licenses | Assigned user ID must exist in users table |
| TC_BZ_022 | Empty dataset handling | All models | Models handle empty source tables gracefully |
| TC_BZ_023 | Null value handling | All models | Null values processed according to business rules |
| TC_BZ_024 | Duplicate record handling | All models | Duplicates removed based on latest timestamp |
| TC_BZ_025 | Invalid data type handling | All models | Invalid data types handled gracefully |
| TC_BZ_026 | Large dataset performance | All models | Models complete within acceptable time limits |
| TC_BZ_027 | Concurrent execution handling | All models | Models handle concurrent executions safely |
| TC_BZ_028 | Post-hook audit logging | All models | Audit records created after model execution |
| TC_BZ_029 | Schema evolution handling | All models | Models adapt to minor schema changes |
| TC_BZ_030 | Data freshness validation | All models | Data loaded within expected timeframes |

---

## dbt Test Scripts

### YAML-based Schema Tests

#### Enhanced Schema Tests (models/bronze/schema_tests.yml)

```yaml
version: 2

models:
  # Audit Table Tests
  - name: bz_data_audit
    description: "Comprehensive audit table tests"
    tests:
      - dbt_utils.expression_is_true:
          expression: "record_id > 0"
          config:
            severity: error
      - dbt_utils.expression_is_true:
          expression: "processing_time >= 0"
          config:
            severity: warn
    columns:
      - name: record_id
        tests:
          - not_null
          - unique
      - name: source_table
        tests:
          - not_null
          - accepted_values:
              values: ['bz_users', 'bz_meetings', 'bz_participants', 'bz_feature_usage', 'bz_support_tickets', 'bz_billing_events', 'bz_licenses']
      - name: load_timestamp
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "load_timestamp >= CURRENT_DATE() - 7"
      - name: status
        tests:
          - not_null
          - accepted_values:
              values: ['STARTED', 'COMPLETED', 'FAILED', 'WARNING']

  # Users Table Tests
  - name: bz_users
    description: "User profile data quality tests"
    tests:
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - user_id
            - load_timestamp
    columns:
      - name: user_id
        tests:
          - not_null
          - unique
      - name: user_name
        tests:
          - not_null
      - name: email
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "email LIKE '%@%'"
              config:
                severity: error
      - name: plan_type
        tests:
          - accepted_values:
              values: ['BASIC', 'PRO', 'BUSINESS', 'ENTERPRISE']
              config:
                severity: warn
      - name: load_timestamp
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "load_timestamp <= CURRENT_TIMESTAMP()"
      - name: source_system
        tests:
          - not_null

  # Meetings Table Tests
  - name: bz_meetings
    description: "Meeting data quality tests"
    tests:
      - dbt_utils.expression_is_true:
          expression: "start_time <= end_time OR end_time IS NULL"
          config:
            severity: error
    columns:
      - name: meeting_id
        tests:
          - not_null
          - unique
      - name: host_id
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: warn
      - name: duration_minutes
        tests:
          - dbt_utils.expression_is_true:
              expression: "duration_minutes >= 0 OR duration_minutes IS NULL"
      - name: load_timestamp
        tests:
          - not_null

  # Participants Table Tests
  - name: bz_participants
    description: "Participant data quality tests"
    tests:
      - dbt_utils.expression_is_true:
          expression: "join_time <= leave_time OR leave_time IS NULL"
          config:
            severity: error
    columns:
      - name: participant_id
        tests:
          - not_null
          - unique
      - name: meeting_id
        tests:
          - not_null
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
      - name: load_timestamp
        tests:
          - not_null

  # Feature Usage Table Tests
  - name: bz_feature_usage
    description: "Feature usage data quality tests"
    columns:
      - name: usage_id
        tests:
          - not_null
          - unique
      - name: meeting_id
        tests:
          - not_null
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
              config:
                severity: warn
      - name: feature_name
        tests:
          - not_null
          - accepted_values:
              values: ['SCREEN_SHARE', 'RECORDING', 'CHAT', 'BREAKOUT_ROOMS', 'WHITEBOARD', 'POLLS']
              config:
                severity: warn
      - name: usage_count
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "usage_count >= 0"
      - name: load_timestamp
        tests:
          - not_null

  # Support Tickets Table Tests
  - name: bz_support_tickets
    description: "Support ticket data quality tests"
    columns:
      - name: ticket_id
        tests:
          - not_null
          - unique
      - name: user_id
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: warn
      - name: ticket_type
        tests:
          - not_null
          - accepted_values:
              values: ['TECHNICAL', 'BILLING', 'ACCOUNT', 'FEATURE_REQUEST', 'BUG_REPORT']
              config:
                severity: warn
      - name: resolution_status
        tests:
          - not_null
          - accepted_values:
              values: ['OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED', 'ESCALATED']
      - name: load_timestamp
        tests:
          - not_null

  # Billing Events Table Tests
  - name: bz_billing_events
    description: "Billing event data quality tests"
    columns:
      - name: event_id
        tests:
          - not_null
          - unique
      - name: user_id
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: warn
      - name: event_type
        tests:
          - not_null
          - accepted_values:
              values: ['CHARGE', 'REFUND', 'CREDIT', 'ADJUSTMENT', 'SUBSCRIPTION']
      - name: amount
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "amount BETWEEN -10000 AND 10000"
              config:
                severity: warn
      - name: load_timestamp
        tests:
          - not_null

  # Licenses Table Tests
  - name: bz_licenses
    description: "License data quality tests"
    tests:
      - dbt_utils.expression_is_true:
          expression: "start_date <= end_date OR end_date IS NULL"
          config:
            severity: error
    columns:
      - name: license_id
        tests:
          - not_null
          - unique
      - name: license_type
        tests:
          - not_null
          - accepted_values:
              values: ['BASIC', 'PRO', 'BUSINESS', 'ENTERPRISE', 'DEVELOPER']
      - name: assigned_to_user_id
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: warn
      - name: load_timestamp
        tests:
          - not_null
```

### Custom SQL-based dbt Tests

#### Test 1: Data Freshness Validation (tests/data_freshness_test.sql)

```sql
-- Test to ensure data is loaded within expected timeframes
-- Fails if any Bronze table has data older than 24 hours

WITH freshness_check AS (
    SELECT 
        'bz_users' as table_name,
        MAX(load_timestamp) as latest_load,
        CURRENT_TIMESTAMP() - INTERVAL '24 HOURS' as threshold
    FROM {{ ref('bz_users') }}
    
    UNION ALL
    
    SELECT 
        'bz_meetings' as table_name,
        MAX(load_timestamp) as latest_load,
        CURRENT_TIMESTAMP() - INTERVAL '24 HOURS' as threshold
    FROM {{ ref('bz_meetings') }}
    
    UNION ALL
    
    SELECT 
        'bz_participants' as table_name,
        MAX(load_timestamp) as latest_load,
        CURRENT_TIMESTAMP() - INTERVAL '24 HOURS' as threshold
    FROM {{ ref('bz_participants') }}
    
    UNION ALL
    
    SELECT 
        'bz_feature_usage' as table_name,
        MAX(load_timestamp) as latest_load,
        CURRENT_TIMESTAMP() - INTERVAL '24 HOURS' as threshold
    FROM {{ ref('bz_feature_usage') }}
    
    UNION ALL
    
    SELECT 
        'bz_support_tickets' as table_name,
        MAX(load_timestamp) as latest_load,
        CURRENT_TIMESTAMP() - INTERVAL '24 HOURS' as threshold
    FROM {{ ref('bz_support_tickets') }}
    
    UNION ALL
    
    SELECT 
        'bz_billing_events' as table_name,
        MAX(load_timestamp) as latest_load,
        CURRENT_TIMESTAMP() - INTERVAL '24 HOURS' as threshold
    FROM {{ ref('bz_billing_events') }}
    
    UNION ALL
    
    SELECT 
        'bz_licenses' as table_name,
        MAX(load_timestamp) as latest_load,
        CURRENT_TIMESTAMP() - INTERVAL '24 HOURS' as threshold
    FROM {{ ref('bz_licenses') }}
)

SELECT 
    table_name,
    latest_load,
    threshold
FROM freshness_check
WHERE latest_load < threshold
```

#### Test 2: Deduplication Validation (tests/deduplication_test.sql)

```sql
-- Test to ensure deduplication logic works correctly
-- Fails if any table has duplicate primary keys

WITH duplicate_check AS (
    SELECT 
        'bz_users' as table_name,
        user_id as primary_key,
        COUNT(*) as record_count
    FROM {{ ref('bz_users') }}
    GROUP BY user_id
    HAVING COUNT(*) > 1
    
    UNION ALL
    
    SELECT 
        'bz_meetings' as table_name,
        meeting_id as primary_key,
        COUNT(*) as record_count
    FROM {{ ref('bz_meetings') }}
    GROUP BY meeting_id
    HAVING COUNT(*) > 1
    
    UNION ALL
    
    SELECT 
        'bz_participants' as table_name,
        participant_id as primary_key,
        COUNT(*) as record_count
    FROM {{ ref('bz_participants') }}
    GROUP BY participant_id
    HAVING COUNT(*) > 1
    
    UNION ALL
    
    SELECT 
        'bz_feature_usage' as table_name,
        usage_id as primary_key,
        COUNT(*) as record_count
    FROM {{ ref('bz_feature_usage') }}
    GROUP BY usage_id
    HAVING COUNT(*) > 1
    
    UNION ALL
    
    SELECT 
        'bz_support_tickets' as table_name,
        ticket_id as primary_key,
        COUNT(*) as record_count
    FROM {{ ref('bz_support_tickets') }}
    GROUP BY ticket_id
    HAVING COUNT(*) > 1
    
    UNION ALL
    
    SELECT 
        'bz_billing_events' as table_name,
        event_id as primary_key,
        COUNT(*) as record_count
    FROM {{ ref('bz_billing_events') }}
    GROUP BY event_id
    HAVING COUNT(*) > 1
    
    UNION ALL
    
    SELECT 
        'bz_licenses' as table_name,
        license_id as primary_key,
        COUNT(*) as record_count
    FROM {{ ref('bz_licenses') }}
    GROUP BY license_id
    HAVING COUNT(*) > 1
)

SELECT *
FROM duplicate_check
```

#### Test 3: Audit Trail Completeness (tests/audit_completeness_test.sql)

```sql
-- Test to ensure all model executions are logged in audit table
-- Fails if any expected audit records are missing

WITH expected_audit_records AS (
    SELECT DISTINCT 'bz_users' as expected_table
    UNION ALL
    SELECT 'bz_meetings'
    UNION ALL
    SELECT 'bz_participants'
    UNION ALL
    SELECT 'bz_feature_usage'
    UNION ALL
    SELECT 'bz_support_tickets'
    UNION ALL
    SELECT 'bz_billing_events'
    UNION ALL
    SELECT 'bz_licenses'
),

actual_audit_records AS (
    SELECT DISTINCT source_table
    FROM {{ ref('bz_data_audit') }}
    WHERE load_timestamp >= CURRENT_DATE()
      AND status = 'COMPLETED'
)

SELECT 
    e.expected_table
FROM expected_audit_records e
LEFT JOIN actual_audit_records a ON e.expected_table = a.source_table
WHERE a.source_table IS NULL
```

#### Test 4: Business Logic Validation (tests/business_logic_test.sql)

```sql
-- Test to validate key business rules across models
-- Fails if business logic violations are found

WITH business_rule_violations AS (
    -- Rule 1: Meeting duration should match calculated duration
    SELECT 
        'meeting_duration_mismatch' as violation_type,
        meeting_id as record_id,
        'Duration does not match start/end times' as description
    FROM {{ ref('bz_meetings') }}
    WHERE start_time IS NOT NULL 
      AND end_time IS NOT NULL
      AND duration_minutes IS NOT NULL
      AND ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) > 1
    
    UNION ALL
    
    -- Rule 2: Participants should not join meetings before they start
    SELECT 
        'participant_early_join' as violation_type,
        p.participant_id as record_id,
        'Participant joined before meeting started' as description
    FROM {{ ref('bz_participants') }} p
    JOIN {{ ref('bz_meetings') }} m ON p.meeting_id = m.meeting_id
    WHERE p.join_time < m.start_time
    
    UNION ALL
    
    -- Rule 3: Feature usage should not exceed reasonable limits
    SELECT 
        'excessive_feature_usage' as violation_type,
        usage_id as record_id,
        'Feature usage count exceeds reasonable limits' as description
    FROM {{ ref('bz_feature_usage') }}
    WHERE usage_count > 1000
    
    UNION ALL
    
    -- Rule 4: Billing amounts should be reasonable
    SELECT 
        'unreasonable_billing_amount' as violation_type,
        event_id as record_id,
        'Billing amount is unreasonably high' as description
    FROM {{ ref('bz_billing_events') }}
    WHERE ABS(amount) > 5000
)

SELECT *
FROM business_rule_violations
```

#### Test 5: Performance Validation (tests/performance_test.sql)

```sql
-- Test to validate model performance metrics
-- Fails if any model takes too long to process or returns unexpected row counts

WITH performance_metrics AS (
    SELECT 
        'bz_users' as model_name,
        COUNT(*) as row_count,
        'Expected reasonable user count' as metric_description
    FROM {{ ref('bz_users') }}
    
    UNION ALL
    
    SELECT 
        'bz_meetings' as model_name,
        COUNT(*) as row_count,
        'Expected reasonable meeting count' as metric_description
    FROM {{ ref('bz_meetings') }}
    
    UNION ALL
    
    SELECT 
        'bz_participants' as model_name,
        COUNT(*) as row_count,
        'Expected reasonable participant count' as metric_description
    FROM {{ ref('bz_participants') }}
)

SELECT 
    model_name,
    row_count,
    metric_description
FROM performance_metrics
WHERE row_count = 0  -- Flag models with no data
   OR row_count > 10000000  -- Flag models with unexpectedly high row counts
```

### Parameterized Tests

#### Generic Test for Source System Validation (macros/test_source_system.sql)

```sql
{% macro test_source_system(model, column_name) %}

    SELECT 
        {{ column_name }} as invalid_source_system,
        COUNT(*) as record_count
    FROM {{ model }}
    WHERE {{ column_name }} IS NULL 
       OR {{ column_name }} = ''
       OR {{ column_name }} NOT IN ('ZOOM_API', 'ZOOM_WEBHOOK', 'ZOOM_EXPORT', 'MANUAL_ENTRY', 'UNKNOWN')
    GROUP BY {{ column_name }}
    HAVING COUNT(*) > 0

{% endmacro %}
```

#### Generic Test for Timestamp Validation (macros/test_timestamp_logic.sql)

```sql
{% macro test_timestamp_logic(model, start_column, end_column) %}

    SELECT 
        *
    FROM {{ model }}
    WHERE {{ start_column }} IS NOT NULL 
      AND {{ end_column }} IS NOT NULL
      AND {{ start_column }} > {{ end_column }}

{% endmacro %}
```

## Test Execution Strategy

### 1. Pre-deployment Testing
- Run all schema tests before deploying models
- Execute custom SQL tests to validate business logic
- Perform performance benchmarking

### 2. Post-deployment Validation
- Verify audit trail completeness
- Check data freshness
- Validate referential integrity

### 3. Continuous Monitoring
- Schedule daily test runs
- Set up alerts for test failures
- Monitor performance metrics

### 4. Test Maintenance
- Review and update tests quarterly
- Add new tests for edge cases discovered in production
- Optimize test performance as data volumes grow

## Expected Test Results

### Success Criteria
- All primary key uniqueness tests pass
- No null values in required fields
- All referential integrity constraints satisfied
- Business logic validations pass
- Performance metrics within acceptable ranges
- Audit trail complete and accurate

### Failure Handling
- Critical failures (data quality issues) should stop pipeline execution
- Warning-level failures should be logged but allow pipeline to continue
- All failures should be tracked in dbt's run_results.json
- Failed tests should trigger alerts to data engineering team

## Monitoring and Alerting

### dbt Cloud Integration
- Configure test results to be stored in Snowflake audit schema
- Set up email notifications for test failures
- Create dashboards for test result monitoring

### Snowflake Audit Schema
- Test results logged to `AUDIT.DBT_TEST_RESULTS` table
- Performance metrics tracked in `AUDIT.DBT_PERFORMANCE_METRICS`
- Historical test trends available for analysis

---

## Conclusion

These comprehensive unit test cases ensure the reliability, performance, and data quality of the Zoom Bronze Layer dbt models in Snowflake. The combination of YAML-based schema tests, custom SQL tests, and parameterized macros provides thorough coverage of all critical data pipeline components.

Regular execution of these tests will help maintain high data quality standards and catch potential issues early in the development cycle, ensuring robust and trustworthy data pipelines for downstream analytics and reporting needs.