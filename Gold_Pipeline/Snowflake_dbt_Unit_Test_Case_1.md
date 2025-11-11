_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Gold Layer dbt models in Snowflake
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Zoom Gold Analytics Pipeline

## Overview

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Gold Analytics pipeline that transforms Silver layer data into Gold layer dimension and fact tables in Snowflake. The tests ensure data quality, transformation accuracy, and business rule compliance across all models.

## Test Strategy

The testing approach covers:
- **Data Quality Tests**: Ensuring data integrity and completeness
- **Business Logic Tests**: Validating transformation rules and calculations
- **Referential Integrity Tests**: Checking foreign key relationships
- **Edge Case Tests**: Handling null values, empty datasets, and boundary conditions
- **Performance Tests**: Ensuring models execute within acceptable timeframes

## Test Case Categories

### 1. Dimension Table Tests

#### 1.1 Date Dimension Tests (`go_dim_date`)

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| DIM_DATE_001 | Verify date range coverage from start_date to end_date | All dates between 2020-01-01 and 2030-12-31 are present | Data Completeness |
| DIM_DATE_002 | Validate unique date keys | No duplicate DATE_KEY values | Data Uniqueness |
| DIM_DATE_003 | Check fiscal year calculation accuracy | Fiscal year correctly calculated (April start) | Business Logic |
| DIM_DATE_004 | Verify weekend flag accuracy | Saturday and Sunday marked as IS_WEEKEND = TRUE | Business Logic |
| DIM_DATE_005 | Validate date attribute consistency | All date attributes match the date value | Data Consistency |

#### 1.2 User Dimension Tests (`go_dim_user`)

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| DIM_USER_001 | Verify user key uniqueness | All USER_KEY values are unique | Data Uniqueness |
| DIM_USER_002 | Validate email domain extraction | Email domains correctly extracted from email addresses | Transformation Logic |
| DIM_USER_003 | Check plan type standardization | Plan types normalized to Basic/Pro/Enterprise/Unknown | Data Standardization |
| DIM_USER_004 | Verify user status mapping | Users with VALIDATION_STATUS='PASSED' marked as Active | Business Logic |
| DIM_USER_005 | Test null handling for user names | Null user names replaced with 'Unknown' | Edge Case Handling |
| DIM_USER_006 | Validate SCD Type 2 implementation | IS_CURRENT_RECORD flag properly maintained | SCD Logic |

#### 1.3 Feature Dimension Tests (`go_dim_feature`)

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| DIM_FEAT_001 | Verify feature categorization logic | Features correctly categorized by name patterns | Business Logic |
| DIM_FEAT_002 | Check premium feature identification | Recording and Breakout features marked as premium | Business Logic |
| DIM_FEAT_003 | Validate feature complexity scoring | Complexity levels assigned based on feature type | Business Logic |
| DIM_FEAT_004 | Test duplicate feature handling | Distinct features only, no duplicates | Data Uniqueness |
| DIM_FEAT_005 | Verify feature key generation | MD5 hash keys generated consistently | Technical Implementation |

#### 1.4 License Dimension Tests (`go_dim_license`)

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| DIM_LIC_001 | Validate license tier mapping | License tiers correctly assigned (Tier 1-3) | Business Logic |
| DIM_LIC_002 | Check pricing calculation accuracy | Monthly and annual prices correctly assigned | Business Logic |
| DIM_LIC_003 | Verify feature entitlements | Admin features only for Enterprise licenses | Business Logic |
| DIM_LIC_004 | Test participant limits | Max participants correctly set by license type | Business Logic |
| DIM_LIC_005 | Validate storage limits | Storage limits properly assigned by tier | Business Logic |

#### 1.5 Meeting Dimension Tests (`go_dim_meeting`)

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| DIM_MEET_001 | Verify duration categorization | Meetings categorized by duration ranges | Business Logic |
| DIM_MEET_002 | Check time of day classification | Meetings classified by start time | Business Logic |
| DIM_MEET_003 | Validate weekend detection | Weekend meetings properly flagged | Business Logic |
| DIM_MEET_004 | Test quality score calculation | Quality scores calculated based on data quality | Business Logic |
| DIM_MEET_005 | Verify meeting key uniqueness | All MEETING_KEY values are unique | Data Uniqueness |

#### 1.6 Support Category Dimension Tests (`go_dim_support_category`)

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| DIM_SUPP_001 | Validate priority level assignment | Priority levels correctly assigned by ticket type | Business Logic |
| DIM_SUPP_002 | Check SLA target calculation | SLA targets set based on priority levels | Business Logic |
| DIM_SUPP_003 | Verify escalation requirements | Critical tickets marked for escalation | Business Logic |
| DIM_SUPP_004 | Test department assignment | Tickets routed to correct departments | Business Logic |
| DIM_SUPP_005 | Validate resolution time estimates | Expected resolution times set appropriately | Business Logic |

### 2. Fact Table Tests

#### 2.1 Meeting Activity Fact Tests (`go_fact_meeting_activity`)

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| FACT_MEET_001 | Verify foreign key relationships | All foreign keys reference valid dimension records | Referential Integrity |
| FACT_MEET_002 | Check participant count accuracy | Participant counts match aggregated data | Data Accuracy |
| FACT_MEET_003 | Validate duration calculations | Meeting durations correctly calculated | Business Logic |
| FACT_MEET_004 | Test feature usage aggregation | Feature usage counts properly aggregated | Aggregation Logic |
| FACT_MEET_005 | Verify quality score calculation | Meeting quality scores calculated correctly | Business Logic |
| FACT_MEET_006 | Check null handling in metrics | Null values replaced with appropriate defaults | Edge Case Handling |
| FACT_MEET_007 | Validate date key assignment | Meeting dates correctly mapped to date dimension | Data Mapping |

#### 2.2 Support Activity Fact Tests (`go_fact_support_activity`)

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| FACT_SUPP_001 | Verify ticket resolution metrics | Resolution times calculated accurately | Business Logic |
| FACT_SUPP_002 | Check SLA compliance calculation | SLA_MET flag correctly determined | Business Logic |
| FACT_SUPP_003 | Validate satisfaction scoring | Customer satisfaction scores assigned properly | Business Logic |
| FACT_SUPP_004 | Test escalation count tracking | Escalation counts properly maintained | Data Tracking |
| FACT_SUPP_005 | Verify cost calculation | Resolution costs calculated correctly | Business Logic |
| FACT_SUPP_006 | Check foreign key integrity | All dimension references are valid | Referential Integrity |

#### 2.3 Revenue Activity Fact Tests (`go_fact_revenue_activity`)

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| FACT_REV_001 | Verify revenue amount accuracy | Revenue amounts correctly captured | Data Accuracy |
| FACT_REV_002 | Check MRR/ARR calculations | Monthly and annual recurring revenue calculated correctly | Business Logic |
| FACT_REV_003 | Validate tax calculations | Tax amounts calculated at 8% rate | Business Logic |
| FACT_REV_004 | Test refund handling | Refunds properly handled with negative amounts | Business Logic |
| FACT_REV_005 | Verify churn risk scoring | Churn risk scores calculated based on events | Business Logic |
| FACT_REV_006 | Check currency standardization | All amounts converted to USD | Data Standardization |

#### 2.4 Feature Usage Fact Tests (`go_fact_feature_usage`)

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| FACT_FEAT_001 | Verify usage count accuracy | Feature usage counts correctly captured | Data Accuracy |
| FACT_FEAT_002 | Check adoption score calculation | Feature adoption scores calculated correctly | Business Logic |
| FACT_FEAT_003 | Validate session duration mapping | Session durations properly assigned | Data Mapping |
| FACT_FEAT_004 | Test usage context classification | Usage contexts correctly categorized | Business Logic |
| FACT_FEAT_005 | Verify success rate calculation | Success rates calculated accurately | Business Logic |

### 3. Cross-Model Integration Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| INTEG_001 | Verify dimension-fact relationships | All fact records have valid dimension references | Integration |
| INTEG_002 | Check data consistency across models | Related data consistent across all models | Data Consistency |
| INTEG_003 | Validate audit trail completeness | All processes logged in audit table | Audit Compliance |
| INTEG_004 | Test end-to-end data flow | Data flows correctly from Silver to Gold | End-to-End |

## dbt Test Scripts

### Schema Tests (schema.yml)

```yaml
version: 2

models:
  # Date Dimension Tests
  - name: go_dim_date
    description: "Date dimension with comprehensive date attributes"
    tests:
      - dbt_expectations.expect_table_row_count_to_be_between:
          min_value: 4000
          max_value: 4020
    columns:
      - name: date_key
        description: "Primary date key"
        tests:
          - unique
          - not_null
      - name: year
        description: "Calendar year"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 2020
              max_value: 2030
      - name: is_weekend
        description: "Weekend flag"
        tests:
          - accepted_values:
              values: [true, false]
      - name: fiscal_quarter
        description: "Fiscal quarter"
        tests:
          - accepted_values:
              values: [1, 2, 3, 4]

  # User Dimension Tests
  - name: go_dim_user
    description: "User dimension with profile information"
    columns:
      - name: user_key
        description: "Surrogate key for user"
        tests:
          - unique
          - not_null
      - name: user_id
        description: "Original user identifier"
        tests:
          - not_null
      - name: plan_type
        description: "Standardized plan type"
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Enterprise', 'Unknown']
      - name: user_status
        description: "User status"
        tests:
          - accepted_values:
              values: ['Active', 'Inactive']
      - name: is_current_record
        description: "SCD Type 2 current record flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  # Feature Dimension Tests
  - name: go_dim_feature
    description: "Feature dimension with categorization"
    columns:
      - name: feature_key
        description: "Surrogate key for feature"
        tests:
          - unique
          - not_null
      - name: feature_category
        description: "Feature category"
        tests:
          - accepted_values:
              values: ['Collaboration', 'Recording', 'Communication', 'Advanced Meeting', 'Engagement', 'General']
      - name: is_premium_feature
        description: "Premium feature flag"
        tests:
          - accepted_values:
              values: [true, false]

  # License Dimension Tests
  - name: go_dim_license
    description: "License dimension with entitlements"
    columns:
      - name: license_key
        description: "Surrogate key for license"
        tests:
          - unique
          - not_null
      - name: license_tier
        description: "License tier"
        tests:
          - accepted_values:
              values: ['Tier 0', 'Tier 1', 'Tier 2', 'Tier 3']
      - name: monthly_price
        description: "Monthly subscription price"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1000

  # Meeting Dimension Tests
  - name: go_dim_meeting
    description: "Meeting dimension with characteristics"
    columns:
      - name: meeting_key
        description: "Surrogate key for meeting"
        tests:
          - unique
          - not_null
      - name: duration_category
        description: "Meeting duration category"
        tests:
          - accepted_values:
              values: ['Brief', 'Standard', 'Extended', 'Long']
      - name: time_of_day_category
        description: "Time of day category"
        tests:
          - accepted_values:
              values: ['Morning', 'Afternoon', 'Evening', 'Night']

  # Support Category Dimension Tests
  - name: go_dim_support_category
    description: "Support category dimension"
    columns:
      - name: support_category_key
        description: "Surrogate key for support category"
        tests:
          - unique
          - not_null
      - name: priority_level
        description: "Support priority level"
        tests:
          - accepted_values:
              values: ['Critical', 'High', 'Medium', 'Low']
      - name: expected_resolution_time_hours
        description: "Expected resolution time"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 168

  # Meeting Activity Fact Tests
  - name: go_fact_meeting_activity
    description: "Meeting activity fact table"
    tests:
      - dbt_expectations.expect_table_row_count_to_be_between:
          min_value: 1
    columns:
      - name: meeting_activity_id
        description: "Unique meeting activity identifier"
        tests:
          - unique
          - not_null
      - name: user_key
        description: "Foreign key to user dimension"
        tests:
          - relationships:
              to: ref('go_dim_user')
              field: user_key
      - name: date_key
        description: "Foreign key to date dimension"
        tests:
          - relationships:
              to: ref('go_dim_date')
              field: date_key
      - name: duration_minutes
        description: "Meeting duration in minutes"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440
      - name: participant_count
        description: "Number of participants"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10000
      - name: meeting_quality_score
        description: "Meeting quality score"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 1.0
              max_value: 5.0

  # Support Activity Fact Tests
  - name: go_fact_support_activity
    description: "Support activity fact table"
    columns:
      - name: support_activity_id
        description: "Unique support activity identifier"
        tests:
          - unique
          - not_null
      - name: user_key
        description: "Foreign key to user dimension"
        tests:
          - relationships:
              to: ref('go_dim_user')
              field: user_key
      - name: support_category_key
        description: "Foreign key to support category dimension"
        tests:
          - relationships:
              to: ref('go_dim_support_category')
              field: support_category_key
      - name: customer_satisfaction_score
        description: "Customer satisfaction score"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 1.0
              max_value: 5.0
      - name: sla_met
        description: "SLA compliance flag"
        tests:
          - accepted_values:
              values: [true, false]

  # Revenue Activity Fact Tests
  - name: go_fact_revenue_activity
    description: "Revenue activity fact table"
    columns:
      - name: revenue_activity_id
        description: "Unique revenue activity identifier"
        tests:
          - unique
          - not_null
      - name: user_key
        description: "Foreign key to user dimension"
        tests:
          - relationships:
              to: ref('go_dim_user')
              field: user_key
      - name: amount
        description: "Transaction amount"
        tests:
          - not_null
      - name: currency
        description: "Transaction currency"
        tests:
          - accepted_values:
              values: ['USD']
      - name: churn_risk_score
        description: "Churn risk score"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 1.0
              max_value: 5.0

  # Feature Usage Fact Tests
  - name: go_fact_feature_usage
    description: "Feature usage fact table"
    columns:
      - name: feature_usage_id
        description: "Unique feature usage identifier"
        tests:
          - unique
          - not_null
      - name: feature_key
        description: "Foreign key to feature dimension"
        tests:
          - relationships:
              to: ref('go_dim_feature')
              field: feature_key
      - name: usage_count
        description: "Feature usage count"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
      - name: feature_adoption_score
        description: "Feature adoption score"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 1.0
              max_value: 5.0
      - name: success_rate
        description: "Feature usage success rate"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.0
              max_value: 100.0
```

### Custom SQL Tests

#### Test 1: Date Dimension Completeness
```sql
-- tests/test_date_dimension_completeness.sql
SELECT 
    'Date gaps found' as test_result
FROM (
    SELECT 
        date_key,
        LAG(date_key) OVER (ORDER BY date_key) as prev_date,
        DATEDIFF('day', LAG(date_key) OVER (ORDER BY date_key), date_key) as day_diff
    FROM {{ ref('go_dim_date') }}
    ORDER BY date_key
) 
WHERE day_diff > 1
```

#### Test 2: User Dimension Email Domain Validation
```sql
-- tests/test_user_email_domain_validation.sql
SELECT 
    'Invalid email domains found' as test_result
FROM {{ ref('go_dim_user') }}
WHERE email_domain = 'Unknown' 
  AND user_name != 'Unknown'
  AND user_status = 'Active'
HAVING COUNT(*) > 0
```

#### Test 3: Meeting Activity Fact Data Consistency
```sql
-- tests/test_meeting_activity_consistency.sql
SELECT 
    'Meeting duration inconsistency found' as test_result
FROM {{ ref('go_fact_meeting_activity') }}
WHERE duration_minutes < 0 
   OR duration_minutes > 1440
   OR (start_time IS NOT NULL AND end_time IS NOT NULL 
       AND DATEDIFF('minute', start_time, end_time) != duration_minutes)
HAVING COUNT(*) > 0
```

#### Test 4: Revenue Fact Business Logic Validation
```sql
-- tests/test_revenue_business_logic.sql
SELECT 
    'Revenue calculation error found' as test_result
FROM {{ ref('go_fact_revenue_activity') }}
WHERE (event_type = 'Refund' AND net_revenue_amount >= 0)
   OR (event_type != 'Refund' AND net_revenue_amount < 0)
   OR (subscription_revenue_amount < 0)
   OR (tax_amount != amount * 0.08)
HAVING COUNT(*) > 0
```

#### Test 5: Foreign Key Integrity Across All Facts
```sql
-- tests/test_foreign_key_integrity.sql
WITH fk_violations AS (
    SELECT 'meeting_activity' as table_name, COUNT(*) as violation_count
    FROM {{ ref('go_fact_meeting_activity') }} f
    LEFT JOIN {{ ref('go_dim_user') }} d ON f.user_key = d.user_key
    WHERE f.user_key IS NOT NULL AND d.user_key IS NULL
    
    UNION ALL
    
    SELECT 'support_activity' as table_name, COUNT(*) as violation_count
    FROM {{ ref('go_fact_support_activity') }} f
    LEFT JOIN {{ ref('go_dim_user') }} d ON f.user_key = d.user_key
    WHERE f.user_key IS NOT NULL AND d.user_key IS NULL
    
    UNION ALL
    
    SELECT 'revenue_activity' as table_name, COUNT(*) as violation_count
    FROM {{ ref('go_fact_revenue_activity') }} f
    LEFT JOIN {{ ref('go_dim_user') }} d ON f.user_key = d.user_key
    WHERE f.user_key IS NOT NULL AND d.user_key IS NULL
    
    UNION ALL
    
    SELECT 'feature_usage' as table_name, COUNT(*) as violation_count
    FROM {{ ref('go_fact_feature_usage') }} f
    LEFT JOIN {{ ref('go_dim_feature') }} d ON f.feature_key = d.feature_key
    WHERE f.feature_key IS NOT NULL AND d.feature_key IS NULL
)
SELECT 
    'Foreign key violations found: ' || table_name as test_result
FROM fk_violations
WHERE violation_count > 0
```

### Macro Tests

#### Test 6: Audit Trail Validation
```sql
-- tests/test_audit_trail_completeness.sql
{% set models_to_check = ['go_dim_user', 'go_dim_feature', 'go_fact_meeting_activity', 'go_fact_support_activity'] %}

WITH audit_check AS (
    {% for model in models_to_check %}
    SELECT 
        '{{ model }}' as model_name,
        CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL' END as audit_status
    FROM {{ ref('go_process_audit') }}
    WHERE process_name = '{{ model }}'
      AND execution_status = 'SUCCESS'
      AND load_date = CURRENT_DATE()
    {% if not loop.last %}
    UNION ALL
    {% endif %}
    {% endfor %}
)
SELECT 
    'Audit trail missing for: ' || model_name as test_result
FROM audit_check
WHERE audit_status = 'FAIL'
```

## Test Execution Strategy

### 1. Pre-deployment Tests
- Run all schema tests to validate data types and constraints
- Execute custom SQL tests to verify business logic
- Perform foreign key integrity checks
- Validate audit trail completeness

### 2. Post-deployment Tests
- Data volume validation tests
- Performance benchmark tests
- End-to-end data flow validation
- Business user acceptance tests

### 3. Continuous Monitoring Tests
- Daily data quality checks
- Weekly business metric validation
- Monthly performance regression tests
- Quarterly comprehensive test suite execution

## Test Data Management

### Test Data Requirements
- **Minimum Records**: Each dimension should have at least 10 test records
- **Edge Cases**: Include null values, boundary conditions, and invalid data scenarios
- **Realistic Data**: Use production-like data patterns for meaningful tests
- **Data Refresh**: Test data should be refreshed weekly to maintain relevance

### Test Environment Setup
```sql
-- Create test schema
CREATE SCHEMA IF NOT EXISTS DB_POC_ZOOM.GOLD_TEST;

-- Grant permissions
GRANT USAGE ON SCHEMA DB_POC_ZOOM.GOLD_TEST TO ROLE FR__POC__ADMIN__ZOOM;
GRANT ALL ON ALL TABLES IN SCHEMA DB_POC_ZOOM.GOLD_TEST TO ROLE FR__POC__ADMIN__ZOOM;
```

## Performance Benchmarks

| Model | Expected Runtime | Max Acceptable Runtime | Row Count Expectation |
|-------|------------------|----------------------|----------------------|
| go_dim_date | < 30 seconds | 2 minutes | ~4,000 rows |
| go_dim_user | < 2 minutes | 5 minutes | Variable |
| go_dim_feature | < 1 minute | 3 minutes | < 100 rows |
| go_fact_meeting_activity | < 5 minutes | 15 minutes | Variable |
| go_fact_support_activity | < 3 minutes | 10 minutes | Variable |
| go_fact_revenue_activity | < 3 minutes | 10 minutes | Variable |
| go_fact_feature_usage | < 5 minutes | 15 minutes | Variable |

## Error Handling Test Cases

### Source Data Issues
- **Empty Source Tables**: Verify graceful handling when Silver tables are empty
- **Schema Changes**: Test behavior when source schema changes
- **Data Type Mismatches**: Validate error handling for unexpected data types
- **Constraint Violations**: Test response to primary key or foreign key violations

### Infrastructure Issues
- **Connection Failures**: Test behavior during Snowflake connection issues
- **Resource Constraints**: Validate handling of warehouse scaling issues
- **Permission Errors**: Test response to insufficient privileges

## Reporting and Alerting

### Test Results Dashboard
- Daily test execution summary
- Failed test details with root cause analysis
- Trend analysis of test performance
- Data quality score tracking

### Alert Configuration
- Immediate alerts for critical test failures
- Daily summary of test results
- Weekly data quality reports
- Monthly performance trend analysis

## Conclusion

This comprehensive test suite ensures the reliability, accuracy, and performance of the Zoom Gold Analytics pipeline. Regular execution of these tests will maintain high data quality standards and catch issues early in the development cycle, preventing production failures and ensuring consistent business intelligence reporting.

The test cases cover all critical aspects of the dbt models including data transformations, business rules, referential integrity, and edge cases. The combination of schema tests, custom SQL tests, and integration tests provides thorough coverage of the entire pipeline.

Regular review and updates of these test cases will ensure they remain relevant as the business requirements and data models evolve.