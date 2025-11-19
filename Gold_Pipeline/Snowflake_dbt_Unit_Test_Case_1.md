_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Snowflake dbt models in Zoom Platform Analytics Gold layer transformation
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Gold Layer Transformation

## Overview

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics System Gold layer transformation models. The tests validate data transformations, business rules, edge cases, and error handling to ensure reliable and high-quality data processing in Snowflake.

## Test Strategy

The testing framework covers:
- **Data Transformation Validation**: Verify correct mapping from Silver to Gold layer
- **Business Rule Implementation**: Ensure business logic is correctly applied
- **Data Quality Assurance**: Validate data integrity and consistency
- **Edge Case Handling**: Test boundary conditions and null value scenarios
- **Performance Validation**: Ensure models execute efficiently
- **Referential Integrity**: Validate foreign key relationships

## Test Case Categories

### 1. Dimension Table Tests

#### Test Case ID: DIM_USER_001
**Test Case Description**: Validate GO_DIM_USER transformation from SI_USERS
**Expected Outcome**: All user records are correctly transformed with proper standardization

**Test Data Setup**:
```sql
-- Test data for SI_USERS
INSERT INTO SILVER.SI_USERS VALUES
('USER001', 'john doe', 'john.doe@company.com', 'Tech Corp', 'PRO', '2024-01-01', '2024-01-01', 'ZOOM_API', '2024-01-01', '2024-01-01', 95, 'PASSED'),
('USER002', 'JANE SMITH', 'jane.smith@enterprise.org', 'Enterprise Ltd', 'ENTERPRISE', '2024-01-02', '2024-01-02', 'ZOOM_API', '2024-01-02', '2024-01-02', 88, 'PASSED'),
('USER003', 'bob johnson', 'bob@startup.io', 'Startup Inc', 'BASIC', '2024-01-03', '2024-01-03', 'ZOOM_API', '2024-01-03', '2024-01-03', 92, 'PASSED');
```

**Validation Queries**:
```sql
-- Test proper case standardization
SELECT COUNT(*) FROM {{ ref('go_dim_user') }} 
WHERE USER_NAME = 'John Doe' AND USER_ID = 'USER001';
-- Expected: 1

-- Test email domain extraction
SELECT COUNT(*) FROM {{ ref('go_dim_user') }} 
WHERE EMAIL_DOMAIN = 'COMPANY.COM' AND USER_ID = 'USER001';
-- Expected: 1

-- Test plan type standardization
SELECT COUNT(*) FROM {{ ref('go_dim_user') }} 
WHERE PLAN_TYPE = 'Pro' AND USER_ID = 'USER001';
-- Expected: 1

-- Test plan category derivation
SELECT COUNT(*) FROM {{ ref('go_dim_user') }} 
WHERE PLAN_CATEGORY = 'Paid' AND PLAN_TYPE IN ('Pro', 'Enterprise');
-- Expected: 2
```

#### Test Case ID: DIM_USER_002
**Test Case Description**: Validate null value handling in GO_DIM_USER
**Expected Outcome**: Null values are properly handled with appropriate defaults

**Test Data Setup**:
```sql
INSERT INTO SILVER.SI_USERS VALUES
('USER004', NULL, 'test@example.com', NULL, 'FREE', '2024-01-04', '2024-01-04', 'ZOOM_API', '2024-01-04', '2024-01-04', 75, 'PASSED');
```

**Validation Queries**:
```sql
-- Test null handling
SELECT COUNT(*) FROM {{ ref('go_dim_user') }} 
WHERE USER_ID = 'USER004' AND USER_NAME IS NOT NULL AND COMPANY IS NOT NULL;
-- Expected: 1
```

#### Test Case ID: DIM_DATE_001
**Test Case Description**: Validate GO_DIM_DATE generation and calculations
**Expected Outcome**: Date dimension contains correct calendar and fiscal year calculations

**Validation Queries**:
```sql
-- Test date range coverage
SELECT COUNT(*) FROM {{ ref('go_dim_date') }} 
WHERE DATE_VALUE BETWEEN '2020-01-01' AND '2030-12-31';
-- Expected: 4018 (11 years of dates)

-- Test fiscal year calculation (April 1st start)
SELECT COUNT(*) FROM {{ ref('go_dim_date') }} 
WHERE DATE_VALUE = '2024-04-01' AND FISCAL_YEAR = 2024 AND FISCAL_QUARTER = 1;
-- Expected: 1

-- Test weekend identification
SELECT COUNT(*) FROM {{ ref('go_dim_date') }} 
WHERE DATE_VALUE = '2024-01-06' AND IS_WEEKEND = TRUE; -- Saturday
-- Expected: 1

-- Test month name extraction
SELECT COUNT(*) FROM {{ ref('go_dim_date') }} 
WHERE DATE_VALUE = '2024-01-01' AND MONTH_NAME = 'January';
-- Expected: 1
```

#### Test Case ID: DIM_FEATURE_001
**Test Case Description**: Validate GO_DIM_FEATURE categorization logic
**Expected Outcome**: Features are correctly categorized based on naming patterns

**Test Data Setup**:
```sql
INSERT INTO SILVER.SI_FEATURE_USAGE VALUES
('USAGE001', 'MEET001', 'Screen Share', 5, '2024-01-01', '2024-01-01', '2024-01-01', 'ZOOM_API', '2024-01-01', '2024-01-01', 90, 'PASSED'),
('USAGE002', 'MEET002', 'Recording', 3, '2024-01-01', '2024-01-01', '2024-01-01', 'ZOOM_API', '2024-01-01', '2024-01-01', 85, 'PASSED'),
('USAGE003', 'MEET003', 'Chat', 10, '2024-01-01', '2024-01-01', '2024-01-01', 'ZOOM_API', '2024-01-01', '2024-01-01', 95, 'PASSED');
```

**Validation Queries**:
```sql
-- Test feature categorization
SELECT COUNT(*) FROM {{ ref('go_dim_feature') }} 
WHERE FEATURE_NAME = 'Screen Share' AND FEATURE_CATEGORY = 'Collaboration';
-- Expected: 1

SELECT COUNT(*) FROM {{ ref('go_dim_feature') }} 
WHERE FEATURE_NAME = 'Recording' AND FEATURE_CATEGORY = 'Recording' AND IS_PREMIUM_FEATURE = TRUE;
-- Expected: 1

SELECT COUNT(*) FROM {{ ref('go_dim_feature') }} 
WHERE FEATURE_NAME = 'Chat' AND FEATURE_CATEGORY = 'Communication';
-- Expected: 1
```

#### Test Case ID: DIM_LICENSE_001
**Test Case Description**: Validate GO_DIM_LICENSE pricing and entitlement logic
**Expected Outcome**: License attributes are correctly derived based on license type

**Test Data Setup**:
```sql
INSERT INTO SILVER.SI_LICENSES VALUES
('LIC001', 'Basic', 'USER001', '2024-01-01', '2024-12-31', '2024-01-01', '2024-01-01', 'ZOOM_API', '2024-01-01', '2024-01-01', 90, 'PASSED'),
('LIC002', 'Pro', 'USER002', '2024-01-01', '2024-12-31', '2024-01-01', '2024-01-01', 'ZOOM_API', '2024-01-01', '2024-01-01', 95, 'PASSED'),
('LIC003', 'Enterprise', 'USER003', '2024-01-01', '2024-12-31', '2024-01-01', '2024-01-01', 'ZOOM_API', '2024-01-01', '2024-01-01', 98, 'PASSED');
```

**Validation Queries**:
```sql
-- Test license tier assignment
SELECT COUNT(*) FROM {{ ref('go_dim_license') }} 
WHERE LICENSE_TYPE = 'Basic' AND LICENSE_TIER = 'Tier 1' AND MAX_PARTICIPANTS = 100;
-- Expected: 1

-- Test enterprise features
SELECT COUNT(*) FROM {{ ref('go_dim_license') }} 
WHERE LICENSE_TYPE = 'Enterprise' AND ADMIN_FEATURES_INCLUDED = TRUE AND SSO_SUPPORT_INCLUDED = TRUE;
-- Expected: 1

-- Test API access entitlement
SELECT COUNT(*) FROM {{ ref('go_dim_license') }} 
WHERE LICENSE_TYPE IN ('Pro', 'Enterprise') AND API_ACCESS_INCLUDED = TRUE;
-- Expected: 2
```

### 2. Fact Table Tests

#### Test Case ID: FACT_MEETING_001
**Test Case Description**: Validate GO_FACT_MEETING_ACTIVITY aggregations and calculations
**Expected Outcome**: Meeting metrics are correctly calculated with proper dimensional relationships

**Test Data Setup**:
```sql
-- Setup meetings
INSERT INTO SILVER.SI_MEETINGS VALUES
('MEET001', 'USER001', 'Team Standup', '2024-01-01 09:00:00', '2024-01-01 09:30:00', 30, '2024-01-01', '2024-01-01', 'ZOOM_API', '2024-01-01', '2024-01-01', 95, 'PASSED'),
('MEET002', 'USER002', 'Client Demo', '2024-01-01 14:00:00', '2024-01-01 15:30:00', 90, '2024-01-01', '2024-01-01', 'ZOOM_API', '2024-01-01', '2024-01-01', 88, 'PASSED');

-- Setup participants
INSERT INTO SILVER.SI_PARTICIPANTS VALUES
('PART001', 'MEET001', 'USER001', '2024-01-01 09:00:00', '2024-01-01 09:30:00', '2024-01-01', '2024-01-01', 'ZOOM_API', '2024-01-01', '2024-01-01', 90, 'PASSED'),
('PART002', 'MEET001', 'USER002', '2024-01-01 09:05:00', '2024-01-01 09:25:00', '2024-01-01', '2024-01-01', 'ZOOM_API', '2024-01-01', '2024-01-01', 85, 'PASSED');
```

**Validation Queries**:
```sql
-- Test participant count calculation
SELECT COUNT(*) FROM {{ ref('go_fact_meeting_activity') }} 
WHERE MEETING_ID = 'MEET001' AND PARTICIPANT_COUNT = 2;
-- Expected: 1

-- Test duration calculation
SELECT COUNT(*) FROM {{ ref('go_fact_meeting_activity') }} 
WHERE MEETING_ID = 'MEET001' AND ACTUAL_DURATION_MINUTES = 30;
-- Expected: 1

-- Test time of day categorization
SELECT COUNT(*) FROM {{ ref('go_fact_meeting_activity') }} 
WHERE MEETING_ID = 'MEET001' AND TIME_OF_DAY_CATEGORY = 'Morning';
-- Expected: 1

-- Test quality score calculation
SELECT COUNT(*) FROM {{ ref('go_fact_meeting_activity') }} 
WHERE MEETING_QUALITY_SCORE BETWEEN 1.0 AND 5.0;
-- Expected: 2
```

#### Test Case ID: FACT_FEATURE_USAGE_001
**Test Case Description**: Validate GO_FACT_FEATURE_USAGE adoption scoring
**Expected Outcome**: Feature adoption scores are correctly calculated based on usage patterns

**Validation Queries**:
```sql
-- Test adoption score calculation
SELECT COUNT(*) FROM {{ ref('go_fact_feature_usage') }} 
WHERE USAGE_COUNT >= 10 AND FEATURE_ADOPTION_SCORE = 5.0;
-- Expected: >= 1

-- Test success rate calculation
SELECT COUNT(*) FROM {{ ref('go_fact_feature_usage') }} 
WHERE USAGE_COUNT > 0 AND SUCCESS_RATE = 100.0;
-- Expected: >= 1

-- Test performance score validation
SELECT COUNT(*) FROM {{ ref('go_fact_feature_usage') }} 
WHERE FEATURE_PERFORMANCE_SCORE BETWEEN 1.0 AND 5.0;
-- Expected: All records
```

#### Test Case ID: FACT_REVENUE_001
**Test Case Description**: Validate GO_FACT_REVENUE_EVENTS financial calculations
**Expected Outcome**: Revenue metrics and MRR/ARR calculations are accurate

**Test Data Setup**:
```sql
INSERT INTO SILVER.SI_BILLING_EVENTS VALUES
('BILL001', 'USER001', 'Subscription', 239.88, '2024-01-01', '2024-01-01', '2024-01-01', 'ZOOM_API', '2024-01-01', '2024-01-01', 95, 'PASSED'),
('BILL002', 'USER002', 'Upgrade', 479.88, '2024-01-01', '2024-01-01', '2024-01-01', 'ZOOM_API', '2024-01-01', '2024-01-01', 90, 'PASSED'),
('BILL003', 'USER003', 'Refund', -119.94, '2024-01-01', '2024-01-01', '2024-01-01', 'ZOOM_API', '2024-01-01', '2024-01-01', 85, 'PASSED');
```

**Validation Queries**:
```sql
-- Test MRR calculation
SELECT COUNT(*) FROM {{ ref('go_fact_revenue_events') }} 
WHERE EVENT_TYPE = 'Subscription' AND MRR_IMPACT = GROSS_AMOUNT / 12;
-- Expected: 1

-- Test negative revenue handling
SELECT COUNT(*) FROM {{ ref('go_fact_revenue_events') }} 
WHERE EVENT_TYPE = 'Refund' AND NET_AMOUNT < 0;
-- Expected: 1

-- Test churn risk scoring
SELECT COUNT(*) FROM {{ ref('go_fact_revenue_events') }} 
WHERE EVENT_TYPE = 'Refund' AND CHURN_RISK_SCORE >= 3.0;
-- Expected: 1
```

### 3. Data Quality Tests

#### Test Case ID: DQ_001
**Test Case Description**: Validate data completeness across all models
**Expected Outcome**: No critical fields contain null values where business rules require data

**Validation Queries**:
```sql
-- Test user dimension completeness
SELECT COUNT(*) FROM {{ ref('go_dim_user') }} 
WHERE USER_ID IS NULL OR USER_NAME IS NULL;
-- Expected: 0

-- Test date dimension completeness
SELECT COUNT(*) FROM {{ ref('go_dim_date') }} 
WHERE DATE_VALUE IS NULL OR YEAR IS NULL;
-- Expected: 0

-- Test fact table foreign key completeness
SELECT COUNT(*) FROM {{ ref('go_fact_meeting_activity') }} 
WHERE DATE_ID IS NULL OR HOST_USER_DIM_ID IS NULL;
-- Expected: 0
```

#### Test Case ID: DQ_002
**Test Case Description**: Validate referential integrity between fact and dimension tables
**Expected Outcome**: All foreign keys in fact tables have corresponding records in dimension tables

**Validation Queries**:
```sql
-- Test user foreign key integrity
SELECT COUNT(*) FROM {{ ref('go_fact_meeting_activity') }} fma
LEFT JOIN {{ ref('go_dim_user') }} du ON fma.HOST_USER_DIM_ID = du.USER_DIM_ID
WHERE du.USER_DIM_ID IS NULL;
-- Expected: 0

-- Test date foreign key integrity
SELECT COUNT(*) FROM {{ ref('go_fact_meeting_activity') }} fma
LEFT JOIN {{ ref('go_dim_date') }} dd ON fma.DATE_ID = dd.DATE_ID
WHERE dd.DATE_ID IS NULL;
-- Expected: 0
```

### 4. Edge Case Tests

#### Test Case ID: EDGE_001
**Test Case Description**: Validate handling of extreme values and boundary conditions
**Expected Outcome**: Models handle edge cases gracefully without errors

**Test Data Setup**:
```sql
-- Test very long meeting duration
INSERT INTO SILVER.SI_MEETINGS VALUES
('MEET999', 'USER001', 'All Day Workshop', '2024-01-01 08:00:00', '2024-01-01 18:00:00', 600, '2024-01-01', '2024-01-01', 'ZOOM_API', '2024-01-01', '2024-01-01', 95, 'PASSED');

-- Test zero usage count
INSERT INTO SILVER.SI_FEATURE_USAGE VALUES
('USAGE999', 'MEET999', 'Whiteboard', 0, '2024-01-01', '2024-01-01', '2024-01-01', 'ZOOM_API', '2024-01-01', '2024-01-01', 70, 'PASSED');
```

**Validation Queries**:
```sql
-- Test long meeting handling
SELECT COUNT(*) FROM {{ ref('go_fact_meeting_activity') }} 
WHERE MEETING_ID = 'MEET999' AND ACTUAL_DURATION_MINUTES = 600;
-- Expected: 1

-- Test zero usage handling
SELECT COUNT(*) FROM {{ ref('go_fact_feature_usage') }} 
WHERE USAGE_COUNT = 0 AND FEATURE_ADOPTION_SCORE = 1.0;
-- Expected: 1
```

#### Test Case ID: EDGE_002
**Test Case Description**: Validate weekend and holiday date handling
**Expected Outcome**: Weekend and holiday flags are correctly set

**Validation Queries**:
```sql
-- Test weekend identification
SELECT COUNT(*) FROM {{ ref('go_dim_date') }} 
WHERE DAY_OF_WEEK IN (1, 7) AND IS_WEEKEND = TRUE;
-- Expected: All weekend days

-- Test weekday identification
SELECT COUNT(*) FROM {{ ref('go_dim_date') }} 
WHERE DAY_OF_WEEK BETWEEN 2 AND 6 AND IS_WEEKEND = FALSE;
-- Expected: All weekdays
```

### 5. Performance Tests

#### Test Case ID: PERF_001
**Test Case Description**: Validate model execution performance
**Expected Outcome**: Models execute within acceptable time limits

**Performance Validation**:
```sql
-- Test large dataset processing
SELECT 
    COUNT(*) as record_count,
    MAX(LOAD_DATE) as last_load_date
FROM {{ ref('go_fact_meeting_activity') }};
-- Expected: Completes within 60 seconds for 1M+ records

-- Test aggregation performance
SELECT 
    DATE_ID,
    COUNT(*) as daily_meetings,
    AVG(ACTUAL_DURATION_MINUTES) as avg_duration
FROM {{ ref('go_fact_meeting_activity') }}
GROUP BY DATE_ID
ORDER BY DATE_ID DESC
LIMIT 30;
-- Expected: Completes within 10 seconds
```

## dbt Test Scripts

### Schema Tests (schema.yml)

```yaml
version: 2

models:
  - name: go_dim_user
    description: "User dimension table with standardized user attributes"
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
          - unique
      - name: email_domain
        description: "Extracted email domain"
        tests:
          - not_null
      - name: plan_type
        description: "Standardized plan type"
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Enterprise', 'Unknown']
      - name: plan_category
        description: "High-level plan category"
        tests:
          - accepted_values:
              values: ['Free', 'Paid']
      - name: user_status
        description: "User status derived from validation"
        tests:
          - accepted_values:
              values: ['Active', 'Inactive']

  - name: go_dim_date
    description: "Date dimension with calendar and fiscal attributes"
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
          - unique
      - name: year
        description: "Calendar year"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 2020
              max_value: 2030
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

  - name: go_dim_feature
    description: "Feature dimension with categorization"
    columns:
      - name: feature_id
        description: "Surrogate key for feature dimension"
        tests:
          - unique
          - not_null
      - name: feature_name
        description: "Standardized feature name"
        tests:
          - not_null
          - unique
      - name: feature_category
        description: "Feature category classification"
        tests:
          - accepted_values:
              values: ['Collaboration', 'Recording', 'Communication', 'Advanced Meeting', 'Engagement', 'General']
      - name: is_premium_feature
        description: "Premium feature flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  - name: go_dim_license
    description: "License dimension with pricing and entitlements"
    columns:
      - name: license_id
        description: "Surrogate key for license dimension"
        tests:
          - unique
          - not_null
      - name: license_type
        description: "Standardized license type"
        tests:
          - not_null
      - name: monthly_price
        description: "Monthly subscription price"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 1000
      - name: max_participants
        description: "Maximum participants allowed"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 1
              max_value: 10000

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
      - name: actual_duration_minutes
        description: "Actual meeting duration in minutes"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 1440  # 24 hours
      - name: participant_count
        description: "Number of meeting participants"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 1
              max_value: 1000
      - name: meeting_quality_score
        description: "Meeting quality score"
        tests:
          - dbt_utils.accepted_range:
              min_value: 1.0
              max_value: 5.0

  - name: go_fact_feature_usage
    description: "Feature usage fact table"
    columns:
      - name: feature_usage_id
        description: "Surrogate key for feature usage"
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
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 10000
      - name: feature_adoption_score
        description: "Feature adoption score"
        tests:
          - dbt_utils.accepted_range:
              min_value: 1.0
              max_value: 5.0
      - name: success_rate
        description: "Feature usage success rate"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0.0
              max_value: 100.0

  - name: go_fact_revenue_events
    description: "Revenue events fact table"
    columns:
      - name: revenue_event_id
        description: "Surrogate key for revenue event"
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
      - name: user_dim_id
        description: "Foreign key to user dimension"
        tests:
          - not_null
          - relationships:
              to: ref('go_dim_user')
              field: user_dim_id
      - name: gross_amount
        description: "Gross transaction amount"
        tests:
          - not_null
      - name: net_amount
        description: "Net transaction amount"
        tests:
          - not_null
      - name: mrr_impact
        description: "Monthly recurring revenue impact"
        tests:
          - not_null
      - name: churn_risk_score
        description: "Customer churn risk score"
        tests:
          - dbt_utils.accepted_range:
              min_value: 1.0
              max_value: 5.0

  - name: go_fact_support_metrics
    description: "Support metrics fact table"
    columns:
      - name: support_metrics_id
        description: "Surrogate key for support metrics"
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
      - name: support_category_id
        description: "Foreign key to support category dimension"
        tests:
          - not_null
          - relationships:
              to: ref('go_dim_support_category')
              field: support_category_id
      - name: resolution_time_hours
        description: "Ticket resolution time in hours"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 8760  # 1 year in hours
      - name: sla_met
        description: "SLA compliance flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]
      - name: customer_satisfaction_score
        description: "Customer satisfaction score"
        tests:
          - dbt_utils.accepted_range:
              min_value: 1.0
              max_value: 5.0
```

### Custom SQL Tests

#### Test: Fiscal Year Calculation Accuracy
```sql
-- tests/assert_fiscal_year_calculation.sql
SELECT *
FROM {{ ref('go_dim_date') }}
WHERE (
    (MONTH(date_value) >= 4 AND fiscal_year != YEAR(date_value))
    OR 
    (MONTH(date_value) < 4 AND fiscal_year != YEAR(date_value) - 1)
)
```

#### Test: Meeting Duration Consistency
```sql
-- tests/assert_meeting_duration_consistency.sql
SELECT *
FROM {{ ref('go_fact_meeting_activity') }}
WHERE actual_duration_minutes != DATEDIFF('minute', meeting_start_time, meeting_end_time)
```

#### Test: Revenue Event Balance
```sql
-- tests/assert_revenue_balance.sql
SELECT *
FROM {{ ref('go_fact_revenue_events') }}
WHERE net_amount != (gross_amount - COALESCE(tax_amount, 0) - COALESCE(discount_amount, 0))
```

#### Test: Feature Adoption Score Logic
```sql
-- tests/assert_feature_adoption_score.sql
SELECT *
FROM {{ ref('go_fact_feature_usage') }}
WHERE (
    (usage_count >= 10 AND feature_adoption_score != 5.0)
    OR (usage_count >= 5 AND usage_count < 10 AND feature_adoption_score != 4.0)
    OR (usage_count >= 3 AND usage_count < 5 AND feature_adoption_score != 3.0)
    OR (usage_count >= 1 AND usage_count < 3 AND feature_adoption_score != 2.0)
    OR (usage_count = 0 AND feature_adoption_score != 1.0)
)
```

#### Test: SCD Type 2 Implementation
```sql
-- tests/assert_scd_type2_integrity.sql
SELECT user_id, COUNT(*) as active_records
FROM {{ ref('go_dim_user') }}
WHERE is_current_record = TRUE
GROUP BY user_id
HAVING COUNT(*) > 1
```

### Macro Tests

#### Test: Email Domain Extraction
```sql
-- macros/test_email_domain_extraction.sql
{% macro test_email_domain_extraction() %}
    SELECT 
        'john.doe@company.com' as email,
        {{ extract_email_domain('john.doe@company.com') }} as extracted_domain,
        'COMPANY.COM' as expected_domain
    WHERE {{ extract_email_domain('john.doe@company.com') }} != 'COMPANY.COM'
{% endmacro %}
```

#### Test: Plan Type Standardization
```sql
-- macros/test_plan_standardization.sql
{% macro test_plan_standardization() %}
    SELECT 
        plan_input,
        {{ standardize_plan_type('plan_input') }} as standardized,
        expected_output
    FROM (
        SELECT 'PRO' as plan_input, 'Pro' as expected_output
        UNION ALL
        SELECT 'ENTERPRISE' as plan_input, 'Enterprise' as expected_output
        UNION ALL
        SELECT 'basic' as plan_input, 'Basic' as expected_output
    )
    WHERE {{ standardize_plan_type('plan_input') }} != expected_output
{% endmacro %}
```

## Test Execution Strategy

### 1. Unit Test Execution
```bash
# Run all tests
dbt test

# Run tests for specific model
dbt test --select go_dim_user

# Run tests with specific tag
dbt test --select tag:data_quality

# Run tests excluding performance tests
dbt test --exclude tag:performance
```

### 2. Test Data Management
```sql
-- Setup test data
dbt seed

-- Run models with test data
dbt run --target test

-- Execute tests against test data
dbt test --target test
```

### 3. Continuous Integration
```yaml
# .github/workflows/dbt_test.yml
name: dbt Test Suite
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
          dbt seed --target ci
          dbt run --target ci
          dbt test --target ci
```

## Test Results Tracking

### 1. Test Results Schema
```sql
CREATE TABLE IF NOT EXISTS GOLD.GO_TEST_RESULTS (
    test_execution_id VARCHAR(50),
    test_name VARCHAR(200),
    test_type VARCHAR(50),
    model_name VARCHAR(200),
    test_status VARCHAR(20),
    execution_time_seconds NUMBER(10,2),
    error_message VARCHAR(1000),
    records_tested NUMBER(20,0),
    records_failed NUMBER(20,0),
    execution_timestamp TIMESTAMP_NTZ(9),
    dbt_version VARCHAR(50),
    git_commit_hash VARCHAR(50)
);
```

### 2. Test Coverage Metrics
```sql
-- Calculate test coverage by model
SELECT 
    model_name,
    COUNT(*) as total_tests,
    SUM(CASE WHEN test_status = 'PASS' THEN 1 ELSE 0 END) as passed_tests,
    (passed_tests * 100.0 / total_tests) as pass_rate
FROM GOLD.GO_TEST_RESULTS
WHERE execution_timestamp >= CURRENT_DATE() - 7
GROUP BY model_name
ORDER BY pass_rate DESC;
```

## Conclusion

This comprehensive test suite ensures the reliability and quality of the Zoom Platform Analytics Gold layer transformation. The tests cover:

- **Data Transformation Accuracy**: Validates correct mapping and calculations
- **Business Rule Implementation**: Ensures business logic is properly applied
- **Data Quality Assurance**: Maintains high data quality standards
- **Edge Case Handling**: Handles boundary conditions gracefully
- **Performance Validation**: Ensures acceptable execution performance
- **Referential Integrity**: Maintains proper relationships between tables

Regular execution of these tests in CI/CD pipelines ensures continuous data quality and reliability in the Gold layer analytics platform.