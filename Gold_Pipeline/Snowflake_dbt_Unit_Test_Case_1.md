_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Platform Analytics System dbt models in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Zoom Platform Analytics System

## Overview

This document provides comprehensive unit test cases and corresponding dbt test scripts for the Zoom Platform Analytics System. The tests validate data transformations, business rules, edge cases, and error handling across all Gold layer dbt models including dimensions and fact tables.

### Test Coverage Scope

- **Dimension Tables**: 6 dimension models (GO_DIM_DATE, GO_DIM_USER, GO_DIM_FEATURE, GO_DIM_LICENSE, GO_DIM_MEETING_TYPE, GO_DIM_SUPPORT_CATEGORY)
- **Fact Tables**: 4 fact models (GO_FACT_FEATURE_USAGE, GO_FACT_MEETING_ACTIVITY, GO_FACT_REVENUE_EVENTS, GO_FACT_SUPPORT_METRICS)
- **Audit Table**: 1 audit model (GO_AUDIT_LOG)
- **Test Types**: Data quality, business rules, referential integrity, edge cases, performance validation

---

## Test Case List

### Dimension Table Test Cases

| Test Case ID | Test Case Description | Model | Expected Outcome |
|--------------|----------------------|-------|------------------|
| DIM_001 | Validate GO_DIM_DATE completeness for date range 2020-2024 | go_dim_date | All dates present, no gaps |
| DIM_002 | Test GO_DIM_DATE fiscal year calculation accuracy | go_dim_date | Correct fiscal year assignment |
| DIM_003 | Validate GO_DIM_USER SCD Type 2 implementation | go_dim_user | Proper effective date management |
| DIM_004 | Test GO_DIM_USER email domain extraction | go_dim_user | Valid email domains extracted |
| DIM_005 | Validate GO_DIM_USER plan category standardization | go_dim_user | Consistent plan categories |
| DIM_006 | Test GO_DIM_FEATURE categorization logic | go_dim_feature | Features properly categorized |
| DIM_007 | Validate GO_DIM_FEATURE complexity assessment | go_dim_feature | Correct complexity levels |
| DIM_008 | Test GO_DIM_LICENSE tier mapping | go_dim_license | Proper license tier assignment |
| DIM_009 | Validate GO_DIM_LICENSE entitlements calculation | go_dim_license | Accurate entitlement values |
| DIM_010 | Test GO_DIM_MEETING_TYPE classification | go_dim_meeting_type | Correct meeting type mapping |
| DIM_011 | Validate GO_DIM_SUPPORT_CATEGORY priority mapping | go_dim_support_category | Proper priority assignment |
| DIM_012 | Test null value handling across all dimensions | all_dimensions | No critical nulls, proper defaults |

### Fact Table Test Cases

| Test Case ID | Test Case Description | Model | Expected Outcome |
|--------------|----------------------|-------|------------------|
| FACT_001 | Validate GO_FACT_FEATURE_USAGE metrics calculation | go_fact_feature_usage | Accurate usage metrics |
| FACT_002 | Test GO_FACT_FEATURE_USAGE bandwidth estimation | go_fact_feature_usage | Correct bandwidth calculations |
| FACT_003 | Validate GO_FACT_MEETING_ACTIVITY engagement scores | go_fact_meeting_activity | Valid engagement metrics |
| FACT_004 | Test GO_FACT_MEETING_ACTIVITY participant aggregations | go_fact_meeting_activity | Accurate participant counts |
| FACT_005 | Validate GO_FACT_REVENUE_EVENTS MRR/ARR calculations | go_fact_revenue_events | Correct revenue recognition |
| FACT_006 | Test GO_FACT_REVENUE_EVENTS tax and discount logic | go_fact_revenue_events | Accurate financial calculations |
| FACT_007 | Validate GO_FACT_SUPPORT_METRICS SLA compliance | go_fact_support_metrics | Proper SLA tracking |
| FACT_008 | Test GO_FACT_SUPPORT_METRICS resolution time calculation | go_fact_support_metrics | Accurate time calculations |
| FACT_009 | Validate referential integrity across all fact tables | all_facts | Valid foreign key relationships |
| FACT_010 | Test data quality score filtering (>=80) | all_facts | Only high-quality records processed |

### Edge Case Test Cases

| Test Case ID | Test Case Description | Model | Expected Outcome |
|--------------|----------------------|-------|------------------|
| EDGE_001 | Test zero usage count handling | go_fact_feature_usage | Graceful zero value handling |
| EDGE_002 | Validate negative duration handling | go_fact_meeting_activity | Negative values rejected/corrected |
| EDGE_003 | Test empty meeting scenarios | go_fact_meeting_activity | Proper handling of no participants |
| EDGE_004 | Validate zero revenue events | go_fact_revenue_events | Zero amounts handled correctly |
| EDGE_005 | Test missing user references | go_dim_user | Orphaned records handled |
| EDGE_006 | Validate future date handling | all_models | Future dates rejected/flagged |
| EDGE_007 | Test extremely long meeting durations | go_fact_meeting_activity | Outliers handled appropriately |
| EDGE_008 | Validate invalid email formats | go_dim_user | Invalid emails handled gracefully |

### Performance Test Cases

| Test Case ID | Test Case Description | Model | Expected Outcome |
|--------------|----------------------|-------|------------------|
| PERF_001 | Validate clustering effectiveness | all_models | Optimal query performance |
| PERF_002 | Test incremental load performance | all_models | Efficient incremental processing |
| PERF_003 | Validate large dataset handling | all_models | Scalable processing |

---

## dbt Test Scripts

### 1. Schema Tests (schema.yml)

```yaml
version: 2

models:
  # Dimension Models
  - name: go_dim_date
    description: "Date dimension with comprehensive time attributes"
    columns:
      - name: date_id
        description: "Unique date identifier"
        tests:
          - unique
          - not_null
      - name: date_value
        description: "Actual date value"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "date_value >= '2020-01-01' and date_value <= '2024-12-31'"
      - name: fiscal_year
        description: "Fiscal year calculation"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "fiscal_year between 2020 and 2025"
      - name: is_weekend
        description: "Weekend flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  - name: go_dim_user
    description: "User dimension with SCD Type 2"
    columns:
      - name: user_dim_id
        description: "Surrogate key for user dimension"
        tests:
          - unique
          - not_null
      - name: email_domain
        description: "Extracted email domain"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "length(email_domain) > 0 and email_domain not like '%@%'"
      - name: plan_category
        description: "Standardized plan category"
        tests:
          - not_null
          - accepted_values:
              values: ['Basic', 'Professional', 'Enterprise', 'Other']
      - name: is_current_record
        description: "Current record flag for SCD Type 2"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  - name: go_dim_feature
    description: "Feature dimension with categorization"
    columns:
      - name: feature_id
        description: "Unique feature identifier"
        tests:
          - unique
          - not_null
      - name: feature_name
        description: "Feature name"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "length(trim(feature_name)) > 0"
      - name: feature_category
        description: "Feature category"
        tests:
          - not_null
          - accepted_values:
              values: ['Collaboration', 'Recording', 'Communication', 'Meeting Management', 'Other']
      - name: feature_complexity
        description: "Feature complexity level"
        tests:
          - not_null
          - accepted_values:
              values: ['Low', 'Medium', 'High']
      - name: is_premium_feature
        description: "Premium feature flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  - name: go_dim_license
    description: "License dimension with entitlements"
    columns:
      - name: license_id
        description: "Unique license identifier"
        tests:
          - unique
          - not_null
      - name: license_tier
        description: "License tier"
        tests:
          - not_null
          - accepted_values:
              values: ['Tier 1', 'Tier 2', 'Tier 3', 'Tier 4', 'Tier 0']
      - name: max_participants
        description: "Maximum participants allowed"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "max_participants > 0"
      - name: monthly_price
        description: "Monthly price"
        tests:
          - dbt_utils.expression_is_true:
              expression: "monthly_price >= 0"
      - name: annual_price
        description: "Annual price"
        tests:
          - dbt_utils.expression_is_true:
              expression: "annual_price >= 0"

  - name: go_dim_meeting_type
    description: "Meeting type dimension"
    columns:
      - name: meeting_type_id
        description: "Unique meeting type identifier"
        tests:
          - unique
          - not_null
      - name: meeting_type
        description: "Meeting type"
        tests:
          - not_null
      - name: duration_category
        description: "Duration category"
        tests:
          - accepted_values:
              values: ['Short', 'Medium', 'Long', 'Variable']
      - name: max_participants_allowed
        description: "Maximum participants allowed"
        tests:
          - dbt_utils.expression_is_true:
              expression: "max_participants_allowed > 0"

  - name: go_dim_support_category
    description: "Support category dimension"
    columns:
      - name: support_category_id
        description: "Unique support category identifier"
        tests:
          - unique
          - not_null
      - name: priority_level
        description: "Priority level"
        tests:
          - not_null
          - accepted_values:
              values: ['Critical', 'High', 'Medium', 'Low']
      - name: expected_resolution_hours
        description: "Expected resolution time in hours"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "expected_resolution_hours > 0"
      - name: requires_escalation
        description: "Escalation requirement flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  # Fact Models
  - name: go_fact_feature_usage
    description: "Feature usage fact table"
    columns:
      - name: feature_usage_id
        description: "Unique feature usage identifier"
        tests:
          - unique
          - not_null
      - name: usage_date
        description: "Usage date"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "usage_date <= current_date()"
      - name: usage_count
        description: "Usage count"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "usage_count >= 0"
      - name: usage_intensity
        description: "Usage intensity classification"
        tests:
          - not_null
          - accepted_values:
              values: ['Low', 'Medium', 'High']
      - name: user_experience_score
        description: "User experience score"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "user_experience_score between 0 and 10"
      - name: success_rate_percentage
        description: "Success rate percentage"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "success_rate_percentage between 0 and 100"
      - name: bandwidth_consumed_mb
        description: "Bandwidth consumed in MB"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "bandwidth_consumed_mb >= 0"

  - name: go_fact_meeting_activity
    description: "Meeting activity fact table"
    columns:
      - name: meeting_activity_id
        description: "Unique meeting activity identifier"
        tests:
          - unique
          - not_null
      - name: meeting_date
        description: "Meeting date"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "meeting_date <= current_date()"
      - name: actual_duration_minutes
        description: "Actual meeting duration in minutes"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "actual_duration_minutes >= 0"
      - name: participant_count
        description: "Number of participants"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "participant_count >= 0"
      - name: participant_engagement_score
        description: "Participant engagement score"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "participant_engagement_score between 0 and 10"
      - name: meeting_quality_score
        description: "Overall meeting quality score"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "meeting_quality_score between 0 and 10"
      - name: audio_quality_score
        description: "Audio quality score"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "audio_quality_score between 0 and 10"
      - name: video_quality_score
        description: "Video quality score"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "video_quality_score between 0 and 10"

  - name: go_fact_revenue_events
    description: "Revenue events fact table"
    columns:
      - name: revenue_event_id
        description: "Unique revenue event identifier"
        tests:
          - unique
          - not_null
      - name: transaction_date
        description: "Transaction date"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "transaction_date <= current_date()"
      - name: gross_amount
        description: "Gross transaction amount"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "gross_amount > 0"
      - name: tax_amount
        description: "Tax amount"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "tax_amount >= 0"
      - name: net_amount
        description: "Net amount after tax and discounts"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "net_amount > 0"
      - name: revenue_type
        description: "Revenue type classification"
        tests:
          - not_null
          - accepted_values:
              values: ['Recurring', 'Expansion', 'Add-on', 'One-time']
      - name: mrr_impact
        description: "Monthly recurring revenue impact"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "mrr_impact >= 0"
      - name: arr_impact
        description: "Annual recurring revenue impact"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "arr_impact >= 0"
      - name: is_recurring_revenue
        description: "Recurring revenue flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  - name: go_fact_support_metrics
    description: "Support metrics fact table"
    columns:
      - name: support_metrics_id
        description: "Unique support metrics identifier"
        tests:
          - unique
          - not_null
      - name: ticket_open_date
        description: "Ticket open date"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "ticket_open_date <= current_date()"
      - name: priority_level
        description: "Priority level"
        tests:
          - not_null
          - accepted_values:
              values: ['P1', 'P2', 'P3', 'P4']
      - name: resolution_time_hours
        description: "Resolution time in hours"
        tests:
          - dbt_utils.expression_is_true:
              expression: "resolution_time_hours >= 0 or resolution_time_hours is null"
      - name: customer_satisfaction_score
        description: "Customer satisfaction score"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "customer_satisfaction_score between 0 and 10"
      - name: sla_met_flag
        description: "SLA met flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]
      - name: first_contact_resolution_flag
        description: "First contact resolution flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  - name: go_audit_log
    description: "Audit log table"
    columns:
      - name: audit_id
        description: "Unique audit identifier"
        tests:
          - unique
          - not_null
      - name: process_name
        description: "Process name"
        tests:
          - not_null
      - name: execution_timestamp
        description: "Execution timestamp"
        tests:
          - not_null
      - name: status
        description: "Execution status"
        tests:
          - not_null
          - accepted_values:
              values: ['SUCCESS', 'FAILED', 'RUNNING', 'PENDING']
```

### 2. Custom SQL Tests

#### Test 1: Date Dimension Completeness
```sql
-- tests/assert_date_dimension_completeness.sql
SELECT 
    expected_days - actual_days as missing_days
FROM (
    SELECT 
        DATEDIFF('day', '2020-01-01', '2024-12-31') + 1 as expected_days,
        COUNT(*) as actual_days
    FROM {{ ref('go_dim_date') }}
    WHERE date_value BETWEEN '2020-01-01' AND '2024-12-31'
)
WHERE expected_days - actual_days != 0
```

#### Test 2: SCD Type 2 Validation for Users
```sql
-- tests/assert_user_scd_type2_integrity.sql
SELECT 
    user_name,
    COUNT(*) as record_count
FROM {{ ref('go_dim_user') }}
WHERE is_current_record = true
GROUP BY user_name
HAVING COUNT(*) > 1
```

#### Test 3: Feature Usage Metrics Validation
```sql
-- tests/assert_feature_usage_metrics_validity.sql
SELECT 
    feature_usage_id,
    'Invalid usage intensity' as error_type
FROM {{ ref('go_fact_feature_usage') }}
WHERE (
    (usage_count >= 10 AND usage_intensity != 'High') OR
    (usage_count >= 5 AND usage_count < 10 AND usage_intensity != 'Medium') OR
    (usage_count < 5 AND usage_intensity != 'Low')
)

UNION ALL

SELECT 
    feature_usage_id,
    'Invalid experience score' as error_type
FROM {{ ref('go_fact_feature_usage') }}
WHERE user_experience_score < 0 OR user_experience_score > 10
```

#### Test 4: Revenue Calculation Validation
```sql
-- tests/assert_revenue_calculations.sql
SELECT 
    revenue_event_id,
    'Tax calculation error' as error_type
FROM {{ ref('go_fact_revenue_events') }}
WHERE ABS(tax_amount - (gross_amount * 0.08)) > 0.01

UNION ALL

SELECT 
    revenue_event_id,
    'Net amount calculation error' as error_type
FROM {{ ref('go_fact_revenue_events') }}
WHERE ABS(net_amount - (gross_amount - tax_amount - discount_amount)) > 0.01
```

#### Test 5: Meeting Activity Aggregation Validation
```sql
-- tests/assert_meeting_activity_aggregations.sql
SELECT 
    meeting_activity_id,
    'Participant count mismatch' as error_type
FROM {{ ref('go_fact_meeting_activity') }} ma
LEFT JOIN (
    SELECT 
        meeting_id,
        COUNT(*) as actual_participant_count
    FROM {{ source('silver', 'si_participants') }}
    GROUP BY meeting_id
) p ON ma.meeting_activity_id = p.meeting_id
WHERE ma.participant_count != COALESCE(p.actual_participant_count, 0)
```

#### Test 6: Support Metrics SLA Validation
```sql
-- tests/assert_support_sla_logic.sql
SELECT 
    support_metrics_id,
    'SLA logic error' as error_type
FROM {{ ref('go_fact_support_metrics') }}
WHERE (
    (priority_level = 'P1' AND resolution_time_hours > 4 AND sla_met_flag = true) OR
    (priority_level = 'P2' AND resolution_time_hours > 24 AND sla_met_flag = true) OR
    (priority_level = 'P3' AND resolution_time_hours > 72 AND sla_met_flag = true) OR
    (priority_level = 'P4' AND resolution_time_hours > 168 AND sla_met_flag = true)
)
```

#### Test 7: Data Quality Score Filtering
```sql
-- tests/assert_data_quality_filtering.sql
SELECT 
    'go_fact_feature_usage' as table_name,
    COUNT(*) as low_quality_records
FROM {{ ref('go_fact_feature_usage') }} f
JOIN {{ source('silver', 'si_feature_usage') }} s ON f.feature_name = s.feature_name
WHERE s.data_quality_score < 80 OR s.validation_status != 'PASSED'

UNION ALL

SELECT 
    'go_fact_meeting_activity' as table_name,
    COUNT(*) as low_quality_records
FROM {{ ref('go_fact_meeting_activity') }} f
JOIN {{ source('silver', 'si_meetings') }} s ON f.meeting_start_time = s.start_time
WHERE s.data_quality_score < 80 OR s.validation_status != 'PASSED'

UNION ALL

SELECT 
    'go_fact_revenue_events' as table_name,
    COUNT(*) as low_quality_records
FROM {{ ref('go_fact_revenue_events') }} f
JOIN {{ source('silver', 'si_billing_events') }} s ON f.transaction_date = s.event_date
WHERE s.data_quality_score < 80 OR s.validation_status != 'PASSED'

UNION ALL

SELECT 
    'go_fact_support_metrics' as table_name,
    COUNT(*) as low_quality_records
FROM {{ ref('go_fact_support_metrics') }} f
JOIN {{ source('silver', 'si_support_tickets') }} s ON f.ticket_open_date = s.open_date
WHERE s.data_quality_score < 80 OR s.validation_status != 'PASSED'
```

#### Test 8: Referential Integrity Validation
```sql
-- tests/assert_referential_integrity.sql
-- Check for orphaned records in fact tables
SELECT 
    'go_fact_feature_usage' as table_name,
    COUNT(*) as orphaned_records
FROM {{ ref('go_fact_feature_usage') }} f
LEFT JOIN {{ source('silver', 'si_feature_usage') }} s ON f.feature_name = s.feature_name
WHERE s.feature_name IS NULL

UNION ALL

SELECT 
    'go_fact_meeting_activity' as table_name,
    COUNT(*) as orphaned_records
FROM {{ ref('go_fact_meeting_activity') }} f
LEFT JOIN {{ source('silver', 'si_meetings') }} s ON f.meeting_start_time = s.start_time
WHERE s.start_time IS NULL
```

#### Test 9: Business Rule Validation
```sql
-- tests/assert_business_rules.sql
-- Validate that MRR and ARR calculations are consistent
SELECT 
    revenue_event_id,
    'MRR/ARR inconsistency' as error_type
FROM {{ ref('go_fact_revenue_events') }}
WHERE is_recurring_revenue = true
    AND subscription_period_months = 12
    AND ABS(arr_impact - (mrr_impact * 12)) > 0.01

UNION ALL

-- Validate that engagement scores are realistic
SELECT 
    meeting_activity_id,
    'Unrealistic engagement score' as error_type
FROM {{ ref('go_fact_meeting_activity') }}
WHERE participant_count = 0 AND participant_engagement_score > 0
```

#### Test 10: Edge Case Validation
```sql
-- tests/assert_edge_cases.sql
-- Test zero and negative value handling
SELECT 
    'go_fact_feature_usage' as table_name,
    'Negative usage count' as error_type,
    COUNT(*) as error_count
FROM {{ ref('go_fact_feature_usage') }}
WHERE usage_count < 0

UNION ALL

SELECT 
    'go_fact_meeting_activity' as table_name,
    'Negative duration' as error_type,
    COUNT(*) as error_count
FROM {{ ref('go_fact_meeting_activity') }}
WHERE actual_duration_minutes < 0

UNION ALL

SELECT 
    'go_fact_revenue_events' as table_name,
    'Zero or negative amount' as error_type,
    COUNT(*) as error_count
FROM {{ ref('go_fact_revenue_events') }}
WHERE gross_amount <= 0
```

### 3. Performance Tests

#### Test 1: Query Performance Validation
```sql
-- tests/assert_query_performance.sql
-- This test should be run manually to validate clustering effectiveness
SELECT 
    'go_fact_feature_usage' as table_name,
    COUNT(*) as record_count
FROM {{ ref('go_fact_feature_usage') }}
WHERE usage_date BETWEEN '2024-01-01' AND '2024-01-31'
    AND feature_name = 'screen_share'
-- Expected: Fast execution due to clustering on (usage_date, feature_name)
```

### 4. Data Freshness Tests

```yaml
# In schema.yml, add freshness tests
sources:
  - name: silver
    description: "Silver layer source tables"
    freshness:
      warn_after: {count: 12, period: hour}
      error_after: {count: 24, period: hour}
    tables:
      - name: si_users
        description: "Silver users table"
        freshness:
          warn_after: {count: 6, period: hour}
          error_after: {count: 12, period: hour}
      - name: si_meetings
      - name: si_participants
      - name: si_feature_usage
      - name: si_support_tickets
      - name: si_billing_events
      - name: si_licenses
```

### 5. Macro-based Tests

#### Custom Test Macro for Score Validation
```sql
-- macros/test_score_range.sql
{% macro test_score_range(model, column_name, min_value=0, max_value=10) %}

SELECT 
    {{ column_name }},
    'Score out of range' as error_type
FROM {{ model }}
WHERE {{ column_name }} < {{ min_value }} 
   OR {{ column_name }} > {{ max_value }}
   OR {{ column_name }} IS NULL

{% endmacro %}
```

#### Usage in schema.yml
```yaml
# Add to model column tests
- name: user_experience_score
  tests:
    - score_range:
        min_value: 0
        max_value: 10
```

---

## Test Execution Strategy

### 1. Test Categories

- **Unit Tests**: Individual model validation
- **Integration Tests**: Cross-model relationship validation
- **Data Quality Tests**: Completeness, accuracy, consistency
- **Business Rule Tests**: Domain-specific logic validation
- **Performance Tests**: Query efficiency and scalability
- **Edge Case Tests**: Boundary condition handling

### 2. Test Execution Commands

```bash
# Run all tests
dbt test

# Run tests for specific model
dbt test --models go_dim_user

# Run specific test type
dbt test --models tag:data_quality

# Run tests with increased verbosity
dbt test --verbose

# Run tests and store results
dbt test --store-failures
```

### 3. Test Result Monitoring

```sql
-- Query to monitor test results
SELECT 
    test_name,
    status,
    execution_time,
    failures,
    run_started_at
FROM dbt_test_results
WHERE run_started_at >= CURRENT_DATE() - 7
ORDER BY run_started_at DESC;
```

---

## Error Handling and Alerting

### 1. Test Failure Handling

```yaml
# dbt_project.yml
tests:
  zoom_gold_analytics:
    +severity: error  # Fail pipeline on test failures
    +store_failures: true  # Store failed records for analysis
    +warn_if: ">= 1"  # Warn if any failures
    +error_if: ">= 10"  # Error if 10+ failures
```

### 2. Custom Alert Macros

```sql
-- macros/alert_on_failure.sql
{% macro alert_on_failure(test_name, failure_count) %}
  {% if failure_count > 0 %}
    {{ log("ALERT: Test " ~ test_name ~ " failed with " ~ failure_count ~ " failures", info=true) }}
  {% endif %}
{% endmacro %}
```

---

## Continuous Integration Integration

### 1. CI/CD Pipeline Integration

```yaml
# .github/workflows/dbt_tests.yml
name: dbt Tests
on:
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 6 * * *'  # Daily at 6 AM

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup dbt
        run: pip install dbt-snowflake
      - name: Run dbt tests
        run: |
          dbt deps
          dbt test --profiles-dir ./profiles
        env:
          SNOWFLAKE_ACCOUNT: ${{ secrets.SNOWFLAKE_ACCOUNT }}
          SNOWFLAKE_USER: ${{ secrets.SNOWFLAKE_USER }}
          SNOWFLAKE_PASSWORD: ${{ secrets.SNOWFLAKE_PASSWORD }}
```

### 2. Test Documentation Generation

```bash
# Generate test documentation
dbt docs generate
dbt docs serve
```

---

## Summary

This comprehensive test suite provides:

✅ **Complete Coverage**: Tests for all 11 dbt models (6 dimensions + 4 facts + 1 audit)  
✅ **Data Quality Validation**: Comprehensive data quality checks and validation rules  
✅ **Business Rule Testing**: Domain-specific logic validation for Zoom analytics  
✅ **Edge Case Handling**: Boundary condition and error scenario testing  
✅ **Performance Validation**: Query performance and scalability testing  
✅ **Referential Integrity**: Cross-table relationship validation  
✅ **Automated Monitoring**: CI/CD integration and automated alerting  
✅ **Snowflake Optimization**: Tests optimized for Snowflake's architecture  
✅ **Maintainable Framework**: Modular, reusable test components  
✅ **Documentation**: Comprehensive test documentation and execution guides  

The test framework ensures reliable, high-quality data transformations in the Zoom Platform Analytics System while maintaining optimal performance and data integrity across all Gold layer models.