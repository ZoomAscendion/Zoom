_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases and dbt test scripts for Zoom Gold Layer Pipeline dbt models in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Zoom Gold Layer Pipeline

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Gold Layer Pipeline dbt models running in Snowflake. The test cases cover all dimension and fact tables, ensuring data quality, transformation accuracy, and business rule validation across the entire Gold layer.

## Test Coverage Overview

The test suite covers the following dbt models:

### Dimension Tables
- `go_dim_date` - Date dimension with calendar and fiscal attributes
- `go_dim_user` - User dimension with SCD Type 2 implementation
- `go_dim_feature` - Feature dimension for usage analysis
- `go_dim_license` - License dimension for entitlement analysis
- `go_dim_meeting_type` - Meeting type dimension
- `go_dim_support_category` - Support category dimension

### Fact Tables
- `go_fact_feature_usage` - Feature usage metrics
- `go_fact_meeting_activity` - Meeting activity and engagement metrics
- `go_fact_revenue_events` - Revenue and billing events
- `go_fact_support_metrics` - Support ticket metrics

### Infrastructure Tables
- `go_audit_log` - Audit logging for pipeline execution

## Test Case Categories

1. **Data Quality Tests** - Validate data integrity and completeness
2. **Business Rule Tests** - Ensure business logic is correctly implemented
3. **Transformation Tests** - Verify data transformations and calculations
4. **Edge Case Tests** - Handle null values, empty datasets, and boundary conditions
5. **Performance Tests** - Validate model execution performance
6. **Integration Tests** - Test relationships between models

---

## Test Case List

| Test Case ID | Test Case Description | Model | Test Type | Expected Outcome |
|--------------|----------------------|-------|-----------|------------------|
| TC_001 | Validate date dimension completeness | go_dim_date | Data Quality | All dates between start_date and end_date exist |
| TC_002 | Verify date dimension calculations | go_dim_date | Transformation | Fiscal year/quarter calculations are correct |
| TC_003 | Test weekend flag accuracy | go_dim_date | Business Rule | Weekend flags correctly identify Sat/Sun |
| TC_004 | Validate user dimension uniqueness | go_dim_user | Data Quality | USER_DIM_ID is unique across all records |
| TC_005 | Test user SCD Type 2 implementation | go_dim_user | Business Rule | Historical records maintained with proper effective dates |
| TC_006 | Verify email domain extraction | go_dim_user | Transformation | Email domains correctly extracted from email addresses |
| TC_007 | Test plan category standardization | go_dim_user | Business Rule | Plan types mapped to correct categories |
| TC_008 | Validate feature categorization | go_dim_feature | Business Rule | Features assigned to correct categories |
| TC_009 | Test premium feature identification | go_dim_feature | Business Rule | Premium features correctly flagged |
| TC_010 | Verify license pricing calculations | go_dim_license | Transformation | Monthly and annual pricing correctly calculated |
| TC_011 | Test license tier assignment | go_dim_license | Business Rule | License types assigned to correct tiers |
| TC_012 | Validate meeting type characteristics | go_dim_meeting_type | Business Rule | Meeting types have consistent characteristics |
| TC_013 | Test support category priority mapping | go_dim_support_category | Business Rule | Support categories mapped to correct priorities |
| TC_014 | Verify resolution time expectations | go_dim_support_category | Business Rule | Expected resolution hours align with priority |
| TC_015 | Validate feature usage calculations | go_fact_feature_usage | Transformation | Usage duration and intensity correctly calculated |
| TC_016 | Test feature usage aggregations | go_fact_feature_usage | Data Quality | Usage counts are positive and realistic |
| TC_017 | Verify meeting activity metrics | go_fact_meeting_activity | Transformation | Participation and engagement metrics accurate |
| TC_018 | Test meeting duration calculations | go_fact_meeting_activity | Business Rule | Actual duration matches start/end time difference |
| TC_019 | Validate revenue event calculations | go_fact_revenue_events | Transformation | Tax, discount, and net amounts correctly calculated |
| TC_020 | Test MRR/ARR impact calculations | go_fact_revenue_events | Business Rule | Monthly and annual recurring revenue correctly computed |
| TC_021 | Verify support metrics calculations | go_fact_support_metrics | Transformation | Resolution times and SLA metrics accurate |
| TC_022 | Test SLA compliance flags | go_fact_support_metrics | Business Rule | SLA met/breach flags correctly set |
| TC_023 | Validate audit log completeness | go_audit_log | Data Quality | All model executions logged |
| TC_024 | Test null value handling | All Models | Edge Case | Null values handled appropriately |
| TC_025 | Verify referential integrity | All Models | Integration | Foreign key relationships maintained |
| TC_026 | Test empty dataset handling | All Models | Edge Case | Models handle empty source data gracefully |
| TC_027 | Validate data type consistency | All Models | Data Quality | All columns have correct data types |
| TC_028 | Test incremental load logic | All Models | Performance | Incremental models process only new/changed data |
| TC_029 | Verify source data validation | All Models | Data Quality | Invalid source data is handled or rejected |
| TC_030 | Test model dependencies | All Models | Integration | Models execute in correct dependency order |

---

## dbt Test Scripts

### 1. Schema Tests (schema.yml)

```yaml
version: 2

models:
  # Date Dimension Tests
  - name: go_dim_date
    description: "Date dimension table for time-based analysis"
    tests:
      - dbt_utils.expression_is_true:
          expression: "count(*) > 0"
          config:
            severity: error
    columns:
      - name: date_id
        description: "Unique date identifier"
        tests:
          - unique:
              config:
                severity: error
          - not_null:
              config:
                severity: error
      - name: date_value
        description: "Actual date value"
        tests:
          - not_null:
              config:
                severity: error
          - dbt_utils.expression_is_true:
              expression: "date_value >= '2020-01-01'"
              config:
                severity: warn
      - name: year
        description: "Year component"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "year between 2020 and 2030"
      - name: is_weekend
        description: "Weekend flag"
        tests:
          - accepted_values:
              values: [true, false]
      - name: fiscal_year
        description: "Fiscal year calculation"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "fiscal_year >= year - 1 and fiscal_year <= year + 1"

  # User Dimension Tests
  - name: go_dim_user
    description: "User dimension table with SCD Type 2"
    tests:
      - dbt_utils.expression_is_true:
          expression: "count(*) > 0"
    columns:
      - name: user_dim_id
        description: "Surrogate key for user dimension"
        tests:
          - unique:
              config:
                severity: error
          - not_null:
              config:
                severity: error
      - name: user_id
        description: "Business key for user"
        tests:
          - not_null:
              config:
                severity: error
      - name: email_domain
        description: "Email domain extracted from user email"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "length(email_domain) > 0"
      - name: plan_category
        description: "Standardized plan category"
        tests:
          - accepted_values:
              values: ['Basic', 'Professional', 'Enterprise', 'Other']
      - name: is_current_record
        description: "Current record flag for SCD Type 2"
        tests:
          - accepted_values:
              values: [true, false]
          - not_null

  # Feature Dimension Tests
  - name: go_dim_feature
    description: "Feature dimension table"
    columns:
      - name: feature_id
        description: "Unique feature identifier"
        tests:
          - unique:
              config:
                severity: error
          - not_null:
              config:
                severity: error
      - name: feature_name
        description: "Feature name"
        tests:
          - not_null:
              config:
                severity: error
          - dbt_utils.expression_is_true:
              expression: "length(trim(feature_name)) > 0"
      - name: feature_category
        description: "Feature category"
        tests:
          - accepted_values:
              values: ['Collaboration', 'Recording', 'Communication', 'Meeting Management', 'Other']
      - name: is_premium_feature
        description: "Premium feature flag"
        tests:
          - accepted_values:
              values: [true, false]
          - not_null

  # License Dimension Tests
  - name: go_dim_license
    description: "License dimension table"
    columns:
      - name: license_id
        description: "Unique license identifier"
        tests:
          - unique:
              config:
                severity: error
          - not_null:
              config:
                severity: error
      - name: license_type
        description: "License type"
        tests:
          - not_null:
              config:
                severity: error
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

  # Meeting Type Dimension Tests
  - name: go_dim_meeting_type
    description: "Meeting type dimension"
    columns:
      - name: meeting_type_id
        description: "Unique meeting type identifier"
        tests:
          - unique:
              config:
                severity: error
          - not_null:
              config:
                severity: error
      - name: meeting_type
        description: "Meeting type name"
        tests:
          - not_null:
              config:
                severity: error
      - name: max_participants_allowed
        description: "Maximum participants allowed"
        tests:
          - dbt_utils.expression_is_true:
              expression: "max_participants_allowed > 0"

  # Support Category Dimension Tests
  - name: go_dim_support_category
    description: "Support category dimension"
    columns:
      - name: support_category_id
        description: "Unique support category identifier"
        tests:
          - unique:
              config:
                severity: error
          - not_null:
              config:
                severity: error
      - name: support_category
        description: "Support category name"
        tests:
          - not_null:
              config:
                severity: error
      - name: priority_level
        description: "Priority level"
        tests:
          - accepted_values:
              values: ['Critical', 'High', 'Medium', 'Low']
      - name: expected_resolution_hours
        description: "Expected resolution hours"
        tests:
          - dbt_utils.expression_is_true:
              expression: "expected_resolution_hours > 0"

  # Feature Usage Fact Tests
  - name: go_fact_feature_usage
    description: "Feature usage fact table"
    tests:
      - dbt_utils.expression_is_true:
          expression: "count(*) > 0"
    columns:
      - name: feature_usage_id
        description: "Unique feature usage identifier"
        tests:
          - unique:
              config:
                severity: error
          - not_null:
              config:
                severity: error
      - name: usage_date
        description: "Usage date"
        tests:
          - not_null:
              config:
                severity: error
      - name: feature_name
        description: "Feature name"
        tests:
          - not_null:
              config:
                severity: error
      - name: usage_count
        description: "Usage count"
        tests:
          - not_null:
              config:
                severity: error
          - dbt_utils.expression_is_true:
              expression: "usage_count > 0"
      - name: success_rate_percentage
        description: "Success rate percentage"
        tests:
          - dbt_utils.expression_is_true:
              expression: "success_rate_percentage between 0 and 100"

  # Meeting Activity Fact Tests
  - name: go_fact_meeting_activity
    description: "Meeting activity fact table"
    columns:
      - name: meeting_activity_id
        description: "Unique meeting activity identifier"
        tests:
          - unique:
              config:
                severity: error
          - not_null:
              config:
                severity: error
      - name: meeting_date
        description: "Meeting date"
        tests:
          - not_null:
              config:
                severity: error
      - name: participant_count
        description: "Number of participants"
        tests:
          - dbt_utils.expression_is_true:
              expression: "participant_count > 0"
      - name: actual_duration_minutes
        description: "Actual meeting duration"
        tests:
          - dbt_utils.expression_is_true:
              expression: "actual_duration_minutes >= 0"

  # Revenue Events Fact Tests
  - name: go_fact_revenue_events
    description: "Revenue events fact table"
    columns:
      - name: revenue_event_id
        description: "Unique revenue event identifier"
        tests:
          - unique:
              config:
                severity: error
          - not_null:
              config:
                severity: error
      - name: transaction_date
        description: "Transaction date"
        tests:
          - not_null:
              config:
                severity: error
      - name: gross_amount
        description: "Gross transaction amount"
        tests:
          - not_null:
              config:
                severity: error
          - dbt_utils.expression_is_true:
              expression: "gross_amount > 0"
      - name: net_amount
        description: "Net transaction amount"
        tests:
          - dbt_utils.expression_is_true:
              expression: "net_amount >= gross_amount"

  # Support Metrics Fact Tests
  - name: go_fact_support_metrics
    description: "Support metrics fact table"
    columns:
      - name: support_metrics_id
        description: "Unique support metrics identifier"
        tests:
          - unique:
              config:
                severity: error
          - not_null:
              config:
                severity: error
      - name: ticket_open_date
        description: "Ticket open date"
        tests:
          - not_null:
              config:
                severity: error
      - name: resolution_time_hours
        description: "Resolution time in hours"
        tests:
          - dbt_utils.expression_is_true:
              expression: "resolution_time_hours >= 0 or resolution_time_hours is null"
      - name: sla_met_flag
        description: "SLA met flag"
        tests:
          - accepted_values:
              values: [true, false]

  # Audit Log Tests
  - name: go_audit_log
    description: "Audit log table"
    columns:
      - name: audit_id
        description: "Unique audit identifier"
        tests:
          - not_null:
              config:
                severity: error
      - name: process_name
        description: "Process name"
        tests:
          - not_null
      - name: process_status
        description: "Process status"
        tests:
          - accepted_values:
              values: ['RUNNING', 'SUCCESS', 'FAILED']
```

### 2. Custom SQL Tests

#### Test: Date Dimension Completeness
```sql
-- tests/test_date_dimension_completeness.sql
-- Test that date dimension has no gaps in date sequence

with date_gaps as (
    select 
        date_value,
        lag(date_value) over (order by date_value) as prev_date,
        datediff(day, lag(date_value) over (order by date_value), date_value) as day_diff
    from {{ ref('go_dim_date') }}
    where date_value between '2020-01-01' and '2030-12-31'
)

select *
from date_gaps
where day_diff > 1
```

#### Test: User SCD Type 2 Validation
```sql
-- tests/test_user_scd_type2_validation.sql
-- Test that SCD Type 2 logic is correctly implemented for users

with user_overlaps as (
    select 
        user_id,
        count(*) as active_records
    from {{ ref('go_dim_user') }}
    where is_current_record = true
    group by user_id
    having count(*) > 1
)

select *
from user_overlaps
```

#### Test: Feature Usage Data Quality
```sql
-- tests/test_feature_usage_data_quality.sql
-- Test feature usage data quality and business rules

with invalid_usage as (
    select 
        feature_usage_id,
        feature_name,
        usage_count,
        usage_duration_minutes,
        success_rate_percentage
    from {{ ref('go_fact_feature_usage') }}
    where 
        usage_count <= 0
        or usage_duration_minutes < 0
        or success_rate_percentage < 0
        or success_rate_percentage > 100
        or feature_name is null
        or trim(feature_name) = ''
)

select *
from invalid_usage
```

#### Test: Meeting Activity Calculations
```sql
-- tests/test_meeting_activity_calculations.sql
-- Test meeting activity metric calculations

with invalid_calculations as (
    select 
        meeting_activity_id,
        meeting_start_time,
        meeting_end_time,
        actual_duration_minutes,
        participant_count,
        unique_participants
    from {{ ref('go_fact_meeting_activity') }}
    where 
        (meeting_end_time is not null and meeting_start_time > meeting_end_time)
        or actual_duration_minutes < 0
        or participant_count < 0
        or unique_participants < 0
        or unique_participants > participant_count
)

select *
from invalid_calculations
```

#### Test: Revenue Event Calculations
```sql
-- tests/test_revenue_event_calculations.sql
-- Test revenue event calculation accuracy

with invalid_revenue as (
    select 
        revenue_event_id,
        gross_amount,
        tax_amount,
        discount_amount,
        net_amount,
        abs(net_amount - (gross_amount + tax_amount - discount_amount)) as calculation_diff
    from {{ ref('go_fact_revenue_events') }}
    where 
        gross_amount <= 0
        or tax_amount < 0
        or discount_amount < 0
        or net_amount <= 0
        or abs(net_amount - (gross_amount + tax_amount - discount_amount)) > 0.01
)

select *
from invalid_revenue
```

#### Test: Support Metrics SLA Validation
```sql
-- tests/test_support_metrics_sla_validation.sql
-- Test support metrics SLA calculations

with sla_validation as (
    select 
        support_metrics_id,
        ticket_type,
        priority_level,
        resolution_time_hours,
        sla_met_flag,
        case 
            when upper(priority_level) = 'CRITICAL' and resolution_time_hours <= 4 then true
            when upper(priority_level) = 'HIGH' and resolution_time_hours <= 24 then true
            when upper(priority_level) = 'MEDIUM' and resolution_time_hours <= 72 then true
            when upper(priority_level) = 'LOW' and resolution_time_hours <= 168 then true
            when resolution_time_hours is null then null
            else false
        end as expected_sla_met
    from {{ ref('go_fact_support_metrics') }}
)

select *
from sla_validation
where sla_met_flag != expected_sla_met
  and expected_sla_met is not null
```

#### Test: Referential Integrity
```sql
-- tests/test_referential_integrity.sql
-- Test referential integrity across fact and dimension tables

with orphaned_records as (
    -- Check feature usage without corresponding feature dimension
    select 'feature_usage' as table_name, feature_name as orphaned_key
    from {{ ref('go_fact_feature_usage') }} fu
    left join {{ ref('go_dim_feature') }} df on upper(fu.feature_name) = upper(df.feature_name)
    where df.feature_name is null
    
    union all
    
    -- Check meeting activity dates without corresponding date dimension
    select 'meeting_activity' as table_name, meeting_date::varchar as orphaned_key
    from {{ ref('go_fact_meeting_activity') }} ma
    left join {{ ref('go_dim_date') }} dd on ma.meeting_date = dd.date_value
    where dd.date_value is null
)

select *
from orphaned_records
```

### 3. Macro-based Tests

#### Test: Data Freshness
```sql
-- macros/test_data_freshness.sql
{% macro test_data_freshness(model_name, date_column, max_days_old=7) %}
    select count(*) as stale_records
    from {{ ref(model_name) }}
    where {{ date_column }} < current_date - {{ max_days_old }}
    having count(*) > 0
{% endmacro %}
```

#### Test: Null Percentage
```sql
-- macros/test_null_percentage.sql
{% macro test_null_percentage(model_name, column_name, max_null_percentage=10) %}
    select 
        '{{ column_name }}' as column_name,
        count(*) as total_records,
        sum(case when {{ column_name }} is null then 1 else 0 end) as null_records,
        (sum(case when {{ column_name }} is null then 1 else 0 end) * 100.0 / count(*)) as null_percentage
    from {{ ref(model_name) }}
    having null_percentage > {{ max_null_percentage }}
{% endmacro %}
```

### 4. Performance Tests

#### Test: Model Execution Time
```sql
-- tests/test_model_execution_time.sql
-- Monitor model execution performance

with execution_stats as (
    select 
        process_name,
        process_duration_seconds,
        records_processed,
        records_processed / nullif(process_duration_seconds, 0) as records_per_second
    from {{ ref('go_audit_log') }}
    where process_status = 'SUCCESS'
      and process_duration_seconds > 300  -- More than 5 minutes
)

select *
from execution_stats
order by process_duration_seconds desc
```

### 5. Integration Tests

#### Test: End-to-End Data Flow
```sql
-- tests/test_end_to_end_data_flow.sql
-- Test complete data flow from Silver to Gold

with source_counts as (
    select 'si_users' as source_table, count(*) as source_count
    from {{ source('silver', 'si_users') }}
    union all
    select 'si_meetings' as source_table, count(*) as source_count
    from {{ source('silver', 'si_meetings') }}
    union all
    select 'si_feature_usage' as source_table, count(*) as source_count
    from {{ source('silver', 'si_feature_usage') }}
),

target_counts as (
    select 'go_dim_user' as target_table, count(*) as target_count
    from {{ ref('go_dim_user') }}
    union all
    select 'go_fact_meeting_activity' as target_table, count(*) as target_count
    from {{ ref('go_fact_meeting_activity') }}
    union all
    select 'go_fact_feature_usage' as target_table, count(*) as target_count
    from {{ ref('go_fact_feature_usage') }}
)

select 
    sc.source_table,
    sc.source_count,
    tc.target_table,
    tc.target_count,
    case 
        when tc.target_count = 0 and sc.source_count > 0 then 'NO_DATA_LOADED'
        when tc.target_count < sc.source_count * 0.8 then 'SIGNIFICANT_DATA_LOSS'
        else 'OK'
    end as data_flow_status
from source_counts sc
left join target_counts tc on (
    (sc.source_table = 'si_users' and tc.target_table = 'go_dim_user') or
    (sc.source_table = 'si_meetings' and tc.target_table = 'go_fact_meeting_activity') or
    (sc.source_table = 'si_feature_usage' and tc.target_table = 'go_fact_feature_usage')
)
where data_flow_status != 'OK'
```

## Test Execution Strategy

### 1. Pre-deployment Testing
```bash
# Run all tests before deployment
dbt test --models tag:pre_deploy

# Run specific model tests
dbt test --models go_dim_date
dbt test --models go_fact_feature_usage

# Run tests with specific severity
dbt test --models tag:critical --fail-fast
```

### 2. Post-deployment Validation
```bash
# Run data quality tests after deployment
dbt test --models tag:data_quality

# Run integration tests
dbt test --models tag:integration

# Generate test documentation
dbt docs generate
dbt docs serve
```

### 3. Continuous Monitoring
```bash
# Daily data quality checks
dbt test --models tag:daily_check

# Weekly comprehensive testing
dbt test --models tag:weekly_check

# Performance monitoring
dbt test --models tag:performance
```

## Test Configuration

### dbt_project.yml Test Configuration
```yaml
tests:
  zoom_gold_pipeline:
    +severity: warn
    +store_failures: true
    +schema: test_results
    
    critical:
      +severity: error
      +fail_fast: true
    
    data_quality:
      +severity: warn
      +store_failures: true
    
    performance:
      +severity: warn
      +enabled: "{{ var('run_performance_tests', false) }}"
```

## Expected Test Results

### Success Criteria
- All critical tests (severity: error) must pass
- Data quality tests should have < 5% failure rate
- Performance tests should complete within acceptable time limits
- Integration tests should show consistent data flow
- No orphaned records in fact tables
- All business rules validated successfully

### Failure Handling
- Critical failures block deployment
- Warning-level failures logged for investigation
- Performance issues trigger optimization review
- Data quality issues trigger source data investigation

## Maintenance and Updates

### Regular Test Review
- Monthly review of test coverage and effectiveness
- Quarterly update of test thresholds and expectations
- Annual comprehensive test suite evaluation

### Test Enhancement
- Add new tests for new business rules
- Update existing tests for changed requirements
- Optimize test performance for large datasets
- Enhance test documentation and examples

---

## Conclusion

This comprehensive test suite ensures the reliability, accuracy, and performance of the Zoom Gold Layer Pipeline dbt models in Snowflake. The tests cover all critical aspects of data quality, business logic, and system integration, providing confidence in the data pipeline's output for downstream analytics and reporting.

Regular execution of these tests, combined with proper monitoring and maintenance, will help maintain high data quality standards and catch issues early in the development cycle.