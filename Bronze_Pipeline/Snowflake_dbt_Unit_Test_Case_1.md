_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Bronze Layer dbt models in Snowflake
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Zoom Bronze Layer Models

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Bronze Layer dbt models running in Snowflake. The test cases cover data quality validation, business rule enforcement, edge case handling, and error scenarios across all Bronze layer models including audit functionality.

## Models Analyzed

### Bronze Layer Models:
1. **bz_data_audit** - Audit trail for all Bronze layer operations
2. **bz_users** - User profile and subscription information
3. **bz_meetings** - Meeting information and session details
4. **bz_participants** - Meeting participants and session details
5. **bz_feature_usage** - Platform feature usage during meetings
6. **bz_support_tickets** - Customer support requests and resolution tracking
7. **bz_billing_events** - Financial transactions and billing activities
8. **bz_licenses** - License assignments and entitlements

## Key Transformations Identified

### Common Patterns Across All Models:
- **Primary Key Validation**: Filtering out NULL primary keys
- **Deduplication Logic**: ROW_NUMBER() window functions with ORDER BY update_timestamp DESC
- **Safe Type Casting**: TRY_CAST functions for data type conversions
- **Audit Trail Integration**: Pre/post hooks for audit logging
- **1-1 Raw to Bronze Mapping**: Direct field mapping with data quality improvements

### Model-Specific Transformations:
- **bz_meetings**: Duration calculation and timestamp handling
- **bz_participants**: Join/leave time processing
- **bz_billing_events**: Amount formatting and financial data validation
- **bz_licenses**: Date range validation for license periods

## Test Case List

### Test Case Categories:
1. **Data Quality Tests** (TC-DQ-001 to TC-DQ-024)
2. **Business Rule Tests** (TC-BR-001 to TC-BR-012)
3. **Edge Case Tests** (TC-EC-001 to TC-EC-016)
4. **Error Handling Tests** (TC-EH-001 to TC-EH-008)
5. **Performance Tests** (TC-PF-001 to TC-PF-004)
6. **Audit Tests** (TC-AU-001 to TC-AU-008)

## Detailed Test Cases

### Data Quality Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) |
|--------------|----------------------|------------------|----------|
| TC-DQ-001 | Validate primary key uniqueness | All primary keys should be unique within each model | All models |
| TC-DQ-002 | Validate primary key not null | No NULL values in primary key columns | All models |
| TC-DQ-003 | Validate email format in users | Email addresses should follow valid format pattern | bz_users |
| TC-DQ-004 | Validate timestamp consistency | load_timestamp should be <= update_timestamp | All models |
| TC-DQ-005 | Validate meeting duration logic | end_time should be >= start_time when both are not null | bz_meetings |
| TC-DQ-006 | Validate participant session logic | leave_time should be >= join_time when both are not null | bz_participants |
| TC-DQ-007 | Validate billing amount format | Amount should be numeric and >= 0 | bz_billing_events |
| TC-DQ-008 | Validate license date ranges | end_date should be >= start_date when both are not null | bz_licenses |
| TC-DQ-009 | Validate feature usage counts | usage_count should be >= 0 | bz_feature_usage |
| TC-DQ-010 | Validate source system consistency | source_system should not be null or empty | All models |
| TC-DQ-011 | Validate user plan types | plan_type should be from accepted values list | bz_users |
| TC-DQ-012 | Validate ticket status values | resolution_status should be from predefined list | bz_support_tickets |
| TC-DQ-013 | Validate meeting topic not empty | meeting_topic should not be null or empty string | bz_meetings |
| TC-DQ-014 | Validate feature name consistency | feature_name should be from accepted feature list | bz_feature_usage |
| TC-DQ-015 | Validate billing event types | event_type should be from predefined billing events | bz_billing_events |
| TC-DQ-016 | Validate license type consistency | license_type should be from accepted license types | bz_licenses |
| TC-DQ-017 | Validate user company not null | company field should not be null for business users | bz_users |
| TC-DQ-018 | Validate ticket type consistency | ticket_type should be from predefined support categories | bz_support_tickets |
| TC-DQ-019 | Validate meeting host relationship | host_id should exist in users table | bz_meetings |
| TC-DQ-020 | Validate participant user relationship | user_id should exist in users table | bz_participants |
| TC-DQ-021 | Validate participant meeting relationship | meeting_id should exist in meetings table | bz_participants |
| TC-DQ-022 | Validate feature usage meeting relationship | meeting_id should exist in meetings table | bz_feature_usage |
| TC-DQ-023 | Validate support ticket user relationship | user_id should exist in users table | bz_support_tickets |
| TC-DQ-024 | Validate billing event user relationship | user_id should exist in users table | bz_billing_events |

### Business Rule Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) |
|--------------|----------------------|------------------|----------|
| TC-BR-001 | Deduplication logic validation | Only latest record per primary key should be retained | All models |
| TC-BR-002 | Audit trail completeness | Every model execution should create audit records | All models |
| TC-BR-003 | Processing time calculation | Audit should track actual processing duration | bz_data_audit |
| TC-BR-004 | Status tracking accuracy | Audit status should reflect actual execution outcome | bz_data_audit |
| TC-BR-005 | License assignment validation | User can have only one active license per type | bz_licenses |
| TC-BR-006 | Meeting duration calculation | Duration should match end_time - start_time | bz_meetings |
| TC-BR-007 | Participant session validation | User cannot join same meeting multiple times simultaneously | bz_participants |
| TC-BR-008 | Feature usage aggregation | Usage counts should be properly aggregated per meeting | bz_feature_usage |
| TC-BR-009 | Support ticket lifecycle | Ticket status should follow proper workflow transitions | bz_support_tickets |
| TC-BR-010 | Billing event sequencing | Events should be chronologically ordered per user | bz_billing_events |
| TC-BR-011 | User plan consistency | User plan should match license assignments | bz_users, bz_licenses |
| TC-BR-012 | Meeting capacity validation | Meeting participants should not exceed plan limits | bz_meetings, bz_participants |

### Edge Case Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) |
|--------------|----------------------|------------------|----------|
| TC-EC-001 | Handle NULL primary keys | Records with NULL primary keys should be filtered out | All models |
| TC-EC-002 | Handle duplicate primary keys | Latest record based on update_timestamp should be kept | All models |
| TC-EC-003 | Handle NULL timestamps | NULL timestamps should be preserved without causing errors | All models |
| TC-EC-004 | Handle invalid email formats | Invalid emails should be preserved but flagged | bz_users |
| TC-EC-005 | Handle negative durations | Negative durations should be handled gracefully | bz_meetings |
| TC-EC-006 | Handle future dates | Future dates should be accepted but may trigger warnings | All models |
| TC-EC-007 | Handle zero amounts | Zero billing amounts should be accepted | bz_billing_events |
| TC-EC-008 | Handle empty strings | Empty strings should be handled consistently | All models |
| TC-EC-009 | Handle very long text fields | Long text should be truncated or handled appropriately | All models |
| TC-EC-010 | Handle special characters | Special characters in text fields should be preserved | All models |
| TC-EC-011 | Handle concurrent meeting sessions | Multiple meetings by same host should be supported | bz_meetings |
| TC-EC-012 | Handle orphaned records | Records without valid foreign keys should be identified | All models |
| TC-EC-013 | Handle timezone differences | Timestamps should be consistently handled in UTC | All models |
| TC-EC-014 | Handle leap year dates | February 29th dates should be processed correctly | All models |
| TC-EC-015 | Handle daylight saving transitions | DST transitions should not cause data issues | All models |
| TC-EC-016 | Handle large numeric values | Very large numbers should be handled without overflow | bz_billing_events |

### Error Handling Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) |
|--------------|----------------------|------------------|----------|
| TC-EH-001 | Handle source table unavailability | Model should fail gracefully with proper error message | All models |
| TC-EH-002 | Handle schema changes | TRY_CAST should prevent failures on type mismatches | All models |
| TC-EH-003 | Handle audit table creation failure | Models should continue even if audit fails | All models |
| TC-EH-004 | Handle circular dependencies | Audit model should not depend on itself | bz_data_audit |
| TC-EH-005 | Handle memory limitations | Large datasets should be processed in chunks | All models |
| TC-EH-006 | Handle connection timeouts | Long-running queries should have proper timeout handling | All models |
| TC-EH-007 | Handle permission errors | Insufficient permissions should produce clear error messages | All models |
| TC-EH-008 | Handle data corruption | Corrupted data should be identified and isolated | All models |

### Performance Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) |
|--------------|----------------------|------------------|----------|
| TC-PF-001 | Deduplication performance | ROW_NUMBER() should perform efficiently on large datasets | All models |
| TC-PF-002 | Join performance | Foreign key joins should use proper indexing | All models |
| TC-PF-003 | Audit overhead | Audit logging should not significantly impact performance | All models |
| TC-PF-004 | Incremental processing | Models should support incremental refresh patterns | All models |

### Audit Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) |
|--------------|----------------------|------------------|----------|
| TC-AU-001 | Audit record creation | Each model run should create start and success audit records | All models |
| TC-AU-002 | Processing time accuracy | Audit should accurately measure processing duration | bz_data_audit |
| TC-AU-003 | Status consistency | Audit status should match actual execution outcome | bz_data_audit |
| TC-AU-004 | Audit table initialization | Audit table should initialize properly on first run | bz_data_audit |
| TC-AU-005 | Concurrent audit handling | Multiple models running simultaneously should not conflict | bz_data_audit |
| TC-AU-006 | Audit data retention | Old audit records should be managed according to policy | bz_data_audit |
| TC-AU-007 | Audit query performance | Audit queries should not impact main processing | bz_data_audit |
| TC-AU-008 | Audit failure handling | Failed executions should be properly logged | bz_data_audit |

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# tests/schema.yml
version: 2

models:
  # Audit Model Tests
  - name: bz_data_audit
    description: "Audit trail for Bronze layer operations"
    tests:
      - dbt_utils.expression_is_true:
          expression: "record_id is not null"
          config:
            severity: error
    columns:
      - name: record_id
        description: "Unique audit record identifier"
        tests:
          - not_null
          - unique
      - name: source_table
        description: "Source table name"
        tests:
          - not_null
          - accepted_values:
              values: ['BZ_USERS', 'BZ_MEETINGS', 'BZ_PARTICIPANTS', 'BZ_FEATURE_USAGE', 'BZ_SUPPORT_TICKETS', 'BZ_BILLING_EVENTS', 'BZ_LICENSES', 'AUDIT_TABLE_INITIALIZED']
      - name: status
        description: "Execution status"
        tests:
          - not_null
          - accepted_values:
              values: ['STARTED', 'SUCCESS', 'FAILED', 'WARNING']
      - name: processing_time
        description: "Processing duration in seconds"
        tests:
          - dbt_utils.expression_is_true:
              expression: "processing_time >= 0"

  # Users Model Tests
  - name: bz_users
    description: "Bronze layer users table"
    tests:
      - dbt_utils.expression_is_true:
          expression: "load_timestamp <= update_timestamp or update_timestamp is null"
          config:
            severity: warn
    columns:
      - name: user_id
        description: "Unique user identifier"
        tests:
          - not_null
          - unique
      - name: user_name
        description: "User display name"
        tests:
          - not_null
      - name: email
        description: "User email address"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "email like '%@%'"
              config:
                severity: warn
      - name: plan_type
        description: "Subscription plan type"
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise', 'Free']
              config:
                severity: warn
      - name: source_system
        description: "Source system identifier"
        tests:
          - not_null

  # Meetings Model Tests
  - name: bz_meetings
    description: "Bronze layer meetings table"
    tests:
      - dbt_utils.expression_is_true:
          expression: "end_time >= start_time or end_time is null"
          config:
            severity: error
    columns:
      - name: meeting_id
        description: "Unique meeting identifier"
        tests:
          - not_null
          - unique
      - name: host_id
        description: "Meeting host user ID"
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: warn
      - name: meeting_topic
        description: "Meeting topic/title"
        tests:
          - not_null
      - name: start_time
        description: "Meeting start timestamp"
        tests:
          - not_null
      - name: duration_minutes
        description: "Meeting duration in minutes"
        tests:
          - dbt_utils.expression_is_true:
              expression: "duration_minutes >= 0 or duration_minutes is null"

  # Participants Model Tests
  - name: bz_participants
    description: "Bronze layer participants table"
    tests:
      - dbt_utils.expression_is_true:
          expression: "leave_time >= join_time or leave_time is null"
          config:
            severity: error
    columns:
      - name: participant_id
        description: "Unique participant identifier"
        tests:
          - not_null
          - unique
      - name: meeting_id
        description: "Associated meeting ID"
        tests:
          - not_null
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
              config:
                severity: warn
      - name: user_id
        description: "Participant user ID"
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: warn
      - name: join_time
        description: "Participant join timestamp"
        tests:
          - not_null

  # Feature Usage Model Tests
  - name: bz_feature_usage
    description: "Bronze layer feature usage table"
    columns:
      - name: usage_id
        description: "Unique usage record identifier"
        tests:
          - not_null
          - unique
      - name: meeting_id
        description: "Associated meeting ID"
        tests:
          - not_null
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
              config:
                severity: warn
      - name: feature_name
        description: "Name of the feature used"
        tests:
          - not_null
          - accepted_values:
              values: ['Screen Share', 'Recording', 'Chat', 'Breakout Rooms', 'Whiteboard', 'Polls', 'Reactions']
              config:
                severity: warn
      - name: usage_count
        description: "Number of times feature was used"
        tests:
          - dbt_utils.expression_is_true:
              expression: "usage_count >= 0"

  # Support Tickets Model Tests
  - name: bz_support_tickets
    description: "Bronze layer support tickets table"
    columns:
      - name: ticket_id
        description: "Unique ticket identifier"
        tests:
          - not_null
          - unique
      - name: user_id
        description: "Ticket creator user ID"
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: warn
      - name: ticket_type
        description: "Type of support ticket"
        tests:
          - not_null
          - accepted_values:
              values: ['Technical', 'Billing', 'Account', 'Feature Request', 'Bug Report']
              config:
                severity: warn
      - name: resolution_status
        description: "Current ticket status"
        tests:
          - not_null
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed', 'Escalated']
      - name: open_date
        description: "Ticket creation date"
        tests:
          - not_null

  # Billing Events Model Tests
  - name: bz_billing_events
    description: "Bronze layer billing events table"
    columns:
      - name: event_id
        description: "Unique billing event identifier"
        tests:
          - not_null
          - unique
      - name: user_id
        description: "Associated user ID"
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: warn
      - name: event_type
        description: "Type of billing event"
        tests:
          - not_null
          - accepted_values:
              values: ['Charge', 'Refund', 'Credit', 'Subscription', 'Upgrade', 'Downgrade']
      - name: amount
        description: "Billing amount"
        tests:
          - dbt_utils.expression_is_true:
              expression: "amount >= 0 or amount is null"
      - name: event_date
        description: "Billing event date"
        tests:
          - not_null

  # Licenses Model Tests
  - name: bz_licenses
    description: "Bronze layer licenses table"
    tests:
      - dbt_utils.expression_is_true:
          expression: "end_date >= start_date or end_date is null"
          config:
            severity: error
    columns:
      - name: license_id
        description: "Unique license identifier"
        tests:
          - not_null
          - unique
      - name: license_type
        description: "Type of license"
        tests:
          - not_null
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise', 'Developer', 'Trial']
      - name: assigned_to_user_id
        description: "User assigned to license"
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: warn
      - name: start_date
        description: "License start date"
        tests:
          - not_null
```

### Custom SQL-based dbt Tests

```sql
-- tests/test_deduplication_logic.sql
-- Test that deduplication logic works correctly across all models

{{ config(severity = 'error') }}

with duplicate_check as (
  select 'bz_users' as model_name, user_id as pk, count(*) as cnt
  from {{ ref('bz_users') }}
  group by user_id
  having count(*) > 1
  
  union all
  
  select 'bz_meetings' as model_name, meeting_id as pk, count(*) as cnt
  from {{ ref('bz_meetings') }}
  group by meeting_id
  having count(*) > 1
  
  union all
  
  select 'bz_participants' as model_name, participant_id as pk, count(*) as cnt
  from {{ ref('bz_participants') }}
  group by participant_id
  having count(*) > 1
  
  union all
  
  select 'bz_feature_usage' as model_name, usage_id as pk, count(*) as cnt
  from {{ ref('bz_feature_usage') }}
  group by usage_id
  having count(*) > 1
  
  union all
  
  select 'bz_support_tickets' as model_name, ticket_id as pk, count(*) as cnt
  from {{ ref('bz_support_tickets') }}
  group by ticket_id
  having count(*) > 1
  
  union all
  
  select 'bz_billing_events' as model_name, event_id as pk, count(*) as cnt
  from {{ ref('bz_billing_events') }}
  group by event_id
  having count(*) > 1
  
  union all
  
  select 'bz_licenses' as model_name, license_id as pk, count(*) as cnt
  from {{ ref('bz_licenses') }}
  group by license_id
  having count(*) > 1
)

select *
from duplicate_check
```

```sql
-- tests/test_audit_completeness.sql
-- Test that audit records are created for each model execution

{{ config(severity = 'warn') }}

with expected_models as (
  select unnest(array['BZ_USERS', 'BZ_MEETINGS', 'BZ_PARTICIPANTS', 'BZ_FEATURE_USAGE', 'BZ_SUPPORT_TICKETS', 'BZ_BILLING_EVENTS', 'BZ_LICENSES']) as model_name
),

actual_audit as (
  select distinct source_table as model_name
  from {{ ref('bz_data_audit') }}
  where status = 'SUCCESS'
    and load_timestamp >= current_date - 1
),

missing_audit as (
  select e.model_name
  from expected_models e
  left join actual_audit a on e.model_name = a.model_name
  where a.model_name is null
)

select *
from missing_audit
```

```sql
-- tests/test_referential_integrity.sql
-- Test referential integrity across Bronze layer models

{{ config(severity = 'warn') }}

with orphaned_records as (
  -- Meetings with invalid host_id
  select 'bz_meetings' as table_name, 'host_id' as column_name, meeting_id as record_id, host_id as invalid_value
  from {{ ref('bz_meetings') }} m
  left join {{ ref('bz_users') }} u on m.host_id = u.user_id
  where u.user_id is null and m.host_id is not null
  
  union all
  
  -- Participants with invalid meeting_id
  select 'bz_participants' as table_name, 'meeting_id' as column_name, participant_id as record_id, meeting_id as invalid_value
  from {{ ref('bz_participants') }} p
  left join {{ ref('bz_meetings') }} m on p.meeting_id = m.meeting_id
  where m.meeting_id is null and p.meeting_id is not null
  
  union all
  
  -- Participants with invalid user_id
  select 'bz_participants' as table_name, 'user_id' as column_name, participant_id as record_id, user_id as invalid_value
  from {{ ref('bz_participants') }} p
  left join {{ ref('bz_users') }} u on p.user_id = u.user_id
  where u.user_id is null and p.user_id is not null
  
  union all
  
  -- Feature usage with invalid meeting_id
  select 'bz_feature_usage' as table_name, 'meeting_id' as column_name, usage_id as record_id, meeting_id as invalid_value
  from {{ ref('bz_feature_usage') }} f
  left join {{ ref('bz_meetings') }} m on f.meeting_id = m.meeting_id
  where m.meeting_id is null and f.meeting_id is not null
  
  union all
  
  -- Support tickets with invalid user_id
  select 'bz_support_tickets' as table_name, 'user_id' as column_name, ticket_id as record_id, user_id as invalid_value
  from {{ ref('bz_support_tickets') }} s
  left join {{ ref('bz_users') }} u on s.user_id = u.user_id
  where u.user_id is null and s.user_id is not null
  
  union all
  
  -- Billing events with invalid user_id
  select 'bz_billing_events' as table_name, 'user_id' as column_name, event_id as record_id, user_id as invalid_value
  from {{ ref('bz_billing_events') }} b
  left join {{ ref('bz_users') }} u on b.user_id = u.user_id
  where u.user_id is null and b.user_id is not null
  
  union all
  
  -- Licenses with invalid assigned_to_user_id
  select 'bz_licenses' as table_name, 'assigned_to_user_id' as column_name, license_id as record_id, assigned_to_user_id as invalid_value
  from {{ ref('bz_licenses') }} l
  left join {{ ref('bz_users') }} u on l.assigned_to_user_id = u.user_id
  where u.user_id is null and l.assigned_to_user_id is not null
)

select *
from orphaned_records
```

```sql
-- tests/test_data_freshness.sql
-- Test that data is being loaded within acceptable timeframes

{{ config(severity = 'warn') }}

with freshness_check as (
  select 
    'bz_users' as model_name,
    max(load_timestamp) as last_load,
    datediff('hour', max(load_timestamp), current_timestamp()) as hours_since_load
  from {{ ref('bz_users') }}
  
  union all
  
  select 
    'bz_meetings' as model_name,
    max(load_timestamp) as last_load,
    datediff('hour', max(load_timestamp), current_timestamp()) as hours_since_load
  from {{ ref('bz_meetings') }}
  
  union all
  
  select 
    'bz_participants' as model_name,
    max(load_timestamp) as last_load,
    datediff('hour', max(load_timestamp), current_timestamp()) as hours_since_load
  from {{ ref('bz_participants') }}
  
  union all
  
  select 
    'bz_feature_usage' as model_name,
    max(load_timestamp) as last_load,
    datediff('hour', max(load_timestamp), current_timestamp()) as hours_since_load
  from {{ ref('bz_feature_usage') }}
  
  union all
  
  select 
    'bz_support_tickets' as model_name,
    max(load_timestamp) as last_load,
    datediff('hour', max(load_timestamp), current_timestamp()) as hours_since_load
  from {{ ref('bz_support_tickets') }}
  
  union all
  
  select 
    'bz_billing_events' as model_name,
    max(load_timestamp) as last_load,
    datediff('hour', max(load_timestamp), current_timestamp()) as hours_since_load
  from {{ ref('bz_billing_events') }}
  
  union all
  
  select 
    'bz_licenses' as model_name,
    max(load_timestamp) as last_load,
    datediff('hour', max(load_timestamp), current_timestamp()) as hours_since_load
  from {{ ref('bz_licenses') }}
)

select *
from freshness_check
where hours_since_load > 24  -- Alert if data is older than 24 hours
```

```sql
-- tests/test_business_rules.sql
-- Test specific business rules across models

{{ config(severity = 'error') }}

with business_rule_violations as (
  -- Test: Meeting duration should match calculated duration
  select 
    'meeting_duration_mismatch' as rule_name,
    meeting_id as record_id,
    'Duration does not match end_time - start_time' as violation_description
  from {{ ref('bz_meetings') }}
  where duration_minutes is not null 
    and end_time is not null 
    and start_time is not null
    and abs(duration_minutes - datediff('minute', start_time, end_time)) > 1
  
  union all
  
  -- Test: Participant cannot join meeting before it starts
  select 
    'participant_early_join' as rule_name,
    p.participant_id as record_id,
    'Participant joined before meeting started' as violation_description
  from {{ ref('bz_participants') }} p
  join {{ ref('bz_meetings') }} m on p.meeting_id = m.meeting_id
  where p.join_time < m.start_time
  
  union all
  
  -- Test: Feature usage should not exceed meeting duration
  select 
    'excessive_feature_usage' as rule_name,
    f.usage_id as record_id,
    'Feature usage count seems excessive for meeting duration' as violation_description
  from {{ ref('bz_feature_usage') }} f
  join {{ ref('bz_meetings') }} m on f.meeting_id = m.meeting_id
  where f.usage_count > (m.duration_minutes * 2)  -- Arbitrary business rule
    and m.duration_minutes is not null
  
  union all
  
  -- Test: Billing amount should be reasonable
  select 
    'unreasonable_billing_amount' as rule_name,
    event_id as record_id,
    'Billing amount exceeds reasonable threshold' as violation_description
  from {{ ref('bz_billing_events') }}
  where amount > 10000  -- Arbitrary threshold
    and amount is not null
)

select *
from business_rule_violations
```

## Test Execution Strategy

### 1. Continuous Integration Tests
- Run all schema tests on every dbt model build
- Execute custom SQL tests as part of CI/CD pipeline
- Fail builds on severity='error' test failures
- Generate warnings for severity='warn' test failures

### 2. Data Quality Monitoring
- Schedule daily execution of all test cases
- Monitor test results in dbt Cloud or custom dashboard
- Set up alerts for test failures
- Track test performance over time

### 3. Test Result Tracking
- Store test results in Snowflake audit schema
- Create dashboards for test result visualization
- Implement automated reporting for stakeholders
- Maintain historical test result trends

### 4. Performance Optimization
- Optimize test queries for large datasets
- Implement sampling strategies for performance tests
- Use incremental testing where appropriate
- Monitor test execution times

## Expected Outcomes Summary

### Data Quality Assurance
- **100% Primary Key Integrity**: All models maintain unique, non-null primary keys
- **Referential Integrity**: Foreign key relationships are validated and monitored
- **Data Type Consistency**: Safe type casting prevents runtime errors
- **Business Rule Compliance**: Custom business logic is validated

### Operational Excellence
- **Comprehensive Audit Trail**: All operations are logged and trackable
- **Error Prevention**: Edge cases and error scenarios are handled gracefully
- **Performance Monitoring**: Processing times and resource usage are tracked
- **Automated Quality Gates**: CI/CD pipeline includes automated testing

### Maintainability
- **Modular Test Design**: Tests are organized by category and reusable
- **Clear Documentation**: Each test case is well-documented with expected outcomes
- **Version Control**: All test scripts are version controlled
- **Scalable Framework**: Test framework can be extended for new models

This comprehensive testing framework ensures the reliability, performance, and maintainability of the Zoom Bronze Layer dbt models in Snowflake, providing confidence in data quality and enabling successful downstream processing in Silver and Gold layers.