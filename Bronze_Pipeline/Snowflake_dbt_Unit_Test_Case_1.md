_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Platform Analytics Bronze layer dbt models in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases - Zoom Platform Analytics Bronze Layer

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics Bronze layer dbt models running in Snowflake. The test suite covers data transformations, business rules, edge cases, and error handling scenarios to ensure reliable and performant data pipelines.

## Test Coverage Overview

The test suite covers 8 Bronze layer models:
- `bz_audit_log` - Audit logging functionality
- `bz_users` - User account data
- `bz_meetings` - Meeting information
- `bz_participants` - Meeting participants
- `bz_feature_usage` - Feature usage tracking
- `bz_support_tickets` - Support ticket data
- `bz_billing_events` - Billing event information
- `bz_licenses` - License management data

## Test Case Categories

### 1. Data Integrity Tests
### 2. Schema Validation Tests
### 3. Business Rule Tests
### 4. Edge Case Tests
### 5. Performance Tests
### 6. Error Handling Tests

---

## Test Case List

| Test Case ID | Model | Test Case Description | Expected Outcome | Test Type |
|--------------|-------|----------------------|------------------|----------|
| TC_BZ_001 | bz_audit_log | Verify audit log table structure creation | Table created with correct schema | Schema Validation |
| TC_BZ_002 | bz_audit_log | Test audit log record insertion | Records inserted successfully | Data Integrity |
| TC_BZ_003 | bz_users | Validate 1:1 mapping from RAW.USERS | All source records mapped correctly | Data Integrity |
| TC_BZ_004 | bz_users | Test data type casting for user fields | All fields cast to correct Snowflake types | Schema Validation |
| TC_BZ_005 | bz_users | Validate email uniqueness constraint | Duplicate emails identified | Business Rule |
| TC_BZ_006 | bz_users | Test null handling in optional fields | Null values preserved correctly | Edge Case |
| TC_BZ_007 | bz_users | Validate plan_type domain values | Only valid plan types accepted | Business Rule |
| TC_BZ_008 | bz_meetings | Validate meeting duration calculation | Duration matches start/end time difference | Business Rule |
| TC_BZ_009 | bz_meetings | Test null handling for optional meeting topic | Null topics handled correctly | Edge Case |
| TC_BZ_010 | bz_meetings | Validate timestamp format consistency | All timestamps in TIMESTAMP_NTZ format | Schema Validation |
| TC_BZ_011 | bz_participants | Test participant-meeting relationship | All participants linked to valid meetings | Data Integrity |
| TC_BZ_012 | bz_participants | Validate join/leave time logic | Join time always before leave time | Business Rule |
| TC_BZ_013 | bz_participants | Test null leave_time handling | Ongoing meetings have null leave_time | Edge Case |
| TC_BZ_014 | bz_feature_usage | Validate feature name domain values | Only valid feature names accepted | Business Rule |
| TC_BZ_015 | bz_feature_usage | Test usage count validation | Usage count is non-negative integer | Business Rule |
| TC_BZ_016 | bz_feature_usage | Validate date format consistency | All dates in DATE format | Schema Validation |
| TC_BZ_017 | bz_support_tickets | Test ticket status domain validation | Only valid status values accepted | Business Rule |
| TC_BZ_018 | bz_support_tickets | Validate ticket type categories | Only valid ticket types accepted | Business Rule |
| TC_BZ_019 | bz_support_tickets | Test open date validation | Open date not in future | Business Rule |
| TC_BZ_020 | bz_billing_events | Validate monetary amount precision | Amounts stored with 2 decimal precision | Schema Validation |
| TC_BZ_021 | bz_billing_events | Test event type validation | Only valid event types accepted | Business Rule |
| TC_BZ_022 | bz_billing_events | Validate negative amount handling | Refunds can have negative amounts | Business Rule |
| TC_BZ_023 | bz_licenses | Test license type validation | Only valid license types accepted | Business Rule |
| TC_BZ_024 | bz_licenses | Validate date range logic | Start date before end date | Business Rule |
| TC_BZ_025 | bz_licenses | Test null end date handling | Perpetual licenses have null end date | Edge Case |
| TC_BZ_026 | All Models | Test source system tracking | All records have valid source system | Data Integrity |
| TC_BZ_027 | All Models | Validate load timestamp consistency | Load timestamps are not null | Data Integrity |
| TC_BZ_028 | All Models | Test incremental loading | Only new/updated records processed | Performance |
| TC_BZ_029 | All Models | Validate error handling | Failed records logged appropriately | Error Handling |
| TC_BZ_030 | All Models | Test large dataset performance | Models handle large volumes efficiently | Performance |

---

## dbt Test Scripts

### Schema Tests (schema.yml)

```yaml
version: 2

models:
  # BZ_AUDIT_LOG Tests
  - name: bz_audit_log
    description: "Bronze layer audit log for tracking data processing activities"
    tests:
      - dbt_utils.expression_is_true:
          expression: "record_id is not null"
          config:
            severity: error
    columns:
      - name: record_id
        description: "Auto-incrementing unique identifier"
        tests:
          - not_null
          - unique
      - name: source_table
        description: "Name of the source table being processed"
        tests:
          - not_null
      - name: load_timestamp
        description: "Timestamp when processing started"
        tests:
          - not_null
      - name: status
        description: "Status of the processing operation"
        tests:
          - not_null
          - accepted_values:
              values: ['COMPLETED', 'FAILED', 'IN_PROGRESS', 'PENDING']

  # BZ_USERS Tests
  - name: bz_users
    description: "Bronze layer users table with raw data from source"
    tests:
      - dbt_utils.expression_is_true:
          expression: "user_id is not null"
          config:
            severity: error
      - dbt_utils.row_count:
          above: 0
    columns:
      - name: user_id
        description: "Unique identifier for each user account"
        tests:
          - not_null
          - unique
      - name: user_name
        description: "Display name of the user"
        tests:
          - not_null
      - name: email
        description: "Email address of the user account"
        tests:
          - not_null
          - unique
      - name: plan_type
        description: "Subscription plan type for the user"
        tests:
          - not_null
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise', 'Education']
      - name: load_timestamp
        description: "Timestamp when record was loaded"
        tests:
          - not_null
      - name: source_system
        description: "Source system identifier"
        tests:
          - not_null
          - accepted_values:
              values: ['Zoom_API', 'User_Management_System', 'Registration_Portal']

  # BZ_MEETINGS Tests
  - name: bz_meetings
    description: "Bronze layer meetings table with raw data from source"
    tests:
      - dbt_utils.expression_is_true:
          expression: "meeting_id is not null"
          config:
            severity: error
    columns:
      - name: meeting_id
        description: "Unique identifier for each meeting session"
        tests:
          - not_null
          - unique
      - name: host_id
        description: "User ID of the meeting host"
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: start_time
        description: "Timestamp when meeting started"
        tests:
          - not_null
      - name: duration_minutes
        description: "Meeting duration in minutes"
        tests:
          - dbt_utils.expression_is_true:
              expression: "duration_minutes >= 0 OR duration_minutes IS NULL"
      - name: load_timestamp
        description: "Timestamp when record was loaded"
        tests:
          - not_null
      - name: source_system
        description: "Source system identifier"
        tests:
          - not_null
          - accepted_values:
              values: ['Zoom_API', 'Meeting_Dashboard']

  # BZ_PARTICIPANTS Tests
  - name: bz_participants
    description: "Bronze layer participants table with raw data from source"
    tests:
      - dbt_utils.expression_is_true:
          expression: "participant_id is not null"
          config:
            severity: error
    columns:
      - name: participant_id
        description: "Unique identifier for each participant session"
        tests:
          - not_null
          - unique
      - name: meeting_id
        description: "Meeting identifier"
        tests:
          - not_null
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
      - name: user_id
        description: "User identifier"
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: join_time
        description: "Participant join time"
        tests:
          - not_null
      - name: load_timestamp
        description: "Timestamp when record was loaded"
        tests:
          - not_null
      - name: source_system
        description: "Source system identifier"
        tests:
          - not_null
          - accepted_values:
              values: ['Zoom_API', 'Participant_Tracking_System']

  # BZ_FEATURE_USAGE Tests
  - name: bz_feature_usage
    description: "Bronze layer feature usage table with raw data from source"
    tests:
      - dbt_utils.expression_is_true:
          expression: "usage_id is not null"
          config:
            severity: error
    columns:
      - name: usage_id
        description: "Unique identifier for each feature usage record"
        tests:
          - not_null
          - unique
      - name: meeting_id
        description: "Meeting identifier"
        tests:
          - not_null
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
      - name: feature_name
        description: "Name of the Zoom feature used"
        tests:
          - not_null
          - accepted_values:
              values: ['screen_share', 'recording', 'chat', 'breakout_rooms', 'whiteboard']
      - name: usage_count
        description: "Number of times feature was used"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "usage_count >= 0"
      - name: usage_date
        description: "Date when feature usage occurred"
        tests:
          - not_null
      - name: load_timestamp
        description: "Timestamp when record was loaded"
        tests:
          - not_null
      - name: source_system
        description: "Source system identifier"
        tests:
          - not_null
          - accepted_values:
              values: ['Zoom_API', 'Analytics_System']

  # BZ_SUPPORT_TICKETS Tests
  - name: bz_support_tickets
    description: "Bronze layer support tickets table with raw data from source"
    tests:
      - dbt_utils.expression_is_true:
          expression: "ticket_id is not null"
          config:
            severity: error
    columns:
      - name: ticket_id
        description: "Unique identifier for each support ticket"
        tests:
          - not_null
          - unique
      - name: user_id
        description: "User who created the ticket"
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: ticket_type
        description: "Category of the support ticket"
        tests:
          - not_null
          - accepted_values:
              values: ['technical_issue', 'billing_inquiry', 'feature_request', 'account_access']
      - name: resolution_status
        description: "Current status of ticket resolution"
        tests:
          - not_null
          - accepted_values:
              values: ['open', 'in_progress', 'resolved', 'closed', 'escalated']
      - name: open_date
        description: "Date when ticket was created"
        tests:
          - not_null
      - name: load_timestamp
        description: "Timestamp when record was loaded"
        tests:
          - not_null
      - name: source_system
        description: "Source system identifier"
        tests:
          - not_null
          - accepted_values:
              values: ['Support_Portal', 'CRM_System', 'Email_Integration']

  # BZ_BILLING_EVENTS Tests
  - name: bz_billing_events
    description: "Bronze layer billing events table with raw data from source"
    tests:
      - dbt_utils.expression_is_true:
          expression: "event_id is not null"
          config:
            severity: error
    columns:
      - name: event_id
        description: "Unique identifier for each billing event"
        tests:
          - not_null
          - unique
      - name: user_id
        description: "User associated with billing event"
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: event_type
        description: "Type of billing event"
        tests:
          - not_null
          - accepted_values:
              values: ['charge', 'credit', 'refund', 'adjustment']
      - name: amount
        description: "Monetary amount of the billing event"
        tests:
          - not_null
      - name: event_date
        description: "Date when billing event occurred"
        tests:
          - not_null
      - name: load_timestamp
        description: "Timestamp when record was loaded"
        tests:
          - not_null
      - name: source_system
        description: "Source system identifier"
        tests:
          - not_null
          - accepted_values:
              values: ['Zoom_API', 'Billing_System', 'Manual_Entry']

  # BZ_LICENSES Tests
  - name: bz_licenses
    description: "Bronze layer licenses table with raw data from source"
    tests:
      - dbt_utils.expression_is_true:
          expression: "license_id is not null"
          config:
            severity: error
    columns:
      - name: license_id
        description: "Unique identifier for each license"
        tests:
          - not_null
          - unique
      - name: license_type
        description: "Type of Zoom license"
        tests:
          - not_null
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise', 'Education']
      - name: assigned_to_user_id
        description: "User ID to whom license is assigned"
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: start_date
        description: "License activation date"
        tests:
          - not_null
      - name: load_timestamp
        description: "Timestamp when record was loaded"
        tests:
          - not_null
      - name: source_system
        description: "Source system identifier"
        tests:
          - not_null
          - accepted_values:
              values: ['Zoom_Admin_API', 'License_Management_System']
```

### Custom SQL-based dbt Tests

#### Test 1: Validate Meeting Duration Logic
```sql
-- tests/test_meeting_duration_logic.sql
-- Test that calculated duration matches the difference between start and end times

SELECT 
    meeting_id,
    start_time,
    end_time,
    duration_minutes,
    DATEDIFF('minute', start_time, end_time) AS calculated_duration
FROM {{ ref('bz_meetings') }}
WHERE 
    end_time IS NOT NULL 
    AND start_time IS NOT NULL
    AND duration_minutes IS NOT NULL
    AND ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) > 1
```

#### Test 2: Validate Participant Join/Leave Time Logic
```sql
-- tests/test_participant_time_logic.sql
-- Test that join time is always before leave time

SELECT 
    participant_id,
    meeting_id,
    join_time,
    leave_time
FROM {{ ref('bz_participants') }}
WHERE 
    leave_time IS NOT NULL 
    AND join_time IS NOT NULL
    AND join_time >= leave_time
```

#### Test 3: Validate License Date Range Logic
```sql
-- tests/test_license_date_range.sql
-- Test that start date is before end date for licenses

SELECT 
    license_id,
    start_date,
    end_date
FROM {{ ref('bz_licenses') }}
WHERE 
    end_date IS NOT NULL 
    AND start_date IS NOT NULL
    AND start_date >= end_date
```

#### Test 4: Validate Data Freshness
```sql
-- tests/test_data_freshness.sql
-- Test that data is loaded within acceptable timeframe

SELECT 
    source_table,
    COUNT(*) as record_count,
    MAX(load_timestamp) as latest_load
FROM (
    SELECT 'bz_users' as source_table, load_timestamp FROM {{ ref('bz_users') }}
    UNION ALL
    SELECT 'bz_meetings' as source_table, load_timestamp FROM {{ ref('bz_meetings') }}
    UNION ALL
    SELECT 'bz_participants' as source_table, load_timestamp FROM {{ ref('bz_participants') }}
    UNION ALL
    SELECT 'bz_feature_usage' as source_table, load_timestamp FROM {{ ref('bz_feature_usage') }}
    UNION ALL
    SELECT 'bz_support_tickets' as source_table, load_timestamp FROM {{ ref('bz_support_tickets') }}
    UNION ALL
    SELECT 'bz_billing_events' as source_table, load_timestamp FROM {{ ref('bz_billing_events') }}
    UNION ALL
    SELECT 'bz_licenses' as source_table, load_timestamp FROM {{ ref('bz_licenses') }}
)
GROUP BY source_table
HAVING MAX(load_timestamp) < DATEADD('hour', -24, CURRENT_TIMESTAMP())
```

#### Test 5: Validate Source System Consistency
```sql
-- tests/test_source_system_consistency.sql
-- Test that all records have valid source system values

SELECT 
    'bz_users' as table_name,
    source_system,
    COUNT(*) as record_count
FROM {{ ref('bz_users') }}
WHERE source_system NOT IN ('Zoom_API', 'User_Management_System', 'Registration_Portal')
GROUP BY source_system

UNION ALL

SELECT 
    'bz_meetings' as table_name,
    source_system,
    COUNT(*) as record_count
FROM {{ ref('bz_meetings') }}
WHERE source_system NOT IN ('Zoom_API', 'Meeting_Dashboard')
GROUP BY source_system

UNION ALL

SELECT 
    'bz_participants' as table_name,
    source_system,
    COUNT(*) as record_count
FROM {{ ref('bz_participants') }}
WHERE source_system NOT IN ('Zoom_API', 'Participant_Tracking_System')
GROUP BY source_system

UNION ALL

SELECT 
    'bz_feature_usage' as table_name,
    source_system,
    COUNT(*) as record_count
FROM {{ ref('bz_feature_usage') }}
WHERE source_system NOT IN ('Zoom_API', 'Analytics_System')
GROUP BY source_system

UNION ALL

SELECT 
    'bz_support_tickets' as table_name,
    source_system,
    COUNT(*) as record_count
FROM {{ ref('bz_support_tickets') }}
WHERE source_system NOT IN ('Support_Portal', 'CRM_System', 'Email_Integration')
GROUP BY source_system

UNION ALL

SELECT 
    'bz_billing_events' as table_name,
    source_system,
    COUNT(*) as record_count
FROM {{ ref('bz_billing_events') }}
WHERE source_system NOT IN ('Zoom_API', 'Billing_System', 'Manual_Entry')
GROUP BY source_system

UNION ALL

SELECT 
    'bz_licenses' as table_name,
    source_system,
    COUNT(*) as record_count
FROM {{ ref('bz_licenses') }}
WHERE source_system NOT IN ('Zoom_Admin_API', 'License_Management_System')
GROUP BY source_system
```

#### Test 6: Validate Referential Integrity
```sql
-- tests/test_referential_integrity.sql
-- Test referential integrity across Bronze layer tables

-- Check participants reference valid meetings
SELECT 
    'participants_invalid_meeting' as test_case,
    COUNT(*) as violation_count
FROM {{ ref('bz_participants') }} p
LEFT JOIN {{ ref('bz_meetings') }} m ON p.meeting_id = m.meeting_id
WHERE m.meeting_id IS NULL

UNION ALL

-- Check participants reference valid users
SELECT 
    'participants_invalid_user' as test_case,
    COUNT(*) as violation_count
FROM {{ ref('bz_participants') }} p
LEFT JOIN {{ ref('bz_users') }} u ON p.user_id = u.user_id
WHERE u.user_id IS NULL

UNION ALL

-- Check meetings reference valid hosts
SELECT 
    'meetings_invalid_host' as test_case,
    COUNT(*) as violation_count
FROM {{ ref('bz_meetings') }} m
LEFT JOIN {{ ref('bz_users') }} u ON m.host_id = u.user_id
WHERE u.user_id IS NULL

UNION ALL

-- Check feature usage references valid meetings
SELECT 
    'feature_usage_invalid_meeting' as test_case,
    COUNT(*) as violation_count
FROM {{ ref('bz_feature_usage') }} f
LEFT JOIN {{ ref('bz_meetings') }} m ON f.meeting_id = m.meeting_id
WHERE m.meeting_id IS NULL

UNION ALL

-- Check support tickets reference valid users
SELECT 
    'support_tickets_invalid_user' as test_case,
    COUNT(*) as violation_count
FROM {{ ref('bz_support_tickets') }} s
LEFT JOIN {{ ref('bz_users') }} u ON s.user_id = u.user_id
WHERE u.user_id IS NULL

UNION ALL

-- Check billing events reference valid users
SELECT 
    'billing_events_invalid_user' as test_case,
    COUNT(*) as violation_count
FROM {{ ref('bz_billing_events') }} b
LEFT JOIN {{ ref('bz_users') }} u ON b.user_id = u.user_id
WHERE u.user_id IS NULL

UNION ALL

-- Check licenses reference valid users
SELECT 
    'licenses_invalid_user' as test_case,
    COUNT(*) as violation_count
FROM {{ ref('bz_licenses') }} l
LEFT JOIN {{ ref('bz_users') }} u ON l.assigned_to_user_id = u.user_id
WHERE u.user_id IS NULL
```

### Parameterized Tests

#### Test 7: Data Quality Metrics Test
```sql
-- tests/test_data_quality_metrics.sql
-- Parameterized test for data quality metrics across all tables

{% set tables = [
    'bz_users',
    'bz_meetings', 
    'bz_participants',
    'bz_feature_usage',
    'bz_support_tickets',
    'bz_billing_events',
    'bz_licenses'
] %}

{% for table in tables %}
SELECT 
    '{{ table }}' as table_name,
    'null_load_timestamp' as quality_check,
    COUNT(*) as violation_count
FROM {{ ref(table) }}
WHERE load_timestamp IS NULL

{% if not loop.last %}
UNION ALL
{% endif %}

{% endfor %}
```

#### Test 8: Row Count Validation
```sql
-- tests/test_row_count_validation.sql
-- Validate that Bronze tables have expected row counts compared to source

{% set source_tables = [
    ('users', 'bz_users'),
    ('meetings', 'bz_meetings'),
    ('participants', 'bz_participants'),
    ('feature_usage', 'bz_feature_usage'),
    ('support_tickets', 'bz_support_tickets'),
    ('billing_events', 'bz_billing_events'),
    ('licenses', 'bz_licenses')
] %}

{% for source_table, bronze_table in source_tables %}
SELECT 
    '{{ bronze_table }}' as table_name,
    (
        SELECT COUNT(*) FROM {{ source('raw_zoom_data', source_table) }}
    ) as source_count,
    (
        SELECT COUNT(*) FROM {{ ref(bronze_table) }}
    ) as bronze_count,
    ABS(
        (SELECT COUNT(*) FROM {{ source('raw_zoom_data', source_table) }}) - 
        (SELECT COUNT(*) FROM {{ ref(bronze_table) }})
    ) as count_difference

{% if not loop.last %}
UNION ALL
{% endif %}

{% endfor %}
```

## Test Execution Strategy

### 1. Pre-deployment Tests
- Schema validation tests
- Basic data integrity tests
- Referential integrity tests

### 2. Post-deployment Tests
- Data quality metrics
- Performance benchmarks
- Row count validation

### 3. Continuous Monitoring Tests
- Data freshness checks
- Source system consistency
- Business rule validation

## Test Configuration

### dbt_project.yml Test Configuration
```yaml
tests:
  zoom_bronze_pipeline:
    +store_failures: true
    +schema: 'test_results'
    +severity: 'warn'
    
    # Critical tests that should fail the build
    critical:
      +severity: 'error'
      
    # Performance tests with custom thresholds
    performance:
      +severity: 'warn'
      +limit: 1000
```

### Test Execution Commands

```bash
# Run all tests
dbt test

# Run tests for specific model
dbt test --select bz_users

# Run only schema tests
dbt test --select test_type:schema

# Run only custom SQL tests
dbt test --select test_type:data

# Run tests with specific tag
dbt test --select tag:critical

# Store test failures for analysis
dbt test --store-failures
```

## Expected Test Results

### Success Criteria
- All schema validation tests pass
- Data integrity tests show 100% success rate
- Business rule violations are within acceptable thresholds (<1%)
- Performance tests complete within SLA (< 5 minutes for full test suite)
- No critical referential integrity violations

### Failure Handling
- Critical test failures stop the deployment
- Warning-level failures are logged but don't block deployment
- All test failures are stored in test_results schema for analysis
- Automated alerts sent for critical test failures

## Monitoring and Alerting

### Key Metrics to Track
- Test execution time trends
- Test failure rates by category
- Data quality score trends
- Model performance metrics

### Alert Conditions
- Any critical test failure
- Data quality score below 95%
- Test execution time exceeds SLA
- Referential integrity violations detected

## Maintenance and Updates

### Regular Review Schedule
- Weekly review of test results and trends
- Monthly review of test coverage and effectiveness
- Quarterly review of test thresholds and SLAs
- Annual comprehensive test suite audit

### Test Evolution
- Add new tests for new business rules
- Update domain value lists as business evolves
- Enhance performance tests based on data growth
- Refine thresholds based on historical performance

---

**Test Suite Summary:**
- **Total Test Cases:** 30
- **Schema Tests:** 8 models with comprehensive column-level tests
- **Custom SQL Tests:** 8 specialized validation tests
- **Coverage:** 100% of Bronze layer models
- **Automation:** Fully integrated with dbt test framework
- **Monitoring:** Comprehensive metrics and alerting

This test suite ensures the reliability, performance, and data quality of the Zoom Platform Analytics Bronze layer dbt models in Snowflake, providing comprehensive coverage of all critical data pipeline components.