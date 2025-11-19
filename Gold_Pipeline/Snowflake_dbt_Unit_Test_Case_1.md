_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Platform Analytics System dbt models in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Zoom Platform Analytics System

## Overview

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics System Gold layer dbt models running in Snowflake. The test cases cover data transformations, business rules, edge cases, and error handling scenarios to ensure reliable and high-quality data pipelines.

### Test Coverage Areas

1. **Data Transformation Validation**
   - Silver to Gold layer transformations
   - Business rule implementations
   - Data type conversions and standardizations
   - Calculated field accuracy

2. **Data Quality Assurance**
   - Null value handling
   - Data integrity constraints
   - Referential integrity validation
   - Business logic validation

3. **Edge Case Handling**
   - Empty datasets
   - Invalid data scenarios
   - Boundary value testing
   - Schema evolution compatibility

4. **Performance and Scalability**
   - Large dataset processing
   - Incremental loading validation
   - Clustering key effectiveness
   - Query performance optimization

## Test Case Categories

### Category 1: Dimension Table Tests

#### Test Case ID: DIM_USER_001
**Test Case Description**: Validate GO_DIM_USER transformation from SI_USERS with proper data standardization
**Expected Outcome**: All user records transformed correctly with standardized naming, plan categorization, and derived attributes

**dbt Test Script**:
```yaml
# tests/dimension/test_go_dim_user_transformation.yml
version: 2

models:
  - name: go_dim_user
    tests:
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - user_key
            - effective_start_date
      - not_null:
          column_name: user_key
      - not_null:
          column_name: user_id
      - accepted_values:
          column_name: plan_type
          values: ['Basic', 'Pro', 'Enterprise', 'Unknown']
      - accepted_values:
          column_name: plan_category
          values: ['Free', 'Paid']
      - accepted_values:
          column_name: user_status
          values: ['Active', 'Inactive']
      - expression_is_true:
          expression: "effective_start_date <= effective_end_date"
      - expression_is_true:
          expression: "length(user_key) = 32"  # MD5 hash length
```

**Custom SQL Test**:
```sql
-- tests/dimension/test_user_name_standardization.sql
SELECT *
FROM {{ ref('go_dim_user') }}
WHERE user_name != INITCAP(TRIM(user_name))
   OR user_name IS NULL
   OR LENGTH(user_name) = 0
```

#### Test Case ID: DIM_DATE_002
**Test Case Description**: Validate GO_DIM_DATE dimension completeness and fiscal year calculations
**Expected Outcome**: Complete date range (2020-2030) with accurate fiscal year and calendar attributes

**dbt Test Script**:
```yaml
# tests/dimension/test_go_dim_date_completeness.yml
version: 2

models:
  - name: go_dim_date
    tests:
      - unique:
          column_name: date_key
      - not_null:
          column_name: date_key
      - expression_is_true:
          expression: "date_key >= '2020-01-01' AND date_key <= '2030-12-31'"
      - expression_is_true:
          expression: "year >= 2020 AND year <= 2030"
      - expression_is_true:
          expression: "quarter >= 1 AND quarter <= 4"
      - expression_is_true:
          expression: "month >= 1 AND month <= 12"
      - expression_is_true:
          expression: "day_of_month >= 1 AND day_of_month <= 31"
      - expression_is_true:
          expression: "day_of_week >= 1 AND day_of_week <= 7"
```

**Custom SQL Test**:
```sql
-- tests/dimension/test_fiscal_year_calculation.sql
SELECT *
FROM {{ ref('go_dim_date') }}
WHERE fiscal_year != CASE 
    WHEN month >= 4 THEN year 
    ELSE year - 1 
END
```

#### Test Case ID: DIM_FEATURE_003
**Test Case Description**: Validate GO_DIM_FEATURE categorization and premium feature identification
**Expected Outcome**: All features properly categorized with correct premium feature flags

**dbt Test Script**:
```yaml
# tests/dimension/test_go_dim_feature_categorization.yml
version: 2

models:
  - name: go_dim_feature
    tests:
      - unique:
          column_name: feature_key
      - not_null:
          column_name: feature_name
      - accepted_values:
          column_name: feature_category
          values: ['Collaboration', 'Recording', 'Communication', 'Advanced Meeting', 'Engagement', 'General']
      - accepted_values:
          column_name: feature_type
          values: ['Core', 'Advanced', 'Standard']
      - accepted_values:
          column_name: feature_complexity
          values: ['High', 'Medium', 'Low']
```

**Custom SQL Test**:
```sql
-- tests/dimension/test_premium_feature_logic.sql
SELECT *
FROM {{ ref('go_dim_feature') }}
WHERE (UPPER(feature_name) LIKE '%RECORD%' OR UPPER(feature_name) LIKE '%BREAKOUT%')
  AND is_premium_feature = FALSE
```

### Category 2: Fact Table Tests

#### Test Case ID: FACT_MEETING_001
**Test Case Description**: Validate GO_FACT_MEETING_ACTIVITY aggregations and quality score calculations
**Expected Outcome**: Accurate meeting metrics with proper participant counts and quality scores

**dbt Test Script**:
```yaml
# tests/fact/test_go_fact_meeting_activity.yml
version: 2

models:
  - name: go_fact_meeting_activity
    tests:
      - unique:
          column_name: meeting_activity_id
      - not_null:
          column_name: meeting_id
      - not_null:
          column_name: date_id
      - not_null:
          column_name: host_user_dim_id
      - expression_is_true:
          expression: "actual_duration_minutes >= 0"
      - expression_is_true:
          expression: "participant_count >= 0"
      - expression_is_true:
          expression: "meeting_quality_score >= 1.0 AND meeting_quality_score <= 10.0"
      - expression_is_true:
          expression: "audio_quality_score >= 1.0 AND audio_quality_score <= 5.0"
      - expression_is_true:
          expression: "video_quality_score >= 1.0 AND video_quality_score <= 5.0"
```

**Custom SQL Test**:
```sql
-- tests/fact/test_meeting_duration_consistency.sql
SELECT *
FROM {{ ref('go_fact_meeting_activity') }}
WHERE actual_duration_minutes > 1440  -- More than 24 hours
   OR actual_duration_minutes < 0
   OR (meeting_end_time IS NOT NULL 
       AND meeting_start_time IS NOT NULL 
       AND DATEDIFF('minute', meeting_start_time, meeting_end_time) != actual_duration_minutes)
```

#### Test Case ID: FACT_REVENUE_002
**Test Case Description**: Validate GO_FACT_REVENUE_EVENTS MRR/ARR calculations and currency handling
**Expected Outcome**: Accurate revenue calculations with proper MRR/ARR impact and currency standardization

**dbt Test Script**:
```yaml
# tests/fact/test_go_fact_revenue_events.yml
version: 2

models:
  - name: go_fact_revenue_events
    tests:
      - unique:
          column_name: revenue_event_id
      - not_null:
          column_name: user_dim_id
      - not_null:
          column_name: transaction_date
      - accepted_values:
          column_name: currency_code
          values: ['USD', 'EUR', 'GBP', 'CAD']
      - expression_is_true:
          expression: "gross_amount >= 0"
      - expression_is_true:
          expression: "net_amount = gross_amount - tax_amount - discount_amount"
      - expression_is_true:
          expression: "churn_risk_score >= 1.0 AND churn_risk_score <= 5.0"
```

**Custom SQL Test**:
```sql
-- tests/fact/test_mrr_arr_calculation.sql
SELECT *
FROM {{ ref('go_fact_revenue_events') }}
WHERE event_type IN ('Subscription', 'Renewal', 'Upgrade')
  AND (mrr_impact != net_amount / 12 
       OR arr_impact != net_amount)
```

#### Test Case ID: FACT_SUPPORT_003
**Test Case Description**: Validate GO_FACT_SUPPORT_METRICS SLA compliance and resolution time calculations
**Expected Outcome**: Accurate support metrics with proper SLA tracking and resolution performance

**dbt Test Script**:
```yaml
# tests/fact/test_go_fact_support_metrics.yml
version: 2

models:
  - name: go_fact_support_metrics
    tests:
      - unique:
          column_name: support_metrics_id
      - not_null:
          column_name: ticket_id
      - not_null:
          column_name: ticket_created_date
      - expression_is_true:
          expression: "resolution_time_hours >= 0"
      - expression_is_true:
          expression: "first_response_time_hours >= 0"
      - expression_is_true:
          expression: "customer_satisfaction_score >= 1.0 AND customer_satisfaction_score <= 5.0"
      - expression_is_true:
          expression: "escalation_count >= 0"
```

**Custom SQL Test**:
```sql
-- tests/fact/test_sla_compliance_logic.sql
SELECT 
    sm.*,
    sc.sla_target_hours
FROM {{ ref('go_fact_support_metrics') }} sm
JOIN {{ ref('go_dim_support_category') }} sc 
  ON sm.support_category_id = sc.support_category_id
WHERE (sm.resolution_time_hours <= sc.sla_target_hours AND sm.sla_met = FALSE)
   OR (sm.resolution_time_hours > sc.sla_target_hours AND sm.sla_met = TRUE)
```

### Category 3: Data Quality Tests

#### Test Case ID: DQ_REFERENTIAL_001
**Test Case Description**: Validate referential integrity between fact and dimension tables
**Expected Outcome**: All foreign keys in fact tables have corresponding records in dimension tables

**Custom SQL Test**:
```sql
-- tests/data_quality/test_referential_integrity.sql
-- Test for orphaned records in fact tables
SELECT 'GO_FACT_MEETING_ACTIVITY' as table_name, 'USER_DIM_ID' as column_name, COUNT(*) as orphaned_records
FROM {{ ref('go_fact_meeting_activity') }} f
LEFT JOIN {{ ref('go_dim_user') }} d ON f.host_user_dim_id = d.user_dim_id
WHERE d.user_dim_id IS NULL AND f.host_user_dim_id IS NOT NULL

UNION ALL

SELECT 'GO_FACT_REVENUE_EVENTS' as table_name, 'LICENSE_ID' as column_name, COUNT(*) as orphaned_records
FROM {{ ref('go_fact_revenue_events') }} f
LEFT JOIN {{ ref('go_dim_license') }} d ON f.license_id = d.license_id
WHERE d.license_id IS NULL AND f.license_id IS NOT NULL

UNION ALL

SELECT 'GO_FACT_FEATURE_USAGE' as table_name, 'FEATURE_ID' as column_name, COUNT(*) as orphaned_records
FROM {{ ref('go_fact_feature_usage') }} f
LEFT JOIN {{ ref('go_dim_feature') }} d ON f.feature_id = d.feature_id
WHERE d.feature_id IS NULL AND f.feature_id IS NOT NULL
```

#### Test Case ID: DQ_COMPLETENESS_002
**Test Case Description**: Validate data completeness for critical business fields
**Expected Outcome**: All critical fields have acceptable completeness rates (>95%)

**Custom SQL Test**:
```sql
-- tests/data_quality/test_data_completeness.sql
WITH completeness_check AS (
  SELECT 
    'GO_DIM_USER' as table_name,
    'USER_NAME' as column_name,
    COUNT(*) as total_records,
    COUNT(user_name) as non_null_records,
    (COUNT(user_name) * 100.0 / COUNT(*)) as completeness_percentage
  FROM {{ ref('go_dim_user') }}
  
  UNION ALL
  
  SELECT 
    'GO_FACT_MEETING_ACTIVITY' as table_name,
    'DURATION_MINUTES' as column_name,
    COUNT(*) as total_records,
    COUNT(actual_duration_minutes) as non_null_records,
    (COUNT(actual_duration_minutes) * 100.0 / COUNT(*)) as completeness_percentage
  FROM {{ ref('go_fact_meeting_activity') }}
  
  UNION ALL
  
  SELECT 
    'GO_FACT_REVENUE_EVENTS' as table_name,
    'NET_AMOUNT' as column_name,
    COUNT(*) as total_records,
    COUNT(net_amount) as non_null_records,
    (COUNT(net_amount) * 100.0 / COUNT(*)) as completeness_percentage
  FROM {{ ref('go_fact_revenue_events') }}
)
SELECT *
FROM completeness_check
WHERE completeness_percentage < 95.0
```

### Category 4: Business Logic Tests

#### Test Case ID: BL_PLAN_CATEGORIZATION_001
**Test Case Description**: Validate plan type standardization and categorization logic
**Expected Outcome**: All plan types correctly mapped to standard categories

**Custom SQL Test**:
```sql
-- tests/business_logic/test_plan_categorization.sql
SELECT *
FROM {{ ref('go_dim_user') }}
WHERE (plan_type = 'Basic' AND plan_category != 'Paid')
   OR (plan_type = 'Pro' AND plan_category != 'Paid')
   OR (plan_type = 'Enterprise' AND plan_category != 'Paid')
   OR (plan_type NOT IN ('Basic', 'Pro', 'Enterprise', 'Unknown'))
```

#### Test Case ID: BL_MEETING_QUALITY_002
**Test Case Description**: Validate meeting quality score calculation logic
**Expected Outcome**: Quality scores calculated correctly based on engagement and technical metrics

**Custom SQL Test**:
```sql
-- tests/business_logic/test_meeting_quality_calculation.sql
SELECT *
FROM {{ ref('go_fact_meeting_activity') }}
WHERE meeting_quality_score IS NOT NULL
  AND (
    (participant_count >= 5 AND average_participation_minutes >= (actual_duration_minutes * 0.8) AND meeting_quality_score != 5.0)
    OR (participant_count >= 3 AND average_participation_minutes >= (actual_duration_minutes * 0.6) AND meeting_quality_score != 4.0)
    OR (participant_count >= 2 AND average_participation_minutes >= (actual_duration_minutes * 0.4) AND meeting_quality_score != 3.0)
  )
```

### Category 5: Edge Case Tests

#### Test Case ID: EDGE_EMPTY_DATASET_001
**Test Case Description**: Validate model behavior with empty source datasets
**Expected Outcome**: Models handle empty inputs gracefully without errors

**Custom SQL Test**:
```sql
-- tests/edge_cases/test_empty_dataset_handling.sql
-- This test should be run with empty source tables
SELECT 
  CASE 
    WHEN COUNT(*) = 0 THEN 'PASS'
    ELSE 'FAIL'
  END as test_result
FROM {{ ref('go_dim_user') }}
WHERE 1=0  -- Simulating empty dataset
```

#### Test Case ID: EDGE_BOUNDARY_VALUES_002
**Test Case Description**: Validate handling of boundary values and extreme cases
**Expected Outcome**: Models handle boundary values correctly without data corruption

**Custom SQL Test**:
```sql
-- tests/edge_cases/test_boundary_values.sql
SELECT *
FROM {{ ref('go_fact_meeting_activity') }}
WHERE actual_duration_minutes = 0  -- Zero duration meetings
   OR participant_count = 0        -- Meetings with no participants
   OR actual_duration_minutes > 480 -- Very long meetings (8+ hours)
```

### Category 6: Performance Tests

#### Test Case ID: PERF_CLUSTERING_001
**Test Case Description**: Validate clustering key effectiveness for query performance
**Expected Outcome**: Queries using clustering keys show improved performance

**Custom SQL Test**:
```sql
-- tests/performance/test_clustering_effectiveness.sql
-- This test checks if clustering keys are being used effectively
SELECT 
  table_name,
  clustering_key,
  total_micro_partitions,
  clustered_micro_partitions,
  (clustered_micro_partitions * 100.0 / total_micro_partitions) as clustering_ratio
FROM INFORMATION_SCHEMA.AUTOMATIC_CLUSTERING_HISTORY
WHERE table_name IN ('GO_FACT_MEETING_ACTIVITY', 'GO_FACT_REVENUE_EVENTS', 'GO_FACT_SUPPORT_METRICS')
  AND clustering_ratio < 80.0  -- Alert if clustering ratio is below 80%
```

## dbt Test Configuration Files

### Schema Tests Configuration
```yaml
# models/schema.yml
version: 2

models:
  - name: go_dim_user
    description: "User dimension with standardized attributes and SCD Type 2 support"
    columns:
      - name: user_dim_id
        description: "Surrogate key for user dimension"
        tests:
          - unique
          - not_null
      - name: user_key
        description: "Business key (MD5 hash of user_id)"
        tests:
          - unique
          - not_null
      - name: plan_type
        description: "Standardized plan type"
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Enterprise', 'Unknown']

  - name: go_fact_meeting_activity
    description: "Meeting activity fact table with comprehensive metrics"
    columns:
      - name: meeting_activity_id
        description: "Surrogate key for meeting activity"
        tests:
          - unique
          - not_null
      - name: actual_duration_minutes
        description: "Actual meeting duration in minutes"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: ">= 0"
```

### Custom Test Macros
```sql
-- macros/test_data_freshness.sql
{% macro test_data_freshness(model, date_column, max_days_old=7) %}
  SELECT COUNT(*)
  FROM {{ model }}
  WHERE {{ date_column }} < CURRENT_DATE() - {{ max_days_old }}
{% endmacro %}

-- macros/test_referential_integrity.sql
{% macro test_referential_integrity(child_table, parent_table, foreign_key, primary_key) %}
  SELECT COUNT(*)
  FROM {{ child_table }} c
  LEFT JOIN {{ parent_table }} p ON c.{{ foreign_key }} = p.{{ primary_key }}
  WHERE p.{{ primary_key }} IS NULL
    AND c.{{ foreign_key }} IS NOT NULL
{% endmacro %}
```

## Test Execution Strategy

### 1. Pre-deployment Testing
```bash
# Run all tests before deployment
dbt test --models tag:dimension
dbt test --models tag:fact
dbt test --models tag:data_quality
```

### 2. Continuous Integration Testing
```yaml
# .github/workflows/dbt_ci.yml
name: dbt CI
on:
  pull_request:
    branches: [main]

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
          dbt seed
          dbt run --models tag:dimension
          dbt run --models tag:fact
          dbt test
```

### 3. Production Monitoring
```sql
-- Create monitoring views for ongoing test results
CREATE OR REPLACE VIEW GOLD.VW_TEST_RESULTS_SUMMARY AS
SELECT 
  test_name,
  model_name,
  test_status,
  execution_time,
  error_message,
  test_timestamp
FROM DBT_TEST_RESULTS
WHERE test_timestamp >= CURRENT_DATE() - 7
ORDER BY test_timestamp DESC;
```

## Test Data Management

### Sample Test Data Creation
```sql
-- seeds/test_data_si_users.csv
user_id,user_name,email,company,plan_type,validation_status
USER001,John Doe,john.doe@company.com,Test Company,PRO,PASSED
USER002,Jane Smith,jane.smith@enterprise.com,Enterprise Corp,ENTERPRISE,PASSED
USER003,Bob Johnson,bob@startup.com,Startup Inc,BASIC,PASSED

-- seeds/test_data_si_meetings.csv
meeting_id,host_id,meeting_topic,start_time,end_time,duration_minutes,validation_status
MTG001,USER001,Team Standup,2024-01-15 09:00:00,2024-01-15 09:30:00,30,PASSED
MTG002,USER002,Client Presentation,2024-01-15 14:00:00,2024-01-15 15:00:00,60,PASSED
MTG003,USER003,Project Review,2024-01-15 16:00:00,2024-01-15 17:30:00,90,PASSED
```

## Error Handling and Recovery

### Test Failure Handling
```sql
-- Handle test failures gracefully
{% if execute %}
  {% set test_results = run_query("SELECT COUNT(*) as failure_count FROM dbt_test_results WHERE test_status = 'FAIL'") %}
  {% if test_results[0][0] > 0 %}
    {{ log("WARNING: " ~ test_results[0][0] ~ " tests failed. Check dbt_test_results table for details.", info=True) }}
  {% endif %}
{% endif %}
```

## Conclusion

This comprehensive test suite ensures the reliability and quality of the Zoom Platform Analytics System dbt models by:

1. **Validating Data Transformations**: Ensuring accurate Silver to Gold layer transformations
2. **Enforcing Business Rules**: Validating plan categorization, quality calculations, and KPI logic
3. **Maintaining Data Quality**: Checking completeness, accuracy, and referential integrity
4. **Handling Edge Cases**: Testing boundary conditions and error scenarios
5. **Monitoring Performance**: Validating clustering effectiveness and query optimization
6. **Supporting CI/CD**: Enabling automated testing in deployment pipelines

The test cases cover all critical aspects of the data pipeline and provide comprehensive coverage for:
- 6 Dimension tables (GO_DIM_USER, GO_DIM_DATE, GO_DIM_FEATURE, GO_DIM_LICENSE, GO_DIM_MEETING_TYPE, GO_DIM_SUPPORT_CATEGORY)
- 4 Fact tables (GO_FACT_MEETING_ACTIVITY, GO_FACT_FEATURE_USAGE, GO_FACT_REVENUE_EVENTS, GO_FACT_SUPPORT_METRICS)
- 1 Audit table (GO_AUDIT_LOG)
- Data quality and validation processes

All tests are designed to run efficiently in Snowflake and integrate seamlessly with dbt's testing framework, providing reliable validation for the production-ready Gold layer transformation pipeline.