_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases and dbt test scripts for Zoom Platform Analytics Gold Layer dbt models
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Zoom Platform Analytics Gold Layer

## Overview

This document provides comprehensive unit test cases and corresponding dbt test scripts for the Zoom Platform Analytics Gold Layer dbt models. The testing framework validates data transformations, business rules, edge cases, and error handling to ensure reliable and performant dbt models in Snowflake.

### Models Covered

- **Dimension Tables**: GO_DIM_DATE, GO_DIM_FEATURE, GO_DIM_LICENSE, GO_DIM_MEETING_TYPE, GO_DIM_SUPPORT_CATEGORY, GO_DIM_USER
- **Fact Tables**: GO_FACT_FEATURE_USAGE, GO_FACT_MEETING_ACTIVITY, GO_FACT_REVENUE_EVENTS, GO_FACT_SUPPORT_METRICS
- **Infrastructure**: GO_AUDIT_LOG

### Testing Framework

- **dbt Testing Methodologies**: Built-in tests (unique, not_null, relationships, accepted_values) and custom SQL tests
- **Data Quality Coverage**: Happy path, edge cases, exception scenarios
- **Business Rule Validation**: KPI calculations, transformations, data integrity
- **Performance Testing**: Query optimization and execution efficiency

---

## Test Case List

### 1. Dimension Table Test Cases

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| DIM_DATE_001 | Validate date dimension completeness for 10-year range | All dates from 2020-2030 present | Data Completeness |
| DIM_DATE_002 | Verify fiscal year calculation with July 1 start | Correct fiscal year assignment | Business Logic |
| DIM_DATE_003 | Test weekend and holiday flag accuracy | Proper boolean flag assignment | Data Accuracy |
| DIM_FEATURE_001 | Validate feature categorization logic | Correct category assignment based on name patterns | Business Logic |
| DIM_FEATURE_002 | Test premium feature identification | Accurate premium flag based on feature type | Data Classification |
| DIM_LICENSE_001 | Verify SCD Type 2 implementation | Proper effective date management and current record flags | SCD Logic |
| DIM_LICENSE_002 | Test license tier standardization | Correct tier assignment (Tier 1-4) | Data Standardization |
| DIM_LICENSE_003 | Validate pricing calculations | Accurate monthly/annual pricing with discounts | Business Calculation |
| DIM_MEETING_TYPE_001 | Test meeting type classification | Proper categorization by duration and participants | Classification Logic |
| DIM_SUPPORT_001 | Validate priority level mapping | Correct P1-P4 assignment | Priority Mapping |
| DIM_USER_001 | Verify SCD Type 2 for user changes | Historical tracking with effective dates | SCD Logic |
| DIM_USER_002 | Test email domain extraction | Accurate domain parsing from email addresses | Data Parsing |
| DIM_USER_003 | Validate plan category standardization | Consistent plan type classification | Data Standardization |

### 2. Fact Table Test Cases

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| FACT_FEATURE_001 | Validate usage intensity classification | Correct High/Medium/Low assignment based on usage count | Business Logic |
| FACT_FEATURE_002 | Test bandwidth consumption calculation | Accurate MB calculation by feature type | Calculation Logic |
| FACT_FEATURE_003 | Verify user experience score calculation | Score between 0-10 with proper formula | KPI Calculation |
| FACT_MEETING_001 | Test participant engagement scoring | Engagement score 0-10 based on participation ratio | Engagement Logic |
| FACT_MEETING_002 | Validate meeting quality assessment | Quality score based on duration, participants, features | Quality Metrics |
| FACT_MEETING_003 | Test feature usage aggregation | Accurate count of distinct features per meeting | Aggregation Logic |
| FACT_REVENUE_001 | Verify MRR/ARR calculation accuracy | Correct monthly/annual recurring revenue calculation | Revenue Recognition |
| FACT_REVENUE_002 | Test tax and discount calculations | Accurate tax (8%) and plan-based discount application | Financial Calculation |
| FACT_REVENUE_003 | Validate customer lifetime value | CLV calculation based on plan type multipliers | Business Metric |
| FACT_SUPPORT_001 | Test SLA compliance tracking | Accurate SLA met/breach flags based on resolution time | SLA Logic |
| FACT_SUPPORT_002 | Validate resolution time calculation | Correct hours calculation by priority level | Time Calculation |
| FACT_SUPPORT_003 | Test customer satisfaction scoring | Satisfaction score based on resolution status and type | Satisfaction Logic |

### 3. Data Quality Test Cases

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| DQ_001 | Validate data quality filter application | Only VALIDATION_STATUS = 'PASSED' records processed | Data Filter |
| DQ_002 | Test data quality score threshold | Only DATA_QUALITY_SCORE >= 80 records included | Quality Threshold |
| DQ_003 | Verify referential integrity | All foreign key relationships maintained | Referential Integrity |
| DQ_004 | Test null value handling | Proper null handling in calculations and transformations | Null Handling |
| DQ_005 | Validate date range constraints | All dates within acceptable business ranges | Date Validation |

### 4. Edge Case Test Cases

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| EDGE_001 | Test zero usage count scenarios | Proper handling of zero values in calculations | Edge Case |
| EDGE_002 | Validate empty dataset processing | Graceful handling of empty source tables | Empty Data |
| EDGE_003 | Test maximum value boundaries | Proper handling of maximum participant counts, amounts | Boundary Testing |
| EDGE_004 | Verify duplicate record handling | Proper deduplication logic in transformations | Duplicate Handling |
| EDGE_005 | Test invalid lookup scenarios | Graceful handling of missing dimension references | Invalid Reference |

---

## dbt Test Scripts

### 1. YAML-based Schema Tests

#### models/schema.yml

```yaml
version: 2

models:
  # Dimension Tables
  - name: go_dim_date
    description: "Standard date dimension for time-based analysis"
    columns:
      - name: date_id
        description: "Unique identifier for each date"
        tests:
          - unique
          - not_null
      - name: date_value
        description: "Actual date value"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: "'2020-01-01'"
              max_value: "'2030-12-31'"
      - name: fiscal_year
        description: "Fiscal year with July 1 start"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 2020
              max_value: 2031
      - name: is_weekend
        description: "Weekend flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  - name: go_dim_feature
    description: "Platform features dimension"
    columns:
      - name: feature_id
        description: "Unique identifier for each feature"
        tests:
          - unique
          - not_null
      - name: feature_name
        description: "Name of the feature"
        tests:
          - not_null
      - name: feature_category
        description: "Feature category classification"
        tests:
          - not_null
          - accepted_values:
              values: ['Communication', 'Collaboration', 'Security', 'Analytics', 'Integration', 'Other']
      - name: is_premium_feature
        description: "Premium feature flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  - name: go_dim_license
    description: "License types and entitlements dimension"
    columns:
      - name: license_id
        description: "Unique identifier for each license"
        tests:
          - unique
          - not_null
      - name: license_tier
        description: "License tier classification"
        tests:
          - not_null
          - accepted_values:
              values: ['Tier 1', 'Tier 2', 'Tier 3', 'Tier 4']
      - name: monthly_price
        description: "Monthly license price"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10000
      - name: is_current_record
        description: "SCD Type 2 current record flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  - name: go_dim_user
    description: "User profile and subscription dimension"
    columns:
      - name: user_dim_id
        description: "Unique identifier for each user dimension record"
        tests:
          - unique
          - not_null
      - name: plan_type
        description: "User subscription plan type"
        tests:
          - not_null
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise']
      - name: plan_category
        description: "Plan category classification"
        tests:
          - not_null
          - accepted_values:
              values: ['Free', 'Paid', 'Premium', 'Enterprise']
      - name: is_current_record
        description: "SCD Type 2 current record flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  # Fact Tables
  - name: go_fact_feature_usage
    description: "Feature usage metrics and patterns"
    columns:
      - name: feature_usage_id
        description: "Unique identifier for each usage record"
        tests:
          - unique
          - not_null
      - name: usage_date
        description: "Date of feature usage"
        tests:
          - not_null
      - name: usage_count
        description: "Number of times feature was used"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10000
      - name: usage_intensity
        description: "Usage intensity classification"
        tests:
          - not_null
          - accepted_values:
              values: ['Very Low', 'Low', 'Medium', 'High', 'Very High']
      - name: user_experience_score
        description: "User experience score 0-10"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10
      - name: success_rate_percentage
        description: "Feature success rate percentage"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100

  - name: go_fact_meeting_activity
    description: "Meeting activities and engagement metrics"
    columns:
      - name: meeting_activity_id
        description: "Unique identifier for each meeting activity record"
        tests:
          - unique
          - not_null
      - name: meeting_date
        description: "Date of the meeting"
        tests:
          - not_null
      - name: participant_count
        description: "Number of meeting participants"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 1
              max_value: 1000
      - name: participant_engagement_score
        description: "Participant engagement score 0-10"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10
      - name: meeting_quality_score
        description: "Overall meeting quality score 0-10"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10

  - name: go_fact_revenue_events
    description: "Revenue-generating events and financial transactions"
    columns:
      - name: revenue_event_id
        description: "Unique identifier for each revenue event"
        tests:
          - unique
          - not_null
      - name: transaction_date
        description: "Date of the transaction"
        tests:
          - not_null
      - name: revenue_type
        description: "Type of revenue"
        tests:
          - not_null
          - accepted_values:
              values: ['Recurring', 'Expansion', 'Add-on', 'One-time']
      - name: gross_amount
        description: "Gross transaction amount"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1000000
      - name: net_amount
        description: "Net transaction amount after tax and discounts"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1000000
      - name: is_recurring_revenue
        description: "Recurring revenue flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  - name: go_fact_support_metrics
    description: "Support ticket activities and resolution performance"
    columns:
      - name: support_metrics_id
        description: "Unique identifier for each support metrics record"
        tests:
          - unique
          - not_null
      - name: ticket_open_date
        description: "Date when ticket was opened"
        tests:
          - not_null
      - name: priority_level
        description: "Ticket priority level"
        tests:
          - not_null
          - accepted_values:
              values: ['P1', 'P2', 'P3', 'P4']
      - name: resolution_time_hours
        description: "Time to resolve ticket in hours"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 720  # 30 days max
      - name: customer_satisfaction_score
        description: "Customer satisfaction score 0-10"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10
      - name: sla_met_flag
        description: "SLA compliance flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]
```

### 2. Custom SQL-based dbt Tests

#### tests/test_data_quality_filter.sql

```sql
-- Test that only records with VALIDATION_STATUS = 'PASSED' are processed
SELECT COUNT(*) as failed_records
FROM (
    SELECT * FROM {{ ref('go_fact_feature_usage') }}
    UNION ALL
    SELECT * FROM {{ ref('go_fact_meeting_activity') }}
    UNION ALL  
    SELECT * FROM {{ ref('go_fact_revenue_events') }}
    UNION ALL
    SELECT * FROM {{ ref('go_fact_support_metrics') }}
) fact_tables
WHERE source_system NOT IN (
    SELECT DISTINCT source_system 
    FROM {{ source('silver', 'si_feature_usage') }}
    WHERE validation_status = 'PASSED'
)
HAVING COUNT(*) > 0
```

#### tests/test_date_dimension_completeness.sql

```sql
-- Test that date dimension covers complete 10-year range without gaps
WITH expected_dates AS (
    SELECT 
        DATEADD('day', seq4(), '2020-01-01') as expected_date
    FROM TABLE(GENERATOR(ROWCOUNT => 4018))  -- 11 years of dates
    WHERE expected_date <= '2030-12-31'
),
actual_dates AS (
    SELECT date_value as actual_date
    FROM {{ ref('go_dim_date') }}
)
SELECT COUNT(*) as missing_dates
FROM expected_dates e
LEFT JOIN actual_dates a ON e.expected_date = a.actual_date
WHERE a.actual_date IS NULL
HAVING COUNT(*) > 0
```

#### tests/test_fiscal_year_calculation.sql

```sql
-- Test fiscal year calculation with July 1 start
SELECT COUNT(*) as incorrect_fiscal_years
FROM {{ ref('go_dim_date') }}
WHERE fiscal_year != CASE 
    WHEN MONTH(date_value) >= 7 THEN YEAR(date_value) + 1
    ELSE YEAR(date_value)
END
HAVING COUNT(*) > 0
```

#### tests/test_scd_type2_implementation.sql

```sql
-- Test SCD Type 2 implementation for user dimension
WITH current_records AS (
    SELECT user_name, COUNT(*) as current_count
    FROM {{ ref('go_dim_user') }}
    WHERE is_current_record = TRUE
    GROUP BY user_name
    HAVING COUNT(*) > 1
)
SELECT COUNT(*) as invalid_current_records
FROM current_records
HAVING COUNT(*) > 0
```

#### tests/test_engagement_score_calculation.sql

```sql
-- Test participant engagement score calculation logic
SELECT COUNT(*) as invalid_engagement_scores
FROM {{ ref('go_fact_meeting_activity') }}
WHERE participant_engagement_score < 0 
   OR participant_engagement_score > 10
   OR (actual_duration_minutes = 0 AND participant_engagement_score > 0)
HAVING COUNT(*) > 0
```

#### tests/test_revenue_calculation_accuracy.sql

```sql
-- Test revenue calculation accuracy (net = gross - tax - discount)
SELECT COUNT(*) as incorrect_calculations
FROM {{ ref('go_fact_revenue_events') }}
WHERE ABS(net_amount - (gross_amount - tax_amount - discount_amount)) > 0.01
HAVING COUNT(*) > 0
```

#### tests/test_mrr_arr_calculation.sql

```sql
-- Test MRR/ARR calculation logic
SELECT COUNT(*) as incorrect_mrr_arr
FROM {{ ref('go_fact_revenue_events') }}
WHERE (
    revenue_type = 'Recurring' 
    AND subscription_period_months = 1 
    AND mrr_impact != gross_amount
) OR (
    revenue_type = 'Recurring' 
    AND subscription_period_months = 12 
    AND arr_impact != gross_amount
) OR (
    revenue_type != 'Recurring' 
    AND (mrr_impact != 0 OR arr_impact != 0)
)
HAVING COUNT(*) > 0
```

#### tests/test_sla_compliance_logic.sql

```sql
-- Test SLA compliance calculation
SELECT COUNT(*) as incorrect_sla_flags
FROM {{ ref('go_fact_support_metrics') }}
WHERE (
    priority_level = 'P1' 
    AND resolution_time_hours <= 4 
    AND sla_met_flag = FALSE
) OR (
    priority_level = 'P1' 
    AND resolution_time_hours > 4 
    AND sla_met_flag = TRUE
) OR (
    priority_level = 'P2' 
    AND resolution_time_hours <= 24 
    AND sla_met_flag = FALSE
) OR (
    priority_level = 'P2' 
    AND resolution_time_hours > 24 
    AND sla_met_flag = TRUE
)
HAVING COUNT(*) > 0
```

#### tests/test_bandwidth_calculation.sql

```sql
-- Test bandwidth consumption calculation by feature type
SELECT COUNT(*) as incorrect_bandwidth_calculations
FROM {{ ref('go_fact_feature_usage') }}
WHERE (
    LOWER(feature_name) LIKE '%video%' 
    AND bandwidth_consumed_mb != usage_count * 50.0
) OR (
    LOWER(feature_name) LIKE '%screen%' 
    AND bandwidth_consumed_mb != usage_count * 30.0
) OR (
    LOWER(feature_name) LIKE '%audio%' 
    AND bandwidth_consumed_mb != usage_count * 5.0
) OR (
    LOWER(feature_name) NOT LIKE '%video%' 
    AND LOWER(feature_name) NOT LIKE '%screen%' 
    AND LOWER(feature_name) NOT LIKE '%audio%'
    AND bandwidth_consumed_mb != usage_count * 2.0
)
HAVING COUNT(*) > 0
```

### 3. Parameterized Tests

#### macros/test_score_range.sql

```sql
{% macro test_score_range(model, column_name, min_value=0, max_value=10) %}

SELECT COUNT(*) as invalid_scores
FROM {{ model }}
WHERE {{ column_name }} < {{ min_value }} 
   OR {{ column_name }} > {{ max_value }}
   OR {{ column_name }} IS NULL
HAVING COUNT(*) > 0

{% endmacro %}
```

#### macros/test_referential_integrity.sql

```sql
{% macro test_referential_integrity(child_model, parent_model, child_key, parent_key) %}

SELECT COUNT(*) as orphaned_records
FROM {{ child_model }} c
LEFT JOIN {{ parent_model }} p ON c.{{ child_key }} = p.{{ parent_key }}
WHERE p.{{ parent_key }} IS NULL
  AND c.{{ child_key }} IS NOT NULL
HAVING COUNT(*) > 0

{% endmacro %}
```

### 4. Performance Tests

#### tests/test_query_performance.sql

```sql
-- Test that key queries execute within acceptable time limits
WITH performance_test AS (
    SELECT 
        CURRENT_TIMESTAMP() as start_time,
        COUNT(*) as record_count
    FROM {{ ref('go_fact_meeting_activity') }}
    WHERE meeting_date >= CURRENT_DATE() - 30
),
end_test AS (
    SELECT 
        *,
        CURRENT_TIMESTAMP() as end_time,
        DATEDIFF('second', start_time, CURRENT_TIMESTAMP()) as execution_seconds
    FROM performance_test
)
SELECT execution_seconds
FROM end_test
WHERE execution_seconds > 30  -- Fail if query takes more than 30 seconds
```

---

## Test Execution Strategy

### 1. Test Organization

- **Unit Tests**: Individual model validation
- **Integration Tests**: Cross-model relationship validation  
- **End-to-End Tests**: Complete pipeline validation
- **Performance Tests**: Query execution efficiency

### 2. Test Execution Order

1. **Schema Tests**: Basic data type and constraint validation
2. **Business Logic Tests**: Transformation and calculation validation
3. **Data Quality Tests**: Quality framework validation
4. **Integration Tests**: Cross-table relationship validation
5. **Performance Tests**: Execution efficiency validation

### 3. Continuous Integration

```yaml
# .github/workflows/dbt_tests.yml
name: dbt Tests
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
          dbt seed
          dbt run
          dbt test
        env:
          SNOWFLAKE_ACCOUNT: ${{ secrets.SNOWFLAKE_ACCOUNT }}
          SNOWFLAKE_USER: ${{ secrets.SNOWFLAKE_USER }}
          SNOWFLAKE_PASSWORD: ${{ secrets.SNOWFLAKE_PASSWORD }}
```

### 4. Test Results Tracking

- **dbt run_results.json**: Automated test result capture
- **Snowflake Audit Schema**: Test execution logging
- **Dashboard Monitoring**: Real-time test status visibility
- **Alert System**: Automated failure notifications

---

## Expected Outcomes

### 1. Data Quality Assurance

✅ **100% Data Validation**: All records pass validation status and quality score thresholds  
✅ **Referential Integrity**: All foreign key relationships maintained across dimension and fact tables  
✅ **Business Rule Compliance**: All transformations follow defined business logic and KPI calculations  
✅ **Edge Case Handling**: Graceful handling of null values, zero counts, and boundary conditions  

### 2. Performance Optimization

✅ **Query Efficiency**: All models execute within acceptable time limits  
✅ **Resource Utilization**: Optimal use of Snowflake compute resources  
✅ **Clustering Effectiveness**: Proper clustering strategies improve query performance  
✅ **Incremental Processing**: CDC-based incremental loads minimize processing overhead  

### 3. Reliability and Maintainability

✅ **Automated Testing**: Comprehensive test coverage with automated execution  
✅ **Error Detection**: Early identification of data quality issues and transformation errors  
✅ **Documentation**: Clear test documentation and expected outcomes  
✅ **Monitoring**: Real-time visibility into pipeline health and data quality metrics  

---

## Summary

This comprehensive unit testing framework ensures the reliability and performance of dbt models in the Zoom Platform Analytics Gold Layer by:

- **Validating Data Transformations**: Comprehensive testing of all business logic and calculations
- **Ensuring Data Quality**: Robust validation of data quality frameworks and thresholds
- **Testing Edge Cases**: Thorough coverage of boundary conditions and error scenarios
- **Performance Monitoring**: Continuous validation of query performance and resource utilization
- **Automated Execution**: Integration with CI/CD pipelines for continuous testing
- **Result Tracking**: Comprehensive logging and monitoring of test results

The testing framework provides confidence in data accuracy, transformation reliability, and system performance while enabling rapid development and deployment of analytics solutions in the Snowflake environment.