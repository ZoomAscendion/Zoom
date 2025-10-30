_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases and dbt test scripts for Zoom Platform Analytics System Silver layer dbt models
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases
## Zoom Platform Analytics System - Silver Layer

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics System Silver layer dbt models. The test cases cover data transformations, business rules, edge cases, and error handling scenarios to ensure reliable and high-quality data pipelines in Snowflake.

## Instructions

The following test cases are designed to validate:
- **Key transformations and business rules**: Data cleansing, standardization, and derived calculations
- **Edge cases**: Null values, empty datasets, invalid lookups, schema mismatches
- **Error handling scenarios**: Failed relationships, unexpected values, constraint violations
- **Data quality validations**: Completeness, accuracy, consistency, and referential integrity

## Test Case List

### 1. SI_USERS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_USR_001 | Validate user_id uniqueness and not null | All user_id values are unique and non-null |
| TC_USR_002 | Validate email format using regex pattern | All email addresses follow valid format |
| TC_USR_003 | Validate plan_type enumeration values | All plan_type values are in (FREE, BASIC, PRO, ENTERPRISE, UNKNOWN) |
| TC_USR_004 | Validate account_status enumeration values | All account_status values are in (ACTIVE, INACTIVE, SUSPENDED) |
| TC_USR_005 | Validate data_quality_score range | All scores are between 0.00 and 1.00 |
| TC_USR_006 | Test user_name standardization (INITCAP) | User names are properly formatted with initial caps |
| TC_USR_007 | Test email standardization (lowercase) | All emails are converted to lowercase |
| TC_USR_008 | Test deduplication logic | Only latest record per user_id is retained |
| TC_USR_009 | Test data quality score calculation | Score reflects completeness and validity |
| TC_USR_010 | Test edge case: null/empty user_name | Records with null user_name are filtered out |

### 2. SI_MEETINGS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_MTG_001 | Validate meeting_id uniqueness and not null | All meeting_id values are unique and non-null |
| TC_MTG_002 | Validate host_id referential integrity | All host_id values exist in si_users table |
| TC_MTG_003 | Validate meeting duration calculation | Duration matches DATEDIFF between start_time and end_time |
| TC_MTG_004 | Validate meeting_type derivation logic | Meeting types are correctly categorized |
| TC_MTG_005 | Validate meeting_status derivation | Status reflects current state based on timestamps |
| TC_MTG_006 | Validate participant_count accuracy | Count matches actual participants from si_participants |
| TC_MTG_007 | Test edge case: end_time before start_time | Invalid records are filtered out |
| TC_MTG_008 | Test edge case: negative duration | Records with negative duration are corrected or filtered |
| TC_MTG_009 | Test incremental loading logic | Only new/updated records are processed |
| TC_MTG_010 | Test data quality score for meetings | Score reflects data completeness and validity |

### 3. SI_PARTICIPANTS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_PRT_001 | Validate participant_id uniqueness | All participant_id values are unique and non-null |
| TC_PRT_002 | Validate meeting_id referential integrity | All meeting_id values exist in si_meetings table |
| TC_PRT_003 | Validate user_id referential integrity | All user_id values exist in si_users table |
| TC_PRT_004 | Validate attendance_duration calculation | Duration matches DATEDIFF between join_time and leave_time |
| TC_PRT_005 | Validate participant_role assignment | Roles are correctly assigned based on context |
| TC_PRT_006 | Test edge case: leave_time before join_time | Invalid records are filtered out |
| TC_PRT_007 | Test edge case: null leave_time | Records with ongoing participation are handled correctly |
| TC_PRT_008 | Test deduplication logic | Only latest record per participant_id is retained |
| TC_PRT_009 | Test data quality threshold filtering | Records below quality threshold are excluded |
| TC_PRT_010 | Test connection_quality default assignment | Default values are assigned when data is missing |

### 4. SI_FEATURE_USAGE Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_FTR_001 | Validate usage_id uniqueness | All usage_id values are unique and non-null |
| TC_FTR_002 | Validate meeting_id referential integrity | All meeting_id values exist in si_meetings table |
| TC_FTR_003 | Validate feature_category mapping | Features are correctly categorized (Audio, Video, Collaboration, Security, Other) |
| TC_FTR_004 | Validate usage_count non-negative constraint | All usage_count values are >= 0 |
| TC_FTR_005 | Validate usage_duration calculation | Duration is calculated based on usage_count |
| TC_FTR_006 | Test feature_name standardization | Feature names are cleaned and standardized |
| TC_FTR_007 | Test edge case: zero usage_count | Records with zero usage are handled appropriately |
| TC_FTR_008 | Test edge case: future usage_date | Records with future dates are filtered out |
| TC_FTR_009 | Test data quality score calculation | Score reflects data completeness and validity |
| TC_FTR_010 | Test incremental processing | Only new/updated records are processed |

### 5. SI_SUPPORT_TICKETS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_TKT_001 | Validate ticket_id uniqueness | All ticket_id values are unique and non-null |
| TC_TKT_002 | Validate user_id referential integrity | All user_id values exist in si_users table |
| TC_TKT_003 | Validate ticket_type enumeration | All values are in (Technical, Billing, Feature Request, Bug Report) |
| TC_TKT_004 | Validate priority_level derivation | Priority is correctly derived from ticket characteristics |
| TC_TKT_005 | Validate resolution_status enumeration | All values are in (Open, In Progress, Resolved, Closed) |
| TC_TKT_006 | Validate resolution_time_hours calculation | Time is calculated correctly in business hours |
| TC_TKT_007 | Test edge case: future open_date | Records with future dates are filtered out |
| TC_TKT_008 | Test close_date derivation logic | Close dates are derived based on resolution status |
| TC_TKT_009 | Test default value assignments | Default descriptions and notes are assigned |
| TC_TKT_010 | Test data quality threshold filtering | Records below quality threshold are excluded |

### 6. SI_BILLING_EVENTS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BIL_001 | Validate event_id uniqueness | All event_id values are unique and non-null |
| TC_BIL_002 | Validate user_id referential integrity | All user_id values exist in si_users table |
| TC_BIL_003 | Validate event_type enumeration | All values are in (Subscription, Upgrade, Downgrade, Refund) |
| TC_BIL_004 | Validate transaction_amount logic | Amounts are positive except for refunds |
| TC_BIL_005 | Validate currency_code assignment | Default currency (USD) is assigned when missing |
| TC_BIL_006 | Validate invoice_number generation | Invoice numbers are generated with proper format |
| TC_BIL_007 | Test edge case: negative amounts for non-refunds | Invalid records are corrected or filtered |
| TC_BIL_008 | Test edge case: future transaction_date | Records with future dates are filtered out |
| TC_BIL_009 | Test transaction_status derivation | Status is derived from event_type and processing |
| TC_BIL_010 | Test data quality score calculation | Score reflects data completeness and validity |

### 7. SI_LICENSES Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_LIC_001 | Validate license_id uniqueness | All license_id values are unique and non-null |
| TC_LIC_002 | Validate assigned_to_user_id referential integrity | All user_id values exist in si_users table |
| TC_LIC_003 | Validate license_type enumeration | All values are in (BASIC, PRO, ENTERPRISE, ADD-ON) |
| TC_LIC_004 | Validate license_status derivation | Status is correctly derived from dates |
| TC_LIC_005 | Validate license_cost assignment | Costs are assigned based on license_type |
| TC_LIC_006 | Validate date logic (end_date >= start_date) | All date relationships are valid |
| TC_LIC_007 | Test assigned_user_name lookup | Names are correctly looked up from si_users |
| TC_LIC_008 | Test utilization_percentage default | Default utilization is assigned |
| TC_LIC_009 | Test renewal_status assignment | Default renewal status is assigned |
| TC_LIC_010 | Test data quality threshold filtering | Records below quality threshold are excluded |

### 8. SI_WEBINARS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_WBN_001 | Validate webinar_id uniqueness | All webinar_id values are unique and non-null |
| TC_WBN_002 | Validate host_id referential integrity | All host_id values exist in si_users table |
| TC_WBN_003 | Validate duration_minutes calculation | Duration matches DATEDIFF between start_time and end_time |
| TC_WBN_004 | Validate attendees calculation | Attendees are calculated as 75% of registrants |
| TC_WBN_005 | Validate attendance_rate calculation | Rate is calculated as (attendees/registrants)*100 |
| TC_WBN_006 | Test edge case: end_time before start_time | Invalid records are filtered out |
| TC_WBN_007 | Test edge case: negative registrants | Records with negative values are filtered out |
| TC_WBN_008 | Test edge case: zero registrants | Attendance rate is set to 0 for zero registrants |
| TC_WBN_009 | Test webinar_topic standardization | Topics are cleaned and standardized |
| TC_WBN_010 | Test data quality score calculation | Score reflects data completeness and validity |

### 9. Cross-Model Integration Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_INT_001 | Validate referential integrity across all models | All foreign key relationships are maintained |
| TC_INT_002 | Test audit_log integration | All model executions are logged in audit_log |
| TC_INT_003 | Test incremental loading consistency | All models process the same time window |
| TC_INT_004 | Test data lineage tracking | Source system information is preserved |
| TC_INT_005 | Test error handling consistency | All models handle errors consistently |

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# models/silver/schema.yml
version: 2

models:
  - name: si_users
    description: "Silver layer cleaned and standardized user data"
    columns:
      - name: user_id
        description: "Unique identifier for each user account"
        tests:
          - not_null
          - unique
      - name: user_name
        description: "Standardized full name of the registered user"
        tests:
          - not_null
      - name: email
        description: "Validated and standardized email address"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
      - name: plan_type
        description: "Standardized subscription tier"
        tests:
          - not_null
          - accepted_values:
              values: ['FREE', 'BASIC', 'PRO', 'ENTERPRISE', 'UNKNOWN']
      - name: account_status
        description: "Current status of user account"
        tests:
          - not_null
          - accepted_values:
              values: ['ACTIVE', 'INACTIVE', 'SUSPENDED']
      - name: data_quality_score
        description: "Overall data quality score for the record"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1

  - name: si_meetings
    description: "Silver layer cleaned and enriched meeting data"
    columns:
      - name: meeting_id
        description: "Unique identifier for each meeting"
        tests:
          - not_null
          - unique
      - name: host_id
        description: "User ID of the meeting host"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: duration_minutes
        description: "Calculated and validated meeting duration"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440
      - name: meeting_type
        description: "Standardized meeting category"
        tests:
          - accepted_values:
              values: ['Scheduled', 'Instant', 'Webinar', 'Personal']
      - name: meeting_status
        description: "Current state of the meeting"
        tests:
          - accepted_values:
              values: ['Scheduled', 'In Progress', 'Completed', 'Unknown']
      - name: participant_count
        description: "Total number of participants"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0

  - name: si_participants
    description: "Silver layer cleaned participant attendance data"
    columns:
      - name: participant_id
        description: "Unique identifier for each participant record"
        tests:
          - not_null
          - unique
      - name: meeting_id
        description: "Reference to meeting"
        tests:
          - not_null
          - relationships:
              to: ref('si_meetings')
              field: meeting_id
      - name: user_id
        description: "Reference to user who participated"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: attendance_duration
        description: "Calculated time participant spent in meeting"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0

  - name: si_feature_usage
    description: "Silver layer standardized feature usage data"
    columns:
      - name: usage_id
        description: "Unique identifier for each feature usage record"
        tests:
          - not_null
          - unique
      - name: meeting_id
        description: "Reference to meeting where feature was used"
        tests:
          - not_null
          - relationships:
              to: ref('si_meetings')
              field: meeting_id
      - name: usage_count
        description: "Validated number of times feature was utilized"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
      - name: feature_category
        description: "Classification of feature type"
        tests:
          - accepted_values:
              values: ['Audio', 'Video', 'Collaboration', 'Security', 'Other']

  - name: si_support_tickets
    description: "Silver layer standardized support ticket data"
    columns:
      - name: ticket_id
        description: "Unique identifier for each support ticket"
        tests:
          - not_null
          - unique
      - name: user_id
        description: "Reference to user who created the ticket"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: ticket_type
        description: "Standardized category"
        tests:
          - accepted_values:
              values: ['Technical', 'Billing', 'Feature Request', 'Bug Report']
      - name: priority_level
        description: "Urgency level of ticket"
        tests:
          - accepted_values:
              values: ['Low', 'Medium', 'High', 'Critical']
      - name: resolution_status
        description: "Current status"
        tests:
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed']

  - name: si_billing_events
    description: "Silver layer validated billing transaction data"
    columns:
      - name: event_id
        description: "Unique identifier for each billing event"
        tests:
          - not_null
          - unique
      - name: user_id
        description: "Reference to user associated with billing event"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: event_type
        description: "Standardized billing transaction type"
        tests:
          - accepted_values:
              values: ['Subscription', 'Upgrade', 'Downgrade', 'Refund']
      - name: transaction_amount
        description: "Validated monetary value"
        tests:
          - not_null
      - name: currency_code
        description: "ISO currency code"
        tests:
          - not_null

  - name: si_licenses
    description: "Silver layer validated license management data"
    columns:
      - name: license_id
        description: "Unique identifier for each license"
        tests:
          - not_null
          - unique
      - name: license_type
        description: "Standardized category"
        tests:
          - accepted_values:
              values: ['BASIC', 'PRO', 'ENTERPRISE', 'ADD-ON']
      - name: license_status
        description: "Current state"
        tests:
          - accepted_values:
              values: ['Active', 'Expired', 'Suspended']
      - name: license_cost
        description: "Price associated with the license"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
      - name: utilization_percentage
        description: "Percentage of license features being utilized"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100

  - name: si_webinars
    description: "Silver layer cleaned webinar data with metrics"
    columns:
      - name: webinar_id
        description: "Unique identifier for each webinar"
        tests:
          - not_null
          - unique
      - name: host_id
        description: "User ID of the webinar host"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: registrants
        description: "Number of registered participants"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
      - name: attendees
        description: "Number of actual attendees"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
      - name: attendance_rate
        description: "Percentage of registrants who attended"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100
```

### Custom SQL-based dbt Tests

#### 1. Test for Meeting Duration Consistency
```sql
-- tests/assert_meeting_duration_consistency.sql
-- Test that calculated duration matches the difference between start and end times

SELECT 
    meeting_id,
    duration_minutes,
    DATEDIFF('minute', start_time, end_time) as calculated_duration
FROM {{ ref('si_meetings') }}
WHERE ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) > 1
```

#### 2. Test for Participant Count Accuracy
```sql
-- tests/assert_participant_count_accuracy.sql
-- Test that meeting participant count matches actual participant records

WITH meeting_participant_counts AS (
    SELECT 
        m.meeting_id,
        m.participant_count as reported_count,
        COUNT(p.participant_id) as actual_count
    FROM {{ ref('si_meetings') }} m
    LEFT JOIN {{ ref('si_participants') }} p ON m.meeting_id = p.meeting_id
    GROUP BY m.meeting_id, m.participant_count
)
SELECT *
FROM meeting_participant_counts
WHERE reported_count != actual_count
```

#### 3. Test for Data Quality Score Validation
```sql
-- tests/assert_data_quality_scores.sql
-- Test that all data quality scores are within valid range across all tables

SELECT 'si_users' as table_name, COUNT(*) as invalid_scores
FROM {{ ref('si_users') }}
WHERE data_quality_score < 0 OR data_quality_score > 1

UNION ALL

SELECT 'si_meetings', COUNT(*)
FROM {{ ref('si_meetings') }}
WHERE data_quality_score < 0 OR data_quality_score > 1

UNION ALL

SELECT 'si_participants', COUNT(*)
FROM {{ ref('si_participants') }}
WHERE data_quality_score < 0 OR data_quality_score > 1

UNION ALL

SELECT 'si_feature_usage', COUNT(*)
FROM {{ ref('si_feature_usage') }}
WHERE data_quality_score < 0 OR data_quality_score > 1

UNION ALL

SELECT 'si_support_tickets', COUNT(*)
FROM {{ ref('si_support_tickets') }}
WHERE data_quality_score < 0 OR data_quality_score > 1

UNION ALL

SELECT 'si_billing_events', COUNT(*)
FROM {{ ref('si_billing_events') }}
WHERE data_quality_score < 0 OR data_quality_score > 1

UNION ALL

SELECT 'si_licenses', COUNT(*)
FROM {{ ref('si_licenses') }}
WHERE data_quality_score < 0 OR data_quality_score > 1

UNION ALL

SELECT 'si_webinars', COUNT(*)
FROM {{ ref('si_webinars') }}
WHERE data_quality_score < 0 OR data_quality_score > 1
```

#### 4. Test for Referential Integrity
```sql
-- tests/assert_referential_integrity.sql
-- Test that all foreign key relationships are maintained

-- Check meetings with invalid host_id
SELECT 'meetings_invalid_host' as test_case, COUNT(*) as violation_count
FROM {{ ref('si_meetings') }} m
LEFT JOIN {{ ref('si_users') }} u ON m.host_id = u.user_id
WHERE u.user_id IS NULL AND m.host_id IS NOT NULL

UNION ALL

-- Check participants with invalid meeting_id
SELECT 'participants_invalid_meeting', COUNT(*)
FROM {{ ref('si_participants') }} p
LEFT JOIN {{ ref('si_meetings') }} m ON p.meeting_id = m.meeting_id
WHERE m.meeting_id IS NULL

UNION ALL

-- Check participants with invalid user_id
SELECT 'participants_invalid_user', COUNT(*)
FROM {{ ref('si_participants') }} p
LEFT JOIN {{ ref('si_users') }} u ON p.user_id = u.user_id
WHERE u.user_id IS NULL AND p.user_id IS NOT NULL

UNION ALL

-- Check feature usage with invalid meeting_id
SELECT 'feature_usage_invalid_meeting', COUNT(*)
FROM {{ ref('si_feature_usage') }} f
LEFT JOIN {{ ref('si_meetings') }} m ON f.meeting_id = m.meeting_id
WHERE m.meeting_id IS NULL

UNION ALL

-- Check support tickets with invalid user_id
SELECT 'support_tickets_invalid_user', COUNT(*)
FROM {{ ref('si_support_tickets') }} t
LEFT JOIN {{ ref('si_users') }} u ON t.user_id = u.user_id
WHERE u.user_id IS NULL

UNION ALL

-- Check billing events with invalid user_id
SELECT 'billing_events_invalid_user', COUNT(*)
FROM {{ ref('si_billing_events') }} b
LEFT JOIN {{ ref('si_users') }} u ON b.user_id = u.user_id
WHERE u.user_id IS NULL

UNION ALL

-- Check webinars with invalid host_id
SELECT 'webinars_invalid_host', COUNT(*)
FROM {{ ref('si_webinars') }} w
LEFT JOIN {{ ref('si_users') }} u ON w.host_id = u.user_id
WHERE u.user_id IS NULL AND w.host_id IS NOT NULL
```

#### 5. Test for Business Logic Validation
```sql
-- tests/assert_business_logic.sql
-- Test business rules and logic constraints

-- Check for meetings with end_time before start_time
SELECT 'meetings_invalid_time_logic' as test_case, COUNT(*) as violation_count
FROM {{ ref('si_meetings') }}
WHERE end_time < start_time

UNION ALL

-- Check for participants with leave_time before join_time
SELECT 'participants_invalid_time_logic', COUNT(*)
FROM {{ ref('si_participants') }}
WHERE leave_time < join_time

UNION ALL

-- Check for webinars with attendees > registrants
SELECT 'webinars_invalid_attendance', COUNT(*)
FROM {{ ref('si_webinars') }}
WHERE attendees > registrants

UNION ALL

-- Check for licenses with end_date before start_date
SELECT 'licenses_invalid_date_logic', COUNT(*)
FROM {{ ref('si_licenses') }}
WHERE end_date < start_date

UNION ALL

-- Check for support tickets with close_date before open_date
SELECT 'tickets_invalid_date_logic', COUNT(*)
FROM {{ ref('si_support_tickets') }}
WHERE close_date < open_date
```

#### 6. Test for Data Completeness
```sql
-- tests/assert_data_completeness.sql
-- Test for required field completeness across all models

WITH completeness_check AS (
    SELECT 
        'si_users' as table_name,
        COUNT(*) as total_records,
        SUM(CASE WHEN user_id IS NULL THEN 1 ELSE 0 END) as null_user_id,
        SUM(CASE WHEN user_name IS NULL THEN 1 ELSE 0 END) as null_user_name,
        SUM(CASE WHEN email IS NULL THEN 1 ELSE 0 END) as null_email
    FROM {{ ref('si_users') }}
    
    UNION ALL
    
    SELECT 
        'si_meetings',
        COUNT(*),
        SUM(CASE WHEN meeting_id IS NULL THEN 1 ELSE 0 END),
        SUM(CASE WHEN host_id IS NULL THEN 1 ELSE 0 END),
        SUM(CASE WHEN start_time IS NULL THEN 1 ELSE 0 END)
    FROM {{ ref('si_meetings') }}
    
    UNION ALL
    
    SELECT 
        'si_participants',
        COUNT(*),
        SUM(CASE WHEN participant_id IS NULL THEN 1 ELSE 0 END),
        SUM(CASE WHEN meeting_id IS NULL THEN 1 ELSE 0 END),
        SUM(CASE WHEN user_id IS NULL THEN 1 ELSE 0 END)
    FROM {{ ref('si_participants') }}
)
SELECT *
FROM completeness_check
WHERE null_user_id > 0 OR null_user_name > 0 OR null_email > 0
```

#### 7. Test for Incremental Loading
```sql
-- tests/assert_incremental_loading.sql
-- Test that incremental loading is working correctly

WITH load_stats AS (
    SELECT 
        'si_users' as table_name,
        COUNT(*) as total_records,
        COUNT(DISTINCT DATE(load_timestamp)) as load_dates,
        MAX(load_timestamp) as latest_load,
        MIN(load_timestamp) as earliest_load
    FROM {{ ref('si_users') }}
    
    UNION ALL
    
    SELECT 
        'si_meetings',
        COUNT(*),
        COUNT(DISTINCT DATE(load_timestamp)),
        MAX(load_timestamp),
        MIN(load_timestamp)
    FROM {{ ref('si_meetings') }}
)
SELECT *
FROM load_stats
WHERE total_records = 0 OR latest_load < CURRENT_DATE() - INTERVAL '7 days'
```

#### 8. Test for Audit Trail Completeness
```sql
-- tests/assert_audit_trail.sql
-- Test that audit logging is working for all model executions

WITH expected_models AS (
    SELECT model_name FROM (
        VALUES 
        ('si_users'),
        ('si_meetings'),
        ('si_participants'),
        ('si_feature_usage'),
        ('si_support_tickets'),
        ('si_billing_events'),
        ('si_licenses'),
        ('si_webinars')
    ) AS t(model_name)
),
logged_models AS (
    SELECT DISTINCT 
        LOWER(TRIM(pipeline_name)) as model_name
    FROM {{ ref('audit_log') }}
    WHERE DATE(start_time) = CURRENT_DATE()
)
SELECT e.model_name
FROM expected_models e
LEFT JOIN logged_models l ON e.model_name = l.model_name
WHERE l.model_name IS NULL
```

### Parameterized Tests

#### Generic Test for Enum Validation
```sql
-- macros/test_enum_values.sql
{% macro test_enum_values(model, column_name, values) %}
    SELECT {{ column_name }}, COUNT(*) as invalid_count
    FROM {{ model }}
    WHERE {{ column_name }} NOT IN ({{ "'" + values | join("', '") + "'" }})
    GROUP BY {{ column_name }}
    HAVING COUNT(*) > 0
{% endmacro %}
```

#### Generic Test for Range Validation
```sql
-- macros/test_range_values.sql
{% macro test_range_values(model, column_name, min_value, max_value) %}
    SELECT COUNT(*) as out_of_range_count
    FROM {{ model }}
    WHERE {{ column_name }} < {{ min_value }} OR {{ column_name }} > {{ max_value }}
{% endmacro %}
```

#### Generic Test for Date Logic
```sql
-- macros/test_date_logic.sql
{% macro test_date_logic(model, start_date_column, end_date_column) %}
    SELECT COUNT(*) as invalid_date_logic_count
    FROM {{ model }}
    WHERE {{ end_date_column }} < {{ start_date_column }}
{% endmacro %}
```

## Test Execution Strategy

### 1. Pre-deployment Testing
- Run all schema tests before deploying models
- Execute custom SQL tests to validate business logic
- Verify data quality scores meet minimum thresholds
- Check referential integrity across all models

### 2. Post-deployment Monitoring
- Schedule daily execution of critical tests
- Monitor test results in dbt's run_results.json
- Set up alerts for test failures
- Track test performance trends over time

### 3. Continuous Integration
- Integrate tests into CI/CD pipeline
- Require all tests to pass before merging changes
- Generate test coverage reports
- Maintain test documentation and updates

### 4. Performance Considerations
- Optimize test queries for large datasets
- Use sampling for performance-intensive tests
- Schedule resource-intensive tests during off-peak hours
- Monitor test execution times and optimize as needed

## Error Handling and Recovery

### 1. Test Failure Response
- Immediate notification to data engineering team
- Automatic rollback of failed deployments
- Investigation and root cause analysis
- Documentation of resolution steps

### 2. Data Quality Issues
- Log issues in SI_DATA_QUALITY_ERRORS table
- Categorize by severity (Critical, High, Medium, Low)
- Implement automated remediation where possible
- Manual review process for critical issues

### 3. Monitoring and Alerting
- Real-time monitoring of test results
- Dashboard for data quality metrics
- Automated alerts for threshold breaches
- Regular reporting to stakeholders

This comprehensive test suite ensures the reliability, accuracy, and performance of the Zoom Platform Analytics System Silver layer dbt models, providing confidence in data quality and business rule compliance throughout the data pipeline.