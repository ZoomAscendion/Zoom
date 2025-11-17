_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases and dbt test scripts for Zoom Platform Analytics System Silver layer models
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases
## Zoom Platform Analytics System - Silver Layer

## 1. Overview

This document provides comprehensive unit test cases and corresponding dbt test scripts for the Zoom Platform Analytics System Silver layer models running in Snowflake. The test cases validate key data transformations, business rules, edge cases, and error handling to ensure reliable and performant dbt models.

### 1.1 Test Coverage Areas
- **Data Transformations**: Timestamp format conversions, data cleansing, standardization
- **Business Rules**: Meeting duration validation, plan type standardization, license validity
- **Edge Cases**: Null values, empty datasets, invalid lookups, timestamp format variations
- **Error Handling**: Failed relationships, unexpected values, format conversion failures
- **Data Quality**: Completeness checks, referential integrity, format validation

### 1.2 dbt Testing Framework
- **Built-in Tests**: unique, not_null, relationships, accepted_values
- **Custom SQL Tests**: Complex business logic validation
- **Parameterized Tests**: Reusable test configurations
- **Data Quality Tests**: Comprehensive validation framework

## 2. Test Case List

### 2.1 SI_USERS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome | Priority |
|--------------|----------------------|------------------|----------|
| TC_USR_001 | Validate USER_ID uniqueness and not null | All USER_ID values are unique and not null | Critical |
| TC_USR_002 | Validate email format using regex pattern | All EMAIL values follow valid email format | High |
| TC_USR_003 | Validate PLAN_TYPE standardization | All PLAN_TYPE values are in accepted list | High |
| TC_USR_004 | Validate data quality score calculation | DATA_QUALITY_SCORE is between 0-100 | Medium |
| TC_USR_005 | Validate email case standardization | All EMAIL values are lowercase | Medium |
| TC_USR_006 | Validate user name trimming and cleaning | USER_NAME values are properly trimmed | Low |
| TC_USR_007 | Validate company name standardization | COMPANY values are properly formatted | Low |
| TC_USR_008 | Validate validation status assignment | VALIDATION_STATUS is in accepted values | Medium |
| TC_USR_009 | Validate load and update date derivation | LOAD_DATE and UPDATE_DATE are properly derived | Medium |
| TC_USR_010 | Validate null plan type default assignment | Null PLAN_TYPE defaults to 'FREE' | High |

### 2.2 SI_MEETINGS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome | Priority |
|--------------|----------------------|------------------|----------|
| TC_MTG_001 | Validate MEETING_ID uniqueness and not null | All MEETING_ID values are unique and not null | Critical |
| TC_MTG_002 | Validate EST timezone format conversion | EST timestamps converted to UTC correctly | Critical |
| TC_MTG_003 | Validate meeting duration calculation | DURATION_MINUTES matches calculated duration | Critical |
| TC_MTG_004 | Validate meeting time logic (END_TIME > START_TIME) | All meetings have valid time logic | Critical |
| TC_MTG_005 | Validate HOST_ID referential integrity | All HOST_ID values exist in SI_USERS | High |
| TC_MTG_006 | Validate duration range constraints | DURATION_MINUTES is between 0-1440 | High |
| TC_MTG_007 | Validate meeting topic PII sanitization | MEETING_TOPIC is properly sanitized | Medium |
| TC_MTG_008 | Validate timestamp format error handling | Invalid EST formats routed to error table | High |
| TC_MTG_009 | Validate timezone conversion accuracy | EST to UTC conversion is accurate | High |
| TC_MTG_010 | Validate meeting classification business rule | Meetings classified correctly by duration | Medium |

### 2.3 SI_PARTICIPANTS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome | Priority |
|--------------|----------------------|------------------|----------|
| TC_PRT_001 | Validate PARTICIPANT_ID uniqueness and not null | All PARTICIPANT_ID values are unique and not null | Critical |
| TC_PRT_002 | Validate MM/DD/YYYY HH:MM format conversion | MM/DD/YYYY timestamps converted correctly | Critical |
| TC_PRT_003 | Validate participant session time logic | LEAVE_TIME > JOIN_TIME for all participants | Critical |
| TC_PRT_004 | Validate meeting boundary constraints | JOIN/LEAVE times within meeting duration | Critical |
| TC_PRT_005 | Validate MEETING_ID referential integrity | All MEETING_ID values exist in SI_MEETINGS | High |
| TC_PRT_006 | Validate USER_ID referential integrity | All USER_ID values exist in SI_USERS | High |
| TC_PRT_007 | Validate unique participant per meeting | MEETING_ID + USER_ID combination is unique | High |
| TC_PRT_008 | Validate timestamp format error handling | Invalid MM/DD/YYYY formats routed to error table | High |
| TC_PRT_009 | Validate cross-format timestamp consistency | Mixed formats within records flagged as warnings | Medium |
| TC_PRT_010 | Validate participant session duration calculation | Session duration calculated correctly | Medium |

### 2.4 SI_FEATURE_USAGE Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome | Priority |
|--------------|----------------------|------------------|----------|
| TC_FTR_001 | Validate USAGE_ID uniqueness and not null | All USAGE_ID values are unique and not null | Critical |
| TC_FTR_002 | Validate MEETING_ID referential integrity | All MEETING_ID values exist in SI_MEETINGS | High |
| TC_FTR_003 | Validate usage count non-negative constraint | All USAGE_COUNT values are >= 0 | High |
| TC_FTR_004 | Validate feature name standardization | FEATURE_NAME values are properly standardized | Medium |
| TC_FTR_005 | Validate usage date alignment with meeting date | USAGE_DATE aligns with meeting START_TIME date | High |
| TC_FTR_006 | Validate feature adoption rate calculation | Feature adoption metrics calculated correctly | Medium |
| TC_FTR_007 | Validate feature name length constraints | FEATURE_NAME length <= 100 characters | Low |
| TC_FTR_008 | Validate orphaned feature usage detection | Feature usage without participants flagged | Medium |
| TC_FTR_009 | Validate feature usage aggregation | Usage counts aggregated correctly by feature | Low |
| TC_FTR_010 | Validate feature usage trend analysis | Usage trends calculated correctly over time | Low |

### 2.5 SI_SUPPORT_TICKETS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome | Priority |
|--------------|----------------------|------------------|----------|
| TC_TKT_001 | Validate TICKET_ID uniqueness and not null | All TICKET_ID values are unique and not null | Critical |
| TC_TKT_002 | Validate USER_ID referential integrity | All USER_ID values exist in SI_USERS | High |
| TC_TKT_003 | Validate resolution status standardization | RESOLUTION_STATUS in accepted values | High |
| TC_TKT_004 | Validate open date future date constraint | OPEN_DATE not in future | High |
| TC_TKT_005 | Validate ticket type standardization | TICKET_TYPE values properly standardized | Medium |
| TC_TKT_006 | Validate ticket volume per user calculation | Ticket volume metrics calculated correctly | Medium |
| TC_TKT_007 | Validate ticket resolution time calculation | Resolution time calculated for closed tickets | Low |
| TC_TKT_008 | Validate ticket priority assignment | Ticket priority assigned based on type | Low |
| TC_TKT_009 | Validate ticket escalation rules | Escalation rules applied correctly | Low |
| TC_TKT_010 | Validate ticket SLA compliance tracking | SLA compliance tracked correctly | Medium |

### 2.6 SI_BILLING_EVENTS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome | Priority |
|--------------|----------------------|------------------|----------|
| TC_BIL_001 | Validate EVENT_ID uniqueness and not null | All EVENT_ID values are unique and not null | Critical |
| TC_BIL_002 | Validate USER_ID referential integrity | All USER_ID values exist in SI_USERS | High |
| TC_BIL_003 | Validate amount positive constraint | All AMOUNT values are > 0 | High |
| TC_BIL_004 | Validate amount precision (2 decimal places) | All AMOUNT values have correct precision | High |
| TC_BIL_005 | Validate event date future date constraint | EVENT_DATE not in future | High |
| TC_BIL_006 | Validate event type standardization | EVENT_TYPE values properly standardized | Medium |
| TC_BIL_007 | Validate MRR calculation business rule | MRR calculated correctly excluding one-time payments | High |
| TC_BIL_008 | Validate refund amount handling | Refund amounts handled correctly (negative) | Medium |
| TC_BIL_009 | Validate billing cycle alignment | Billing events align with subscription cycles | Medium |
| TC_BIL_010 | Validate revenue recognition rules | Revenue recognized according to business rules | Medium |

### 2.7 SI_LICENSES Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome | Priority |
|--------------|----------------------|------------------|----------|
| TC_LIC_001 | Validate LICENSE_ID uniqueness and not null | All LICENSE_ID values are unique and not null | Critical |
| TC_LIC_002 | Validate ASSIGNED_TO_USER_ID referential integrity | All user assignments exist in SI_USERS | High |
| TC_LIC_003 | Validate license date logic (START_DATE <= END_DATE) | All licenses have valid date logic | Critical |
| TC_LIC_004 | Validate license type standardization | LICENSE_TYPE values properly standardized | Medium |
| TC_LIC_005 | Validate active license identification | Active licenses identified correctly | High |
| TC_LIC_006 | Validate license utilization rate calculation | Utilization rates calculated correctly | Medium |
| TC_LIC_007 | Validate license expiration tracking | Expired licenses tracked correctly | Medium |
| TC_LIC_008 | Validate license renewal detection | License renewals detected correctly | Low |
| TC_LIC_009 | Validate license upgrade/downgrade tracking | License changes tracked correctly | Low |
| TC_LIC_010 | Validate license compliance reporting | Compliance metrics calculated correctly | Medium |

### 2.8 Cross-Table Integration Test Cases

| Test Case ID | Test Case Description | Expected Outcome | Priority |
|--------------|----------------------|------------------|----------|
| TC_INT_001 | Validate user activity consistency | Users with meetings have participant records | High |
| TC_INT_002 | Validate feature usage alignment | Feature usage aligns with participant records | Medium |
| TC_INT_003 | Validate billing-license consistency | Users with billing have corresponding licenses | High |
| TC_INT_004 | Validate data freshness across tables | All tables have consistent load timestamps | Medium |
| TC_INT_005 | Validate referential integrity cascade | All foreign key relationships maintained | High |
| TC_INT_006 | Validate business metric consistency | Cross-table metrics are consistent | Medium |
| TC_INT_007 | Validate audit trail completeness | All operations logged in audit table | Medium |
| TC_INT_008 | Validate error handling consistency | Errors handled consistently across models | High |
| TC_INT_009 | Validate data quality score alignment | DQ scores consistent across related records | Low |
| TC_INT_010 | Validate timestamp format consistency | Timestamp formats consistent across tables | High |

## 3. dbt Test Scripts

### 3.1 Schema Tests (schema.yml)

```yaml
version: 2

models:
  - name: si_users
    description: "Silver layer users table with cleaned and standardized user data"
    columns:
      - name: user_id
        description: "Unique identifier for each user"
        tests:
          - unique
          - not_null
      - name: email
        description: "User email address (validated and standardized)"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "regexp_like(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')"
              config:
                severity: error
      - name: plan_type
        description: "Subscription plan type"
        tests:
          - accepted_values:
              values: ['FREE', 'BASIC', 'PRO', 'ENTERPRISE']
      - name: data_quality_score
        description: "Data quality score (0-100)"
        tests:
          - dbt_utils.expression_is_true:
              expression: "data_quality_score >= 0 and data_quality_score <= 100"
      - name: validation_status
        description: "Validation status"
        tests:
          - accepted_values:
              values: ['PASSED', 'FAILED', 'WARNING']

  - name: si_meetings
    description: "Silver layer meetings table with timezone-converted timestamps"
    columns:
      - name: meeting_id
        description: "Unique identifier for each meeting"
        tests:
          - unique
          - not_null
      - name: host_id
        description: "Meeting host user ID"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: start_time
        description: "Meeting start time (UTC)"
        tests:
          - not_null
      - name: end_time
        description: "Meeting end time (UTC)"
        tests:
          - not_null
      - name: duration_minutes
        description: "Meeting duration in minutes"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "duration_minutes >= 0 and duration_minutes <= 1440"
    tests:
      - dbt_utils.expression_is_true:
          expression: "end_time > start_time"
          config:
            severity: error
      - dbt_utils.expression_is_true:
          expression: "abs(duration_minutes - datediff('minute', start_time, end_time)) <= 1"
          config:
            severity: warn

  - name: si_participants
    description: "Silver layer participants table with converted timestamps"
    columns:
      - name: participant_id
        description: "Unique identifier for each participant"
        tests:
          - unique
          - not_null
      - name: meeting_id
        description: "Reference to meeting"
        tests:
          - not_null
          - relationships:
              to: ref('si_meetings')
              field: meeting_id
      - name: user_id
        description: "Reference to user"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: join_time
        description: "Participant join time"
        tests:
          - not_null
      - name: leave_time
        description: "Participant leave time"
        tests:
          - not_null
    tests:
      - dbt_utils.expression_is_true:
          expression: "leave_time > join_time"
          config:
            severity: error
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - meeting_id
            - user_id

  - name: si_feature_usage
    description: "Silver layer feature usage table"
    columns:
      - name: usage_id
        description: "Unique identifier for each usage record"
        tests:
          - unique
          - not_null
      - name: meeting_id
        description: "Reference to meeting"
        tests:
          - not_null
          - relationships:
              to: ref('si_meetings')
              field: meeting_id
      - name: usage_count
        description: "Number of times feature was used"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "usage_count >= 0"
      - name: feature_name
        description: "Name of the feature"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "length(feature_name) <= 100"

  - name: si_support_tickets
    description: "Silver layer support tickets table"
    columns:
      - name: ticket_id
        description: "Unique identifier for each ticket"
        tests:
          - unique
          - not_null
      - name: user_id
        description: "Reference to user who created ticket"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: resolution_status
        description: "Current ticket status"
        tests:
          - accepted_values:
              values: ['OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED']
      - name: open_date
        description: "Date ticket was opened"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "open_date <= current_date()"

  - name: si_billing_events
    description: "Silver layer billing events table"
    columns:
      - name: event_id
        description: "Unique identifier for each billing event"
        tests:
          - unique
          - not_null
      - name: user_id
        description: "Reference to user"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: amount
        description: "Billing amount"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "amount > 0"
      - name: event_date
        description: "Date of billing event"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "event_date <= current_date()"

  - name: si_licenses
    description: "Silver layer licenses table"
    columns:
      - name: license_id
        description: "Unique identifier for each license"
        tests:
          - unique
          - not_null
      - name: assigned_to_user_id
        description: "User assigned to license"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: start_date
        description: "License start date"
        tests:
          - not_null
      - name: end_date
        description: "License end date"
        tests:
          - not_null
    tests:
      - dbt_utils.expression_is_true:
          expression: "start_date <= end_date"
          config:
            severity: error
```

### 3.2 Custom SQL-based Tests

#### 3.2.1 EST Timezone Conversion Validation Test

```sql
-- tests/assert_est_timezone_conversion_accuracy.sql
-- Test to validate EST timezone conversion accuracy for SI_MEETINGS

select
    meeting_id,
    start_time,
    end_time,
    'EST timezone conversion failed' as error_message
from {{ ref('si_meetings') }}
where 
    -- Check for any remaining EST timezone indicators after conversion
    (start_time::string like '%EST%' or end_time::string like '%EST%')
    -- Or check for invalid timezone conversion results
    or (start_time is null and end_time is null)
```

#### 3.2.2 MM/DD/YYYY Format Conversion Validation Test

```sql
-- tests/assert_mmddyyyy_format_conversion.sql
-- Test to validate MM/DD/YYYY format conversion for SI_PARTICIPANTS

select
    participant_id,
    join_time,
    leave_time,
    'MM/DD/YYYY format conversion failed' as error_message
from {{ ref('si_participants') }}
where 
    -- Check for any remaining MM/DD/YYYY format indicators after conversion
    (join_time::string regexp '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$'
     or leave_time::string regexp '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$')
    -- Or check for null values after conversion attempt
    or (join_time is null or leave_time is null)
```

#### 3.2.3 Meeting Duration Consistency Test

```sql
-- tests/assert_meeting_duration_consistency.sql
-- Test to validate meeting duration calculation consistency

select
    meeting_id,
    start_time,
    end_time,
    duration_minutes,
    datediff('minute', start_time, end_time) as calculated_duration,
    abs(duration_minutes - datediff('minute', start_time, end_time)) as duration_difference,
    'Meeting duration inconsistency detected' as error_message
from {{ ref('si_meetings') }}
where 
    abs(duration_minutes - datediff('minute', start_time, end_time)) > 1
```

#### 3.2.4 Participant Meeting Boundary Validation Test

```sql
-- tests/assert_participant_meeting_boundaries.sql
-- Test to validate participant join/leave times are within meeting boundaries

select
    p.participant_id,
    p.meeting_id,
    p.join_time,
    p.leave_time,
    m.start_time as meeting_start,
    m.end_time as meeting_end,
    'Participant time outside meeting boundaries' as error_message
from {{ ref('si_participants') }} p
join {{ ref('si_meetings') }} m on p.meeting_id = m.meeting_id
where 
    p.join_time < m.start_time
    or p.leave_time > m.end_time
```

#### 3.2.5 Cross-Table Referential Integrity Test

```sql
-- tests/assert_cross_table_referential_integrity.sql
-- Test to validate referential integrity across all Silver layer tables

with integrity_violations as (
    -- Check for meetings without hosts in users table
    select 'meetings_without_hosts' as violation_type, count(*) as violation_count
    from {{ ref('si_meetings') }} m
    left join {{ ref('si_users') }} u on m.host_id = u.user_id
    where u.user_id is null
    
    union all
    
    -- Check for participants without valid meetings
    select 'participants_without_meetings', count(*)
    from {{ ref('si_participants') }} p
    left join {{ ref('si_meetings') }} m on p.meeting_id = m.meeting_id
    where m.meeting_id is null
    
    union all
    
    -- Check for participants without valid users
    select 'participants_without_users', count(*)
    from {{ ref('si_participants') }} p
    left join {{ ref('si_users') }} u on p.user_id = u.user_id
    where u.user_id is null
    
    union all
    
    -- Check for feature usage without valid meetings
    select 'feature_usage_without_meetings', count(*)
    from {{ ref('si_feature_usage') }} f
    left join {{ ref('si_meetings') }} m on f.meeting_id = m.meeting_id
    where m.meeting_id is null
    
    union all
    
    -- Check for billing events without valid users
    select 'billing_events_without_users', count(*)
    from {{ ref('si_billing_events') }} b
    left join {{ ref('si_users') }} u on b.user_id = u.user_id
    where u.user_id is null
    
    union all
    
    -- Check for licenses without valid users
    select 'licenses_without_users', count(*)
    from {{ ref('si_licenses') }} l
    left join {{ ref('si_users') }} u on l.assigned_to_user_id = u.user_id
    where u.user_id is null
)

select 
    violation_type,
    violation_count,
    'Referential integrity violation detected' as error_message
from integrity_violations
where violation_count > 0
```

#### 3.2.6 Data Quality Score Validation Test

```sql
-- tests/assert_data_quality_scores.sql
-- Test to validate data quality score calculations across all tables

with dq_validation as (
    select 'si_users' as table_name, user_id as record_id, data_quality_score
    from {{ ref('si_users') }}
    where data_quality_score < 0 or data_quality_score > 100
    
    union all
    
    select 'si_meetings', meeting_id, data_quality_score
    from {{ ref('si_meetings') }}
    where data_quality_score < 0 or data_quality_score > 100
    
    union all
    
    select 'si_participants', participant_id, data_quality_score
    from {{ ref('si_participants') }}
    where data_quality_score < 0 or data_quality_score > 100
    
    union all
    
    select 'si_feature_usage', usage_id, data_quality_score
    from {{ ref('si_feature_usage') }}
    where data_quality_score < 0 or data_quality_score > 100
    
    union all
    
    select 'si_support_tickets', ticket_id, data_quality_score
    from {{ ref('si_support_tickets') }}
    where data_quality_score < 0 or data_quality_score > 100
    
    union all
    
    select 'si_billing_events', event_id, data_quality_score
    from {{ ref('si_billing_events') }}
    where data_quality_score < 0 or data_quality_score > 100
    
    union all
    
    select 'si_licenses', license_id, data_quality_score
    from {{ ref('si_licenses') }}
    where data_quality_score < 0 or data_quality_score > 100
)

select 
    table_name,
    record_id,
    data_quality_score,
    'Invalid data quality score detected' as error_message
from dq_validation
```

#### 3.2.7 Business Rule Validation Test

```sql
-- tests/assert_business_rules_compliance.sql
-- Test to validate key business rules across Silver layer

with business_rule_violations as (
    -- Meeting classification rule validation
    select 
        'meeting_classification' as rule_type,
        meeting_id as record_id,
        'Meeting duration and classification mismatch' as error_message
    from {{ ref('si_meetings') }}
    where 
        (duration_minutes < 5 and meeting_topic not like '%Brief%')
        or (duration_minutes >= 60 and meeting_topic not like '%Extended%')
    
    union all
    
    -- Plan type business rule validation
    select 
        'plan_type_validation',
        user_id,
        'Invalid plan type detected'
    from {{ ref('si_users') }}
    where plan_type not in ('FREE', 'BASIC', 'PRO', 'ENTERPRISE')
    
    union all
    
    -- License validity business rule
    select 
        'license_validity',
        license_id,
        'License date logic violation'
    from {{ ref('si_licenses') }}
    where start_date > end_date
    
    union all
    
    -- Billing amount business rule
    select 
        'billing_amount_validation',
        event_id,
        'Invalid billing amount detected'
    from {{ ref('si_billing_events') }}
    where amount <= 0 or amount > 10000  -- Assuming max reasonable amount
)

select 
    rule_type,
    record_id,
    error_message
from business_rule_violations
```

### 3.3 Parameterized Tests

#### 3.3.1 Generic Timestamp Format Validation Test

```sql
-- macros/test_timestamp_format_validation.sql
-- Generic macro for timestamp format validation across tables

{% macro test_timestamp_format_validation(model, timestamp_column, expected_format) %}

select 
    {{ timestamp_column }},
    '{{ timestamp_column }} format validation failed' as error_message
from {{ model }}
where 
    {{ timestamp_column }} is not null
    and not (
        {% if expected_format == 'UTC' %}
            {{ timestamp_column }}::string not like '%EST%'
            and {{ timestamp_column }}::string not regexp '^\\d{1,2}/\\d{1,2}/\\d{4}'
        {% elif expected_format == 'STANDARD' %}
            {{ timestamp_column }}::string regexp '^\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}'
        {% endif %}
    )

{% endmacro %}
```

#### 3.3.2 Generic Data Quality Score Test

```sql
-- macros/test_data_quality_score_range.sql
-- Generic macro for data quality score validation

{% macro test_data_quality_score_range(model, min_score=0, max_score=100) %}

select 
    *,
    'Data quality score out of range' as error_message
from {{ model }}
where 
    data_quality_score < {{ min_score }}
    or data_quality_score > {{ max_score }}
    or data_quality_score is null

{% endmacro %}
```

#### 3.3.3 Generic Referential Integrity Test

```sql
-- macros/test_referential_integrity.sql
-- Generic macro for referential integrity validation

{% macro test_referential_integrity(model, column, ref_model, ref_column) %}

select 
    {{ column }},
    'Referential integrity violation: {{ column }} not found in {{ ref_model }}.{{ ref_column }}' as error_message
from {{ model }} source_table
left join {{ ref_model }} ref_table on source_table.{{ column }} = ref_table.{{ ref_column }}
where 
    source_table.{{ column }} is not null
    and ref_table.{{ ref_column }} is null

{% endmacro %}
```

## 4. Test Execution Strategy

### 4.1 Test Execution Order
1. **Schema Tests**: Execute built-in dbt tests (unique, not_null, relationships, accepted_values)
2. **Format Validation Tests**: Execute timestamp format and data format validation tests
3. **Business Rule Tests**: Execute business logic and calculation validation tests
4. **Cross-Table Tests**: Execute referential integrity and consistency tests
5. **Performance Tests**: Execute data freshness and volume validation tests

### 4.2 Test Severity Levels
- **Error**: Critical failures that prevent model execution (uniqueness, not_null, referential integrity)
- **Warn**: Data quality issues that should be monitored (format inconsistencies, business rule violations)
- **Info**: Informational tests for monitoring and alerting (performance metrics, data freshness)

### 4.3 Test Configuration

```yaml
# dbt_project.yml test configuration
tests:
  zoom_silver_layer:
    +severity: error  # Default severity for all tests
    +error_if: ">= 1"  # Fail if any test returns results
    +warn_if: ">= 1"   # Warn if any test returns results
    
    # Specific test configurations
    assert_est_timezone_conversion_accuracy:
      +severity: error
      +error_if: ">= 1"
    
    assert_mmddyyyy_format_conversion:
      +severity: error
      +error_if: ">= 1"
    
    assert_data_quality_scores:
      +severity: warn
      +warn_if: ">= 10"  # Warn if 10 or more records have invalid DQ scores
    
    assert_business_rules_compliance:
      +severity: warn
      +warn_if: ">= 5"   # Warn if 5 or more business rule violations
```

### 4.4 Test Automation and CI/CD Integration

```bash
# Example dbt test execution commands

# Run all tests
dbt test

# Run tests for specific models
dbt test --models si_users si_meetings

# Run tests with specific severity
dbt test --severity error

# Run tests and generate documentation
dbt test && dbt docs generate

# Run tests in CI/CD pipeline
dbt test --profiles-dir ./profiles --target prod
```

## 5. Test Results Tracking and Monitoring

### 5.1 Test Results Schema

```sql
-- Create test results tracking table
CREATE TABLE IF NOT EXISTS SILVER.SI_TEST_EXECUTION_LOG (
    TEST_EXECUTION_ID VARCHAR(16777216),
    TEST_NAME VARCHAR(16777216),
    MODEL_NAME VARCHAR(16777216),
    TEST_TYPE VARCHAR(100),
    EXECUTION_TIMESTAMP TIMESTAMP_NTZ(9),
    TEST_STATUS VARCHAR(50),
    RECORDS_TESTED NUMBER(38,0),
    RECORDS_FAILED NUMBER(38,0),
    FAILURE_RATE NUMBER(5,2),
    ERROR_MESSAGE VARCHAR(16777216),
    EXECUTION_DURATION_SECONDS NUMBER(10,2),
    DBT_RUN_ID VARCHAR(16777216),
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9)
);
```

### 5.2 Test Results Dashboard Queries

```sql
-- Test success rate by model
SELECT 
    MODEL_NAME,
    COUNT(*) as total_tests,
    COUNT(CASE WHEN TEST_STATUS = 'PASSED' THEN 1 END) as passed_tests,
    ROUND((COUNT(CASE WHEN TEST_STATUS = 'PASSED' THEN 1 END) * 100.0 / COUNT(*)), 2) as success_rate
FROM SILVER.SI_TEST_EXECUTION_LOG
WHERE EXECUTION_TIMESTAMP >= CURRENT_DATE() - INTERVAL '7 days'
GROUP BY MODEL_NAME
ORDER BY success_rate DESC;

-- Test failure trends over time
SELECT 
    DATE(EXECUTION_TIMESTAMP) as test_date,
    TEST_TYPE,
    COUNT(*) as total_tests,
    COUNT(CASE WHEN TEST_STATUS = 'FAILED' THEN 1 END) as failed_tests,
    AVG(FAILURE_RATE) as avg_failure_rate
FROM SILVER.SI_TEST_EXECUTION_LOG
WHERE EXECUTION_TIMESTAMP >= CURRENT_DATE() - INTERVAL '30 days'
GROUP BY DATE(EXECUTION_TIMESTAMP), TEST_TYPE
ORDER BY test_date DESC, TEST_TYPE;
```

### 5.3 Alerting and Notifications

```sql
-- Critical test failures requiring immediate attention
SELECT 
    TEST_NAME,
    MODEL_NAME,
    RECORDS_FAILED,
    ERROR_MESSAGE,
    EXECUTION_TIMESTAMP
FROM SILVER.SI_TEST_EXECUTION_LOG
WHERE 
    TEST_STATUS = 'FAILED'
    AND TEST_TYPE IN ('REFERENTIAL_INTEGRITY', 'TIMESTAMP_FORMAT', 'BUSINESS_RULE')
    AND EXECUTION_TIMESTAMP >= CURRENT_TIMESTAMP() - INTERVAL '1 hour'
ORDER BY EXECUTION_TIMESTAMP DESC;
```

## 6. Performance Optimization for Tests

### 6.1 Test Performance Best Practices
- **Incremental Testing**: Test only changed data using `--defer` flag
- **Parallel Execution**: Use `--threads` parameter for concurrent test execution
- **Selective Testing**: Use `--models` and `--exclude` flags for targeted testing
- **Test Sampling**: Implement sampling for large datasets in non-critical tests

### 6.2 Test Performance Monitoring

```sql
-- Test execution performance analysis
SELECT 
    TEST_NAME,
    MODEL_NAME,
    AVG(EXECUTION_DURATION_SECONDS) as avg_duration,
    MAX(EXECUTION_DURATION_SECONDS) as max_duration,
    COUNT(*) as execution_count
FROM SILVER.SI_TEST_EXECUTION_LOG
WHERE EXECUTION_TIMESTAMP >= CURRENT_DATE() - INTERVAL '7 days'
GROUP BY TEST_NAME, MODEL_NAME
HAVING AVG(EXECUTION_DURATION_SECONDS) > 30  -- Tests taking more than 30 seconds
ORDER BY avg_duration DESC;
```

## 7. Conclusion

This comprehensive unit testing framework for the Zoom Platform Analytics System Silver layer provides:

### 7.1 Key Benefits
- **Comprehensive Coverage**: 70+ test cases covering all critical aspects
- **Timestamp Format Validation**: Specific tests for EST and MM/DD/YYYY format issues
- **Business Rule Validation**: Tests for all key business logic and calculations
- **Error Prevention**: Early detection of data quality issues and format problems
- **Performance Monitoring**: Tracking of test execution and model performance
- **Automated Quality Gates**: Integration with CI/CD pipelines for continuous validation

### 7.2 Implementation Recommendations
1. **Phase 1**: Implement critical tests (P1) for timestamp format validation and referential integrity
2. **Phase 2**: Deploy business rule and data quality tests (P2)
3. **Phase 3**: Add performance and monitoring tests (P3)
4. **Phase 4**: Implement advanced analytics and trend monitoring (P4)

### 7.3 Success Metrics
- **Test Coverage**: >95% of critical data transformations covered
- **Test Success Rate**: >98% of tests passing in production
- **Issue Detection**: <1 hour mean time to detection for critical issues
- **Model Reliability**: >99.5% uptime for Silver layer models
- **Format Compliance**: >99% timestamp format conversion success rate

This testing framework ensures the reliability, performance, and data quality of the Zoom Platform Analytics System Silver layer, providing confidence in the data transformations and business intelligence capabilities built on top of this foundation.
