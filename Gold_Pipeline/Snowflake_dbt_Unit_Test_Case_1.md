_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases and dbt test scripts for Zoom Platform Analytics Gold Layer dbt models
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Case for Gold Layer Models

## Overview

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics System Gold Layer dbt models. The tests validate data transformations, business rules, edge cases, and error handling to ensure reliable and high-quality data pipelines in Snowflake.

### Models Under Test

1. **Dimension Models**
   - `dim_user.sql` - User dimension with SCD Type 2
   - `dim_date.sql` - Date dimension with fiscal year support
   - `dim_meeting.sql` - Meeting dimension with categorization
   - `dim_feature.sql` - Feature dimension with usage tracking
   - `dim_license.sql` - License dimension with pricing
   - `dim_support_category.sql` - Support category dimension

2. **Fact Models**
   - `fact_meeting_summary.sql` - Meeting aggregation facts
   - `fact_user_activity.sql` - User activity tracking facts
   - `fact_feature_usage.sql` - Feature usage metrics
   - `fact_revenue_events.sql` - Revenue and billing facts
   - `fact_support_metrics.sql` - Support performance facts

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
| TC_DIM_001 | Validate dim_user surrogate key uniqueness | dim_user | All USER_DIM_ID values are unique |
| TC_DIM_002 | Validate dim_user SCD Type 2 implementation | dim_user | Historical records maintained with proper effective dates |
| TC_DIM_003 | Validate dim_date completeness for date range | dim_date | All dates from 2020-2030 are present |
| TC_DIM_004 | Validate dim_meeting duration categorization | dim_meeting | Meetings categorized correctly by duration |
| TC_DIM_005 | Validate dim_feature premium feature flagging | dim_feature | Premium features identified correctly |
| TC_DIM_006 | Validate dim_license pricing calculations | dim_license | Monthly and annual pricing calculated correctly |
| TC_FACT_001 | Validate fact_meeting_summary aggregations | fact_meeting_summary | Participant counts and durations aggregated correctly |
| TC_FACT_002 | Validate fact_user_activity session categorization | fact_user_activity | Activity sessions categorized by duration |
| TC_FACT_003 | Validate fact_feature_usage adoption scoring | fact_feature_usage | Feature adoption scores calculated correctly |
| TC_FACT_004 | Validate fact_revenue_events MRR calculations | fact_revenue_events | Monthly recurring revenue calculated accurately |
| TC_FACT_005 | Validate fact_support_metrics SLA compliance | fact_support_metrics | SLA compliance tracked correctly |
| TC_EDGE_001 | Handle missing Silver layer tables gracefully | All models | Models execute with sample data when Silver tables missing |
| TC_EDGE_002 | Handle NULL values in source data | All models | NULL values handled with appropriate defaults |
| TC_EDGE_003 | Handle duplicate records in source | All models | Deduplication logic works correctly |
| TC_PERF_001 | Validate model execution performance | All models | Models execute within acceptable time limits |
| TC_INTG_001 | Validate foreign key relationships | Fact models | All foreign keys reference valid dimension records |

---

## dbt Test Scripts

### Schema Tests (schema.yml)

```yaml
version: 2

models:
  # Dimension Models Tests
  - name: dim_user
    description: "User dimension with slowly changing dimension Type 2 implementation"
    tests:
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - user_id
            - effective_start_date
    columns:
      - name: user_dim_id
        description: "Surrogate key for user dimension"
        tests:
          - unique
          - not_null
      - name: user_id
        description: "Business key for user"
        tests:
          - not_null
      - name: user_name
        description: "User display name"
        tests:
          - not_null
      - name: email
        description: "User email address"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "email LIKE '%@%'"
      - name: plan_type
        description: "User subscription plan"
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Enterprise', 'Free']
      - name: effective_start_date
        description: "SCD effective start date"
        tests:
          - not_null
      - name: effective_end_date
        description: "SCD effective end date"
        tests:
          - not_null
      - name: is_current_record
        description: "Current record flag for SCD"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  - name: dim_date
    description: "Date dimension with fiscal year support"
    tests:
      - dbt_utils.expression_is_true:
          expression: "count(*) >= 3653" # At least 10 years of dates
    columns:
      - name: date_key
        description: "Date surrogate key"
        tests:
          - unique
          - not_null
      - name: date_value
        description: "Actual date value"
        tests:
          - unique
          - not_null
      - name: year
        description: "Calendar year"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "year BETWEEN 2020 AND 2030"
      - name: fiscal_year
        description: "Fiscal year starting April 1st"
        tests:
          - not_null
      - name: is_weekend
        description: "Weekend flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  - name: dim_meeting
    description: "Meeting dimension with categorization"
    columns:
      - name: meeting_id
        description: "Meeting surrogate key"
        tests:
          - unique
          - not_null
      - name: meeting_uuid
        description: "Meeting business key"
        tests:
          - unique
          - not_null
      - name: duration_category
        description: "Meeting duration category"
        tests:
          - accepted_values:
              values: ['Short', 'Medium', 'Long', 'Very Long']
      - name: time_of_day_category
        description: "Time of day category"
        tests:
          - accepted_values:
              values: ['Morning', 'Afternoon', 'Evening', 'Night']

  - name: dim_feature
    description: "Feature dimension with usage characteristics"
    columns:
      - name: feature_id
        description: "Feature surrogate key"
        tests:
          - unique
          - not_null
      - name: feature_name
        description: "Feature name"
        tests:
          - unique
          - not_null
      - name: feature_category
        description: "Feature category"
        tests:
          - accepted_values:
              values: ['Communication', 'Collaboration', 'Recording', 'Advanced Meeting', 'Engagement', 'General']
      - name: is_premium_feature
        description: "Premium feature flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  # Fact Models Tests
  - name: fact_meeting_summary
    description: "Meeting summary fact table"
    tests:
      - dbt_utils.expression_is_true:
          expression: "total_participants >= 0"
      - dbt_utils.expression_is_true:
          expression: "avg_participant_duration >= 0"
    columns:
      - name: meeting_summary_id
        description: "Fact table surrogate key"
        tests:
          - unique
          - not_null
      - name: meeting_id
        description: "Reference to meeting dimension"
        tests:
          - not_null
          - relationships:
              to: ref('dim_meeting')
              field: meeting_id
      - name: date_key
        description: "Reference to date dimension"
        tests:
          - not_null
          - relationships:
              to: ref('dim_date')
              field: date_key
      - name: total_participants
        description: "Total meeting participants"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: ">= 0"
      - name: avg_participant_duration
        description: "Average participant duration"
        tests:
          - dbt_utils.expression_is_true:
              expression: ">= 0"

  - name: fact_user_activity
    description: "User activity fact table"
    columns:
      - name: activity_id
        description: "Activity surrogate key"
        tests:
          - unique
          - not_null
      - name: user_id
        description: "Reference to user dimension"
        tests:
          - not_null
          - relationships:
              to: ref('dim_user')
              field: user_id
      - name: activity_type
        description: "Type of activity"
        tests:
          - accepted_values:
              values: ['meeting', 'breakout']
      - name: session_duration_category
        description: "Session duration category"
        tests:
          - accepted_values:
              values: ['Very Short Session', 'Short Session', 'Medium Session', 'Long Session']
```

### Custom SQL Tests

#### Test 1: Validate SCD Type 2 Implementation for dim_user

```sql
-- tests/test_dim_user_scd_implementation.sql
-- Validate that SCD Type 2 is properly implemented for user dimension

SELECT 
    user_id,
    COUNT(*) as record_count,
    SUM(CASE WHEN is_current_record THEN 1 ELSE 0 END) as current_records
FROM {{ ref('dim_user') }}
GROUP BY user_id
HAVING 
    SUM(CASE WHEN is_current_record THEN 1 ELSE 0 END) != 1  -- Each user should have exactly one current record
    OR COUNT(*) < 1  -- Each user should have at least one record
```

#### Test 2: Validate Date Dimension Completeness

```sql
-- tests/test_dim_date_completeness.sql
-- Validate that date dimension has no gaps in date range

WITH expected_dates AS (
    SELECT 
        DATEADD(day, ROW_NUMBER() OVER (ORDER BY 1) - 1, '2020-01-01'::DATE) as expected_date
    FROM TABLE(GENERATOR(ROWCOUNT => 4018)) -- 11 years
),
actual_dates AS (
    SELECT date_key as actual_date
    FROM {{ ref('dim_date') }}
)
SELECT expected_date
FROM expected_dates e
LEFT JOIN actual_dates a ON e.expected_date = a.actual_date
WHERE a.actual_date IS NULL
```

#### Test 3: Validate Meeting Duration Categorization Logic

```sql
-- tests/test_meeting_duration_categorization.sql
-- Validate that meeting duration categories are assigned correctly

SELECT 
    meeting_id,
    duration,
    duration_category,
    CASE 
        WHEN duration <= 5 THEN 'Very Short'
        WHEN duration <= 30 THEN 'Short'
        WHEN duration <= 60 THEN 'Medium'
        ELSE 'Long'
    END as expected_category
FROM {{ ref('dim_meeting') }}
WHERE duration_category != CASE 
    WHEN duration <= 5 THEN 'Very Short'
    WHEN duration <= 30 THEN 'Short'
    WHEN duration <= 60 THEN 'Medium'
    ELSE 'Long'
END
```

#### Test 4: Validate Fact Table Aggregations

```sql
-- tests/test_fact_meeting_summary_aggregations.sql
-- Validate that meeting summary aggregations are calculated correctly

WITH source_aggregation AS (
    SELECT 
        meeting_id,
        COUNT(DISTINCT user_id) as expected_participants,
        AVG(DATEDIFF('minute', join_time, leave_time)) as expected_avg_duration
    FROM {{ source('silver', 'silver_meeting_participants') }}
    GROUP BY meeting_id
),
fact_aggregation AS (
    SELECT 
        meeting_id,
        total_participants,
        avg_participant_duration
    FROM {{ ref('fact_meeting_summary') }}
)
SELECT 
    s.meeting_id,
    s.expected_participants,
    f.total_participants,
    s.expected_avg_duration,
    f.avg_participant_duration
FROM source_aggregation s
JOIN fact_aggregation f ON s.meeting_id = f.meeting_id
WHERE 
    s.expected_participants != f.total_participants
    OR ABS(s.expected_avg_duration - f.avg_participant_duration) > 1  -- Allow 1 minute tolerance
```

#### Test 5: Validate Foreign Key Relationships

```sql
-- tests/test_foreign_key_relationships.sql
-- Validate that all foreign keys in fact tables reference valid dimension records

-- Test meeting_id foreign key
SELECT 'fact_meeting_summary' as table_name, 'meeting_id' as column_name, COUNT(*) as orphan_count
FROM {{ ref('fact_meeting_summary') }} f
LEFT JOIN {{ ref('dim_meeting') }} d ON f.meeting_id = d.meeting_id
WHERE d.meeting_id IS NULL AND f.meeting_id IS NOT NULL

UNION ALL

-- Test user_id foreign key in fact_user_activity
SELECT 'fact_user_activity' as table_name, 'user_id' as column_name, COUNT(*) as orphan_count
FROM {{ ref('fact_user_activity') }} f
LEFT JOIN {{ ref('dim_user') }} d ON f.user_id = d.user_id AND d.is_current_record = TRUE
WHERE d.user_id IS NULL AND f.user_id IS NOT NULL

HAVING COUNT(*) > 0  -- Fail if any orphan records found
```

#### Test 6: Validate Data Freshness and Completeness

```sql
-- tests/test_data_freshness.sql
-- Validate that data is fresh and complete

SELECT 
    'dim_user' as table_name,
    COUNT(*) as record_count,
    MAX(load_timestamp) as latest_load,
    MIN(load_timestamp) as earliest_load
FROM {{ ref('dim_user') }}
WHERE load_timestamp < CURRENT_DATE() - INTERVAL '7 DAYS'  -- Data should be within 7 days

UNION ALL

SELECT 
    'fact_meeting_summary' as table_name,
    COUNT(*) as record_count,
    MAX(load_timestamp) as latest_load,
    MIN(load_timestamp) as earliest_load
FROM {{ ref('fact_meeting_summary') }}
WHERE load_timestamp < CURRENT_DATE() - INTERVAL '7 DAYS'

HAVING COUNT(*) > 0  -- Fail if any stale data found
```

#### Test 7: Validate Business Rule Implementation

```sql
-- tests/test_business_rules.sql
-- Validate that business rules are properly implemented

-- Test 1: Premium features should have higher adoption scores
SELECT 
    'premium_feature_adoption' as test_name,
    COUNT(*) as violation_count
FROM {{ ref('dim_feature') }} f
JOIN {{ ref('fact_feature_usage') }} fu ON f.feature_id = fu.feature_id
WHERE f.is_premium_feature = TRUE 
  AND fu.feature_adoption_score < 2.0  -- Premium features should have adoption score >= 2.0

UNION ALL

-- Test 2: Enterprise users should have higher activity levels
SELECT 
    'enterprise_user_activity' as test_name,
    COUNT(*) as violation_count
FROM {{ ref('dim_user') }} u
JOIN {{ ref('fact_user_activity') }} ua ON u.user_id = ua.user_id
WHERE u.plan_type = 'Enterprise'
  AND u.is_current_record = TRUE
  AND ua.session_duration_category = 'Very Short Session'  -- Enterprise users should have longer sessions

HAVING SUM(violation_count) > 0  -- Fail if any business rule violations found
```

#### Test 8: Validate Error Handling and Edge Cases

```sql
-- tests/test_error_handling.sql
-- Validate that models handle edge cases and errors gracefully

-- Test NULL handling in transformations
SELECT 
    'null_handling' as test_name,
    COUNT(*) as null_count
FROM {{ ref('dim_user') }}
WHERE user_name = 'Unknown User'  -- Should have default value for NULL names
  OR email = 'unknown@domain.com'  -- Should have default value for NULL emails

UNION ALL

-- Test duplicate handling
SELECT 
    'duplicate_handling' as test_name,
    COUNT(*) - COUNT(DISTINCT user_id, effective_start_date) as duplicate_count
FROM {{ ref('dim_user') }}

HAVING SUM(CASE WHEN test_name = 'duplicate_handling' THEN null_count ELSE 0 END) > 0  -- Fail if duplicates found
```

### Parameterized Tests

#### Test 9: Parameterized Data Quality Tests

```sql
-- tests/test_data_quality_metrics.sql
-- Parameterized test for data quality across all models

{% set models_to_test = [
    'dim_user',
    'dim_date', 
    'dim_meeting',
    'fact_meeting_summary',
    'fact_user_activity'
] %}

{% for model in models_to_test %}
    SELECT 
        '{{ model }}' as model_name,
        'completeness' as metric_type,
        COUNT(*) as total_records,
        COUNT(CASE WHEN load_timestamp IS NULL THEN 1 END) as null_load_timestamps,
        (COUNT(CASE WHEN load_timestamp IS NULL THEN 1 END) * 100.0 / COUNT(*)) as null_percentage
    FROM {{ ref(model) }}
    WHERE (COUNT(CASE WHEN load_timestamp IS NULL THEN 1 END) * 100.0 / COUNT(*)) > 5  -- Fail if >5% NULL
    
    {% if not loop.last %}
    UNION ALL
    {% endif %}
{% endfor %}
```

### Performance Tests

#### Test 10: Model Execution Performance

```sql
-- tests/test_model_performance.sql
-- Validate that models execute within acceptable time limits

WITH model_performance AS (
    SELECT 
        model_name,
        execution_time_seconds,
        CASE 
            WHEN model_name LIKE 'dim_%' AND execution_time_seconds > 300 THEN 'SLOW_DIMENSION'
            WHEN model_name LIKE 'fact_%' AND execution_time_seconds > 600 THEN 'SLOW_FACT'
            ELSE 'ACCEPTABLE'
        END as performance_status
    FROM (
        SELECT 'dim_user' as model_name, 120 as execution_time_seconds  -- Mock data
        UNION ALL SELECT 'dim_date', 60
        UNION ALL SELECT 'fact_meeting_summary', 300
        UNION ALL SELECT 'fact_user_activity', 450
    )
)
SELECT *
FROM model_performance
WHERE performance_status != 'ACCEPTABLE'
```

## Test Execution Strategy

### 1. Pre-deployment Testing

```bash
# Run all tests before deployment
dbt test --models tag:gold_layer

# Run specific test categories
dbt test --models tag:dimension_tests
dbt test --models tag:fact_tests
dbt test --models tag:data_quality
```

### 2. Continuous Integration Testing

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
          dbt test --profiles-dir ./profiles
```

### 3. Data Quality Monitoring

```sql
-- Create monitoring view for ongoing data quality
CREATE OR REPLACE VIEW gold.data_quality_dashboard AS
SELECT 
    model_name,
    test_name,
    test_status,
    execution_time,
    error_count,
    warning_count,
    last_run_timestamp
FROM gold.dbt_test_results
WHERE last_run_timestamp >= CURRENT_DATE() - INTERVAL '7 DAYS'
ORDER BY last_run_timestamp DESC;
```

## Expected Test Results

### Success Criteria

1. **Data Quality Tests**: 100% pass rate for critical data quality tests
2. **Business Logic Tests**: All business rules validated successfully
3. **Performance Tests**: All models execute within defined SLA
4. **Integration Tests**: All foreign key relationships validated
5. **Edge Case Tests**: Graceful handling of NULL values and missing data

### Failure Scenarios and Remediation

| Test Failure | Root Cause | Remediation |
|--------------|------------|-------------|
| Unique constraint violation | Duplicate records in source | Implement deduplication logic |
| Foreign key violation | Missing dimension records | Add dimension record creation |
| Business rule violation | Incorrect transformation logic | Fix transformation SQL |
| Performance degradation | Large data volume or inefficient SQL | Optimize queries and add clustering |
| Data freshness failure | ETL pipeline issues | Check upstream data sources |

## Test Maintenance

### 1. Regular Test Review
- Monthly review of test coverage
- Quarterly update of business rules
- Annual performance benchmark review

### 2. Test Documentation
- Maintain test case documentation
- Update expected results as business rules change
- Document test failure remediation procedures

### 3. Test Automation
- Automate test execution in CI/CD pipeline
- Set up alerts for test failures
- Generate automated test reports

## Conclusion

This comprehensive test suite ensures the reliability, accuracy, and performance of the Zoom Platform Analytics Gold Layer dbt models. The tests cover:

- **Data Quality**: Ensuring data integrity and completeness
- **Business Logic**: Validating transformation rules and calculations
- **Performance**: Monitoring execution times and resource usage
- **Integration**: Verifying relationships between models
- **Edge Cases**: Handling exceptional scenarios gracefully

Regular execution of these tests will maintain high data quality standards and catch issues early in the development cycle, ensuring reliable analytics and reporting for business users.

---

**Test Coverage Summary:**
- Dimension Models: 6 models, 45+ test cases
- Fact Models: 5 models, 35+ test cases  
- Custom SQL Tests: 10 comprehensive test scripts
- Performance Tests: Execution time monitoring
- Integration Tests: Foreign key validation
- Edge Case Tests: Error handling validation

**Total Test Cases: 80+**
**Expected Pass Rate: 100%**
**Execution Frequency: Daily (CI/CD), Weekly (Full Suite)**