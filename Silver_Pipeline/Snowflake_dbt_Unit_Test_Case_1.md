_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Silver Pipeline dbt models in Snowflake
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases - Zoom Silver Pipeline

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Silver Pipeline dbt models running in Snowflake. The test cases cover data transformations, business rules, edge cases, and error handling scenarios to ensure data quality and pipeline reliability.

## Test Coverage Overview

The test suite covers the following dbt models:
- `si_users` - User account data transformation
- `si_meetings` - Meeting session data processing
- `si_participants` - Meeting participant tracking
- `si_feature_usage` - Platform feature usage analytics
- `si_support_tickets` - Customer support ticket management
- `si_billing_events` - Billing and financial transactions
- `si_licenses` - License assignment and management
- `si_webinars` - Webinar session analytics
- `audit_log` - Pipeline execution audit trail

## Test Case List

### 1. SI_USERS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_USR_001 | Validate user_id uniqueness and not null | All user_id values are unique and non-null |
| TC_USR_002 | Validate email format using regex pattern | Only valid email formats are accepted |
| TC_USR_003 | Validate plan_type accepted values | Only 'FREE', 'BASIC', 'PRO', 'ENTERPRISE' values allowed |
| TC_USR_004 | Test data quality score calculation | Data quality score between 0.0 and 1.0 |
| TC_USR_005 | Test deduplication logic with ROW_NUMBER | Latest record by update_timestamp is retained |
| TC_USR_006 | Validate account_status derivation | Status correctly derived from plan_type |
| TC_USR_007 | Test incremental processing | Only new/updated records processed |
| TC_USR_008 | Handle null/empty user_name gracefully | Records with null user_name are processed |
| TC_USR_009 | Test TRIM and INITCAP transformations | Names properly formatted and trimmed |
| TC_USR_010 | Validate critical data quality error handling | Records with critical errors are excluded |

### 2. SI_MEETINGS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_MTG_001 | Validate meeting_id uniqueness and not null | All meeting_id values are unique and non-null |
| TC_MTG_002 | Test host_id relationship with si_users | Valid foreign key relationship maintained |
| TC_MTG_003 | Validate meeting_type classification | Correct meeting type assigned based on topic |
| TC_MTG_004 | Test duration calculation logic | Duration correctly calculated from start/end times |
| TC_MTG_005 | Validate meeting_status derivation | Status correctly derived from timestamps |
| TC_MTG_006 | Test participant count aggregation | Accurate participant counts from participants table |
| TC_MTG_007 | Handle invalid time logic (end < start) | Records with invalid times flagged as errors |
| TC_MTG_008 | Test duration range validation (0-1440 minutes) | Duration values within acceptable range |
| TC_MTG_009 | Validate host name lookup | Host names correctly retrieved from users table |
| TC_MTG_010 | Test incremental processing with updates | Only changed meetings processed incrementally |

### 3. SI_PARTICIPANTS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_PRT_001 | Validate participant_id uniqueness | All participant_id values are unique |
| TC_PRT_002 | Test meeting_id relationship validation | Valid relationships to si_meetings maintained |
| TC_PRT_003 | Test user_id relationship validation | Valid relationships to si_users maintained |
| TC_PRT_004 | Validate attendance duration calculation | Duration correctly calculated from join/leave times |
| TC_PRT_005 | Handle null leave_time scenarios | Null leave_time handled gracefully |
| TC_PRT_006 | Test invalid time logic (leave < join) | Records with invalid times flagged as errors |
| TC_PRT_007 | Validate participant role assignment | Default roles assigned correctly |
| TC_PRT_008 | Test connection quality defaults | Default quality values assigned |
| TC_PRT_009 | Test deduplication by participant_id | Latest participant record retained |
| TC_PRT_010 | Validate data quality score calculation | Quality scores calculated accurately |

### 4. SI_FEATURE_USAGE Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_FTR_001 | Validate usage_id uniqueness | All usage_id values are unique |
| TC_FTR_002 | Test feature_category classification | Features correctly categorized by name patterns |
| TC_FTR_003 | Validate usage_count non-negative | Usage counts are zero or positive |
| TC_FTR_004 | Test usage_duration calculation | Duration estimated from usage count |
| TC_FTR_005 | Handle future usage_date scenarios | Future dates flagged as medium priority errors |
| TC_FTR_006 | Test meeting_id relationship | Valid relationships to meetings maintained |
| TC_FTR_007 | Validate feature_name not null/empty | Feature names are required and non-empty |
| TC_FTR_008 | Test incremental processing | Only new usage records processed |
| TC_FTR_009 | Handle negative usage_count | Negative counts converted to zero |
| TC_FTR_010 | Validate feature category mapping | Audio, Video, Collaboration, Security categories assigned correctly |

### 5. SI_SUPPORT_TICKETS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_TKT_001 | Validate ticket_id uniqueness | All ticket_id values are unique |
| TC_TKT_002 | Test user_id relationship validation | Valid relationships to si_users maintained |
| TC_TKT_003 | Validate ticket_type accepted values | Only valid ticket types accepted |
| TC_TKT_004 | Test priority_level derivation | Priority correctly derived from ticket type |
| TC_TKT_005 | Validate resolution_status values | Only valid resolution statuses accepted |
| TC_TKT_006 | Test close_date calculation | Close dates calculated for resolved tickets |
| TC_TKT_007 | Validate resolution_time_hours | Resolution time estimated correctly |
| TC_TKT_008 | Handle future open_date scenarios | Future dates flagged as errors |
| TC_TKT_009 | Test resolution_notes assignment | Notes assigned for resolved tickets |
| TC_TKT_010 | Validate incremental processing | Only updated tickets processed |

### 6. SI_BILLING_EVENTS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BIL_001 | Validate event_id uniqueness | All event_id values are unique |
| TC_BIL_002 | Test user_id relationship validation | Valid relationships to si_users maintained |
| TC_BIL_003 | Validate event_type accepted values | Only valid event types accepted |
| TC_BIL_004 | Test transaction_amount validation | Amounts are positive (absolute value applied) |
| TC_BIL_005 | Validate currency_code defaults | Default USD currency assigned |
| TC_BIL_006 | Test invoice_number generation | Invoice numbers generated with prefix |
| TC_BIL_007 | Handle refund amount logic | Refund amounts handled correctly |
| TC_BIL_008 | Validate transaction_status defaults | Default 'Completed' status assigned |
| TC_BIL_009 | Test payment_method defaults | Default payment method assigned |
| TC_BIL_010 | Handle future event_date scenarios | Future dates flagged as errors |

### 7. SI_LICENSES Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_LIC_001 | Validate license_id uniqueness | All license_id values are unique |
| TC_LIC_002 | Test assigned_to_user_id relationship | Valid relationships to si_users maintained |
| TC_LIC_003 | Validate license_type accepted values | Only valid license types accepted |
| TC_LIC_004 | Test license_status derivation | Status correctly derived from dates |
| TC_LIC_005 | Validate date logic (start < end) | Start date must be before end date |
| TC_LIC_006 | Test license_cost calculation | Costs assigned based on license type |
| TC_LIC_007 | Validate utilization_percentage range | Utilization between 0-100% |
| TC_LIC_008 | Test assigned_user_name lookup | User names correctly retrieved |
| TC_LIC_009 | Handle unassigned licenses | Unassigned licenses handled gracefully |
| TC_LIC_010 | Test renewal_status defaults | Default renewal status assigned |

### 8. SI_WEBINARS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_WEB_001 | Validate webinar_id uniqueness | All webinar_id values are unique |
| TC_WEB_002 | Test host_id relationship validation | Valid relationships to si_users maintained |
| TC_WEB_003 | Validate duration calculation | Duration correctly calculated from timestamps |
| TC_WEB_004 | Test registrants non-negative | Registrant counts are zero or positive |
| TC_WEB_005 | Validate attendees estimation | Attendees estimated at 75% of registrants |
| TC_WEB_006 | Test attendance_rate calculation | Attendance rate calculated correctly |
| TC_WEB_007 | Handle invalid time logic | End time must be after start time |
| TC_WEB_008 | Validate duration range (0-1440 minutes) | Duration within acceptable range |
| TC_WEB_009 | Test negative registrants handling | Negative values converted to zero |
| TC_WEB_010 | Validate incremental processing | Only updated webinars processed |

### 9. AUDIT_LOG Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_AUD_001 | Validate execution_id uniqueness | All execution_id values are unique |
| TC_AUD_002 | Test pipeline execution tracking | Pipeline start/end times recorded |
| TC_AUD_003 | Validate status transitions | Status correctly transitions from STARTED to SUCCESS |
| TC_AUD_004 | Test record count aggregation | Total records processed calculated |
| TC_AUD_005 | Validate execution duration calculation | Duration calculated in seconds |
| TC_AUD_006 | Test error handling in post-hooks | Errors in post-hooks handled gracefully |
| TC_AUD_007 | Validate data lineage information | Source and target tables documented |
| TC_AUD_008 | Test environment tracking | Execution environment recorded |
| TC_AUD_009 | Validate user tracking | Executing user recorded |
| TC_AUD_010 | Test incremental behavior | Audit records only inserted on initial run |

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# tests/schema_tests.yml
version: 2

models:
  - name: si_users
    tests:
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - user_id
            - load_date
      - dbt_expectations.expect_table_row_count_to_be_between:
          min_value: 1
          max_value: 1000000
    columns:
      - name: user_id
        tests:
          - unique
          - not_null
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: '^[A-Za-z0-9_-]+$'
      - name: email
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
      - name: plan_type
        tests:
          - accepted_values:
              values: ['FREE', 'BASIC', 'PRO', 'ENTERPRISE']
      - name: account_status
        tests:
          - accepted_values:
              values: ['Active', 'Inactive', 'Suspended']
      - name: data_quality_score
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.0
              max_value: 1.0

  - name: si_meetings
    tests:
      - dbt_utils.expression_is_true:
          expression: "duration_minutes >= 0"
      - dbt_utils.expression_is_true:
          expression: "end_time >= start_time"
    columns:
      - name: meeting_id
        tests:
          - unique
          - not_null
      - name: host_id
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: meeting_type
        tests:
          - accepted_values:
              values: ['Scheduled', 'Instant', 'Webinar', 'Personal']
      - name: meeting_status
        tests:
          - accepted_values:
              values: ['Scheduled', 'In Progress', 'Completed', 'Cancelled']
      - name: duration_minutes
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440
      - name: participant_count
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0

  - name: si_participants
    tests:
      - dbt_utils.expression_is_true:
          expression: "leave_time IS NULL OR leave_time >= join_time"
    columns:
      - name: participant_id
        tests:
          - unique
          - not_null
      - name: meeting_id
        tests:
          - not_null
          - relationships:
              to: ref('si_meetings')
              field: meeting_id
      - name: user_id
        tests:
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: attendance_duration
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440
              row_condition: "attendance_duration IS NOT NULL"

  - name: si_feature_usage
    columns:
      - name: usage_id
        tests:
          - unique
          - not_null
      - name: meeting_id
        tests:
          - relationships:
              to: ref('si_meetings')
              field: meeting_id
      - name: feature_category
        tests:
          - accepted_values:
              values: ['Audio', 'Video', 'Collaboration', 'Security', 'Other']
      - name: usage_count
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
      - name: usage_duration
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0

  - name: si_support_tickets
    columns:
      - name: ticket_id
        tests:
          - unique
          - not_null
      - name: user_id
        tests:
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: ticket_type
        tests:
          - accepted_values:
              values: ['TECHNICAL', 'BILLING', 'FEATURE REQUEST', 'BUG REPORT']
      - name: priority_level
        tests:
          - accepted_values:
              values: ['Low', 'Medium', 'High', 'Critical']
      - name: resolution_status
        tests:
          - accepted_values:
              values: ['OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED']
      - name: resolution_time_hours
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 8760  # 1 year in hours
              row_condition: "resolution_time_hours IS NOT NULL"

  - name: si_billing_events
    columns:
      - name: event_id
        tests:
          - unique
          - not_null
      - name: user_id
        tests:
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: event_type
        tests:
          - accepted_values:
              values: ['SUBSCRIPTION', 'UPGRADE', 'DOWNGRADE', 'REFUND']
      - name: transaction_amount
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
      - name: currency_code
        tests:
          - accepted_values:
              values: ['USD', 'EUR', 'GBP', 'CAD', 'AUD']
      - name: invoice_number
        tests:
          - unique
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: '^INV-.*'

  - name: si_licenses
    tests:
      - dbt_utils.expression_is_true:
          expression: "end_date > start_date"
    columns:
      - name: license_id
        tests:
          - unique
          - not_null
      - name: assigned_to_user_id
        tests:
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: license_type
        tests:
          - accepted_values:
              values: ['BASIC', 'PRO', 'ENTERPRISE', 'ADD-ON']
      - name: license_status
        tests:
          - accepted_values:
              values: ['Active', 'Expired', 'Suspended']
      - name: utilization_percentage
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100
      - name: license_cost
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0

  - name: si_webinars
    tests:
      - dbt_utils.expression_is_true:
          expression: "end_time > start_time"
      - dbt_utils.expression_is_true:
          expression: "attendees <= registrants"
    columns:
      - name: webinar_id
        tests:
          - unique
          - not_null
      - name: host_id
        tests:
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: duration_minutes
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440
      - name: registrants
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
      - name: attendees
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
      - name: attendance_rate
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100

  - name: audit_log
    columns:
      - name: execution_id
        tests:
          - unique
          - not_null
      - name: pipeline_name
        tests:
          - not_null
      - name: status
        tests:
          - accepted_values:
              values: ['STARTED', 'IN_PROGRESS', 'SUCCESS', 'FAILED']
```

### Custom SQL-based dbt Tests

```sql
-- tests/test_data_quality_scores.sql
-- Test that all data quality scores are within valid range
SELECT *
FROM (
    SELECT 'si_users' as table_name, user_id as record_id, data_quality_score
    FROM {{ ref('si_users') }}
    WHERE data_quality_score < 0 OR data_quality_score > 1
    
    UNION ALL
    
    SELECT 'si_meetings' as table_name, meeting_id as record_id, data_quality_score
    FROM {{ ref('si_meetings') }}
    WHERE data_quality_score < 0 OR data_quality_score > 1
    
    UNION ALL
    
    SELECT 'si_participants' as table_name, participant_id as record_id, data_quality_score
    FROM {{ ref('si_participants') }}
    WHERE data_quality_score < 0 OR data_quality_score > 1
    
    UNION ALL
    
    SELECT 'si_feature_usage' as table_name, usage_id as record_id, data_quality_score
    FROM {{ ref('si_feature_usage') }}
    WHERE data_quality_score < 0 OR data_quality_score > 1
    
    UNION ALL
    
    SELECT 'si_support_tickets' as table_name, ticket_id as record_id, data_quality_score
    FROM {{ ref('si_support_tickets') }}
    WHERE data_quality_score < 0 OR data_quality_score > 1
    
    UNION ALL
    
    SELECT 'si_billing_events' as table_name, event_id as record_id, data_quality_score
    FROM {{ ref('si_billing_events') }}
    WHERE data_quality_score < 0 OR data_quality_score > 1
    
    UNION ALL
    
    SELECT 'si_licenses' as table_name, license_id as record_id, data_quality_score
    FROM {{ ref('si_licenses') }}
    WHERE data_quality_score < 0 OR data_quality_score > 1
    
    UNION ALL
    
    SELECT 'si_webinars' as table_name, webinar_id as record_id, data_quality_score
    FROM {{ ref('si_webinars') }}
    WHERE data_quality_score < 0 OR data_quality_score > 1
)
```

```sql
-- tests/test_incremental_processing.sql
-- Test that incremental models only process new/updated records
WITH incremental_test AS (
    SELECT 
        'si_users' as model_name,
        COUNT(*) as total_records,
        COUNT(CASE WHEN update_timestamp > CURRENT_TIMESTAMP() - INTERVAL '1 DAY' THEN 1 END) as recent_records
    FROM {{ ref('si_users') }}
    
    UNION ALL
    
    SELECT 
        'si_meetings' as model_name,
        COUNT(*) as total_records,
        COUNT(CASE WHEN update_timestamp > CURRENT_TIMESTAMP() - INTERVAL '1 DAY' THEN 1 END) as recent_records
    FROM {{ ref('si_meetings') }}
    
    UNION ALL
    
    SELECT 
        'si_participants' as model_name,
        COUNT(*) as total_records,
        COUNT(CASE WHEN update_timestamp > CURRENT_TIMESTAMP() - INTERVAL '1 DAY' THEN 1 END) as recent_records
    FROM {{ ref('si_participants') }}
)
SELECT *
FROM incremental_test
WHERE total_records = 0  -- Should not have zero records in production
```

```sql
-- tests/test_referential_integrity.sql
-- Test referential integrity across all models
SELECT 'si_meetings' as child_table, 'host_id' as foreign_key, COUNT(*) as orphaned_records
FROM {{ ref('si_meetings') }} m
LEFT JOIN {{ ref('si_users') }} u ON m.host_id = u.user_id
WHERE u.user_id IS NULL AND m.host_id IS NOT NULL

UNION ALL

SELECT 'si_participants' as child_table, 'meeting_id' as foreign_key, COUNT(*) as orphaned_records
FROM {{ ref('si_participants') }} p
LEFT JOIN {{ ref('si_meetings') }} m ON p.meeting_id = m.meeting_id
WHERE m.meeting_id IS NULL AND p.meeting_id IS NOT NULL

UNION ALL

SELECT 'si_participants' as child_table, 'user_id' as foreign_key, COUNT(*) as orphaned_records
FROM {{ ref('si_participants') }} p
LEFT JOIN {{ ref('si_users') }} u ON p.user_id = u.user_id
WHERE u.user_id IS NULL AND p.user_id IS NOT NULL

UNION ALL

SELECT 'si_feature_usage' as child_table, 'meeting_id' as foreign_key, COUNT(*) as orphaned_records
FROM {{ ref('si_feature_usage') }} f
LEFT JOIN {{ ref('si_meetings') }} m ON f.meeting_id = m.meeting_id
WHERE m.meeting_id IS NULL AND f.meeting_id IS NOT NULL

UNION ALL

SELECT 'si_support_tickets' as child_table, 'user_id' as foreign_key, COUNT(*) as orphaned_records
FROM {{ ref('si_support_tickets') }} s
LEFT JOIN {{ ref('si_users') }} u ON s.user_id = u.user_id
WHERE u.user_id IS NULL AND s.user_id IS NOT NULL

UNION ALL

SELECT 'si_billing_events' as child_table, 'user_id' as foreign_key, COUNT(*) as orphaned_records
FROM {{ ref('si_billing_events') }} b
LEFT JOIN {{ ref('si_users') }} u ON b.user_id = u.user_id
WHERE u.user_id IS NULL AND b.user_id IS NOT NULL

UNION ALL

SELECT 'si_licenses' as child_table, 'assigned_to_user_id' as foreign_key, COUNT(*) as orphaned_records
FROM {{ ref('si_licenses') }} l
LEFT JOIN {{ ref('si_users') }} u ON l.assigned_to_user_id = u.user_id
WHERE u.user_id IS NULL AND l.assigned_to_user_id IS NOT NULL

UNION ALL

SELECT 'si_webinars' as child_table, 'host_id' as foreign_key, COUNT(*) as orphaned_records
FROM {{ ref('si_webinars') }} w
LEFT JOIN {{ ref('si_users') }} u ON w.host_id = u.user_id
WHERE u.user_id IS NULL AND w.host_id IS NOT NULL

HAVING orphaned_records > 0  -- Only return tables with orphaned records
```

```sql
-- tests/test_business_rules.sql
-- Test business logic and derived fields
SELECT 'Invalid account status derivation' as test_name, COUNT(*) as failed_records
FROM {{ ref('si_users') }}
WHERE (plan_type IN ('PRO', 'ENTERPRISE', 'BASIC') AND account_status != 'Active')
   OR (plan_type = 'FREE' AND account_status = 'Active')

UNION ALL

SELECT 'Invalid meeting type classification' as test_name, COUNT(*) as failed_records
FROM {{ ref('si_meetings') }}
WHERE (meeting_topic LIKE '%Webinar%' AND meeting_type != 'Webinar')
   OR (meeting_topic LIKE '%Personal%' AND meeting_type != 'Personal')

UNION ALL

SELECT 'Invalid priority level assignment' as test_name, COUNT(*) as failed_records
FROM {{ ref('si_support_tickets') }}
WHERE (ticket_type = 'BUG REPORT' AND priority_level != 'Critical')
   OR (ticket_type = 'TECHNICAL' AND priority_level != 'High')
   OR (ticket_type = 'BILLING' AND priority_level != 'Medium')

UNION ALL

SELECT 'Invalid license status derivation' as test_name, COUNT(*) as failed_records
FROM {{ ref('si_licenses') }}
WHERE (CURRENT_DATE() BETWEEN start_date AND end_date AND license_status != 'Active')
   OR (CURRENT_DATE() > end_date AND license_status != 'Expired')

HAVING failed_records > 0
```

```sql
-- tests/test_data_transformations.sql
-- Test data cleansing and transformation logic
SELECT 'Untrimmed user names' as test_name, COUNT(*) as failed_records
FROM {{ ref('si_users') }}
WHERE user_name != TRIM(user_name)
   OR user_name LIKE ' %'
   OR user_name LIKE '% '

UNION ALL

SELECT 'Invalid email format' as test_name, COUNT(*) as failed_records
FROM {{ ref('si_users') }}
WHERE email IS NOT NULL 
  AND NOT REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')

UNION ALL

SELECT 'Inconsistent case in plan_type' as test_name, COUNT(*) as failed_records
FROM {{ ref('si_users') }}
WHERE plan_type != UPPER(plan_type)

UNION ALL

SELECT 'Invalid duration calculations' as test_name, COUNT(*) as failed_records
FROM {{ ref('si_meetings') }}
WHERE duration_minutes != DATEDIFF('minute', start_time, end_time)
  AND end_time IS NOT NULL
  AND start_time IS NOT NULL

HAVING failed_records > 0
```

```sql
-- tests/test_edge_cases.sql
-- Test handling of edge cases and null values
SELECT 'Null handling in attendance duration' as test_name, COUNT(*) as records_count
FROM {{ ref('si_participants') }}
WHERE leave_time IS NULL AND attendance_duration IS NOT NULL

UNION ALL

SELECT 'Zero registrants with positive attendees' as test_name, COUNT(*) as records_count
FROM {{ ref('si_webinars') }}
WHERE registrants = 0 AND attendees > 0

UNION ALL

SELECT 'Future transaction dates' as test_name, COUNT(*) as records_count
FROM {{ ref('si_billing_events') }}
WHERE transaction_date > CURRENT_DATE()

UNION ALL

SELECT 'Negative usage counts after transformation' as test_name, COUNT(*) as records_count
FROM {{ ref('si_feature_usage') }}
WHERE usage_count < 0

UNION ALL

SELECT 'Missing host names for valid host IDs' as test_name, COUNT(*) as records_count
FROM {{ ref('si_meetings') }} m
JOIN {{ ref('si_users') }} u ON m.host_id = u.user_id
WHERE m.host_name = 'Unknown Host'
```

### Parameterized Tests

```sql
-- macros/test_column_completeness.sql
{% macro test_column_completeness(model, column_name, threshold=0.95) %}
  SELECT 
    '{{ model }}' as model_name,
    '{{ column_name }}' as column_name,
    COUNT(*) as total_records,
    COUNT({{ column_name }}) as non_null_records,
    COUNT({{ column_name }}) * 1.0 / COUNT(*) as completeness_ratio,
    {{ threshold }} as threshold
  FROM {{ ref(model) }}
  HAVING completeness_ratio < {{ threshold }}
{% endmacro %}
```

```sql
-- tests/test_completeness_all_models.sql
{{ test_column_completeness('si_users', 'user_name', 0.98) }}
UNION ALL
{{ test_column_completeness('si_users', 'email', 0.95) }}
UNION ALL
{{ test_column_completeness('si_meetings', 'meeting_topic', 0.90) }}
UNION ALL
{{ test_column_completeness('si_meetings', 'host_name', 0.95) }}
UNION ALL
{{ test_column_completeness('si_participants', 'user_id', 0.99) }}
UNION ALL
{{ test_column_completeness('si_feature_usage', 'feature_name', 0.99) }}
UNION ALL
{{ test_column_completeness('si_support_tickets', 'ticket_type', 0.99) }}
UNION ALL
{{ test_column_completeness('si_billing_events', 'transaction_amount', 0.99) }}
UNION ALL
{{ test_column_completeness('si_licenses', 'license_type', 0.99) }}
UNION ALL
{{ test_column_completeness('si_webinars', 'webinar_topic', 0.90) }}
```

## Test Execution Strategy

### 1. Pre-deployment Testing
```bash
# Run all tests before deployment
dbt test --models tag:silver_layer

# Run specific test categories
dbt test --models tag:data_quality
dbt test --models tag:referential_integrity
dbt test --models tag:business_rules
```

### 2. Continuous Integration Testing
```bash
# Run tests on changed models only
dbt test --models state:modified+

# Run tests with fail-fast option
dbt test --fail-fast
```

### 3. Production Monitoring
```bash
# Schedule regular test runs
dbt test --models tag:critical_tests

# Generate test results for monitoring
dbt test --store-failures
```

## Test Results Tracking

All test results are automatically tracked in:
- **dbt's run_results.json**: Contains detailed test execution results
- **Snowflake audit schema**: Custom audit tables for test result history
- **dbt Cloud/dbt Core logs**: Comprehensive logging of test execution

## Maintenance and Updates

### Regular Test Review
- **Weekly**: Review failed tests and update thresholds
- **Monthly**: Add new test cases for edge cases discovered
- **Quarterly**: Performance review of test execution times

### Test Coverage Expansion
- Add tests for new business rules as they are identified
- Implement additional data quality checks based on data profiling
- Create custom tests for domain-specific validation rules

## Conclusion

This comprehensive test suite ensures the reliability and quality of the Zoom Silver Pipeline dbt models in Snowflake. The combination of schema tests, custom SQL tests, and parameterized tests provides thorough coverage of data transformations, business rules, edge cases, and error handling scenarios. Regular execution of these tests will help maintain data quality and catch issues early in the development cycle.