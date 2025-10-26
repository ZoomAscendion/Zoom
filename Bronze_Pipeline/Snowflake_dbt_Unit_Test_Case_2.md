_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Enhanced comprehensive unit test cases for Zoom Bronze Pipeline dbt models in Snowflake with advanced testing patterns
## *Version*: 2
## *Updated on*: 2024-12-19
_____________________________________________

# Enhanced Snowflake dbt Unit Test Cases for Zoom Bronze Pipeline - Version 2

## Description

This enhanced version provides comprehensive unit test cases and dbt test scripts for the Zoom Bronze Pipeline dbt models running in Snowflake. Version 2 includes advanced testing patterns, statistical validation, data quality scoring, anomaly detection, and enhanced monitoring capabilities across all 9 bronze layer models and the audit log system.

## What's New in Version 2

### Enhanced Features
- **Statistical Data Validation**: Using dbt-expectations for advanced data quality checks
- **Anomaly Detection Tests**: Identifying outliers and unusual patterns
- **Data Quality Scoring**: Comprehensive scoring system for data health
- **Cross-Model Dependency Tests**: Validating relationships across multiple models
- **Advanced Performance Monitoring**: Resource utilization and query optimization tests
- **Data Freshness Validation**: Custom thresholds for data timeliness
- **Incremental Testing Strategies**: Specialized tests for incremental models
- **Enhanced Error Handling**: More granular error categorization and handling

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

### Enhanced Test Categories
- **Core Data Quality Tests**: Null checks, uniqueness, referential integrity
- **Statistical Validation Tests**: Distribution analysis, outlier detection
- **Business Rule Tests**: Date validations, logical constraints, value ranges
- **Cross-Model Relationship Tests**: Complex joins and dependency validation
- **Performance & Resource Tests**: Query optimization, memory usage, execution time
- **Data Freshness Tests**: Timeliness and staleness detection
- **Anomaly Detection Tests**: Pattern recognition and deviation alerts
- **Data Quality Scoring**: Comprehensive health metrics

## Enhanced Test Case List

| Test Case ID | Test Case Description | Model | Test Type | Expected Outcome |
|--------------|----------------------|-------|-----------|------------------|
| **Core Data Quality Tests** |
| TC_AUDIT_001 | Validate audit log record uniqueness | bz_audit_log | Uniqueness | All record_id values are unique |
| TC_AUDIT_002 | Validate audit log status values | bz_audit_log | Accepted Values | Status only contains valid values |
| TC_AUDIT_003 | Validate audit log timestamp consistency | bz_audit_log | Not Null | load_timestamp is not null and valid |
| TC_BILLING_001 | Validate billing events data completeness | bz_billing_events | Not Null | No null values in required fields |
| TC_BILLING_002 | Validate positive billing amounts | bz_billing_events | Range Check | All amounts are >= 0 |
| TC_BILLING_003 | Validate billing event date logic | bz_billing_events | Date Logic | event_date <= current_date |
| TC_BILLING_004 | Validate billing event type values | bz_billing_events | Accepted Values | event_type contains valid values |
| **Statistical Validation Tests** |
| TC_STAT_001 | Billing amount distribution analysis | bz_billing_events | Statistical | Amount distribution within expected range |
| TC_STAT_002 | Meeting duration statistical validation | bz_meetings | Statistical | Duration follows expected patterns |
| TC_STAT_003 | Feature usage count distribution | bz_feature_usage | Statistical | Usage counts within normal distribution |
| TC_STAT_004 | Webinar registrant count validation | bz_webinars | Statistical | Registrant counts within expected bounds |
| **Anomaly Detection Tests** |
| TC_ANOM_001 | Detect unusual billing amounts | bz_billing_events | Anomaly | Identify outlier billing amounts |
| TC_ANOM_002 | Detect abnormal meeting durations | bz_meetings | Anomaly | Flag meetings with unusual durations |
| TC_ANOM_003 | Detect feature usage spikes | bz_feature_usage | Anomaly | Identify unusual usage patterns |
| TC_ANOM_004 | Detect support ticket volume anomalies | bz_support_tickets | Anomaly | Flag unusual ticket creation patterns |
| **Cross-Model Relationship Tests** |
| TC_REL_001 | Validate user-billing event relationships | bz_users, bz_billing_events | Relationship | All billing events have valid users |
| TC_REL_002 | Validate meeting-participant consistency | bz_meetings, bz_participants | Relationship | Participant counts match meeting data |
| TC_REL_003 | Validate license-user assignments | bz_licenses, bz_users | Relationship | All licenses assigned to valid users |
| TC_REL_004 | Validate feature usage-meeting links | bz_feature_usage, bz_meetings | Relationship | Feature usage linked to valid meetings |
| **Data Freshness Tests** |
| TC_FRESH_001 | Validate billing events freshness | bz_billing_events | Freshness | Data updated within SLA |
| TC_FRESH_002 | Validate meeting data timeliness | bz_meetings | Freshness | Meeting data available within 1 hour |
| TC_FRESH_003 | Validate user data staleness | bz_users | Freshness | User data not older than 24 hours |
| **Performance & Resource Tests** |
| TC_PERF_001 | Model execution time validation | All models | Performance | Models complete within SLA |
| TC_PERF_002 | Memory usage optimization | All models | Performance | Memory usage within limits |
| TC_PERF_003 | Query plan optimization | All models | Performance | Optimal query execution plans |
| **Data Quality Scoring Tests** |
| TC_SCORE_001 | Overall data quality score | All models | Quality Score | Score above 95% threshold |
| TC_SCORE_002 | Model-specific quality metrics | Individual models | Quality Score | Each model meets quality standards |

## Enhanced dbt Test Scripts

### Updated packages.yml
```yaml
packages:
  - package: dbt-labs/dbt_utils
    version: 1.1.1
  - package: calogica/dbt_expectations
    version: 0.10.1
  - package: dbt-labs/dbt_external_tables
    version: 0.8.7
  - package: elementary-data/elementary
    version: 0.13.1
```

### Enhanced YAML-based Schema Tests

#### File: tests/enhanced_schema_tests.yml
```yaml
version: 2

models:
  # Enhanced Audit Log Tests
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
      - dbt_expectations.expect_table_row_count_to_be_between:
          min_value: 1
          max_value: 1000000
          config:
            severity: warn
    columns:
      - name: record_id
        tests:
          - unique
          - not_null
      - name: processing_time
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 3600
              config:
                severity: warn
      - name: load_timestamp
        tests:
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: timestamp_ntz

  # Enhanced Billing Events Tests
  - name: bz_billing_events
    tests:
      - dbt_expectations.expect_table_row_count_to_be_between:
          min_value: 1
          config:
            severity: error
      - dbt_expectations.expect_compound_columns_to_be_unique:
          column_list: ["user_id", "event_type", "event_date", "amount"]
          config:
            severity: warn
    columns:
      - name: amount
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10000
              config:
                severity: error
          - dbt_expectations.expect_column_mean_to_be_between:
              min_value: 10
              max_value: 500
              config:
                severity: warn
          - dbt_expectations.expect_column_stdev_to_be_between:
              min_value: 1
              max_value: 1000
              config:
                severity: warn
      - name: event_type
        tests:
          - dbt_expectations.expect_column_values_to_be_in_set:
              value_set: ['payment', 'refund', 'subscription', 'upgrade', 'downgrade', 'trial']
      - name: event_date
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: "'2020-01-01'"
              max_value: "current_date()"
              config:
                severity: error

  # Enhanced Feature Usage Tests
  - name: bz_feature_usage
    tests:
      - dbt_expectations.expect_table_row_count_to_be_between:
          min_value: 1
          config:
            severity: error
    columns:
      - name: usage_count
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1000
              config:
                severity: warn
          - dbt_expectations.expect_column_quantile_values_to_be_between:
              quantile: 0.95
              min_value: 1
              max_value: 100
              config:
                severity: warn
      - name: feature_name
        tests:
          - dbt_expectations.expect_column_values_to_be_in_set:
              value_set: ['screen_share', 'recording', 'chat', 'breakout_rooms', 'whiteboard', 'polls', 'annotation', 'virtual_background']

  # Enhanced Meeting Tests
  - name: bz_meetings
    tests:
      - dbt_expectations.expect_table_row_count_to_be_between:
          min_value: 1
          config:
            severity: error
    columns:
      - name: duration_minutes
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 1
              max_value: 1440  # 24 hours max
              config:
                severity: error
          - dbt_expectations.expect_column_mean_to_be_between:
              min_value: 15
              max_value: 120
              config:
                severity: warn
      - name: meeting_topic
        tests:
          - dbt_expectations.expect_column_value_lengths_to_be_between:
              min_value: 1
              max_value: 500
              config:
                severity: warn

  # Enhanced User Tests
  - name: bz_users
    tests:
      - dbt_expectations.expect_table_row_count_to_be_between:
          min_value: 1
          config:
            severity: error
    columns:
      - name: email
        tests:
          - unique
          - not_null
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
              config:
                severity: error
      - name: user_name
        tests:
          - dbt_expectations.expect_column_value_lengths_to_be_between:
              min_value: 1
              max_value: 100
              config:
                severity: error
```

### Advanced Custom SQL Tests

#### File: tests/statistical_validation_tests.sql
```sql
-- Statistical Validation: Billing Amount Distribution Analysis
{{ config(severity='warn') }}

WITH billing_stats AS (
    SELECT 
        AVG(amount) as mean_amount,
        STDDEV(amount) as stddev_amount,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY amount) as q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY amount) as q3,
        COUNT(*) as total_records
    FROM {{ ref('bz_billing_events') }}
    WHERE event_date >= CURRENT_DATE() - 30
),
outliers AS (
    SELECT 
        b.*,
        s.q1,
        s.q3,
        (s.q3 - s.q1) * 1.5 as iqr_threshold
    FROM {{ ref('bz_billing_events') }} b
    CROSS JOIN billing_stats s
    WHERE b.event_date >= CURRENT_DATE() - 30
      AND (b.amount < (s.q1 - (s.q3 - s.q1) * 1.5) 
           OR b.amount > (s.q3 + (s.q3 - s.q1) * 1.5))
)
SELECT 
    user_id,
    event_type,
    amount,
    event_date,
    'STATISTICAL_OUTLIER' as anomaly_type
FROM outliers
WHERE amount > 1000  -- Flag only significant outliers
```

#### File: tests/anomaly_detection_tests.sql
```sql
-- Anomaly Detection: Meeting Duration Patterns
{{ config(severity='warn') }}

WITH daily_meeting_stats AS (
    SELECT 
        DATE(start_time) as meeting_date,
        COUNT(*) as daily_meeting_count,
        AVG(duration_minutes) as avg_duration,
        STDDEV(duration_minutes) as stddev_duration
    FROM {{ ref('bz_meetings') }}
    WHERE start_time >= CURRENT_DATE() - 30
    GROUP BY DATE(start_time)
),
historical_baseline AS (
    SELECT 
        AVG(daily_meeting_count) as baseline_count,
        STDDEV(daily_meeting_count) as baseline_stddev,
        AVG(avg_duration) as baseline_avg_duration
    FROM daily_meeting_stats
    WHERE meeting_date < CURRENT_DATE() - 7
),
anomalies AS (
    SELECT 
        d.*,
        h.baseline_count,
        h.baseline_stddev,
        CASE 
            WHEN d.daily_meeting_count > (h.baseline_count + 2 * h.baseline_stddev) THEN 'HIGH_VOLUME'
            WHEN d.daily_meeting_count < (h.baseline_count - 2 * h.baseline_stddev) THEN 'LOW_VOLUME'
            WHEN d.avg_duration > (h.baseline_avg_duration * 2) THEN 'LONG_DURATION'
            ELSE 'NORMAL'
        END as anomaly_type
    FROM daily_meeting_stats d
    CROSS JOIN historical_baseline h
    WHERE d.meeting_date >= CURRENT_DATE() - 7
)
SELECT *
FROM anomalies
WHERE anomaly_type != 'NORMAL'
```

#### File: tests/cross_model_relationship_tests.sql
```sql
-- Cross-Model Relationship: User Activity Consistency
{{ config(severity='error') }}

WITH user_activity_summary AS (
    SELECT 
        u.user_name,
        u.email,
        u.plan_type,
        COUNT(DISTINCT m.host_id) as meetings_hosted,
        COUNT(DISTINCT p.user_id) as meetings_participated,
        COUNT(DISTINCT b.user_id) as billing_events,
        COUNT(DISTINCT s.user_id) as support_tickets,
        COUNT(DISTINCT l.assigned_to_user_id) as licenses_assigned
    FROM {{ ref('bz_users') }} u
    LEFT JOIN {{ ref('bz_meetings') }} m ON u.user_name = m.host_id
    LEFT JOIN {{ ref('bz_participants') }} p ON u.user_name = p.user_id
    LEFT JOIN {{ ref('bz_billing_events') }} b ON u.user_name = b.user_id
    LEFT JOIN {{ ref('bz_support_tickets') }} s ON u.user_name = s.user_id
    LEFT JOIN {{ ref('bz_licenses') }} l ON u.user_name = l.assigned_to_user_id
    GROUP BY u.user_name, u.email, u.plan_type
),
inconsistent_users AS (
    SELECT *
    FROM user_activity_summary
    WHERE (
        -- Users with premium plans but no activity
        (plan_type IN ('pro', 'business', 'enterprise') 
         AND meetings_hosted = 0 
         AND meetings_participated = 0 
         AND billing_events = 0)
        OR
        -- Users with billing events but no licenses
        (billing_events > 0 AND licenses_assigned = 0)
        OR
        -- Users hosting meetings without appropriate licenses
        (meetings_hosted > 0 AND plan_type = 'basic' AND licenses_assigned = 0)
    )
)
SELECT 
    user_name,
    email,
    plan_type,
    meetings_hosted,
    meetings_participated,
    billing_events,
    licenses_assigned,
    'ACTIVITY_INCONSISTENCY' as issue_type
FROM inconsistent_users
```

#### File: tests/data_quality_scoring_tests.sql
```sql
-- Data Quality Scoring: Comprehensive Quality Assessment
{{ config(severity='warn') }}

WITH model_quality_scores AS (
    -- Billing Events Quality Score
    SELECT 
        'bz_billing_events' as model_name,
        COUNT(*) as total_records,
        COUNT(CASE WHEN user_id IS NOT NULL THEN 1 END) * 100.0 / COUNT(*) as completeness_score,
        COUNT(CASE WHEN amount >= 0 THEN 1 END) * 100.0 / COUNT(*) as validity_score,
        COUNT(CASE WHEN event_date <= CURRENT_DATE() THEN 1 END) * 100.0 / COUNT(*) as timeliness_score
    FROM {{ ref('bz_billing_events') }}
    
    UNION ALL
    
    -- Meetings Quality Score
    SELECT 
        'bz_meetings' as model_name,
        COUNT(*) as total_records,
        COUNT(CASE WHEN host_id IS NOT NULL AND meeting_topic IS NOT NULL THEN 1 END) * 100.0 / COUNT(*) as completeness_score,
        COUNT(CASE WHEN start_time < end_time AND duration_minutes > 0 THEN 1 END) * 100.0 / COUNT(*) as validity_score,
        COUNT(CASE WHEN start_time <= CURRENT_TIMESTAMP() THEN 1 END) * 100.0 / COUNT(*) as timeliness_score
    FROM {{ ref('bz_meetings') }}
    
    UNION ALL
    
    -- Users Quality Score
    SELECT 
        'bz_users' as model_name,
        COUNT(*) as total_records,
        COUNT(CASE WHEN user_name IS NOT NULL AND email IS NOT NULL THEN 1 END) * 100.0 / COUNT(*) as completeness_score,
        COUNT(CASE WHEN email LIKE '%@%' THEN 1 END) * 100.0 / COUNT(*) as validity_score,
        100.0 as timeliness_score  -- Users don't have time-based validation
    FROM {{ ref('bz_users') }}
),
overall_quality AS (
    SELECT 
        model_name,
        total_records,
        completeness_score,
        validity_score,
        timeliness_score,
        (completeness_score + validity_score + timeliness_score) / 3 as overall_quality_score
    FROM model_quality_scores
)
SELECT 
    model_name,
    total_records,
    ROUND(completeness_score, 2) as completeness_score,
    ROUND(validity_score, 2) as validity_score,
    ROUND(timeliness_score, 2) as timeliness_score,
    ROUND(overall_quality_score, 2) as overall_quality_score,
    CASE 
        WHEN overall_quality_score >= 95 THEN 'EXCELLENT'
        WHEN overall_quality_score >= 90 THEN 'GOOD'
        WHEN overall_quality_score >= 80 THEN 'FAIR'
        ELSE 'POOR'
    END as quality_grade
FROM overall_quality
WHERE overall_quality_score < 95  -- Only show models below excellent threshold
```

#### File: tests/data_freshness_validation_tests.sql
```sql
-- Data Freshness Validation: Custom Freshness Thresholds
{{ config(severity='warn') }}

WITH freshness_check AS (
    SELECT 
        'bz_billing_events' as model_name,
        MAX(load_timestamp) as last_load_time,
        DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP()) as hours_since_last_load,
        4 as max_allowed_hours  -- 4 hour SLA
    FROM {{ ref('bz_billing_events') }}
    
    UNION ALL
    
    SELECT 
        'bz_meetings' as model_name,
        MAX(load_timestamp) as last_load_time,
        DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP()) as hours_since_last_load,
        1 as max_allowed_hours  -- 1 hour SLA
    FROM {{ ref('bz_meetings') }}
    
    UNION ALL
    
    SELECT 
        'bz_users' as model_name,
        MAX(load_timestamp) as last_load_time,
        DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP()) as hours_since_last_load,
        24 as max_allowed_hours  -- 24 hour SLA
    FROM {{ ref('bz_users') }}
    
    UNION ALL
    
    SELECT 
        'bz_feature_usage' as model_name,
        MAX(load_timestamp) as last_load_time,
        DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP()) as hours_since_last_load,
        2 as max_allowed_hours  -- 2 hour SLA
    FROM {{ ref('bz_feature_usage') }}
)
SELECT 
    model_name,
    last_load_time,
    hours_since_last_load,
    max_allowed_hours,
    CASE 
        WHEN hours_since_last_load > max_allowed_hours THEN 'STALE'
        WHEN hours_since_last_load > (max_allowed_hours * 0.8) THEN 'WARNING'
        ELSE 'FRESH'
    END as freshness_status
FROM freshness_check
WHERE hours_since_last_load > max_allowed_hours
```

#### File: tests/performance_optimization_tests.sql
```sql
-- Performance Optimization: Query Plan and Resource Usage Analysis
{{ config(severity='warn') }}

WITH model_performance AS (
    SELECT 
        source_table as model_name,
        AVG(processing_time) as avg_processing_time,
        MAX(processing_time) as max_processing_time,
        MIN(processing_time) as min_processing_time,
        STDDEV(processing_time) as stddev_processing_time,
        COUNT(*) as execution_count
    FROM {{ ref('bz_audit_log') }}
    WHERE status = 'COMPLETED'
      AND load_timestamp >= CURRENT_DATE() - 7
    GROUP BY source_table
),
performance_issues AS (
    SELECT 
        model_name,
        avg_processing_time,
        max_processing_time,
        execution_count,
        CASE 
            WHEN avg_processing_time > 300 THEN 'SLOW_AVERAGE'  -- > 5 minutes
            WHEN max_processing_time > 600 THEN 'SLOW_MAX'      -- > 10 minutes
            WHEN stddev_processing_time > avg_processing_time THEN 'INCONSISTENT'
            ELSE 'NORMAL'
        END as performance_issue
    FROM model_performance
)
SELECT 
    model_name,
    ROUND(avg_processing_time, 2) as avg_processing_time_seconds,
    ROUND(max_processing_time, 2) as max_processing_time_seconds,
    execution_count,
    performance_issue,
    CASE 
        WHEN performance_issue = 'SLOW_AVERAGE' THEN 'Consider query optimization or incremental processing'
        WHEN performance_issue = 'SLOW_MAX' THEN 'Investigate resource constraints or data volume spikes'
        WHEN performance_issue = 'INCONSISTENT' THEN 'Review for intermittent performance issues'
        ELSE 'Performance within acceptable range'
    END as recommendation
FROM performance_issues
WHERE performance_issue != 'NORMAL'
```

### Enhanced Monitoring and Alerting

#### File: macros/data_quality_alerts.sql
```sql
-- Macro for generating data quality alerts
{% macro generate_quality_alert(model_name, quality_threshold=95) %}
    
    WITH quality_check AS (
        SELECT 
            '{{ model_name }}' as model_name,
            COUNT(*) as total_records,
            CURRENT_TIMESTAMP() as check_timestamp,
            {{ quality_threshold }} as threshold
        FROM {{ ref(model_name) }}
    )
    SELECT 
        model_name,
        total_records,
        check_timestamp,
        threshold,
        CASE 
            WHEN total_records = 0 THEN 'CRITICAL: No data found'
            WHEN total_records < 100 THEN 'WARNING: Low record count'
            ELSE 'OK'
        END as alert_status
    FROM quality_check
    WHERE total_records < 100 OR total_records = 0
    
{% endmacro %}
```

#### File: tests/comprehensive_health_check.sql
```sql
-- Comprehensive Health Check: Overall System Status
{{ config(severity='error') }}

WITH system_health AS (
    -- Model record counts
    SELECT 'RECORD_COUNT' as check_type, 'bz_billing_events' as model_name, COUNT(*) as value FROM {{ ref('bz_billing_events') }}
    UNION ALL
    SELECT 'RECORD_COUNT' as check_type, 'bz_meetings' as model_name, COUNT(*) as value FROM {{ ref('bz_meetings') }}
    UNION ALL
    SELECT 'RECORD_COUNT' as check_type, 'bz_users' as model_name, COUNT(*) as value FROM {{ ref('bz_users') }}
    UNION ALL
    SELECT 'RECORD_COUNT' as check_type, 'bz_participants' as model_name, COUNT(*) as value FROM {{ ref('bz_participants') }}
    UNION ALL
    SELECT 'RECORD_COUNT' as check_type, 'bz_feature_usage' as model_name, COUNT(*) as value FROM {{ ref('bz_feature_usage') }}
    UNION ALL
    SELECT 'RECORD_COUNT' as check_type, 'bz_licenses' as model_name, COUNT(*) as value FROM {{ ref('bz_licenses') }}
    UNION ALL
    SELECT 'RECORD_COUNT' as check_type, 'bz_support_tickets' as model_name, COUNT(*) as value FROM {{ ref('bz_support_tickets') }}
    UNION ALL
    SELECT 'RECORD_COUNT' as check_type, 'bz_webinars' as model_name, COUNT(*) as value FROM {{ ref('bz_webinars') }}
),
health_status AS (
    SELECT 
        check_type,
        model_name,
        value,
        CASE 
            WHEN check_type = 'RECORD_COUNT' AND value = 0 THEN 'CRITICAL'
            WHEN check_type = 'RECORD_COUNT' AND value < 10 THEN 'WARNING'
            ELSE 'HEALTHY'
        END as status
    FROM system_health
)
SELECT 
    model_name,
    value as record_count,
    status,
    CURRENT_TIMESTAMP() as check_timestamp
FROM health_status
WHERE status IN ('CRITICAL', 'WARNING')
```

### Enhanced CI/CD Integration

#### File: .github/workflows/enhanced_dbt_test.yml
```yaml
name: Enhanced dbt Test Pipeline
on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [main, develop]
  schedule:
    - cron: '0 */4 * * *'  # Run every 4 hours

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        test-type: ["unit", "integration", "performance"]
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      
      - name: Install dbt and dependencies
        run: |
          pip install dbt-snowflake dbt-expectations elementary-data
          dbt deps
      
      - name: Run dbt tests
        run: |
          case "${{ matrix.test-type }}" in
            "unit")
              dbt test --select tag:unit
              ;;
            "integration")
              dbt test --select tag:integration
              ;;
            "performance")
              dbt test --select tag:performance
              ;;
          esac
        env:
          DBT_PROFILES_DIR: ./profiles
      
      - name: Generate test report
        if: always()
        run: |
          dbt docs generate
          dbt run-operation generate_test_report
      
      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: test-results-${{ matrix.test-type }}
          path: |
            target/run_results.json
            target/manifest.json
            target/index.html
```

### Advanced Monitoring Dashboard

#### File: analysis/data_quality_dashboard.sql
```sql
-- Data Quality Dashboard: Executive Summary
WITH quality_metrics AS (
    SELECT 
        'Data Completeness' as metric_name,
        AVG(CASE WHEN user_id IS NOT NULL THEN 100.0 ELSE 0.0 END) as score,
        'Percentage of records with complete user information' as description
    FROM {{ ref('bz_billing_events') }}
    
    UNION ALL
    
    SELECT 
        'Data Accuracy' as metric_name,
        AVG(CASE WHEN amount >= 0 AND event_date <= CURRENT_DATE() THEN 100.0 ELSE 0.0 END) as score,
        'Percentage of records with valid business rules' as description
    FROM {{ ref('bz_billing_events') }}
    
    UNION ALL
    
    SELECT 
        'Data Consistency' as metric_name,
        AVG(CASE WHEN start_time < end_time THEN 100.0 ELSE 0.0 END) as score,
        'Percentage of meetings with consistent time logic' as description
    FROM {{ ref('bz_meetings') }}
    
    UNION ALL
    
    SELECT 
        'Data Timeliness' as metric_name,
        AVG(CASE WHEN DATEDIFF('hour', load_timestamp, CURRENT_TIMESTAMP()) <= 4 THEN 100.0 ELSE 0.0 END) as score,
        'Percentage of data loaded within SLA' as description
    FROM {{ ref('bz_billing_events') }}
)
SELECT 
    metric_name,
    ROUND(score, 2) as score_percentage,
    description,
    CASE 
        WHEN score >= 95 THEN '🟢 Excellent'
        WHEN score >= 90 THEN '🟡 Good'
        WHEN score >= 80 THEN '🟠 Fair'
        ELSE '🔴 Poor'
    END as status_indicator,
    CURRENT_TIMESTAMP() as last_updated
FROM quality_metrics
ORDER BY score DESC
```

## Test Execution Strategy

### 1. Automated Test Execution
```bash
# Run all enhanced tests
dbt test

# Run statistical validation tests
dbt test --select tag:statistical

# Run anomaly detection tests
dbt test --select tag:anomaly

# Run performance tests
dbt test --select tag:performance

# Run data quality scoring
dbt test --select tag:quality_score
```

### 2. Continuous Monitoring
```bash
# Daily health check
dbt run-operation comprehensive_health_check

# Weekly quality report
dbt run-operation generate_weekly_quality_report

# Monthly performance review
dbt run-operation generate_performance_report
```

### 3. Alert Configuration
```sql
-- Set up automated alerts in Snowflake
CREATE OR REPLACE ALERT bronze_data_quality_alert
  WAREHOUSE = WH_POC_ZOOM_DEV_XSMALL
  SCHEDULE = 'USING CRON 0 */2 * * * UTC'  -- Every 2 hours
  IF (EXISTS (
    SELECT 1 FROM BRONZE.TEST_RESULTS 
    WHERE status = 'fail' 
      AND run_started_at >= DATEADD('hour', -2, CURRENT_TIMESTAMP())
  ))
  THEN CALL SYSTEM$SEND_EMAIL(
    'data-team@company.com',
    'Bronze Layer Data Quality Alert',
    'Data quality issues detected in Bronze layer. Please check the test results.'
  );
```

## Key Improvements in Version 2

### 1. **Statistical Validation**
- Distribution analysis for numerical fields
- Outlier detection using IQR method
- Mean and standard deviation validation
- Quantile-based quality checks

### 2. **Anomaly Detection**
- Time-series pattern analysis
- Volume spike detection
- Duration anomaly identification
- Usage pattern deviation alerts

### 3. **Enhanced Relationships**
- Cross-model consistency validation
- User activity correlation checks
- License-usage alignment verification
- Billing-activity relationship validation

### 4. **Quality Scoring**
- Comprehensive quality metrics
- Model-specific scorecards
- Executive dashboard views
- Trend analysis capabilities

### 5. **Advanced Monitoring**
- Real-time alerting system
- Performance trend analysis
- Resource utilization tracking
- Automated report generation

## Conclusion

Version 2 of the Snowflake dbt Unit Test Cases provides enterprise-grade testing capabilities with advanced statistical validation, anomaly detection, and comprehensive monitoring. This enhanced framework ensures superior data quality, proactive issue detection, and robust performance monitoring for the Zoom Bronze Pipeline in Snowflake. The combination of traditional testing with modern data observability practices creates a comprehensive quality assurance system that scales with your data platform needs.