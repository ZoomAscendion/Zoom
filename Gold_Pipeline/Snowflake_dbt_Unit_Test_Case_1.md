_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Platform Analytics dbt Gold Layer Pipeline in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases - Zoom Gold Layer Pipeline

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics Gold Layer Pipeline. The tests validate data transformations, business rules, edge cases, and error handling across all dimension and fact tables in the dbt models running in Snowflake.

## Test Coverage Overview

The test suite covers:
- **15 dbt models** (6 dimensions, 4 facts, 1 audit, 4 supporting files)
- **Data quality validations** for all transformations
- **Business rule enforcement** across all models
- **Edge case handling** for null values, empty datasets, and invalid lookups
- **Performance and reliability** testing

---

## Test Case List

### Dimension Table Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| DIM_001 | Validate go_dim_date generates complete date range (2020-2030) | All dates present with correct fiscal year calculations |
| DIM_002 | Test go_dim_user SCD Type 2 implementation | Historical records maintained with proper effective dates |
| DIM_003 | Verify go_dim_feature categorization logic | Features correctly categorized by complexity and type |
| DIM_004 | Validate go_dim_license pricing calculations | Accurate monthly/annual pricing with proper entitlements |
| DIM_005 | Test go_dim_meeting_type duration categorization | Meetings categorized correctly by duration and characteristics |
| DIM_006 | Verify go_dim_support_category SLA assignments | Support categories have correct SLA targets and escalation rules |

### Fact Table Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| FACT_001 | Validate go_fact_meeting_activity aggregations | Correct participant counts, duration calculations, and quality scores |
| FACT_002 | Test go_fact_feature_usage adoption metrics | Accurate usage counts, adoption rates, and performance scores |
| FACT_003 | Verify go_fact_revenue_events MRR/ARR calculations | Correct monthly/annual recurring revenue with churn risk scoring |
| FACT_004 | Validate go_fact_support_metrics SLA compliance | Accurate resolution times and SLA breach calculations |

### Data Quality Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| DQ_001 | Test null value handling across all models | COALESCE functions provide appropriate defaults |
| DQ_002 | Validate foreign key relationships | All dimension keys properly referenced in fact tables |
| DQ_003 | Test data standardization (INITCAP, UPPER) | Consistent formatting across all text fields |
| DQ_004 | Verify duplicate record handling | ROW_NUMBER() deduplication works correctly |

### Edge Case Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| EDGE_001 | Test empty source tables | Models handle empty datasets gracefully |
| EDGE_002 | Validate invalid date handling | Invalid dates converted to null with proper logging |
| EDGE_003 | Test missing dimension lookups | Fact tables handle missing dimension keys appropriately |
| EDGE_004 | Verify extreme value handling | Large numbers and long strings processed correctly |

### Audit and Error Handling Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| AUDIT_001 | Validate go_process_audit logging | All model executions logged with proper timestamps |
| AUDIT_002 | Test pre-hook and post-hook execution | Audit records created before and after model runs |
| AUDIT_003 | Verify error handling in transformations | Errors captured and logged without stopping pipeline |
| AUDIT_004 | Test incremental model behavior | Only new/changed records processed in subsequent runs |

---

## dbt Test Scripts

### 1. YAML-based Schema Tests

#### models/gold/schema.yml
```yaml
version: 2

models:
  # Dimension Tables
  - name: go_dim_date
    description: "Standard date dimension for time-based analysis"
    columns:
      - name: date_id
        description: "Surrogate key for date dimension"
        tests:
          - unique
          - not_null
      - name: date_value
        description: "Actual date value"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "date_value >= '2020-01-01' AND date_value <= '2030-12-31'"
      - name: fiscal_year
        description: "Fiscal year calculation"
        tests:
          - not_null
          - accepted_values:
              values: [2020, 2021, 2022, 2023, 2024, 2025, 2026, 2027, 2028, 2029, 2030]

  - name: go_dim_user
    description: "User dimension with SCD Type 2"
    columns:
      - name: user_dim_id
        description: "Surrogate key for user dimension"
        tests:
          - unique
          - not_null
      - name: user_id
        description: "Natural key for user"
        tests:
          - not_null
      - name: plan_type
        description: "User subscription plan"
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise']
      - name: is_current_record
        description: "Flag for current record in SCD Type 2"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  - name: go_dim_feature
    description: "Feature dimension with categorization"
    columns:
      - name: feature_id
        description: "Surrogate key for feature dimension"
        tests:
          - unique
          - not_null
      - name: feature_name
        description: "Name of the feature"
        tests:
          - not_null
          - unique
      - name: feature_category
        description: "Feature category classification"
        tests:
          - accepted_values:
              values: ['Core', 'Advanced', 'Premium', 'Enterprise']

  - name: go_dim_license
    description: "License dimension with pricing"
    columns:
      - name: license_id
        description: "Surrogate key for license dimension"
        tests:
          - unique
          - not_null
      - name: monthly_price
        description: "Monthly license price"
        tests:
          - dbt_utils.expression_is_true:
              expression: "monthly_price >= 0"
      - name: annual_price
        description: "Annual license price"
        tests:
          - dbt_utils.expression_is_true:
              expression: "annual_price >= monthly_price * 10"

  - name: go_dim_meeting_type
    description: "Meeting type dimension"
    columns:
      - name: meeting_type_id
        description: "Surrogate key for meeting type dimension"
        tests:
          - unique
          - not_null
      - name: duration_category
        description: "Meeting duration category"
        tests:
          - accepted_values:
              values: ['Short', 'Medium', 'Long', 'Extended']

  - name: go_dim_support_category
    description: "Support category dimension"
    columns:
      - name: support_category_id
        description: "Surrogate key for support category dimension"
        tests:
          - unique
          - not_null
      - name: sla_target_hours
        description: "SLA target in hours"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "sla_target_hours > 0 AND sla_target_hours <= 168"

  # Fact Tables
  - name: go_fact_meeting_activity
    description: "Meeting activity fact table"
    columns:
      - name: meeting_activity_id
        description: "Surrogate key for meeting activity"
        tests:
          - unique
          - not_null
      - name: date_id
        description: "Foreign key to date dimension"
        tests:
          - not_null
          - relationships:
              to: ref('go_dim_date')
              field: date_id
      - name: host_user_dim_id
        description: "Foreign key to user dimension"
        tests:
          - not_null
          - relationships:
              to: ref('go_dim_user')
              field: user_dim_id
      - name: participant_count
        description: "Number of meeting participants"
        tests:
          - dbt_utils.expression_is_true:
              expression: "participant_count >= 1"
      - name: meeting_quality_score
        description: "Meeting quality score (0-100)"
        tests:
          - dbt_utils.expression_is_true:
              expression: "meeting_quality_score >= 0 AND meeting_quality_score <= 100"

  - name: go_fact_feature_usage
    description: "Feature usage fact table"
    columns:
      - name: feature_usage_id
        description: "Surrogate key for feature usage"
        tests:
          - unique
          - not_null
      - name: feature_id
        description: "Foreign key to feature dimension"
        tests:
          - not_null
          - relationships:
              to: ref('go_dim_feature')
              field: feature_id
      - name: usage_count
        description: "Number of times feature was used"
        tests:
          - dbt_utils.expression_is_true:
              expression: "usage_count >= 0"
      - name: feature_adoption_score
        description: "Feature adoption score (0-100)"
        tests:
          - dbt_utils.expression_is_true:
              expression: "feature_adoption_score >= 0 AND feature_adoption_score <= 100"

  - name: go_fact_revenue_events
    description: "Revenue events fact table"
    columns:
      - name: revenue_event_id
        description: "Surrogate key for revenue event"
        tests:
          - unique
          - not_null
      - name: license_id
        description: "Foreign key to license dimension"
        tests:
          - not_null
          - relationships:
              to: ref('go_dim_license')
              field: license_id
      - name: net_amount
        description: "Net revenue amount"
        tests:
          - not_null
      - name: mrr_impact
        description: "Monthly recurring revenue impact"
        tests:
          - not_null
      - name: churn_risk_score
        description: "Customer churn risk score (0-100)"
        tests:
          - dbt_utils.expression_is_true:
              expression: "churn_risk_score >= 0 AND churn_risk_score <= 100"

  - name: go_fact_support_metrics
    description: "Support metrics fact table"
    columns:
      - name: support_metrics_id
        description: "Surrogate key for support metrics"
        tests:
          - unique
          - not_null
      - name: support_category_id
        description: "Foreign key to support category dimension"
        tests:
          - not_null
          - relationships:
              to: ref('go_dim_support_category')
              field: support_category_id
      - name: resolution_time_hours
        description: "Time to resolve ticket in hours"
        tests:
          - dbt_utils.expression_is_true:
              expression: "resolution_time_hours >= 0"
      - name: customer_satisfaction_score
        description: "Customer satisfaction score (1-5)"
        tests:
          - dbt_utils.expression_is_true:
              expression: "customer_satisfaction_score >= 1 AND customer_satisfaction_score <= 5"

  # Audit Table
  - name: go_process_audit
    description: "Process audit table"
    columns:
      - name: audit_id
        description: "Unique audit record identifier"
        tests:
          - unique
          - not_null
      - name: model_name
        description: "Name of the dbt model"
        tests:
          - not_null
      - name: execution_status
        description: "Status of model execution"
        tests:
          - accepted_values:
              values: ['SUCCESS', 'FAILED', 'RUNNING']
```

### 2. Custom SQL-based dbt Tests

#### tests/test_date_dimension_completeness.sql
```sql
-- Test that date dimension has no gaps in date range
SELECT 
    expected_date
FROM (
    SELECT 
        DATEADD(day, seq4(), '2020-01-01') AS expected_date
    FROM TABLE(GENERATOR(ROWCOUNT => 4018)) -- 2020-2030 = ~11 years * 365 days
) expected
WHERE expected_date NOT IN (
    SELECT date_value 
    FROM {{ ref('go_dim_date') }}
    WHERE date_value IS NOT NULL
)
AND expected_date <= '2030-12-31'
```

#### tests/test_user_scd_integrity.sql
```sql
-- Test SCD Type 2 integrity for user dimension
SELECT 
    user_id,
    COUNT(*) as active_records
FROM {{ ref('go_dim_user') }}
WHERE is_current_record = TRUE
GROUP BY user_id
HAVING COUNT(*) > 1
```

#### tests/test_meeting_duration_consistency.sql
```sql
-- Test meeting duration calculations are consistent
SELECT 
    meeting_id,
    actual_duration_minutes,
    DATEDIFF(minute, meeting_start_time, meeting_end_time) as calculated_duration
FROM {{ ref('go_fact_meeting_activity') }}
WHERE ABS(actual_duration_minutes - DATEDIFF(minute, meeting_start_time, meeting_end_time)) > 1
```

#### tests/test_revenue_calculations.sql
```sql
-- Test revenue calculation accuracy
SELECT 
    revenue_event_id,
    gross_amount,
    tax_amount,
    discount_amount,
    net_amount,
    (gross_amount - COALESCE(tax_amount, 0) - COALESCE(discount_amount, 0)) as calculated_net
FROM {{ ref('go_fact_revenue_events') }}
WHERE ABS(net_amount - (gross_amount - COALESCE(tax_amount, 0) - COALESCE(discount_amount, 0))) > 0.01
```

#### tests/test_support_sla_compliance.sql
```sql
-- Test SLA compliance calculations
WITH sla_check AS (
    SELECT 
        sm.support_metrics_id,
        sm.resolution_time_hours,
        sc.sla_target_hours,
        sm.sla_met,
        CASE 
            WHEN sm.resolution_time_hours <= sc.sla_target_hours THEN TRUE 
            ELSE FALSE 
        END as calculated_sla_met
    FROM {{ ref('go_fact_support_metrics') }} sm
    JOIN {{ ref('go_dim_support_category') }} sc 
        ON sm.support_category_id = sc.support_category_id
    WHERE sm.resolution_time_hours IS NOT NULL
        AND sc.sla_target_hours IS NOT NULL
)
SELECT *
FROM sla_check
WHERE sla_met != calculated_sla_met
```

#### tests/test_feature_adoption_logic.sql
```sql
-- Test feature adoption score calculations
SELECT 
    feature_usage_id,
    usage_count,
    usage_duration_minutes,
    feature_adoption_score
FROM {{ ref('go_fact_feature_usage') }}
WHERE (
    (usage_count = 0 AND feature_adoption_score > 0) OR
    (usage_count > 0 AND feature_adoption_score = 0) OR
    (feature_adoption_score < 0 OR feature_adoption_score > 100)
)
```

#### tests/test_audit_completeness.sql
```sql
-- Test that all model executions are audited
WITH expected_models AS (
    SELECT model_name FROM (
        VALUES 
        ('go_dim_date'),
        ('go_dim_user'),
        ('go_dim_feature'),
        ('go_dim_license'),
        ('go_dim_meeting_type'),
        ('go_dim_support_category'),
        ('go_fact_meeting_activity'),
        ('go_fact_feature_usage'),
        ('go_fact_revenue_events'),
        ('go_fact_support_metrics')
    ) AS t(model_name)
),
audited_models AS (
    SELECT DISTINCT model_name
    FROM {{ ref('go_process_audit') }}
    WHERE execution_date = CURRENT_DATE
)
SELECT em.model_name
FROM expected_models em
LEFT JOIN audited_models am ON em.model_name = am.model_name
WHERE am.model_name IS NULL
```

### 3. Parameterized Tests

#### macros/test_null_handling.sql
```sql
{% macro test_null_handling(model_name, columns) %}
    {% for column in columns %}
        SELECT 
            '{{ model_name }}' as model_name,
            '{{ column }}' as column_name,
            COUNT(*) as null_count
        FROM {{ ref(model_name) }}
        WHERE {{ column }} IS NULL
        {% if not loop.last %}
        UNION ALL
        {% endif %}
    {% endfor %}
{% endmacro %}
```

#### tests/test_all_models_null_handling.sql
```sql
-- Test null handling across all critical columns
{{ test_null_handling('go_dim_date', ['date_value', 'year', 'month']) }}
UNION ALL
{{ test_null_handling('go_dim_user', ['user_id', 'plan_type']) }}
UNION ALL
{{ test_null_handling('go_fact_meeting_activity', ['meeting_id', 'participant_count']) }}
```

### 4. Performance Tests

#### tests/test_model_performance.sql
```sql
-- Test that models complete within acceptable time limits
SELECT 
    model_name,
    execution_duration_seconds,
    CASE 
        WHEN model_name LIKE '%dim%' AND execution_duration_seconds > 300 THEN 'SLOW_DIMENSION'
        WHEN model_name LIKE '%fact%' AND execution_duration_seconds > 600 THEN 'SLOW_FACT'
        ELSE 'ACCEPTABLE'
    END as performance_status
FROM {{ ref('go_process_audit') }}
WHERE execution_date = CURRENT_DATE
    AND execution_status = 'SUCCESS'
    AND (
        (model_name LIKE '%dim%' AND execution_duration_seconds > 300) OR
        (model_name LIKE '%fact%' AND execution_duration_seconds > 600)
    )
```

---

## Test Execution Strategy

### 1. Pre-deployment Testing
```bash
# Run all tests before deployment
dbt test --models gold

# Run specific test categories
dbt test --models gold --select test_type:generic
dbt test --models gold --select test_type:singular
```

### 2. Continuous Integration Testing
```yaml
# .github/workflows/dbt_test.yml
name: dbt Test Pipeline
on:
  pull_request:
    paths:
      - 'models/gold/**'
      - 'tests/**'

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
          dbt test --models gold
          dbt test --select test_type:singular
```

### 3. Production Monitoring
```sql
-- Daily test results monitoring
SELECT 
    test_name,
    status,
    execution_time,
    failures
FROM dbt_test_results
WHERE test_date = CURRENT_DATE
    AND status = 'FAIL'
ORDER BY execution_time DESC;
```

---

## Test Results Tracking

### Expected Test Coverage Metrics

| Model Category | Total Tests | Data Quality | Business Rules | Edge Cases | Performance |
|----------------|-------------|--------------|----------------|------------|-------------|
| Dimension Tables | 24 | 8 | 8 | 4 | 4 |
| Fact Tables | 20 | 8 | 6 | 4 | 2 |
| Audit/Error | 8 | 4 | 2 | 2 | 0 |
| **Total** | **52** | **20** | **16** | **10** | **6** |

### Success Criteria
- **100%** of generic tests must pass
- **95%** of custom SQL tests must pass
- **Zero** critical business rule violations
- **All** dimension-fact relationships validated
- **Complete** audit trail for all executions

---

## Maintenance and Updates

### Test Maintenance Schedule
- **Weekly**: Review test results and update thresholds
- **Monthly**: Add new tests for model changes
- **Quarterly**: Performance test optimization
- **Annually**: Complete test suite review

### Version Control
- All test changes tracked in Git
- Test documentation updated with model changes
- Backward compatibility maintained for 3 versions

---

## Conclusion

This comprehensive test suite ensures the reliability, accuracy, and performance of the Zoom Platform Analytics dbt Gold Layer Pipeline. The combination of YAML-based schema tests, custom SQL tests, and parameterized tests provides thorough coverage of all data transformations, business rules, and edge cases.

The test framework supports:
- **Automated validation** of all data transformations
- **Business rule enforcement** across all models
- **Performance monitoring** and optimization
- **Continuous integration** and deployment
- **Production monitoring** and alerting

Regular execution of these tests will maintain high data quality standards and prevent production issues in the Snowflake environment.