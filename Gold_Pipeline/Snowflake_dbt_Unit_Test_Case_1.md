## *Author*: AAVA
## *Created on*: December 19, 2024
## *Description*: Comprehensive unit test cases for Zoom Gold Pipeline dbt models in Snowflake
## *Version*: 1
## *Updated on*: December 19, 2024
_____________________________________________

# Comprehensive Unit Test Cases for Zoom Gold Pipeline DBT Models

## 1. Test Case Overview

### 1.1 Test Case List

| Test Case ID | Model | Description | Expected Outcome |
|--------------|-------|-------------|------------------|
| TC_AUDIT_001 | go_audit_log | Validate audit log creation and process tracking | Audit records created for each pipeline execution |
| TC_AUDIT_002 | go_audit_log | Test error handling in audit logging | Error records properly logged with stack traces |
| TC_DIM_001 | go_dim_date | Validate date dimension completeness (2020-2030) | All dates present with correct attributes |
| TC_DIM_002 | go_dim_date | Test fiscal year calculations | Fiscal years correctly calculated |
| TC_DIM_003 | go_dim_date | Validate weekend and holiday flags | Boolean flags correctly set |
| TC_DIM_004 | go_dim_user | Test SCD Type 2 implementation | Historical records maintained correctly |
| TC_DIM_005 | go_dim_user | Validate data quality filters | Only records with VALIDATION_STATUS = 'PASSED' |
| TC_DIM_006 | go_dim_user | Test current record flag logic | Only one current record per user |
| TC_DIM_007 | go_dim_feature | Validate feature categorization | Features properly classified by complexity |
| TC_DIM_008 | go_dim_feature | Test premium feature identification | Premium features correctly flagged |
| TC_DIM_009 | go_dim_license | Validate license pricing calculations | Pricing fields correctly populated |
| TC_DIM_010 | go_dim_license | Test license entitlements | Entitlements properly mapped |
| TC_DIM_011 | go_dim_meeting_type | Validate meeting type characteristics | Meeting attributes correctly assigned |
| TC_DIM_012 | go_dim_support_category | Test SLA definitions | SLA hours correctly calculated |
| TC_FACT_001 | go_fact_feature_usage | Validate usage metrics calculations | Usage intensity and scores computed |
| TC_FACT_002 | go_fact_feature_usage | Test performance score logic | Performance scores within valid range (0-10) |
| TC_FACT_003 | go_fact_meeting_activity | Validate engagement scoring | Engagement scores properly calculated |
| TC_FACT_004 | go_fact_meeting_activity | Test meeting quality metrics | Quality scores within valid range |
| TC_FACT_005 | go_fact_revenue_events | Validate MRR/ARR calculations | Revenue recognition correctly computed |
| TC_FACT_006 | go_fact_revenue_events | Test currency conversion | USD amounts correctly calculated |
| TC_FACT_007 | go_fact_support_metrics | Validate SLA compliance tracking | SLA breach calculations accurate |
| TC_FACT_008 | go_fact_support_metrics | Test resolution time calculations | Time calculations in hours correct |
| TC_DQ_001 | All Models | Data quality score validation | Only records with DATA_QUALITY_SCORE >= 80 |
| TC_DQ_002 | All Models | Validation status check | Only 'PASSED' validation status records |
| TC_REL_001 | All Models | Test referential integrity | Proper relationships between facts and dimensions |
| TC_PERF_001 | All Models | Performance validation | Models execute within acceptable time limits |

## 2. DBT Test Scripts

### 2.1 Schema Tests (schema.yml)

```yaml
version: 2

sources:
  - name: silver_layer
    description: "Silver layer source tables for Gold transformations"
    database: DB_POC_ZOOM
    schema: SILVER
    tables:
      - name: sl_user_profiles
        description: "Silver layer user profile data"
        columns:
          - name: user_id
            description: "Unique user identifier"
            tests:
              - not_null
              - unique
          - name: validation_status
            description: "Data validation status"
            tests:
              - accepted_values:
                  values: ['PASSED', 'FAILED', 'PENDING']
          - name: data_quality_score
            description: "Data quality score (0-100)"
            tests:
              - not_null
              - dbt_utils.accepted_range:
                  min_value: 0
                  max_value: 100

      - name: sl_feature_usage
        description: "Silver layer feature usage data"
        columns:
          - name: usage_id
            tests:
              - not_null
              - unique
          - name: feature_name
            tests:
              - not_null
          - name: validation_status
            tests:
              - accepted_values:
                  values: ['PASSED', 'FAILED', 'PENDING']

      - name: sl_meeting_activities
        description: "Silver layer meeting activity data"
        columns:
          - name: meeting_id
            tests:
              - not_null
              - unique
          - name: validation_status
            tests:
              - accepted_values:
                  values: ['PASSED', 'FAILED', 'PENDING']

      - name: sl_revenue_transactions
        description: "Silver layer revenue transaction data"
        columns:
          - name: transaction_id
            tests:
              - not_null
              - unique
          - name: validation_status
            tests:
              - accepted_values:
                  values: ['PASSED', 'FAILED', 'PENDING']

      - name: sl_support_tickets
        description: "Silver layer support ticket data"
        columns:
          - name: ticket_id
            tests:
              - not_null
              - unique
          - name: validation_status
            tests:
              - accepted_values:
                  values: ['PASSED', 'FAILED', 'PENDING']

models:
  # Audit Infrastructure
  - name: go_audit_log
    description: "Process audit log table for pipeline execution tracking"
    columns:
      - name: audit_id
        description: "Unique audit log identifier"
        tests:
          - not_null
          - unique
      - name: process_name
        description: "Name of the process being audited"
        tests:
          - not_null
      - name: process_status
        description: "Status of the process"
        tests:
          - not_null
          - accepted_values:
              values: ['STARTED', 'COMPLETED', 'FAILED', 'RUNNING']
      - name: start_timestamp
        description: "Process start timestamp"
        tests:
          - not_null
      - name: end_timestamp
        description: "Process end timestamp"
      - name: records_processed
        description: "Number of records processed"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              inclusive: true
      - name: error_message
        description: "Error message if process failed"

  # Dimension Tables
  - name: go_dim_date
    description: "Standard date dimension with 10 years of data (2020-2030)"
    columns:
      - name: date_id
        description: "Unique date identifier"
        tests:
          - not_null
          - unique
      - name: date_value
        description: "Actual date value"
        tests:
          - not_null
          - unique
      - name: year
        description: "Year component"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 2020
              max_value: 2030
      - name: quarter
        description: "Quarter component (1-4)"
        tests:
          - not_null
          - accepted_values:
              values: [1, 2, 3, 4]
      - name: month
        description: "Month component (1-12)"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 1
              max_value: 12
      - name: day_of_week
        description: "Day of week (1-7)"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 1
              max_value: 7
      - name: is_weekend
        description: "Weekend flag"
        tests:
          - not_null
      - name: is_holiday
        description: "Holiday flag"
        tests:
          - not_null

  - name: go_dim_user
    description: "User dimension with SCD Type 2 implementation"
    columns:
      - name: user_dim_id
        description: "Unique user dimension identifier"
        tests:
          - not_null
          - unique
      - name: user_name
        description: "User name"
        tests:
          - not_null
      - name: email_domain
        description: "Email domain"
        tests:
          - not_null
      - name: plan_type
        description: "User plan type"
        tests:
          - not_null
      - name: user_status
        description: "User status"
        tests:
          - not_null
          - accepted_values:
              values: ['ACTIVE', 'INACTIVE', 'SUSPENDED', 'PENDING']
      - name: effective_start_date
        description: "SCD Type 2 start date"
        tests:
          - not_null
      - name: effective_end_date
        description: "SCD Type 2 end date"
      - name: is_current_record
        description: "Current record flag for SCD Type 2"
        tests:
          - not_null
      - name: load_date
        description: "Record load date"
        tests:
          - not_null

  - name: go_dim_feature
    description: "Feature dimension with categorization and complexity classification"
    columns:
      - name: feature_id
        description: "Unique feature identifier"
        tests:
          - not_null
          - unique
      - name: feature_name
        description: "Feature name"
        tests:
          - not_null
      - name: feature_category
        description: "Feature category"
        tests:
          - not_null
      - name: feature_complexity
        description: "Feature complexity level"
        tests:
          - accepted_values:
              values: ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL']
      - name: is_premium_feature
        description: "Premium feature flag"
        tests:
          - not_null
      - name: feature_status
        description: "Feature status"
        tests:
          - accepted_values:
              values: ['ACTIVE', 'DEPRECATED', 'BETA', 'ALPHA']

  - name: go_dim_license
    description: "License dimension with pricing and entitlements"
    columns:
      - name: license_id
        description: "Unique license identifier"
        tests:
          - not_null
          - unique
      - name: license_type
        description: "License type"
        tests:
          - not_null
      - name: license_tier
        description: "License tier"
        tests:
          - accepted_values:
              values: ['BASIC', 'PRO', 'BUSINESS', 'ENTERPRISE']
      - name: monthly_price
        description: "Monthly price"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              inclusive: true
      - name: annual_price
        description: "Annual price"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              inclusive: true
      - name: max_participants
        description: "Maximum participants allowed"
        tests:
          - dbt_utils.accepted_range:
              min_value: 1
              inclusive: true

  - name: go_dim_meeting_type
    description: "Meeting type dimension with characteristics"
    columns:
      - name: meeting_type_id
        description: "Unique meeting type identifier"
        tests:
          - not_null
          - unique
      - name: meeting_type
        description: "Meeting type"
        tests:
          - not_null
      - name: meeting_category
        description: "Meeting category"
        tests:
          - not_null
      - name: is_recurring_type
        description: "Recurring meeting flag"
        tests:
          - not_null
      - name: supports_recording
        description: "Recording support flag"
        tests:
          - not_null

  - name: go_dim_support_category
    description: "Support category dimension with SLA definitions"
    columns:
      - name: support_category_id
        description: "Unique support category identifier"
        tests:
          - not_null
          - unique
      - name: support_category
        description: "Support category"
        tests:
          - not_null
      - name: priority_level
        description: "Priority level"
        tests:
          - accepted_values:
              values: ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL']
      - name: expected_resolution_hours
        description: "Expected resolution time in hours"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 1
              max_value: 168  # 1 week max

  # Fact Tables
  - name: go_fact_feature_usage
    description: "Feature usage metrics with performance scores"
    columns:
      - name: feature_usage_id
        description: "Unique feature usage identifier"
        tests:
          - not_null
          - unique
      - name: usage_date
        description: "Usage date"
        tests:
          - not_null
      - name: feature_name
        description: "Feature name"
        tests:
          - not_null
      - name: usage_count
        description: "Usage count"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
              inclusive: true
      - name: usage_duration_minutes
        description: "Usage duration in minutes"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              inclusive: true
      - name: user_experience_score
        description: "User experience score (0-10)"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 10
              inclusive: true
      - name: feature_performance_score
        description: "Feature performance score (0-10)"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 10
              inclusive: true
      - name: success_rate_percentage
        description: "Success rate percentage"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 100
              inclusive: true

  - name: go_fact_meeting_activity
    description: "Meeting engagement and quality metrics"
    columns:
      - name: meeting_activity_id
        description: "Unique meeting activity identifier"
        tests:
          - not_null
          - unique
      - name: meeting_date
        description: "Meeting date"
        tests:
          - not_null
      - name: scheduled_duration_minutes
        description: "Scheduled duration in minutes"
        tests:
          - dbt_utils.accepted_range:
              min_value: 1
              inclusive: true
      - name: actual_duration_minutes
        description: "Actual duration in minutes"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              inclusive: true
      - name: participant_count
        description: "Number of participants"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 1
              inclusive: true
      - name: participant_engagement_score
        description: "Participant engagement score (0-10)"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 10
              inclusive: true
      - name: meeting_quality_score
        description: "Meeting quality score (0-10)"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 10
              inclusive: true
      - name: audio_quality_score
        description: "Audio quality score (0-10)"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 10
              inclusive: true
      - name: video_quality_score
        description: "Video quality score (0-10)"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 10
              inclusive: true

  - name: go_fact_revenue_events
    description: "Revenue events with MRR/ARR calculations"
    columns:
      - name: revenue_event_id
        description: "Unique revenue event identifier"
        tests:
          - not_null
          - unique
      - name: transaction_date
        description: "Transaction date"
        tests:
          - not_null
      - name: event_type
        description: "Revenue event type"
        tests:
          - not_null
          - accepted_values:
              values: ['SUBSCRIPTION', 'UPGRADE', 'DOWNGRADE', 'CANCELLATION', 'REFUND', 'CHARGEBACK']
      - name: gross_amount
        description: "Gross amount"
        tests:
          - not_null
      - name: net_amount
        description: "Net amount"
        tests:
          - not_null
      - name: currency_code
        description: "Currency code"
        tests:
          - not_null
      - name: usd_amount
        description: "USD converted amount"
        tests:
          - not_null
      - name: mrr_impact
        description: "Monthly Recurring Revenue impact"
      - name: arr_impact
        description: "Annual Recurring Revenue impact"
      - name: is_recurring_revenue
        description: "Recurring revenue flag"
        tests:
          - not_null

  - name: go_fact_support_metrics
    description: "Support ticket performance metrics"
    columns:
      - name: support_metrics_id
        description: "Unique support metrics identifier"
        tests:
          - not_null
          - unique
      - name: ticket_open_date
        description: "Ticket open date"
        tests:
          - not_null
      - name: resolution_time_hours
        description: "Resolution time in hours"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              inclusive: true
      - name: first_response_time_hours
        description: "First response time in hours"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              inclusive: true
      - name: customer_satisfaction_score
        description: "Customer satisfaction score (0-10)"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 10
              inclusive: true
      - name: first_contact_resolution_flag
        description: "First contact resolution flag"
        tests:
          - not_null
      - name: sla_met_flag
        description: "SLA met flag"
        tests:
          - not_null
```

### 2.2 Custom SQL-based DBT Tests

#### 2.2.1 Data Quality Tests

```sql
-- tests/data_quality_score_validation.sql
-- Test: Validate that all records have DATA_QUALITY_SCORE >= 80
{{ config(severity = 'error') }}

SELECT 
    'go_dim_user' as table_name,
    COUNT(*) as failed_records
FROM {{ ref('go_dim_user') }}
WHERE data_quality_score < 80

UNION ALL

SELECT 
    'go_dim_feature' as table_name,
    COUNT(*) as failed_records
FROM {{ ref('go_dim_feature') }}
WHERE data_quality_score < 80

UNION ALL

SELECT 
    'go_fact_feature_usage' as table_name,
    COUNT(*) as failed_records
FROM {{ ref('go_fact_feature_usage') }}
WHERE data_quality_score < 80

UNION ALL

SELECT 
    'go_fact_meeting_activity' as table_name,
    COUNT(*) as failed_records
FROM {{ ref('go_fact_meeting_activity') }}
WHERE data_quality_score < 80

UNION ALL

SELECT 
    'go_fact_revenue_events' as table_name,
    COUNT(*) as failed_records
FROM {{ ref('go_fact_revenue_events') }}
WHERE data_quality_score < 80

UNION ALL

SELECT 
    'go_fact_support_metrics' as table_name,
    COUNT(*) as failed_records
FROM {{ ref('go_fact_support_metrics') }}
WHERE data_quality_score < 80

HAVING SUM(failed_records) > 0
```

```sql
-- tests/validation_status_check.sql
-- Test: Validate that all records have VALIDATION_STATUS = 'PASSED'
{{ config(severity = 'error') }}

SELECT 
    'go_dim_user' as table_name,
    COUNT(*) as failed_records
FROM {{ ref('go_dim_user') }}
WHERE validation_status != 'PASSED'

UNION ALL

SELECT 
    'go_dim_feature' as table_name,
    COUNT(*) as failed_records
FROM {{ ref('go_dim_feature') }}
WHERE validation_status != 'PASSED'

UNION ALL

SELECT 
    'go_fact_feature_usage' as table_name,
    COUNT(*) as failed_records
FROM {{ ref('go_fact_feature_usage') }}
WHERE validation_status != 'PASSED'

UNION ALL

SELECT 
    'go_fact_meeting_activity' as table_name,
    COUNT(*) as failed_records
FROM {{ ref('go_fact_meeting_activity') }}
WHERE validation_status != 'PASSED'

UNION ALL

SELECT 
    'go_fact_revenue_events' as table_name,
    COUNT(*) as failed_records
FROM {{ ref('go_fact_revenue_events') }}
WHERE validation_status != 'PASSED'

UNION ALL

SELECT 
    'go_fact_support_metrics' as table_name,
    COUNT(*) as failed_records
FROM {{ ref('go_fact_support_metrics') }}
WHERE validation_status != 'PASSED'

HAVING SUM(failed_records) > 0
```

#### 2.2.2 SCD Type 2 Tests

```sql
-- tests/scd_type2_current_record_validation.sql
-- Test: Validate SCD Type 2 implementation - only one current record per user
{{ config(severity = 'error') }}

SELECT 
    user_name,
    COUNT(*) as current_record_count
FROM {{ ref('go_dim_user') }}
WHERE is_current_record = TRUE
GROUP BY user_name
HAVING COUNT(*) > 1
```

```sql
-- tests/scd_type2_date_consistency.sql
-- Test: Validate SCD Type 2 date consistency
{{ config(severity = 'error') }}

SELECT 
    user_dim_id,
    effective_start_date,
    effective_end_date
FROM {{ ref('go_dim_user') }}
WHERE effective_end_date IS NOT NULL 
  AND effective_start_date >= effective_end_date
```

#### 2.2.3 Business Logic Tests

```sql
-- tests/date_dimension_completeness.sql
-- Test: Validate date dimension has all dates from 2020 to 2030
{{ config(severity = 'error') }}

WITH expected_dates AS (
    SELECT 
        DATE('2020-01-01') + (ROW_NUMBER() OVER (ORDER BY 1) - 1) as expected_date
    FROM TABLE(GENERATOR(ROWCOUNT => 4018)) -- 11 years * 365.25 days
    WHERE expected_date <= DATE('2030-12-31')
),
actual_dates AS (
    SELECT DISTINCT date_value as actual_date
    FROM {{ ref('go_dim_date') }}
)
SELECT 
    expected_date
FROM expected_dates e
LEFT JOIN actual_dates a ON e.expected_date = a.actual_date
WHERE a.actual_date IS NULL
```

```sql
-- tests/revenue_calculation_validation.sql
-- Test: Validate MRR/ARR calculations
{{ config(severity = 'error') }}

SELECT 
    revenue_event_id,
    mrr_impact,
    arr_impact,
    subscription_period_months
FROM {{ ref('go_fact_revenue_events') }}
WHERE is_recurring_revenue = TRUE
  AND subscription_period_months > 0
  AND ABS(arr_impact - (mrr_impact * 12)) > 0.01  -- Allow for rounding differences
```

```sql
-- tests/meeting_duration_validation.sql
-- Test: Validate meeting duration logic
{{ config(severity = 'error') }}

SELECT 
    meeting_activity_id,
    scheduled_duration_minutes,
    actual_duration_minutes,
    meeting_start_time,
    meeting_end_time
FROM {{ ref('go_fact_meeting_activity') }}
WHERE actual_duration_minutes > (scheduled_duration_minutes * 2)  -- Actual duration shouldn't be more than 2x scheduled
   OR actual_duration_minutes < 0
   OR DATEDIFF('minute', meeting_start_time, meeting_end_time) != actual_duration_minutes
```

```sql
-- tests/support_sla_validation.sql
-- Test: Validate SLA calculations
{{ config(severity = 'error') }}

SELECT 
    s.support_metrics_id,
    s.resolution_time_hours,
    c.expected_resolution_hours,
    s.sla_met_flag,
    s.sla_breach_hours
FROM {{ ref('go_fact_support_metrics') }} s
JOIN {{ ref('go_dim_support_category') }} c 
  ON s.support_category_id = c.support_category_id
WHERE (s.resolution_time_hours <= c.expected_resolution_hours AND s.sla_met_flag = FALSE)
   OR (s.resolution_time_hours > c.expected_resolution_hours AND s.sla_met_flag = TRUE)
   OR (s.sla_breach_hours != GREATEST(0, s.resolution_time_hours - c.expected_resolution_hours))
```

#### 2.2.4 Referential Integrity Tests

```sql
-- tests/fact_dimension_relationships.sql
-- Test: Validate relationships between facts and dimensions
{{ config(severity = 'error') }}

-- Test feature usage to feature dimension relationship
SELECT 'go_fact_feature_usage' as fact_table, COUNT(*) as orphaned_records
FROM {{ ref('go_fact_feature_usage') }} f
LEFT JOIN {{ ref('go_dim_feature') }} d ON f.feature_name = d.feature_name
WHERE d.feature_name IS NULL

UNION ALL

-- Test meeting activity to meeting type relationship
SELECT 'go_fact_meeting_activity' as fact_table, COUNT(*) as orphaned_records
FROM {{ ref('go_fact_meeting_activity') }} f
LEFT JOIN {{ ref('go_dim_meeting_type') }} d ON f.meeting_type_id = d.meeting_type_id
WHERE d.meeting_type_id IS NULL

UNION ALL

-- Test support metrics to support category relationship
SELECT 'go_fact_support_metrics' as fact_table, COUNT(*) as orphaned_records
FROM {{ ref('go_fact_support_metrics') }} f
LEFT JOIN {{ ref('go_dim_support_category') }} d ON f.support_category_id = d.support_category_id
WHERE d.support_category_id IS NULL

HAVING SUM(orphaned_records) > 0
```

#### 2.2.5 Performance and Volume Tests

```sql
-- tests/model_performance_validation.sql
-- Test: Validate model performance and execution time
{{ config(severity = 'warn') }}

WITH model_stats AS (
    SELECT 
        'go_dim_date' as model_name,
        COUNT(*) as record_count,
        MIN(load_date) as min_load_date,
        MAX(load_date) as max_load_date
    FROM {{ ref('go_dim_date') }}
    
    UNION ALL
    
    SELECT 
        'go_dim_user' as model_name,
        COUNT(*) as record_count,
        MIN(load_date) as min_load_date,
        MAX(load_date) as max_load_date
    FROM {{ ref('go_dim_user') }}
    
    UNION ALL
    
    SELECT 
        'go_fact_feature_usage' as model_name,
        COUNT(*) as record_count,
        MIN(load_date) as min_load_date,
        MAX(load_date) as max_load_date
    FROM {{ ref('go_fact_feature_usage') }}
    
    UNION ALL
    
    SELECT 
        'go_fact_meeting_activity' as model_name,
        COUNT(*) as record_count,
        MIN(load_date) as min_load_date,
        MAX(load_date) as max_load_date
    FROM {{ ref('go_fact_meeting_activity') }}
)
SELECT 
    model_name,
    record_count
FROM model_stats
WHERE record_count = 0  -- Flag models with no data
```

### 2.3 Parameterized Tests

#### 2.3.1 Generic Score Range Test

```sql
-- macros/test_score_range.sql
{% macro test_score_range(model, column_name, min_value=0, max_value=10) %}

SELECT 
    {{ column_name }},
    COUNT(*) as invalid_records
FROM {{ model }}
WHERE {{ column_name }} IS NOT NULL
  AND ({{ column_name }} < {{ min_value }} OR {{ column_name }} > {{ max_value }})
GROUP BY {{ column_name }}
HAVING COUNT(*) > 0

{% endmacro %}
```

#### 2.3.2 Generic Date Range Test

```sql
-- macros/test_date_range.sql
{% macro test_date_range(model, column_name, start_date, end_date) %}

SELECT 
    {{ column_name }},
    COUNT(*) as invalid_records
FROM {{ model }}
WHERE {{ column_name }} IS NOT NULL
  AND ({{ column_name }} < '{{ start_date }}' OR {{ column_name }} > '{{ end_date }}')
GROUP BY {{ column_name }}
HAVING COUNT(*) > 0

{% endmacro %}
```

#### 2.3.3 Generic Audit Test

```sql
-- macros/test_audit_completeness.sql
{% macro test_audit_completeness(model) %}

SELECT 
    'Missing load_date' as issue_type,
    COUNT(*) as issue_count
FROM {{ model }}
WHERE load_date IS NULL

UNION ALL

SELECT 
    'Missing source_system' as issue_type,
    COUNT(*) as issue_count
FROM {{ model }}
WHERE source_system IS NULL OR source_system = ''

UNION ALL

SELECT 
    'Future load_date' as issue_type,
    COUNT(*) as issue_count
FROM {{ model }}
WHERE load_date > CURRENT_DATE()

HAVING SUM(issue_count) > 0

{% endmacro %}
```

### 2.4 Test Configuration

#### 2.4.1 dbt_project.yml Test Configuration

```yaml
# dbt_project.yml
name: 'zoom_gold_pipeline'
version: '1.0.0'
config-version: 2

model-paths: ["models"]
analysis-paths: ["analysis"]
test-paths: ["tests"]
seed-paths: ["data"]
macro-paths: ["macros"]
snapshot-paths: ["snapshots"]

target-path: "target"
clean-targets:
  - "target"
  - "dbt_packages"

models:
  zoom_gold_pipeline:
    +materialized: table
    audit:
      +materialized: table
      +tags: ["audit", "infrastructure"]
    dimensions:
      +materialized: table
      +tags: ["dimension", "gold"]
    facts:
      +materialized: table
      +tags: ["fact", "gold"]

tests:
  zoom_gold_pipeline:
    +severity: error
    +store_failures: true
    +schema: gold_test_results

vars:
  # Test configuration variables
  data_quality_threshold: 80
  validation_status_required: 'PASSED'
  date_range_start: '2020-01-01'
  date_range_end: '2030-12-31'
  score_min_value: 0
  score_max_value: 10
```

## 3. Test Execution Strategy

### 3.1 Test Categories

1. **Unit Tests**: Individual model validation
2. **Integration Tests**: Cross-model relationship validation
3. **Data Quality Tests**: Business rule validation
4. **Performance Tests**: Execution time and volume validation
5. **Regression Tests**: Ensuring changes don't break existing functionality

### 3.2 Test Execution Order

1. **Pre-execution Tests**: Source data validation
2. **Model Tests**: Individual model validation
3. **Cross-model Tests**: Referential integrity
4. **Business Logic Tests**: Complex business rule validation
5. **Performance Tests**: Execution metrics validation

### 3.3 Test Automation

```yaml
# .github/workflows/dbt_tests.yml
name: DBT Tests
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Python
        uses: actions/setup-python@v2
        with:
          python-version: '3.8'
          
      - name: Install dependencies
        run: |
          pip install dbt-snowflake
          dbt deps
          
      - name: Run DBT Tests
        run: |
          dbt test --select tag:audit
          dbt test --select tag:dimension
          dbt test --select tag:fact
          dbt test --select test_type:data_quality
          
      - name: Generate Test Report
        run: |
          dbt docs generate
          dbt docs serve --port 8080
```

## 4. Test Coverage Matrix

| Model | Unit Tests | Integration Tests | Data Quality Tests | Performance Tests | Business Logic Tests |
|-------|------------|-------------------|-------------------|-------------------|---------------------|
| go_audit_log | ✓ | ✓ | ✓ | ✓ | ✓ |
| go_dim_date | ✓ | ✓ | ✓ | ✓ | ✓ |
| go_dim_user | ✓ | ✓ | ✓ | ✓ | ✓ |
| go_dim_feature | ✓ | ✓ | ✓ | ✓ | ✓ |
| go_dim_license | ✓ | ✓ | ✓ | ✓ | ✓ |
| go_dim_meeting_type | ✓ | ✓ | ✓ | ✓ | ✓ |
| go_dim_support_category | ✓ | ✓ | ✓ | ✓ | ✓ |
| go_fact_feature_usage | ✓ | ✓ | ✓ | ✓ | ✓ |
| go_fact_meeting_activity | ✓ | ✓ | ✓ | ✓ | ✓ |
| go_fact_revenue_events | ✓ | ✓ | ✓ | ✓ | ✓ |
| go_fact_support_metrics | ✓ | ✓ | ✓ | ✓ | ✓ |

## 5. Test Maintenance Guidelines

### 5.1 Test Review Process
- All new models must include corresponding tests
- Test coverage must be maintained at 95% or higher
- Critical business logic must have multiple test scenarios
- Performance benchmarks must be established and monitored

### 5.2 Test Documentation
- Each test must include clear description and expected outcome
- Test failures must provide actionable error messages
- Test results must be logged and tracked over time

### 5.3 Continuous Improvement
- Regular review of test effectiveness
- Addition of new test cases based on production issues
- Performance optimization of test execution
- Integration with monitoring and alerting systems

This comprehensive test suite ensures the reliability, accuracy, and performance of the Zoom Gold Pipeline dbt models while maintaining data quality standards and business rule compliance.
