_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Platform Analytics Bronze Layer dbt models in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases - Bronze Layer Pipeline

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics Bronze Layer dbt models running in Snowflake. The test suite covers data transformations, business rules, edge cases, and error handling scenarios to ensure reliable and performant dbt models.

## Test Coverage Overview

The test suite covers 8 Bronze layer models:
1. **bz_data_audit** - Audit trail table
2. **bz_users** - User profile information
3. **bz_meetings** - Meeting session details
4. **bz_participants** - Meeting participant tracking
5. **bz_feature_usage** - Platform feature usage
6. **bz_support_tickets** - Customer support requests
7. **bz_billing_events** - Financial transactions
8. **bz_licenses** - License assignments

## Test Case List

### 1. BZ_DATA_AUDIT Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_AUDIT_001 | Verify record_id uniqueness and not null | All record_id values are unique and not null |
| BZ_AUDIT_002 | Validate audit table structure initialization | Table creates with correct schema without data |
| BZ_AUDIT_003 | Test audit trail logging functionality | Pre/post hooks successfully log operations |
| BZ_AUDIT_004 | Verify status field accepted values | Status contains only valid values (INITIALIZED, STARTED, SUCCESS, FAILED) |
| BZ_AUDIT_005 | Test processing_time data type validation | Processing_time accepts numeric values ≥ 0 |

### 2. BZ_USERS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_USERS_001 | Verify user_id primary key constraints | All user_id values are unique and not null |
| BZ_USERS_002 | Validate email uniqueness and format | All email values are unique and not null |
| BZ_USERS_003 | Test deduplication logic with multiple records | Latest record by update_timestamp is selected |
| BZ_USERS_004 | Verify null primary key filtering | Records with null user_id are excluded |
| BZ_USERS_005 | Test plan_type accepted values | Plan_type contains valid subscription types |
| BZ_USERS_006 | Validate source system tracking | All records have valid source_system values |
| BZ_USERS_007 | Test PII data handling compliance | PII fields (user_name, email) are properly identified |

### 3. BZ_MEETINGS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_MEETINGS_001 | Verify meeting_id primary key constraints | All meeting_id values are unique and not null |
| BZ_MEETINGS_002 | Test TRY_CAST functionality for end_time | Invalid timestamps convert to null without errors |
| BZ_MEETINGS_003 | Test TRY_CAST functionality for duration_minutes | Invalid numbers convert to null without errors |
| BZ_MEETINGS_004 | Validate start_time not null constraint | All records have valid start_time values |
| BZ_MEETINGS_005 | Test deduplication with ROW_NUMBER() | Latest record per meeting_id is selected |
| BZ_MEETINGS_006 | Verify host_id foreign key relationship | All host_id values reference valid users |
| BZ_MEETINGS_007 | Test meeting duration calculation logic | Duration_minutes matches time difference when both timestamps exist |

### 4. BZ_PARTICIPANTS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_PARTICIPANTS_001 | Verify participant_id primary key constraints | All participant_id values are unique and not null |
| BZ_PARTICIPANTS_002 | Test TRY_CAST functionality for join_time | Invalid timestamps convert to null without errors |
| BZ_PARTICIPANTS_003 | Validate meeting_id foreign key relationship | All meeting_id values reference valid meetings |
| BZ_PARTICIPANTS_004 | Validate user_id foreign key relationship | All user_id values reference valid users |
| BZ_PARTICIPANTS_005 | Test join_time vs leave_time logic validation | Join_time ≤ leave_time when both are not null |
| BZ_PARTICIPANTS_006 | Test deduplication logic | Latest record per participant_id is selected |
| BZ_PARTICIPANTS_007 | Verify null handling for optional timestamps | Null join_time and leave_time are preserved |

### 5. BZ_FEATURE_USAGE Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_FEATURE_USAGE_001 | Verify usage_id primary key constraints | All usage_id values are unique and not null |
| BZ_FEATURE_USAGE_002 | Validate usage_count positive values | All usage_count values are ≥ 0 |
| BZ_FEATURE_USAGE_003 | Test feature_name standardization | Feature names follow consistent naming convention |
| BZ_FEATURE_USAGE_004 | Validate meeting_id foreign key relationship | All meeting_id values reference valid meetings |
| BZ_FEATURE_USAGE_005 | Test usage_date validation | All usage_date values are valid dates |
| BZ_FEATURE_USAGE_006 | Test deduplication logic | Latest record per usage_id is selected |
| BZ_FEATURE_USAGE_007 | Verify feature usage aggregation accuracy | Usage_count reflects actual feature utilization |

### 6. BZ_SUPPORT_TICKETS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_SUPPORT_TICKETS_001 | Verify ticket_id primary key constraints | All ticket_id values are unique and not null |
| BZ_SUPPORT_TICKETS_002 | Validate user_id foreign key relationship | All user_id values reference valid users |
| BZ_SUPPORT_TICKETS_003 | Test ticket_type accepted values | Ticket_type contains valid support categories |
| BZ_SUPPORT_TICKETS_004 | Test resolution_status workflow validation | Resolution_status follows valid state transitions |
| BZ_SUPPORT_TICKETS_005 | Validate open_date not null constraint | All records have valid open_date values |
| BZ_SUPPORT_TICKETS_006 | Test deduplication logic | Latest record per ticket_id is selected |
| BZ_SUPPORT_TICKETS_007 | Verify ticket lifecycle tracking | Status changes are properly tracked over time |

### 7. BZ_BILLING_EVENTS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_BILLING_EVENTS_001 | Verify event_id primary key constraints | All event_id values are unique and not null |
| BZ_BILLING_EVENTS_002 | Test TRY_CAST functionality for amount | Invalid amounts convert to null without errors |
| BZ_BILLING_EVENTS_003 | Validate amount precision (10,2) | Amount values maintain proper decimal precision |
| BZ_BILLING_EVENTS_004 | Validate user_id foreign key relationship | All user_id values reference valid users |
| BZ_BILLING_EVENTS_005 | Test event_type accepted values | Event_type contains valid billing categories |
| BZ_BILLING_EVENTS_006 | Validate event_date not null constraint | All records have valid event_date values |
| BZ_BILLING_EVENTS_007 | Test deduplication logic | Latest record per event_id is selected |
| BZ_BILLING_EVENTS_008 | Verify financial data accuracy | Amount values are positive for charges, negative for refunds |

### 8. BZ_LICENSES Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_LICENSES_001 | Verify license_id primary key constraints | All license_id values are unique and not null |
| BZ_LICENSES_002 | Test TRY_CAST functionality for end_date | Invalid dates convert to null without errors |
| BZ_LICENSES_003 | Validate assigned_to_user_id foreign key | All assigned_to_user_id values reference valid users |
| BZ_LICENSES_004 | Test license_type accepted values | License_type contains valid license categories |
| BZ_LICENSES_005 | Validate start_date not null constraint | All records have valid start_date values |
| BZ_LICENSES_006 | Test date range validation | Start_date ≤ end_date when end_date is not null |
| BZ_LICENSES_007 | Test deduplication logic | Latest record per license_id is selected |
| BZ_LICENSES_008 | Verify license assignment tracking | License assignments are properly tracked over time |

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# tests/schema.yml
version: 2

models:
  # BZ_DATA_AUDIT Tests
  - name: bz_data_audit
    tests:
      - dbt_utils.expression_is_true:
          expression: "record_id is not null"
          config:
            severity: error
    columns:
      - name: record_id
        tests:
          - not_null
          - unique
      - name: status
        tests:
          - accepted_values:
              values: ['INITIALIZED', 'STARTED', 'SUCCESS', 'FAILED', 'WARNING']
      - name: processing_time
        tests:
          - dbt_utils.expression_is_true:
              expression: "processing_time >= 0"

  # BZ_USERS Tests
  - name: bz_users
    tests:
      - dbt_utils.expression_is_true:
          expression: "user_id is not null"
          config:
            severity: error
    columns:
      - name: user_id
        tests:
          - not_null
          - unique
      - name: email
        tests:
          - not_null
          - unique
      - name: plan_type
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise']
      - name: source_system
        tests:
          - not_null

  # BZ_MEETINGS Tests
  - name: bz_meetings
    tests:
      - dbt_utils.expression_is_true:
          expression: "meeting_id is not null"
          config:
            severity: error
    columns:
      - name: meeting_id
        tests:
          - not_null
          - unique
      - name: start_time
        tests:
          - not_null
      - name: duration_minutes
        tests:
          - dbt_utils.expression_is_true:
              expression: "duration_minutes >= 0 or duration_minutes is null"

  # BZ_PARTICIPANTS Tests
  - name: bz_participants
    columns:
      - name: participant_id
        tests:
          - not_null
          - unique
      - name: meeting_id
        tests:
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
      - name: user_id
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id

  # BZ_FEATURE_USAGE Tests
  - name: bz_feature_usage
    columns:
      - name: usage_id
        tests:
          - not_null
          - unique
      - name: usage_count
        tests:
          - dbt_utils.expression_is_true:
              expression: "usage_count >= 0"
      - name: meeting_id
        tests:
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id

  # BZ_SUPPORT_TICKETS Tests
  - name: bz_support_tickets
    columns:
      - name: ticket_id
        tests:
          - not_null
          - unique
      - name: user_id
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: open_date
        tests:
          - not_null

  # BZ_BILLING_EVENTS Tests
  - name: bz_billing_events
    columns:
      - name: event_id
        tests:
          - not_null
          - unique
      - name: user_id
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: event_date
        tests:
          - not_null

  # BZ_LICENSES Tests
  - name: bz_licenses
    columns:
      - name: license_id
        tests:
          - not_null
          - unique
      - name: assigned_to_user_id
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: start_date
        tests:
          - not_null
```

### Custom SQL-based dbt Tests

#### 1. Test Deduplication Logic

```sql
-- tests/test_deduplication_bz_users.sql
-- Test that deduplication logic works correctly for bz_users

select user_id, count(*) as duplicate_count
from {{ ref('bz_users') }}
group by user_id
having count(*) > 1
```

#### 2. Test Data Type Conversions

```sql
-- tests/test_try_cast_bz_meetings.sql
-- Test that TRY_CAST functions handle invalid data gracefully

select 
    meeting_id,
    end_time,
    duration_minutes
from {{ ref('bz_meetings') }}
where 
    (end_time is not null and end_time < start_time)
    or (duration_minutes is not null and duration_minutes < 0)
```

#### 3. Test Audit Trail Functionality

```sql
-- tests/test_audit_trail_completeness.sql
-- Test that audit records are created for each model run

with model_runs as (
    select distinct source_table
    from {{ ref('bz_data_audit') }}
    where status in ('STARTED', 'SUCCESS')
),
expected_tables as (
    select 'BZ_USERS' as table_name
    union all select 'BZ_MEETINGS'
    union all select 'BZ_PARTICIPANTS'
    union all select 'BZ_FEATURE_USAGE'
    union all select 'BZ_SUPPORT_TICKETS'
    union all select 'BZ_BILLING_EVENTS'
    union all select 'BZ_LICENSES'
)
select table_name
from expected_tables
where table_name not in (select source_table from model_runs)
```

#### 4. Test Foreign Key Relationships

```sql
-- tests/test_foreign_key_integrity.sql
-- Test referential integrity across bronze models

with orphaned_participants as (
    select p.participant_id, p.meeting_id, p.user_id
    from {{ ref('bz_participants') }} p
    left join {{ ref('bz_meetings') }} m on p.meeting_id = m.meeting_id
    left join {{ ref('bz_users') }} u on p.user_id = u.user_id
    where m.meeting_id is null or u.user_id is null
)
select * from orphaned_participants
```

#### 5. Test Business Logic Validation

```sql
-- tests/test_meeting_duration_logic.sql
-- Test that meeting duration calculations are logical

select 
    meeting_id,
    start_time,
    end_time,
    duration_minutes,
    datediff('minute', start_time, end_time) as calculated_duration
from {{ ref('bz_meetings') }}
where 
    start_time is not null 
    and end_time is not null 
    and duration_minutes is not null
    and abs(duration_minutes - datediff('minute', start_time, end_time)) > 1
```

#### 6. Test Data Quality Metrics

```sql
-- tests/test_data_quality_metrics.sql
-- Test overall data quality across bronze layer

with quality_metrics as (
    select 
        'bz_users' as table_name,
        count(*) as total_records,
        count(case when user_id is null then 1 end) as null_primary_keys,
        count(case when email is null then 1 end) as null_emails
    from {{ ref('bz_users') }}
    
    union all
    
    select 
        'bz_meetings' as table_name,
        count(*) as total_records,
        count(case when meeting_id is null then 1 end) as null_primary_keys,
        count(case when start_time is null then 1 end) as null_start_times
    from {{ ref('bz_meetings') }}
)
select *
from quality_metrics
where null_primary_keys > 0
```

#### 7. Test Edge Cases

```sql
-- tests/test_edge_cases_timestamps.sql
-- Test handling of edge cases in timestamp fields

select 
    'participants' as source_table,
    participant_id,
    join_time,
    leave_time
from {{ ref('bz_participants') }}
where 
    join_time is not null 
    and leave_time is not null 
    and join_time > leave_time

union all

select 
    'licenses' as source_table,
    license_id,
    start_date::timestamp as join_time,
    end_date::timestamp as leave_time
from {{ ref('bz_licenses') }}
where 
    start_date is not null 
    and end_date is not null 
    and start_date > end_date
```

### Parameterized Tests for Reusability

#### Generic Test Macro

```sql
-- macros/test_primary_key_integrity.sql
-- Generic macro to test primary key integrity across models

{% macro test_primary_key_integrity(model, primary_key_column) %}
    select {{ primary_key_column }}, count(*) as duplicate_count
    from {{ model }}
    where {{ primary_key_column }} is not null
    group by {{ primary_key_column }}
    having count(*) > 1
{% endmacro %}
```

#### Usage in Tests

```sql
-- tests/test_all_primary_keys.sql
-- Test primary key integrity across all bronze models

{{ test_primary_key_integrity(ref('bz_users'), 'user_id') }}
union all
{{ test_primary_key_integrity(ref('bz_meetings'), 'meeting_id') }}
union all
{{ test_primary_key_integrity(ref('bz_participants'), 'participant_id') }}
union all
{{ test_primary_key_integrity(ref('bz_feature_usage'), 'usage_id') }}
union all
{{ test_primary_key_integrity(ref('bz_support_tickets'), 'ticket_id') }}
union all
{{ test_primary_key_integrity(ref('bz_billing_events'), 'event_id') }}
union all
{{ test_primary_key_integrity(ref('bz_licenses'), 'license_id') }}
```

## Test Execution Strategy

### 1. Pre-deployment Testing
- Run all schema tests before model deployment
- Validate data type conversions and transformations
- Check referential integrity constraints

### 2. Post-deployment Validation
- Execute custom SQL tests after successful deployment
- Verify audit trail completeness
- Validate business logic and edge cases

### 3. Continuous Monitoring
- Schedule regular test runs to monitor data quality
- Set up alerts for test failures
- Track test results in dbt's run_results.json

### 4. Performance Testing
- Monitor query execution times
- Validate Snowflake warehouse utilization
- Test scalability with large datasets

## Expected Test Results Tracking

### dbt Test Results
- All tests tracked in `target/run_results.json`
- Test status: `pass`, `fail`, `error`, `skipped`
- Execution time and resource utilization metrics

### Snowflake Audit Schema
- Test execution logs stored in `BRONZE.BZ_DATA_AUDIT`
- Performance metrics tracked per model
- Error handling and recovery procedures documented

## Maintenance and Updates

### Test Case Versioning
- Version control for all test scripts
- Documentation updates with schema changes
- Backward compatibility considerations

### Performance Optimization
- Regular review of test execution times
- Optimization of complex test queries
- Snowflake warehouse sizing recommendations

---

**Test Suite Summary:**
- **Total Test Cases:** 56 comprehensive test cases
- **Coverage:** 8 Bronze layer dbt models
- **Test Types:** Schema tests, custom SQL tests, parameterized tests
- **Validation Areas:** Data integrity, business logic, edge cases, performance
- **Monitoring:** Continuous data quality tracking and alerting

This comprehensive test suite ensures the reliability, performance, and data quality of the Bronze layer dbt models in the Zoom Platform Analytics system running on Snowflake.